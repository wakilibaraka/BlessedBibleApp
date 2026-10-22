import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/curated_plans.dart';
import '../../data/local_storage/preferences_service.dart';
import '../../l10n/l10n.dart';
import '../../state/reading_plan_provider.dart';
import '../../theme/design_tokens.dart';
import '../screens/study_reader_screen.dart';

/// Shared pieces of the reading-plan flow:
/// Study widget -> Plans page -> Plan page -> reader.
///
/// Every "Read" button in the flow resolves its day through [planTarget],
/// so the Study widget, the Plans hero and the Plan page always agree on
/// what to read next, and each opens the reader directly.

enum PlanTargetKind {
  /// Today's scheduled (or, when flexible, next unread) day.
  today,

  /// Scheduled plan with missed days: the oldest one.
  catchUp,

  /// Today is done; [PlanTarget.day] is the next unread day, if any.
  doneToday,

  /// Every day is complete.
  complete,
}

class PlanTarget {
  final int day;
  final PlanTargetKind kind;
  const PlanTarget(this.day, this.kind);
}

/// The day a plan's primary action should open.
PlanTarget planTarget(ReadingPlanState s) {
  final total = s.planData.length;
  if (total == 0) return const PlanTarget(1, PlanTargetKind.today);
  if (s.isComplete) return PlanTarget(total, PlanTargetKind.complete);
  final current = (s.todayReadingDay ?? total).clamp(1, total);
  final missed = s.missedDays;
  if (missed.isNotEmpty) {
    return PlanTarget(
        missed.reduce((a, b) => a < b ? a : b), PlanTargetKind.catchUp);
  }
  if (s.isDayComplete(current)) {
    for (var d = current + 1; d <= total; d++) {
      if (!s.isDayComplete(d)) return PlanTarget(d, PlanTargetKind.doneToday);
    }
    return PlanTarget(s.oldestUnread, PlanTargetKind.doneToday);
  }
  return PlanTarget(current, PlanTargetKind.today);
}

/// "Genesis 1 · Psalm 1" for [day], '' when out of range.
String planDayLabel(ReadingPlanState s, int day) {
  if (day < 1 || day > s.planData.length) return '';
  return s.planData[day - 1].passages.map((p) => p.label).join(' · ');
}

/// Display title for a curated or custom plan id.
String planTitleFor(WidgetRef ref, String id) {
  for (final p in availablePlans) {
    if (p.id == id) return p.title;
  }
  try {
    final custom = ref.read(preferencesProvider).getCustomPlan(id);
    final title = custom?['title'] as String?;
    if (title != null && title.isNotEmpty) return title;
  } catch (_) {}
  return id.replaceAll('_', ' ');
}

/// Opens the reader on [day]. The reader marks the day complete itself.
Future<void> openPlanDay(BuildContext context, String planId, int day) {
  HapticFeedback.selectionClick();
  return Navigator.of(context).push(CupertinoPageRoute<void>(
    builder: (_) => StudyReaderScreen(
      payload: StudySessionPayload.plan(planId: planId, dayNum: day),
    ),
  ));
}

/// Solid accent button. Built from the theme accent rather than the
/// Material colour scheme, whose secondary colours drift from the accent
/// in some themes (teal tonal buttons on the gold light theme).
ButtonStyle planFilledStyle(BuildContext context) {
  final theme = Theme.of(context);
  final accent = theme.primaryColor;
  return FilledButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: AppPalette.onColor(accent),
    // Keep the theme's button font; only the weight changes.
    textStyle:
        theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
  );
}

/// Soft accent button for secondary actions (Review, Read ahead, Start).
ButtonStyle planTonalStyle(BuildContext context) {
  final theme = Theme.of(context);
  final accent = theme.primaryColor;
  return FilledButton.styleFrom(
    backgroundColor: accent.withValues(alpha: 0.14),
    foregroundColor: accent,
    textStyle:
        theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
  );
}

/// Today's reading for one plan: an eyebrow that names the state, the
/// passages, and one button. Used inline on the Study widget and the
/// Plans hero ([compact]) and as the Plan page hero (full).
class PlanTodayPanel extends ConsumerWidget {
  final String planId;

  /// Row layout with a trailing button instead of a full-width one.
  final bool compact;

