import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/models/bible_model.dart';
import 'package:the_blessed_bible/utils/passage.dart';
import 'package:the_blessed_bible/utils/prose.dart';

BibleBook _book(String name, List<int> versesPerChapter) => BibleBook(
      name: name,
      abbreviation: name,
      chapters: [
        for (var c = 0; c < versesPerChapter.length; c++)
          BibleChapter(number: c + 1, verses: [
            for (var v = 1; v <= versesPerChapter[c]; v++)
              BibleVerse(number: v, text: '${c + 1}.$v'),
          ]),
      ],
    );

void main() {
  group('PassageRef.parse', () {
    test('cross-chapter range', () {
      final p = PassageRef.parse('Judges 13:1-14:20')!;
      expect(p.bookName, 'Judges');
      expect(p.chapter, 13);
      expect(p.startVerse, 1);
      expect(p.endChapter, 14);
      expect(p.endVerse, 20);
      expect(p.wholeChapter, isFalse);
    });

    test('single-chapter range, single verse and whole chapter', () {
      final range = PassageRef.parse('1 Samuel 3:1-10')!;
      expect(range.bookName, '1 Samuel');
      expect(range.endChapter, isNull);
      expect(range.endVerse, 10);
      expect(PassageRef.parse('John 3:16')!.endVerse, isNull);
      expect(PassageRef.parse('Psalms 23')!.wholeChapter, isTrue);
    });

    test('rejects text that is not a reference', () {
      expect(PassageRef.parse('Judges'), isNull);
    });
  });

  group('resolvePassage', () {
    final books = [
      _book('Judges', [3, 4])
    ];

    test('spans chapters with chapter-prefixed labels', () {
      final verses =
          resolvePassage(books, PassageRef.parse('Judges 1:2-2:2')!)!;
      expect(verses.map((v) => v.label), ['1:2', '1:3', '2:1', '2:2']);
    });

    test('whole chapter returns every verse', () {
      final verses = resolvePassage(books, PassageRef.parse('Judges 2')!)!;
      expect(verses.map((v) => v.text), ['2.1', '2.2', '2.3', '2.4']);
    });

    test('missing book or chapter is null', () {
      expect(resolvePassage(books, PassageRef.parse('Ruth 1:1')!), isNull);
      expect(resolvePassage(books, PassageRef.parse('Judges 9:1')!), isNull);
    });
  });

  test('stripQuotes removes the pack quotes the reader would double', () {
    expect(stripQuotes('“"And the woman bare a son."”'),
        'And the woman bare a son.');
    expect(stripQuotes('“Now I beseech you”'), 'Now I beseech you');
    expect(stripQuotes('No quotes'), 'No quotes');
  });
}
