// Share cards render at their export size with no overflow, for short and
// long verses, word cards, story cards, commentary cards and every format.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/share_content.dart';
import 'package:the_blessed_bible/ui/widgets/share_card.dart';

Widget host(Widget card) => MaterialApp(
      home: Scaffold(
        // Both axes scroll so the 1080-wide card is laid out at its export
        // size instead of being clamped to the test surface.
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(child: card),
        ),
      ),
    );

const short = 'Jesus wept.';
const long = 'For God so loved the world, that he gave his only begotten Son, '
    'that whosoever believeth in him should not perish, but have '
    'everlasting life. For God sent not his Son into the world to '
    'condemn the world, but that the world through him might be saved.';

void main() {
  for (final backdrop in ShareCardBackdrop.values) {
    testWidgets('verse card (short) renders without overflow: $backdrop',
        (tester) async {
      await tester.pumpWidget(host(ShareCard.verse(
        reference: 'John 11:35',
        body: short,
        translationTag: 'KJV',
        backdrop: backdrop,
      )));
      expect(tester.takeException(), isNull);
      expect(find.text(short), findsOneWidget);
      expect(find.text('JOHN 11:35 · KJV'), findsOneWidget);
      expect(find.text('John 11:35'), findsOneWidget);
    });
  }

  testWidgets('verse card (long passage) renders without overflow',
      (tester) async {
    await tester.pumpWidget(host(ShareCard.verse(
      reference: 'John 3:16-17',
      body: long,
      translationTag: 'KJV',
    )));
    expect(tester.takeException(), isNull);
    expect(find.text('JOHN 3:16-17 · KJV'), findsOneWidget);
  });

  testWidgets('verse card carries a decorative quote mark', (tester) async {
    await tester.pumpWidget(host(ShareCard.verse(
      reference: 'John 11:35',
      body: short,
      translationTag: 'KJV',
    )));
    expect(find.text('\u201c'), findsOneWidget);
  });

  for (final format in ShareCardFormat.values) {
    testWidgets('${format.name} export renders at its exact size',
        (tester) async {
      await tester.pumpWidget(host(
        ShareCard.verse(
          reference: 'John 11:35',
          body: short,
          translationTag: 'KJV',
          style: ShareCardStyle(format: format),
        ),
      ));
      expect(tester.takeException(), isNull);
      final card = tester.widget<ShareCard>(find.byType(ShareCard));
      expect(card.style.format, format);
      final box = tester.getSize(find.byType(ShareCard));
      expect(box.width, format.width);
      expect(box.height, format.height);
    });
  }

  testWidgets('word card renders caps headword and source', (tester) async {
    await tester.pumpWidget(host(ShareCard.word(
      eyebrow: 'Word of the day',
      word: 'grace',
      definition: 'Unmerited favour of God toward sinners.',
      source: "Easton's Bible Dictionary",
    )));
    expect(tester.takeException(), isNull);
    expect(find.text('GRACE'), findsOneWidget);
    expect(find.text('WORD OF THE DAY'), findsOneWidget);
    expect(find.text("EASTON'S BIBLE DICTIONARY"), findsOneWidget);
  });

  testWidgets('story card renders eyebrow, title, summary, and reference',
      (tester) async {
    await tester.pumpWidget(host(ShareCard.story(
      eyebrow: 'Story of the day',
      title: 'The Creation of the World',
      summary: 'In the beginning God created the heaven and the earth.',
      reference: 'Genesis 1:1-2:3',
    )));
    expect(tester.takeException(), isNull);
    expect(find.text('STORY OF THE DAY'), findsOneWidget);
    expect(find.text('THE CREATION OF THE WORLD'), findsOneWidget);
    expect(find.text('In the beginning God created the heaven and the earth.'),
        findsOneWidget);
    expect(find.text('Genesis 1:1-2:3'), findsOneWidget);
  });

  testWidgets('commentary card renders a quoted insight and attribution',
      (tester) async {
    await tester.pumpWidget(host(ShareCard.commentary(
      eyebrow: 'Genesis 1:2',
      insight: 'The earth was without form and void.',
      attribution: 'Ellen G. White, Patriarchs and Prophets',
    )));
    expect(tester.takeException(), isNull);
    expect(find.text('GENESIS 1:2'), findsOneWidget);
    expect(find.text('\u201cThe earth was without form and void.\u201d'),
        findsOneWidget);
    expect(
        find.text('Ellen G. White, Patriarchs and Prophets'), findsOneWidget);
  });

  testWidgets('artwork backdrop renders with a plate path', (tester) async {
    await tester.pumpWidget(host(ShareCard.verse(
      reference: 'John 3:16',
      body: short,
      translationTag: 'KJV',
      backdrop: ShareCardBackdrop.artwork,
      artworkPath: 'assets/devotional/art/creation.webp',
    )));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('artwork backdrop without a plate falls back to a gradient',
      (tester) async {
    await tester.pumpWidget(host(ShareCard.verse(
      reference: 'John 3:16',
      body: short,
      translationTag: 'KJV',
      backdrop: ShareCardBackdrop.artwork,
    )));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('typography style is applied to the passage', (tester) async {
    await tester.pumpWidget(host(ShareCard.verse(
      reference: 'John 3:16',
      body: short,
      translationTag: 'KJV',
      style: const ShareCardStyle(
        fontFamily: 'Lora',
        scale: 1.2,
        letterSpacing: 2,
        lineHeight: 1.6,
        align: TextAlign.center,
      ),
    )));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
    // The passage itself must carry the chosen typography.
    final passage = tester.widget<Text>(find.text(short));
    expect(passage.style?.fontFamily, 'Lora');
    expect(passage.style?.letterSpacing, 2);
    expect(passage.textAlign, TextAlign.center);
    // Eyebrow keeps its own tracking (a control label, not body copy).
    final eyebrow = tester.widget<Text>(find.text('JOHN 3:16 · KJV'));
    expect(eyebrow.style?.letterSpacing, 6);
  });

  test('ShareCardStyle copyWith honours clearFont', () {
    const s = ShareCardStyle(fontFamily: 'Lora', scale: 1.2);
    expect(s.copyWith().fontFamily, 'Lora');
    expect(s.copyWith(clearFont: true).fontFamily, isNull);
    expect(s.copyWith(scale: 0.85).scale, 0.85);
    // Other fields survive.
    expect(s.copyWith(scale: 0.85).fontFamily, 'Lora');
  });

  test('ShareCardStyle copyWith keeps and replaces the format', () {
    const s = ShareCardStyle();
    expect(s.format, ShareCardFormat.portrait);
    expect(s.copyWith(format: ShareCardFormat.story).format,
        ShareCardFormat.story);
    expect(s.copyWith(scale: 0.85).format, ShareCardFormat.portrait);
  });

  group('ShareCard.fromContent', () {
    testWidgets('verse content becomes a verse card', (tester) async {
      await tester.pumpWidget(host(ShareCard.fromContent(ShareContent.verse(
        reference: 'John 11:35',
        texts: [short],
        translationTag: 'KJV',
      ))));
      expect(tester.takeException(), isNull);
      expect(find.text('JOHN 11:35 · KJV'), findsOneWidget);
      expect(find.text(short), findsOneWidget);
    });

    testWidgets('story content shows a caps title and excerpt', (tester) async {
      await tester.pumpWidget(host(ShareCard.fromContent(ShareContent.story(
        title: 'The Creation of the World',
        body: 'In the beginning God created the heaven and the earth.',
        reference: 'Genesis 1:1-2:3',
        eyebrow: 'Story of the day',
      ))));
      expect(tester.takeException(), isNull);
      expect(find.text('THE CREATION OF THE WORLD'), findsOneWidget);
      expect(find.text('Genesis 1:1-2:3'), findsOneWidget);
    });

    testWidgets('commentary content becomes a commentary card', (tester) async {
      await tester.pumpWidget(host(ShareCard.fromContent(
        ShareContent.commentary(
          text: 'The earth was without form and void.',
          reference: 'Genesis 1:2',
          source: 'Patriarchs and Prophets',
          author: 'Ellen G. White',
        ),
      )));
      expect(tester.takeException(), isNull);
      expect(find.text('GENESIS 1:2'), findsOneWidget);
      expect(
          find.text('Ellen G. White, Patriarchs and Prophets'), findsOneWidget);
    });
  });

  testWidgets('word card with a very long definition stays inside',
      (tester) async {
    await tester.pumpWidget(host(ShareCard.word(
      eyebrow: 'Dictionary',
      word: 'abomination',
      definition: List.filled(120, 'word').join(' '),
      source: 'Smith',
    )));
    expect(tester.takeException(), isNull);
  });
}
