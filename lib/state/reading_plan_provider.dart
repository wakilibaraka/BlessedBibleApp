import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../data/local_storage/preferences_service.dart';
import 'read_settings_provider.dart';
import '../models/plan_spec.dart';
import '../models/reading_plan.dart';
import '../services/pace_remap_service.dart';
import '../services/word_count_service.dart';
import '../utils/isolate_parsers.dart';

/// App weekday: 1=Sunday, 2=Monday, ..., 7=Saturday
int appWeekday(DateTime date) {
  return (date.weekday % 7) + 1;
}

/// Verse range with completion flag for chapter-coverage checks.
class _CoverRange {
  final int lo;
  final int hi;
  final bool done;
  const _CoverRange(this.lo, this.hi, this.done);
}

class PlanChapter {
  final String id;
  final String bookName;
  final int chapterNum;
  PlanChapter({this.bookName = '', this.chapterNum = 1, String? id})
      : id = id ?? (bookName.isEmpty ? '' : '${bookName}_$chapterNum');
}
// ---------------------

class PlanPassage {
  final String label;
  final List<String> refs;

  /// Parsed bounds attached at load (in-memory only; never persisted).
  /// Empty when the label/refs were unparseable.
  final List<PlanRefSpec> parsedRefs;
  PlanPassage(
      {required this.label, required this.refs, this.parsedRefs = const []});
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
  /// Chapters covered by this day's passages (from load-time parsed
  /// bounds). Powers the read-screen end-of-chapter prompt.
  List<PlanChapter> get chapters {
    final out = <PlanChapter>[];
    final seen = <String>{};
    for (final p in passages) {
      for (final r in p.parsedRefs) {
        for (var ch = r.startChapter; ch <= r.endChapter; ch++) {
          final id = '${r.book}_$ch';
          if (seen.add(id)) {
            out.add(PlanChapter(
                bookName: r.book, chapterNum: ch, id: id));
          }
        }
      }
    }
    return out;
  }
}

class ReadingPlanState {
  final bool isLoading;
  final String planId;
  final DateTime? planStartedOn;
  final String paceMode; // 'scheduled' | 'flexible'
  final int? restDay; // 1=Sun .. 7=Sat, null = no rest (legacy single)
  /// Rest weekdays (app convention 1=Sun..7=Sat). When non-empty this set
  /// wins over [restDay]; empty + null restDay means no rest days.
  final Set<int> restDays;
  final Set<int> completedReadings; // Set of day numbers (legacy)
  final List<PlanDayData> planData;

  /// Content-keyed completion: atom ids `Book|sc|sv|ec|ev` per passage.
  /// Stable across re-partitioning (repace never loses progress), unlike
  /// day numbers. Written alongside [completedReadings] (additive
  /// migration); getters prefer atoms whenever the set is non-empty.
  final Set<String> completedAtomIds;

  /// Transient per-day atom lists, rebuilt on every load (never persisted;
  /// persistence holds the completed sets only). Empty map or empty entry
  /// falls back to the legacy day-number rule for that day.
  final Map<int, List<String>> dayAtoms;

