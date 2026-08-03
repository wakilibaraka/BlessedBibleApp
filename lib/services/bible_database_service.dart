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

    final prefs = await SharedPreferences.getInstance();
    final currentDbVersion = prefs.getInt('db_version') ?? 1;
    const requiredDbVersion = 2; // Bump this to force re-copy from assets

    // If the database doesn't exist locally, or is old, copy it from assets
    if (!await File(dbPath).exists() || currentDbVersion < requiredDbVersion) {
      try {
        if (await File(dbPath).exists()) {
          await File(dbPath).delete();
        }
        await Directory(dirname(dbPath)).create(recursive: true);
        final data = await rootBundle.load('assets/bible/$_dbName');
        final bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
        await prefs.setInt('db_version', requiredDbVersion);
      } catch (e) {
        throw Exception('Error copying database from assets: $e');
      }
    }

    return await openDatabase(
      dbPath,
      readOnly: false,
      onConfigure: (db) async {
        await db.rawQuery('PRAGMA journal_mode=WAL;');
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
      await txn.insert(
        'translations',
        info.toMap(),
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
