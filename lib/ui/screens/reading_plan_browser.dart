// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../state/reading_plan_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/shared_app_bar.dart';
import 'plan_reader_screen.dart';
import '../../state/streak_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import 'package:flutter/cupertino.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

String _expandLabel(PlanPassage p) {
  if (p.refs.isEmpty) return p.label;
  final match = RegExp(r'^([1-3]?\s?[a-zA-Z\s]+?)\s\d').firstMatch(p.refs.first);
  final bookName = match != null ? match.group(1)! : p.refs.first;
  return p.label.replaceFirst(RegExp(r'^[1-3]?\s?[a-zA-Z]+\s?'), '$bookName ');
}

List<String> celebrationMilestones(Set<int> prev, Set<int> next, List<PlanDayData> planData) {
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
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth',
    '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles',
    'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon',
    'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi'
  };
  final ntBooks = {
    'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians',
    'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians',
    '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter',
    '1 John', '2 John', '3 John', 'Jude', 'Revelation'
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
      if (bookDays.every((d) => next.contains(d)) && !bookDays.every((d) => prev.contains(d))) {
        milestones.add('book complete: $book');
      }
    }
  }

  if (otReadings.isNotEmpty && otReadings.every((d) => next.contains(d)) && !otReadings.every((d) => prev.contains(d))) {
    milestones.add('OT complete');
  }
  
  if (ntReadings.isNotEmpty && ntReadings.every((d) => next.contains(d)) && !ntReadings.every((d) => prev.contains(d))) {
    milestones.add('NT complete');
  }

  if (next.length == planData.length && prev.length != planData.length) {
    milestones.add('Plan 100% complete');
  }

  return milestones.toSet().toList();
}

const _weekdayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
const _weekdayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'];
const _monthNamesShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

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
  DateTime d = DateTime.utc(s.planStartedOn!.year, s.planStartedOn!.month, s.planStartedOn!.day);
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
  {"prompt": "Reflect on God's peace today.", "verse": "Be still, and know that I am God.", "reference": "Psalm 46:10"},
  {"prompt": "Find rest in Him.", "verse": "Come unto me, all ye that labour and are heavy laden, and I will give you rest.", "reference": "Matthew 11:28"},
  {"prompt": "Trust in His provision.", "verse": "The LORD is my shepherd; I shall not want.", "reference": "Psalm 23:1"},
  {"prompt": "Renew your strength.", "verse": "But they that wait upon the LORD shall renew their strength; they shall mount up with wings as eagles...", "reference": "Isaiah 40:31"},
  {"prompt": "Remember His mercies.", "verse": "It is of the LORD's mercies that we are not consumed, because his compassions fail not. They are new every morning: great is thy faithfulness.", "reference": "Lamentations 3:22-23"},
  {"prompt": "Rest your soul.", "verse": "Return unto thy rest, O my soul; for the LORD hath dealt bountifully with thee.", "reference": "Psalm 116:7"},
  {"prompt": "Cast your cares.", "verse": "Casting all your care upon him; for he careth for you.", "reference": "1 Peter 5:7"},
  {"prompt": "Abide in peace.", "verse": "Peace I leave with you, my peace I give unto you...", "reference": "John 14:27"},
  {"prompt": "Rejoice in today.", "verse": "This is the day which the LORD hath made; we will rejoice and be glad in it.", "reference": "Psalm 118:24"},
  {"prompt": "Wait patiently.", "verse": "Rest in the LORD, and wait patiently for him...", "reference": "Psalm 37:7"},
  {"prompt": "He is our refuge.", "verse": "God is our refuge and strength, a very present help in trouble.", "reference": "Psalm 46:1"},
  {"prompt": "Dwell in safety.", "verse": "I will both lay me down in peace, and sleep: for thou, LORD, only makest me dwell in safety.", "reference": "Psalm 4:8"},
]; // TODO: replace with curated content file

int _logicalDayForReadingDay(int readingDay, ReadingPlanState s) {
  if (s.paceMode != 'scheduled' || s.restDay == null || s.planStartedOn == null) return readingDay;
  final date = _dateForReadingDay(s.planStartedOn!, readingDay, s.restDay);
  return date.difference(DateTime.utc(s.planStartedOn!.year, s.planStartedOn!.month, s.planStartedOn!.day)).inDays + 1;
}

