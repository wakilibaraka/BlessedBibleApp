import 'dart:convert';
import '../data/models/bible_model.dart';
import '../data/models/commentary_model.dart';

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
    
    booksMap.putIfAbsent(bookName, () => BibleBook(
      name: bookName,
      abbreviation: bookName, // Fixed from substring(0, 3) to prevent collisions
      chapters: [],
    ));
    
    final book = booksMap[bookName]!;
    
    // Ensure chapter exists
    while (book.chapters.length < chapterNum) {
      book.chapters.add(BibleChapter(number: book.chapters.length + 1, verses: []));
    }
    
    final chapter = book.chapters[chapterNum - 1];
    chapter.verses.add(BibleVerse(number: verseNum, text: text));
  }
  
  return booksMap.values.toList();
}

/// Top-level function to parse EGW Commentary JSON on a background isolate
Map<String, Map<String, Map<String, List<CommentaryEntry>>>> parseEgwJson(String jsonString) {
  Map<String, Map<String, Map<String, List<CommentaryEntry>>>> result = {};
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  
  for (var bookEntry in jsonData.entries) {
    final String book = bookEntry.key;
    result.putIfAbsent(book, () => {});
    final Map<String, dynamic> chapters = bookEntry.value;
    
    for (var chapterEntry in chapters.entries) {
      final String chapter = chapterEntry.key;
      result[book]!.putIfAbsent(chapter, () => {});
      final Map<String, dynamic> verses = chapterEntry.value;
      
      for (var verseEntry in verses.entries) {
        final String verse = verseEntry.key;
        result[book]![chapter]!.putIfAbsent(verse, () => []);
        final List<dynamic> comments = verseEntry.value;
        
        for (var item in comments) {
          final entryMap = item as Map<String, dynamic>;
          result[book]![chapter]![verse]!.add(CommentaryEntry(
            id: entryMap['id']?.toString() ?? '',
            title: 'ELLEN G. WHITE - ${entryMap['title']?.toString() ?? 'Commentary'}',
            text: entryMap['text']?.toString() ?? '',
          ));
        }
      }
    }
  }
  
  return result;
}
