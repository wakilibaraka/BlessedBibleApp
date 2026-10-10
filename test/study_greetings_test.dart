// Study greeting selection: grace > encouragement > time of day >
// daily rotation; deterministic per calendar day, stable all day.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/study_greetings.dart';

const _morning = {
  'Awake, O sleeper.',
  'Joy comes in the morning.',
  'This is the day the Lord has made.',
};
const _evening = {
  'The day is done.',
  'Under His wings.',
  'Come to Me, you who are weary.',
};
const _grace = {
  'Cast all your anxiety on Him.',
  'My peace I give you.',
  'He heals the brokenhearted.',
  'Nothing can separate us.',
};
const _cheer = {
  'Be strong and courageous.',
  'Run with endurance.',
  'Iron sharpens iron.',
};

StudyGreeting at(int y, int m, int d, int h,
        {int streak = 0, int distinct = 0}) =>
    greetingFor(
      now: DateTime(y, m, d, h),
      streakCount: streak,
      distinctDaysThisYear: distinct,
    );

void main() {
  test('fresh user at midday gets the shared daily rotation', () {
    final a = at(2026, 10, 4, 13);
    expect(at(2026, 10, 4, 13).title, a.title);
    // Consecutive days advance through the 12-pair pool.
    expect(at(2026, 10, 5, 13).title, isNot(a.title));
    // Midday is none of the special pools.
    expect(
        _morning.union(_evening).union(_grace).union(_cheer).contains(a.title),
        isFalse);
  });

  test('morning window is 5:00-11:59', () {
    expect(_morning, contains(at(2026, 10, 4, 5).title));
    expect(_morning, contains(at(2026, 10, 4, 11).title));
    // Noon leaves the morning pool.
    expect(_morning, isNot(contains(at(2026, 10, 4, 12).title)));
  });

  test('evening window is 18:00-4:59', () {
    expect(_evening, contains(at(2026, 10, 4, 18).title));
    expect(_evening, contains(at(2026, 10, 4, 23).title));
    expect(_evening, contains(at(2026, 10, 5, 0).title));
    expect(_evening, contains(at(2026, 10, 5, 4).title));
    expect(_morning, contains(at(2026, 10, 5, 5).title));
  });

  test('broken streak with history gets grace words', () {
    expect(_grace, contains(at(2026, 10, 4, 13, streak: 0, distinct: 5).title));
    // Grace overrides the morning pool too.
    expect(_grace, contains(at(2026, 10, 4, 8, streak: 0, distinct: 5).title));
  });

  test('restarted-today counts as a grace day', () {
    expect(_grace, contains(at(2026, 10, 4, 13, streak: 1, distinct: 6).title));
    // ...but a genuine day-one user does not get grace words.
    expect(_grace,
        isNot(contains(at(2026, 10, 4, 13, streak: 1, distinct: 1).title)));
  });

  test('streak of 3+ gets encouragement, overriding time of day', () {
    expect(_cheer, contains(at(2026, 10, 4, 8, streak: 5, distinct: 9).title));
    expect(_cheer, contains(at(2026, 10, 4, 20, streak: 3, distinct: 4).title));
  });

  test('all 25 titles unique', () {
    final seen = <String>{};
    // Sweep every pool across several days (small pools rotate).
    for (var d = 0; d < 12; d++) {
      seen.add(at(2026, 10, 4 + d, 13).title); // daily
      seen.add(at(2026, 10, 4 + d, 8).title); // morning
      seen.add(at(2026, 10, 4 + d, 21).title); // evening
      seen.add(at(2026, 10, 4 + d, 13, streak: 0, distinct: 9).title);
      seen.add(at(2026, 10, 4 + d, 13, streak: 9, distinct: 12).title);
    }
    expect(seen, hasLength(12 + 3 + 3 + 4 + 3));
  });

  test('eyebrow names weekday + daypart', () {
    // 2026-10-04 is a Sunday.
    expect(greetingEyebrow(DateTime(2026, 10, 4, 9)), 'Sunday morning');
    expect(greetingEyebrow(DateTime(2026, 10, 4, 14)), 'Sunday afternoon');
    expect(greetingEyebrow(DateTime(2026, 10, 4, 20)), 'Sunday evening');
    expect(greetingEyebrow(DateTime(2026, 10, 5, 2)), 'Monday night');
  });
}
