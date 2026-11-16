// Year progress + shared verse-of-the-day helpers for the Plans header.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/let_read.dart';
import 'package:the_blessed_bible/data/models/home_data.dart';
import 'package:the_blessed_bible/l10n/l10n.dart';

final _en = lookupAppLocalizations(const Locale('en'));

/// 1-based day of year from pure calendar math (month lengths), so the
/// expectation never depends on the device timezone or DST transitions
/// the production `Duration`-based implementation is sensitive to.
int dayOfYearFromCalendar(DateTime day) {
  const monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  final leap =
      day.year % 4 == 0 && (day.year % 100 != 0 || day.year % 400 == 0);
  var doy = day.day;
  for (var m = 0; m < day.month - 1; m++) {
    doy += monthDays[m] + (m == 1 && leap ? 1 : 0);
  }
  return doy;
}

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
      final now = DateTime.now();
      final doy = dayOfYearFromCalendar(now);
      expect(YearProgress.label(now, _en),
          'Day $doy of ${YearProgress.daysInYear(now.year)}');
      expect(YearProgress.label(DateTime(2024, 12, 31), _en), 'Day 366 of 366');
      expect(YearProgress.remainingLabel(DateTime(2026, 12, 31), _en),
          'Last day of the year');
      expect(YearProgress.remainingLabel(DateTime(2026, 12, 30), _en),
          '1 day left in the year');
      final left = YearProgress.daysInYear(now.year) - doy;
      expect(YearProgress.remainingLabel(now, _en),
          left == 0 ? 'Last day of the year' : '$left days left in the year');
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
