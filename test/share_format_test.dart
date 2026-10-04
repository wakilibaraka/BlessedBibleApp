// Share text formatting: clean clipboard layout, WhatsApp-aware share
// flavor (italic reference lines), bilingual blocks, caps word format,
// and reference building.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/services/share_service.dart';

void main() {
  group('cleanVerseText', () {
    test("strips Strong's tags, keeps supplied words, drops markers", () {
      expect(
        ShareService.cleanVerseText(
            'the mighty [God] of Jacob[ H722 ]¶‹ Jesus › wept [ G11 ]'),
        'the mighty God of Jacob Jesus wept',
      );
    });

    test('collapses whitespace', () {
      expect(ShareService.cleanVerseText('  peace   be \n with  you '),
          'peace be with you');
    });
  });

  group('formatVerse', () {
    test('two-line layout with translation tag', () {
      expect(
        ShareService.formatVerse(
          texts: ['Jesus wept.'],
          reference: 'John 11:35',
          translationTag: 'KJV',
        ),
        '"Jesus wept."\n\n— John 11:35 (KJV)',
      );
    });

    test('whatsapp flavor italicises the reference line', () {
      expect(
        ShareService.formatVerse(
          texts: ['Jesus wept.'],
          reference: 'John 11:35',
          translationTag: 'KJV',
          whatsapp: true,
        ),
        '"Jesus wept."\n\n_— John 11:35 (KJV)_',
      );
    });

    test('multi-verse selection is numbered', () {
      expect(
        ShareService.formatVerse(
          texts: ['First.', 'Second.'],
          reference: 'John 3:16-17',
          translationTag: 'KJV',
        ),
        '"1. First. 2. Second."\n\n— John 3:16-17 (KJV)',
      );
    });

    test('bilingual: second block, italics in whatsapp flavor', () {
      const primary = ['For God so loved the world.'];
      const secondary = ['Car Dieu a tant aimé le monde.'];
      expect(
        ShareService.formatVerse(
          texts: primary,
          reference: 'John 3:16',
          translationTag: 'KJV',
          secondaryTexts: secondary,
          secondaryReference: 'John 3:16',
          secondaryTag: 'LSG',
        ),
        '"For God so loved the world."\n\n'
        '— John 3:16 (KJV)\n\n'
        '"Car Dieu a tant aimé le monde."\n\n'
        '— John 3:16 (LSG)',
      );
      expect(
        ShareService.formatVerse(
          texts: primary,
          reference: 'John 3:16',
          translationTag: 'KJV',
          secondaryTexts: secondary,
          secondaryReference: 'John 3:16',
          secondaryTag: 'LSG',
          whatsapp: true,
        ),
        '"For God so loved the world."\n\n'
        '_— John 3:16 (KJV)_\n\n'
        '_"Car Dieu a tant aimé le monde."_\n\n'
        '_— John 3:16 (LSG)_',
      );
    });

    test('missing secondary falls back silently to primary only', () {
      expect(
        ShareService.formatVerse(
          texts: ['Jesus wept.'],
          reference: 'John 11:35',
          translationTag: 'KJV',
          secondaryTexts: const [],
          secondaryReference: 'John 11:35',
          secondaryTag: 'LSG',
        ),
        '"Jesus wept."\n\n— John 11:35 (KJV)',
      );
    });

    test('empty input yields empty string', () {
      expect(
        ShareService.formatVerse(
            texts: const ['', '  '],
            reference: 'John 3:16',
            translationTag: 'KJV'),
        '',
      );
    });
  });

  group('formatWord', () {
    test('word and source in capitals', () {
      expect(
        ShareService.formatWord(
          word: 'grace',
          definition: 'Unmerited favour of God.',
          sourceName: "Easton's Bible Dictionary",
        ),
        'GRACE\n"Unmerited favour of God."\n\n'
        "— EASTON'S BIBLE DICTIONARY",
      );
    });

    test('long definitions truncate with an ellipsis', () {
      final out = ShareService.formatWord(
        word: 'abomination',
        definition: 'x' * 700,
        sourceName: 'Smith',
        maxDefinitionLength: 50,
      );
      expect(out.split('\n')[1], '"${'x' * 50}…"');
    });
  });

  group('referenceFor', () {
    test('single verse', () {
      expect(ShareService.referenceFor('John', 3, [16]), 'John 3:16');
    });
    test('contiguous becomes a range', () {
      expect(ShareService.referenceFor('John', 3, [16, 17, 18]),
          'John 3:16-18');
    });
    test('non-contiguous lists verses', () {
      expect(ShareService.referenceFor('John', 3, [16, 18, 19]),
          'John 3:16, 18, 19');
    });
    test('order independent', () {
      expect(ShareService.referenceFor('John', 3, [18, 16]), 'John 3:16, 18');
    });
  });
}