  /// Muted line under the passages, e.g. the plan title on the Plans page.
  final String? caption;

  /// Extra widgets under the button (catch-up actions on the Plan page).
  final List<Widget> footer;

  const PlanTodayPanel({
    super.key,
    required this.planId,
    this.compact = false,
    this.caption,
    this.footer = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final l10n = context.l10n;
    final plan = ref.watch(readingPlanProvider(planId));
    if (plan.planData.isEmpty) {
      return Text(l10n.studyReadyToBegin, style: theme.textTheme.bodyMedium);
    }
    final target = planTarget(plan);

    final String eyebrow;
    final Color tone;
    switch (target.kind) {
      case PlanTargetKind.today:
        eyebrow = l10n.planFlowTodayDay(target.day);
        tone = theme.primaryColor;
      case PlanTargetKind.catchUp:
        eyebrow = l10n.planFlowCatchUpDay(target.day);
        tone = palette.warning;
      case PlanTargetKind.doneToday:
        eyebrow = l10n.planFlowDoneToday;
        tone = palette.success;
      case PlanTargetKind.complete:
        eyebrow = l10n.planFlowPlanComplete;
        tone = palette.success;
    }

    final String body;
    if (target.kind == PlanTargetKind.complete) {
      body = l10n.planFlowPlanCompleteBody;
    } else if (target.kind == PlanTargetKind.doneToday) {
      body =
          '${l10n.planFlowNextDay(target.day)} · ${planDayLabel(plan, target.day)}';
    } else {
      body = planDayLabel(plan, target.day);
    }
    final passages = target.day <= plan.planData.length
        ? plan.planData[target.day - 1].passages.length
        : 0;

    final String? cta = switch (target.kind) {
      PlanTargetKind.today => compact ? l10n.studyRead : l10n.planFlowReadToday,
      PlanTargetKind.catchUp =>
        compact ? l10n.studyRead : l10n.planFlowReadDay(target.day),
      PlanTargetKind.doneToday => l10n.planFlowReadAhead,
      PlanTargetKind.complete => null,
    };
    void read() => openPlanDay(context, planId, target.day);
    final primary = target.kind == PlanTargetKind.today ||
        target.kind == PlanTargetKind.catchUp;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          eyebrow.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: tone,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: (compact
                  ? theme.textTheme.bodyMedium
                  : theme.textTheme.titleMedium)
              ?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
        ),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(
            caption!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (!compact &&
            passages > 1 &&
            target.kind != PlanTargetKind.complete) ...[
          const SizedBox(height: 2),
          Text(
            l10n.planFlowPassages(passages),
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.textMuted,
            ),
          ),
        ],
      ],
    );

    if (compact) {
      return Row(
        children: [
          Expanded(child: text),
          if (cta != null) ...[
            const SizedBox(width: 10),
            FilledButton(
              onPressed: read,
              style:
                  primary ? planFilledStyle(context) : planTonalStyle(context),
              child: Text(cta),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        text,
        if (cta != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: read,
              style:
                  primary ? planFilledStyle(context) : planTonalStyle(context),
              icon: Icon(
                primary ? Icons.menu_book_rounded : Icons.arrow_forward_rounded,
                size: 20,
              ),
              label: Text(cta),
            ),
          ),
        ],
        ...footer,
      ],
    );
  }
}

/// Plan status pill: on track (success), N behind (warning), complete.
class PlanStatusChip extends StatelessWidget {
  final ReadingPlanState plan;
  const PlanStatusChip({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final behind = plan.missedDays.length;
    final (String label, Color tone) = plan.isComplete
        ? (l10n.plansComplete, palette.success)
        : behind > 0
            ? (l10n.plansBehindChip(behind), palette.warning)
            : ('${l10n.plansOnTrack} ✓', palette.success);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: tone,
            ),
      ),
    );
  }
}

/// Inset well that holds a [PlanTodayPanel] inside a larger card.
class PlanTodayWell extends StatelessWidget {
  final Widget child;
  const PlanTodayWell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}

/// Small "Label →" link in the accent colour.
class PlanLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PlanLink({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(kMinTouchTarget, kMinTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: Text(
        context.l10n.studyCtaArrow(label),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}
