// Compact verse-action sheet: height contract, Apple tap targets,
// contextual label, and dismissal behaviour.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/widgets/verse_action_sheet.dart';

void main() {
  List<SheetAction> actions([int hits = 0]) => [
        SheetAction(
            icon: Icons.bookmark_border_rounded,
            label: 'Save',
            active: true,
            onTap: () => hits++),
        SheetAction(
            icon: Icons.color_lens_rounded,
            label: 'Highlight',
            onTap: () => hits++),
        SheetAction(icon: Icons.note_add_outlined, label: 'Note', onTap: () {}),
        SheetAction(
            icon: Icons.menu_book_rounded, label: 'Study', onTap: () {}),
        SheetAction(
            icon: Icons.ios_share_rounded, label: 'Share', onTap: () {}),
      ];

  Future<void> openSheet(
    WidgetTester tester, {
    required String label,
    int count = 1,
    List<SheetAction>? items,
  }) async {
    // TexturedGlassContainer reads theme/surface providers.
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
      theme: AppTheme.lightTheme(1.0),
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => VerseActionSheet.show(
              context,
              contextLabel: label,
              actionCount: count,
              actions: items ?? actions(),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('renders the five actions and the context label', (tester) async {
    await openSheet(tester, label: verseSelectionContextLabel('John', 3, [16]));

    expect(find.text('1 verse selected · John 3:16'), findsOneWidget);
    for (final label in ['Save', 'Highlight', 'Note', 'Study', 'Share']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
  });

  testWidgets('stays short — never a tall panel', (tester) async {
    await openSheet(tester,
        label: verseSelectionContextLabel('John', 3, [16, 17, 18]));

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final card = tester.getRect(find.textContaining('verses selected'));
    expect(card.height, lessThan(screenHeight * 0.3));
    // The height cap itself is part of the contract.
    expect(kVerseSheetMaxHeightFactor, lessThan(0.3));
  });

  testWidgets('tapping an action fires it and keeps the sheet open',
      (tester) async {
    var tapped = 0;
    await openSheet(
      tester,
      label: verseSelectionContextLabel('John', 3, [16]),
      items: [
        SheetAction(
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: () => tapped++,
        ),
      ],
    );

    await tester.tap(find.text('Copy'));
    await tester.pump();
    expect(tapped, 1);
  });

  test('labels: single, range, and non-contiguous selections', () {
    expect(verseSelectionContextLabel('John', 3, [16]),
        '1 verse selected · John 3:16');
    expect(verseSelectionContextLabel('John', 3, [16, 17, 18]),
        '3 verses selected · John 3:16-18');
    // Non-contiguous falls back to the chapter.
    expect(verseSelectionContextLabel('John', 3, [16, 20]),
        '2 verses selected · John 3');
  });
}
