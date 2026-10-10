import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';

import '../../state/reading_plan_provider.dart'
    show readingPlanProvider, appWeekday, ReadingPlanState;
import '../../state/theme_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import 'journey_map_screen.dart';
import '../../data/curated_plans.dart';
import 'study_reader_screen.dart';

/// Rebuilt plan detail (V2). Shown from [StudyScreenV2].
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
  DateTime? _pendingStartDate;

  /// Anchor keys for scroll-to-day jumps (row tap, "jump to today").
  final GlobalKey _todayRowKey = GlobalKey();
  final GlobalKey _dayDetailKey = GlobalKey();

  void _reveal(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          alignment: 0.05,
        );
      }
    });
  }

  String _title() {
    for (final p in availablePlans) {
      if (p.id == widget.planId) return p.title;
    }
    try {
      final custom = ref.read(preferencesProvider).getCustomPlan(widget.planId);
      final t = custom?['title'] as String?;
      if (t != null && t.isNotEmpty) return t;
    } catch (_) {}
    return widget.planId.replaceAll('_', ' ');
  }

  /// Maps reading-day number -> calendar date, skipping the rest weekday.
  Map<int, DateTime> _dateMap(
      DateTime start, bool Function(int appWeekday) isRest, int total) {
    final map = <int, DateTime>{};
    var date = DateTime(start.year, start.month, start.day);
    var day = 1;
    var guard = 0;
    while (day <= total && guard < total + 370) {
      guard++;
      if (!isRest(appWeekday(date))) {
        map[day] = date;
        day++;
      }
      date = date.add(const Duration(days: 1));
    }
    return map;
  }

  /// "Rest Sun, Wed" for a set, "Rest Sun" for the legacy single day,
  /// '' when there are no rest days.
  String _restChipLabel(Set<int> days, int? single) {
    if (days.isNotEmpty) {
      // Order Monday-first for stable display.
      final ordered = days.toList()
        ..sort((a, b) => ((a + 6) % 7).compareTo((b + 6) % 7));
      return context.l10n.plansRestChip(ordered.map(_weekdayName).join(', '));
    }
    if (single == null) return '';
    return context.l10n.plansRestChip(_weekdayName(single));
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
    ref.read(readingPlanProvider(widget.planId).notifier).setStartDate(shifted);
    if (!mounted) return;
    unawaited(HapticFeedback.mediumImpact());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.plansRebasedSnack(behind)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = ref.watch(readingPlanProvider(widget.planId));
    final notifier = ref.read(readingPlanProvider(widget.planId).notifier);
    final appThemeMode = ref.watch(themeProvider);

    if (plan.isLoading) {
      return V2PageShell(
        appThemeMode: appThemeMode,
        page: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: SharedAppBar(title: Text(context.l10n.plansPlan)),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final loadError = plan.error;
    if (loadError != null) {
      return V2PageShell(
        appThemeMode: appThemeMode,
        page: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: SharedAppBar(title: Text(context.l10n.plansPlan)),
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
                    onPressed: () =>
                        ref.invalidate(readingPlanProvider(widget.planId)),
                    child: Text(context.l10n.commonRetry),
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
          appBar: SharedAppBar(title: Text(context.l10n.plansPlan)),
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
                      ? context.l10n.plansNoReadingsYet
                      : context.l10n
                          .plansReadingDaysWeeks(total, (total / 7).ceil()),
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
                      V2Eyebrow(context.l10n.plansBeginPlan),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month_rounded),
                        title: Text(context.l10n.plansStartDate),
                        subtitle: Text(DateFormat.yMMMEd(
                          Localizations.localeOf(context).toString(),
                        ).format(start)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: start,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
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
                          child: Text(context.l10n.plansStartDayOne),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.plansStartDateNote,
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
    final dateMap = _dateMap(plan.planStartedOn!, plan.isRestWeekday, total);
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
                    textured: true,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.plansScheduleLabel,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.4,
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                  Text(
                                    total == 0
                                        ? context.l10n.plansNoReadings
                                        : context.l10n
                                            .plansDayOfTotal(current, total),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  V2ProgressBar(fraction: plan.percentComplete),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.l10n.plansPercentComplete(
                                        (plan.percentComplete * 100).round()),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      V2MetaChip(plan.paceMode == 'flexible'
                                          ? context.l10n.plansFlexible
                                          : context.l10n.plansScheduled),
                                      if (plan.restDay != null ||
                                          plan.restDays.isNotEmpty)
                                        V2MetaChip(_restChipLabel(
                                            plan.restDays, plan.restDay)),
                                      if (behind > 0)
                                        V2MetaChip(
                                            '⚠ ${context.l10n.plansBehindChip(behind)}')
                                      else
                                        V2MetaChip(
                                            '${context.l10n.plansOnTrack} ✓'),
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
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: theme.dividerColor),
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
                                          ? theme.colorScheme.onSurface
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      m == 'scheduled'
                                          ? context.l10n.plansScheduled
                                          : context.l10n.plansFlexible,
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: on
                                            ? theme.colorScheme.surface
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.7),
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
                              ? context.l10n.plansFlexibleHelp
                              : context.l10n.plansScheduledHelp,
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
                            V2Eyebrow(context.l10n.plansCatchUp),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n
                                  .plansBehindBy(behind, plan.oldestUnread),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.plansCatchUpHelp,
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
                                  onPressed: () => setState(
                                      () => _selectedDay = plan.oldestUnread),
                                  child: Text(context.l10n.plansGoToOldest),
                                ),
                                FilledButton.tonal(
                                  onPressed: () {
                                    notifier
                                        .markReadingComplete(plan.oldestUnread);
                                    HapticFeedback.mediumImpact();
                                  },
                                  child: Text(context.l10n.plansMarkOldestDone),
                                ),
                                FilledButton.tonal(
                                  onPressed: () {
                                    final newly = List.generate(
                                            current - 1, (i) => i + 1)
                                        .where((d) =>
                                            !plan.completedReadings.contains(d))
                                        .length;
                                    notifier.markAllPreviousRead(current);
                                    HapticFeedback.mediumImpact();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(newly == 0
                                            ? context.l10n.plansAllPreviousDone
                                            : context.l10n
                                                .plansPreviousMarked(newly)),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child:
                                      Text(context.l10n.plansMarkAllPrevious),
                                ),
                                OutlinedButton(
                                  onPressed: () => _rebase(behind),
                                  child: Text(
                                      context.l10n.plansRebaseDays(behind)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Readings list ─────────────────────────────
                  // Day-by-day rows (done / today / missed / upcoming)
                  // replace the old month calendar: same states, scannable
                  // at a glance. Tapping a row selects the day below.
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: V2Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.plansReadingsHeader(total),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.map_rounded),
                                tooltip: context.l10n.plansJourneyMap,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => JourneyMapScreen(
                                          planId: widget.planId),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.today_rounded),
                                tooltip: context.l10n.plansJumpToToday,
                                onPressed: () {
                                  setState(() => _selectedDay = current);
                                  _reveal(_todayRowKey);
                                  _reveal(_dayDetailKey);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Flexible plans accrue no missed days, so the
                          // catch-up card never appears for them — offer
                          // the same one-tap catch-up here instead.
                          if (plan.paceMode == 'flexible' &&
                              plan.oldestUnread > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: FilledButton.tonal(
                                onPressed: () {
                                  notifier
                                      .markAllPreviousRead(plan.oldestUnread);
                                  HapticFeedback.mediumImpact();
                                },
                                child: Text(context.l10n.plansMarkAllPrevious),
                              ),
                            ),
                          for (var day = 1; day <= total; day++)
                            Builder(builder: (_) {
                              final done = plan.completedReadings.contains(day);
                              final missed = plan.missedDays.contains(day);
                              final isToday = day == current;
                              final date = dateMap[day];
                              final dateLabel = date == null
                                  ? context.l10n.plansDayN(day)
                                  : '${context.l10n.plansDayN(day)} · ${_weekdayName(appWeekday(date))} ${DateFormat.Md(Localizations.localeOf(context).toString()).format(date)}';
                              final summary = plan.planData[day - 1].passages
                                  .map((p) => p.label)
                                  .join(', ');
                              return _DayRow(
                                key: isToday ? _todayRowKey : null,
                                day: day,
                                dateLabel: dateLabel,
                                summary: summary,
                                done: done,
                                isToday: isToday,
                                isMissed: missed && !done,
                                isSelected: day == selected,
                                onTap: () {
                                  setState(() => _selectedDay = day);
                                  _reveal(_dayDetailKey);
                                },
                                onToggle: () {
                                  HapticFeedback.mediumImpact();
                                  if (done) {
                                    notifier.markReadingIncomplete(day);
                                  } else {
                                    notifier.markReadingComplete(day);
                                  }
                                },
                              );
                            }),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              _Legend(theme.primaryColor,
                                  context.l10n.plansLegendDone),
                              _Legend(null, context.l10n.plansLegendToday,
                                  ring: true),
                              _Legend(theme.colorScheme.error,
                                  context.l10n.plansLegendMissed),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Day detail ────────────────────────────────
                  Padding(
                    key: _dayDetailKey,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.reminderEnabled
                                      ? context.l10n.plansReminderAtTime(
                                          _fmtTime(plan.reminderTimeHour,
                                              plan.reminderTimeMinute))
                                      : context.l10n.plansReminderOff,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  context.l10n.plansReminderHelp,
                                  style: theme.textTheme.bodySmall?.copyWith(
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
                                      minute: plan.reminderTimeMinute),
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

  /// Short weekday name in the current locale for the app convention
  /// 1=Sun..7=Sat ('' when out of range).
  String _weekdayName(int appDay) {
    if (appDay < 1 || appDay > 7) return '';
    // 2024-01-07 was a Sunday.
    return DateFormat.E(Localizations.localeOf(context).toString())
        .format(DateTime(2024, 1, 6 + appDay));
  }

  /// 'None' or 'Sun, Wed' for the settings row.
  String _restSummary(ReadingPlanState plan) {
    if (plan.restDays.isNotEmpty) {
      final ordered = plan.restDays.toList()
        ..sort((a, b) => ((a + 6) % 7).compareTo((b + 6) % 7));
      return ordered.map(_weekdayName).join(', ');
    }
    return plan.restDay == null
        ? context.l10n.plansNone
        : _weekdayName(plan.restDay!);
  }

  /// Multi-select rest weekdays (app convention 1=Sun..7=Sat).
  /// Returns null when cancelled.
  Future<Set<int>?> _pickRestDays(
      BuildContext context, ReadingPlanState plan) async {
    final Set<int> selected = Set<int>.from(plan.restDays.isNotEmpty
        ? plan.restDays
        : {if (plan.restDay != null) plan.restDay!});
    return showDialog<Set<int>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.l10n.plansRestDays),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var d = 1; d <= 7; d++)
                  StatefulBuilder(builder: (ctx, setRowState) {
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_weekdayName(d)),
                      value: selected.contains(d),
                      onChanged: (v) {
                        setRowState(() {
                          if (v == true) {
                            selected.add(d);
                          } else {
                            selected.remove(d);
                          }
                        });
                      },
                    );
                  }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(ctx).pop(Set<int>.from(selected));
              },
              child: Text(selected.isEmpty
                  ? context.l10n.plansNoRestDays
                  : context.l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  String _fmtTime(int h, int m) =>
      TimeOfDay(hour: h, minute: m).format(context);

  PlanMetadata? _metadata() {
    for (final p in availablePlans) {
      if (p.id == widget.planId) return p;
    }
    return null;
  }

  void _showPlanSettings(dynamic plan) {
    final notifier = ref.read(readingPlanProvider(widget.planId).notifier);
    final meta = _metadata();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final p = ref.read(readingPlanProvider(widget.planId));
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              V2Eyebrow(context.l10n.plansSettings),
              if (meta?.attribution != null)
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(context.l10n.plansAboutEllipsis),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    showDialog<void>(
                      context: context,
                      builder: (d) => AlertDialog(
                        title: Text(meta?.title ?? context.l10n.plansAbout),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((meta?.description ?? '').isNotEmpty)
                                Text(meta!.description),
                              if ((meta?.attribution ?? '').isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  meta!.attribution!,
                                  style: Theme.of(d).textTheme.bodySmall,
                                ),
                              ],
                              if ((meta?.license ?? '').isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  meta!.license!,
                                  style:
                                      Theme.of(d).textTheme.bodySmall?.copyWith(
                                            fontStyle: FontStyle.italic,
                                          ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(d).pop(),
                            child: Text(context.l10n.commonClose),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.calendar_month_rounded),
                title: Text(context.l10n.plansChangeStartDate),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: p.planStartedOn ?? DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 730)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) notifier.setStartDate(picked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bedtime_rounded),
                title: Text(context.l10n.plansRestDaysValue(_restSummary(p))),
                subtitle: Text(context.l10n.plansRestDaysHelp),
                onTap: () async {
                  final picked = await _pickRestDays(context, p);
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  if (picked != null) notifier.setRestDays(picked);
                },
              ),
              ListTile(
                leading: Icon(Icons.restart_alt_rounded,
                    color: theme.colorScheme.error),
                title: Text(context.l10n.plansRestartFromDayOne,
                    style: TextStyle(color: theme.colorScheme.error)),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: Text(context.l10n.plansRestartTitle),
                      content: Text(context.l10n.plansRestartBody),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(d).pop(false),
                          child: Text(context.l10n.commonCancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(d).pop(true),
                          child: Text(context.l10n.plansRestart),
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

/// One readings-list row: status ring (check when done, day number
/// otherwise), date + passage summary, and a read/unread toggle.
/// Tap selects the day detail below; the toggle flips completion.
class _DayRow extends StatelessWidget {
  final int day;
  final String dateLabel;
  final String summary;
  final bool done;
  final bool isToday;
  final bool isMissed;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  const _DayRow({
    super.key,
    required this.day,
    required this.dateLabel,
    required this.summary,
    required this.done,
    required this.isToday,
    required this.isMissed,
    required this.isSelected,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = done
        ? theme.primaryColor
        : isMissed
            ? theme.colorScheme.error
            : isToday
                ? theme.primaryColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.35);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected
            ? theme.primaryColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? theme.primaryColor : Colors.transparent,
                    border: Border.all(
                      color: statusColor,
                      width: (isToday || done) ? 2 : 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: done
                      ? Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: theme.colorScheme.surface,
                        )
                      : Text(
                          '$day',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: (isToday || isMissed)
                                ? statusColor
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.65),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dateLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: done
                      ? context.l10n.plansMarkUnread
                      : context.l10n.plansMarkRead,
                  icon: Icon(
                    done ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: done
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                  onPressed: onToggle,
                ),
              ],
            ),
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
  const _Legend(this.color, this.text, {this.ring = false});

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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    final notifier = ref.read(readingPlanProvider(widget.planId).notifier);
    final done = plan.completedReadings.contains(widget.day);

    final dayData = plan.planData.length >= widget.day && widget.day >= 1
        ? plan.planData[widget.day - 1]
        : null;

    if (widget.isRest || dayData == null) {
      return V2Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            V2Eyebrow(context.l10n.plansRestAndReflect),
            const SizedBox(height: 6),
            Text(
              context.l10n.plansRestDayBody,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final dateLabel = widget.date == null
        ? ''
        : ' · ${DateFormat.Md(Localizations.localeOf(context).toString()).format(widget.date!)}';
    return V2Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2Eyebrow('${context.l10n.plansDayN(widget.day)}$dateLabel'),
          const SizedBox(height: 6),
          Text(
            dayData.passages.map((p) => p.label).join(' · '),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.plansDayDetailHelp,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                  final markedComplete = await Navigator.of(context).push<bool>(
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
                        : theme.colorScheme.onSurface.withValues(alpha: 0.03),
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
                                size: 16, color: theme.colorScheme.surface)
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
                  final completed = plan.completedReadings.length + 1;
                  if (completed % 30 == 0 && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '🎉 ${context.l10n.plansMilestone(completed)}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(done
                  ? '✓ ${context.l10n.plansCompletedTapToUndo}'
                  : context.l10n.plansMarkDayRead(
                      widget.day, _checked.length, dayData.passages.length)),
            ),
          ),
        ],
      ),
    );
  }
}
