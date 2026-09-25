// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../state/reading_plan_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/shared_app_bar.dart';
import 'plan_reader_screen.dart';
import 'journey_map_screen.dart';
import '../../state/streak_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/surface_style_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/textured_glass_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

String _expandLabel(PlanPassage p) {
  if (p.refs.isEmpty) return p.label;
  final match =
      RegExp(r'^([1-3]?\s?[a-zA-Z\s]+?)\s\d').firstMatch(p.refs.first);
  final bookName = match != null ? match.group(1)! : p.refs.first;
  return p.label.replaceFirst(RegExp(r'^[1-3]?\s?[a-zA-Z]+\s?'), '$bookName ');
}

List<String> celebrationMilestones(
    Set<int> prev, Set<int> next, List<PlanDayData> planData) {
  final milestones = <String>[];
  if (next.isEmpty) return milestones;

  if (next.length % 30 == 0 && prev.length != next.length) {
    milestones.add('30-readings milestone');
  }

  final bookToReadings = <String, Set<int>>{};
  final readingToBooks = <int, Set<String>>{};
  final otReadings = <int>{};
  final ntReadings = <int>{};

  final otBooks = {
    'Genesis',
    'Exodus',
    'Leviticus',
    'Numbers',
    'Deuteronomy',
    'Joshua',
    'Judges',
    'Ruth',
    '1 Samuel',
    '2 Samuel',
    '1 Kings',
    '2 Kings',
    '1 Chronicles',
    '2 Chronicles',
    'Ezra',
    'Nehemiah',
    'Esther',
    'Job',
    'Psalms',
    'Proverbs',
    'Ecclesiastes',
    'Song of Solomon',
    'Isaiah',
    'Jeremiah',
    'Lamentations',
    'Ezekiel',
    'Daniel',
    'Hosea',
    'Joel',
    'Amos',
    'Obadiah',
    'Jonah',
    'Micah',
    'Nahum',
    'Habakkuk',
    'Zephaniah',
    'Haggai',
    'Zechariah',
    'Malachi'
  };
  final ntBooks = {
    'Matthew',
    'Mark',
    'Luke',
    'John',
    'Acts',
    'Romans',
    '1 Corinthians',
    '2 Corinthians',
    'Galatians',
    'Ephesians',
    'Philippians',
    'Colossians',
    '1 Thessalonians',
    '2 Thessalonians',
    '1 Timothy',
    '2 Timothy',
    'Titus',
    'Philemon',
    'Hebrews',
    'James',
    '1 Peter',
    '2 Peter',
    '1 John',
    '2 John',
    '3 John',
    'Jude',
    'Revelation'
  };

  for (int i = 0; i < planData.length; i++) {
    final day = i + 1;
    final booksForDay = <String>{};
    for (var p in planData[i].passages) {
      for (var ref in p.refs) {
        final match = RegExp(r'^([1-3]?\s?[a-zA-Z\s]+?)\s\d').firstMatch(ref);
        final book = match != null ? match.group(1)! : ref;
        booksForDay.add(book);
        bookToReadings.putIfAbsent(book, () => {}).add(day);

        if (otBooks.contains(book)) otReadings.add(day);
        if (ntBooks.contains(book)) ntReadings.add(day);
      }
    }
    readingToBooks[day] = booksForDay;
  }

  final newlyAdded = next.difference(prev);
  for (var day in newlyAdded) {
    final books = readingToBooks[day] ?? {};
    for (var book in books) {
      final bookDays = bookToReadings[book]!;
      if (bookDays.every((d) => next.contains(d)) &&
          !bookDays.every((d) => prev.contains(d))) {
        milestones.add('book complete: $book');
      }
    }
  }

  if (otReadings.isNotEmpty &&
      otReadings.every((d) => next.contains(d)) &&
      !otReadings.every((d) => prev.contains(d))) {
    milestones.add('OT complete');
  }

  if (ntReadings.isNotEmpty &&
      ntReadings.every((d) => next.contains(d)) &&
      !ntReadings.every((d) => prev.contains(d))) {
    milestones.add('NT complete');
  }

  if (next.length == planData.length && prev.length != planData.length) {
    milestones.add('Plan 100% complete');
  }

  return milestones.toSet().toList();
}

const _weekdayNames = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday'
];
const _weekdayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];
const _monthNamesShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

/// For scheduled mode: compute the real wall-clock date for reading [readingDay]
/// given [startedOn] and [restDay] (1=Sun..7=Sat, null = none).
DateTime _dateForReadingDay(DateTime startedOn, int readingDay, int? restDay) {
  DateTime d = DateTime.utc(startedOn.year, startedOn.month, startedOn.day);
  int count = 0;
  while (true) {
    if (restDay == null || appWeekday(d) != restDay) {
      count++;
      if (count == readingDay) return d;
    }
    d = d.add(const Duration(days: 1));
  }
}

/// For scheduled mode: build a map from [year-month-day string] → readingDay number
Map<String, int> _buildDateToReadingMap(ReadingPlanState s) {
  final map = <String, int>{};
  if (s.planStartedOn == null || s.planData.isEmpty) return map;
  DateTime d = DateTime.utc(
      s.planStartedOn!.year, s.planStartedOn!.month, s.planStartedOn!.day);
  int readingIdx = 0;
  while (readingIdx < s.planData.length) {
    if (s.restDay == null || appWeekday(d) != s.restDay) {
      readingIdx++;
      map['${d.year}-${d.month}-${d.day}'] = readingIdx;
    }
    d = d.add(const Duration(days: 1));
  }
  return map;
}

const _restDayReflections = [
  {
    "prompt": "Reflect on God's peace today.",
    "verse": "Be still, and know that I am God.",
    "reference": "Psalm 46:10"
  },
  {
    "prompt": "Find rest in Him.",
    "verse":
        "Come unto me, all ye that labour and are heavy laden, and I will give you rest.",
    "reference": "Matthew 11:28"
  },
  {
    "prompt": "Trust in His provision.",
    "verse": "The LORD is my shepherd; I shall not want.",
    "reference": "Psalm 23:1"
  },
  {
    "prompt": "Renew your strength.",
    "verse":
        "But they that wait upon the LORD shall renew their strength; they shall mount up with wings as eagles...",
    "reference": "Isaiah 40:31"
  },
  {
    "prompt": "Remember His mercies.",
    "verse":
        "It is of the LORD's mercies that we are not consumed, because his compassions fail not. They are new every morning: great is thy faithfulness.",
    "reference": "Lamentations 3:22-23"
  },
  {
    "prompt": "Rest your soul.",
    "verse":
        "Return unto thy rest, O my soul; for the LORD hath dealt bountifully with thee.",
    "reference": "Psalm 116:7"
  },
  {
    "prompt": "Cast your cares.",
    "verse": "Casting all your care upon him; for he careth for you.",
    "reference": "1 Peter 5:7"
  },
  {
    "prompt": "Abide in peace.",
    "verse": "Peace I leave with you, my peace I give unto you...",
    "reference": "John 14:27"
  },
  {
    "prompt": "Rejoice in today.",
    "verse":
        "This is the day which the LORD hath made; we will rejoice and be glad in it.",
    "reference": "Psalm 118:24"
  },
  {
    "prompt": "Wait patiently.",
    "verse": "Rest in the LORD, and wait patiently for him...",
    "reference": "Psalm 37:7"
  },
  {
    "prompt": "He is our refuge.",
    "verse": "God is our refuge and strength, a very present help in trouble.",
    "reference": "Psalm 46:1"
  },
  {
    "prompt": "Dwell in safety.",
    "verse":
        "I will both lay me down in peace, and sleep: for thou, LORD, only makest me dwell in safety.",
    "reference": "Psalm 4:8"
  },
]; // TODO: replace with curated content file

