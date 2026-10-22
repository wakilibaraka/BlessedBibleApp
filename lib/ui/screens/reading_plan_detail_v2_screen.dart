import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';

import '../../state/reading_plan_provider.dart'
    show
        readingPlanProvider,
        activePlanIdsProvider,
        appWeekday,
        ReadingPlanState;
import '../../state/theme_provider.dart';
import '../widgets/plan_flow.dart';
import '../widgets/plans_library_widgets.dart'
    show PlanCoverPlaceholder, planInitials;
import '../widgets/shared_app_bar.dart';
import '../widgets/state_views.dart';
import '../widgets/study_v2_widgets.dart';
import 'journey_map_screen.dart';
import '../../data/curated_plans.dart';
import '../../theme/design_tokens.dart';

/// Plan page (V2): one screen for a plan before and after it starts.
///
/// Replaces the separate "Begin plan" screen and the old detail layout:
/// - Not started: the first day's reading with "Start & read day 1" and
///   an inline start date, then a preview of every day.
/// - Started: a slim progress strip, a hero that always holds the next
///   thing to read (today, the oldest missed day, or read-ahead), then
///   the readings list opened at that day.
/// Every Read action opens the reader directly; the reader marks the day
/// complete itself. Pace, reminder, rest days and restart live in the
/// settings sheet (⋯) so the page stays short.
///
/// Mapping notes kept from V1:
/// - Weekdays use [appWeekday] (Sun=1..Sat=7).
/// - Rest "None" uses the `-1` sentinel required by `copyWith`.
class ReadingPlanDetailV2Screen extends ConsumerStatefulWidget {
  final String planId;
  const ReadingPlanDetailV2Screen({super.key, required this.planId});

  @override
  ConsumerState<ReadingPlanDetailV2Screen> createState() =>
      _ReadingPlanDetailV2ScreenState();
}

