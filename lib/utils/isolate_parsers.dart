import 'dart:convert';
import '../data/bible_books.dart';
import '../data/models/bible_model.dart';
import '../models/commentary_entry.dart';
import '../models/pericope_entry.dart';

/// Builds the in-memory KJV backbone from database rows (offline-first).
///
/// Rows come from `verses WHERE translation_id = 'kjv'` as maps with
/// `book_number`, `chapter`, `verse`, `text` ordered by book/chapter/verse.
/// Book names come from [kBibleBookNames] (index + 1 == book_number). Same
/// paragraph-marker stripping and abbreviation behavior as [parseBibleJson];
/// replaces `assets/data/kjvbible.json` (deleted).
List<BibleBook> parseBibleRows(List<Map<String, dynamic>> rows) {
  final books = <BibleBook>[];
  var currentBookNum = -1;
  var currentChapterNum = -1;
  BibleBook? book;
  BibleChapter? chapter;

  for (final r in rows) {
    final bookNum = (r['book_number'] as num).toInt();
    final chapterNum = (r['chapter'] as num).toInt();
    final verseNum = (r['verse'] as num).toInt();
    String text = r['text'] as String;

    // Strip paragraph markers, preserve bracketed words
    text = text.replaceAll('¶ ', '').replaceAll('¶', '');

    if (bookNum != currentBookNum) {
      final name = (bookNum >= 1 && bookNum <= kBibleBookNames.length)
          ? kBibleBookNames[bookNum - 1]
          : 'Book $bookNum';
      book = BibleBook(
        name: name,
        abbreviation: name, // Fixed from substring(0, 3) to prevent collisions
        chapters: [],
      );
      books.add(book);
      currentBookNum = bookNum;
      currentChapterNum = -1;
    }
    if (chapterNum != currentChapterNum) {
      chapter = BibleChapter(number: chapterNum, verses: []);
      book!.chapters.add(chapter);
      currentChapterNum = chapterNum;
    }
    chapter!.verses.add(BibleVerse(number: verseNum, text: text));
  }

  return books;
}

/// Top-level function to parse Commentary JSON on a background isolate
List<CommentaryEntry> parseCommentaryJson(String jsonString) {
  final decoded = jsonDecode(jsonString);

  List<dynamic> entriesList;
  if (decoded is Map<String, dynamic> && decoded.containsKey('entries')) {
    entriesList = decoded['entries'] as List<dynamic>;
  } else if (decoded is List) {
    entriesList = decoded;
  } else {
    return [];
  }

  return entriesList
      .map((e) => CommentaryEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// Top-level function to parse Pericopes JSON on a background isolate
List<PericopeEntry> parsePericopesJson(String jsonString) {
  final decoded = jsonDecode(jsonString);

  List<dynamic> entriesList;
  if (decoded is Map<String, dynamic> && decoded.containsKey('entries')) {
    entriesList = decoded['entries'] as List<dynamic>;
  } else if (decoded is List) {
    entriesList = decoded;
  } else {
    return [];
  }

  return entriesList
      .map((e) => PericopeEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}
