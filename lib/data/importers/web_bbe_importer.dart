import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../../services/bible_database_service.dart';

class WebBbeImporter {
  static Future<void> importData() async {
    final db = await bibleDbService.database;

    // Check if BBE exists
    final bbeExists = await db.query('translations', where: 'translation_id = ?', whereArgs: ['bbe']);
    final isBbePresent = bbeExists.isNotEmpty;

    // Check if WEB is repaired (we can use a flag in SharedPreferences or just count verses with length < 10)
    // Actually, checking if WEB needs repair:
    final badWebVerses = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM verses WHERE translation_id = 'web' AND length(text) < 10"
    )) ?? 0;
    final needsWebRepair = badWebVerses > 1000; // If there are >1000 short verses, it needs repair

    if (isBbePresent && !needsWebRepair) {
      return; // Already done
    }

    print('Starting WEB repair and BBE import...');

    if (needsWebRepair) {
      try {
        final webJsonStr = await rootBundle.loadString('assets/data/web_bible.json');
        final webList = _parseJson(webJsonStr);
        if (webList.isNotEmpty) {
          await _updateVerses(db, 'web', webList);
          print('WEB repaired successfully.');
        }
      } catch (e) {
        print('Error repairing WEB: $e');
      }
    }

    if (!isBbePresent) {
      try {
        final bbeJsonStr = await rootBundle.loadString('assets/data/bbe_bible.json');
        final bbeList = _parseJson(bbeJsonStr);
        if (bbeList.isNotEmpty) {
          await db.insert('translations', {
            'translation_id': 'bbe',
            'language_code': 'en',
            'language_name': 'English',
            'translation_name': 'Bible in Basic English',
            'abbreviation': 'BBE',
            'license': 'Public Domain',
            'is_complete': 1,
          });
          await _insertVerses(db, 'bbe', bbeList);
          print('BBE imported successfully.');
        }
      } catch (e) {
        print('Error importing BBE: $e');
      }
    }
  }

  static List<Map<String, dynamic>> _parseJson(String jsonStr) {
    final dynamic data = json.decode(jsonStr);
    List<Map<String, dynamic>> verses = [];

    // Scrollmapper JSON structure: {"resultset": {"row": [ {"field": [id, b, c, v, text]} ]}}
    if (data is Map && data.containsKey('resultset')) {
      final rows = data['resultset']['row'] as List;
      for (final row in rows) {
        final fields = row['field'] as List;
        // fields: [id (0), book (1), chapter (2), verse (3), text (4)]
        if (fields.length >= 5) {
          verses.add({
            'book_number': fields[1] as int,
            'chapter': fields[2] as int,
            'verse': fields[3] as int,
            'text': fields[4].toString().trim(),
          });
        }
      }
    }
    // Our kjvbible.json structure: [{"book": 1, "chapter": 1, "verse": 1, "text": "..."}]
    else if (data is List) {
      for (final item in data) {
        if (item is Map) {
          if (item.containsKey('book') && item.containsKey('chapter') && item.containsKey('verse') && item.containsKey('text')) {
            verses.add({
              'book_number': item['book'] as int,
              'chapter': item['chapter'] as int,
              'verse': item['verse'] as int,
              'text': item['text'].toString().trim(),
            });
          }
        }
      }
    }
    // Thiago Bodruk JSON structure: [{"name": "Genesis", "chapters": [ [ "verse 1" ] ] }]
    else if (data is List && data.isNotEmpty && data.first is Map && data.first.containsKey('chapters')) {
      int bookNum = 1;
      for (final book in data) {
        final chapters = book['chapters'] as List;
        int chapterNum = 1;
        for (final chapter in chapters) {
          final chapterVerses = chapter as List;
          int verseNum = 1;
          for (final verseText in chapterVerses) {
            verses.add({
              'book_number': bookNum,
              'chapter': chapterNum,
              'verse': verseNum,
              'text': verseText.toString().trim(),
            });
            verseNum++;
          }
          chapterNum++;
        }
        bookNum++;
      }
    }
    return verses;
  }

  static Future<void> _updateVerses(Database db, String translationId, List<Map<String, dynamic>> verses) async {
    // Only update verses that exist in the KJV structure (already in DB for 'kjv').
    // Since 'web' already has 31k rows, we just UPDATE existing rows to not leak outside KJV boundaries.
    
    // Create a lookup for fast access
    final batch = db.batch();
    for (final v in verses) {
      batch.update(
        'verses',
        {'text': v['text']},
        where: 'translation_id = ? AND book_number = ? AND chapter = ? AND verse = ?',
        whereArgs: [translationId, v['book_number'], v['chapter'], v['verse']],
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _insertVerses(Database db, String translationId, List<Map<String, dynamic>> verses) async {
    // We only insert verses that match the KJV boundary.
    // Fetch KJV boundaries
    final kjvRows = await db.query('verses', columns: ['book_number', 'chapter', 'verse'], where: "translation_id = 'kjv'");
    final kjvSet = <String>{};
    for (final row in kjvRows) {
      kjvSet.add('${row['book_number']}_${row['chapter']}_${row['verse']}');
    }

    final batch = db.batch();
    for (final v in verses) {
      final key = '${v['book_number']}_${v['chapter']}_${v['verse']}';
      if (kjvSet.contains(key)) {
        batch.insert('verses', {
          'translation_id': translationId,
          'language_code': 'en',
          'book_number': v['book_number'],
          'chapter': v['chapter'],
          'verse': v['verse'],
          'text': v['text'],
        });
      }
    }
    await batch.commit(noResult: true);
  }
}