int _logicalDayForReadingDay(int readingDay, ReadingPlanState s) {
  if (s.paceMode != 'scheduled' || s.restDay == null || s.planStartedOn == null) {
    return readingDay;
  }
  final date = _dateForReadingDay(s.planStartedOn!, readingDay, s.restDay);
  return date
          .difference(DateTime.utc(s.planStartedOn!.year,
              s.planStartedOn!.month, s.planStartedOn!.day))
          .inDays +
      1;
}

int _totalLogicalDays(ReadingPlanState s) {
  if (s.paceMode != 'scheduled' || s.restDay == null || s.planStartedOn == null) {
    return s.planData.length;
  }
  final date =
      _dateForReadingDay(s.planStartedOn!, s.planData.length, s.restDay);
  return date
          .difference(DateTime.utc(s.planStartedOn!.year,
              s.planStartedOn!.month, s.planStartedOn!.day))
          .inDays +
      1;
}

int? _readingDayForLogicalDay(int logicalDay, ReadingPlanState s) {
  if (s.paceMode != 'scheduled' || s.restDay == null || s.planStartedOn == null) {
    return logicalDay;
  }
  final d = DateTime.utc(
          s.planStartedOn!.year, s.planStartedOn!.month, s.planStartedOn!.day)
      .add(Duration(days: logicalDay - 1));
  if (appWeekday(d) == s.restDay) return null; // Rest day

  int readingDay = 0;
  DateTime curr = DateTime.utc(
      s.planStartedOn!.year, s.planStartedOn!.month, s.planStartedOn!.day);
  for (int i = 0; i < logicalDay; i++) {
    if (appWeekday(curr) != s.restDay) readingDay++;
    curr = curr.add(const Duration(days: 1));
  }
  return readingDay;
}

// ─────────────────────────────────────────────────────────────────────────────
// PIECE 1 — PLAN SETUP SHEET
// ─────────────────────────────────────────────────────────────────────────────

class PlanSetupSheet extends StatefulWidget {
  final ReadingPlanState initialState;
  final bool isEditing;
  final void Function(String pace, int? restDay, bool reminderEnabled,
      int reminderHour, int reminderMinute) onConfirm;

  const PlanSetupSheet({
    super.key,
    required this.initialState,
    required this.isEditing,
    required this.onConfirm,
  });

  @override
  State<PlanSetupSheet> createState() => _PlanSetupSheetState();
}

