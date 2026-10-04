import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/bible_model.dart';
import '../data/models/translation_model.dart';
import 'translation_pack_store.dart';

/// Offline-first content store for the bundled Bible database.
///
/// Guarantees:
/// - The core database is schema-probed on every open and fully
///   integrity-checked after every copy.
/// - A missing, corrupt, stale (upgrade / downgrade / test-APK) or partial
///   copy is automatically re-materialized from the bundled asset — the app
///   can never get stuck with a permanently blank database.
/// - Copies are atomic (write -> verify -> publish) with progress for
///   first-run UI; failures are loud ([StateError]) instead of silent blanks.
/// - `onOpen` hooks never throw: they tolerate partial databases; repair is
///   handled by [_initDB] via [_probeCore].
class BibleDatabaseService {
  static const String _dbName = 'bible.db';

  /// Content generation id. Bump when the bundled content assets or the
  /// on-disk layout change. Any mismatch (upgrade, downgrade, test APK,
  /// corruption repair) converges by re-materializing from asset.
  ///
  /// History: 1 = single-file layout (P0); 2 = core + translation packs
  /// (KJV + KJV-Strong's backbone); 3 = BBE joins the backbone in core,
  /// KJV-Strong's becomes a downloadable pack.
  static const int contentVersion = 3;
  static const String _contentVersionKey = 'content_version';
  static const String _repairAttemptsKey = 'content_repair_attempts';
  static const int _maxRepairAttempts = 2;

  /// Legacy version key, kept in sync so older builds don't needlessly
  /// re-copy when run against a database installed by a newer build.
  static const int _legacyRequiredDbVersion = 12;

  /// Core tables every usable database must contain.
  static const List<String> _requiredTables = [
    'verses',
    'translations',
    'dictionary',
    'cross_references',
    'strongs_lexicon',
  ];

  Database? _db;
  Future<Database>? _installing;

  final TranslationPackStore _packStore = TranslationPackStore();

  final StreamController<double> _installProgressController =
      StreamController<double>.broadcast();

  /// 0..1 progress of the active content install (first run / upgrade /
  /// repair). Emits nothing while idle.
  Stream<double> get installProgress => _installProgressController.stream;

