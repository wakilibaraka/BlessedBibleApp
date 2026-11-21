import '../../data/models/home_data.dart';
import '../l10n/l10n.dart';

/// Day counts come from civil dates, never from elapsed 24-hour spans: a local
/// day is 23 or 25 hours long across a daylight-saving change, and
/// `difference(...).inDays` truncates those, which repeats one day's verse and
/// skips the next. Normalising to UTC midnight keeps every calendar day
/// exactly one apart in every time zone.
int calendarDayNumber(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// The day the daily-verse cycle counts from (2026-01-01).
final int _votdEpochDay = calendarDayNumber(DateTime(2026, 1, 1));

/// Whole calendar days from the cycle's epoch; negative before it.
int votdDayNumber(DateTime day) => calendarDayNumber(day) - _votdEpochDay;

/// Index of [day]'s verse in a pool of [poolLength], always in range.
int votdIndexFor(int poolLength, DateTime day) {
  if (poolLength <= 0) return 0;
  final index = votdDayNumber(day) % poolLength;
  return index < 0 ? index + poolLength : index;
}

/// [count] local-midnight days starting at [today] and walking back, so
/// history rows line up with the day the verse was actually shown.
List<DateTime> recentCalendarDays(DateTime today, int count) => List.generate(
    count, (index) => DateTime(today.year, today.month, today.day - index));

/// Year-progress helpers for the Plans Library header.
///
/// Pure functions over a [DateTime] so they are trivially testable and
/// leap-year correct (Feb 29 shifts every later day-of-year by one).
class YearProgress {
  /// 365, or 366 in a leap year.
  static int daysInYear(int year) =>
      ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) ? 366 : 365;

  /// 1-based day of the year, counted in calendar days.
  static int dayOfYear(DateTime day) =>
      calendarDayNumber(day) - calendarDayNumber(DateTime(day.year)) + 1;

  /// Whole days left in the year after [day] (0 on Dec 31).
  static int daysRemaining(DateTime day) =>
      daysInYear(day.year) - dayOfYear(day);

  /// "Day 277 of 365"
  static String label(DateTime day, AppLocalizations l10n) =>
      l10n.plansDayOfTotal(dayOfYear(day), daysInYear(day.year));

  /// "89 days left in the year" (or "Last day of the year").
  static String remainingLabel(DateTime day, AppLocalizations l10n) {
    final left = daysRemaining(day);
    if (left == 0) return l10n.plansLastDayOfYear;
    return l10n.plansDaysLeftInYear(left);
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
  return pool[votdIndexFor(pool.length, day)];
}
