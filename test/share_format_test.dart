// Share text formatting: clean clipboard layout, WhatsApp-aware markup,
// bilingual blocks, caps word format, commentary format and reference
// building.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/share_content.dart';
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

    test('collapses whitespace and strips bold markers', () {
      expect(ShareService.cleanVerseText('  **peace**   be \n with  you '),
          'peace be with you');
    });
  });

  group('formatVerse', () {
    test('single verse is quoted with a citation line', () {
      expect(
        ShareService.formatVerse(
          texts: ['Jesus wept.'],
          reference: 'John 11:35',
          translationTag: 'KJV',
        ),
        '“Jesus wept.”\n\n— John 11:35 (KJV)',
      );
    });

    test('whatsapp flavor italicises the citation line', () {
      expect(
        ShareService.formatVerse(
          texts: ['Jesus wept.'],
          reference: 'John 11:35',
          translationTag: 'KJV',
          whatsapp: true,
        ),
        '“Jesus wept.”\n\n_— John 11:35 (KJV)_',
      );
    });

    test('multi-verse selection keeps one verse per line', () {
      expect(
        ShareService.formatVerse(
          texts: ['First.', 'Second.'],
          reference: 'John 3:16-17',
          translationTag: 'KJV',
        ),
        'First.\nSecond.\n\n— John 3:16-17 (KJV)',
      );
    });

    test('verse numbers prefix each line when known', () {
      expect(
        ShareService.formatVerse(
          texts: ['First.', 'Second.'],
          reference: 'John 3:16-17',
          translationTag: 'KJV',
          verseNumbers: const [16, 17],
        ),
        '16 First.\n17 Second.\n\n— John 3:16-17 (KJV)',
      );
    });

    test('bilingual: second block with its own citation', () {
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
        '“For God so loved the world.”\n\n'
        '— John 3:16 (KJV)\n\n'
        '“Car Dieu a tant aimé le monde.”\n\n'
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
        '“For God so loved the world.”\n\n'
        '_— John 3:16 (KJV)_\n\n'
        '_“Car Dieu a tant aimé le monde.”_\n\n'
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
        '“Jesus wept.”\n\n— John 11:35 (KJV)',
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
    test('caps headword and source with a quoted definition', () {
      expect(
        ShareService.formatWord(
          word: 'grace',
          definition: "Unmerited favour of God.",
          sourceName: "Easton's Bible Dictionary",
        ),
        'GRACE\n\n'
        '“Unmerited favour of God.”\n\n'
        "— EASTON'S BIBLE DICTIONARY",
      );
    });

    test('whatsapp flavor bolds the headword', () {
      expect(
        ShareService.formatWord(
          word: 'grace',
          definition: 'Unmerited favour of God.',
          sourceName: 'Smith',
          whatsapp: true,
        ),
        '*GRACE*\n\n'
        '“Unmerited favour of God.”\n\n'
        '_— SMITH_',
      );
    });

    test('long definitions truncate on a word boundary', () {
      final out = ShareService.formatWord(
        word: 'abomination',
        definition: List.filled(200, 'word').join(' '),
        sourceName: 'Smith',
        maxDefinitionLength: 50,
      );
      expect(out, contains('…'));
      // Never cuts mid-word.
      expect(out, contains('word word'));
      expect(out.contains('wor…'), isFalse);
    });
  });

  group('formatStory', () {
    test('caps title, plain body and reference citation', () {
      expect(
        ShareService.formatStory(
          title: 'The Creation of the World',
          summary: 'In the beginning God created the heaven and the earth.',
          reference: 'Genesis 1:1-2:3',
        ),
        'THE CREATION OF THE WORLD\n\n'
        'In the beginning God created the heaven and the earth.\n\n'
        '— Genesis 1:1-2:3',
      );
    });

    test('whatsapp flavor bolds the title, italicises the reference', () {
      expect(
        ShareService.formatStory(
          title: 'Noah and the Ark',
          summary: 'The waters rose.',
          reference: 'Genesis 6:1-9:17',
          whatsapp: true,
        ),
        '*NOAH AND THE ARK*\n\n'
        'The waters rose.\n\n'
        '_— Genesis 6:1-9:17_',
      );
    });

    test('long story summary truncates with an ellipsis', () {
      final out = ShareService.formatStory(
        title: 'Noah and the Ark',
        summary: 'y' * 800,
        reference: 'Genesis 6:1-9:17',
        maxSummaryLength: 60,
      );
      expect(out, contains('…'));
    });
  });

  group('formatCommentary', () {
    test('reference heading, body and author/source citation', () {
      expect(
        ShareService.formatCommentary(
          text: 'Is it possible to imagine a time when nothing existed?',
          reference: 'Genesis 1:2',
          source: 'Patriarchs and Prophets',
          author: 'Ellen G. White',
        ),
        'Genesis 1:2\n\n'
        'Is it possible to imagine a time when nothing existed?\n\n'
        '— Ellen G. White, Patriarchs and Prophets',
      );
    });

    test('whatsapp flavor italicises the reference and citation', () {
      final out = ShareService.formatCommentary(
        text: 'The earth was without form.',
        reference: 'Genesis 1:2',
        source: 'Patriarchs and Prophets',
        author: 'Ellen G. White',
        whatsapp: true,
      );
      expect(out, startsWith('_Genesis 1:2_'));
      expect(out, contains('_— Ellen G. White, Patriarchs and Prophets_'));
    });

    test('bold markers never leak into shared text', () {
      final out = ShareService.formatCommentary(
        text: 'He called the **light** day.',
        reference: 'Genesis 1:5',
      );
      expect(out, contains('He called the light day.'));
      expect(out, isNot(contains('**')));
    });
  });

  group('ShareContent', () {
    final verse = ShareContent.verse(
      reference: 'John 3:16',
      texts: ['For God so loved the world.'],
      translationTag: 'KJV',
    );

    test('includeReference drops the citation on request', () {
      expect(
          verse.text(includeReference: false), '“For God so loved the world.”');
    });

    test('caption names the reference and the app', () {
      expect(verse.caption, 'John 3:16 (KJV) · The Blessed Bible');
    });

    test('PDF is offered for long-form content only', () {
      expect(verse.offersPdf, isFalse);
      final story = ShareContent.story(
        title: 'Creation',
        body: 'In the beginning.',
        reference: 'Genesis 1:1',
      );
      final commentary = ShareContent.commentary(
        text: 'The earth was without form.',
        reference: 'Genesis 1:2',
      );
      expect(story.offersPdf, isTrue);
      expect(commentary.offersPdf, isTrue);
    });

    test('story text leads with the key verse, then the retelling', () {
      final story = ShareContent.story(
        title: 'The Creation of the World',
        body: 'God made the heavens and the earth.',
        reference: 'Genesis 1:1-2:3',
        keyVerse: '"In the beginning God created the heaven and the earth."',
        keyVerseRef: 'Genesis 1:1',
      );
      expect(
        story.plain,
        'THE CREATION OF THE WORLD\n\n'
        '“In the beginning God created the heaven and the earth.”\n'
        'Genesis 1:1\n\n'
        'God made the heavens and the earth.\n\n'
        '— Genesis 1:1-2:3',
      );
    });

    test('excerpt stops on a word boundary with an ellipsis', () {
      final commentary = ShareContent.commentary(
        text: List.filled(80, 'word').join(' '),
        reference: 'Genesis 1:2',
      );
      final excerpt = commentary.excerpt(maxChars: 60);
      expect(excerpt, endsWith('…'));
      expect(excerpt.contains('wor…'), isFalse);
      expect(excerpt.length, lessThanOrEqualTo(61));
    });
  });

  group('referenceFor', () {
    test('single verse', () {
      expect(ShareService.referenceFor('John', 3, [16]), 'John 3:16');
    });
    test('contiguous becomes a range', () {
      expect(
          ShareService.referenceFor('John', 3, [16, 17, 18]), 'John 3:16-18');
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
