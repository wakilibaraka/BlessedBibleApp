// "Read in context" opens the chapter reading UI (the one a reading-plan day
// uses) at the right chapter, with the requested verse emphasised — never the
// main Read tab, and never a neighbouring verse.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/data/models/bible_model.dart';
import 'package:the_blessed_bible/l10n/l10n.dart';
import 'package:the_blessed_bible/state/bible_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/study_reader_screen.dart';
import 'package:the_blessed_bible/ui/widgets/passage_reader_link.dart';

class _FakeBible extends BibleNotifier {
  @override
  BibleState build() => BibleState(books: [
        BibleBook(name: 'Daniel', abbreviation: 'Dan', chapters: [
          // The reader indexes chapters by number, so chapter 11 has to be
          // eleventh in the list.
          for (var n = 1; n <= 11; n++)
            BibleChapter(number: n, verses: [
              if (n < 11) BibleVerse(number: 1, text: 'Chapter $n verse one.'),
              if (n == 11) ...[
                BibleVerse(number: 25, text: 'Verse twenty-five.'),
                BibleVerse(number: 26, text: 'Verse twenty-six.'),
                BibleVerse(number: 27, text: 'Verse twenty-seven.'),
              ],
            ]),
        ]),
      ]);
}

Future<void> _pumpReader(WidgetTester tester, {Locale? locale}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      bibleProvider.overrideWith(_FakeBible.new),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme(16),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const StudyReaderScreen(
        payload: StudySessionPayload.passage(
          bookName: 'Daniel',
          chapter: 11,
          verse: 26,
        ),
      ),
    ),
  ));
  // Fixed pumps rather than pumpAndSettle: the chapter reader keeps a
  // decorative animation running on some themes, which never settles.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

BoxDecoration _decorationOf(WidgetTester tester, String key) =>
    tester.widget<AnimatedContainer>(find.byKey(ValueKey(key))).decoration
        as BoxDecoration;

void main() {
  group('resolvePassageTarget', () {
    test('keeps the canonical book name and the requested verse', () {
      final target =
          resolvePassageTarget(bookName: 'Daniel', chapter: 11, verse: 26);
      expect(target, isNotNull);
      expect(target!.bookName, 'Daniel');
      expect(target.chapter, 11);
      expect(target.verse, 26);
    });

    test('canonicalises a lowercase or padded book name', () {
      expect(resolvePassageTarget(bookName: ' daniel ', chapter: 11)!.bookName,
          'Daniel');
      expect(resolvePassageTarget(bookName: '1 john', chapter: 3)!.bookName,
          '1 John');
    });

    test('a chapter-only target has no verse', () {
      expect(
          resolvePassageTarget(bookName: 'Daniel', chapter: 11)!.verse, isNull);
      expect(
          resolvePassageTarget(bookName: 'Daniel', chapter: 11, verse: 0)!
              .verse,
          isNull);
    });

    test('refuses unknown books and impossible chapters', () {
      expect(resolvePassageTarget(bookName: 'Hezekiah', chapter: 1), isNull);
      expect(resolvePassageTarget(bookName: '', chapter: 1), isNull);
      expect(resolvePassageTarget(bookName: 'Daniel', chapter: 0), isNull);
      expect(resolvePassageTarget(bookName: 'Daniel', chapter: -3), isNull);
    });
  });

  testWidgets('opens the chapter reader with the requested verse emphasised',
      (tester) async {
    await _pumpReader(tester);

    expect(find.byType(StudyReaderScreen), findsOneWidget);
    // The chapter's own reading UI, labelled with the requested chapter.
    expect(find.textContaining('Daniel 11'), findsWidgets);
    // Verses render as RichText spans (red-letter markup), not Text widgets.
    expect(find.textContaining('Verse twenty-six', findRichText: true),
        findsOneWidget);

    // Only the requested verse carries the focus accent.
    expect(_decorationOf(tester, 'verse-11-26').border, isNotNull);
    expect(_decorationOf(tester, 'verse-11-25').border, isNull);
    expect(_decorationOf(tester, 'verse-11-27').border, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('book names inside the chapter reader follow the locale',
      (tester) async {
    await _pumpReader(tester, locale: const Locale('sw'));

    expect(find.textContaining('Danieli 11'), findsWidgets);
    expect(find.textContaining('Daniel 11'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
