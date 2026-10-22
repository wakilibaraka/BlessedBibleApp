// Plans Library redesign: pure-logic unit tests + widget smoke test.
// Mirrors the harness in widget_test.dart (mocked prefs, AppTheme).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/l10n/generated/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/bible_books.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/plans_library_screen.dart';
import 'package:the_blessed_bible/ui/widgets/plans_library_widgets.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('plans library helpers', () {
    test('hero date is month and day, weekday is upper-cased', () {
      final day = DateTime(2026, 10, 22);
      expect(libraryMonthDay(day), 'October 22');
      expect(libraryWeekday(day), 'THURSDAY');
    });

    test('plan initials are stable and sensible', () {
      expect(planInitials("M'Cheyne 1-Year Plan"), 'M1');
      expect(planInitials('Psalms'), 'PS');
      expect(planInitials('  '), 'BB');
    });

    test('book presets reference real books with sane durations', () {
      expect(bookPlanPresets.length, greaterThanOrEqualTo(8));
      for (final p in bookPlanPresets) {
        expect(p.title.isNotEmpty, isTrue);
        expect(p.days, greaterThan(0));
        expect(
          kBibleBookNames
              .any((b) => b.toLowerCase() == p.startBook.toLowerCase()),
          isTrue,
          reason: 'unknown start book ${p.startBook}',
        );
        expect(
          kBibleBookNames
              .any((b) => b.toLowerCase() == p.endBook.toLowerCase()),
          isTrue,
          reason: 'unknown end book ${p.endBook}',
        );
        final startIdx = kBibleBookNames
            .indexWhere((b) => b.toLowerCase() == p.startBook.toLowerCase());
        final endIdx = kBibleBookNames
            .indexWhere((b) => b.toLowerCase() == p.endBook.toLowerCase());
        expect(endIdx, greaterThanOrEqualTo(startIdx));
      }
    });
  });

  group('plans library screen', () {
    Future<void> pumpLibrary(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(PreferencesService(prefs)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme(1.0),
          home: const PlansLibraryScreen(),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('renders header, tabs and curated plans', (tester) async {
      await pumpLibrary(tester);

      // The greeting and the calendar strip are gone; the hero shows the
      // date and the year-progress line instead.
      expect(find.text('Hello,'), findsNothing);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
      expect(find.textContaining('My Plans'), findsOneWidget);
      // Curated plan cards on the Reading tab.
      expect(find.text("M'Cheyne 1-Year Plan"), findsOneWidget);
      // Unstarted plans show their length and a Start button instead of
      // an empty bar labelled "Not started" twice.
      expect(find.text('365 days'), findsWidgets);
      expect(find.text('Start'), findsWidgets);
      expect(find.text('Not started'), findsNothing);
      expect(find.text('New readings'), findsNothing);
      // The Bible-story band is gone; no active plan means no hero.
      expect(find.text('Bible story'), findsNothing);
      expect(find.text('My Plans'), findsOneWidget);
      // Year progress link is in the hero; no streak chip at 0.
      expect(find.textContaining('Day '), findsWidgets);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);
    });

    testWidgets('Books tab shows presets, My Plans shows empty state',
        (tester) async {
      await pumpLibrary(tester);

      // Note: pump(), not pumpAndSettle() — the themed background
      // animates continuously, so the framework never fully settles.
      await tester.tap(find.text('Books'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Genesis in 30 days'), findsOneWidget);
      // Last preset starts below the fold — scroll it into view.
      await tester.dragUntilVisible(
        find.text('Gospels in 90 days'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Gospels in 90 days'), findsOneWidget);

      await tester.tap(find.textContaining('My Plans'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('No active plans'), findsOneWidget);
    });
  });

  group('plans header', () {
    Widget host(Widget child) => MaterialApp(
          theme: AppTheme.lightTheme(1.0),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        );

    testWidgets('streak chip shows the count, and nothing at 0',
        (tester) async {
      await tester.pumpWidget(host(const StreakChip(count: 3)));
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.pumpWidget(host(const StreakChip(count: 0)));
      expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);
    });

    testWidgets('year progress sits on the date row, to its right',
        (tester) async {
      await tester.pumpWidget(host(LibraryHeroHeader(
        weekday: 'THURSDAY',
        date: 'October 22',
        progressLabel: 'Day 295 of 365',
        onProgressPressed: () {},
      )));
      final date = tester.getRect(find.text('October 22'));
      final progress = tester.getRect(find.text('Day 295 of 365'));
      expect(progress.left, greaterThan(date.right));
      // Shares the date's line rather than sitting below it.
      expect(progress.top, lessThan(date.bottom));
    });
  });
}
