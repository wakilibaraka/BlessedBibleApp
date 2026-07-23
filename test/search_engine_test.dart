import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/models/bible_model.dart';
import 'package:the_blessed_bible/state/search_engine.dart';

void main() {
  group('SearchEngine', () {
    final mockBooks = [
      BibleBook(
        name: 'Genesis',
        abbreviation: 'GEN',
        chapters: [
          BibleChapter(
            number: 1,
            verses: [
              BibleVerse(number: 1, text: 'In the beginning...'),
              BibleVerse(number: 2, text: 'And the earth...'),
            ],
          ),
          BibleChapter(
            number: 2,
            verses: [
              BibleVerse(number: 1, text: 'Thus the heavens...'),
            ],
          ),
        ],
      ),
      BibleBook(
        name: 'Revelation',
        abbreviation: 'REV',
        chapters: [
          BibleChapter(
            number: 1,
            verses: [
              BibleVerse(number: 1, text: 'The Revelation of Jesus Christ...'),
            ],
          ),
          BibleChapter(
            number: 14,
            verses: [
              BibleVerse(number: 1, text: 'And I looked, and, lo, a Lamb stood on the mount Sion...'),
            ],
          ),
        ],
      ),
      BibleBook(
        name: '1 Corinthians',
        abbreviation: '1CO',
        chapters: List.generate(13, (i) {
          return BibleChapter(
            number: i + 1,
            verses: [
              if (i == 12) BibleVerse(number: 1, text: 'Though I speak with the tongues of men and of angels...'),
            ],
          );
        }),
      ),
    ];

    test('parses exact book name correctly', () {
      final engine = SearchEngine(bibleBooks: mockBooks);
      final results = engine.search('Genesis');
      
      final refResults = results.where((r) => r.type == SearchResultType.reference).toList();
      expect(refResults.length, 1);
      expect(refResults[0].metadata['bookAbbrev'], 'GEN');
      expect(refResults[0].metadata['chapter'], 1);
    });

    test('parses book abbreviation correctly', () {
      final engine = SearchEngine(bibleBooks: mockBooks);
      final results = engine.search('REV');
      
      final refResults = results.where((r) => r.type == SearchResultType.reference).toList();
      expect(refResults.length, 1);
      expect(refResults[0].metadata['bookAbbrev'], 'REV');
    });

    test('parses book prefix correctly', () {
      final engine = SearchEngine(bibleBooks: mockBooks);
      final results = engine.search('reve');
      
      final refResults = results.where((r) => r.type == SearchResultType.reference).toList();
      expect(refResults.length, 1);
      expect(refResults[0].metadata['bookAbbrev'], 'REV');
    });

    test('parses book and chapter correctly', () {
      final engine = SearchEngine(bibleBooks: mockBooks);
      final results = engine.search('gen 2');
      
      final refResults = results.where((r) => r.type == SearchResultType.reference).toList();
      expect(refResults.length, 1);
      expect(refResults[0].metadata['bookAbbrev'], 'GEN');
      expect(refResults[0].metadata['chapter'], 2);
      expect(refResults[0].metadata['verse'], null);
    });

    test('parses book, chapter and verse correctly', () {
      final engine = SearchEngine(bibleBooks: mockBooks);
      final results = engine.search('gen 1:2');
      
      final refResults = results.where((r) => r.type == SearchResultType.reference).toList();
      expect(refResults.length, 1);
      expect(refResults[0].metadata['bookAbbrev'], 'GEN');
      expect(refResults[0].metadata['chapter'], 1);
      expect(refResults[0].metadata['verse'], 2);
    });

    test('parses numbered books correctly', () {
      final engine = SearchEngine(bibleBooks: mockBooks);
      final results = engine.search('1 cor 13:1');
      
      final refResults = results.where((r) => r.type == SearchResultType.reference).toList();
      expect(refResults.length, 1);
      expect(refResults[0].metadata['bookAbbrev'], '1CO');
      expect(refResults[0].metadata['chapter'], 13);
      expect(refResults[0].metadata['verse'], 1);
    });
    
    test('returns bible verse match correctly', () {
      final engine = SearchEngine(bibleBooks: mockBooks);
      final results = engine.search('Lamb stood');
      
      final bibleResults = results.where((r) => r.type == SearchResultType.bible).toList();
      expect(bibleResults.length, 1);
      expect(bibleResults[0].metadata['bookAbbrev'], 'REV');
      expect(bibleResults[0].metadata['chapter'], 14);
      expect(bibleResults[0].metadata['verse'], 1);
    });
  });
}
