import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/textured_glass_container.dart';
import 'reading_plan_browser.dart';
import 'create_custom_plan_screen.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/shared_app_bar.dart';

class PlanMetadata {
  final String id;
  final String title;
  final String description;
  final bool isAvailable;

  const PlanMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.isAvailable,
  });
}

// Future-ready plan model list.
// When real plans are added, just flip isAvailable to true and wire up the provider accordingly.
const List<PlanMetadata> availablePlans = [
  PlanMetadata(
    id: 'chronological_1yr',
    title: 'Chronological Bible in a Year',
    description: 'Read the Bible in the order events occurred.',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'great_controversy',
    title: 'The Great Controversy',
    description: 'A study through the classic book along with Scripture.',
    isAvailable: false,
  ),
  PlanMetadata(
    id: 'prophetic_timeline',
    title: 'Prophetic Timeline',
    description: 'Explore the prophecies of Daniel and Revelation.',
    isAvailable: false,
  ),
];

class ReadingPlansHubScreen extends ConsumerWidget {
  const ReadingPlansHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final activePlanIds = ref.watch(activePlanIdsProvider);
    final prefs = ref.watch(preferencesProvider);

    final inProgressPlanIds = <String>[];
    final completedPlanIds = <String>[];
    for (final id in activePlanIds) {
      if (ref.watch(readingPlanProvider(id)).isPlanComplete) {
        completedPlanIds.add(id);
      } else {
        inProgressPlanIds.add(id);
      }
    }

    // Preset plans not currently active — show in Discover section
    final fixedPlans =
        availablePlans.where((p) => !activePlanIds.contains(p.id)).toList();

    // Load custom plans, filter out active ones
    final customPlanIds = prefs
        .getCustomPlanIds()
        .where((id) => !activePlanIds.contains(id))
        .toList();
    final customPlans = customPlanIds
        .map((id) => prefs.getCustomPlan(id))
        .whereType<Map<String, dynamic>>()
        .toList();

