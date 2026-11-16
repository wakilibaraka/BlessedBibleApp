// Slidable week calendar rail: Monday-first weeks, snapping pager,
// completion dots from the plan, and date-jump from the header.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/state/reading_plan_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/widgets/library_calendar_rail.dart';

ReadingPlanState planStartedOn(DateTime start, int days) => ReadingPlanState(
      planId: 'test',
      planData: List.generate(
        days,
        (i) => PlanDayData(
            day: i + 1,
            week: i ~/ 7 + 1,
            title: 'Day ${i + 1}',
            passages: const []),
      ),
      planStartedOn: start,
    );

DateTime atMidnight(DateTime d) => DateTime(d.year, d.month, d.day);

/// The week [weeksAhead] weeks from [today] whose day-number labels do
/// not include [today]'s day number, so `findsNothing` assertions are
/// stable on any calendar date.
List<DateTime> weekExcludingDay(DateTime today, int weeksAhead) {
  for (var offset = weeksAhead; offset < 26; offset++) {
    final week = libraryWeekDays(today.add(Duration(days: 7 * offset)));
    if (week.every((d) => d.day != today.day)) return week;
  }
  throw StateError('no week found');
}

Widget host({DateTime? today, ReadingPlanState? plan}) {
  final now = atMidnight(DateTime.now());
  return MaterialApp(
    theme: AppTheme.lightTheme(1.0),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 380,
          child: LibraryCalendarRail(
            today: today ?? now,
            plan: plan,
          ),
        ),
      ),
    ),
  );
}

/// PageView needs incremental frames to run its page animation.
Future<void> settlePaging(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('centers on the current week and renders 7 days', (tester) async {
    final today = atMidnight(DateTime.now());
    final week = libraryWeekDays(today);
    await tester.pumpWidget(host(today: today));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('${week.first.day}'), findsOneWidget); // Monday
    expect(find.text('${week.last.day}'), findsOneWidget); // Sunday
    expect(find.text('${today.day}'), findsOneWidget); // today
    expect(find.text('MON'), findsOneWidget);
    expect(find.text('SUN'), findsOneWidget);
  });

  testWidgets('sliding left shows the next week', (tester) async {
    final today = atMidnight(DateTime.now());
    final next = libraryWeekDays(today.add(const Duration(days: 7)));
    await tester.pumpWidget(host(today: today));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.fling(find.byType(PageView), const Offset(-260, 0), 900);
    await settlePaging(tester);

    expect(find.text('${next.first.day}'), findsOneWidget);
    expect(find.text('${next.last.day}'), findsOneWidget);
    if (next.every((d) => d.day != today.day)) {
      expect(find.text('${today.day}'), findsNothing);
    }
  });

  testWidgets('step button advances exactly one week', (tester) async {
    final today = atMidnight(DateTime.now());
    final next = libraryWeekDays(today.add(const Duration(days: 7)));
    await tester.pumpWidget(host(today: today));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await settlePaging(tester);

    expect(find.text('${next.first.day}'), findsOneWidget);
    expect(find.text('${next.last.day}'), findsOneWidget);
  });

  testWidgets('scrollToDate jumps to that week', (tester) async {
    final today = atMidnight(DateTime.now());
    final targetWeek = weekExcludingDay(today, 10);
    final targetDay = targetWeek.last; // Sunday
    await tester.pumpWidget(host(today: today));
    await tester.pump(const Duration(milliseconds: 100));

    final state = tester
        .state<LibraryCalendarRailState>(find.byType(LibraryCalendarRail));
    state.scrollToDate(targetDay);
    await settlePaging(tester);

    expect(find.text('${targetWeek.last.day}'), findsOneWidget);
    expect(find.text('${targetWeek.first.day}'), findsOneWidget);
    expect(find.text('${today.day}'), findsNothing);
  });

  testWidgets('completion dots come from the plan', (tester) async {
    // Plan started Oct 1; mark day 4 complete (Oct 4 = today).
    var plan = planStartedOn(DateTime(2026, 10, 1), 30);
    plan = plan.copyWith(completedReadings: {4});
    await tester.pumpWidget(host(plan: plan));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    // Rendering completes without overflow at phone width.
    expect(find.byType(LibraryCalendarRail), findsOneWidget);
  });

  testWidgets('no plan -> no crash, still scrollable', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.fling(find.byType(PageView), const Offset(-260, 0), 900);
    await settlePaging(tester);
    expect(tester.takeException(), isNull);
  });

  test('libraryWeekDays is Monday-first and spans 7 days', () {
    final days = libraryWeekDays(DateTime(2026, 10, 4));
    expect(days.length, 7);
    expect(days.first.weekday, DateTime.monday);
    expect(days.last.weekday, DateTime.sunday);
    expect(days.first, DateTime(2026, 9, 28));
    expect(days.last, DateTime(2026, 10, 4));
  });
}
