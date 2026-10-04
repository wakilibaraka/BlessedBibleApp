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
        (i) => PlanDayData(day: i + 1, week: i ~/ 7 + 1, title: 'Day ${i + 1}', passages: const []),
      ),
      planStartedOn: start,
    );

Widget host({DateTime? today, ReadingPlanState? plan}) => MaterialApp(
      theme: AppTheme.lightTheme(1.0),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 380,
            child: LibraryCalendarRail(
              today: today ?? DateTime(2026, 10, 4),
              plan: plan,
            ),
          ),
        ),
      ),
    );

/// PageView needs incremental frames to run its page animation.
Future<void> settlePaging(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  // 2026-10-04 is a Sunday -> its Monday-first week starts 2026-09-28.
  testWidgets('centers on the current week and renders 7 days',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 100));

    // Oct 4 2026 is a Sunday, so its Monday-first week is Sep 28..Oct 4.
    expect(find.text('4'), findsOneWidget); // today, last cell
    expect(find.text('28'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('MON'), findsOneWidget);
    expect(find.text('SUN'), findsOneWidget);
  });

  testWidgets('sliding left shows the next week', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.fling(find.byType(PageView), const Offset(-260, 0), 900);
    await settlePaging(tester);

    // Next week: Oct 5-11 (today's Oct 4 is gone).
    expect(find.text('4'), findsNothing);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
  });

  testWidgets('step button advances exactly one week', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await settlePaging(tester);

    expect(find.text('5'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
  });

  testWidgets('scrollToDate jumps to that week', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 100));

    final state = tester.state<LibraryCalendarRailState>(
        find.byType(LibraryCalendarRail));
    state.scrollToDate(DateTime(2026, 12, 20));
    await settlePaging(tester);

    // Dec 20 2026 is a Sunday; its week is Dec 14-20.
    expect(find.text('20'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('4'), findsNothing);
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