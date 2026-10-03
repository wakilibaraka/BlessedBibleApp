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

  /// Content generation id. Bump when the bundled `assets/bible/bible.db`
  /// asset or the on-disk layout changes. Any mismatch (upgrade, downgrade,
  /// test APK, corruption repair) converges by re-materializing from asset.
  static const int contentVersion = 1;
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

  final StreamController<double> _installProgressController =
      StreamController<double>.broadcast();

  /// 0..1 progress of the active content install (first run / upgrade /
  /// repair). Emits nothing while idle.
  Stream<double> get installProgress => _installProgressController.stream;

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
    // Legacy migration: a db_version at/above the last shipped legacy
    // version means the installed content is current.
    final legacy = prefs.getInt('db_version') ?? 1;
    return legacy >= _legacyRequiredDbVersion ? contentVersion : 0;
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
      await _installFromAsset(
        dbPath,
        prefs,
        preservePacks: await dbFile.exists(),
      );
    }

    var db = await _openGuarded(dbPath);
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
        // Copy phase reports 0..0.9; verification takes it to 1.0.
        _emitProgress(0.9 * end / bytes.length);
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
      _emitProgress(0.95);
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
      try {
        final kjv = await db.rawQuery(
            "SELECT COUNT(*) AS c FROM verses WHERE translation_id = 'kjv'");
        final count = (kjv.first['c'] as num?)?.toInt() ?? 0;
        if (count == 0) problems.add('KJV backbone has no verses');
      } catch (e) {
        problems.add('KJV backbone unreadable: $e');
      }
    } catch (e) {
      problems.add('probe error: $e');
    }
    return problems;
  }

  /// Best-effort carry-over of user-downloaded translation packs from the
  /// previous database file. Never throws: a bad backup must not break the
  /// install (the fresh asset copy is already verified at this point).
  Future<void> _preserveDownloadedPacks(
      String dbPath, String backupPath) async {
    Database? mainDb;
    try {
      mainDb = await openDatabase(
        dbPath,
        onConfigure: (db) async {
          try {
            await db.rawQuery('PRAGMA journal_mode=WAL;');
          } catch (_) {}
        },
      );

      try {
        final tableRows = await mainDb.rawQuery(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'translations'");
        if (tableRows.isNotEmpty) {
          final mainCols =
              await mainDb.rawQuery('PRAGMA table_info(translations);');
          if (!mainCols.any((c) => c['name'] == 'is_downloaded')) {
            await mainDb.execute(
                'ALTER TABLE translations ADD COLUMN is_downloaded INTEGER NOT NULL DEFAULT 0;');
          }
        }
      } catch (e) {
        stderr.writeln('DB preserve is_downloaded guard: $e');
      }

      final escapedBackupPath = backupPath.replaceAll("'", "''");
      try {
        await mainDb
            .execute("ATTACH DATABASE '$escapedBackupPath' AS backup;");
      } catch (e) {
        stderr.writeln('DB preserve: attach backup failed: $e');
        return;
      }

      List<Map<String, Object?>> backupCols = [];
      try {
        backupCols =
            await mainDb.rawQuery('PRAGMA backup.table_info(translations);');
      } catch (_) {}
      if (backupCols.isEmpty) {
        stderr.writeln('DB preserve: backup has no translations table');
        return;
      }
      final hasIsDownloadedInBackup =
          backupCols.any((c) => c['name'] == 'is_downloaded');

      try {
        await mainDb.transaction((txn) async {
          if (!hasIsDownloadedInBackup) {
            // One-time deduction backfill (v1/v2 -> v3)
            final unbundledRows = await txn.rawQuery('''
              SELECT translation_id, language_code, language_name, translation_name, abbreviation, license, is_complete
              FROM backup.translations
              WHERE translation_id NOT IN (SELECT translation_id FROM main.translations)
            ''');

            for (final row in unbundledRows) {
              final tid = row['translation_id'] as String;
              await txn.rawInsert('''
                INSERT OR REPLACE INTO main.translations 
                (translation_id, language_code, language_name, translation_name, abbreviation, license, is_complete, is_downloaded)
                VALUES (?, ?, ?, ?, ?, ?, ?, 1)
              ''', [
                row['translation_id'],
                row['language_code'],
                row['language_name'],
                row['translation_name'],
                row['abbreviation'],
                row['license'],
                row['is_complete'],
              ]);

              await txn.rawInsert('''
                INSERT INTO main.verses (translation_id, language_code, book_number, chapter, verse, text)
                SELECT translation_id, language_code, book_number, chapter, verse, text
                FROM backup.verses
                WHERE translation_id = ?
              ''', [tid]);
            }
          } else {
            // Future migrations (v3+): read is_downloaded flag directly
            final downloadedRows = await txn.rawQuery('''
              SELECT translation_id, language_code, language_name, translation_name, abbreviation, license, is_complete
              FROM backup.translations
              WHERE is_downloaded = 1
            ''');

            for (final row in downloadedRows) {
              final tid = row['translation_id'] as String;
              await txn.rawInsert('''
                INSERT OR REPLACE INTO main.translations 
                (translation_id, language_code, language_name, translation_name, abbreviation, license, is_complete, is_downloaded)
                VALUES (?, ?, ?, ?, ?, ?, ?, 1)
              ''', [
                row['translation_id'],
                row['language_code'],
                row['language_name'],
                row['translation_name'],
                row['abbreviation'],
                row['license'],
                row['is_complete'],
              ]);

              await txn.rawInsert('''
                INSERT INTO main.verses (translation_id, language_code, book_number, chapter, verse, text)
                SELECT translation_id, language_code, book_number, chapter, verse, text
                FROM backup.verses
                WHERE translation_id = ?
              ''', [tid]);
            }
          }
        });
      } finally {
        try {
          await mainDb.execute('DETACH DATABASE backup;');
        } catch (_) {}
      }
    } catch (e) {
      stderr.writeln('DB preserve downloaded packs failed: $e');
    } finally {
      try {
        await mainDb?.close();
      } catch (_) {}
    }
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

  Future<List<TranslationInfo>> getTranslations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      orderBy: 'language_name ASC, translation_name ASC',
    );
    return maps.map((map) => TranslationInfo.fromMap(map)).toList();
  }

  Future<List<BibleVerse>> getChapter(
      String translationId, int bookNumber, int chapterNumber) async {
    final db = await database;
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
    final db = await database;
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
    final db = await database;
    return await db.query(
      'verses',
      columns: ['book_number', 'chapter', 'verse', 'text'],
      where: 'translation_id = ?',
      whereArgs: [translationId],
      // Canonical order: required by parseBibleRows (KJV backbone build).
      orderBy: 'book_number ASC, chapter ASC, verse ASC',
    );
  }

  Future<void> insertTranslationPack(
      TranslationInfo info, List<Map<String, dynamic>> verses) async {
    final db = await database;
    await db.transaction((txn) async {
      final map = info.toMap();
      map['is_downloaded'] = 1;
      await txn.insert(
        'translations',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final batch = txn.batch();
      for (final verse in verses) {
        batch.insert('verses', verse);
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> deleteTranslationPack(String translationId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('verses',
          where: 'translation_id = ?', whereArgs: [translationId]);
      await txn.delete('translations',
          where: 'translation_id = ?', whereArgs: [translationId]);
    });
    // Vacuum to reclaim space, but do it outside the transaction as it rewrites the DB
    await db.execute('VACUUM;');
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
