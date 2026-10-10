import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/translation_model.dart';

/// Metadata for one installed translation pack.
class PackMeta {
  final String id;
  final String languageCode;
  final String languageName;
  final String translationName;
  final String abbreviation;
  final String license;
  final bool isComplete;

  /// 'bundled' (shipped in the APK, restorable offline) or
  /// 'downloaded' (fetched over the network).
  final String source;

  const PackMeta({
    required this.id,
    required this.languageCode,
    required this.languageName,
    required this.translationName,
    required this.abbreviation,
    required this.license,
    required this.isComplete,
    required this.source,
  });

  TranslationInfo toInfo() => TranslationInfo(
        translationId: id,
        languageCode: languageCode,
        languageName: languageName,
        translationName: translationName,
        abbreviation: abbreviation,
        license: license,
        isComplete: isComplete,
        isDownloaded: source == 'downloaded',
      );

  Map<String, dynamic> toJson() => {
        'language_code': languageCode,
        'language_name': languageName,
        'translation_name': translationName,
        'abbreviation': abbreviation,
        'license': license,
        'is_complete': isComplete ? 1 : 0,
        'source': source,
      };

  factory PackMeta.fromJson(String id, Map<String, dynamic> json) {
    return PackMeta(
      id: id,
      languageCode: json['language_code'] as String? ?? 'und',
      languageName: json['language_name'] as String? ?? id,
      translationName: json['translation_name'] as String? ?? id,
      abbreviation: json['abbreviation'] as String? ?? id.toUpperCase(),
      license: json['license'] as String? ?? '',
      isComplete: (json['is_complete'] as int? ?? 0) == 1,
      source: json['source'] as String? ?? 'downloaded',
    );
  }
}

/// On-disk home for every non-backbone translation: one SQLite file per
/// translation under `<support>/packs/<id>.db`, plus a `catalog.json`
/// describing installed packs.
///
/// - KJV + KJV-Strong's live in the core database (never deletable).
/// - Bundled packs ship in `assets/packs/` and are copied on demand;
///   deleting one just removes the file, restoring re-copies from the APK
///   (instant, offline). Downloaded packs are fetched over the network.
/// - Pack files carry the same `verses`/`translations` table shapes as the
///   core database, so all verse queries work unchanged once routed.
class TranslationPackStore {
  /// Backbone translations: live in the core database, never deletable,
  /// always on device (KJV + BBE). Everything else is a standalone pack.
  static const List<String> coreIds = ['kjv', 'bbe'];

  /// Packs shipped inside the APK (restorable offline).
  static const List<String> bundledPackIds = [
    'swh_ulb',
    'ita_dio',
    'fra_lsg',
    'ron_btf',
    'tgl_ulb',
  ];

  static bool isCoreId(String id) => coreIds.contains(id);

  static const String _deletedPacksKey = 'deleted_packs';

  static const String _versesDdl = '''CREATE TABLE verses (
  translation_id TEXT NOT NULL,
  language_code  TEXT NOT NULL,
  book_number    INTEGER NOT NULL,
  chapter        INTEGER NOT NULL,
  verse          INTEGER NOT NULL,
  text           TEXT NOT NULL
)''';

  static const String _translationsDdl = '''CREATE TABLE translations (
  translation_id   TEXT PRIMARY KEY,
  language_code    TEXT NOT NULL,
  language_name    TEXT NOT NULL,
  translation_name TEXT NOT NULL,
  abbreviation     TEXT NOT NULL,
  license          TEXT NOT NULL,
  is_complete      INTEGER NOT NULL DEFAULT 0,
  is_downloaded    INTEGER NOT NULL DEFAULT 0
)''';

  static const String _packIndex =
      'CREATE INDEX idx_verses_pack ON verses(book_number, chapter, verse)';

  final Map<String, Database> _open = {};

