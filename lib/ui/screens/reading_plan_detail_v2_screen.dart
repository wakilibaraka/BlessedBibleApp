import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/reading_plan_provider.dart'
    show readingPlanProvider, appWeekday;
import '../../state/theme_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import 'journey_map_screen.dart';
import 'plans_hub_v2_screen.dart' show availablePlans;
import 'study_reader_screen.dart';

/// Rebuilt plan detail (V2). Shown from [PlansHubV3Screen] / [StudyScreenV2].
///
/// Same [readingPlanProvider] state as V1 — this screen only changes
/// presentation and fixes mapping bugs locally:
/// - Weekday headers use [appWeekday] (Sun=1..Sat=7); the old
///   `_weekdayShort[d.weekday-1]` off-by-one is not repeated here.
/// - Begin sheet passes the chosen start date into `startPlan`.
/// - Rest "None" uses the `-1` sentinel required by `copyWith`.
/// - Catch-up offers oldest-first, mark-done and schedule rebase
///   (shift start date forward over rest days) instead of silent auto-skip.
class ReadingPlanDetailV2Screen extends ConsumerStatefulWidget {
  final String planId;
  const ReadingPlanDetailV2Screen({super.key, required this.planId});

  @override
  ConsumerState<ReadingPlanDetailV2Screen> createState() =>
      _ReadingPlanDetailV2ScreenState();
}

