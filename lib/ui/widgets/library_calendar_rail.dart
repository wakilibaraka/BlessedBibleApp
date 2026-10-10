import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../state/reading_plan_provider.dart';
import 'study_v2_widgets.dart';
import '../../l10n/l10n.dart';

/// Short, upper-cased weekday name for [day] in the current locale.
String _weekdayShort(BuildContext context, DateTime day) =>
    DateFormat.E(Localizations.localeOf(context).toString())
        .format(day)
        .toUpperCase();

/// Monday-first week containing [day].
List<DateTime> libraryWeekDays(DateTime day) {
  final monday = DateTime(day.year, day.month, day.day)
      .subtract(Duration(days: day.weekday - 1));
  return List.generate(7, (i) => monday.add(Duration(days: i)));
}

/// Weeks of runway kept before/after today.
const int kCalendarWeekWindow = 26;

/// Slidable week calendar for the Plans Library.
///
/// One page = one week, snapped, windowed +/- [kCalendarWeekWindow]
/// weeks around today so paging is bounded and the initial page is a
/// plain index. Day cells carry a completion dot sourced from the active
/// plan, which makes the rail double as a progress view.
class LibraryCalendarRail extends StatefulWidget {
  final DateTime today;

  /// Plan driving completion dots (null = no plan, no dots).
  final ReadingPlanState? plan;

  const LibraryCalendarRail({super.key, required this.today, this.plan});

  @override
  State<LibraryCalendarRail> createState() => LibraryCalendarRailState();
}

class LibraryCalendarRailState extends State<LibraryCalendarRail> {
  late final DateTime _anchor;
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _anchor = libraryWeekDays(widget.today).first;
    _index =
        _weeksBetween(_anchor, widget.today).clamp(0, kCalendarWeekWindow * 2);
    _controller = PageController(initialPage: _index);
  }

  @override
  void didUpdateWidget(LibraryCalendarRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Plan changes only affect the dots (a plain rebuild). A new "today"
    // (app resumed next day) re-centers the rail.
    if (oldWidget.today != widget.today) {
      final next = _weeksBetween(_anchor, widget.today)
          .clamp(0, kCalendarWeekWindow * 2);
      if (_controller.hasClients) _controller.jumpToPage(next);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static int _weeksBetween(DateTime a, DateTime b) =>
      (DateTime(b.year, b.month, b.day)
          .difference(DateTime(a.year, a.month, a.day))
          .inDays) ~/
      7;

  int get _lastIndex => kCalendarWeekWindow * 2;

  DateTime get _visibleWeekStart =>
      _anchor.add(Duration(days: 7 * _index.clamp(0, _lastIndex)));

  /// Jumps the rail to the week containing [day].
  void scrollToDate(DateTime day) => _goTo(day);

  void _goTo(DateTime day) {
    final next = _weeksBetween(_anchor, day).clamp(0, _lastIndex);
    if (next == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = next);
    if (_controller.hasClients) {
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Plan day number (1-based) for [day], or null when outside the plan.
  static int? _planDayFor(ReadingPlanState? plan, DateTime day) {
    final start = plan?.planStartedOn;
    if (plan == null || start == null || plan.planData.isEmpty) return null;
    final diff = DateTime(day.year, day.month, day.day)
        .difference(DateTime(start.year, start.month, start.day))
        .inDays;
    if (diff < 0) return null;
    final n = diff + 1;
    return n <= plan.planData.length ? n : null;
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Row(
      children: [
        _StepButton(
          icon: Icons.chevron_left_rounded,
          enabled: _index > 0,
          onTap: () =>
              _goTo(_visibleWeekStart.subtract(const Duration(days: 7))),
        ),
        Expanded(
          // Deliberately flat: this is header chrome in a fixed-height
          // rail, and the surface container's 300ms fade would fight
          // page snapping.
          child: V2Card(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: SizedBox(
              height: 64,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _index = i);
                },
                itemBuilder: (context, page) {
                  final weekStart = _anchor.add(Duration(days: 7 * page));
                  return Row(
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: Builder(builder: (_) {
                            final day = weekStart.add(Duration(days: i));
                            final planDay = _planDayFor(plan, day);
                            return _DayCell(
                              day: day,
                              today: widget.today,
                              planDay: planDay,
                              complete: planDay != null &&
                                  plan!.isDayComplete(planDay),
                            );
                          }),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        _StepButton(
          icon: Icons.chevron_right_rounded,
          enabled: _index < _lastIndex,
          onTap: () => _goTo(_visibleWeekStart.add(const Duration(days: 7))),
        ),
      ],
    );
  }
}

/// One day: number over weekday label, today in accent, dot when the
/// plan's reading for that date is complete.
class _DayCell extends StatelessWidget {
  final DateTime day;
  final DateTime today;
  final int? planDay;
  final bool complete;

  const _DayCell({
    required this.day,
    required this.today,
    this.planDay,
    this.complete = false,
  });

  String _dayLabel(BuildContext context, bool isToday) {
    final l10n = context.l10n;
    var label = '${_weekdayShort(context, day)} ${day.day}';
    if (complete) label = l10n.plansCalendarDayComplete(label);
    if (isToday) label = l10n.plansCalendarDayToday(label);
    return label;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
    final inFuture = day.isAfter(today);
    final color = isToday
        ? theme.primaryColor
        : theme.colorScheme.onSurface.withValues(alpha: inFuture ? 0.3 : 0.5);
    return Semantics(
      label: _dayLabel(context, isToday),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              _weekdayShort(context, day),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 0.5,
                fontSize: 9,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            // 6pt dot: filled = read, hollow = scheduled, none = off-plan.
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: complete ? theme.primaryColor : Colors.transparent,
                border: (planDay != null && !complete)
                    ? Border.all(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.28),
                        width: 1,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      enabled: enabled,
      label: context.l10n.plansChangeWeek,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          // 44pt target with the icon centered.
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 22,
              color: enabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
    );
  }
}