  Future<Directory> _packsDir() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(join(support.path, 'packs'));
    await dir.create(recursive: true);
    return dir;
  }

  Future<File> _packFile(String id) async {
    return File(join((await _packsDir()).path, '$id.db'));
  }

  Future<File> _catalogFile() async {
    return File(join((await _packsDir()).path, 'catalog.json'));
  }

  Future<Map<String, PackMeta>> readCatalog() async {
    try {
      final file = await _catalogFile();
      if (!await file.exists()) return {};
      final decoded =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final out = <String, PackMeta>{};
      decoded.forEach((id, v) {
        if (v is Map<String, dynamic>) {
          try {
            out[id] = PackMeta.fromJson(id, v);
          } catch (_) {}
        }
      });
      return out;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeCatalog(Map<String, PackMeta> catalog) async {
    final file = await _catalogFile();
    final tmp = File('${file.path}.tmp');
    final json = <String, dynamic>{};
    catalog.forEach((id, meta) => json[id] = meta.toJson());
    await tmp.writeAsString(jsonEncode(json), flush: true);
    await tmp.rename(file.path);
  }

  /// Translations the user deleted (bundled packs only). Re-installs skip
  /// these so a repair never resurrects content the user removed.
  Future<Set<String>> deletedPackIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_deletedPacksKey) ?? []).toSet();
  }

  Future<void> _setPackDeleted(String id, bool deleted) async {
    final prefs = await SharedPreferences.getInstance();
    final list = (prefs.getStringList(_deletedPacksKey) ?? []).toSet();
    if (deleted) {
      list.add(id);
    } else {
      list.remove(id);
    }
    await prefs.setStringList(_deletedPacksKey, list.toList());
  }

  /// Installed packs = catalog entries whose file actually exists.
  Future<List<PackMeta>> installedPacks() async {
    final catalog = await readCatalog();
    final out = <PackMeta>[];
    for (final entry in catalog.entries) {
      final file = await _packFile(entry.key);
      if (await file.exists()) out.add(entry.value);
    }
    return out;
  }

  /// Opens a pack database read-only (cached). Throws [StateError] with a
  /// human-readable message when the pack is not installed — callers render
  /// restore/download UI instead of blank content.
  Future<Database> openPack(String id) async {
    if (isCoreId(id)) {
      throw StateError("'$id' lives in the core database, not a pack.");
    }
    final cached = _open[id];
    if (cached != null && cached.isOpen) return cached;
    final file = await _packFile(id);
    if (!await file.exists()) {
      throw StateError(
          "Translation '$id' is not installed. Restore or download it to read.");
    }
    final db = await openDatabase(file.path, readOnly: true);
    _open[id] = db;
    return db;
  }

  /// Copies every bundled pack that should be present (missing file, or
  /// present file with no catalog entry). Skips user-deleted packs.
  Future<void> ensureBundledPacks({
    void Function(double progress)? onProgress,
    Set<String>? skipIds,
  }) async {
    final skipped = skipIds ?? await deletedPackIds();
    final catalog = await readCatalog();
    var changed = false;
    var done = 0;
    for (final id in bundledPackIds) {
      done++;
      if (skipped.contains(id)) {
        onProgress?.call(done / bundledPackIds.length);
        continue;
      }
      final file = await _packFile(id);
      if (!await file.exists()) {
        await _copyAssetPack(id, file);
        catalog[id] = await _metaFromPackFile(id, file, source: 'bundled');
        changed = true;
      } else if (!catalog.containsKey(id)) {
        try {
          catalog[id] = await _metaFromPackFile(id, file, source: 'bundled');
          changed = true;
        } catch (_) {}
      }
      onProgress?.call(done / bundledPackIds.length);
    }
    if (changed) await _writeCatalog(catalog);
  }

  Future<void> _copyAssetPack(String id, File dest) async {
    final data = await rootBundle.load('assets/packs/$id.db');
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final tmp = File('${dest.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await _verifyPackFile(id, tmp.path);
    await tmp.rename(dest.path);
  }

  Future<void> _verifyPackFile(String id, String path) async {
    final db = await openDatabase(path, readOnly: true);
    try {
      final qc = await db.rawQuery('PRAGMA quick_check');
      if ('${qc.first.values.first}' != 'ok') {
        throw StateError('pack $id failed integrity check');
      }
      final rows = await db.query('translations', limit: 1);
      if (rows.isEmpty || (rows.first['translation_id'] as String?) != id) {
        throw StateError('pack $id has no matching translations row');
      }
      final n = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) AS c FROM verses')) ??
          0;
      if (n < 30000) throw StateError('pack $id has too few verses: $n');
    } finally {
      await db.close();
    }
  }

  Future<PackMeta> _metaFromPackFile(String id, File file,
      {required String source}) async {
    final db = await openDatabase(file.path, readOnly: true);
    try {
      final rows = await db.query('translations', limit: 1);
      if (rows.isEmpty) throw StateError('pack $id has no translations row');
      final m = rows.first;
      return PackMeta(
        id: id,
        languageCode: m['language_code'] as String? ?? 'und',
        languageName: m['language_name'] as String? ?? id,
        translationName: m['translation_name'] as String? ?? id,
        abbreviation: m['abbreviation'] as String? ?? id.toUpperCase(),
        license: m['license'] as String? ?? '',
        isComplete: (m['is_complete'] as int? ?? 0) == 1,
        source: source,
      );
    } finally {
      await db.close();
    }
  }

  /// Removes all traces of a pack (open handle, file, catalog entry)
  /// without backbone guards or delete bookkeeping. Used when a pack's
  /// content moves into the core database (no duplicate copies).
  Future<void> forgetPack(String id) async {
    final handle = _open.remove(id);
    try {
      await handle?.close();
    } catch (_) {}
    final file = await _packFile(id);
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
    final catalog = await readCatalog();
    if (catalog.remove(id) != null) await _writeCatalog(catalog);
  }

  /// Deletes a non-backbone translation. Frees its storage immediately
  /// (file removal, no VACUUM needed). Throws for backbone ids.
  Future<void> deletePack(String id) async {
    if (isCoreId(id)) {
      throw StateError(
          "'$id' is part of the app backbone and cannot be deleted.");
    }
    final handle = _open.remove(id);
    try {
      await handle?.close();
    } catch (_) {}
    final file = await _packFile(id);
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
    final catalog = await readCatalog();
    if (catalog.remove(id) != null) await _writeCatalog(catalog);
    if (bundledPackIds.contains(id)) await _setPackDeleted(id, true);
  }

  /// Restores a user-deleted bundled pack from the APK (instant, offline).
  Future<void> restoreBundledPack(String id) async {
    if (!bundledPackIds.contains(id)) {
      throw StateError("'$id' is not a bundled pack.");
    }
    final file = await _packFile(id);
    await _copyAssetPack(id, file);
    final catalog = await readCatalog();
    catalog[id] = await _metaFromPackFile(id, file, source: 'bundled');
    await _writeCatalog(catalog);
    await _setPackDeleted(id, false);
  }

  /// Builds a pack from parsed verse rows (network download flow).
  Future<void> installPackFromRows(
      TranslationInfo info, List<Map<String, dynamic>> verses) async {
    if (verses.length < 30000) {
      throw StateError('Downloaded ${info.translationId} looks incomplete '
          '(${verses.length} verses).');
    }
    final file = await _packFile(info.translationId);
    final tmp = File('${file.path}.tmp');
    if (await tmp.exists()) await tmp.delete();
    final db = await openDatabase(tmp.path);
    try {
      await db.execute(_versesDdl);
      await db.execute(_translationsDdl);
      final map = info.toMap();
      map['is_downloaded'] = 1;
      await db.insert('translations', map);
      final batch = db.batch();
      for (final v in verses) {
        batch.insert('verses', v);
      }
      await batch.commit(noResult: true);
      await db.execute(_packIndex);
    } finally {
      await db.close();
    }
    await _verifyPackFile(info.translationId, tmp.path);
    final handle = _open.remove(info.translationId);
    try {
      await handle?.close();
    } catch (_) {}
    await tmp.rename(file.path);
    final catalog = await readCatalog();
    catalog[info.translationId] = PackMeta(
      id: info.translationId,
      languageCode: info.languageCode,
      languageName: info.languageName,
      translationName: info.translationName,
      abbreviation: info.abbreviation,
      license: info.license,
      isComplete: info.isComplete,
      source: 'downloaded',
    );
    await _writeCatalog(catalog);
    await _setPackDeleted(info.translationId, false);
  }

  /// Installs a prebuilt pack database (Firebase Storage flow).
  /// When [expectedSha256] is given, the bytes are hash-verified first so a
  /// corrupt or tampered download can never become installed content.
  Future<void> installPackFromBytes(String id, List<int> bytes,
      {String? expectedSha256}) async {
    if (expectedSha256 != null) {
      final actual = sha256.convert(bytes).toString();
      if (actual != expectedSha256.toLowerCase()) {
        throw StateError(
            'Download of $id failed integrity check (sha256 mismatch).');
      }
    }
    final file = await _packFile(id);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await _verifyPackFile(id, tmp.path);
    final handle = _open.remove(id);
    try {
      await handle?.close();
    } catch (_) {}
    await tmp.rename(file.path);
    final catalog = await readCatalog();
    catalog[id] = await _metaFromPackFile(id, file, source: 'downloaded');
    await _writeCatalog(catalog);
    await _setPackDeleted(id, false);
  }

  /// P2 migration helper: extracts translations out of a legacy single-file
  /// database into standalone pack files. Returns the extracted ids.
  /// [shouldExtract] decides per id (backbone ids are never extracted).
  Future<List<String>> extractFromDatabase(
    Database legacyDb, {
    required bool Function(String id) shouldExtract,
  }) async {
    final rows = await legacyDb.query('translations');
    final extracted = <String>[];
    for (final r in rows) {
      final tid = r['translation_id'] as String?;
      if (tid == null || tid.isEmpty) continue;
      if (isCoreId(tid) || !shouldExtract(tid)) continue;
      final verses = await legacyDb.query(
        'verses',
        where: 'translation_id = ?',
        whereArgs: [tid],
        orderBy: 'book_number ASC, chapter ASC, verse ASC',
      );
      if (verses.isEmpty) continue;
      final file = await _packFile(tid);
      final tmp = File('${file.path}.tmp');
      if (await tmp.exists()) await tmp.delete();
      final db = await openDatabase(tmp.path);
      try {
        await db.execute(_versesDdl);
        await db.execute(_translationsDdl);
        final tmap = Map<String, dynamic>.from(r);
        tmap['is_downloaded'] = bundledPackIds.contains(tid) ? 0 : 1;
        await db.insert('translations', tmap);
        final batch = db.batch();
        for (final v in verses) {
          batch.insert('verses', Map<String, dynamic>.from(v));
        }
        await batch.commit(noResult: true);
        await db.execute(_packIndex);
      } finally {
        await db.close();
      }
      await _verifyPackFile(tid, tmp.path);
      final handle = _open.remove(tid);
      try {
        await handle?.close();
      } catch (_) {}
      await tmp.rename(file.path);
      final catalog = await readCatalog();
      catalog[tid] = await _metaFromPackFile(
        tid,
        file,
        source: bundledPackIds.contains(tid) ? 'bundled' : 'downloaded',
      );
      await _writeCatalog(catalog);
      extracted.add(tid);
    }
    return extracted;
  }
}