  /// Load failure (e.g. bundled plan asset missing). Null when healthy;
  /// screens must render an honest error + retry instead of an empty plan.
  final String? error;

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
    this.restDays = const {},
    this.completedReadings = const {},
    this.planData = const [],
    this.completedAtomIds = const {},
    this.dayAtoms = const {},
    this.error,
    this.reminderEnabled = false,
    this.reminderTimeHour = 8,
    this.reminderTimeMinute = 0,
  });

  bool get isActive => planStartedOn != null;

  /// Rest-day rule (app weekday 1=Sun..7=Sat): the set wins when non-empty,
  /// otherwise the legacy single day; nothing set means no rest days.
  bool isRestWeekday(int appWeekday) =>
      restDays.isNotEmpty ? restDays.contains(appWeekday) : restDay == appWeekday;

  /// Effective day completion: the atom rule when atoms exist for the
  /// day (and any atom is recorded at all), otherwise the legacy
  /// day-number rule. During the additive migration both sets are kept.
  bool isDayComplete(int day) {
    final atoms = dayAtoms[day];
    if (completedAtomIds.isNotEmpty &&
        atoms != null &&
        atoms.isNotEmpty) {
      for (final a in atoms) {
        if (!completedAtomIds.contains(a)) return false;
      }
      return true;
    }
    return completedReadings.contains(day);
  }

  int get _completeDayCount {
    var n = 0;
    for (var i = 1; i <= planData.length; i++) {
      if (isDayComplete(i)) n++;
    }
    return n;
  }

  bool get isComplete =>
      planData.isNotEmpty && _completeDayCount >= planData.length;

  double get percentComplete =>
      planData.isEmpty ? 0.0 : _completeDayCount / planData.length;

  int get oldestUnread {
    if (planData.isEmpty) return 1;
    for (int i = 1; i <= planData.length; i++) {
      if (!isDayComplete(i)) return i;
    }
    return planData.length;
  }

  /// Days where the atom rule and the legacy rule disagree (migration
  /// diagnostics; feeds the decision to drop day numbers later).
  List<int> get progressDisagreement {
    final out = <int>[];
    if (completedAtomIds.isEmpty) return out;
    for (var i = 1; i <= planData.length; i++) {
      final atoms = dayAtoms[i];
      bool atomRule;
      if (atoms == null || atoms.isEmpty) {
        atomRule = completedReadings.contains(i);
      } else {
        atomRule = true;
        for (final a in atoms) {
          if (!completedAtomIds.contains(a)) {
            atomRule = false;
            break;
          }
        }
      }
      if (atomRule != completedReadings.contains(i)) out.add(i);
    }
    return out;
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
        if (!isRestWeekday(appWeekday(current))) {
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
      if (!isDayComplete(i)) {
        missed.add(i);
      }
    }
    return missed;
  }

  static const _keepError = Object();

  ReadingPlanState copyWith({
    bool? isLoading,
    String? planId,
    DateTime? planStartedOn,
    String? paceMode,
    int? restDay,
    Set<int>? restDays,
    Set<int>? completedReadings,
    List<PlanDayData>? planData,
    Set<String>? completedAtomIds,
    Map<int, List<String>>? dayAtoms,
    // Sentinel so callers can explicitly clear with error: null.
    Object? error = _keepError,
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
      restDays: restDays ?? this.restDays,
      completedReadings: completedReadings ?? this.completedReadings,
      planData: planData ?? this.planData,
      completedAtomIds: completedAtomIds ?? this.completedAtomIds,
      // New readings invalidate cached atoms (rebuilt on next load).
      dayAtoms: planData != null ? (dayAtoms ?? {}) : (dayAtoms ?? this.dayAtoms),
      error:
          identical(error, _keepError) ? this.error : error as String?,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
    );
  }

  // --- Remaining convenience getters (all live) ---
  int get currentDay => todayReadingDay ?? planData.length;

  /// Chapters fully covered by completed atoms (derived, not stored).
  /// Powers the read-screen end-of-chapter prompt and first-unread lookup.
  Set<String> get completedChapters {
    final out = <String>{};
    if (completedAtomIds.isEmpty) return out;
    // (1) Chapters of fully complete days.
    for (var d = 1; d <= planData.length; d++) {
      if (!isDayComplete(d)) continue;
      for (final c in planData[d - 1].chapters) {
        out.add(c.id);
      }
    }
    // (2) Standalone-covered chapters: every single-chapter atom
    // touching the chapter is recorded and they jointly cover it within
    // plan scope. Exact without canon data; multi-chapter atoms are
    // covered by rule (1) (their day must complete).
    final Map<String, List<_CoverRange>> touching = {};
    for (final atoms in dayAtoms.values) {
      for (final a in atoms) {
        final parts = a.split('|');
        if (parts.length != 5) continue;
        final sc = int.tryParse(parts[1]);
        final sv = int.tryParse(parts[2]);
        final ec = int.tryParse(parts[3]);
        final ev = int.tryParse(parts[4]);
        if (sc == null || sv == null || ec == null || ev == null) continue;
        if (sc != ec) continue;
        touching.putIfAbsent('${parts[0]}|$sc', () => []).add(
            _CoverRange(sv, ev, completedAtomIds.contains(a)));
      }
    }
    touching.forEach((key, ranges) {
      var planMax = 0;
      for (final r in ranges) {
        if (r.hi > planMax) planMax = r.hi;
      }
      final sorted = ranges.toList()
        ..sort((a, b) => a.lo.compareTo(b.lo));
      var covered = 1;
      var complete = false;
      for (final r in sorted) {
        if (!r.done) continue;
        if (r.lo > covered) break;
        if (r.hi >= covered) covered = r.hi + 1;
        if (covered > planMax) {
          complete = true;
          break;
        }
      }
      if (complete) {
        final bar = key.indexOf('|');
        out.add('${key.substring(0, bar)}_${key.substring(bar + 1)}');
      }
    });
    return out;
  }

  bool get isPlanComplete => isComplete;
}