int _totalLogicalDays(ReadingPlanState s) {
  if (s.paceMode != 'scheduled' || s.restDay == null || s.planStartedOn == null) return s.planData.length;
  final date = _dateForReadingDay(s.planStartedOn!, s.planData.length, s.restDay);
  return date.difference(DateTime.utc(s.planStartedOn!.year, s.planStartedOn!.month, s.planStartedOn!.day)).inDays + 1;
}

int? _readingDayForLogicalDay(int logicalDay, ReadingPlanState s) {
  if (s.paceMode != 'scheduled' || s.restDay == null || s.planStartedOn == null) return logicalDay;
  final d = DateTime.utc(s.planStartedOn!.year, s.planStartedOn!.month, s.planStartedOn!.day).add(Duration(days: logicalDay - 1));
  if (appWeekday(d) == s.restDay) return null; // Rest day
  
  int readingDay = 0;
  DateTime curr = DateTime.utc(s.planStartedOn!.year, s.planStartedOn!.month, s.planStartedOn!.day);
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
  final void Function(String pace, int? restDay, bool reminderEnabled, int reminderHour, int reminderMinute) onConfirm;

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
    _reminderTime = TimeOfDay(hour: widget.initialState.reminderTimeHour, minute: widget.initialState.reminderTimeMinute);
  }

  int? get _effectiveRestDay {
    if (_restDayChoice == null) return -1;
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
                child: Text(_weekdayNames[i], style: const TextStyle(fontSize: 16)),
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
                style: const TextStyle(fontFamily: 'EB Garamond', fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Text('Pace Mode', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildPaceOption('Flexible', 'Readings wait for you. Never fall behind.', theme, gold),
              const SizedBox(height: 8),
              _buildPaceOption('Scheduled', 'Each reading is tied to a date. Miss a day and you move on.', theme, gold),
              const SizedBox(height: 24),

              Text('Rest Day', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: gold),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: gold),
                        const SizedBox(width: 10),
                        Text(
                          _customDay != null ? _weekdayNames[_customDay! - 1] : 'Tap to choose a day',
                          style: TextStyle(color: gold, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, color: gold),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Text('Daily Reminder', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: gold),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 18, color: gold),
                        const SizedBox(width: 10),
                        Text(_reminderTime.format(context), style: TextStyle(color: gold, fontWeight: FontWeight.w600)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  widget.onConfirm(_paceMode, _effectiveRestDay, _reminderEnabled, _reminderTime.hour, _reminderTime.minute);
                  Navigator.pop(context);
                },
                child: Text(
                  widget.isEditing ? 'Update Settings' : 'Start Plan',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            border: Border.all(color: isSelected ? gold : theme.dividerColor, width: isSelected ? 2 : 1),
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

  Widget _buildPaceOption(String mode, String desc, ThemeData theme, Color gold) {
    final isSelected = _paceMode == mode.toLowerCase();
    return InkWell(
      onTap: () => setState(() => _paceMode = mode.toLowerCase()),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? gold : theme.dividerColor, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? gold.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? gold : theme.disabledColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isSelected ? gold : null)),
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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    HapticFeedback.lightImpact();
    setState(() => _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1));
  }
  
  void _nextMonth() {
    HapticFeedback.lightImpact();
    setState(() => _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1));
  }

  @override
  Widget build(BuildContext context) {
    return _TodayViewBody(
      planState: widget.planState,
      displayMonth: _displayMonth,
      onPrevMonth: _prevMonth,
      onNextMonth: _nextMonth,
    );
  }
}

