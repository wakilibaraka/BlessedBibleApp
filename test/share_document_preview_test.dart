// The PDF page preview must look like the exported document: A4 portrait,
// running head, title, byline, body and footer, for both long-form kinds.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/share_content.dart';
import 'package:the_blessed_bible/ui/widgets/share_document_preview.dart';

Widget host(Widget child) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: child,
          ),
        ),
      ),
    );

void main() {
  testWidgets('commentary preview is A4 with head, title, body and citation',
      (tester) async {
    await tester.pumpWidget(host(ShareDocumentPreview(
      content: ShareContent.commentary(
        text: 'The earth was without form, and void; and darkness was upon '
            'the face of the deep.',
        reference: 'Genesis 1:2',
        source: 'Patriarchs and Prophets',
        author: 'Ellen G. White',
        eyebrow: 'Commentary',
      ),
    )));

    expect(tester.takeException(), isNull);
    expect(find.text('Genesis 1:2'), findsOneWidget);
    expect(find.text('COMMENTARY'), findsOneWidget);
    expect(find.textContaining('The earth was without form'), findsOneWidget);
    expect(
        find.text('— Ellen G. White, Patriarchs and Prophets'), findsOneWidget);
    expect(find.text('The Blessed Bible'), findsOneWidget);

    // A4 portrait proportions.
    final size = tester.getSize(find
        .descendant(
          of: find.byType(ShareDocumentPreview),
          matching: find.byType(Container),
        )
        .first);
    expect(size.width / size.height, closeTo(1 / 1.414, 0.02));
  });

  testWidgets('story preview leads with the title and key verse',
      (tester) async {
    await tester.pumpWidget(host(ShareDocumentPreview(
      content: ShareContent.story(
        title: 'The Creation of the World',
        body: 'In the beginning God created the heaven and the earth.',
        reference: 'Genesis 1:1-2:3',
        keyVerse: 'In the beginning God created the heaven and the earth.',
        keyVerseRef: 'Genesis 1:1',
        eyebrow: 'Bible stories',
      ),
    )));

    expect(tester.takeException(), isNull);
    expect(find.text('The Creation of the World'), findsOneWidget);
    expect(find.text('Genesis 1:1-2:3'), findsOneWidget);
    expect(find.text('Genesis 1:1'), findsOneWidget);
    // Stories carry their reference under the title, not as a closing cite.
    expect(find.textContaining('— Genesis'), findsNothing);
  });

  testWidgets('long commentary stays inside its page', (tester) async {
    await tester.pumpWidget(host(ShareDocumentPreview(
      content: ShareContent.commentary(
        text: List.filled(60, 'Long paragraph of insight.').join(' '),
        reference: 'Genesis 1:2',
        source: 'Patriarchs and Prophets',
        author: 'Ellen G. White',
      ),
    )));
    expect(tester.takeException(), isNull);
  });
}
