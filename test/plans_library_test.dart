// Plans Library redesign: pure-logic unit tests + widget smoke test.
// Mirrors the harness in widget_test.dart (mocked prefs, AppTheme).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/bible_books.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/plans_library_screen.dart';
import 'package:the_blessed_bible/ui/widgets/plans_library_widgets.dart';
import 'package:the_blessed_bible/ui/widgets/library_calendar_rail.dart';

void main() {
  group('plans library helpers', () {
    test('date header formats like the reference design', () {
      expect(
        libraryDateHeader(DateTime(2025, 11, 10)),
        'November 10, 2025',
      );
    });

    test('calendar week is Monday-first with 7 days containing today', () {
      // 2025-11-10 is a Monday.
      final days = libraryWeekDays(DateTime(2025, 11, 12));
      expect(days.length, 7);
      expect(days.first.weekday, DateTime.monday);
      expect(days.last.weekday, DateTime.sunday);
      expect(
        days.any((d) => d.day == 12 && d.month == 11),
        isTrue,
      );
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
        final startIdx = kBibleBookNames.indexWhere(
            (b) => b.toLowerCase() == p.startBook.toLowerCase());
        final endIdx = kBibleBookNames.indexWhere(
            (b) => b.toLowerCase() == p.endBook.toLowerCase());
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

      expect(find.text('Hello,'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
      expect(find.textContaining('My Plans'), findsOneWidget);
      // Curated plan cards on the Reading tab.
      expect(find.text("M'Cheyne 1-Year Plan"), findsOneWidget);
      expect(find.text('New readings'), findsWidgets);
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
}
