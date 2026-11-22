import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

/// Consecutive-day counters for the Home card.
///
/// These count *app-use* days (the day the app was opened), not completed
/// readings; plan-level reading streaks live on `ReadingPlanState`.
class StreakState {
  final int consecutiveDays;
  final int distinctDaysThisYear;

  /// Whether the app has been opened today.
  final bool openedToday;

  int get count => consecutiveDays;
  bool get readToday => openedToday;

  const StreakState({
    required this.consecutiveDays,
    required this.distinctDaysThisYear,
    this.openedToday = false,
  });
}

class StreakNotifier extends Notifier<StreakState> {
  @override
  StreakState build() {
    final prefs = ref.watch(preferencesProvider);
    return calculateStreak(prefs.getAppUsageDates());
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Counts the streak from [rawDates] (`yyyy-MM-dd`), optionally at a fixed
  /// [now] for tests.
  ///
  /// Dates are walked by calendar day (`day - 1`) rather than by subtracting
  /// a 24-hour duration: across a DST shift the latter lands at 23:00 the
  /// previous day and the streak read as broken. Duplicates, out-of-order
  /// entries and unparseable strings are tolerated.
  static StreakState calculateStreak(List<String> rawDates, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final byDay = <String, DateTime>{};
    for (final raw in rawDates) {
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) continue;
      byDay[_key(_dateOnly(parsed))] = _dateOnly(parsed);
    }

    final daysThisYear = byDay.values.where((d) => d.year == today.year).length;
    if (byDay.isEmpty) {
      return StreakState(consecutiveDays: 0, distinctDaysThisYear: 0);
    }

    final openedToday = byDay.containsKey(_key(today));
    // Yesterday still counts: the streak only breaks once a whole day passes
    // with no activity.
    var cursor =
        openedToday ? today : DateTime(today.year, today.month, today.day - 1);
    if (!byDay.containsKey(_key(cursor))) {
      return StreakState(
        consecutiveDays: 0,
        distinctDaysThisYear: daysThisYear,
        openedToday: openedToday,
      );
    }

    var consecutive = 0;
    while (byDay.containsKey(_key(cursor))) {
      consecutive++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    return StreakState(
      consecutiveDays: consecutive,
      distinctDaysThisYear: daysThisYear,
      openedToday: openedToday,
    );
  }

  void markAppOpenedToday() {
    final prefs = ref.read(preferencesProvider);
    final usageDates = prefs.getAppUsageDates();
    final today = _key(_dateOnly(DateTime.now()));

    if (!usageDates.contains(today)) {
      final updatedDates = List<String>.from(usageDates)..add(today);
      prefs.saveAppUsageDates(updatedDates);
      state = calculateStreak(updatedDates);
    }
  }

  // Kept for call sites that mark a completed reading as activity; recorded
  // days stay app-use days, which is what the Home streak displays.
  void markReadToday() {
    markAppOpenedToday();
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakState>(() {
  return StreakNotifier();
});
