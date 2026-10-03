import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the [WordCountService].
final wordCountServiceProvider = Provider<WordCountService>((ref) {
  return WordCountService();
});

/// A service to query word counts for the KJV Bible.
/// Must call [init] before querying.
class WordCountService {
  Map<String, dynamic>? _data;

  /// Loads and parses the word_counts.json asset off the main isolate.
  Future<void> init() async {
    if (_data != null) return;
    final jsonString = await rootBundle.loadString('assets/data/word_counts.json');
    await initFromJson(jsonString);
  }

  /// Initializes the service with a given JSON string (useful for testing).
  Future<void> initFromJson(String jsonString) async {
    _data = await compute(_parseWordCountsJson, jsonString);
  }

  /// Helper top-level function for [compute].
  static Map<String, dynamic> _parseWordCountsJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Returns the total word count for a specific verse.
  int wordsInVerse(String book, int chapter, int verse) {
    _ensureInitialized();
    try {
      final bookData = _data![book];
      if (bookData == null) return 0;
      final chapterData = bookData[chapter.toString()];
      if (chapterData == null) return 0;
      final verses = chapterData['verses'] as Map<String, dynamic>;
      return (verses[verse.toString()] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Returns the total word count for an entire chapter.
  int wordsInChapter(String book, int chapter) {
    _ensureInitialized();
    try {
      final bookData = _data![book];
      if (bookData == null) return 0;
      final chapterData = bookData[chapter.toString()];
      if (chapterData == null) return 0;
      return (chapterData['total'] as num).toInt();
    } catch (e) {
      return 0;
    }
  }

  /// Returns the total word count for a continuous range of verses within the same book.
  /// Note: The range can span across multiple chapters.
  int wordsInRange(String book, int startCh, int startV, int endCh, int endV) {
    _ensureInitialized();
    
    final bookData = _data![book];
    if (bookData == null) return 0;

    int total = 0;
    
    for (int c = startCh; c <= endCh; c++) {
      final chapterData = bookData[c.toString()];
      if (chapterData == null) continue;
      
      final verses = chapterData['verses'] as Map<String, dynamic>;
      
      // If we are in the start chapter, start from startV, else start from verse 1
      int firstVerseInChapter = (c == startCh) ? startV : 1;
      
      // If we are in the end chapter, end at endV, else go to the end of the chapter
      int lastVerseInChapter = -1;
      if (c == endCh) {
        lastVerseInChapter = endV;
      } else {
        lastVerseInChapter = maxVerseInChapter(book, c);
      }

      for (int v = firstVerseInChapter; v <= lastVerseInChapter; v++) {
        final count = (verses[v.toString()] as num?)?.toInt() ?? 0;
        total += count;
      }
    }
    
    return total;
  }

  /// Returns the highest verse number in the given chapter.
  int maxVerseInChapter(String book, int chapter) {
    _ensureInitialized();
    try {
      final bookData = _data![book];
      if (bookData == null) return 0;
      final chapterData = bookData[chapter.toString()];
      if (chapterData == null) return 0;
      final verses = chapterData['verses'] as Map<String, dynamic>;
      int maxV = 0;
      for (final vKey in verses.keys) {
        final vNum = int.tryParse(vKey) ?? 0;
        if (vNum > maxV) maxV = vNum;
      }
      return maxV;
    } catch (e) {
      return 0;
    }
  }

  void _ensureInitialized() {
    if (_data == null) {
      throw StateError('WordCountService is not initialized. Call init() first.');
    }
  }
}
