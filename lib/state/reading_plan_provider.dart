import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import '../services/notification_service.dart';
enum PlanStartMode { startToday, calendarYear }

class PlanChapter {
  final String bookName;
  final int chapterNum;

  PlanChapter({required this.bookName, required this.chapterNum});

  String get id => '${bookName}_$chapterNum';
}

List<PlanChapter> _expandReadings(List<String> readings) {
  List<PlanChapter> result = [];
  for (String reading in readings) {
    final match = RegExp(r'^(\d?\s*[a-zA-Z\s]+)(?:\s+([\d,\-\s;]+))?').firstMatch(reading);
    if (match != null) {
      String bookName = match.group(1)!.trim();
      if (bookName.toLowerCase() == 'song of solomon') bookName = 'Song of Solomon';
      
      String? chaptersStr = match.group(2);
      if (chaptersStr == null || chaptersStr.isEmpty) {
        result.add(PlanChapter(bookName: bookName, chapterNum: 1));
      } else {
        final parts = chaptersStr.split(RegExp(r'[,;]'));
        for (var part in parts) {
          part = part.trim();
          if (part.isEmpty) continue;
          if (part.contains('-')) {
            final rangeParts = part.split('-');
            int start = int.tryParse(rangeParts[0]) ?? 1;
            int end = int.tryParse(rangeParts[1]) ?? 1;
            for (int i = start; i <= end; i++) {
              result.add(PlanChapter(bookName: bookName, chapterNum: i));
            }
          } else {
            int num = int.tryParse(part) ?? 1;
            result.add(PlanChapter(bookName: bookName, chapterNum: num));
          }
        }
      }
    }
  }
  return result;
}

class ChronologicalDay {
  final int day;
  final List<String> readings;
  final List<PlanChapter> chapters;

  ChronologicalDay({required this.day, required this.readings, required this.chapters});

  factory ChronologicalDay.fromJson(Map<String, dynamic> json) {
    final rawReadings = List<String>.from(json['readings'] as List);
    return ChronologicalDay(
      day: json['day'] as int,
      readings: rawReadings,
      chapters: _expandReadings(rawReadings),
    );
  }
}

class ReadingPlanState {
  final bool isLoading;
  final List<ChronologicalDay> planData;
  final int currentDay; // 0 means not started
  final Set<String> completedChapters;
  final DateTime startDate;
  final PlanStartMode startMode;
  final bool reminderEnabled;
  final int reminderTimeHour;
  final int reminderTimeMinute;

  ReadingPlanState({
    this.isLoading = false,
    this.planData = const [],
    this.currentDay = 0,
    this.completedChapters = const {},
    required this.startDate,
    this.startMode = PlanStartMode.startToday,
    this.reminderEnabled = false,
    this.reminderTimeHour = 8,
    this.reminderTimeMinute = 0,
  });

  bool get isPlanComplete => planData.isNotEmpty && completedChapters.length >= planData.fold(0, (sum, d) => sum + d.chapters.length);
  
  double get completionPercentage => planData.isEmpty ? 0 : completedChapters.length / planData.fold(0, (sum, d) => sum + d.chapters.length);