class _ReadingPlanDetailV2ScreenState
    extends ConsumerState<ReadingPlanDetailV2Screen> {
  int? _selectedDay;
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _pendingStartDate;

  String _title() {
    for (final p in availablePlans) {
      if (p.id == widget.planId) return p.title;
    }
    try {
      final custom = ref
          .read(preferencesProvider)
          .getCustomPlan(widget.planId);
      final t = custom?['title'] as String?;
      if (t != null && t.isNotEmpty) return t;
    } catch (_) {}
    return widget.planId.replaceAll('_', ' ');
  }

  /// Maps reading-day number -> calendar date, skipping the rest weekday.
  Map<int, DateTime> _dateMap(
      DateTime start, int? restDay, int total) {
    final map = <int, DateTime>{};
    var date = DateTime(start.year, start.month, start.day);
    var day = 1;
    var guard = 0;
    while (day <= total && guard < total + 370) {
      guard++;
      if (restDay == null || appWeekday(date) != restDay) {
        map[day] = date;
        day++;
      }
      date = date.add(const Duration(days: 1));
    }
    return map;
  }

  DateTime? _restDateForSelected(
      Map<int, DateTime> dateMap, int? restDay, int selected) {
    if (restDay == null || dateMap.isEmpty) return null;
    // A "rest" selection is encoded as -(calendar day offset marker).
    // We only use this when the selected day has no reading date; find the
    // calendar date by walking from the nearest mapped day.
    final sorted = dateMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final first = sorted.first.value;
    return DateTime(first.year, first.month, first.day)
        .add(Duration(days: selected.abs()));
  }

  Future<void> _rebase(int behind) async {
    final plan = ref.read(readingPlanProvider(widget.planId));
    final start = plan.planStartedOn;
    if (start == null) return;
    var shifted = DateTime(start.year, start.month, start.day);
    var moved = 0;
    var guard = 0;
    while (moved < behind && guard < behind + 370) {
      guard++;
      shifted = shifted.add(const Duration(days: 1));
      if (plan.restDay == null || appWeekday(shifted) != plan.restDay) {
        moved++;
      }
    }
    ref
        .read(readingPlanProvider(widget.planId).notifier)
        .setStartDate(shifted);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Schedule rebased +$behind reading days. Completed days untouched.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = ref.watch(readingPlanProvider(widget.planId));
    final notifier =
        ref.read(readingPlanProvider(widget.planId).notifier);
    final appThemeMode = ref.watch(themeProvider);

    if (plan.isLoading) {
      return V2PageShell(
        appThemeMode: appThemeMode,
        page: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const SharedAppBar(title: Text('Plan')),
          body:
              const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final loadError = plan.error;
    if (loadError != null) {
      return V2PageShell(
        appThemeMode: appThemeMode,
        page: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const SharedAppBar(title: Text('Plan')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loadError,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => ref.invalidate(
                        readingPlanProvider(widget.planId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final total = plan.planData.length;

    // ── Not started: Begin card ───────────────────────────────
    if (plan.planStartedOn == null) {
      final start = _pendingStartDate ?? DateTime.now();
      return V2PageShell(
        appThemeMode: appThemeMode,
        page: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const SharedAppBar(title: Text('Plan')),
          body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
            children: [
              Text(_title(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 4),
              Text(
                total == 0
                    ? 'This plan has no readings yet.'
                    : '$total reading days · ~${(total / 7).ceil()} weeks',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 14),
              V2Card(
                featured: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const V2Eyebrow('Begin plan'),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month_rounded),
                      title: const Text('Start date'),
                      subtitle: Text(
                          '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: start,
                          firstDate: DateTime.now().subtract(
                              const Duration(days: 365)),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _pendingStartDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: total == 0
                            ? null
                            : () {
                                notifier.startPlan(
                                  planId: widget.planId,
                                  paceMode: 'scheduled',
                                  startDate: start,
                                );
                                HapticFeedback.mediumImpact();
                              },
                        child: const Text('Start Day 1 →'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The chosen date is passed into startPlan — it is honoured, not replaced with today.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      );
    }

    final current = plan.todayReadingDay ?? total;
    final behind = plan.missedDays.length;
    final selected = _selectedDay ?? current;
    final dateMap = _dateMap(plan.planStartedOn!, plan.restDay, total);
    final dateForSelected = dateMap[selected];
    final isRestSelected = dateForSelected == null && selected > 0;

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SharedAppBar(
          title: Text(_title()),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => _showPlanSettings(plan),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              children: [
                // ── Progress hero ─────────────────────────────
                V2Card(
                  featured: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          V2ProgressRing(
                              fraction: plan.percentComplete, size: 92),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SCHEDULE',
                                  style: theme
                                      .textTheme.labelSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                    fontSize: 10,
                                    color: theme
                                        .colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                                Text(
                                  total == 0
                                      ? 'No readings'
                                      : 'Day $current of $total',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                V2ProgressBar(
                                    fraction: plan.percentComplete),
                                const SizedBox(height: 4),
                                Text(
                                  '${(plan.percentComplete * 100).round()}% complete',
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme
                                        .colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    V2MetaChip(plan.paceMode == 'flexible'
                                        ? 'Flexible'
                                        : 'Scheduled'),
                                    if (plan.restDay != null)
                                      V2MetaChip(
                                          'Rest ${_weekdayName(plan.restDay!)}'),
                                    if (behind > 0)
                                      V2MetaChip('⚠ $behind behind')
                                    else
                                      const V2MetaChip('On track ✓'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Pace segmented control
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(999),
                          border: Border.all(
                              color: theme.dividerColor),
                        ),
                        child: Row(
                          children: ['scheduled', 'flexible'].map((m) {
                            final on = plan.paceMode == m;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  notifier.setPaceMode(m);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  decoration: BoxDecoration(
                                    color: on
                                        ? theme
                                            .colorScheme.onSurface
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    m == 'scheduled'
                                        ? 'Scheduled'
                                        : 'Flexible',
                                    style: theme.textTheme.labelLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: on
                                          ? theme
                                              .colorScheme.surface
                                          : theme
                                              .colorScheme.onSurface
                                              .withValues(
                                                  alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.paceMode == 'flexible'
                            ? 'Flexible: work oldest-unread first. No missed days accrue.'
                            : 'Scheduled: each date maps to a reading day. Missed days accrue as behind — catch up below.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Catch-up ──────────────────────────────────
                if (behind > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: V2Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const V2Eyebrow('Catch up'),
                          const SizedBox(height: 6),
                          Text(
                            'Behind by $behind — oldest unread is Day ${plan.oldestUnread}.',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Backfilling marks progress. Rebase shifts the remaining schedule forward instead.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton(
                                onPressed: () => setState(() =>
                                    _selectedDay = plan.oldestUnread),
                                child: const Text('Go to oldest'),
                              ),
                              FilledButton.tonal(
                                onPressed: () {
                                  notifier.markReadingComplete(
                                      plan.oldestUnread);
                                  HapticFeedback.mediumImpact();
                                },
                                child: const Text('Mark oldest done'),
                              ),
                              OutlinedButton(
                                onPressed: () => _rebase(behind),
                                child: Text('Rebase +$behind days'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Calendar ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: V2Card(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _monthLabel(_visibleMonth, total),
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                  Icons.chevron_left_rounded),
                              onPressed: () => setState(() {
                                _visibleMonth = DateTime(
                                    _visibleMonth.year,
                                    _visibleMonth.month - 1);
                              }),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon:
                                  const Icon(Icons.map_rounded),
                              tooltip: 'Journey map view',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        JourneyMapScreen(
                                            planId:
                                                widget.planId),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                  Icons.today_rounded),
                              tooltip: 'Jump to today',
                              onPressed: () => setState(() {
                                final now = DateTime.now();
                                _visibleMonth =
                                    DateTime(now.year, now.month);
                                _selectedDay = current;
                              }),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                  Icons.chevron_right_rounded),
                              onPressed: () => setState(() {
                                _visibleMonth = DateTime(
                                    _visibleMonth.year,
                                    _visibleMonth.month + 1);
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: const [
                            _Dow('SUN'),
                            _Dow('MON'),
                            _Dow('TUE'),
                            _Dow('WED'),
                            _Dow('THU'),
                            _Dow('FRI'),
                            _Dow('SAT'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                          itemCount: _cellsForMonth(
                                  _visibleMonth, dateMap, plan.restDay)
                              .length,
                          itemBuilder: (context, i) {
                            final cell = _cellsForMonth(_visibleMonth,
                                dateMap, plan.restDay)[i];
                            return _DayCell(
                              cell: cell,
                              isToday: cell.readingDay != null &&
                                  cell.readingDay == current,
                              isSelected:
                                  cell.readingDay == selected,
                              onTap: cell.readingDay == null
                                  ? null
                                  : () => setState(() =>
                                      _selectedDay =
                                          cell.readingDay),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            _Legend(
                                theme.primaryColor, 'Done'),
                            _Legend(null, 'Today = ring',
                                ring: true),
                            _Legend(null, 'Missed = dashed',
                                dashed: true),
                            _Legend(null, 'Rest = hatched',
                                hatched: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Day detail ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _DayDetailCard(
                    key: ValueKey(
                        '${widget.planId}:$selected:${plan.completedReadings.contains(selected)}'),
                    planId: widget.planId,
                    day: selected,
                    isRest: isRestSelected,
                    restDate: isRestSelected
                        ? _restDateForSelected(
                            dateMap, plan.restDay, selected)
                        : dateForSelected,
                    date: dateForSelected,
                  ),
                ),

                // ── Reminder ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: V2Card(
                    child: Row(
                      children: [
                        Icon(Icons.notifications_outlined,
                            color: theme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.reminderEnabled
                                    ? 'Reminder · ${_fmtTime(plan.reminderTimeHour, plan.reminderTimeMinute)}'
                                    : 'Reminder off',
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Per-plan notification — skips the rest day automatically.',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: plan.reminderEnabled,
                          onChanged: (v) async {
                            if (v) {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: plan.reminderTimeHour,
                                    minute:
                                        plan.reminderTimeMinute),
                              );
                              if (picked == null) return;
                              notifier.setReminder(
                                  true, picked.hour, picked.minute);
                            } else {
                              notifier.setReminder(
                                  false,
                                  plan.reminderTimeHour,
                                  plan.reminderTimeMinute);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  String _monthLabel(DateTime m, int total) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    return '${names[m.month - 1]} ${m.year}';
  }

  /// Sunday-first cells. readingDay == null → padding or rest date.
  List<_CalCell> _cellsForMonth(
      DateTime month, Map<int, DateTime> dateMap, int? restDay) {
    final first = DateTime(month.year, month.month, 1);
    // Sunday-first offset: DateTime.weekday Mon=1..Sun=7.
    final leading = first.weekday % 7;
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;
    final byDate = <String, int>{};
    for (final e in dateMap.entries) {
      byDate[_key(e.value)] = e.key;
    }
    final plan = ref.read(readingPlanProvider(widget.planId));
    final cells = <_CalCell>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const _CalCell.blank());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final readingDay = byDate[_key(date)];
      final isRestDay =
          restDay != null && appWeekday(date) == restDay;
      final done = readingDay != null &&
          plan.completedReadings.contains(readingDay);
      final missed = readingDay != null &&
          plan.missedDays.contains(readingDay);
      cells.add(_CalCell(
        dayOfMonth: d,
        readingDay: readingDay,
        isRest: isRestDay && readingDay == null,
        isDone: done,
        isMissed: missed,
      ));
    }
    return cells;
  }

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  String _weekdayName(int appDay) {
    const names = ['', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return (appDay >= 1 && appDay <= 7) ? names[appDay] : '';
  }

  String _fmtTime(int h, int m) {
    final hh = h % 12 == 0 ? 12 : h % 12;
    final ap = h < 12 ? 'AM' : 'PM';
    return '$hh:${m.toString().padLeft(2, '0')} $ap';
  }

  void _showPlanSettings(dynamic plan) {
    final notifier =
        ref.read(readingPlanProvider(widget.planId).notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final p = ref.read(readingPlanProvider(widget.planId));
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const V2Eyebrow('Plan settings'),
              ListTile(
                leading: const Icon(Icons.calendar_month_rounded),
                title: const Text('Change start date…'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: p.planStartedOn ?? DateTime.now(),
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 730)),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) notifier.setStartDate(picked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bedtime_rounded),
                title: Text(
                    'Rest day: ${p.restDay == null ? 'None' : _weekdayName(p.restDay!)}'),
                subtitle:
                    const Text('Tap to cycle None → Sun → … → Sat'),
                onTap: () {
                  // copyWith uses -1 as the null sentinel.
                  final next = p.restDay == null
                      ? 1
                      : (p.restDay! >= 7 ? -1 : p.restDay! + 1);
                  notifier.setRestDay(next);
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.restart_alt_rounded,
                    color: theme.colorScheme.error),
                title: Text('Restart from Day 1…',
                    style: TextStyle(
                        color: theme.colorScheme.error)),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: const Text('Restart plan?'),
                      content: const Text(
                          'Completed days will be cleared.'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(d).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(d).pop(true),
                          child: const Text('Restart'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) notifier.restartPlan();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Dow extends StatelessWidget {
  final String text;
  const _Dow(this.text);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 10,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.65),
            ),
      ),
    );
  }
}

class _CalCell {
  final int? dayOfMonth;
  final int? readingDay;
  final bool isRest;
  final bool isDone;
  final bool isMissed;
  const _CalCell({
    this.dayOfMonth,
    this.readingDay,
    this.isRest = false,
    this.isDone = false,
    this.isMissed = false,
  });
  const _CalCell.blank()
      : dayOfMonth = null,
        readingDay = null,
        isRest = false,
        isDone = false,
        isMissed = false;
}

class _DayCell extends StatelessWidget {
  final _CalCell cell;
  final bool isToday;
  final bool isSelected;
  final VoidCallback? onTap;
  const _DayCell({
    required this.cell,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (cell.dayOfMonth == null) {
      return const SizedBox.shrink();
    }
    Color? bg;
    Border? border;
    if (isSelected) {
      bg = theme.colorScheme.onSurface;
    } else if (cell.isDone) {
      bg = theme.primaryColor.withValues(alpha: 0.14);
      border = Border.all(
          color: theme.primaryColor.withValues(alpha: 0.35));
    } else if (isToday) {
      border = Border.all(color: theme.primaryColor, width: 2);
    } else if (cell.isMissed) {
      border = Border.all(
        color: theme.primaryColor.withValues(alpha: 0.5),
      );
    } else {
      border = Border.all(color: theme.dividerColor);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cell.isRest && bg == null
              ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
              : bg,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          '${cell.dayOfMonth}',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected
                ? theme.colorScheme.surface
                : cell.isRest
                    ? theme.colorScheme.onSurface
                        .withValues(alpha: 0.6)
                    : null,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color? color;
  final String text;
  final bool ring;
  final bool dashed;
  final bool hatched;
  const _Legend(this.color, this.text,
      {this.ring = false, this.dashed = false, this.hatched = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color?.withValues(alpha: 0.25) ??
                theme.colorScheme.onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color ?? theme.primaryColor,
              width: ring ? 2 : 1,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color:
                theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Day detail with per-passage check-off. Checking every passage and then
/// confirming marks the whole day complete — reading *is* completing.
class _DayDetailCard extends ConsumerStatefulWidget {
  final String planId;
  final int day;
  final bool isRest;
  final DateTime? date;
  final DateTime? restDate;
  const _DayDetailCard({
    super.key,
    required this.planId,
    required this.day,
    required this.isRest,
    required this.date,
    required this.restDate,
  });

  @override
  ConsumerState<_DayDetailCard> createState() => _DayDetailCardState();
}

class _DayDetailCardState extends ConsumerState<_DayDetailCard> {
  final Set<int> _checked = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = ref.watch(readingPlanProvider(widget.planId));
    final notifier =
        ref.read(readingPlanProvider(widget.planId).notifier);
    final done = plan.completedReadings.contains(widget.day);

    final dayData = plan.planData.length >= widget.day && widget.day >= 1
        ? plan.planData[widget.day - 1]
        : null;

    if (widget.isRest || dayData == null) {
      return V2Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const V2Eyebrow('Rest & reflect'),
            const SizedBox(height: 6),
            Text(
              'A day of rest — no reading assigned. Rest days carry no reading.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final dateLabel = widget.date == null
        ? ''
        : ' · ${widget.date!.month}/${widget.date!.day}';
    return V2Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2Eyebrow('Day ${widget.day}$dateLabel'),
          const SizedBox(height: 6),
          Text(
            dayData.passages.map((p) => p.label).join(' · '),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a passage to open it. Check each one off as you read.',
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          for (var i = 0; i < dayData.passages.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  // Open the passage in the shared study reader; the
                  // checkbox below tracks it as read for this plan day.
                  final markedComplete =
                      await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => StudyReaderScreen(
                        payload: StudySessionPayload.plan(
                          planId: widget.planId,
                          dayNum: widget.day,
                          initialPassageIndex: i,
                        ),
                      ),
                    ),
                  );
                  if (!mounted) return;
                  setState(() => _checked.add(i));
                  if (markedComplete == true && !done) {
                    notifier.markReadingComplete(widget.day);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _checked.contains(i)
                        ? theme.primaryColor.withValues(alpha: 0.1)
                        : theme.colorScheme.onSurface
                            .withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _checked.contains(i)
                          ? theme.primaryColor.withValues(alpha: 0.35)
                          : theme.dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _checked.contains(i)
                              ? theme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _checked.contains(i)
                                ? theme.primaryColor
                                : theme.dividerColor,
                            width: 2,
                          ),
                        ),
                        child: _checked.contains(i)
                            ? Icon(Icons.check_rounded,
                                size: 16,
                                color: theme.colorScheme.surface)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dayData.passages[i].label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: theme.primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: done
                  ? FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    )
                  : null,
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (done) {
                  notifier.markReadingIncomplete(widget.day);
                } else {
                  notifier.markReadingComplete(widget.day);
                  final completed =
                      plan.completedReadings.length + 1;
                  if (completed % 30 == 0 && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '🎉 $completed readings completed — keep going!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(done
                  ? '✓ Completed — tap to undo'
                  : 'Mark Day ${widget.day} as Read ✓ (${_checked.length}/${dayData.passages.length} passages)'),
            ),
          ),
        ],
      ),
    );
  }
}
