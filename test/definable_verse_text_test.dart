// DefinableVerseText: long-press reports the word under the press,
// taps pass through, and the inner long-press beats an ancestor
// verse-menu long-press in the arena.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/ui/widgets/definable_verse_text.dart';

// Plain text under test: "12  In the beginning God created".
// "God" occupies offsets 21-24.
const _godSelection = TextSelection(baseOffset: 21, extentOffset: 24);

void main() {
  Future<RenderParagraph> pumpText(
    WidgetTester tester, {
    required ValueChanged<String> onWord,
    VoidCallback? onOuterMenu,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            onLongPress: onOuterMenu,
            child: DefinableVerseText(
              textSpan: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(text: '12  '),
                  TextSpan(text: 'In the beginning God created'),
                ],
              ),
              onWordLongPress: onWord,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    return tester.renderObject<RenderParagraph>(
        find.byType(RichText).first);
  }

  Future<void> longPressSelection(
      WidgetTester tester, RenderParagraph paragraph, TextSelection sel) async {
    final boxes = paragraph.getBoxesForSelection(sel);
    expect(boxes, isNotEmpty);
    await tester.longPressAt(
        paragraph.localToGlobal(boxes.first.toRect().center));
  }

  testWidgets('long-press on a word reports it lowercased',
      (tester) async {
    String? seen;
    final paragraph = await pumpText(tester, onWord: (w) => seen = w);

    await longPressSelection(tester, paragraph, _godSelection);
    expect(seen, 'god');
  });

  testWidgets('long-press on digits reports nothing', (tester) async {
    var calls = 0;
    final paragraph = await pumpText(tester, onWord: (_) => calls++);

    // The "12" verse number: inside the paragraph, no alpha word.
    await longPressSelection(
        tester, paragraph, const TextSelection(baseOffset: 0, extentOffset: 2));
    expect(calls, 0);
  });

  testWidgets('inner long-press wins over the ancestor menu',
      (tester) async {
    String? seen;
    var menuCalls = 0;
    final paragraph = await pumpText(tester,
        onWord: (w) => seen = w, onOuterMenu: () => menuCalls++);

    await longPressSelection(tester, paragraph, _godSelection);
    expect(seen, 'god');
    expect(menuCalls, 0);
  });
}