class _PlanSetupSheetState extends State<PlanSetupSheet> {
  late String _paceMode;
  late int? _restDayChoice;
  late int? _customDay;
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    _paceMode = widget.initialState.paceMode;
    final rd = widget.initialState.restDay;
    if (rd == null || rd == -1) {
      _restDayChoice = null;
    } else if (rd == 7) {
      _restDayChoice = 7;
      _customDay = null;
    } else {
      _restDayChoice = -1; // custom
      _customDay = rd;
    }
    _reminderEnabled = widget.initialState.reminderEnabled;
    _reminderTime = TimeOfDay(
        hour: widget.initialState.reminderTimeHour,
        minute: widget.initialState.reminderTimeMinute);
  }

  int? get _effectiveRestDay {
    if (_restDayChoice == null) return null;
    if (_restDayChoice == 7) return 7;
    return _customDay;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  void _pickCustomDay() {
    showDialog<int>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Choose Rest Day'),
          children: List.generate(7, (i) {
            final dayNum = i + 1; // 1=Sun..7=Sat
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, dayNum),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(_weekdayNames[i],
                    style: const TextStyle(fontSize: 16)),
              ),
            );
          }),
        );
      },
    ).then((picked) {
      if (picked != null) {
        setState(() {
          _restDayChoice = -1;
          _customDay = picked;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = AppColors.goldAccent;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.isEditing ? 'Plan Settings' : 'Start Reading Plan',
                style: const TextStyle(
                    fontFamily: 'EB Garamond',
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text('Pace Mode',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildPaceOption('Flexible',
                  'Readings wait for you. Never fall behind.', theme, gold),
              const SizedBox(height: 8),
              _buildPaceOption(
                  'Scheduled',
                  'Each reading is tied to a date. Miss a day and you move on.',
                  theme,
                  gold),
              const SizedBox(height: 24),
              Text('Rest Day',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _restChip('Saturday', 7, theme, gold),
                  const SizedBox(width: 8),
                  _restChip('Choose…', -1, theme, gold),
                  const SizedBox(width: 8),
                  _restChip('None', null, theme, gold),
                ],
              ),
              if (_restDayChoice == -1) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickCustomDay,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: gold),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18, color: gold),
                        const SizedBox(width: 10),
                        Text(
                          _customDay != null
                              ? _weekdayNames[_customDay! - 1]
                              : 'Tap to choose a day',
                          style: TextStyle(
                              color: gold, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, color: gold),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('Daily Reminder',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Enable Reminder'),
                value: _reminderEnabled,
                onChanged: (v) => setState(() => _reminderEnabled = v),
                activeColor: gold,
                contentPadding: EdgeInsets.zero,
              ),
              if (_reminderEnabled)
                InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: gold),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 18, color: gold),
                        const SizedBox(width: 10),
                        Text(_reminderTime.format(context),
                            style: TextStyle(
                                color: gold, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Icon(Icons.edit_rounded, size: 18, color: gold),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  widget.onConfirm(
                      _paceMode,
                      _effectiveRestDay,
                      _reminderEnabled,
                      _reminderTime.hour,
                      _reminderTime.minute);
                  Navigator.pop(context);
                },
                child: Text(
                  widget.isEditing ? 'Update Settings' : 'Start Plan',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _restChip(String label, int? value, ThemeData theme, Color gold) {
    final isSelected = _restDayChoice == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (value == -1) _pickCustomDay();
          setState(() => _restDayChoice = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? gold.withValues(alpha: 0.12) : theme.cardColor,
            border: Border.all(
                color: isSelected ? gold : theme.dividerColor,
                width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? gold : theme.textTheme.bodyMedium?.color,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaceOption(
      String mode, String desc, ThemeData theme, Color gold) {
    final isSelected = _paceMode == mode.toLowerCase();
    return InkWell(
      onTap: () => setState(() => _paceMode = mode.toLowerCase()),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? gold : theme.dividerColor,
              width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? gold.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? gold : theme.disabledColor,
                size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode,
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? gold : null)),
                  const SizedBox(height: 2),
                  Text(desc, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIECE 2 — TODAY VIEW  (with real month calendar)
// ─────────────────────────────────────────────────────────────────────────────

class TodayView extends StatefulWidget {
  final ReadingPlanState planState;
  const TodayView({super.key, required this.planState});

  @override
  State<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<TodayView> {
  late DateTime _displayMonth;
  CalendarViewMode _viewMode = CalendarViewMode.month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    HapticFeedback.lightImpact();
    setState(() => _displayMonth =
        DateTime(_displayMonth.year, _displayMonth.month - 1, 1));
  }

  void _nextMonth() {
    HapticFeedback.lightImpact();
    setState(() => _displayMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 1));
  }

  void _jumpToMonth(DateTime month) {
    HapticFeedback.lightImpact();
    setState(() {
      _displayMonth = month;
      _viewMode = CalendarViewMode.month;
    });
  }

  void _setViewMode(CalendarViewMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _viewMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return _TodayViewBody(
      planState: widget.planState,
      displayMonth: _displayMonth,
      viewMode: _viewMode,
      onPrevMonth: _prevMonth,
      onNextMonth: _nextMonth,
      onJumpToMonth: _jumpToMonth,
      onSetViewMode: _setViewMode,
    );
  }
}

class _TodayViewBody extends ConsumerWidget {
  final ReadingPlanState planState;
  final DateTime displayMonth;
  final CalendarViewMode viewMode;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime) onJumpToMonth;
  final void Function(CalendarViewMode) onSetViewMode;

  const _TodayViewBody({
    required this.planState,
    required this.displayMonth,
    required this.viewMode,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onJumpToMonth,
    required this.onSetViewMode,
  });

  void _openSettings(
      BuildContext context, WidgetRef ref, ReadingPlanState planState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanSetupSheet(
        initialState: planState,
        isEditing: true,
        onConfirm: (pace, rest, remEnabled, remH, remM) {
          ref
              .read(readingPlanProvider(planState.planId).notifier)
              .setPaceMode(pace);
          ref
              .read(readingPlanProvider(planState.planId).notifier)
              .setRestDay(rest);
          ref
              .read(readingPlanProvider(planState.planId).notifier)
              .setReminder(remEnabled, remH, remM);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gold = AppColors.goldAccent;
    final today = planState.todayReadingDay;
    final percent = (planState.percentComplete * 100).toInt();
    final realNow = DateTime.now();

    final scheduledMap = planState.paceMode == 'scheduled'
        ? _buildDateToReadingMap(planState)
        : <String, int>{};

    final isScheduled = planState.paceMode == 'scheduled';

    final appThemeMode = ref.watch(themeProvider);

    Color getThemeBackgroundColor() {
      switch (appThemeMode) {
        case AppThemeMode.dawn:
          return AppColors.dawnBackground;
        case AppThemeMode.lilies:
          return AppColors.liliesBackground;
        case AppThemeMode.roses:
          return AppColors.rosesBackground;
        case AppThemeMode.olives:
          return AppColors.olivesBackground;
        case AppThemeMode.dusk:
          return const Color(0xFF312C51);
        case AppThemeMode.fresh:
          return const Color(0xFF132C33);
        default:
          return theme.scaffoldBackgroundColor;
      }
    }

    return Scaffold(
      backgroundColor: getThemeBackgroundColor(),
      appBar: SharedAppBar(
        title: const Text('Reading Plan',
            style: TextStyle(fontFamily: 'EB Garamond', fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Plan Settings',
            onPressed: () => _openSettings(context, ref, planState),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: planState.percentComplete,
                    strokeWidth: 9,
                    backgroundColor: gold.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(gold),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('$percent%',
                      style: TextStyle(
                          fontFamily: 'EB Garamond',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: gold)),
                  Text('Complete', style: theme.textTheme.labelSmall),
                ]),
              ],
            ),
            const SizedBox(height: 24),
            if (today != null)
              Builder(builder: (ctx) {
                final dayData = planState.planData[today - 1];
                final summary =
                    dayData.passages.map((p) => _expandLabel(p)).join(', ');
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DayView(
                                planId: planState.planId, dayNum: today)));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: gold.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Chronological Bible in a Year',
                                    style: TextStyle(
                                        fontFamily: 'EB Garamond',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: gold)),
                                const SizedBox(height: 4),
                                Text('${dayData.title}: $summary',
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ]),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: gold),
                      ],
                    ),
                  ),
                );
              }),
            if (planState.paceMode == 'scheduled' &&
                planState.missedDays.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.history_rounded, size: 16),
                label: Text('Catch up · Day ${planState.oldestUnread}'),
                style: TextButton.styleFrom(
                    foregroundColor: theme.textTheme.bodyMedium?.color),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DayView(
                              planId: planState.planId,
                              dayNum: planState.oldestUnread)));
                },
              ),
            ],
            const SizedBox(height: 28),
            _AdaptivePlanCalendar(
              planState: planState,
              displayMonth: displayMonth,
              viewMode: viewMode,
              onPrevMonth: onPrevMonth,
              onNextMonth: onNextMonth,
              onJumpToMonth: onJumpToMonth,
              onSetViewMode: onSetViewMode,
              scheduledMap: scheduledMap,
              realToday: realNow,
              isScheduled: isScheduled,
              gold: gold,
              theme: theme,
              onDayTap: (dayNum) {
                HapticFeedback.selectionClick();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DayView(planId: planState.planId, dayNum: dayNum)));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanMonthCalendar extends StatelessWidget {
  final ReadingPlanState planState;
  final DateTime displayMonth;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final Map<String, int> scheduledMap;
  final DateTime realToday;
  final bool isScheduled;
  final Color gold;
  final void Function(int dayNum) onDayTap;

  const _PlanMonthCalendar({
    required this.planState,
    required this.displayMonth,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.scheduledMap,
    required this.realToday,
    required this.isScheduled,
    required this.gold,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int year = displayMonth.year;
    final int month = displayMonth.month;
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int firstDayDart = DateTime(year, month, 1).weekday;
    final int firstDaySundayFirst = firstDayDart % 7;
    final int? restDay = planState.restDay;

    return Container(
      color: Colors.transparent, // required for GestureDetector
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: onPrevMonth,
                  color: gold),
              Text('${_monthNames[month - 1]} $year',
                  style: TextStyle(
                      fontFamily: 'EB Garamond',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: gold)),
              IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: onNextMonth,
                  color: gold),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
                7,
                (i) => Expanded(
                      child: Center(
                        child: Text(
                          _weekdayShort[i][0],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: i == 0
                                ? gold.withValues(alpha: 0.7)
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
          ),
          const SizedBox(height: 0),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 1.0,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              DateTime cellDate;
              bool isCurrentMonth = true;

              if (index < firstDaySundayFirst) {
                isCurrentMonth = false;
                cellDate =
                    DateTime(year, month, 1 - (firstDaySundayFirst - index));
              } else if (index >= firstDaySundayFirst + daysInMonth) {
                isCurrentMonth = false;
                cellDate =
                    DateTime(year, month, index - firstDaySundayFirst + 1);
              } else {
                cellDate =
                    DateTime(year, month, index - firstDaySundayFirst + 1);
              }

              final isRealToday = cellDate.year == realToday.year &&
                  cellDate.month == realToday.month &&
                  cellDate.day == realToday.day;
              final cellAppWeekday = appWeekday(cellDate);
              final isRestDay = restDay != null && cellAppWeekday == restDay;

              int? readingDay;
              if (isScheduled && isCurrentMonth) {
                readingDay = scheduledMap[
                    '${cellDate.year}-${cellDate.month}-${cellDate.day}'];
              }

              return _DayCell(
                dayNum: cellDate.day,
                isRealToday: isRealToday,
                isRestDay: isRestDay,
                readingDay: readingDay,
                isCompleted: readingDay != null &&
                    planState.completedReadings.contains(readingDay),
                isMissed: readingDay != null &&
                    planState.missedDays.contains(readingDay),
                isToday: readingDay != null &&
                    readingDay == planState.todayReadingDay,
                isScheduled: isScheduled,
                isCurrentMonth: isCurrentMonth,
                gold: gold,
                theme: theme,
                onTap: (readingDay != null && isCurrentMonth)
                    ? () => onDayTap(readingDay!)
                    : null,
              );
            },
          ),
          if (!isScheduled) ...[
            const SizedBox(height: 16),
            Text('Flexible mode: dates assigned as you read.',
                style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int dayNum;
  final bool isRealToday;
  final bool isRestDay;
  final int? readingDay;
  final bool isCompleted;
  final bool isMissed;
  final bool isToday;
  final bool isScheduled;
  final bool isCurrentMonth;
  final Color gold;
  final ThemeData theme;
  final VoidCallback? onTap;

  const _DayCell({
    required this.dayNum,
    required this.isRealToday,
    required this.isRestDay,
    required this.readingDay,
    required this.isCompleted,
    required this.isMissed,
    required this.isToday,
    required this.isScheduled,
    required this.isCurrentMonth,
    required this.gold,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? circleBg;
    Color? circleBorder;
    Color textColor = theme.colorScheme.onSurface;
    Widget? indicator;

    if (!isCurrentMonth) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.15);
      if (isRestDay) {
        circleBorder = gold.withValues(alpha: 0.1);
      }
    } else {
      if (isRealToday && !isRestDay) {
        circleBg = gold;
        textColor = theme.colorScheme.surface; // high contrast on gold
      } else if (isCompleted) {
        circleBg = gold.withValues(alpha: 0.2);
        textColor = gold;
        indicator = Icon(Icons.check_rounded, size: 10, color: gold);
      } else if (isToday && isScheduled) {
        circleBorder = gold;
        textColor = gold;
      } else if (isMissed) {
        circleBorder = theme.colorScheme.onSurface.withValues(alpha: 0.4);
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
      } else if (isRestDay) {
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.35);
        circleBorder =
            gold.withValues(alpha: 0.3); // Subtle border for rest day
      } else if (readingDay != null) {
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.85);
      }
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
              border: circleBorder != null
                  ? Border.all(color: circleBorder, width: 1.5)
                  : null,
            ),
            child: Center(
              child: isRestDay
                  ? Icon(Icons.self_improvement_rounded,
                      size: 14,
                      color: isCurrentMonth
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.15))
                  : Text('$dayNum',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
            ),
          ),
          if (indicator != null) ...[
            const SizedBox(height: 2),
            indicator,
          ] else if (readingDay != null &&
              !isCompleted &&
              !isRestDay &&
              isCurrentMonth)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
            ),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIECE 3 — DAY VIEW
