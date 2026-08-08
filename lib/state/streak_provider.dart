import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

class StreakState {
  final int consecutiveDays;
  final int distinctDaysThisYear;

  int get count => consecutiveDays;
  bool get readToday => false; // Dummy, we can derive this if needed or just return false

  const StreakState({
    required this.consecutiveDays,
    required this.distinctDaysThisYear,
  });
}

class StreakNotifier extends Notifier<StreakState> {
  @override
  StreakState build() {
    final prefs = ref.watch(preferencesProvider);
    final usageDates = prefs.getAppUsageDates();
    
    return _calculateState(usageDates);
  }

  StreakState _calculateState(List<String> dates) {
    if (dates.isEmpty) {
      return const StreakState(consecutiveDays: 0, distinctDaysThisYear: 0);
    }

    final now = DateTime.now();
    final currentYear = now.year.toString();

    // Calculate distinct days this year
    int daysThisYear = 0;
    for (final date in dates) {
      if (date.startsWith(currentYear)) {
        daysThisYear++;
      }
    }

    // Calculate consecutive days
    final sortedDates = dates.map((d) => DateTime.parse(d)).toList()
      ..sort((a, b) => b.compareTo(a));

    int consecutive = 0;
    DateTime dateToCheck = DateTime(now.year, now.month, now.day);
    
    // Check if today is in the list, if not, maybe yesterday is (streak not broken yet)
    if (sortedDates.isNotEmpty) {
      final latest = sortedDates.first;
      if (latest.year == dateToCheck.year && latest.month == dateToCheck.month && latest.day == dateToCheck.day) {
        // Today is included
      } else {
        final yesterday = dateToCheck.subtract(const Duration(days: 1));
        if (latest.year == yesterday.year && latest.month == yesterday.month && latest.day == yesterday.day) {
          // Started checking from yesterday, streak is maintained but not incremented today yet
          dateToCheck = yesterday;
        } else {
          // Latest is older than yesterday, streak is broken
          return StreakState(consecutiveDays: 0, distinctDaysThisYear: daysThisYear);
        }
      }
    }

    // Walk backward to count consecutive days
    for (final date in sortedDates) {
      if (date.year == dateToCheck.year && date.month == dateToCheck.month && date.day == dateToCheck.day) {
        consecutive++;
        dateToCheck = dateToCheck.subtract(const Duration(days: 1));
      } else {
        // Since we sort descending, if it doesn't match the expected previous day, we break.
        // But wait, there might be duplicate dates or we might just skip over it if it's not contiguous.
        // Actually, since it's a set of distinct dates, if it doesn't match dateToCheck, the streak ends.
        break;
      }
    }

    return StreakState(
      consecutiveDays: consecutive,
      distinctDaysThisYear: daysThisYear,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void markAppOpenedToday() {
    final prefs = ref.read(preferencesProvider);
    final usageDates = prefs.getAppUsageDates();
    final today = _formatDate(DateTime.now());

    if (!usageDates.contains(today)) {
      final updatedDates = List<String>.from(usageDates)..add(today);
      prefs.saveAppUsageDates(updatedDates);
      state = _calculateState(updatedDates);
    }
  }

  // Keep this for backwards compatibility if needed by other parts of the app for now,
  // though we are moving to app-usage streak for the home screen.
  void markReadToday() {
    // We can also trigger app opened here just in case.
    markAppOpenedToday();
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakState>(() {
  return StreakNotifier();
});
