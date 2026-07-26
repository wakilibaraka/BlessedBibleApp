import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

class ChronologicalDay {
  final int day;
  final List<String> readings;

  ChronologicalDay({required this.day, required this.readings});

  factory ChronologicalDay.fromJson(Map<String, dynamic> json) {
    return ChronologicalDay(
      day: json['day'] as int,
      readings: List<String>.from(json['readings'] as List),
    );
  }
}

class ReadingPlanState {
  final bool isLoading;
  final List<ChronologicalDay> planData;
  final int currentDay; // 0 means not started
  final Set<int> completedDays;

  ReadingPlanState({
    this.isLoading = false,
    this.planData = const [],
    this.currentDay = 0,
    this.completedDays = const {},
  });

  bool get isPlanComplete => completedDays.contains(365);
  double get completionPercentage => planData.isEmpty ? 0 : completedDays.length / planData.length;

  ReadingPlanState copyWith({
    bool? isLoading,
    List<ChronologicalDay>? planData,
    int? currentDay,
    Set<int>? completedDays,
  }) {
    return ReadingPlanState(
      isLoading: isLoading ?? this.isLoading,
      planData: planData ?? this.planData,
      currentDay: currentDay ?? this.currentDay,
      completedDays: completedDays ?? this.completedDays,
    );
  }
}

class ReadingPlanNotifier extends Notifier<ReadingPlanState> {
  @override
  ReadingPlanState build() {
    _loadData();
    return ReadingPlanState(isLoading: true);
  }

  Future<void> _loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/chronological_plan.json');
      final List<dynamic> decoded = jsonDecode(jsonString);
      final planData = decoded.map((e) => ChronologicalDay.fromJson(e)).toList();

      final prefsState = ref.read(preferencesProvider).getReadingPlanState();
      int currentDay = 0;
      Set<int> completedDays = {};

      if (prefsState != null) {
        currentDay = prefsState['currentDay'] as int? ?? 0;
        completedDays = Set<int>.from(prefsState['completedDays'] ?? []);
      }

      state = state.copyWith(
        isLoading: false,
        planData: planData,
        currentDay: currentDay,
        completedDays: completedDays,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _saveState() {
    ref.read(preferencesProvider).saveReadingPlanState({
      'currentDay': state.currentDay,
      'completedDays': state.completedDays.toList(),
    });
  }

  void startPlan() {
    state = state.copyWith(currentDay: 1);
    _saveState();
  }

  void markDayComplete(int day) {
    final newCompleted = Set<int>.from(state.completedDays)..add(day);
    
    // Auto-advance if we are completing the current day and it's not the last day
    int nextDay = state.currentDay;
    if (day == state.currentDay && day < state.planData.length) {
      nextDay = day + 1;
      // Skip already completed days if possible
      while (newCompleted.contains(nextDay) && nextDay < state.planData.length) {
        nextDay++;
      }
    }

    state = state.copyWith(
      completedDays: newCompleted,
      currentDay: nextDay,
    );
    _saveState();
  }

  void markDayIncomplete(int day) {
    final newCompleted = Set<int>.from(state.completedDays)..remove(day);
    state = state.copyWith(completedDays: newCompleted);
    _saveState();
  }

  void jumpToDay(int day) {
    state = state.copyWith(currentDay: day);
    _saveState();
  }
}

final readingPlanProvider = NotifierProvider<ReadingPlanNotifier, ReadingPlanState>(ReadingPlanNotifier.new);
