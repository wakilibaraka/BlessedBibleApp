// The daily verse and the calendar it walks on.
//
// A local day is 23 or 25 hours long across a daylight-saving change, so any
// count built from elapsed durations repeats one day and skips the next. These
// tests pin the calendar-day rule shared by Home, the Study card, the archive
// and the Plans header.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/let_read.dart';
import 'package:the_blessed_bible/data/models/home_data.dart';
import 'package:the_blessed_bible/utils/passage.dart';

VerseOfTheDay _verse(String reference) => VerseOfTheDay(reference, reference);

void main() {
  group('calendar days', () {
    test('consecutive dates are one day apart across DST changes', () {
      // EU transitions (last Sundays of March and October) and US ones.
      for (final start in [
        DateTime(2026, 3, 26),
        DateTime(2026, 10, 23),
        DateTime(2026, 3, 5),
        DateTime(2026, 10, 29),
      ]) {
        for (var i = 0; i < 8; i++) {
          final day = DateTime(start.year, start.month, start.day + i);
          final next = DateTime(start.year, start.month, start.day + i + 1);
          expect(
            votdDayNumber(next) - votdDayNumber(day),
            1,
            reason: '$next must directly follow $day',
          );
        }
      }
    });

    test('recentCalendarDays walks back at local midnight', () {
      final days = recentCalendarDays(DateTime(2026, 3, 30, 15, 42), 7);
      expect(days.length, 7);
      expect(days.first, DateTime(2026, 3, 30));
      expect(days.last, DateTime(2026, 3, 24));
      for (final day in days) {
        expect(day.hour, 0);
        expect(day.minute, 0);
      }
      for (var i = 0; i < days.length - 1; i++) {
        expect(days[i].day, isNot(days[i + 1].day));
      }
    });

    test('year progress counts calendar days through summer', () {
      expect(YearProgress.dayOfYear(DateTime(2026, 10, 4)), 277);
      expect(YearProgress.dayOfYear(DateTime(2026, 7, 4)), 185);
      expect(YearProgress.daysRemaining(DateTime(2026, 10, 4)), 88);
    });
  });

  group('votdIndexFor', () {
    test('advances one step per calendar day through a DST change', () {
      final days = recentCalendarDays(DateTime(2026, 10, 30), 10).reversed;
      final indices = days.map((day) => votdIndexFor(97, day)).toList();
      for (var i = 0; i < indices.length - 1; i++) {
        expect(indices[i + 1], (indices[i] + 1) % 97);
      }
    });

    test('a week of history never repeats a verse', () {
      final indices = recentCalendarDays(DateTime(2026, 10, 26), 7)
          .map((day) => votdIndexFor(1989, day))
          .toList();
      expect(indices.toSet().length, indices.length);
    });

    test('stays inside the pool for pre-epoch dates', () {
      for (final day in recentCalendarDays(DateTime(2025, 12, 31), 120)) {
        final index = votdIndexFor(5, day);
        expect(index, inInclusiveRange(0, 4));
        expect(votdIndexFor(0, day), 0);
      }
    });

    test('Plans and Home pick the same verse for a day', () {
      final pool = List.generate(5, (i) => _verse('Book ${i + 1}:1'));
      for (final day in recentCalendarDays(DateTime(2026, 1, 10), 40)) {
        expect(
          verseForDay(pool, day).reference,
          pool[votdIndexFor(pool.length, day)].reference,
        );
      }
    });
  });

  group('reference parsing for history cards', () {
    test('multi-word books keep their numbered name', () {
      final kings = PassageRef.parse('1 Kings 3:5')!;
      expect(kings.bookName, '1 Kings');
      expect(kings.chapter, 3);
      expect(kings.startVerse, 5);
      expect(PassageRef.parse('2 Chronicles 7:14')!.bookName, '2 Chronicles');
      expect(
          PassageRef.parse('Song of Solomon 2:1')!.bookName, 'Song of Solomon');
      expect(PassageRef.parse('John 3:16')!.bookName, 'John');
    });
  });
}
