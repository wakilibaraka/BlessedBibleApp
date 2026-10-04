import '../../data/models/home_data.dart';
import '../../state/home_provider.dart';

/// Year-progress helpers for the Plans Library header.
///
/// Pure functions over a [DateTime] so they are trivially testable and
/// leap-year correct (Feb 29 shifts every later day-of-year by one).
class YearProgress {
  /// 365, or 366 in a leap year.
  static int daysInYear(int year) =>
      ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) ? 366 : 365;

  /// 1-based day of the year.
  static int dayOfYear(DateTime day) =>
      day.difference(DateTime(day.year)).inDays + 1;

  /// Whole days left in the year after [day] (0 on Dec 31).
  static int daysRemaining(DateTime day) =>
      daysInYear(day.year) - dayOfYear(day);

  /// "Day 277 of 365"
  static String label(DateTime day) =>
      'Day ${dayOfYear(day)} of ${daysInYear(day.year)}';

  /// "89 days left in the year" (or "Last day of the year").
  static String remainingLabel(DateTime day) {
    final left = daysRemaining(day);
    if (left == 0) return 'Last day of the year';
    return '$left day${left == 1 ? '' : 's'} left in the year';
  }
}

/// Picks today's verse from the shared VOTD pool (same day-index rule
/// as Home, so both surfaces always agree).
VerseOfTheDay verseForDay(List<VerseOfTheDay> pool, DateTime day) {
  if (pool.isEmpty) {
    return VerseOfTheDay(
      'Revelation 14:12',
      'Here is the patience of the saints: here are they that keep the '
      'commandments of God, and the faith of Jesus.',
    );
  }
  final start = DateTime(2026, 1, 1);
  final index = DateTime(day.year, day.month, day.day)
          .difference(start)
          .inDays
          .abs() %
      pool.length;
  return pool[index];
}