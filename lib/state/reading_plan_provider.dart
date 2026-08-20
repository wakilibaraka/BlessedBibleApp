import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../data/local_storage/preferences_service.dart';

/// App weekday: 1=Sunday, 2=Monday, ..., 7=Saturday
int appWeekday(DateTime date) {
  return (date.weekday % 7) + 1;
}

// --- LEGACY FOR UI ---
enum PlanStartMode { startToday, calendarYear }

class PlanChapter {
  final String id = '';
  final String bookName;
  final int chapterNum;
  PlanChapter({this.bookName = '', this.chapterNum = 1});
}
// ---------------------

class PlanPassage {
  final String label;
  final List<String> refs;
  PlanPassage({required this.label, required this.refs});
  factory PlanPassage.fromJson(Map<String, dynamic> json) {
    return PlanPassage(
      label: json['label'] as String,
      refs: List<String>.from(json['refs']),
    );
  }
  Map<String, dynamic> toJson() => {
        'label': label,
        'refs': refs,
      };
}

class PlanDayData {
  final int day;
  final int week;
  final String title;
  final List<PlanPassage> passages;

  PlanDayData(
      {required this.day,
      required this.week,
      required this.title,
      required this.passages});

  factory PlanDayData.fromJson(Map<String, dynamic> json) {
    return PlanDayData(
      day: json['day'] as int,
      week: json['week'] as int,
      title: json['title'] as String,
      passages: (json['passages'] as List)
          .map((e) => PlanPassage.fromJson(e))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        'day': day,
        'week': week,
        'title': title,
        'passages': passages.map((p) => p.toJson()).toList(),
      };

  // --- LEGACY FOR UI ---
  List<PlanChapter> get chapters => [];
  List<String> get readings => [];
}

class ReadingPlanState {
  final bool isLoading;
  final String planId;
  final DateTime? planStartedOn;
  final String paceMode; // 'scheduled' | 'flexible'
  final int? restDay; // 1=Sun .. 7=Sat, null = no rest
  final Set<int> completedReadings; // Set of day numbers
  final List<PlanDayData> planData;

  // Additional legacy state preserved so UI compiles during step 1
  final bool reminderEnabled;
  final int reminderTimeHour;
  final int reminderTimeMinute;

  ReadingPlanState({
    this.isLoading = false,
    this.planId = '',
    this.planStartedOn,
    this.paceMode = 'scheduled',
    this.restDay,
    this.completedReadings = const {},
    this.planData = const [],
    this.reminderEnabled = false,
    this.reminderTimeHour = 8,
    this.reminderTimeMinute = 0,
  });

  bool get isActive => planStartedOn != null;

  bool get isComplete =>
      planData.isNotEmpty && completedReadings.length >= planData.length;

  double get percentComplete =>
      planData.isEmpty ? 0.0 : completedReadings.length / planData.length;

  int get oldestUnread {
    if (planData.isEmpty) return 1;
    for (int i = 1; i <= planData.length; i++) {
      if (!completedReadings.contains(i)) return i;
    }
    return planData.length;
  }

  int? get todayReadingDay {
    if (planData.isEmpty || planStartedOn == null) return 1;
    if (isComplete) return null;

    if (paceMode == 'flexible') {
      return oldestUnread;
    } else {
      // Mode A: scheduled
      final s = DateTime.utc(
          planStartedOn!.year, planStartedOn!.month, planStartedOn!.day);
      final now = DateTime.now();
      final t = DateTime.utc(now.year, now.month, now.day);

      if (t.isBefore(s)) return 1;

      int elapsedReadingDays = 0;
      DateTime current = s;
      while (!current.isAfter(t)) {
        if (restDay == null || appWeekday(current) != restDay) {
          elapsedReadingDays++;
        }
        current = current.add(const Duration(days: 1));
      }

      // If elapsedReadingDays is 0 (e.g. started today and today is a rest day), it's day 1
      return elapsedReadingDays.clamp(1, planData.length);
    }
  }

  Set<int> get missedDays {
    if (paceMode == 'flexible' ||
        planData.isEmpty ||
        planStartedOn == null ||
        isComplete) {
      return {};
    }

    final today = todayReadingDay;
    if (today == null) return {};

    final Set<int> missed = {};
    for (int i = 1; i < today; i++) {
      if (!completedReadings.contains(i)) {
        missed.add(i);
      }
    }
    return missed;
  }

  ReadingPlanState copyWith({
    bool? isLoading,
    String? planId,
    DateTime? planStartedOn,
    String? paceMode,
    int? restDay,
    Set<int>? completedReadings,
    List<PlanDayData>? planData,
    bool? reminderEnabled,
    int? reminderTimeHour,
    int? reminderTimeMinute,
  }) {
    return ReadingPlanState(
      isLoading: isLoading ?? this.isLoading,
      planId: planId ?? this.planId,
      planStartedOn: planStartedOn ?? this.planStartedOn,
      paceMode: paceMode ?? this.paceMode,
      restDay: restDay == -1 ? null : (restDay ?? this.restDay),
      completedReadings: completedReadings ?? this.completedReadings,
      planData: planData ?? this.planData,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
    );
  }

