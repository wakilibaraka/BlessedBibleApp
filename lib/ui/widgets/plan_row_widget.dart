import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/reading_plan_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../screens/reading_plan_browser.dart';
import '../screens/study_reader_screen.dart';
import '../sheets/custom_plan_action_sheet.dart';
import '../sheets/curated_plan_action_sheet.dart';
import '../screens/plans_hub_v2_screen.dart';

class PlanRowWidget extends ConsumerStatefulWidget {
  final String planId;
  const PlanRowWidget({super.key, required this.planId});

  @override
  ConsumerState<PlanRowWidget> createState() => _PlanRowWidgetState();
}

class _PlanRowWidgetState extends ConsumerState<PlanRowWidget> {
  double _lastPct = 0.0;
  bool _isInit = false;

  String _getPlanTitle(String planId, WidgetRef ref) {
    for (final p in availablePlans) {
      if (p.id == planId) return p.title;
    }
    final customPlan = ref.read(preferencesProvider).getCustomPlan(planId);
    return customPlan?['title'] ?? 'Custom Plan';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final planId = widget.planId;
    final planState = ref.watch(readingPlanProvider(planId));
    final title = _getPlanTitle(planId, ref);
    final pct = planState.percentComplete;

    if (!_isInit) {
      _lastPct = pct;
      _isInit = true;
    }
    final beginPct = _lastPct;
    _lastPct = pct;

    final currentDay = planState.currentDay;
    final totalDays = planState.planData.length;
    final isDoneToday = planState.completedReadings.contains(currentDay);

    String passagesSummary = '';
    if (currentDay > 0 && currentDay <= totalDays) {
      final dayData = planState.planData[currentDay - 1];
      if (dayData.passages.isEmpty) {
        passagesSummary = 'Rest & Reflection day';
      } else {
        passagesSummary = dayData.passages.map((p) => p.label).join(', ');
      }
    } else if (planState.isPlanComplete) {
      passagesSummary = 'All readings completed! Congratulations!';
    } else {
      passagesSummary = 'Ready to begin reading.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onLongPress: () async {
            final prefs = ref.read(preferencesProvider);
            if (prefs.getCustomPlanIds().contains(planId)) {
              await CustomPlanActionSheet.show(context, ref, planId);
              if (mounted) setState(() {});
            } else {
              await CuratedPlanActionSheet.show(context, ref, planId);
            }
          },
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (_) => ReadingPlanBrowser(planId: planId),
            ));
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title, Day Badge, Overflow options
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: gold.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  planState.isPlanComplete
                                      ? 'Completed'
                                      : 'Day $currentDay of $totalDays',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: gold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(pct * 100).toStringAsFixed(0)}% done',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      onPressed: () async {
                        final prefs = ref.read(preferencesProvider);
                        if (prefs.getCustomPlanIds().contains(planId)) {
                          await CustomPlanActionSheet.show(context, ref, planId);
                          if (mounted) setState(() {});
                        } else {
                          await CuratedPlanActionSheet.show(context, ref, planId);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Animated Linear Progress Bar
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: beginPct, end: pct),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: value.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: gold.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(gold),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // Bottom Action & Assigned Passages Box
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDoneToday
                            ? Icons.check_circle_rounded
                            : Icons.menu_book_rounded,
                        size: 20,
                        color: isDoneToday
                            ? Colors.green
                            : gold.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDoneToday ? "Today's Reading Done" : "Today's Reading",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDoneToday
                                    ? Colors.green
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              passagesSummary,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDoneToday
                                    ? theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6)
                                    : theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () {
                          if (currentDay > 0 && currentDay <= totalDays) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudyReaderScreen(
                                  payload: StudySessionPayload.plan(
                                    planId: planId,
                                    dayNum: currentDay,
                                    initialPassageIndex: 0,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(CupertinoPageRoute(
                              builder: (_) => ReadingPlanBrowser(planId: planId),
                            ));
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: isDoneToday
                              ? theme.colorScheme.surface
                              : gold,
                          foregroundColor: isDoneToday
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          minimumSize: const Size(60, 34),
                          elevation: 0,
                          side: isDoneToday
                              ? BorderSide(
                                  color: theme.dividerColor
                                      .withValues(alpha: 0.2))
                              : BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isDoneToday ? 'Review' : 'Read',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