  bool isDayComplete(int day) {
    if (planData.isEmpty || day < 1 || day > planData.length) return false;
    final target = planData[day - 1];
    return target.chapters.every((c) => completedChapters.contains(c.id));
  }

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
    Set<String>? completedChapters,
    DateTime? startDate,
    PlanStartMode? startMode,
    bool? reminderEnabled,
    int? reminderTimeHour,
    int? reminderTimeMinute,
  }) {
    return ReadingPlanState(
      isLoading: isLoading ?? this.isLoading,
      planData: planData ?? this.planData,
      currentDay: currentDay ?? this.currentDay,
      completedChapters: completedChapters ?? this.completedChapters,
      startDate: startDate ?? this.startDate,
      startMode: startMode ?? this.startMode,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
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
      // Parse on a background isolate — this JSON is ~27KB with complex per-day expansion
      final List<dynamic> decoded = await compute<String, List<dynamic>>(
        (s) => jsonDecode(s) as List<dynamic>,
        jsonString,
      );
      final planData = decoded.map((e) => ChronologicalDay.fromJson(e)).toList();

      final prefsState = ref.read(preferencesProvider).getReadingPlanState();
      int currentDay = 0;
      Set<String> completedChapters = {};
      DateTime startDate = DateTime.now();
      PlanStartMode startMode = PlanStartMode.startToday;
      bool reminderEnabled = false;
      int reminderTimeHour = 8;
      int reminderTimeMinute = 0;

      if (prefsState != null) {
        currentDay = prefsState['currentDay'] as int? ?? 0;
        
        if (prefsState.containsKey('completedChapters')) {
          final chaptersList = prefsState['completedChapters'] as List;
          completedChapters = chaptersList.map((e) => e.toString()).toSet();
        } else if (prefsState.containsKey('completedDays')) {
          // Migration!
          final completedDays = Set<int>.from(prefsState['completedDays']);
          for (final d in completedDays) {
            if (d >= 1 && d <= planData.length) {
              for (final c in planData[d - 1].chapters) {
                completedChapters.add(c.id);
              }
            }
          }
        }
        if (prefsState['startDate'] != null) {
          startDate = DateTime.parse(prefsState['startDate'] as String);
        }
        if (prefsState['startMode'] == 'calendarYear') {
          startMode = PlanStartMode.calendarYear;
        }
        reminderEnabled = prefsState['reminderEnabled'] as bool? ?? false;
        reminderTimeHour = prefsState['reminderTimeHour'] as int? ?? 8;
        reminderTimeMinute = prefsState['reminderTimeMinute'] as int? ?? 0;
      }

      state = state.copyWith(
        isLoading: false,
        planData: planData,
        currentDay: currentDay,
        completedChapters: completedChapters,
        startDate: startDate,
        startMode: startMode,
        reminderEnabled: reminderEnabled,
        reminderTimeHour: reminderTimeHour,
        reminderTimeMinute: reminderTimeMinute,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _saveState() {
    ref.read(preferencesProvider).saveReadingPlanState({
      'currentDay': state.currentDay,
      'completedChapters': state.completedChapters.toList(),
      'startDate': state.startDate.toIso8601String(),
      'startMode': state.startMode.name,
      'reminderEnabled': state.reminderEnabled,
      'reminderTimeHour': state.reminderTimeHour,
      'reminderTimeMinute': state.reminderTimeMinute,
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
    if (state.reminderEnabled) {
      ref.read(notificationServiceProvider).scheduleDailyReminder(state.reminderTimeHour, state.reminderTimeMinute);
    }
  }

  void restartPlan() {
    int day = 1;
    if (state.startMode == PlanStartMode.calendarYear) {
      final now = DateTime.now();
      day = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    }
    state = state.copyWith(
      currentDay: day, 
      startDate: DateTime.now(),
      completedChapters: {},
    );
    _saveState();
    if (state.reminderEnabled) {
      ref.read(notificationServiceProvider).scheduleDailyReminder(state.reminderTimeHour, state.reminderTimeMinute);
    }
  }

  void setReminder(bool enabled, int hour, int minute) {
    state = state.copyWith(
      reminderEnabled: enabled,
      reminderTimeHour: hour,
      reminderTimeMinute: minute,
    );
    _saveState();
    if (enabled) {
      ref.read(notificationServiceProvider).scheduleDailyReminder(hour, minute);
    } else {
      ref.read(notificationServiceProvider).cancelReminder();
    }
  }

  void changeStartMode(PlanStartMode mode) {
    int newCurrentDay = state.currentDay;
    if (state.currentDay == 0 || state.completedChapters.isEmpty) {
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

  void startPlanFromDay(int day) {
    final newCompleted = Set<String>.from(state.completedChapters);
    for (int i = 1; i < day; i++) {
      for (final c in state.planData[i - 1].chapters) {
        newCompleted.add(c.id);
      }
    }
    
    DateTime newStartDate = state.startDate;
    if (state.startMode == PlanStartMode.startToday) {
      // Backdate the start date so that 'day' lands exactly on today.
      final now = DateTime.now();
      newStartDate = now.subtract(Duration(days: day - 1));
    }

    state = state.copyWith(
      currentDay: day,
      completedChapters: newCompleted,
      startDate: newStartDate,
    );
    _saveState();
    if (state.reminderEnabled) {
      ref.read(notificationServiceProvider).scheduleDailyReminder(state.reminderTimeHour, state.reminderTimeMinute);
    }
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

  int? findDayForPassage(String targetBook, int targetChapter) {
    final tBook = targetBook.toLowerCase();
    for (int i = 0; i < state.planData.length; i++) {
      final day = state.planData[i];
      for (final reading in day.readings) {
        final match = RegExp(r'^(\d?\s*[a-zA-Z\s]+)(?:\s+([\d,\-\s;a-zA-Z]+))?').firstMatch(reading);
        if (match != null) {
          String bName = match.group(1)!.trim().toLowerCase();
          if (bName == 'song of solomon') bName = 'song of solomon';
          
          if (bName == tBook || bName.contains(tBook) || tBook.contains(bName)) {
            final chaptersStr = match.group(2);
            if (chaptersStr == null || chaptersStr.isEmpty) return day.day;
            
            final chapterRegex = RegExp(r'\b' + targetChapter.toString() + r'\b');
            if (chapterRegex.hasMatch(chaptersStr)) return day.day;
            
            final rangeMatches = RegExp(r'(\d+)\s*-\s*(\d+)').allMatches(chaptersStr);
            for (final rm in rangeMatches) {
               final start = int.tryParse(rm.group(1)!) ?? 0;
               final end = int.tryParse(rm.group(2)!) ?? 0;
               if (targetChapter >= start && targetChapter <= end) return day.day;
            }
          }
        }
      }
    }
    return null;
  }

  void markDayComplete(int day) {
    if (day < 1 || day > state.planData.length) return;
    final newCompleted = Set<String>.from(state.completedChapters);
    for (final c in state.planData[day - 1].chapters) {
      newCompleted.add(c.id);
    }
    
    int nextDay = state.currentDay;
    if (day == state.currentDay && day < state.planData.length) {
      nextDay = day + 1;
      while (nextDay < state.planData.length && state.planData[nextDay - 1].chapters.every((c) => newCompleted.contains(c.id))) {
        nextDay++;
      }
    }

    state = state.copyWith(
      completedChapters: newCompleted,
      currentDay: nextDay,
    );
    _saveState();

    if (state.isPlanComplete) {
      ref.read(notificationServiceProvider).cancelReminder();
    }
  }

  void markDayIncomplete(int day) {
    if (day < 1 || day > state.planData.length) return;
    final newCompleted = Set<String>.from(state.completedChapters);
    for (final c in state.planData[day - 1].chapters) {
      newCompleted.remove(c.id);
    }
    state = state.copyWith(completedChapters: newCompleted);
    _saveState();
  }

  void markChapterComplete(PlanChapter chapter) {
    final newCompleted = Set<String>.from(state.completedChapters)..add(chapter.id);
    state = state.copyWith(completedChapters: newCompleted);
    _saveState();
  }

  void jumpToDay(int day) {
    state = state.copyWith(currentDay: day);
    _saveState();
  }
}

final readingPlanProvider = NotifierProvider<ReadingPlanNotifier, ReadingPlanState>(ReadingPlanNotifier.new);

class ActivePlanContextNotifier extends Notifier<int?> {
  @override
  int? build() {
    return null;
  }

  void setContext(int? day) {
    state = day;
  }
}

final activePlanContextProvider = NotifierProvider<ActivePlanContextNotifier, int?>(ActivePlanContextNotifier.new);