class _TodayViewBody extends ConsumerWidget {
  final ReadingPlanState planState;
  final DateTime displayMonth;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const _TodayViewBody({
    required this.planState,
    required this.displayMonth,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  void _openSettings(BuildContext context, WidgetRef ref, ReadingPlanState planState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanSetupSheet(
        initialState: planState,
        isEditing: true,
        onConfirm: (pace, rest, remEnabled, remH, remM) {
          ref.read(readingPlanProvider(planState.planId).notifier).setPaceMode(pace);
          ref.read(readingPlanProvider(planState.planId).notifier).setRestDay(rest);
          ref.read(readingPlanProvider(planState.planId).notifier).setReminder(remEnabled, remH, remM);
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

    return Scaffold(
      appBar: SharedAppBar(
        title: const Text('Reading Plan', style: TextStyle(fontFamily: 'EB Garamond', fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(planState.reminderEnabled ? Icons.notifications_active_rounded : Icons.notifications_none_rounded),
            tooltip: 'Reminder Settings',
            onPressed: () => _openSettings(context, ref, planState),
          ),
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
                  Text('$percent%', style: TextStyle(fontFamily: 'EB Garamond', fontSize: 34, fontWeight: FontWeight.bold, color: gold)),
                  Text('Complete', style: theme.textTheme.labelSmall),
                ]),
              ],
            ),
            const SizedBox(height: 24),

            if (today != null) Builder(builder: (ctx) {
              final dayData = planState.planData[today - 1];
              final summary = dayData.passages.map((p) => _expandLabel(p)).join(', ');
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DayView(planId: planState.planId, dayNum: today)));
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
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Chronological Bible in a Year', style: TextStyle(fontFamily: 'EB Garamond', fontSize: 18, fontWeight: FontWeight.bold, color: gold)),
                          const SizedBox(height: 4),
                          Text('${dayData.title}: $summary', style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: gold),
                    ],
                  ),
                ),
              );
            }),

            if (planState.paceMode == 'scheduled' && planState.missedDays.isNotEmpty) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.history_rounded, size: 16),
                label: Text('Catch up · Day ${planState.oldestUnread}'),
                style: TextButton.styleFrom(foregroundColor: theme.textTheme.bodyMedium?.color),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DayView(planId: planState.planId, dayNum: planState.oldestUnread)));
                },
              ),
            ],

            const SizedBox(height: 28),

            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < -300) {
                  onNextMonth();
                } else if (details.primaryVelocity! > 300) {
                  onPrevMonth();
                }
              },
              child: _PlanMonthCalendar(
                planState: planState,
                displayMonth: displayMonth,
                onPrevMonth: onPrevMonth,
                onNextMonth: onNextMonth,
                scheduledMap: scheduledMap,
                realToday: realNow,
                isScheduled: isScheduled,
                gold: gold,
                onDayTap: (dayNum) {
                  HapticFeedback.selectionClick();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DayView(planId: planState.planId, dayNum: dayNum)));
                },
              ),
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
              IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: onPrevMonth, color: gold),
              Text('${_monthNames[month - 1]} $year', style: TextStyle(fontFamily: 'EB Garamond', fontSize: 22, fontWeight: FontWeight.bold, color: gold)),
              IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: onNextMonth, color: gold),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(7, (i) => Expanded(
              child: Center(
                child: Text(
                  _weekdayShort[i][0],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: i == 0 ? gold.withValues(alpha: 0.7) : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
              childAspectRatio: 0.9,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              DateTime cellDate;
              bool isCurrentMonth = true;

              if (index < firstDaySundayFirst) {
                isCurrentMonth = false;
                cellDate = DateTime(year, month, 1 - (firstDaySundayFirst - index));
              } else if (index >= firstDaySundayFirst + daysInMonth) {
                isCurrentMonth = false;
                cellDate = DateTime(year, month, index - firstDaySundayFirst + 1);
              } else {
                cellDate = DateTime(year, month, index - firstDaySundayFirst + 1);
              }

              final isRealToday = cellDate.year == realToday.year && cellDate.month == realToday.month && cellDate.day == realToday.day;
              final cellAppWeekday = appWeekday(cellDate);
              final isRestDay = restDay != null && cellAppWeekday == restDay;

              int? readingDay;
              if (isScheduled && isCurrentMonth) readingDay = scheduledMap['${cellDate.year}-${cellDate.month}-${cellDate.day}'];

              return _DayCell(
                dayNum: cellDate.day,
                isRealToday: isRealToday,
                isRestDay: isRestDay,
                readingDay: readingDay,
                isCompleted: readingDay != null && planState.completedReadings.contains(readingDay),
                isMissed: readingDay != null && planState.missedDays.contains(readingDay),
                isToday: readingDay != null && readingDay == planState.todayReadingDay,
                isScheduled: isScheduled,
                isCurrentMonth: isCurrentMonth,
                gold: gold,
                theme: theme,
                onTap: (readingDay != null && isCurrentMonth) ? () => onDayTap(readingDay!) : null,
              );
            },
          ),
          if (!isScheduled) ...[
            const SizedBox(height: 16),
            Text('Flexible mode: dates assigned as you read.', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.45)), textAlign: TextAlign.center),
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
    required this.dayNum, required this.isRealToday, required this.isRestDay,
    required this.readingDay, required this.isCompleted, required this.isMissed,
    required this.isToday, required this.isScheduled, required this.isCurrentMonth,
    required this.gold, required this.theme, this.onTap,
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
        circleBorder = gold.withValues(alpha: 0.3); // Subtle border for rest day
      } else if (readingDay != null) {
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.85);
      }
    }

    return GestureDetector(
      onTap: onTap,
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
              border: circleBorder != null ? Border.all(color: circleBorder, width: 1.5) : null,
            ),
            child: Center(
              child: isRestDay
                  ? Icon(Icons.self_improvement_rounded, size: 14, color: isCurrentMonth ? theme.colorScheme.onSurface.withValues(alpha: 0.35) : theme.colorScheme.onSurface.withValues(alpha: 0.15))
                  : Text('$dayNum', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
            ),
          ),
          if (indicator != null) ...[
            const SizedBox(height: 4),
            indicator,
          ] else if (readingDay != null && !isCompleted && !isRestDay && isCurrentMonth)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
            ),
        ],
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

