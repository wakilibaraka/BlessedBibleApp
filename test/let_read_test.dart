// Year progress + shared verse-of-the-day helpers for the Plans header.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/let_read.dart';
import 'package:the_blessed_bible/data/models/home_data.dart';

void main() {
  group('YearProgress', () {
    test('non-leap year has 365 days', () {
      expect(YearProgress.daysInYear(2026), 365);
      expect(YearProgress.daysInYear(2025), 365);
      expect(YearProgress.daysInYear(1900), 365); // century, not leap
    });

    test('leap year has 366 days', () {
      expect(YearProgress.daysInYear(2024), 366);
      expect(YearProgress.daysInYear(2000), 366); // 400-rule
    });

    test('day-of-year is 1-based and correct at boundaries', () {
      expect(YearProgress.dayOfYear(DateTime(2026, 1, 1)), 1);
      expect(YearProgress.dayOfYear(DateTime(2026, 12, 31)), 365);
      expect(YearProgress.dayOfYear(DateTime(2024, 12, 31)), 366);
      expect(YearProgress.dayOfYear(DateTime(2026, 3, 1)), 60);
    });

    test('days remaining counts down to zero on Dec 31', () {
      expect(YearProgress.daysRemaining(DateTime(2026, 12, 31)), 0);
      expect(YearProgress.daysRemaining(DateTime(2026, 12, 30)), 1);
      expect(YearProgress.daysRemaining(DateTime(2026, 1, 1)), 364);
    });

    test('labels read "Day N of M" and the remaining phrase', () {
      expect(YearProgress.label(DateTime(2026, 10, 4)), 'Day 277 of 365');
      expect(YearProgress.label(DateTime(2024, 12, 31)), 'Day 366 of 366');
      expect(YearProgress.remainingLabel(DateTime(2026, 12, 31)),
          'Last day of the year');
      expect(YearProgress.remainingLabel(DateTime(2026, 12, 30)),
          '1 day left in the year');
      expect(YearProgress.remainingLabel(DateTime(2026, 10, 4)),
          '88 days left in the year');
    });

    test('leap-year days remaining stays non-negative', () {
      for (var d = 1; d <= 366; d++) {
        final day = DateTime(2024, 1, 1).add(Duration(days: d - 1));
        expect(YearProgress.daysRemaining(day), greaterThanOrEqualTo(0));
      }
    });
  });

  group('verseForDay', () {
    test('is stable for a given day', () {
      final pool = [
        VerseOfTheDay('A 1:1', 'a'),
        VerseOfTheDay('B 2:2', 'b'),
        VerseOfTheDay('C 3:3', 'c'),
      ];
      final d = DateTime(2026, 10, 4);
      expect(verseForDay(pool, d).reference, verseForDay(pool, d).reference);
    });

    test('cycles across consecutive days', () {
      final pool = [
        VerseOfTheDay('A 1:1', 'a'),
        VerseOfTheDay('B 2:2', 'b'),
      ];
      final a = verseForDay(pool, DateTime(2026, 1, 1));
      final b = verseForDay(pool, DateTime(2026, 1, 2));
      expect(a.reference == b.reference, isFalse);
      // Two days apart wraps back to the same entry (2-verse pool).
      final c = verseForDay(pool, DateTime(2026, 1, 3));
      expect(c.reference, a.reference);
    });

    test('empty pool falls back to a real verse, never blank', () {
      final v = verseForDay(<VerseOfTheDay>[], DateTime(2026, 10, 4));
      expect(v.text, isNotEmpty);
      expect(v.reference, isNotEmpty);
    });
  });
}

/// Small helper so the test reads clearly; VerseOfTheDay is not const.
class VerseOfDayStub {
  final String s;
  const VerseOfDayStub(this.s);
  VerseOfTheDay build() => VerseOfTheDay(s, s);
}