class _ReadingPlanDetailV2ScreenState
    extends ConsumerState<ReadingPlanDetailV2Screen> {
  DateTime? _pendingStartDate;

  /// When false the list opens one day before the hero's day.
  bool _showEarlier = false;

  String get _locale => Localizations.localeOf(context).toString();

  String _title() => planTitleFor(ref, widget.planId);

  PlanMetadata? _metadata() {
    for (final p in availablePlans) {
      if (p.id == widget.planId) return p;
    }
    return null;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Maps reading-day number -> calendar date, skipping rest weekdays.
  Map<int, DateTime> _dateMap(
      DateTime start, bool Function(int appWeekday) isRest, int total) {
    final map = <int, DateTime>{};
    var date = _dateOnly(start);
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

  Future<void> _pickPendingStart(DateTime current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _pendingStartDate = picked);
  }

  /// Starts the plan (and adds it to the active list so the Study widget
  /// and Plans hero pick it up), then opens day 1 unless it starts later.
  void _start(DateTime start) {
    final added =
        ref.read(activePlanIdsProvider.notifier).addPlan(widget.planId);
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.plansSlotsFull(3)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref.read(readingPlanProvider(widget.planId).notifier).startPlan(
          planId: widget.planId,
          paceMode: 'scheduled',
          startDate: start,
        );
    unawaited(HapticFeedback.mediumImpact());
    if (!_dateOnly(start).isAfter(_dateOnly(DateTime.now()))) {
      openPlanDay(context, widget.planId, 1);
    }
  }

  /// Shifts the start date forward by [behind] reading days so missed
  /// days become future days (completed days are untouched).
  Future<void> _rebase(int behind) async {
    final plan = ref.read(readingPlanProvider(widget.planId));
    final start = plan.planStartedOn;
    if (start == null) return;
    var shifted = _dateOnly(start);
    var moved = 0;
    var guard = 0;
    while (moved < behind && guard < behind + 370) {
      guard++;
      shifted = shifted.add(const Duration(days: 1));
      if (!plan.isRestWeekday(appWeekday(shifted))) moved++;
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

  void _markAllPrevious(ReadingPlanState plan, int current) {
    final newly = List.generate(current - 1, (i) => i + 1)
        .where((d) => !plan.isDayComplete(d))
        .length;
    ref
        .read(readingPlanProvider(widget.planId).notifier)
        .markAllPreviousRead(current);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newly == 0
            ? context.l10n.plansAllPreviousDone
            : context.l10n.plansPreviousMarked(newly)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(readingPlanProvider(widget.planId));
    final appThemeMode = ref.watch(themeProvider);

    Widget shell(Widget body, {List<Widget>? actions}) => V2PageShell(
          appThemeMode: appThemeMode,
          page: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: SharedAppBar(actions: actions),
            body: body,
          ),
        );

    if (plan.isLoading) return shell(const LoadingView());

    if (plan.error != null) {
      // The provider's message carries exception text, so show a plain
      // line instead.
      return shell(ErrorState(
        message: context.l10n.plansDetailLoadFailed,
        onRetry: () => ref.invalidate(readingPlanProvider(widget.planId)),
      ));
    }

    final total = plan.planData.length;
    final started = plan.planStartedOn != null;
    final start = started
        ? plan.planStartedOn!
        : (_pendingStartDate ?? _dateOnly(DateTime.now()));
    final dateMap = _dateMap(start, plan.isRestWeekday, total);
    final int current =
        total == 0 ? 1 : (plan.todayReadingDay ?? total).clamp(1, total);
    final target = started ? planTarget(plan) : null;
    final anchor = target == null ? 1 : math.min(target.day, current);
    final firstDay = (!started || _showEarlier) ? 1 : math.max(1, anchor - 1);
    final hasSettings = started || _metadata()?.attribution != null;

    final header = <Widget>[
      _PlanHeader(
        seed: widget.planId,
        title: _title(),
        meta: total == 0
            ? context.l10n.plansNoReadingsYet
            : context.l10n.plansReadingDaysWeeks(total, (total / 7).ceil()),
      ),
      if (started && total > 0) ...[
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: V2ProgressBar(fraction: plan.percentComplete)),
            const SizedBox(width: 10),
            Text(
              context.l10n.plansDayOfTotal(current, total),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.palette.textMuted,
                  ),
            ),
            const SizedBox(width: 8),
            PlanStatusChip(plan: plan),
          ],
        ),
      ],
      const SizedBox(height: 16),
      if (total > 0)
        V2Card(
          textured: true,
          featured: true,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: started
              ? PlanTodayPanel(
                  planId: widget.planId,
                  footer: [
                    if (target!.kind == PlanTargetKind.catchUp)
                      _CatchUpActions(
                        behind: plan.missedDays.length,
                        oldest: target.day,
                        onMarkAll: () => _markAllPrevious(plan, current),
                        onShift: () => _rebase(plan.missedDays.length),
                      ),
                  ],
                )
              : _BeginPanel(
                  dayLabel: planDayLabel(plan, 1),
                  passages: plan.planData.first.passages.length,
                  start: start,
                  onStart: () => _start(start),
                  onChangeDate: () => _pickPendingStart(start),
                ),
        ),
      if (total > 0) ...[
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: _InlineLabel(context.l10n.plansReadingsHeader(total))),
            IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: context.l10n.plansJourneyMap,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => JourneyMapScreen(planId: widget.planId),
                  ),
                );
              },
            ),
          ],
        ),
        if (firstDay > 1)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _showEarlier = true),
              icon: const Icon(Icons.expand_less_rounded, size: 20),
              label: Text(context.l10n.planFlowShowEarlier(firstDay - 1)),
            ),
          ),
        const SizedBox(height: 4),
      ],
    ];

    final theme = Theme.of(context);
    final rowCount = total == 0 ? 0 : total - firstDay + 1;
    final missed = plan.missedDays;

    return shell(
      SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  sliver: SliverList.list(children: header),
                ),
                if (rowCount > 0)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    // Lazy rows: a 365-day plan builds only what is on
                    // screen (the old list built every row up front).
                    sliver: DecoratedSliver(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(Radii.xxl),
                        border: Border.all(color: context.palette.divider),
                      ),
                      sliver: SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 6),
                        sliver: SliverList.builder(
                          itemCount: rowCount,
                          itemBuilder: (context, i) {
                            final day = firstDay + i;
                            final done = started && plan.isDayComplete(day);
                            final date = dateMap[day];
                            return _DayRow(
                              day: day,
                              summary: planDayLabel(plan, day),
                              dateLabel: date == null
                                  ? ''
                                  : DateFormat.MMMEd(_locale).format(date),
                              done: done,
                              isTarget: started && day == target!.day,
                              isMissed: missed.contains(day),
                              showDivider: i < rowCount - 1,
                              onTap: () =>
                                  openPlanDay(context, widget.planId, day),
                              onToggle: !started
                                  ? null
                                  : () {
                                      HapticFeedback.mediumImpact();
                                      final n = ref.read(
                                          readingPlanProvider(widget.planId)
                                              .notifier);
                                      if (done) {
                                        n.markReadingIncomplete(day);
                                      } else {
                                        n.markReadingComplete(day);
                                      }
                                    },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (hasSettings)
          IconButton(
            tooltip: context.l10n.plansSettings,
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => _showPlanSettings(started),
          ),
      ],
    );
  }

  /// Short weekday name in the current locale for the app convention
  /// 1=Sun..7=Sat ('' when out of range).
  String _weekdayName(int appDay) {
    if (appDay < 1 || appDay > 7) return '';
    // 2024-01-07 was a Sunday.
    return DateFormat.E(_locale).format(DateTime(2024, 1, 6 + appDay));
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

  void _showAbout(PlanMetadata meta) {
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(meta.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meta.description.isNotEmpty) Text(meta.description),
              if ((meta.attribution ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(meta.attribution!, style: Theme.of(d).textTheme.bodySmall),
              ],
              if ((meta.license ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  meta.license!,
                  style: Theme.of(d).textTheme.bodySmall?.copyWith(
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
  }

  /// Settings sheet: pace and reminder (moved off the page), then start
  /// date, rest days, about and restart. Watches the plan so toggles
  /// update in place.
  void _showPlanSettings(bool started) {
    final notifier = ref.read(readingPlanProvider(widget.planId).notifier);
    final meta = _metadata();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(builder: (ctx, ref, _) {
        final theme = Theme.of(ctx);
        final p = ref.watch(readingPlanProvider(widget.planId));
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: Radii.sheet,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      margin: const EdgeInsets.only(top: 6, bottom: 10),
                      decoration: BoxDecoration(
                        color: ctx.palette.divider,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: V2Eyebrow(context.l10n.plansSettings),
                  ),
                  if (started) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Text(
                        context.l10n.planFlowPace,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: 'scheduled',
                            label: Text(context.l10n.plansScheduled),
                            icon: const Icon(Icons.event_rounded),
                          ),
                          ButtonSegment(
                            value: 'flexible',
                            label: Text(context.l10n.plansFlexible),
                            icon: const Icon(Icons.all_inclusive_rounded),
                          ),
                        ],
                        selected: {p.paceMode},
                        onSelectionChanged: (s) {
                          HapticFeedback.selectionClick();
                          notifier.setPaceMode(s.first);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: Text(
                        p.paceMode == 'flexible'
                            ? context.l10n.plansFlexibleHelp
                            : context.l10n.plansScheduledHelp,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ctx.palette.textMuted,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: Text(p.reminderEnabled
                          ? context.l10n.plansReminderAtTime(_fmtTime(
                              p.reminderTimeHour, p.reminderTimeMinute))
                          : context.l10n.plansReminderOff),
                      subtitle: Text(context.l10n.plansReminderHelp),
                      value: p.reminderEnabled,
                      onChanged: (v) async {
                        if (v) {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay(
                                hour: p.reminderTimeHour,
                                minute: p.reminderTimeMinute),
                          );
                          if (picked == null) return;
                          notifier.setReminder(
                              true, picked.hour, picked.minute);
                        } else {
                          notifier.setReminder(
                              false, p.reminderTimeHour, p.reminderTimeMinute);
                        }
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
                          context.l10n.plansRestDaysValue(_restSummary(p))),
                      subtitle: Text(context.l10n.plansRestDaysHelp),
                      onTap: () async {
                        final picked = await _pickRestDays(context, p);
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        if (picked != null) notifier.setRestDays(picked);
                      },
                    ),
                  ],
                  if (meta?.attribution != null)
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(context.l10n.plansAboutEllipsis),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _showAbout(meta!);
                      },
                    ),
                  if (started)
                    ListTile(
                      leading: Icon(Icons.restart_alt_rounded,
                          color: ctx.palette.danger),
                      title: Text(context.l10n.plansRestartFromDayOne,
                          style: TextStyle(color: ctx.palette.danger)),
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
                                child: Text(
                                  context.l10n.plansRestart,
                                  style: TextStyle(color: d.palette.danger),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) notifier.restartPlan();
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Muted uppercase label without [V2SectionLabel]'s top padding, for
/// rows that also hold an action.
class _InlineLabel extends StatelessWidget {
  final String text;
  const _InlineLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: context.palette.textMuted,
          ),
    );
  }
}

/// Cover, title and length.
class _PlanHeader extends StatelessWidget {
  final String seed;
  final String title;
  final String meta;
  const _PlanHeader(
      {required this.seed, required this.title, required this.meta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        PlanCoverPlaceholder(
          seed: seed,
          initials: planInitials(title),
          width: 60,
          height: 60,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meta,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.palette.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Not-started hero: day 1, one button, and the start date inline.
class _BeginPanel extends StatelessWidget {
  final String dayLabel;
  final int passages;
  final DateTime start;
  final VoidCallback onStart;
  final VoidCallback onChangeDate;
  const _BeginPanel({
    required this.dayLabel,
    required this.passages,
    required this.start,
    required this.onStart,
    required this.onChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(start.year, start.month, start.day);
    final later = day.isAfter(today);
    final dateText = DateFormat.MMMEd(locale).format(day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        V2Eyebrow(l10n.plansDayN(1)),
        const SizedBox(height: 4),
        Text(
          dayLabel,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        if (passages > 1) ...[
          const SizedBox(height: 2),
          Text(
            l10n.planFlowPassages(passages),
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.palette.textMuted,
            ),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: onStart,
            style: planFilledStyle(context),
            icon: Icon(
              later ? Icons.event_available_rounded : Icons.menu_book_rounded,
              size: 20,
            ),
            label: Text(later
                ? l10n.planFlowStartOn(dateText)
                : l10n.planFlowStartAndRead),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 16, color: context.palette.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                day == today
                    ? l10n.planFlowStartsToday
                    : l10n.planFlowStartsOn(dateText),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.palette.textMuted,
                ),
              ),
            ),
            TextButton(
              onPressed: onChangeDate,
              child: Text(
                l10n.planFlowChangeDate,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Under the catch-up hero: what happened and the two ways out.
class _CatchUpActions extends StatelessWidget {
  final int behind;
  final int oldest;
  final VoidCallback onMarkAll;
  final VoidCallback onShift;
  const _CatchUpActions({
    required this.behind,
    required this.oldest,
    required this.onMarkAll,
    required this.onShift,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.plansBehindBy(behind, oldest),
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.palette.textMuted,
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              TextButton(
                onPressed: onMarkAll,
                child: Text(context.l10n.plansMarkAllPrevious,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              TextButton(
                onPressed: onShift,
                child: Text(context.l10n.plansRebaseDays(behind),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One readings row: status dot, passages on one line, date, and a
/// read/unread toggle. Tapping the row opens the reader on that day.
class _DayRow extends StatelessWidget {
  final int day;
  final String summary;
  final String dateLabel;
  final bool done;
  final bool isTarget;
  final bool isMissed;
  final bool showDivider;
  final VoidCallback onTap;

  /// Null before the plan starts (nothing to tick yet).
  final VoidCallback? onToggle;

  const _DayRow({
    required this.day,
    required this.summary,
    required this.dateLabel,
    required this.done,
    required this.isTarget,
    required this.isMissed,
    required this.showDivider,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final accent = theme.primaryColor;
    final Color ring = done
        ? accent
        : isMissed
            ? palette.warning
            : isTarget
                ? accent
                : palette.divider;
    return Material(
      color: isTarget ? accent.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.lg),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: showDivider && !isTarget
                ? Border(bottom: BorderSide(color: palette.divider, width: 0.5))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? accent : Colors.transparent,
                  border: Border.all(
                      color: ring, width: (isTarget || done) ? 2 : 1.5),
                ),
                child: done
                    ? Icon(Icons.check_rounded,
                        size: 18, color: palette.onAccent)
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            '$day',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: (isTarget || isMissed)
                                  ? ring
                                  : palette.textMuted,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isTarget ? FontWeight.w800 : FontWeight.w600,
                          color: done ? palette.textMuted : null,
                        ),
                      ),
                      if (dateLabel.isNotEmpty)
                        Text(
                          '${context.l10n.plansDayN(day)} · $dateLabel',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isTarget ? accent : palette.textFaint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (onToggle != null)
                IconButton(
                  tooltip: done
                      ? context.l10n.plansMarkUnread
                      : context.l10n.plansMarkRead,
                  icon: Icon(
                    done ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: done ? accent : palette.textFaint,
                  ),
                  onPressed: onToggle,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right_rounded,
                      color: palette.textFaint),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