    return Scaffold(
      extendBody: true,
      appBar: SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Reading Plans',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          CustomScrollView(
            slivers: [
              // ── ACTIVE PLANS (Top) ──
              if (inProgressPlanIds.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text(
                      'Active Plans',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldAccent,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final planId = inProgressPlanIds[index];
                      final planState = ref.watch(readingPlanProvider(planId));
                      if (planState.planData.isEmpty && !planState.isLoading)
                        return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: _buildActivePlanCard(
                            context, ref, theme, planId, planState),
                      );
                    },
                    childCount: inProgressPlanIds.length,
                  ),
                ),
              ],

              // ── COMPLETED PLANS ──
              if (completedPlanIds.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text(
                      'Completed Plans',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final planId = completedPlanIds[index];
                      final planState = ref.watch(readingPlanProvider(planId));
                      if (planState.planData.isEmpty && !planState.isLoading)
                        return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: _buildActivePlanCard(
                            context, ref, theme, planId, planState),
                      );
                    },
                    childCount: completedPlanIds.length,
                  ),
                ),
              ],

              // ── MY CUSTOM PLANS ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Custom Plans',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (_) => const CreateCustomPlanScreen()));
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create'),
                      )
                    ],
                  ),
                ),
              ),
              if (customPlans.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    child: Text(
                      'Create your own reading plan by selecting books, chapters, and setting your preferred pace.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final customPlan = customPlans[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: _buildCustomPlanCard(
                            context, ref, theme, customPlan, prefs),
                      );
                    },
                    childCount: customPlans.length,
                  ),
                ),

              // ── DISCOVER / FIXED PLANS ──
              if (fixedPlans.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                    child: Text(
                      'Fixed Plans',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final plan = fixedPlans[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: plan.isAvailable
                            ? _buildFixedPlanCard(context, ref, theme, plan)
                            : _buildOtherPlanCard(theme, plan),
                      );
                    },
                    childCount: fixedPlans.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard(BuildContext context, WidgetRef ref,
      ThemeData theme, String planId, ReadingPlanState planState) {
    final String effectivePlanId =
        planId == 'chronological' ? 'chronological_1yr' : planId;
    final preset =
        availablePlans.where((p) => p.id == effectivePlanId).firstOrNull;
    String title = preset?.title ?? 'Custom Plan';
    String description = preset?.description ?? '';
    if (preset == null) {
      final customPlan = ref.read(preferencesProvider).getCustomPlan(planId);
      if (customPlan != null) {
        title = customPlan['title'] ?? 'Custom Plan';
        description = _getPlanDescription(customPlan);
      }
    }

    int missedDays = 0;
    if (planState.currentDay > 0) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = DateTime(planState.startDate.year,
          planState.startDate.month, planState.startDate.day);
      final elapsed = today.difference(start).inDays;
      if (elapsed > planState.currentDay - 1) {
        missedDays = elapsed - (planState.currentDay - 1);
      }
    }

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (c) => CupertinoAlertDialog(
            title:
                Text(preset == null ? 'Delete Active Plan' : 'Deactivate Plan'),
            content: Text(preset == null
                ? 'Are you sure you want to delete this custom plan? It will be permanently removed.'
                : 'Are you sure you want to deactivate this plan? You can reactivate it later from the Fixed Plans section.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(c),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  if (preset == null) {
                    ref.read(preferencesProvider).deleteCustomPlan(planId);
                  }
                  ref.read(activePlanIdsProvider.notifier).removePlan(planId);
                  ref.invalidate(preferencesProvider);
                  Navigator.pop(c);
                },
                child: Text(preset == null ? 'Delete' : 'Deactivate'),
              ),
            ],
          ),
        );
      },
      child: TexturedGlassContainer(
        borderRadius: BorderRadius.circular(16),
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.15),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (preset == null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              border: Border.all(
                                  color: theme.primaryColor
                                      .withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('CUSTOM',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    letterSpacing: 0.5)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Active',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.goldAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // Status row
              if (planState.isLoading)
                Text('Loading...', style: theme.textTheme.bodySmall)
              else if (planState.isPlanComplete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Plan Completed 🎉',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (c) => CupertinoAlertDialog(
                                title: const Text('Restart Plan'),
                                content: const Text(
                                    'Are you sure you want to restart this plan? All progress will be reset to Day 1.'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed: () => Navigator.pop(c),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      ref
                                          .read(readingPlanProvider(planId)
                                              .notifier)
                                          .restartPlan();
                                      Navigator.pop(c);
                                    },
                                    child: const Text('Restart'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text('Restart',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            ref
                                .read(currentActivePlanIdProvider.notifier)
                                .setContext(planId);
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (_) =>
                                    ReadingPlanBrowser(planId: planId)));
                          },
                          child: const Text('Re-read',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (planState.currentDay == 0)
                            Text('Not Started',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold))
                          else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Day ${planState.currentDay}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${(planState.completionPercentage * 100).toStringAsFixed(0)}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: planState.completionPercentage,
                                backgroundColor: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.primaryColor),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ref
                            .read(currentActivePlanIdProvider.notifier)
                            .setContext(planId);
                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (_) =>
                                ReadingPlanBrowser(planId: planId)));
                      },
                      child: Text(
                        (planState.currentDay == 0) ? 'Start' : 'Continue',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                if (missedDays > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 14,
                          color: Colors.orange.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Behind schedule by $missedDays day${missedDays == 1 ? '' : 's'}.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.orange.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherPlanCard(ThemeData theme, PlanMetadata plan) {
    return TexturedGlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7), // greyed out
                    ),
                  ),
                ),
                if (!plan.isAvailable)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.5), // greyed out
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedPlanCard(
      BuildContext context, WidgetRef ref, ThemeData theme, PlanMetadata plan) {
    return TexturedGlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(
                      color: AppColors.goldAccent.withValues(alpha: 0.6)),
                ),
                onPressed: () {
                  final added =
                      ref.read(activePlanIdsProvider.notifier).addPlan(plan.id);
                  if (!added) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'You have 3 active plans. Deactivate one to add another.')),
                    );
                    return;
                  }
                  ref.read(readingPlanProvider(plan.id).notifier).startPlan(
                        planId: plan.id,
                        paceMode: 'scheduled',
                        restDay: 7,
                      );
                  ref
                      .read(currentActivePlanIdProvider.notifier)
                      .setContext(plan.id);
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                        builder: (_) => ReadingPlanBrowser(planId: plan.id)),
                  );
                },
                child: Text(
                  'Start Plan',
                  style: TextStyle(
                      color: AppColors.goldAccent, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanDescription(Map<String, dynamic> customPlan) {
    String desc = customPlan['description'] ?? '';
    if (desc.isNotEmpty && desc != 'A custom reading plan.') {
      return desc;
    }
    final readings = customPlan['readings'] as List?;
    if (readings != null && readings.isNotEmpty) {
      try {
        final firstDay = readings.first['chapters'] as List?;
        final lastDay = readings.last['chapters'] as List?;
        if (firstDay != null &&
            firstDay.isNotEmpty &&
            lastDay != null &&
            lastDay.isNotEmpty) {
          final firstChap = firstDay.first;
          final lastChap = lastDay.last;

          final String firstBook = firstChap['bookName'];
          final int firstNum = firstChap['chapterNum'];
          final String lastBook = lastChap['bookName'];
          final int lastNum = lastChap['chapterNum'];

          if (firstBook == lastBook) {
            return '$firstBook $firstNum – $lastNum';
          } else {
            return '$firstBook $firstNum – $lastBook $lastNum';
          }
        }
      } catch (_) {}
    }
    return 'A custom reading plan.';
  }

  Widget _buildCustomPlanCard(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      Map<String, dynamic> customPlan,
      PreferencesService prefs) {
    String id = customPlan['id'] ?? '';
    String title = customPlan['title'] ?? 'Custom Plan';
    String description = _getPlanDescription(customPlan);

    return GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (c) => CupertinoAlertDialog(
              title: const Text('Delete Plan'),
              content: const Text(
                  'Are you sure you want to delete this custom plan?'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(c),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    prefs.deleteCustomPlan(id);
                    if (ref.read(activePlanIdsProvider).contains(id)) {
                      ref.read(activePlanIdsProvider.notifier).removePlan(id);
                    }
                    ref.invalidate(preferencesProvider);
                    Navigator.pop(c);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
        child: TexturedGlassContainer(
          borderRadius: BorderRadius.circular(16),
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              border: Border.all(
                                  color: theme.primaryColor
                                      .withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('CUSTOM',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    letterSpacing: 0.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // Try to make this plan active
                      final added =
                          ref.read(activePlanIdsProvider.notifier).addPlan(id);
                      if (!added) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'You have 3 active plans. Deactivate one to add another.')));
                        return;
                      }

                      ref.read(readingPlanProvider(id).notifier).startPlan(
                            planId: id,
                            paceMode: customPlan['paceMode'] ?? 'scheduled',
                            restDay: customPlan['restDay'] as int?,
                          );
                      ref
                          .read(currentActivePlanIdProvider.notifier)
                          .setContext(id);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => ReadingPlanBrowser(planId: id)));
                    },
                    child: const Text('Activate Plan'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
