import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/bible_model.dart';
import '../data/models/translation_model.dart';

class BibleDatabaseService {
  static const String _dbName = 'bible.db';
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbDir = await getApplicationSupportDirectory();
    final dbPath = join(dbDir.path, _dbName);
    final backupPath = join(dbDir.path, 'bible_backup.db');

    final prefs = await SharedPreferences.getInstance();
    final currentDbVersion = prefs.getInt('db_version') ?? 1;
    const requiredDbVersion = 5;

    final dbFile = File(dbPath);
    final backupFile = File(backupPath);

    if (!await dbFile.exists()) {
      await Directory(dirname(dbPath)).create(recursive: true);
      final data = await rootBundle.load('assets/bible/$_dbName');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await dbFile.writeAsBytes(bytes, flush: true);
      await prefs.setInt('db_version', requiredDbVersion);
    } else if (currentDbVersion < requiredDbVersion) {
      try {
        if (await backupFile.exists()) {
          await backupFile.delete();
        }
        await dbFile.rename(backupPath);

        final data = await rootBundle.load('assets/bible/$_dbName');
        final bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await dbFile.writeAsBytes(bytes, flush: true);

        final mainDb = await openDatabase(
          dbPath,
          onConfigure: (db) async {
            await db.rawQuery('PRAGMA journal_mode=WAL;');
          },
        );

        final mainCols =
            await mainDb.rawQuery('PRAGMA table_info(translations);');
        if (!mainCols.any((c) => c['name'] == 'is_downloaded')) {
          await mainDb.execute(
              'ALTER TABLE translations ADD COLUMN is_downloaded INTEGER NOT NULL DEFAULT 0;');
        }

        final escapedBackupPath = backupPath.replaceAll("'", "''");
        await mainDb.execute("ATTACH DATABASE '$escapedBackupPath' AS backup;");

        final backupCols =
            await mainDb.rawQuery('PRAGMA backup.table_info(translations);');
        final hasIsDownloadedInBackup =
            backupCols.any((c) => c['name'] == 'is_downloaded');

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

        await mainDb.execute('DETACH DATABASE backup;');
        await mainDb.close();

        if (await backupFile.exists()) {
          await backupFile.delete();
        }

        await prefs.setInt('db_version', requiredDbVersion);
      } catch (e) {
        stderr.writeln('DB migration error: $e');
        if (await backupFile.exists() && !await dbFile.exists()) {
          await backupFile.copy(dbPath);
        }
      }
    }

    return await openDatabase(
      dbPath,
      readOnly: false,
      onConfigure: (db) async {
        await db.rawQuery('PRAGMA journal_mode=WAL;');
      },
      onOpen: (db) async {
        final cols = await db.rawQuery('PRAGMA table_info(translations);');
        if (!cols.any((c) => c['name'] == 'is_downloaded')) {
          await db.execute(
              'ALTER TABLE translations ADD COLUMN is_downloaded INTEGER NOT NULL DEFAULT 0;');
        }
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
}

// Global singleton
final bibleDbService = BibleDatabaseService();
