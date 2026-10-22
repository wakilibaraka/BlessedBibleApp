// planTarget decides what every Read button in the plan flow opens
// (Study widget, Plans hero, Plan page), so the three always agree.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/state/reading_plan_provider.dart';
import 'package:the_blessed_bible/ui/widgets/plan_flow.dart';

void main() {
  final days = [
    for (var d = 1; d <= 10; d++)
      PlanDayData(
        day: d,
        week: 1,
        title: 'Day $d',
        passages: [
          PlanPassage(label: 'Genesis $d', refs: ['Genesis $d'])
        ],
      ),
  ];
  DateTime daysAgo(int n) => DateTime.now().subtract(Duration(days: n));

  ReadingPlanState plan({
    required DateTime start,
    Set<int> done = const {},
    String pace = 'scheduled',
  }) =>
      ReadingPlanState(
        planId: 'p',
        planStartedOn: start,
        paceMode: pace,
        completedReadings: done,
        planData: days,
      );

  test('on track: today', () {
    final t = planTarget(plan(start: daysAgo(2), done: {1, 2}));
    expect(t.kind, PlanTargetKind.today);
    expect(t.day, 3);
  });

  test('behind: oldest missed day', () {
    final t = planTarget(plan(start: daysAgo(4), done: {1, 3}));
    expect(t.kind, PlanTargetKind.catchUp);
    expect(t.day, 2);
  });

  test('today done: next unread day to read ahead', () {
    final t = planTarget(plan(start: daysAgo(1), done: {1, 2, 3}));
    expect(t.kind, PlanTargetKind.doneToday);
    expect(t.day, 4);
  });

  test('flexible never reports catch-up', () {
    final t =
        planTarget(plan(start: daysAgo(6), done: {1, 2}, pace: 'flexible'));
    expect(t.kind, PlanTargetKind.today);
    expect(t.day, 3);
  });

  test('every day done: complete', () {
    final t = planTarget(
        plan(start: daysAgo(3), done: {for (var d = 1; d <= 10; d++) d}));
    expect(t.kind, PlanTargetKind.complete);
  });

  test('day label joins passages', () {
    expect(planDayLabel(plan(start: daysAgo(0)), 4), 'Genesis 4');
    expect(planDayLabel(plan(start: daysAgo(0)), 40), '');
  });
}