  // --- LEGACY ALIASES FOR UI TO COMPILE ---
  int get currentDay => todayReadingDay ?? planData.length;
  DateTime get startDate => planStartedOn ?? DateTime.now();
  Set<String> get completedChapters => {};
  bool isDayComplete(int day) => completedReadings.contains(day);
  double get completionPercentage => percentComplete;
  bool get isPlanComplete => isComplete;
  PlanStartMode get startMode => PlanStartMode.startToday;
  String getFormattedDateForDay(int day) => '';
}

class ReadingPlanNotifier extends Notifier<ReadingPlanState> {
  /// The planId this notifier instance is keyed for (injected via factory).
  final String _planId;
  ReadingPlanNotifier(this._planId);

  @override
  ReadingPlanState build() {
    _loadData(_planId);
    return ReadingPlanState(isLoading: true, planId: _planId);
  }

  Future<void> _loadData(String targetPlanId) async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/reading_plans/chronological_1yr.json');
      final Map<String, dynamic> decoded =
          await compute<String, Map<String, dynamic>>(
        (s) => jsonDecode(s) as Map<String, dynamic>,
        jsonString,
      );
      final rawReadings = decoded['readings'] as List;
      final planData = rawReadings.map((e) => PlanDayData.fromJson(e)).toList();

      final prefsState =
          ref.read(preferencesProvider).getReadingPlanState(targetPlanId);

      String planId = targetPlanId;
      DateTime? planStartedOn;
      String paceMode = 'scheduled';
      int? restDay;
      Set<int> completedReadings = {};
      bool reminderEnabled = false;
      int reminderTimeHour = 8;
      int reminderTimeMinute = 0;

      if (prefsState != null) {
        if (prefsState.containsKey('completedReadings')) {
          final list = prefsState['completedReadings'] as List;
          completedReadings = list.map((e) => e as int).toSet();
        }
        if (prefsState['planStartedOn'] != null) {
          planStartedOn =
              DateTime.tryParse(prefsState['planStartedOn'] as String);
        }
        if (prefsState['paceMode'] != null) {
          paceMode = prefsState['paceMode'] as String;
        }
        if (prefsState.containsKey('restDay')) {
          restDay = prefsState['restDay'] as int?;
        }
        if (prefsState['planId'] != null) {
          planId = prefsState['planId'] as String;
        }
        if (prefsState.containsKey('reminderEnabled')) {
          reminderEnabled = prefsState['reminderEnabled'] as bool;
          reminderTimeHour = prefsState['reminderTimeHour'] as int;
          reminderTimeMinute = prefsState['reminderTimeMinute'] as int;
        }
      }

      List<PlanDayData> finalPlanData = planData;
      if (planId != 'chronological_1yr') {
        final customPlan = ref.read(preferencesProvider).getCustomPlan(planId);
        if (customPlan != null) {
          if (customPlan.containsKey('schedule')) {
            final schedule = customPlan['schedule'] as List;
            finalPlanData = [];
            for (final dayMap in schedule) {
              final dayNum = dayMap['dayNumber'] as int;
              final portions = dayMap['portions'] as List;
              
              List<PlanPassage> passages = [];
              for (final portionMap in portions) {
                final book = portionMap['book'] as String;
                final startCh = portionMap['startChapter'] as int;
                final startV = portionMap['startVerse'] as int;
                final endCh = portionMap['endChapter'] as int;
                final endV = portionMap['endVerse'] as int;
                
                List<String> refs = [];
                for (int ch = startCh; ch <= endCh; ch++) {
                  if (startCh == endCh) {
                     refs.add('$book $ch:$startV-$endV');
                  } else if (ch == startCh) {
                     refs.add('$book $ch:$startV');
                  } else if (ch == endCh) {
                     refs.add('$book $ch:1-$endV');
                  } else {
                     refs.add('$book $ch');
                  }
                }
                
                String label;
                if (startCh == endCh) {
                  label = '$book $startCh:$startV-$endV';
                } else {
                  label = '$book $startCh:$startV–$endCh:$endV';
                }
                
                passages.add(PlanPassage(label: label, refs: refs));
              }
              
              finalPlanData.add(PlanDayData(
                day: dayNum,
                week: ((dayNum - 1) ~/ 7) + 1,
                title: 'Day $dayNum',
                passages: passages,
              ));
            }
          } else {
            final rawReadings = customPlan['readings'] as List;
            finalPlanData =
                rawReadings.map((e) => PlanDayData.fromJson(e)).toList();
          }

          // Restore paceMode and restDay saved inside the plan definition
          if (customPlan.containsKey('paceMode')) {
            paceMode = customPlan['paceMode'] as String;
          }
          if (customPlan.containsKey('restDay')) {
            restDay = customPlan['restDay'] as int?;
          }
        } else {
          // Custom plan not found, fallback to chronological
          planId = 'chronological_1yr';
        }
      }

