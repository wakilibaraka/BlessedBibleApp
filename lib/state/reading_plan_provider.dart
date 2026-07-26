import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import '../services/notification_service.dart';
enum PlanStartMode { startToday, calendarYear }

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
  final DateTime startDate;
  final PlanStartMode startMode;

  ReadingPlanState({
    this.isLoading = false,
    this.planData = const [],
    this.currentDay = 0,
    this.completedDays = const {},
    required this.startDate,
    this.startMode = PlanStartMode.startToday,
  });

  bool get isPlanComplete => completedDays.contains(365);
  double get completionPercentage => planData.isEmpty ? 0 : completedDays.length / planData.length;

  DateTime getDateForDay(int day) {
    if (startMode == PlanStartMode.calendarYear) {
      final now = DateTime.now();
      return DateTime(now.year, 1, 1).add(Duration(days: day - 1));
    } else {
      // For startToday, startDate maps to day 1
      return startDate.add(Duration(days: day - 1));
    }
  }

  String getFormattedDateForDay(int day) {
    final date = getDateForDay(day);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  ReadingPlanState copyWith({
    bool? isLoading,
    List<ChronologicalDay>? planData,
    int? currentDay,
    Set<int>? completedDays,
    DateTime? startDate,
    PlanStartMode? startMode,
  }) {
    return ReadingPlanState(
      isLoading: isLoading ?? this.isLoading,
      planData: planData ?? this.planData,
      currentDay: currentDay ?? this.currentDay,
      completedDays: completedDays ?? this.completedDays,
      startDate: startDate ?? this.startDate,
      startMode: startMode ?? this.startMode,
    );
  }
}

class ReadingPlanNotifier extends Notifier<ReadingPlanState> {
  @override
  ReadingPlanState build() {
    // Initial sync state before async load
    _loadData();
    return ReadingPlanState(isLoading: true, startDate: DateTime.now());
  }

  Future<void> _loadData() async {
    // We defer loading to allow constructor to return. This is called manually or via FutureProvider ideally, 
    // but riverpod Notifier can just call this from build. Wait, since it's an async method called from build without await, 
    // we need to be careful. The user already tested it and it worked.
    try {
      final jsonString = await rootBundle.loadString('assets/data/chronological_plan.json');
      final List<dynamic> decoded = jsonDecode(jsonString);
      final planData = decoded.map((e) => ChronologicalDay.fromJson(e)).toList();

      final prefsState = ref.read(preferencesProvider).getReadingPlanState();
      int currentDay = 0;
      Set<int> completedDays = {};
      DateTime startDate = DateTime.now();
      PlanStartMode startMode = PlanStartMode.startToday;

      if (prefsState != null) {
        currentDay = prefsState['currentDay'] as int? ?? 0;
        completedDays = Set<int>.from(prefsState['completedDays'] ?? []);
        if (prefsState['startDate'] != null) {
          startDate = DateTime.parse(prefsState['startDate'] as String);
        }
        if (prefsState['startMode'] == 'calendarYear') {
          startMode = PlanStartMode.calendarYear;
        }
      }

      state = state.copyWith(
        isLoading: false,
        planData: planData,
        currentDay: currentDay,
        completedDays: completedDays,
        startDate: startDate,
        startMode: startMode,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _saveState() {
    ref.read(preferencesProvider).saveReadingPlanState({
      'currentDay': state.currentDay,
      'completedDays': state.completedDays.toList(),
      'startDate': state.startDate.toIso8601String(),
      'startMode': state.startMode.name,
    });
  }

  void startPlan() {
    int day = 1;
    if (state.startMode == PlanStartMode.calendarYear) {
      final now = DateTime.now();
      day = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    }
    state = state.copyWith(currentDay: day, startDate: DateTime.now());
    _saveState();
    
    // Schedule daily notification
    ref.read(notificationServiceProvider).scheduleDailyReminder();
  }

  void changeStartMode(PlanStartMode mode) {
    int newCurrentDay = state.currentDay;
    if (state.currentDay == 0 || state.completedDays.isEmpty) {
      if (mode == PlanStartMode.calendarYear) {
        final now = DateTime.now();
        newCurrentDay = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      } else {
        newCurrentDay = state.currentDay == 0 ? 0 : 1;
      }
    }
    state = state.copyWith(startMode: mode, startDate: DateTime.now(), currentDay: newCurrentDay);
    _saveState();
  }

  bool jumpToBook(String bookQuery) {
    final query = bookQuery.trim().toLowerCase();
    
    // As per instruction: "It finds the FIRST plan day where that book appears in the chronological sequence"
    for (int i = 0; i < state.planData.length; i++) {
      final day = state.planData[i];
      for (final reading in day.readings) {
        final match = RegExp(r'^(\d?\s*[a-zA-Z\s]+)(?:\s+(\d+))?').firstMatch(reading);
        if (match != null) {
          String bookName = match.group(1)!.trim().toLowerCase();
          if (bookName == 'song of solomon') bookName = 'song of solomon'; // normalize
          
          if (bookName == query || bookName.contains(query) || query.contains(bookName)) {
            jumpToDay(day.day);
            return true;
          }
        }
      }
    }
    return false;
  }

  void markDayComplete(int day) {
    final newCompleted = Set<int>.from(state.completedDays)..add(day);
    
    int nextDay = state.currentDay;
    if (day == state.currentDay && day < state.planData.length) {
      nextDay = day + 1;
      while (newCompleted.contains(nextDay) && nextDay < state.planData.length) {
        nextDay++;
      }
    }

    state = state.copyWith(
      completedDays: newCompleted,
      currentDay: nextDay,
    );
    _saveState();

    if (state.isPlanComplete) {
      ref.read(notificationServiceProvider).cancelReminder();
    }
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