  /// Bytes used on device by the core database, journals and installed
  /// translation packs. Powers the Storage row in Settings.
  Future<int> contentBytesUsed() async {
    var total = 0;
    try {
      final dbDir = await getApplicationSupportDirectory();
      await for (final entry in Directory(dbDir.path).list(recursive: true)) {
        if (entry is File &&
            (entry.path.endsWith('.db') ||
                entry.path.endsWith('.db-wal') ||
                entry.path.endsWith('.db-shm'))) {
          try {
            total += await entry.length();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return total;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _installing ??= _initDB();
    try {
      _db = await _installing!;
      return _db!;
    } finally {
      _installing = null;
    }
  }

  void _emitProgress(double value) {
    if (_installProgressController.isClosed) return;
    final v = value < 0 ? 0.0 : (value > 1 ? 1.0 : value);
    _installProgressController.add(v);
  }

  int _storedContentVersion(SharedPreferences prefs) {
    final v = prefs.getInt(_contentVersionKey);
    if (v != null) return v;
    // Legacy migration: db_version 12 == the P0 single-file layout.
    final legacy = prefs.getInt('db_version') ?? 1;
    return legacy >= _legacyRequiredDbVersion ? 1 : 0;
  }

  Future<int> _repairAttempts(SharedPreferences prefs) async {
    return prefs.getInt(_repairAttemptsKey) ?? 0;
  }

  Future<void> _recordRepairAttempt(SharedPreferences prefs) async {
    final n = await _repairAttempts(prefs);
    await prefs.setInt(_repairAttemptsKey, n + 1);
  }

  Future<void> _clearRepairAttempts(SharedPreferences prefs) async {
    await prefs.remove(_repairAttemptsKey);
  }

  Future<Database> _initDB() async {
    final dbDir = await getApplicationSupportDirectory();
    final dbPath = join(dbDir.path, _dbName);
    final prefs = await SharedPreferences.getInstance();
    final stored = _storedContentVersion(prefs);

    final dbFile = File(dbPath);
    if (!await dbFile.exists() || stored < contentVersion) {
      if (stored == 2 && await dbFile.exists()) {
        // V2 -> V3 layout migration: KJV-Strong's leaves the core for a
        // pack file, BBE joins the core backbone (from the user's pack
        // file, or from the bundled core asset as fallback).
        try {
          await _migrateV2ToV3(dbPath, prefs);
        } catch (e) {
          stderr.writeln('DB v2->v3 migration failed, reinstalling: $e');
          await _installFromAsset(dbPath, prefs, preservePacks: true);
        }
      } else if (stored == 1 && await dbFile.exists()) {
        // P2 layout migration: extract translations into pack files
        // in place (preserves bundled + downloaded translations).
        // (With current backbone ids this lands directly on v3.)
        try {
          await _migrateToPacks(dbPath, prefs);
        } catch (e) {
          stderr.writeln('DB pack migration failed, reinstalling: $e');
          await _installFromAsset(dbPath, prefs, preservePacks: true);
        }
      } else {
        await _installFromAsset(
          dbPath,
          prefs,
          preservePacks: await dbFile.exists(),
        );
      }
    }

    // Bundled packs must be present (fresh installs, repairs, or packs
    // lost outside the app). Cheap no-op when everything is in place;
    // never resurrects packs the user deleted.
    await _packStore.ensureBundledPacks(
      skipIds: await _packStore.deletedPackIds(),
    );

    var db = await _openGuarded(dbPath);
    // Converge interrupted migrations: legacy translation rows must not
    // linger in the core database.
    if (await _hasLegacyTranslationRows(db)) {
      if (await _repairAttempts(prefs) >= _maxRepairAttempts) {
        throw StateError(
          'Bible database has an unsupported layout. '
          'Please check storage space, then retry or reinstall the app.',
        );
      }
      try {
        await db.close();
      } catch (_) {}
      _db = null;
      try {
        await _migrateToPacks(dbPath, prefs);
      } catch (e) {
        stderr.writeln('DB pack migration failed, reinstalling: $e');
        await _recordRepairAttempt(prefs);
        await _installFromAsset(dbPath, prefs, preservePacks: true);
      }
      await _packStore.ensureBundledPacks(
        skipIds: await _packStore.deletedPackIds(),
      );
      db = await _openGuarded(dbPath);
    }

    var problems = await _probeCore(db);
    if (problems.isEmpty) {
      await _clearRepairAttempts(prefs);
      return db;
    }

    // Self-heal: the on-disk file is unusable (e.g. a partial copy from an
    // interrupted first run, or a downgrade/test-APK mismatch). Re-materialize
    // from the bundled asset, then re-verify. Bounded so a device that can
    // never hold a good copy fails loudly instead of looping.
    if (await _repairAttempts(prefs) >= _maxRepairAttempts) {
      throw StateError(
        'Bible database failed verification (${problems.join('; ')}). '
        'Please check storage space, then retry or reinstall the app.',
      );
    }
    try {
      await db.close();
    } catch (_) {}
    _db = null;
    _emitProgress(0);
    await _installFromAsset(dbPath, prefs, preservePacks: true);
    db = await _openGuarded(dbPath);
    problems = await _probeCore(db);
    if (problems.isEmpty) {
      await _clearRepairAttempts(prefs);
      return db;
    }
    await _recordRepairAttempt(prefs);
    throw StateError(
      'Bible database failed verification after repair (${problems.join('; ')}). '
      'Please check storage space, then retry or reinstall the app.',
    );
  }

  /// Copies the bundled asset into place atomically, verifies it, preserves
  /// user-downloaded translation packs from the previous file (best effort),
  /// then stamps the content version. Throws on failure; callers retry later.
  Future<void> _installFromAsset(
    String dbPath,
    SharedPreferences prefs, {
    required bool preservePacks,
  }) async {
    final backupPath = join(dirname(dbPath), 'bible_backup.db');
    final dbFile = File(dbPath);
    final backupFile = File(backupPath);

    String? backupForPreserve;
    if (await dbFile.exists()) {
      try {
        if (await backupFile.exists()) await backupFile.delete();
        await dbFile.rename(backupPath);
        if (preservePacks) backupForPreserve = backupPath;
      } catch (e) {
        stderr.writeln('DB install: could not stage backup: $e');
      }
    }

    var copyOk = false;
    try {
      await _copyAssetDb(dbPath);
      await _verifyCopiedDb(dbPath);
      copyOk = true;
      if (backupForPreserve != null) {
        await _preserveDownloadedPacks(dbPath, backupForPreserve);
      }
      // Bundled packs must be present on every fresh install / repair.
      // Skips packs the user deleted; no-op when everything is in place.
      await _packStore.ensureBundledPacks(
        skipIds: await _packStore.deletedPackIds(),
        onProgress: (p) => _emitProgress(0.8 + 0.15 * p),
      );
      // Backbone translations live in the core DB only: drop any stale
      // pack files for them so there is never a duplicate copy.
      for (final id in TranslationPackStore.coreIds) {
        await _packStore.forgetPack(id);
      }
    } catch (e) {
      stderr.writeln('DB install error: $e');
      if (!copyOk) {
        try {
          if (await dbFile.exists()) await dbFile.delete();
        } catch (_) {}
      }
      // If we clobbered a (possibly working) file and the copy failed,
      // put the backup back so the app can still run.
      try {
        if (backupForPreserve != null && !await dbFile.exists()) {
          await File(backupForPreserve).copy(dbPath);
        }
      } catch (_) {}
      rethrow;
    }

    try {
      if (await backupFile.exists()) await backupFile.delete();
    } catch (_) {}

    await prefs.setInt(_contentVersionKey, contentVersion);
    await prefs.setInt('db_version', _legacyRequiredDbVersion);
    _emitProgress(1.0);
  }

  /// Streams the bundled asset to [dbPath] in chunks so first-run UI can
  /// show progress. Deletes the partial file on failure.
  Future<void> _copyAssetDb(String dbPath) async {
    await Directory(dirname(dbPath)).create(recursive: true);
    final data = await rootBundle.load('assets/bible/$_dbName');
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    const chunk = 1024 * 1024;
    final out = File(dbPath).openWrite();
    try {
      for (var off = 0; off < bytes.length; off += chunk) {
        final end =
            (off + chunk > bytes.length) ? bytes.length : off + chunk;
        out.add(bytes.sublist(off, end));
        // Copy phase reports 0..0.75; packs take it to ~0.95.
        _emitProgress(0.75 * end / bytes.length);
      }
      await out.flush();
      await out.close();
    } catch (_) {
      try {
        await out.close();
      } catch (_) {}
      try {
        await File(dbPath).delete();
      } catch (_) {}
      rethrow;
    }
  }

  /// Opens a freshly copied database read-only and runs a full integrity
  /// check plus the core schema probe. Throws if anything is wrong.
  Future<void> _verifyCopiedDb(String dbPath) async {
    Database? tmp;
    try {
      tmp = await openDatabase(dbPath, readOnly: true);
      final qc = await tmp.rawQuery('PRAGMA quick_check');
      final ok = qc.isNotEmpty && '${qc.first.values.first}' == 'ok';
      final problems =
          ok ? await _probeCore(tmp) : ['integrity check failed'];
      if (problems.isNotEmpty) {
        throw StateError(
            'Copied database failed verification: ${problems.join('; ')}');
      }
      _emitProgress(0.8);
    } finally {
      try {
        await tmp?.close();
      } catch (_) {}
    }
  }

  /// Cheap structural probe used on every open: required tables present,
  /// `translations` queryable, and the KJV backbone (never-missing content)
  /// contains verses. Never throws — returns problem descriptions.
  Future<List<String>> _probeCore(Database db) async {
    final problems = <String>[];
    try {
      final rows = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table'");
      final tables = <String>{};
      for (final r in rows) {
        final n = r['name'];
        if (n is String) tables.add(n);
      }
      for (final t in _requiredTables) {
        if (!tables.contains(t)) problems.add('missing table: $t');
      }
      if (!tables.contains('verses') || !tables.contains('translations')) {
        return problems;
      }
      // Both backbone translations must be present and readable.
      for (final entry in {'kjv': 'KJV', 'bbe': 'BBE'}.entries) {
        try {
          final rows = await db.rawQuery(
              "SELECT COUNT(*) AS c FROM verses WHERE translation_id = '${entry.key}'");
          final count = (rows.first['c'] as num?)?.toInt() ?? 0;
          if (count == 0) {
            problems.add('${entry.value} backbone has no verses');
          }
        } catch (e) {
          problems.add('${entry.value} backbone unreadable: $e');
        }
      }
    } catch (e) {
      problems.add('probe error: $e');
    }
    return problems;
  }

  /// Best-effort carry-over of translations from the previous database
  /// file into standalone pack files (P2 layout). Bundled-era rows
  /// (bbe/web) travel along so the user keeps what they had; the pack
  /// store marks bundled ids accordingly. Never throws: a bad backup must
  /// not break the install (the fresh core copy is already verified).
  Future<void> _preserveDownloadedPacks(
      String dbPath, String backupPath) async {
    Database? backupDb;
    try {
      // Never resurrect packs the user deleted.
      final deleted = await _packStore.deletedPackIds();
      backupDb = await openDatabase(backupPath, readOnly: true);
      await _packStore.extractFromDatabase(
        backupDb,
        shouldExtract: (id) =>
            !TranslationPackStore.isCoreId(id) && !deleted.contains(id),
      );
    } catch (e) {
      stderr.writeln('DB preserve downloaded packs failed: $e');
    } finally {
      try {
        await backupDb?.close();
      } catch (_) {}
    }
  }

  /// P2 layout migration: extracts every non-backbone translation out of a
  /// legacy single-file database into standalone pack files, then slims the
  /// core database down to the KJV backbone + reference tables. Stamps
  /// content version 2 on success. Throws on failure (caller reinstalls).
  Future<void> _migrateToPacks(
      String dbPath, SharedPreferences prefs) async {
    Database? db;
    try {
      db = await _openGuarded(dbPath);
      final problems = await _probeCore(db);
      if (problems.isNotEmpty) {
        throw StateError(
            'Cannot migrate unreadable database: ${problems.join('; ')}');
      }
      final deleted = await _packStore.deletedPackIds();
      final extracted = await _packStore.extractFromDatabase(
        db,
        shouldExtract: (id) =>
            !TranslationPackStore.isCoreId(id) && !deleted.contains(id),
      );
      if (extracted.isNotEmpty) {
        const keep = "'kjv','kjv_strongs'";
        await db.execute(
            'DELETE FROM verses WHERE translation_id NOT IN ($keep)');
        await db.execute(
            'DELETE FROM translations WHERE translation_id NOT IN ($keep)');
        // One-time compaction (~50 MB rewrite). Cannot report progress.
        await db.execute('VACUUM');
      }
    } finally {
      try {
        await db?.close();
      } catch (_) {}
    }
    // Re-verify the slimmed core before publishing the version stamp.
    final check = await _openGuarded(dbPath);
    try {
      final problems = await _probeCore(check);
      if (problems.isNotEmpty) {
        throw StateError(
            'Migrated database failed verification: ${problems.join('; ')}');
      }
    } finally {
      try {
        await check.close();
      } catch (_) {}
    }
    await prefs.setInt(_contentVersionKey, contentVersion);
    await prefs.setInt('db_version', _legacyRequiredDbVersion);
    _emitProgress(1.0);
  }

  /// V2 -> V3 layout migration, run once per device:
  /// 1. KJV-Strong's rows leave the core for a standalone pack file, so
  ///    the translation becomes downloadable/deletable like the rest.
  /// 2. BBE joins the core backbone: merged in from the user's BBE pack
  ///    file when present, otherwise seeded from the bundled core asset
  ///    (written to a temp file, attached, then removed).
  /// Idempotent: every step checks current state first. Throws on failure
  /// (caller falls back to a fresh install which salvages packs).
  Future<void> _migrateV2ToV3(String dbPath, SharedPreferences prefs) async {
    var changed = false;
    Database? db;
    try {
      db = await _openGuarded(dbPath);

      // Step 1: move KJV-Strong's out of the core into its pack file.
      final packFile =
          File(join(dirname(dbPath), 'packs', 'kjv_strongs.db'));
      final coreIds = await db
          .query('translations', columns: ['translation_id']);
      final inCore = {
        for (final r in coreIds) r['translation_id'] as String
      };
      if (inCore.contains('kjv_strongs') && !await packFile.exists()) {
        await _packStore.extractFromDatabase(
          db,
          shouldExtract: (id) => id == 'kjv_strongs',
        );
        await db.execute(
            "DELETE FROM verses WHERE translation_id = 'kjv_strongs'");
        await db.execute(
            "DELETE FROM translations WHERE translation_id = 'kjv_strongs'");
        changed = true;
      }

      // Step 2: ensure BBE lives in the core.
      if (!inCore.contains('bbe') ||
          (await db.rawQuery(
                  "SELECT COUNT(*) AS c FROM verses WHERE translation_id = 'bbe'"))
                  .first['c'] ==
              0) {
        await _seedBbeIntoCore(db, dbPath);
        changed = true;
      }

      if (changed) {
        // One-time compaction after the row moves.
        await db.execute('VACUUM');
      }
    } finally {
      try {
        await db?.close();
      } catch (_) {}
    }
    // Re-verify before publishing the version stamp.
    final check = await _openGuarded(dbPath);
    try {
      final problems = await _probeCore(check);
      if (problems.isNotEmpty) {
        throw StateError(
            'Migrated database failed verification: ${problems.join('; ')}');
      }
    } finally {
      try {
        await check.close();
      } catch (_) {}
    }
    await prefs.setInt(_contentVersionKey, contentVersion);
    await prefs.setInt('db_version', _legacyRequiredDbVersion);
    _emitProgress(1.0);
  }

  /// Copies BBE verses + catalog row into the core database: from the
  /// user's installed BBE pack file when present, otherwise from the
  /// bundled core asset (materialized to a temp file first, then removed).
  Future<void> _seedBbeIntoCore(Database db, String dbPath) async {
    final packFile = File(join(dirname(dbPath), 'packs', 'bbe.db'));
    File? tmpAsset;
    try {
      String seedPath;
      if (await packFile.exists()) {
        seedPath = packFile.path;
      } else {
        final data = await rootBundle.load('assets/bible/$_dbName');
        final bytes = data.buffer
            .asUint8List(data.offsetInBytes, data.lengthInBytes);
        tmpAsset = File(join(dirname(dbPath), 'bbe_seed.tmp.db'));
        await tmpAsset.writeAsBytes(bytes, flush: true);
        seedPath = tmpAsset.path;
      }
      final escaped = seedPath.replaceAll("'", "''");
      await db.execute("ATTACH DATABASE '$escaped' AS bbeseed;");
      try {
        final cols = await db.rawQuery('PRAGMA table_info(translations)');
        final names = {for (final c in cols) c['name'] as String};
        final extra =
            names.contains('is_downloaded') ? ', is_downloaded' : '';
        // Idempotent: clear first so re-runs never duplicate verses.
        await db.execute("DELETE FROM verses WHERE translation_id = 'bbe'");
        await db.execute(
            'INSERT INTO verses SELECT translation_id, language_code, '
            'book_number, chapter, verse, text FROM bbeseed.verses '
            "WHERE translation_id = 'bbe'");
        await db.execute(
            'INSERT OR REPLACE INTO translations (translation_id, '
            'language_code, language_name, translation_name, abbreviation, '
            'license, is_complete$extra) '
            'SELECT translation_id, language_code, language_name, '
            'translation_name, abbreviation, license, is_complete$extra '
            'FROM bbeseed.translations '
            "WHERE translation_id = 'bbe'");
      } finally {
        try {
          await db.execute('DETACH DATABASE bbeseed;');
        } catch (_) {}
      }
      // BBE now lives in the core: drop the redundant pack file (if any)
      // so there is exactly one copy. Not recorded as user-deleted.
      await _packStore.forgetPack('bbe');
    } finally {
      try {
        if (tmpAsset != null && await tmpAsset.exists()) {
          await tmpAsset.delete();
        }
      } catch (_) {}
    }
  }

  /// True when the core database still holds legacy (non-backbone)
  /// translation rows — i.e. a pack-layout migration is pending.
  Future<bool> _hasLegacyTranslationRows(Database db) async {
    try {
      final rows =
          await db.query('translations', columns: ['translation_id']);
      for (final r in rows) {
        final tid = r['translation_id'] as String?;
        if (tid != null &&
            tid.isNotEmpty &&
            !TranslationPackStore.isCoreId(tid)) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }


  /// Opens the installed database. Hooks are fully guarded so a partial or
  /// corrupt file can never throw here — [_initDB] verifies and repairs via
  /// [_probeCore] instead.
  Future<Database> _openGuarded(String dbPath) {
    return openDatabase(
      dbPath,
      readOnly: false,
      onConfigure: (db) async {
        try {
          await db.rawQuery('PRAGMA journal_mode=WAL;');
        } catch (_) {}
      },
      onOpen: (db) async {
        try {
          final rows = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type = 'table'");
          final tables = <String>{};
          for (final r in rows) {
            final n = r['name'];
            if (n is String) tables.add(n);
          }
          if (tables.contains('translations')) {
            try {
              final cols =
                  await db.rawQuery('PRAGMA table_info(translations);');
              if (!cols.any((c) => c['name'] == 'is_downloaded')) {
                await db.execute(
                    'ALTER TABLE translations ADD COLUMN is_downloaded INTEGER NOT NULL DEFAULT 0;');
              }
            } catch (e) {
              stderr.writeln('DB onOpen is_downloaded guard: $e');
            }
          }
          try {
            await db.execute('''
          CREATE TABLE IF NOT EXISTS reading_plans (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            days_count INTEGER NOT NULL,
            category TEXT,
            plan_json TEXT NOT NULL
          );
        ''');
          } catch (_) {}
          try {
            await db.execute('''
          CREATE TABLE IF NOT EXISTS user_plan_progress (
            plan_id TEXT,
            day_number INTEGER,
            completed_at INTEGER,
            PRIMARY KEY (plan_id, day_number)
          );
        ''');
          } catch (_) {}
        } catch (_) {}
      },
    );
  }

  /// Routes a translation id to its database: backbone ids (kjv,
  /// kjv_strongs) live in the core database, everything else in its
  /// standalone pack file (opened lazily, read-only). Throws [StateError]
  /// when the translation is not installed — callers render restore /
  /// download UI instead of blank content.
  Future<Database> _dbForTranslation(String translationId) async {
    if (TranslationPackStore.isCoreId(translationId)) return database;
    return _packStore.openPack(translationId);
  }

  Future<List<TranslationInfo>> getTranslations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      orderBy: 'language_name ASC, translation_name ASC',
    );
    final infos = maps.map((map) => TranslationInfo.fromMap(map)).toList();
    for (final meta in await _packStore.installedPacks()) {
      infos.add(meta.toInfo());
    }
    infos.sort((a, b) {
      final l = a.languageName.compareTo(b.languageName);
      return l != 0 ? l : a.translationName.compareTo(b.translationName);
    });
    return infos;
  }

  Future<List<BibleVerse>> getChapter(
      String translationId, int bookNumber, int chapterNumber) async {
    final db = await _dbForTranslation(translationId);
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      columns: ['verse', 'text'],
      where: 'translation_id = ? AND book_number = ? AND chapter = ?',
      whereArgs: [translationId, bookNumber, chapterNumber],
      orderBy: 'verse ASC',
    );

    return maps
        .map((map) => BibleVerse(
              number: map['verse'] as int,
              text: map['text'] as String,
            ))
        .toList();
  }

  Future<BibleVerse?> getVerse(String translationId, int bookNumber,
      int chapterNumber, int verseNumber) async {
    final db = await _dbForTranslation(translationId);
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      columns: ['verse', 'text'],
      where:
          'translation_id = ? AND book_number = ? AND chapter = ? AND verse = ?',
      whereArgs: [translationId, bookNumber, chapterNumber, verseNumber],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BibleVerse(
      number: maps.first['verse'] as int,
      text: maps.first['text'] as String,
    );
  }

  Future<List<Map<String, dynamic>>> getAllVerses(String translationId) async {
    final db = await _dbForTranslation(translationId);
    return await db.query(
      'verses',
      columns: ['book_number', 'chapter', 'verse', 'text'],
      where: 'translation_id = ?',
      whereArgs: [translationId],
      // Canonical order: required by parseBibleRows (KJV backbone build).
      orderBy: 'book_number ASC, chapter ASC, verse ASC',
    );
  }

  /// Installs a downloaded translation as a standalone pack file
  /// (verified before publishing). Backbone ids are rejected.
  Future<void> insertTranslationPack(
      TranslationInfo info, List<Map<String, dynamic>> verses) async {
    if (TranslationPackStore.isCoreId(info.translationId)) {
      throw StateError(
          "'${info.translationId}' is part of the app backbone.");
    }
    await _packStore.installPackFromRows(info, verses);
  }

  /// Deletes a non-backbone translation pack. Frees storage immediately
  /// (file removal, no VACUUM needed). Throws for backbone ids.
  Future<void> deleteTranslationPack(String translationId) async {
    await _packStore.deletePack(translationId);
  }

  /// Restores a user-deleted bundled pack from the APK (instant, offline).
  Future<void> restoreBundledPack(String translationId) async {
    await _packStore.restoreBundledPack(translationId);
  }

  /// Installs a prebuilt pack database downloaded over the network
  /// (Firebase Storage flow), hash-verified when [expectedSha256] is given.
  Future<void> installPrebuiltPack(
      String translationId, List<int> bytes,
      {String? expectedSha256}) async {
    if (TranslationPackStore.isCoreId(translationId)) {
      throw StateError(
          "'$translationId' is part of the app backbone.");
    }
    await _packStore.installPackFromBytes(translationId, bytes,
        expectedSha256: expectedSha256);
  }

  Future<void> migrateReadingPlansFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool('plans_migrated_to_sqlite') ?? false;
    if (migrated) return;

    final db = await database;
    await db.transaction((txn) async {
      final activeIds = prefs.getStringList('active_plan_ids') ?? [];

      for (final id in activeIds) {
        final jsonString = prefs.getString('reading_plan_state_$id');
        if (jsonString != null) {
          try {
            final state = jsonDecode(jsonString) as Map<String, dynamic>;
            final completedDaysList = state['completedDays'];
            if (completedDaysList != null && completedDaysList is List) {
              for (final dayObj in completedDaysList) {
                final dayNumber = int.tryParse(dayObj.toString());
                if (dayNumber != null) {
                  await txn.insert('user_plan_progress', {
                    'plan_id': id,
                    'day_number': dayNumber,
                    'completed_at': DateTime.now().millisecondsSinceEpoch,
                  }, conflictAlgorithm: ConflictAlgorithm.ignore);
                }
              }
            }
          } catch (_) {}
        }
      }
    });

    await prefs.setBool('plans_migrated_to_sqlite', true);
  }
}

// Global singleton
final bibleDbService = BibleDatabaseService();
