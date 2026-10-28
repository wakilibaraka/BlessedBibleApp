import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/bible_books.dart';
import 'package:the_blessed_bible/models/commentary_entry.dart';
import 'package:the_blessed_bible/models/commentary_work.dart';
import 'package:the_blessed_bible/utils/isolate_parsers.dart';

void main() {
  late List<CommentaryEntry> entries;
  late List<CommentaryWork> works;
  final packFile = File('assets/commentary/jfb.json.gz');

  setUpAll(() {
    entries = parseGzipCommentaryJson(packFile.readAsBytesSync());
    works = buildCommentaryWorks(entries);
  });

  test('compressed pack parses all entries and stays under 6 MB', () {
    expect(packFile.lengthSync(), lessThan(6 * 1024 * 1024));
    expect(entries, hasLength(19015));
    expect(entries.every((entry) => entry.text.trim().isNotEmpty), isTrue);
    expect(
      entries.every((entry) =>
          entry.source ==
          'Commentary Critical and Explanatory on the Whole Bible (1871)'),
      isTrue,
    );
  });

  test('JFB covers all 66 books and every canonical chapter', () {
    expect(works, hasLength(1));
    expect(works.single.title,
        'Commentary Critical and Explanatory on the Whole Bible (1871)');
    expect(works.single.books, kBibleBookNames);
    expect(works.single.chapterCount, 1189);
  });

  test('representative verse notes are indexed to the expected references', () {
    for (final (book, chapter, verse) in [
      ('Genesis', 1, 1),
      ('Exodus', 20, 8),
      ('Psalms', 119, 105),
      ('Daniel', 8, 14),
      ('Revelation', 14, 12),
    ]) {
      expect(
        entries.any((entry) =>
            entry.scope.type == 'verse' &&
            entry.scope.book == book &&
            entry.scope.chapter == chapter &&
            entry.scope.verse == verse),
        isTrue,
        reason: '$book $chapter:$verse should have a JFB note',
      );
    }
  });
}
