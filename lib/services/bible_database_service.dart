import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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

    // If the database doesn't exist locally, copy it from assets
    if (!await File(dbPath).exists()) {
      try {
        await Directory(dirname(dbPath)).create(recursive: true);
        final data = await rootBundle.load('assets/bible/$_dbName');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception('Error copying database from assets: $e');
      }
    }

    return await openDatabase(dbPath, readOnly: true);
  }

  Future<List<TranslationInfo>> getTranslations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      orderBy: 'language_name ASC, translation_name ASC',
    );
    return maps.map((map) => TranslationInfo.fromMap(map)).toList();
  }

  Future<List<BibleVerse>> getChapter(String translationId, int bookNumber, int chapterNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      columns: ['verse', 'text'],
      where: 'translation_id = ? AND book_number = ? AND chapter = ?',
      whereArgs: [translationId, bookNumber, chapterNumber],
      orderBy: 'verse ASC',
    );

    return maps.map((map) => BibleVerse(
      number: map['verse'] as int,
      text: map['text'] as String,
    )).toList();
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
}


// Global singleton
final bibleDbService = BibleDatabaseService();