const Set<String> kBundledPlanIds = {
  'chronological_1yr',
  'mccheyne_1yr',
  'horner_10_chapters',
  'esv_through_the_bible',
  'esv_everyday_in_word',
  'esv_gospels_and_epistles',
  'esv_psalms_and_wisdom',
  'esv_pentateuch_and_history',
  'esv_chronicles_and_prophets',
  'heartlight_ot_nt',
};

class ReadingPlanNotifier extends Notifier<ReadingPlanState> {
  /// The planId this notifier instance is keyed for (injected via factory).
  final String _planId;
  ReadingPlanNotifier(this._planId);

  @override
  ReadingPlanState build() {
    // Deferred: for custom ids _loadData has no await before the state
    // assignment, so running it inline would write state while the
    // provider is still uninitialized (stuck on isLoading forever).
    // A microtask runs after build() has returned, when state is legal.
    // _loadData is fully try/caught, so the deferred future cannot
    // produce unhandled async errors.
    Future.microtask(() => _loadData(_planId));
    return ReadingPlanState(isLoading: true, planId: _planId);
  }

  Future<void> _loadData(String targetPlanId) async {
    try {
      List<PlanDayData> planData = [];
      final bool isBundled = kBundledPlanIds.contains(targetPlanId);
      
      if (isBundled) {
        final jsonString = await rootBundle.loadString('assets/reading_plans/$targetPlanId.json');
        final Map<String, dynamic> decoded = await compute<String, Map<String, dynamic>>(
          (s) => jsonDecode(s) as Map<String, dynamic>, jsonString);
        final rawReadings = decoded['readings'] as List;
        planData = rawReadings.map((e) => PlanDayData.fromJson(e)).toList();
      }

      final prefsState =
          ref.read(preferencesProvider).getReadingPlanState(targetPlanId);

      String planId = targetPlanId;
      DateTime? planStartedOn;
      String paceMode = 'scheduled';
      int? restDay;
      Set<int> restDays = {};
      Set<int> completedReadings = {};
      Set<String> completedAtoms = {};
      bool reminderEnabled = false;
      int reminderTimeHour = 8;
      int reminderTimeMinute = 0;

      if (prefsState != null) {
        if (prefsState.containsKey('completedReadings')) {
          final list = prefsState['completedReadings'] as List;
          completedReadings = list.map((e) => e as int).toSet();
        }
        if (prefsState.containsKey('completedAtoms')) {
          final list = prefsState['completedAtoms'] as List;
          completedAtoms = list.map((e) => e as String).toSet();
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
        if (prefsState.containsKey('restDays')) {
          final list = prefsState['restDays'] as List;
          restDays = list.map((e) => e as int).toSet();
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
      if (!isBundled) {
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

      // Parse every passage once (drives chapters + content atoms).
      // Unparseable passages keep empty parsedRefs and degrade to the
      // legacy day-number rule — they must never break loading.
      CanonIndex? canon;
      try {
        canon = await _canonIndex();
      } catch (e) {
        debugPrint('plan refs: canon unavailable ($e)');
      }
      var parsedPlanData = finalPlanData;
      if (canon != null) {
        parsedPlanData = [
          for (final day in finalPlanData)
            PlanDayData(
              day: day.day,
              week: day.week,
              title: day.title,
              passages: [
                for (final p in day.passages) _parsePassage(p, canon),
              ],
            ),
        ];
      }
      final dayAtoms = _dayAtomsFromParsed(parsedPlanData);
      if (completedAtoms.isEmpty && completedReadings.isNotEmpty) {
        // One-time backfill: expand legacy day numbers to atoms.
        for (final d in completedReadings) {
          final atoms = dayAtoms[d];
          if (atoms != null) completedAtoms.addAll(atoms);
        }
      }

      state = state.copyWith(
        isLoading: false,
        planData: parsedPlanData,
        planId: planId,
        planStartedOn: planStartedOn,
        paceMode: paceMode,
        restDay: restDay,
        restDays: restDays,
        completedReadings: completedReadings,
        completedAtomIds: completedAtoms,
        dayAtoms: dayAtoms,
        reminderEnabled: reminderEnabled,
        reminderTimeHour: reminderTimeHour,
        reminderTimeMinute: reminderTimeMinute,
        error: null,
      );
    } catch (e) {
      // Never a silent empty plan: surface the failure for retry UI.
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load this plan ($e).',
      );
    }
  }

  /// Canon bounds shared by all plan loads in this process (word counts
  /// asset; tiny). Loaded once, lazily — only plans actually opened pay.
  static CanonIndex? _canonCache;

  static Future<CanonIndex> _canonIndex() async {
    final hit = _canonCache;
    if (hit != null) return hit;
    final jsonString =
        await rootBundle.loadString('assets/data/word_counts.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final canon = <String, Map<int, List<int>>>{};
    decoded.forEach((book, chapters) {
      final chMap = <int, List<int>>{};
      (chapters as Map<String, dynamic>).forEach((ch, info) {
        chMap[int.parse(ch)] = (((info as Map<String, dynamic>)['verses'])
                as Map<String, dynamic>)
            .keys
            .map(int.parse)
            .toList();
      });
      canon[book] = chMap;
    });
    return _canonCache = canon;
  }

  /// Attaches parsed bounds to one passage (label first, then refs).
  /// Returns the passage unchanged when nothing parses.
  PlanPassage _parsePassage(PlanPassage passage, CanonIndex canon) {
    PlanRefSpec? parsed;
    try {
      parsed = PlanRefSpec.parse(passage.label, canon);
    } catch (_) {
      for (final alt in passage.refs) {
        try {
          parsed = PlanRefSpec.parse(alt, canon);
          break;
        } catch (_) {}
      }
    }
    if (parsed == null) {
      debugPrint('plan refs: unparseable passage "${passage.label}"');
      return passage;
    }
    return PlanPassage(
        label: passage.label, refs: passage.refs, parsedRefs: [parsed]);
  }

  /// Content atom ids per 1-based day from already-parsed passages.
  Map<int, List<String>> _dayAtomsFromParsed(
      List<PlanDayData> planData) {
    final out = <int, List<String>>{};
    for (var i = 0; i < planData.length; i++) {
      out[i + 1] = [
        for (final p in planData[i].passages)
          for (final r in p.parsedRefs)
            '${r.book}|${r.startChapter}|${r.startVerse}|${r.endChapter}|${r.endVerse}',
      ];
    }
    return out;
  }

  void _saveToPrefs(ReadingPlanState s) {
    ref.read(preferencesProvider).saveReadingPlanState(s.planId, {
      'planId': s.planId,
      'planStartedOn': s.planStartedOn?.toIso8601String(),
      'paceMode': s.paceMode,
      'restDay': s.restDay,
      'restDays': s.restDays.toList(),
      'completedReadings': s.completedReadings.toList(),
      'completedAtoms': s.completedAtomIds.toList(),
      'reminderEnabled': s.reminderEnabled,
      'reminderTimeHour': s.reminderTimeHour,
      'reminderTimeMinute': s.reminderTimeMinute,
    });
  }

  void deletePlanProgress() {
    ref.read(preferencesProvider).deleteReadingPlanState(_planId);
    ref.invalidateSelf();
  }


  void startPlan({
      String? planId,
      String paceMode = 'scheduled',
      int? restDay,
      DateTime? startDate,
      List<PlanDayData>? customPlanData}) {
    final next = state.copyWith(
      planId: planId ?? _planId,
      planStartedOn: startDate ?? DateTime.now(),
      paceMode: paceMode,
      // Normalize through the -1 sentinel so an explicit null rest day
      // actually clears a previously stored one (see setRestDayOrNone).
      restDay: restDay ?? -1,
      completedReadings: {},
      planData: customPlanData,
      completedAtomIds: {},
    );
    state = next;
    _saveToPrefs(next);
    _syncReminder(next);
  }

  void markReadingComplete(int day) {
    final newCompleted = Set<int>.from(state.completedReadings)..add(day);
    final newAtoms = Set<String>.from(state.completedAtomIds)
      ..addAll(state.dayAtoms[day] ?? const []);
    final next = state.copyWith(
        completedReadings: newCompleted, completedAtomIds: newAtoms);
    state = next;
    _saveToPrefs(next);
  }

  void markReadingIncomplete(int day) {
    final newCompleted = Set<int>.from(state.completedReadings)..remove(day);
    final newAtoms = Set<String>.from(state.completedAtomIds)
      ..removeAll(state.dayAtoms[day] ?? const []);
    final next = state.copyWith(
        completedReadings: newCompleted, completedAtomIds: newAtoms);
    state = next;
    _saveToPrefs(next);
  }

  /// Marks every reading day strictly before [upToDay] complete
  /// (catch-up: "mark all previous as read"). Clamps to the plan range;
  /// [upToDay] itself is never touched.
  void markAllPreviousRead(int upToDay) {
    final last = upToDay.clamp(1, state.planData.length + 1);
    final newCompleted = Set<int>.from(state.completedReadings)
      ..addAll(List.generate(last - 1, (i) => i + 1));
    final newAtoms = Set<String>.from(state.completedAtomIds);
    for (var d = 1; d < last; d++) {
      newAtoms.addAll(state.dayAtoms[d] ?? const []);
    }
    final next = state.copyWith(
        completedReadings: newCompleted, completedAtomIds: newAtoms);
    state = next;
    _saveToPrefs(next);
  }

  void setPaceMode(String mode) {
    final next = state.copyWith(paceMode: mode);
    state = next;
    _saveToPrefs(next);
  }

  void setRestDay(int? day) {
    final next = state.copyWith(restDay: day, restDays: {});
    state = next;
    _saveToPrefs(next);
    _syncReminder(next);
  }

  /// Sets the rest-weekday set (app convention 1=Sun..7=Sat, empty = none).
  /// Clears the legacy single day so the set is unambiguous.
  void setRestDays(Set<int> days) {
    // -1 sentinel: copyWith(null) would silently keep the old single day.
    final next = state.copyWith(restDay: -1, restDays: days);
    state = next;
    _saveToPrefs(next);
    _syncReminder(next);
  }

  /// Best-effort reminder sync: a notification failure must never break
  /// plan state writes (or unit tests without platform channels). Async
  /// with an awaited call so failures land in this try/catch instead of
  /// escaping through an async gap.
  Future<void> _syncReminder(ReadingPlanState next) async {
    try {
      await ref.read(notificationServiceProvider).syncReadingPlanReminder(
          next.reminderEnabled,
          next.reminderTimeHour,
          next.reminderTimeMinute,
          next.restDay,
          restDays: next.restDays,
          planId: next.planId);
    } catch (e) {
      debugPrint('plan reminder sync failed (non-fatal): $e');
    }
  }

  /// Null-safe rest-day setter. NOTE: `copyWith(restDay: null)` silently
  /// keeps the old value (Dart can't distinguish "absent" from null), so
  /// "no rest day" must be expressed as -1 (converted to null in copyWith).
  /// Always use this helper instead of setRestDay(null).
  void setRestDayOrNone(int? day) => setRestDay(day ?? -1);


  void setStartDate(DateTime startDate) {
    final next = state.copyWith(planStartedOn: startDate);
    state = next;
    _saveToPrefs(next);
  }

  void restartPlan() {
    final next = state.copyWith(
      planStartedOn: DateTime.now(),
      completedReadings: {},
      completedAtomIds: {},
    );
    state = next;
    _saveToPrefs(next);
  }

  void setReminder(bool enabled, int hour, int minute) {
    final next = state.copyWith(
      reminderEnabled: enabled,
      reminderTimeHour: hour,
      reminderTimeMinute: minute,
    );
    state = next;
    _saveToPrefs(next);
    _syncReminder(next);
  }

  void markDayComplete(int day) => markReadingComplete(day);

  /// Marks one chapter read at atom precision: every recorded atom fully
  /// inside (book, chapter) is added, then day numbers are recomputed so
  /// partially-covered days stay honestly incomplete. Multi-chapter atoms
  /// spanning beyond the chapter are (correctly) left alone.
  void markChapterComplete(PlanChapter c) {
    if (c.bookName.isEmpty) return;
    final newAtoms = Set<String>.from(state.completedAtomIds);
    for (final atoms in state.dayAtoms.values) {
      for (final a in atoms) {
        final parts = a.split('|');
        if (parts.length != 5 || parts[0] != c.bookName) continue;
        final sc = int.tryParse(parts[1]);
        final ec = int.tryParse(parts[3]);
        if (sc == null || ec == null) continue;
        if (sc >= c.chapterNum && ec <= c.chapterNum) newAtoms.add(a);
      }
    }
    final newCompleted = <int>{};
    for (var d = 1; d <= state.planData.length; d++) {
      final atoms = state.dayAtoms[d];
      if (atoms != null &&
          atoms.isNotEmpty &&
          atoms.every(newAtoms.contains)) {
        newCompleted.add(d);
      } else if (state.completedReadings.contains(d)) {
        newCompleted.add(d);
      }
    }
    final next = state.copyWith(
        completedReadings: newCompleted, completedAtomIds: newAtoms);
    state = next;
    _saveToPrefs(next);
  }

  /// Adjust the day count of this custom plan and remap existing progress by
  /// content position. Persists both the new plan definition and new progress.
  ///
  /// Returns null on success, or an error string if tracks are missing or
  /// another failure occurs.
  Future<String?> adjustPace(int newDayCount) async {
    try {
      final prefs = ref.read(preferencesProvider);
      final planJson = prefs.getCustomPlan(_planId);
      if (planJson == null) return 'Plan not found.';

      final oldPlan = ReadingPlan.fromJson(planJson);
      if (oldPlan.tracks == null || oldPlan.tracks!.isEmpty) {
        return 'This plan was created before pace-adjustment was supported. '
            'Recreate it to enable this feature.';
      }

      final wcs = ref.read(wordCountServiceProvider);
      await wcs.init();
      final pJson =
          await rootBundle.loadString('assets/data/pericopes.json');
      final allPericopes =
          await compute(parsePericopesJson, pJson);

      final remapSvc = PaceRemapService(
        wordCountService: wcs,
        allPericopes: allPericopes,
        wpm: ref.read(readSettingsProvider).readingWpm,
      );

      // Atom-first remap: content-keyed completion survives re-partitioning
      // exactly (including partial-day progress); falls back to day numbers
      // when no atoms were recorded yet.
      final result = remapSvc.remap(
        oldPlan: oldPlan,
        oldCompleted: state.completedReadings,
        completedAtoms:
            state.completedAtomIds.isEmpty ? null : state.completedAtomIds,
        newDayCount: newDayCount,
      );

      // Persist updated plan definition
      prefs.saveCustomPlan(_planId, result.newPlan.toJson());

      // Persist updated progress
      final next = state.copyWith(completedReadings: result.newCompletedReadings);
      state = next;
      _saveToPrefs(next);

      // Reload planData from the new schedule
      ref.invalidateSelf();
      return null;
    } catch (e) {
      return 'Pace adjustment failed: $e';
    }
  }
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

  void makePrimary(String id) {
    if (!state.contains(id)) return;
    if (state.first == id) return;
    final next = state.where((e) => e != id).toList();
    next.insert(0, id);
    state = next;
    ref.read(preferencesProvider).saveActivePlanIds(next);
  }
}

final activePlanIdsProvider =
    NotifierProvider<ActivePlanIdsNotifier, List<String>>(
        ActivePlanIdsNotifier.new);

class HiddenPlanIdsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return ref.read(preferencesProvider).getHiddenPlanIds();
  }

  void addPlan(String id) {
    if (state.contains(id)) return;
    final next = [...state, id];
    state = next;
    ref.read(preferencesProvider).saveHiddenPlanIds(next);
  }

  void removePlan(String id) {
    final next = state.where((e) => e != id).toList();
    state = next;
    ref.read(preferencesProvider).saveHiddenPlanIds(next);
  }
}

final hiddenPlanIdsProvider =
    NotifierProvider<HiddenPlanIdsNotifier, List<String>>(
        HiddenPlanIdsNotifier.new);

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
