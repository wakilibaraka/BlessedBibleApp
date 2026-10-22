// Plan detail redesign: readings list replaces the calendar, catch-up
// offers mark-all-previous. Uses a real bundled asset (rootBundle works
// in tests) with mocked prefs; no notification channels touched.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/reading_plan_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/reading_plan_detail_v2_screen.dart';

void main() {
  // Started 10 days ago, days 1..8 done -> behind by day 9.
  // NOTE: the provider is pre-loaded here (not after pumpWidget) because
  // rootBundle + compute need real async time, which only runAsync gives.
  Future<ProviderContainer> makeContainer(WidgetTester tester,
      {bool started = true}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
    final start = DateTime.now().subtract(const Duration(days: 9));
    if (started) {
      container.read(preferencesProvider).saveReadingPlanState(
        'chronological_1yr',
        {
          'planId': 'chronological_1yr',
          'planStartedOn': start.toIso8601String(),
          'paceMode': 'scheduled',
          'completedReadings': [1, 2, 3, 4, 5, 6, 7, 8],
          'reminderEnabled': false,
          'reminderTimeHour': 8,
          'reminderTimeMinute': 0,
        },
      );
    }
    // Provider creation AND load must both happen under real async:
    // FakeAsync stalls rootBundle + compute futures created outside it.
    await tester.runAsync(() async {
      container.read(readingPlanProvider('chronological_1yr'));
      for (var i = 0; i < 100; i++) {
        final s = container.read(readingPlanProvider('chronological_1yr'));
        if (!s.isLoading) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    });
    final loaded = container.read(readingPlanProvider('chronological_1yr'));
    expect(loaded.error, isNull);
    expect(loaded.isLoading, isFalse);
    expect(loaded.planData.length, 365);
    return container;
  }

  testWidgets('detail shows readings list and catch-up actions',
      (tester) async {
    final container = await makeContainer(tester);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme(1.0),
          home: const ReadingPlanDetailV2Screen(planId: 'chronological_1yr'),
        ),
      ),
    );
    await tester.pump();

    // List header, not a calendar grid.
    expect(find.textContaining('READINGS ·'), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
    // Hero holds the oldest missed day with one Read button.
    expect(find.text('CATCH UP · DAY 9'), findsOneWidget);
    expect(find.text('Read day 9'), findsOneWidget);
    // Catch-up with the bulk action.
    expect(find.textContaining('Behind by'), findsOneWidget);
    expect(find.text('Mark all previous done'), findsOneWidget);
    // The list opens one day before the hero; earlier days fold away.
    expect(find.text('Show 7 earlier days'), findsOneWidget);
    expect(find.textContaining('Genesis 1:1'), findsNothing);
    await tester.tap(find.text('Show 7 earlier days'));
    await tester.pump();
    expect(find.textContaining('Genesis 1:1'), findsWidgets);
    // Pace no longer takes room on the page; it lives in the ⋯ sheet.
    expect(find.text('Flexible'), findsNothing);
  });

  testWidgets('mark all previous completes every earlier day', (tester) async {
    final container = await makeContainer(tester);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme(1.0),
          home: const ReadingPlanDetailV2Screen(planId: 'chronological_1yr'),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Mark all previous done'));
    await tester.pump(const Duration(milliseconds: 300));

    final state = container.read(readingPlanProvider('chronological_1yr'));
    final current = state.todayReadingDay ?? state.planData.length;
    for (var d = 1; d < current; d++) {
      expect(state.completedReadings.contains(d), isTrue,
          reason: 'day $d should be marked (current=$current)');
    }
    expect(find.textContaining('marked as read'), findsOneWidget);
  });

  testWidgets('not started: start & read adds the plan and starts day 1',
      (tester) async {
    final container = await makeContainer(tester, started: false);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme(1.0),
          home: const ReadingPlanDetailV2Screen(planId: 'chronological_1yr'),
        ),
      ),
    );
    await tester.pump();

    // One screen: day 1, the start button, the date inline, the list.
    expect(find.text('Start & read day 1'), findsOneWidget);
    expect(find.text('Starts today'), findsOneWidget);
    expect(find.textContaining('READINGS ·'), findsOneWidget);
    expect(find.text('Begin plan'), findsNothing);

    await tester.tap(find.text('Start & read day 1'));
    await tester.pump();

    final state = container.read(readingPlanProvider('chronological_1yr'));
    expect(state.planStartedOn, isNotNull);
    expect(
        container.read(activePlanIdsProvider), contains('chronological_1yr'));
  });
}
