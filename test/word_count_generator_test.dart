import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Generate word_counts.json', () {
    // Read the KJV bible JSON
    final file = File('assets/data/kjvbible.json');
    final jsonStr = file.readAsStringSync();
    final data = jsonDecode(jsonStr);
    final verses = data['verses'] as List<dynamic>;

    final result = <String, Map<String, dynamic>>{};
    int totalWords = 0;

    for (final v in verses) {
      final book = v['book_name'] as String;
      final chapterStr = v['chapter'].toString();
      final verseStr = v['verse'].toString();
      final text = v['text'] as String;

      // Clean the text and split on whitespace
      // We'll strip paragraph markers '¶ ', punctuation if needed, but the prompt says:
      // "split on whitespace, count tokens — simple and consistent; don’t overthink tokenization"
      final tokens = text.trim().split(RegExp(r'\s+'));
      // Wait, '¶' is separated by space? "¶ In the beginning..." -> token 1 is '¶'. 
      // Let's filter out standalone '¶' just to be safe, or just let it be a token? 
      // "don't overthink tokenization". We'll just filter empty strings.
      int count = 0;
      for (final t in tokens) {
        if (t.isNotEmpty && t != '¶') {
          count++;
        }
      }

      result.putIfAbsent(book, () => {});
      result[book]!.putIfAbsent(chapterStr, () => {'total': 0, 'verses': <String, int>{}});
      
      final chapterData = result[book]![chapterStr] as Map<String, dynamic>;
      final versesMap = chapterData['verses'] as Map<String, int>;
      
      versesMap[verseStr] = count;
      chapterData['total'] = (chapterData['total'] as int) + count;
      totalWords += count;
    }

    final outFile = File('assets/data/word_counts.json');
    outFile.writeAsStringSync(jsonEncode(result));

    debugPrint('Total words: $totalWords');
    final ps119 = result['Psalms']!['119'];
    debugPrint('Psalm 119 total words: ${ps119['total']}');
    final ps117 = result['Psalms']!['117'];
    debugPrint('Psalm 117 total words: ${ps117['total']}');
    final jn11_35 = result['John']!['11']['verses']['35'];
    debugPrint('John 11:35 total words: $jn11_35');
    
    int bookCount = result.keys.length;
    int chapterCount = 0;
    for (final b in result.keys) {
      chapterCount += result[b]!.keys.length;
    }
    debugPrint('Books: $bookCount, Chapters: $chapterCount');
  });
}
