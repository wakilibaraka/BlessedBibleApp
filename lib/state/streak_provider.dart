import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

class StreakState {
  final int count;
  final bool readToday;

  const StreakState({required this.count, required this.readToday});
}

class StreakNotifier extends Notifier<StreakState> {
  @override
  StreakState build() {
    final prefs = ref.watch(preferencesProvider);
    final count = prefs.getStreakCount();
    final lastRead = prefs.getLastReadDate();
    
    final today = _formatDate(DateTime.now());
    final yesterday = _formatDate(DateTime.now().subtract(const Duration(days: 1)));
    
    if (lastRead == null) {
      return const StreakState(count: 0, readToday: false);
    }
    
    if (lastRead == today) {
      return StreakState(count: count, readToday: true);
    } else if (lastRead == yesterday) {
      return StreakState(count: count, readToday: false);
    } else {
      // Streak broken, wait for user to read today to start at 1
      return const StreakState(count: 0, readToday: false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void markReadToday() {
    if (state.readToday) return;

    final prefs = ref.read(preferencesProvider);
    final lastRead = prefs.getLastReadDate();
    final today = _formatDate(DateTime.now());
    final yesterday = _formatDate(DateTime.now().subtract(const Duration(days: 1)));
    
    int newCount = state.count;
    if (lastRead == yesterday) {
      newCount += 1;
    } else if (lastRead != today) {
      newCount = 1; // Broken streak or first time
    }

    prefs.saveLastReadDate(today);
    prefs.saveStreakCount(newCount);
    
    state = StreakState(count: newCount, readToday: true);
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakState>(() {
  return StreakNotifier();
});
