// Streak maths: consecutive calendar days, tolerant of duplicates, order,
// junk strings, and a missing "today" (a streak breaks at the end of a day,
// not at the start of the next one).

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/state/streak_provider.dart';

void main() {
  final now = DateTime(2026, 11, 21);
  StreakState calc(List<String> dates, {DateTime? at}) =>
      StreakNotifier.calculateStreak(dates, now: at ?? now);

  test('no activity has no streak', () {
    final s = calc(const []);
    expect(s.consecutiveDays, 0);
    expect(s.openedToday, isFalse);
    expect(s.readToday, isFalse);
  });

  test('today alone is a one-day streak', () {
    final s = calc(['2026-11-21']);
    expect(s.consecutiveDays, 1);
    expect(s.openedToday, isTrue);
  });

  test('consecutive days ending today count', () {
    expect(calc(['2026-11-19', '2026-11-20', '2026-11-21']).consecutiveDays, 3);
  });

  test('today not opened yet keeps yesterday streak alive', () {
    final s = calc(['2026-11-19', '2026-11-20']);
    expect(s.consecutiveDays, 2);
    expect(s.openedToday, isFalse);
  });

  test('a missed day ends the streak', () {
    expect(calc(['2026-11-18', '2026-11-21']).consecutiveDays, 1);
    expect(calc(['2026-11-17', '2026-11-18']).consecutiveDays, 0);
  });

  test('duplicates, order and junk do not distort the count', () {
    final s = calc([
      '2026-11-21',
      '2026-11-20',
      '2026-11-21', // duplicate
      'not-a-date',
      '2026-11-19',
    ]);
    expect(s.consecutiveDays, 3);
    expect(s.distinctDaysThisYear, 3);
  });

  test('distinct days this year ignores other years', () {
    final s = calc(['2025-12-31', '2026-11-21', '2026-11-20']);
    expect(s.distinctDaysThisYear, 2);
  });

  test('a DST boundary does not skip or repeat a day', () {
    // In a zone that springs forward on 2026-03-29, subtracting a 24h
    // duration from midnight lands on 23:00 the previous day; walking by
    // calendar day keeps the streak intact.
    final s = calc(['2026-03-28', '2026-03-29', '2026-03-30'],
        at: DateTime(2026, 3, 30));
    expect(s.consecutiveDays, 3);
  });
}
