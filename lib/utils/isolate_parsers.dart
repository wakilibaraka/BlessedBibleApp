import 'dart:convert';
import '../data/models/bible_model.dart';

/// Top-level function to parse Bible JSON on a background isolate
List<BibleBook> parseBibleJson(String jsonString) {
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  final List<dynamic> versesList = jsonMap['verses'];

  final Map<String, BibleBook> booksMap = {};

  for (var v in versesList) {
    final bookName = v['book_name'] as String;
    final chapterNum = v['chapter'] as int;
    final verseNum = v['verse'] as int;
    String text = v['text'] as String;

    // Strip paragraph markers, preserve bracketed words
    text = text.replaceAll('¶ ', '').replaceAll('¶', '');

    booksMap.putIfAbsent(
        bookName,
        () => BibleBook(
              name: bookName,
              abbreviation:
                  bookName, // Fixed from substring(0, 3) to prevent collisions
              chapters: [],
            ));

    final book = booksMap[bookName]!;

    // Ensure chapter exists
    while (book.chapters.length < chapterNum) {
      book.chapters
          .add(BibleChapter(number: book.chapters.length + 1, verses: []));
    }

    final chapter = book.chapters[chapterNum - 1];
    chapter.verses.add(BibleVerse(number: verseNum, text: text));
  }

  return booksMap.values.toList();
}
