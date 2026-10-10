import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/services/translation_downloader.dart';

/// Minimal `complete.json` in the Free Use Bible API's documented shape.
Map<String, dynamic> _fixture() => {
      'translation': {'id': 'deu_l12'},
      'books': [
        {
          'id': 'GEN',
          'order': 1,
          'chapters': [
            {
              'chapter': {
                'number': 1,
                'content': [
                  {
                    'type': 'heading',
                    'content': ['Die Schöpfung']
                  },
                  {
                    'type': 'verse',
                    'number': 1,
                    'content': [
                      'Am Anfang schuf Gott',
                      {'text': 'Himmel und Erde', 'wordsOfJesus': false},
                      {'noteId': 0},
                      '.',
                    ],
                  },
                  {'type': 'line_break'},
                  {
                    'type': 'verse',
                    'number': 2,
                    'content': [
                      {'heading': 'inline'},
                      'Und die Erde war wüst ,',
                      {'lineBreak': true},
                      'und leer.',
                    ],
                  },
                ],
              },
            },
          ],
        },
        {
          'id': 'TOB', // apocrypha: skipped
          'order': 67,
          'chapters': [
            {
              'chapter': {
                'number': 1,
                'content': [
                  {
                    'type': 'verse',
                    'number': 1,
                    'content': ['Tobias']
                  },
                ],
              },
            },
          ],
        },
        {
          'id': 'REV',
          'order': 66,
          'chapters': [
            {
              'chapter': {
                'number': 22,
                'content': [
                  {
                    'type': 'verse',
                    'number': 21,
                    'content': ['Amen.']
                  },
                ],
              },
            },
          ],
        },
      ],
    };

void main() {
  test('parses verses, book numbers and text from complete.json', () {
    final rows = TranslationDownloader.versesFromCompleteJson(_fixture(),
        translationId: 'deu_l12', languageCode: 'de');

    expect(rows, hasLength(3));
    expect(rows[0], {
      'translation_id': 'deu_l12',
      'language_code': 'de',
      'book_number': 1,
      'chapter': 1,
      'verse': 1,
      'text': 'Am Anfang schuf Gott Himmel und Erde.',
    });
    expect(rows[1]['text'], 'Und die Erde war wüst, und leer.');
    expect(rows[2]['book_number'], 66);
    expect(rows.any((r) => r['text'] == 'Tobias'), isFalse);
  });

  // CI downloads the real file first (see .github/workflows/ci.yml); skipped
  // locally when it isn't there.
  final live = File('build/helloao/deu_l12.complete.json');
  test('parses the live Luther 1912 download end to end', () {
    final rows = TranslationDownloader.versesFromCompleteJson(
        jsonDecode(live.readAsStringSync()) as Map<String, dynamic>,
        translationId: 'deu_l12',
        languageCode: 'de');
    expect(rows.length, greaterThan(31000));
    expect({for (final r in rows) r['book_number']}, hasLength(66));
    expect(rows.first['text'], startsWith('Am Anfang schuf Gott'));
  }, skip: live.existsSync() ? false : 'no live download in this run');

  test('parses OSIS verses, skipping notes and apocrypha', () {
    const xml = """<?xml version="1.0" encoding="UTF-8"?>
<osis><osisText><div type="book" osisID="Gen"><chapter osisID="Gen.1">
<verse osisID="Gen.1.1">Kezdetben teremté Isten<note>jegyzet</note> az eget és a földet .</verse>
<verse osisID="Gen.1.2">Hogy az õ egyszülött Fiát adta</verse>
</chapter></div><div type="book" osisID="Tob"><chapter osisID="Tob.1">
<verse osisID="Tob.1.1">Tobiás</verse></chapter></div></osisText></osis>""";
    final rows = TranslationDownloader.versesFromOsis(xml,
        translationId: 'hun_kar', languageCode: 'hu', fixLegacyHungarian: true);
    expect(rows, hasLength(2));
    expect(rows[0]['text'], 'Kezdetben teremté Isten az eget és a földet.');
    expect(rows[0]['book_number'], 1);
    expect(rows[1]['text'], 'Hogy az ő egyszülött Fiát adta');
  });

  final liveOsis = File('build/open-bibles/hun-karoli.osis.xml');
  test('parses the live Károli OSIS end to end', () {
    final rows = TranslationDownloader.versesFromOsis(
        liveOsis.readAsStringSync(),
        translationId: 'hun_kar',
        languageCode: 'hu',
        fixLegacyHungarian: true);
    expect(rows, hasLength(31170));
    expect({for (final r in rows) r['book_number']}, hasLength(66));
    final john316 = rows.firstWhere(
        (r) => r['book_number'] == 43 && r['chapter'] == 3 && r['verse'] == 16);
    expect(john316['text'], contains('az ő egyszülött Fiát'));
    expect(rows.any((r) => (r['text'] as String).contains('õ')), isFalse);
  }, skip: liveOsis.existsSync() ? false : 'no live download in this run');
}
