// Share cards render at 1080x1350 with no overflow, for short and long
// verses and word cards.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/ui/widgets/share_card.dart';

Widget host(Widget card) => MaterialApp(
      home: Scaffold(
        // Surface enough room for the full-size card so the layout is
        // exercised unconstrained inside the FittedBox used in-app.
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 1080,
              height: 1400,
              child: card,
            ),
          ),
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