class _DayViewState extends ConsumerState<DayView> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late ConfettiController _confettiController;
  late int _currentLogicalDay;
  late int _totalLogicalDaysCount;

  @override
  void initState() {
    super.initState();
    final planState = ref.read(readingPlanProvider(widget.planId));
    _currentLogicalDay = _logicalDayForReadingDay(widget.dayNum, planState);
    _totalLogicalDaysCount = _totalLogicalDays(planState);
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
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
      
      final previousCompleted = ref.read(readingPlanProvider(widget.planId)).completedReadings;
      ref.read(readingPlanProvider(widget.planId).notifier).markReadingComplete(readingDay);
      final newCompleted = ref.read(readingPlanProvider(widget.planId)).completedReadings;
      final planData = ref.read(readingPlanProvider(widget.planId)).planData;
      
      final celebrations = celebrationMilestones(previousCompleted, newCompleted, planData);
      
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
            final customPlan = ref.read(preferencesProvider).getCustomPlan(widget.planId);
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
      ref.read(readingPlanProvider(widget.planId).notifier).markReadingIncomplete(readingDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(readingPlanProvider(widget.planId));
    if (planState.planData.isEmpty || _currentLogicalDay < 1 || _currentLogicalDay > _totalLogicalDaysCount) {
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
              isRestDay ? 'Rest Day' : '${planState.paceMode == 'scheduled' ? 'Reading' : 'Day'} $readingDay of ${planState.planData.length}',
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
              onPressed: _currentLogicalDay < _totalLogicalDaysCount ? _nextDay : null,
            ),
          ],
        ),
      ),
    );

    if (isRestDay) {
      final date = DateTime.utc(planState.planStartedOn!.year, planState.planStartedOn!.month, planState.planStartedOn!.day).add(Duration(days: _currentLogicalDay - 1));
      final dateHeader = '${_weekdayShort[date.weekday - 1]}, ${_monthNamesShort[date.month - 1]} ${date.day}, ${date.year}';
      
      String? weekTitle;
      final prevReadingDay = _readingDayForLogicalDay(_currentLogicalDay - 1, planState);
      if (prevReadingDay != null && prevReadingDay >= 1 && prevReadingDay <= planState.planData.length) {
         weekTitle = planState.planData[prevReadingDay - 1].title;
      }
      
      final weekIndex = ((_currentLogicalDay - 1) / 7).floor();
      final reflection = _restDayReflections[weekIndex % _restDayReflections.length];

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: SharedAppBar(title: const Text(''), backgroundColor: Colors.transparent, elevation: 0),
        bottomNavigationBar: navBar,
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! < -300) {
              _nextDay();
            } else if (details.primaryVelocity! > 300) {
              _prevDay();
            }
          },
          child: Container(
            color: theme.scaffoldBackgroundColor,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(dateHeader, style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.1, color: gold.withValues(alpha: 0.8))),
                const SizedBox(height: 16),
                const Text('Rest & Reflect', style: TextStyle(fontFamily: 'EB Garamond', fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                if (weekTitle != null) ...[
                  const SizedBox(height: 12),
                  Text("You've journeyed through:\n$weekTitle", textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                ],
                const SizedBox(height: 48),
                Text(reflection['prompt']!, style: theme.textTheme.titleMedium?.copyWith(color: gold), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Text('“${reflection['verse']!}”', style: const TextStyle(fontFamily: 'EB Garamond', fontSize: 24, fontStyle: FontStyle.italic, height: 1.3), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(reflection['reference']!, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                const SizedBox(height: 64),
                
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: gold,
                    side: BorderSide(color: gold.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  child: const Text('I reflected today', style: TextStyle(letterSpacing: 1.0)),
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
      final d = DateTime.utc(planState.planStartedOn!.year, planState.planStartedOn!.month, planState.planStartedOn!.day).add(Duration(days: _currentLogicalDay - 1));
      dateHeader = '${_weekdayShort[d.weekday - 1]}, ${_monthNamesShort[d.month - 1]} ${d.day}, ${d.year}';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SharedAppBar(title: const Text(''), backgroundColor: Colors.transparent, elevation: 0),
      bottomNavigationBar: navBar,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -300) {
            _nextDay();
          } else if (details.primaryVelocity! > 300) {
            _prevDay();
          }
        },
        child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: gold.withValues(alpha: 0.10),
                padding: const EdgeInsets.only(top: 96, bottom: 32, left: 24, right: 24),
                child: Column(
                  children: [
                    Text(dateHeader, style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.1, color: gold.withValues(alpha: 0.8))),

                    const SizedBox(height: 8),
                    Text(dayData.title, style: const TextStyle(fontFamily: 'EB Garamond', fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  children: [
                    ...dayData.passages.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final passage = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Material(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () async {
                              final markedComplete = await Navigator.push<bool>(
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
                                final isDoneNow = ref.read(readingPlanProvider(widget.planId)).completedReadings.contains(readingDay);
                                if (!isDoneNow) {
                                  _toggleDone(false, readingDay);
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 64,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: gold.withValues(alpha: 0.12)),
                                    child: Center(child: Text('$idx', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gold))),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(child: Text(_expandLabel(passage), style: const TextStyle(fontFamily: 'EB Garamond', fontSize: 18, fontWeight: FontWeight.w600))),
                                  Icon(Icons.menu_book_rounded, size: 18, color: gold.withValues(alpha: 0.6)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 28),

                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) => Container(
                        decoration: BoxDecoration(
                          boxShadow: _glowAnimation.value > 0
                              ? [
                                  BoxShadow(
                                    color: gold.withValues(alpha: 0.55 * _glowAnimation.value),
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
                            backgroundColor: isDone ? gold : theme.cardColor,
                            foregroundColor: isDone ? Colors.white : gold,
                            side: isDone ? BorderSide.none : BorderSide(color: gold, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _toggleDone(isDone, readingDay),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isDone ? Icons.check_circle_rounded : Icons.circle_outlined, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                isDone ? 'COMPLETED' : 'MARK AS READ',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From the plan:', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.45))),
                          const SizedBox(height: 8),
                          Text('Chronological Bible in a Year', style: TextStyle(fontFamily: 'EB Garamond', fontSize: 18, fontWeight: FontWeight.bold, color: gold)),
                          const SizedBox(height: 4),
                          Text('Guthrie – Read the Bible for Life\n52 weeks', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
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

    if (planState.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: gold)));
    }

    if (!planState.isActive) {
      return Scaffold(
        appBar: const SharedAppBar(title: Text('Reading Plan', style: TextStyle(fontFamily: 'EB Garamond'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, size: 64, color: gold.withValues(alpha: 0.4)),
                const SizedBox(height: 24),
                const Text('Chronological Bible in a Year', style: TextStyle(fontFamily: 'EB Garamond', fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Read through the Bible in the order events occurred.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          ref.read(readingPlanProvider(widget.planId).notifier).startPlan(
                            planId: widget.planId,
                            paceMode: pace,
                            restDay: rest,
                          );
                          ref.read(readingPlanProvider(widget.planId).notifier).setReminder(remEnabled, remH, remM);
                          _confettiController.play();
                        },
                      ),
                    );
                  },
                  child: const Text('Begin Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        TodayView(planState: planState),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [gold, gold.withValues(alpha: 0.8), Colors.white],
            emissionFrequency: 0.05,
            numberOfParticles: 40,
          ),
        ),
      ],
    );
  }
}
