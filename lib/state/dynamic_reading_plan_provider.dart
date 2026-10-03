import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bible_provider.dart';

class DynamicReadingPlan {
  final int totalDays;
  final int currentDay;
  final List<List<FlatChapter>> dailyChunks;
  final bool isCompleted;

  DynamicReadingPlan({
    required this.totalDays,
    required this.currentDay,
    required this.dailyChunks,
    required this.isCompleted,
  });

  DynamicReadingPlan copyWith({
    int? totalDays,
    int? currentDay,
    List<List<FlatChapter>>? dailyChunks,
    bool? isCompleted,
  }) {
    return DynamicReadingPlan(
      totalDays: totalDays ?? this.totalDays,
      currentDay: currentDay ?? this.currentDay,
      dailyChunks: dailyChunks ?? this.dailyChunks,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class DynamicReadingPlanNotifier extends Notifier<DynamicReadingPlan?> {
  static const _totalDaysKey = 'dynamic_plan_total_days';
  static const _currentDayKey = 'dynamic_plan_current_day';

  @override
  DynamicReadingPlan? build() {
    final chapters = ref.watch(flatChaptersProvider);
    _loadPlan(chapters);
    return null;
  }

  Future<void> _loadPlan(List<FlatChapter> chapters) async {
    final prefs = await SharedPreferences.getInstance();
    final totalDays = prefs.getInt(_totalDaysKey);
    final currentDay = prefs.getInt(_currentDayKey) ?? 1;

    if (totalDays == null || totalDays <= 0 || chapters.isEmpty) {
      // Don't set state if chapters aren't loaded yet
      return;
    }

    state = _generatePlan(totalDays, currentDay, chapters);
  }

  DynamicReadingPlan _generatePlan(int totalDays, int currentDay, List<FlatChapter> chapters) {
    final chunks = <List<FlatChapter>>[];
    final double chaptersPerDay = chapters.length / totalDays;
    
    int currentIndex = 0;
    for (int i = 0; i < totalDays; i++) {
      int endIdx = ((i + 1) * chaptersPerDay).round();
      if (endIdx > chapters.length) endIdx = chapters.length;
      if (i == totalDays - 1) endIdx = chapters.length;
      
      if (currentIndex < endIdx) {
        chunks.add(chapters.sublist(currentIndex, endIdx));
      } else {
        chunks.add([]);
      }
      currentIndex = endIdx;
    }

    return DynamicReadingPlan(
      totalDays: totalDays,
      currentDay: currentDay,
      dailyChunks: chunks,
      isCompleted: currentDay > totalDays,
    );
  }

  Future<void> startNewPlan(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalDaysKey, days);
    await prefs.setInt(_currentDayKey, 1);
    
    final chapters = ref.read(flatChaptersProvider);
    if (chapters.isNotEmpty) {
      state = _generatePlan(days, 1, chapters);
    }
  }

  Future<void> completeDay() async {
    if (state == null || state!.isCompleted) return;

    final nextDay = state!.currentDay + 1;
    final isCompleted = nextDay > state!.totalDays;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentDayKey, nextDay);

    state = state!.copyWith(
      currentDay: nextDay,
      isCompleted: isCompleted,
    );
  }

  Future<void> clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_totalDaysKey);
    await prefs.remove(_currentDayKey);
    state = null;
  }
}

final dynamicReadingPlanProvider =
    NotifierProvider<DynamicReadingPlanNotifier, DynamicReadingPlan?>(
        DynamicReadingPlanNotifier.new);
