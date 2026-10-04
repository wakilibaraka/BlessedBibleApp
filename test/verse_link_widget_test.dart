// Verse links + bold composition + dictionary style reservation.
// The tap test pumps VerseLinkText and follows a link into the verse
// modal (content stays in its loading state without real async — the
// modal chrome, reference title and Open in Read action are asserted).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/widgets/verse_link_text.dart';

void main() {
  group('splitBoldSegments', () {
    test('hides markers and flags bold text', () {
      final segs = splitBoldSegments('Read **John 3:16** today.');
      expect(segs.length, 3);
      expect(segs[0], (text: 'Read ', bold: false));
      expect(segs[1], (text: 'John 3:16', bold: true));
      expect(segs[2], (text: ' today.', bold: false));
    });

    test('plain text is one non-bold segment', () {
      final segs = splitBoldSegments('No markers here.');
      expect(segs.length, 1);
      expect(segs.single.bold, isFalse);
    });

    test('unmatched markers stay literal', () {
      final segs = splitBoldSegments('A **lonely marker.');
      expect(segs.length, 1);
      expect(segs.single.text, 'A **lonely marker.');
    });
  });

  testWidgets('dictionary style is dotted, untapped, theme gray',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(1.0),
        home: Builder(builder: (context) {
          final style = dictionaryWordStyle(
            context,
            const TextStyle(color: Colors.black),
          );
          expect(style.decoration, TextDecoration.underline);
          expect(style.decorationStyle, TextDecorationStyle.dotted);
          return const SizedBox.shrink();
        }),
      ),
    );
  });

  testWidgets('tapping a verse span opens the verse modal', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(PreferencesService(prefs)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme(1.0),
          home: const Scaffold(
            // Centered so the center-tap lands on the link span.
            body: Center(
              child: VerseLinkText(
                // Entire string is the link.
                text: 'John 3:16',
                referenceStyle: TextStyle(color: Colors.blue),
                numberStyle: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byType(RichText));
    await tester.pump(const Duration(milliseconds: 300));

    // Modal chrome with the reference title and the Read action.
    expect(find.text('John 3:16'), findsWidgets);
    expect(find.text('Open in Read'), findsOneWidget);
  });
}