// ─────────────────────────────────────────────────────────────────────────────

class DayView extends ConsumerStatefulWidget {
  final String planId;
  final int dayNum;
  const DayView({super.key, required this.planId, required this.dayNum});

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late ConfettiController _confettiController;
  late int _currentLogicalDay;
  late int _totalLogicalDaysCount;

  // Calendar State
  late DateTime _displayMonth;
  CalendarViewMode _viewMode = CalendarViewMode.month;

  @override
  void initState() {
    super.initState();
    final planState = ref.read(readingPlanProvider(widget.planId));
    _currentLogicalDay = _logicalDayForReadingDay(widget.dayNum, planState);
    _totalLogicalDaysCount = _totalLogicalDays(planState);
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    HapticFeedback.lightImpact();
    setState(() => _displayMonth =
        DateTime(_displayMonth.year, _displayMonth.month - 1, 1));
  }

  void _nextMonth() {
    HapticFeedback.lightImpact();
    setState(() => _displayMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 1));
  }

  void _jumpToMonth(DateTime month) {
    HapticFeedback.lightImpact();
    setState(() {
      _displayMonth = month;
      _viewMode = CalendarViewMode.month;
    });
  }

  void _setViewMode(CalendarViewMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _viewMode = mode);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _nextDay() {
    if (_currentLogicalDay < _totalLogicalDaysCount) {
      HapticFeedback.lightImpact();
      _glowController.reset();
      setState(() => _currentLogicalDay++);
    }
  }

  void _prevDay() {
    if (_currentLogicalDay > 1) {
      HapticFeedback.lightImpact();
      _glowController.reset();
      setState(() => _currentLogicalDay--);
    }
  }

  void _toggleDone(bool isDone, int readingDay) {
    if (!isDone) {
      HapticFeedback.mediumImpact();
      _glowController.forward().then((_) => _glowController.reverse());

      final previousCompleted =
          ref.read(readingPlanProvider(widget.planId)).completedReadings;
      ref
          .read(readingPlanProvider(widget.planId).notifier)
          .markReadingComplete(readingDay);
      final newCompleted =
          ref.read(readingPlanProvider(widget.planId)).completedReadings;
      final planData = ref.read(readingPlanProvider(widget.planId)).planData;

      final celebrations =
          celebrationMilestones(previousCompleted, newCompleted, planData);

      if (celebrations.isNotEmpty) {
        _confettiController.play();
        debugPrint('Celebrations triggered: $celebrations');

        if (celebrations.contains('Plan 100% complete') && mounted) {
          String planTitle = 'Custom Plan';
          if (widget.planId == 'chronological_1yr') {
            planTitle = 'Chronological Bible in a Year';
          } else if (widget.planId == 'great_controversy') {
            planTitle = 'The Great Controversy';
          } else if (widget.planId == 'prophetic_timeline') {
            planTitle = 'Prophetic Timeline';
          } else {
            final customPlan =
                ref.read(preferencesProvider).getCustomPlan(widget.planId);
            if (customPlan != null) {
              planTitle = customPlan['title'] ?? 'Custom Plan';
            }
          }

          showDialog(
            context: context,
            builder: (c) => CupertinoAlertDialog(
              title: const Text('Congratulations! 🎉'),
              content: Text('You\'ve completed $planTitle! Well done.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(c),
                ),
              ],
            ),
          );
        }
      }
    } else {
      HapticFeedback.lightImpact();
      ref
          .read(readingPlanProvider(widget.planId).notifier)
          .markReadingIncomplete(readingDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(readingPlanProvider(widget.planId));
    if (planState.planData.isEmpty ||
        _currentLogicalDay < 1 ||
        _currentLogicalDay > _totalLogicalDaysCount) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final readingDay = _readingDayForLogicalDay(_currentLogicalDay, planState);
    final isRestDay = readingDay == null;
    final theme = Theme.of(context);
    final gold = AppColors.goldAccent;

    final navBar = SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: 32,
              padding: const EdgeInsets.all(12),
              icon: const Icon(Icons.chevron_left_rounded),
              color: gold,
              disabledColor: theme.disabledColor,
              onPressed: _currentLogicalDay > 1 ? _prevDay : null,
            ),
            Text(
              isRestDay
                  ? 'Rest Day'
                  : '${planState.paceMode == 'scheduled' ? 'Reading' : 'Day'} $readingDay of ${planState.planData.length}',
              style: theme.textTheme.titleMedium?.copyWith(
                letterSpacing: 0.8,
                color: gold.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              iconSize: 32,
              padding: const EdgeInsets.all(12),
              icon: const Icon(Icons.chevron_right_rounded),
              color: gold,
              disabledColor: theme.disabledColor,
              onPressed:
                  _currentLogicalDay < _totalLogicalDaysCount ? _nextDay : null,
            ),
          ],
        ),
      ),
    );

    final appThemeMode = ref.watch(themeProvider);

    Color getThemeBackgroundColor() {
      switch (appThemeMode) {
        case AppThemeMode.dawn:
          return AppColors.dawnBackground;
        case AppThemeMode.lilies:
          return AppColors.liliesBackground;
        case AppThemeMode.roses:
          return AppColors.rosesBackground;
        case AppThemeMode.olives:
          return AppColors.olivesBackground;
        case AppThemeMode.dusk:
          return const Color(0xFF312C51);
        case AppThemeMode.fresh:
          return const Color(0xFF132C33);
        default:
          return theme.scaffoldBackgroundColor;
      }
    }

    if (isRestDay) {
      final date = DateTime.utc(planState.planStartedOn!.year,
              planState.planStartedOn!.month, planState.planStartedOn!.day)
          .add(Duration(days: _currentLogicalDay - 1));
      final dateHeader =
          '${_weekdayShort[date.weekday - 1]}, ${_monthNamesShort[date.month - 1]} ${date.day}, ${date.year}';

      String? weekTitle;
      final prevReadingDay =
          _readingDayForLogicalDay(_currentLogicalDay - 1, planState);
      if (prevReadingDay != null &&
          prevReadingDay >= 1 &&
          prevReadingDay <= planState.planData.length) {
        weekTitle = planState.planData[prevReadingDay - 1].title;
      }

      final weekIndex = ((_currentLogicalDay - 1) / 7).floor();
      final reflection =
          _restDayReflections[weekIndex % _restDayReflections.length];

      return Scaffold(
        backgroundColor: getThemeBackgroundColor(),
        extendBodyBehindAppBar: true,
        appBar: SharedAppBar(
            title: const Text(''),
            backgroundColor: Colors.transparent,
            elevation: 0),
        bottomNavigationBar: navBar,
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! < -300.0) {
              _nextDay();
            } else if (details.primaryVelocity! > 300.0) {
              _prevDay();
            }
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(dateHeader,
                    style: theme.textTheme.labelMedium?.copyWith(
                        letterSpacing: 1.1,
                        color: gold.withValues(alpha: 0.8))),
                const SizedBox(height: 16),
                const Text('Rest & Reflect',
                    style: TextStyle(
                        fontFamily: 'EB Garamond',
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                if (weekTitle != null) ...[
                  const SizedBox(height: 12),
                  Text("You've journeyed through:\n$weekTitle",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6))),
                ],
                const SizedBox(height: 48),
                Text(reflection['prompt']!,
                    style: theme.textTheme.titleMedium?.copyWith(color: gold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Text('“${reflection['verse']!}”',
                    style: const TextStyle(
                        fontFamily: 'EB Garamond',
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        height: 1.3),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(reflection['reference']!,
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
                const SizedBox(height: 64),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: gold,
                    side: BorderSide(color: gold.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(streakProvider.notifier).markReadToday();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Streak maintained!'),
                      backgroundColor: gold.withValues(alpha: 0.9),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  child: const Text('I reflected today',
                      style: TextStyle(letterSpacing: 1.0)),
                ),
                const SizedBox(height: 48),
                _AdaptivePlanCalendar(
                  planState: planState,
                  displayMonth: _displayMonth,
                  viewMode: _viewMode,
                  onPrevMonth: _prevMonth,
                  onNextMonth: _nextMonth,
                  onJumpToMonth: _jumpToMonth,
                  onSetViewMode: _setViewMode,
                  scheduledMap: planState.paceMode == 'scheduled'
                      ? _buildDateToReadingMap(planState)
                      : <String, int>{},
                  realToday: DateTime.now(),
                  isScheduled: planState.paceMode == 'scheduled',
                  gold: gold,
                  theme: theme,
                  onDayTap: (dayNum) {
                    HapticFeedback.selectionClick();
                    final logicalDay =
                        _logicalDayForReadingDay(dayNum, planState);
                    setState(() => _currentLogicalDay = logicalDay);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dayData = planState.planData[readingDay - 1];
    final isDone = planState.completedReadings.contains(readingDay);

    String dateHeader = 'Reading $readingDay';
    if (planState.paceMode == 'scheduled' && planState.planStartedOn != null) {
      final d = DateTime.utc(planState.planStartedOn!.year,
              planState.planStartedOn!.month, planState.planStartedOn!.day)
          .add(Duration(days: _currentLogicalDay - 1));
      dateHeader =
          '${_weekdayShort[d.weekday - 1]}, ${_monthNamesShort[d.month - 1]} ${d.day}, ${d.year}';
    }

    // ── Derive plan display name ──────────────────────────────────────────────
    String planDisplayName;
    String planSubtitle;
    if (widget.planId == 'chronological_1yr') {
      planDisplayName = 'Chronological Bible in a Year';
      planSubtitle = 'Guthrie · Read the Bible for Life · 52 wks';
    } else if (widget.planId == 'great_controversy') {
      planDisplayName = 'The Great Controversy';
      planSubtitle = 'Ellen G. White';
    } else if (widget.planId == 'prophetic_timeline') {
      planDisplayName = 'Prophetic Timeline';
      planSubtitle = '';
    } else {
      final customPlan =
          ref.read(preferencesProvider).getCustomPlan(widget.planId);
      planDisplayName = customPlan?['title'] ?? 'Reading Plan';
      planSubtitle = '';
    }

    final progressPct =
        (planState.percentComplete * 100).toStringAsFixed(1);

    // ── Passage subtitle line ─────────────────────────────────────────────────
    final passageSubtitle =
        dayData.passages.map((p) => _expandLabel(p)).join(' · ');

    return Scaffold(
      backgroundColor: getThemeBackgroundColor(),
      extendBodyBehindAppBar: true,
      // Transparent app bar — back arrow left, settings gear right
      appBar: SharedAppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded,
                color: gold.withValues(alpha: 0.8)),
            onPressed: () {},
            tooltip: 'Plan Settings',
          ),
        ],
      ),
      // Bottom nav: Reading X of Y with prev/next
      bottomNavigationBar: navBar,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -300.0) {
            _nextDay();
          } else if (details.primaryVelocity! > 300.0) {
            _prevDay();
          }
        },
        child: Stack(
          children: [
            // ── Main scrollable body ──────────────────────────────────────────
            ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── HERO HEADER — editorial title zone ───────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        gold.withValues(alpha: 0.13),
                        gold.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 48,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Eyebrow date label
                      Text(
                        dateHeader.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.4,
                          color: gold.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Large expressive plan-section title
                      Text(
                        dayData.title,
                        style: const TextStyle(
                          fontFamily: 'EB Garamond',
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      // Passage subtitle — more visible with checkbox
                      GestureDetector(
                        onTap: () => _toggleDone(isDone, readingDay),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isDone
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: gold,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              passageSubtitle,
                              style: TextStyle(
                                fontFamily: 'EB Garamond',
                                color: gold,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── MARK AS READ — full-width primary CTA ────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _glowAnimation.value > 0
                            ? [
                                BoxShadow(
                                  color: gold.withValues(
                                      alpha: 0.55 * _glowAnimation.value),
                                  blurRadius: 22 * _glowAnimation.value,
                                  spreadRadius: 4 * _glowAnimation.value,
                                )
                              ]
                            : [],
                      ),
                      child: child,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDone ? gold : theme.cardColor,
                          foregroundColor: isDone ? Colors.white : gold,
                          side: isDone
                              ? BorderSide.none
                              : BorderSide(color: gold, width: 2),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: isDone ? 3 : 0,
                        ),
                        onPressed: () async {
                          final markedComplete = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlanReaderScreen(
                                planId: widget.planId,
                                dayNum: readingDay,
                                initialPassageIndex: 0,
                              ),
                            ),
                          );
                          if (markedComplete == true && mounted) {
                            final isDoneNow = ref
                                .read(readingPlanProvider(widget.planId))
                                .completedReadings
                                .contains(readingDay);
                            if (!isDoneNow) {
                              _toggleDone(false, readingDay);
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 22),
                            const SizedBox(width: 10),
                            const Text(
                              'START READING',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Passage tap-cards — compact row under the CTA ────────────
                if (dayData.passages.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Column(
                      children: dayData.passages.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final passage = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () async {
                                final markedComplete =
                                    await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlanReaderScreen(
                                      planId: widget.planId,
                                      dayNum: readingDay,
                                      initialPassageIndex: entry.key,
                                    ),
                                  ),
                                );
                                if (markedComplete == true && mounted) {
                                  final isDoneNow = ref
                                      .read(readingPlanProvider(
                                          widget.planId))
                                      .completedReadings
                                      .contains(readingDay);
                                  if (!isDoneNow) {
                                    _toggleDone(false, readingDay);
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: theme.dividerColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              gold.withValues(alpha: 0.12)),
                                      child: Center(
                                          child: Text('$idx',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: gold))),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Text(_expandLabel(passage),
                                            style: const TextStyle(
                                                fontFamily: 'EB Garamond',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600))),
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        size: 12,
                                        color: gold.withValues(alpha: 0.5)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // ── CALENDAR — HERO section ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _AdaptivePlanCalendar(
                    planState: planState,
                    displayMonth: _displayMonth,
                    viewMode: _viewMode,
                    onPrevMonth: _prevMonth,
                    onNextMonth: _nextMonth,
                    onJumpToMonth: _jumpToMonth,
                    onSetViewMode: _setViewMode,
                    scheduledMap: planState.paceMode == 'scheduled'
                        ? _buildDateToReadingMap(planState)
                        : <String, int>{},
                    realToday: DateTime.now(),
                    isScheduled: planState.paceMode == 'scheduled',
                    gold: gold,
                    theme: theme,
                    onDayTap: (dayNum) {
                      HapticFeedback.selectionClick();
                      final logicalDay =
                          _logicalDayForReadingDay(dayNum, planState);
                      setState(() => _currentLogicalDay = logicalDay);
                    },
                  ),
                ),

                // ── PLAN INFO — compact footer strip ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Row(
                    children: [
                      Icon(Icons.auto_stories_rounded,
                          size: 14, color: gold.withValues(alpha: 0.5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: planDisplayName,
                                style: TextStyle(
                                  fontFamily: 'EB Garamond',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: gold.withValues(alpha: 0.8),
                                ),
                              ),
                              if (planSubtitle.isNotEmpty)
                                TextSpan(
                                  text: '  ·  $planSubtitle',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$progressPct%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: gold.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Confetti overlay ──────────────────────────────────────────────
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [gold, gold.withValues(alpha: 0.8), Colors.white],
                emissionFrequency: 0.05,
                numberOfParticles: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT — Reading Plan Browser (router widget)
// ─────────────────────────────────────────────────────────────────────────────

enum CalendarViewMode { week, month, year }

class ReadingPlanBrowser extends ConsumerStatefulWidget {
  final String planId;
  const ReadingPlanBrowser({super.key, required this.planId});

  @override
  ConsumerState<ReadingPlanBrowser> createState() => _ReadingPlanBrowserState();
}

class _ReadingPlanBrowserState extends ConsumerState<ReadingPlanBrowser> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(readingPlanProvider(widget.planId));
    final gold = AppColors.goldAccent;
    final appThemeMode = ref.watch(themeProvider);

    Color getThemeBackgroundColor() {
      switch (appThemeMode) {
        case AppThemeMode.dawn:
          return AppColors.dawnBackground;
        case AppThemeMode.lilies:
          return AppColors.liliesBackground;
        case AppThemeMode.roses:
          return AppColors.rosesBackground;
        case AppThemeMode.olives:
          return AppColors.olivesBackground;
        case AppThemeMode.dusk:
          return const Color(0xFF312C51);
        case AppThemeMode.fresh:
          return const Color(0xFF132C33);
        default:
          return Theme.of(context).scaffoldBackgroundColor;
      }
    }

    if (planState.isLoading) {
      return Scaffold(
          body: Center(child: CircularProgressIndicator(color: gold)));
    }

    if (!planState.isActive) {
      return Scaffold(
        backgroundColor: getThemeBackgroundColor(),
        appBar: const SharedAppBar(
            title: Text('Reading Plan',
                style: TextStyle(fontFamily: 'EB Garamond'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded,
                    size: 64, color: gold.withValues(alpha: 0.4)),
                const SizedBox(height: 24),
                const Text('Chronological Bible in a Year',
                    style: TextStyle(
                        fontFamily: 'EB Garamond',
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Read through the Bible in the order events occurred.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => PlanSetupSheet(
                        initialState: planState,
                        isEditing: false,
                        onConfirm: (pace, rest, remEnabled, remH, remM) {
                          ref
                              .read(readingPlanProvider(widget.planId).notifier)
                              .startPlan(
                                planId: widget.planId,
                                paceMode: pace,
                                restDay: rest,
                              );
                          ref
                              .read(readingPlanProvider(widget.planId).notifier)
                              .setReminder(remEnabled, remH, remM);
                          _confettiController.play();
                        },
                      ),
                    );
                  },
                  child: const Text('Begin Plan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (widget.planId == 'chronological_1yr') {
      return JourneyMapScreen(planId: widget.planId);
    }
    
    return DayView(
      planId: widget.planId,
      dayNum: planState.currentDay > 0 ? planState.currentDay : 1,
    );
  }
}

class _AdaptivePlanCalendar extends ConsumerWidget {
  final ReadingPlanState planState;
  final DateTime displayMonth;
  final CalendarViewMode viewMode;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime) onJumpToMonth;
  final void Function(CalendarViewMode) onSetViewMode;
  final Map<String, int> scheduledMap;
  final DateTime realToday;
  final bool isScheduled;
  final Color gold;
  final ThemeData theme;
  final void Function(int dayNum) onDayTap;

  const _AdaptivePlanCalendar({
    required this.planState,
    required this.displayMonth,
    required this.viewMode,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onJumpToMonth,
    required this.onSetViewMode,
    required this.scheduledMap,
    required this.realToday,
    required this.isScheduled,
    required this.gold,
    required this.theme,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaceStyle = ref.watch(surfaceStyleProvider);
    final is3D = surfaceStyle == SurfaceStyle.threeDimensional || surfaceStyle == SurfaceStyle.depth3D || surfaceStyle == SurfaceStyle.skeuomorphic;

    final totalDays = planState.planData.length;

    Widget calendarWidget;
    if (totalDays <= 14) {
      calendarWidget = _PlanCompactCalendar(
        planState: planState,
        gold: gold,
        theme: theme,
        onDayTap: onDayTap,
      );
    } else if (totalDays <= 90) {
      calendarWidget = GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -300.0) {
            onNextMonth();
          } else if (details.primaryVelocity! > 300.0) {
            onPrevMonth();
          }
        },
        child: _PlanMonthCalendar(
          planState: planState,
          displayMonth: displayMonth,
          onPrevMonth: onPrevMonth,
          onNextMonth: onNextMonth,
          scheduledMap: scheduledMap,
          realToday: realToday,
          isScheduled: isScheduled,
          gold: gold,
          onDayTap: onDayTap,
        ),
      );
    } else {
      final startedOn = planState.planStartedOn ?? DateTime.now();
      int currentMonthNum = (displayMonth.year - startedOn.year) * 12 +
          displayMonth.month -
          startedOn.month +
          1;
      if (currentMonthNum < 1) currentMonthNum = 1;

      final totalMonths =
          (totalDays / (planState.restDay != null ? 26 : 30)).ceil();
      final displayTotalMonths =
          totalMonths > 12 && totalDays <= 366 ? 12 : totalMonths;
      final pct = totalDays > 0
          ? (planState.completedReadings.length / totalDays * 100)
              .toStringAsFixed(1)
          : '0.0';

      calendarWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Month $currentMonthNum of $displayTotalMonths · $pct% complete',
                style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              ToggleButtons(
                isSelected: [
                  viewMode == CalendarViewMode.week,
                  viewMode == CalendarViewMode.month,
                  viewMode == CalendarViewMode.year,
                ],
                onPressed: (index) {
                  if (index == 0) {
                    onSetViewMode(CalendarViewMode.week);
                  } else if (index == 1) {
                    onSetViewMode(CalendarViewMode.month);
                  } else {
                    onSetViewMode(CalendarViewMode.year);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                constraints: const BoxConstraints(minHeight: 28, minWidth: 48),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                selectedColor: gold,
                fillColor: gold.withValues(alpha: 0.15),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Week',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Month',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Year',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (viewMode == CalendarViewMode.year)
            _PlanYearCalendar(
              planState: planState,
              startedOn: startedOn,
              currentDisplayMonth: displayMonth,
              gold: gold,
              theme: theme,
              onMonthTap: onJumpToMonth,
            )
          else if (viewMode == CalendarViewMode.week)
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < -300.0) {
                  onNextMonth();
                } else if (details.primaryVelocity! > 300.0) {
                  onPrevMonth();
                }
              },
              child: _PlanWeekCalendar(
                planState: planState,
                displayDate: displayMonth,
                onPrevWeek: onPrevMonth, // reusing the month callbacks for now to navigate time
                onNextWeek: onNextMonth,
                scheduledMap: scheduledMap,
                realToday: realToday,
                isScheduled: isScheduled,
                gold: gold,
                onDayTap: onDayTap,
              ),
            )
          else
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < -300.0) {
                  onNextMonth();
                } else if (details.primaryVelocity! > 300.0) {
                  onPrevMonth();
                }
              },
              child: _PlanMonthCalendar(
                planState: planState,
                displayMonth: displayMonth,
                onPrevMonth: onPrevMonth,
                onNextMonth: onNextMonth,
                scheduledMap: scheduledMap,
                realToday: realToday,
                isScheduled: isScheduled,
                gold: gold,
                onDayTap: onDayTap,
              ),
            ),
        ],
      );
    }

    if (is3D) {
      return TexturedGlassContainer(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: calendarWidget,
      );
    }
    return calendarWidget;
  }
}

class _PlanCompactCalendar extends StatelessWidget {
  final ReadingPlanState planState;
  final Color gold;
  final ThemeData theme;
  final void Function(int dayNum) onDayTap;

  const _PlanCompactCalendar({
    required this.planState,
    required this.gold,
    required this.theme,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Full Plan View',
            style: TextStyle(
                fontFamily: 'EB Garamond',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: planState.planData.length,
            itemBuilder: (context, index) {
              final readingDay = index + 1;
              final isCompleted =
                  planState.completedReadings.contains(readingDay);
              final isMissed = planState.missedDays.contains(readingDay);
              final isToday = planState.todayReadingDay == readingDay;

              Color? circleBg;
              Color? circleBorder;
              Color textColor = theme.colorScheme.onSurface;
              Widget? indicator;

              if (isCompleted) {
                circleBg = gold.withValues(alpha: 0.2);
                textColor = gold;
                indicator = Icon(Icons.check_rounded, size: 10, color: gold);
              } else if (isToday) {
                circleBg = gold;
                textColor = theme.colorScheme.surface;
              } else if (isMissed) {
                circleBorder =
                    theme.colorScheme.onSurface.withValues(alpha: 0.4);
                textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
              } else {
                textColor = theme.colorScheme.onSurface.withValues(alpha: 0.85);
              }

              return GestureDetector(
                onTap: () => onDayTap(readingDay),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: circleBg,
                        shape: BoxShape.circle,
                        border: circleBorder != null
                            ? Border.all(color: circleBorder, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$readingDay',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor),
                        ),
                      ),
                    ),
                    if (indicator != null) ...[
                      const SizedBox(height: 4),
                      indicator,
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlanYearCalendar extends StatelessWidget {
  final ReadingPlanState planState;
  final DateTime startedOn;
  final DateTime currentDisplayMonth;
  final Color gold;
  final ThemeData theme;
  final void Function(DateTime) onMonthTap;

  const _PlanYearCalendar({
    required this.planState,
    required this.startedOn,
    required this.currentDisplayMonth,
    required this.gold,
    required this.theme,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final targetMonth =
            DateTime(startedOn.year, startedOn.month + index, 1);

        final isCurrentMonth =
            targetMonth.year == now.year && targetMonth.month == now.month;
        final isPast = targetMonth.isBefore(DateTime(now.year, now.month, 1));
        final isSelected = targetMonth.year == currentDisplayMonth.year &&
            targetMonth.month == currentDisplayMonth.month;

        Color bgColor = theme.colorScheme.surface;
        Color textColor = theme.colorScheme.onSurface;
        Color borderColor = theme.dividerColor.withValues(alpha: 0.3);

        if (isSelected) {
          borderColor = gold;
          bgColor = gold.withValues(alpha: 0.1);
          textColor = gold;
        } else if (isCurrentMonth) {
          borderColor = gold.withValues(alpha: 0.5);
          textColor = gold;
        } else if (isPast) {
          bgColor = theme.colorScheme.onSurface.withValues(alpha: 0.05);
          textColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
        }

        return GestureDetector(
          onTap: () => onMonthTap(targetMonth),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    months[targetMonth.month - 1],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${targetMonth.year}',
                    style: TextStyle(
                        fontSize: 11, color: textColor.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlanWeekCalendar extends StatelessWidget {
  final ReadingPlanState planState;
  final DateTime displayDate;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final Map<String, int> scheduledMap;
  final DateTime realToday;
  final bool isScheduled;
  final Color gold;
  final void Function(int dayNum) onDayTap;

  const _PlanWeekCalendar({
    required this.planState,
    required this.displayDate,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.scheduledMap,
    required this.realToday,
    required this.isScheduled,
    required this.gold,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int year = displayDate.year;
    final int month = displayDate.month;
    final int? restDay = planState.restDay;

    // Find the Sunday of the current week
    final int currentWeekday = displayDate.weekday; // 1=Mon, 7=Sun
    final int daysToSubtract = currentWeekday == 7 ? 0 : currentWeekday;
    final DateTime startOfWeek = displayDate.subtract(Duration(days: daysToSubtract));

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: onPrevWeek,
                  color: gold),
              Text('${_monthNames[month - 1]} $year',
                  style: TextStyle(
                      fontFamily: 'EB Garamond',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: gold)),
              IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: onNextWeek,
                  color: gold),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
                7,
                (i) => Expanded(
                      child: Center(
                        child: Text(
                          _weekdayShort[i][0],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: i == 0
                                ? gold.withValues(alpha: 0.7)
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
          ),
          const SizedBox(height: 0),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 1.0,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              final cellDate = startOfWeek.add(Duration(days: index));
              
              final isCurrentMonth = cellDate.month == month;
              
              final isRealToday = cellDate.year == realToday.year &&
                  cellDate.month == realToday.month &&
                  cellDate.day == realToday.day;
              final cellAppWeekday = appWeekday(cellDate);
              final isRestDay = restDay != null && cellAppWeekday == restDay;

              int? readingDay;
              if (isScheduled && isCurrentMonth) {
                readingDay = scheduledMap[
                    '${cellDate.year}-${cellDate.month}-${cellDate.day}'];
              } else if (isScheduled) {
                readingDay = scheduledMap[
                    '${cellDate.year}-${cellDate.month}-${cellDate.day}'];
              }

              return _DayCell(
                dayNum: cellDate.day,
                isRealToday: isRealToday,
                isRestDay: isRestDay,
                readingDay: readingDay,
                isCompleted: readingDay != null &&
                    planState.completedReadings.contains(readingDay),
                isMissed: readingDay != null &&
                    planState.missedDays.contains(readingDay),
                isToday: readingDay != null &&
                    readingDay == planState.todayReadingDay,
                isScheduled: isScheduled,
                isCurrentMonth: isCurrentMonth, 
                theme: theme,
                gold: gold,
                onTap: (readingDay != null)
                    ? () => onDayTap(readingDay!)
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
