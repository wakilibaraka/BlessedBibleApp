import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/models/bible_model.dart';
import 'package:the_blessed_bible/data/models/commentary_model.dart';
import 'package:the_blessed_bible/data/models/home_data.dart';
import 'package:the_blessed_bible/state/search_engine.dart';

void main() {
  test('SearchEngine builds index and executes query', () async {
    final books = [
      BibleBook(
        name: 'Genesis',
        abbreviation: 'Gen',
        chapters: [
          BibleChapter(
            number: 1,
            verses: [
              BibleVerse(number: 1, text: "In the beginning God created the heaven and the earth."),
            ],
          ),
        ],
      ),
      BibleBook(
        name: 'John',
        abbreviation: 'John',
        chapters: [
          BibleChapter(
            number: 3,
            verses: [
              BibleVerse(number: 16, text: "For God so loved the world..."),
            ],
          ),
        ],
      )
    ];

    final commentary = {
      'Daniel': {
        '1': {
          '1': [
            CommentaryEntry(id: 'uriah_smith', title: 'Uriah Smith', text: 'This is a test commentary by Uriah.'),
            CommentaryEntry(id: 'egw', title: 'EGW', text: 'This should be ignored.'),
          ]
        }
      }
    };

    final notes = [
      PersonalNote('My Note', 'This is a test note about creation.', '2026-07-26'),
    ];

    final engine = SearchEngine(bibleBooks: books, commentaryData: commentary, notes: notes);

    // Test 1: Verse text query
    final res1 = await engine.search('beginning');
    expect(res1.isNotEmpty, isTrue);
    expect(res1.first.title, 'Genesis 1:1');

    // Test 2: Reference query
    final res2 = await engine.search('John 3:16');
    expect(res2.isNotEmpty, isTrue);
    expect(res2.first.type, SearchResultType.reference);

    // Test 3: Commentary query
    final res3 = await engine.search('uriah');
    expect(res3.isNotEmpty, isTrue);
    expect(res3.first.type, SearchResultType.commentary);

    // Test 4: EGW query (should be ignored)
    final res4 = await engine.search('ignored');
    expect(res4.isEmpty, isTrue);

    // Test 5: Note query
    final res5 = await engine.search('creation');
    expect(res5.isNotEmpty, isTrue);
    expect(res5.first.type, SearchResultType.note);
  });
}
