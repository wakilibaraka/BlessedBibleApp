import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/reading_plan_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../screens/reading_plan_browser.dart';
import '../sheets/custom_plan_action_sheet.dart';
import '../sheets/curated_plan_action_sheet.dart';

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
    if (planId == 'chronological_1yr') return 'Chronological — Bible in a Year';
    if (planId == 'great_controversy') return 'The Great Controversy';
    if (planId == 'prophetic_timeline') return 'Prophetic Timeline';
    final customPlan = ref.read(preferencesProvider).getCustomPlan(planId);
    return customPlan?['title'] ?? 'Custom Plan';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    String subtitle =
        'Day ${planState.currentDay} of ${planState.planData.length}';
    if (planState.currentDay > 0 &&
        planState.currentDay <= planState.planData.length) {
      final dayData = planState.planData[planState.currentDay - 1];
      if (dayData.passages.isEmpty) {
        subtitle = 'Today: Rest & Reflection';
      } else {
        subtitle = 'Today: ${dayData.passages.first.label}';
        if (dayData.passages.length > 1) {
          subtitle += ' + ${dayData.passages.length - 1} more';
        }
      }
    } else if (planState.currentDay == 0) {
      subtitle = 'Not Started';
    } else if (planState.isPlanComplete) {
      subtitle = 'Plan Completed!';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            if (planState.currentDay == 0) {
              ref.read(readingPlanProvider(planId).notifier).startPlan();
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => DayView(planId: planId, dayNum: 1),
              ));
            } else if (planState.isPlanComplete) {
              final lastDay = planState.planData.isNotEmpty ? planState.planData.length : 1;
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => DayView(planId: planId, dayNum: lastDay),
              ));
            } else {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => DayView(planId: planId, dayNum: planState.currentDay),
              ));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.primaryColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: beginPct, end: pct),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return SizedBox(
                        width: 36,
                        height: 36,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                  theme.primaryColor.withValues(alpha: 0.15)),
                            ),
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation(theme.primaryColor),
                              strokeCap: StrokeCap.round,
                            ),
                            Center(
                              child: Text(
                                '${(value * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
