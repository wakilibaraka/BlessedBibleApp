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
const long =
    'For God so loved the world, that he gave his only begotten Son, '
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

  testWidgets('word card renders caps headword and source',
      (tester) async {
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