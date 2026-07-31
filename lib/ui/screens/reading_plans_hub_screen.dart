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
    id: 'chronological',
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
    final planState = ref.watch(readingPlanProvider);
    final prefs = ref.watch(preferencesProvider);
    
    // In this MVP, only chronological is active.
    final otherPlans = availablePlans.where((p) => p.id != 'chronological').toList();

    // Load custom plans
    final customPlanIds = prefs.getCustomPlanIds();
    final customPlans = customPlanIds.map((id) => prefs.getCustomPlan(id)).whereType<Map<String, dynamic>>().toList();
    
    return Scaffold(
      extendBody: true,
      appBar: SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Reading Plans', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          CustomScrollView(
            slivers: [
              // ── ACTIVE PLAN (Top) ──
              if (planState.planData.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text(
                      'Active Plan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldAccent,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildActivePlanCard(context, ref, theme, planState.planId, planState),
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
                          Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const CreateCustomPlanScreen()));
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Text(
                      'Create your own reading plan by selecting books, chapters, and setting your preferred pace.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final customPlan = customPlans[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: _buildCustomPlanCard(context, ref, theme, customPlan, prefs),
                      );
                    },
                    childCount: customPlans.length,
                  ),
                ),
              
              // ── PRE-AUTHORED PLANS ──

              // ── OTHER PLANS (Bottom) ──
              if (otherPlans.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                    child: Text(
                      'Other Plans',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final plan = otherPlans[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: _buildOtherPlanCard(theme, plan),
                      );
                    },
                    childCount: otherPlans.length,
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

  Widget _buildActivePlanCard(BuildContext context, WidgetRef ref, ThemeData theme, String planId, ReadingPlanState planState) {
    String title = 'Chronological Bible in a Year';
    String description = 'Read the Bible in the order events occurred.';
    if (planId != 'chronological_1yr') {
      final customPlan = ref.read(preferencesProvider).getCustomPlan(planId);
      if (customPlan != null) {
        title = customPlan['title'] ?? 'Custom Plan';
        description = customPlan['description'] ?? 'A custom reading plan.';
      }
    }

    int missedDays = 0;
    if (planState.currentDay > 0) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = DateTime(planState.startDate.year, planState.startDate.month, planState.startDate.day);
      final elapsed = today.difference(start).inDays;
      if (elapsed > planState.currentDay - 1) {
        missedDays = elapsed - (planState.currentDay - 1);
      }
    }

    return TexturedGlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withValues(alpha: 0.15),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 24),
            
            // Status row
            if (planState.isLoading)
              Text('Loading...', style: theme.textTheme.bodyMedium)
            else if (planState.currentDay == 0)
              Text('Not Started', style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold))
            else if (planState.isPlanComplete)
              Text('Plan Completed 🎉', style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold))
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Day ${planState.currentDay}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(planState.completionPercentage * 100).toStringAsFixed(1)}% completed',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: planState.completionPercentage,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  minHeight: 8,
                ),
              ),
              if (missedDays > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'You are $missedDays day${missedDays == 1 ? '' : 's'} behind schedule.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],

            const SizedBox(height: 24),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const ReadingPlanBrowser())
                  );
                },
                child: Text(
                  (planState.currentDay == 0) ? 'Start Plan' : 'Continue Plan',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7), // greyed out
                    ),
                  ),
                ),
                if (!plan.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5), // greyed out
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPlanCard(BuildContext context, WidgetRef ref, ThemeData theme, Map<String, dynamic> customPlan, PreferencesService prefs) {
    String id = customPlan['id'] ?? '';
    String title = customPlan['title'] ?? 'Custom Plan';
    String description = customPlan['description'] ?? '';
    
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => CupertinoAlertDialog(
                        title: const Text('Delete Plan'),
                        content: const Text('Are you sure you want to delete this custom plan?'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(c),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              prefs.deleteCustomPlan(id);
                              // Simple state refresh hack by forcing UI rebuild or reloading provider
                              // We just rely on watch rebuilds or navigate
                              Navigator.pop(c);
                              // We can trigger a rebuild by restarting the active plan if it was deleted, but for now just pop
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Make this plan active
                  // Note: The custom plan is loaded asynchronously, but we can pass the data directly
                  // Or let the provider handle loading it from prefs since it has the ID
                  ref.read(readingPlanProvider.notifier).startPlan(
                    planId: id,
                    paceMode: customPlan['paceMode'] ?? 'scheduled',
                    restDay: customPlan['restDay'] as int?,
                  );
                  // Reload the page or show toast
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan activated!')));
                },
                child: const Text('Set as Active Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