      state = state.copyWith(
        isLoading: false,
        planData: finalPlanData,
        planId: planId,
        planStartedOn: planStartedOn,
        paceMode: paceMode,
        restDay: restDay,
        completedReadings: completedReadings,
        reminderEnabled: reminderEnabled,
        reminderTimeHour: reminderTimeHour,
        reminderTimeMinute: reminderTimeMinute,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _saveToPrefs(ReadingPlanState s) {
    ref.read(preferencesProvider).saveReadingPlanState(s.planId, {
      'planId': s.planId,
      'planStartedOn': s.planStartedOn?.toIso8601String(),
      'paceMode': s.paceMode,
      'restDay': s.restDay,
      'completedReadings': s.completedReadings.toList(),
      'reminderEnabled': s.reminderEnabled,
      'reminderTimeHour': s.reminderTimeHour,
      'reminderTimeMinute': s.reminderTimeMinute,
    });
  }

  void deletePlanProgress() {
    ref.read(preferencesProvider).deleteReadingPlanState(id);
    ref.invalidateSelf();
  }


  void startPlan(
      {String? planId,
      String paceMode = 'scheduled',
      int? restDay,
      List<PlanDayData>? customPlanData}) {
    final next = state.copyWith(
      planId: planId ?? _planId,
      planStartedOn: DateTime.now(),
      paceMode: paceMode,
      restDay: restDay,
      completedReadings: {},
      planData: customPlanData,
    );
    state = next;
    _saveToPrefs(next);
    ref.read(notificationServiceProvider).syncReadingPlanReminder(
        next.reminderEnabled,
        next.reminderTimeHour,
        next.reminderTimeMinute,
        next.restDay);
  }

  void markReadingComplete(int day) {
    final newCompleted = Set<int>.from(state.completedReadings)..add(day);
    final next = state.copyWith(completedReadings: newCompleted);
    state = next;
    _saveToPrefs(next);
  }

  void markReadingIncomplete(int day) {
    final newCompleted = Set<int>.from(state.completedReadings)..remove(day);
    final next = state.copyWith(completedReadings: newCompleted);
    state = next;
    _saveToPrefs(next);
  }

  void setPaceMode(String mode) {
    final next = state.copyWith(paceMode: mode);
    state = next;
    _saveToPrefs(next);
  }

  void setRestDay(int? day) {
    final next = state.copyWith(restDay: day);
    state = next;
    _saveToPrefs(next);
    ref.read(notificationServiceProvider).syncReadingPlanReminder(
        next.reminderEnabled,
        next.reminderTimeHour,
        next.reminderTimeMinute,
        next.restDay);
  }

  void restartPlan() {
    final next = state.copyWith(
      planStartedOn: DateTime.now(),
      completedReadings: {},
    );
    state = next;
    _saveToPrefs(next);
  }

  // --- LEGACY ALIASES FOR UI TO COMPILE ---
  void startPlanFromDay(int day) {}
  void changeStartMode(dynamic mode) {}
  void setReminder(bool enabled, int hour, int minute) {
    final next = state.copyWith(
      reminderEnabled: enabled,
      reminderTimeHour: hour,
      reminderTimeMinute: minute,
    );
    state = next;
    _saveToPrefs(next);
    ref
        .read(notificationServiceProvider)
        .syncReadingPlanReminder(enabled, hour, minute, next.restDay);
  }

  void jumpToDay(int day) {}
  bool jumpToBook(String book) => false;
  int? findDayForPassage(String book, int chapter) => 1;
  void markDayComplete(int day) => markReadingComplete(day);
  void markDayIncomplete(int day) => markReadingIncomplete(day);
  void markChapterComplete(PlanChapter c) {}
}

final readingPlanProvider =
    NotifierProvider.family<ReadingPlanNotifier, ReadingPlanState, String>(
  (planId) => ReadingPlanNotifier(planId),
);

class ActivePlanIdsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return ref.read(preferencesProvider).getActivePlanIds();
  }

  bool addPlan(String id) {
    if (state.contains(id)) return true;
    if (state.length >= 3) return false; // Enforce block-not-evict
    final next = [...state, id];
    state = next;
    ref.read(preferencesProvider).saveActivePlanIds(next);
    return true;
  }

  void removePlan(String id) {
    final next = state.where((e) => e != id).toList();
    state = next;
    ref.read(preferencesProvider).saveActivePlanIds(next);
  }
}

final activePlanIdsProvider =
    NotifierProvider<ActivePlanIdsNotifier, List<String>>(
        ActivePlanIdsNotifier.new);

class CurrentActivePlanIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setContext(String? id) => state = id;
}

final currentActivePlanIdProvider =
    NotifierProvider<CurrentActivePlanIdNotifier, String?>(
        CurrentActivePlanIdNotifier.new);

class ActivePlanContextNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  void setContext(int? day) => state = day;
}

final activePlanContextProvider =
    NotifierProvider<ActivePlanContextNotifier, int?>(
        ActivePlanContextNotifier.new);
