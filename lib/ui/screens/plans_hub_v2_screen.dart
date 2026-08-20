import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/reading_plan_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/plan_row_widget.dart';
import 'custom_plan_builder_screen.dart';
import 'reading_plan_browser.dart';
import 'reading_plans_hub_screen.dart';

class PlansHubV2Screen extends ConsumerStatefulWidget {
  const PlansHubV2Screen({super.key});

  @override
  ConsumerState<PlansHubV2Screen> createState() => _PlansHubV2ScreenState();
}

class _PlansHubV2ScreenState extends ConsumerState<PlansHubV2Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SharedAppBar(
        title: const Text('Plans'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            tabs: const [
              Tab(text: 'My Plans'),
              Tab(text: 'Discover'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MyPlansTab(),
                _DiscoverTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPlansTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlanIds = ref.watch(activePlanIdsProvider);
    final theme = Theme.of(context);

    if (activePlanIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, size: 48, color: theme.primaryColor.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('No Active Plans', style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Go to the Discover tab to start a reading plan.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
            ],
          ),
        ),
      );
    }

    final primaryPlanId = activePlanIds.first;
    final secondaryPlanIds = activePlanIds.skip(1).toList();
    final primaryState = ref.watch(readingPlanProvider(primaryPlanId));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        _buildWeekStrip(context, primaryState, theme),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Today\'s Reading', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        PlanRowWidget(planId: primaryPlanId),
        
        if (secondaryPlanIds.isNotEmpty) ...[
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Other Active Plans', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          ...secondaryPlanIds.map((id) => PlanRowWidget(planId: id)),
        ],
      ],
    );
  }

  Widget _buildWeekStrip(BuildContext context, ReadingPlanState state, ThemeData theme) {
    final now = DateTime.now();
    final todayWeekday = now.weekday == 7 ? 0 : now.weekday; // 0 = Sunday, 6 = Saturday
    final startOfWeek = now.subtract(Duration(days: todayWeekday));
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final date = startOfWeek.add(Duration(days: index));
          final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
          
          // simplified completion check based on today's reading day
          // Since mapping actual dates is complex (depends on rest day logic),
          // we use a simplified approximation: if it's before today, and we haven't missed days, it's checked.
          // For absolute precision, we'd need _readingDayForLogicalDay, but since this is UI logic, 
          // we'll just check if the reading day for this date is in completedReadings.
          // Let's do a very basic lookup for demonstration:
          bool isCompleted = false;
          int? rDay;
          if (state.planStartedOn != null) {
              final sDate = DateTime.utc(state.planStartedOn!.year, state.planStartedOn!.month, state.planStartedOn!.day);
              final tDate = DateTime.utc(date.year, date.month, date.day);
              final diff = tDate.difference(sDate).inDays;
              if (diff >= 0) {
                 final logicalDay = diff + 1;
                 // Approximation: if diff >= 0, just assume readingDay ~ logicalDay for UI if scheduled
                 rDay = logicalDay; 
              }
          }
          if (rDay != null && state.completedReadings.contains(rDay)) {
              isCompleted = true;
          }

          return Column(
            children: [
              Text(
                days[index],
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isToday ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday 
                      ? theme.primaryColor 
                      : (isCompleted ? theme.primaryColor.withValues(alpha: 0.1) : Colors.transparent),
                  border: isToday || isCompleted 
                      ? null 
                      : Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: isCompleted && !isToday
                      ? Icon(Icons.check, size: 16, color: theme.primaryColor)
                      : Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isToday ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                          ),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DiscoverTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final prefs = ref.watch(preferencesProvider);
    final customPlanIds = prefs.getCustomPlanIds();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        // Placeholder Hero Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withValues(alpha: 0.3)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(color: gold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(8)),
                        child: Text('BOOK OF THE MONTH (PLACEHOLDER)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
                      ),
                      const SizedBox(height: 8),
                      Text('Prayers for the Weary Warrior', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: gold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Custom Plans Section
        _buildSectionTitle(theme, 'Custom Plans'),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCreateCustomPlanCard(context, theme, gold),
              for (final id in customPlanIds)
                _buildCustomPlanCard(context, ref, theme, id),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Curated Plans Section
        _buildSectionTitle(theme, 'Curated Plans'),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: availablePlans.map((plan) => _buildCuratedPlanCard(context, ref, theme, plan)).toList(),
          ),
        ),
        const SizedBox(height: 32),

        // Placeholder Devotionals Section
        _buildSectionTitle(theme, 'Devotionals (Coming Soon)'),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildPlaceholderCard(theme, 'Anxiety'),
              _buildPlaceholderCard(theme, 'Healing'),
              _buildPlaceholderCard(theme, 'Faith'),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCreateCustomPlanCard(BuildContext context, ThemeData theme, Color gold) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const CustomPlanBuilderScreen()));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: gold, size: 32),
            const SizedBox(height: 8),
            Text('Build a custom\nplan', textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: gold, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPlanCard(BuildContext context, WidgetRef ref, ThemeData theme, String id) {
    final customPlan = ref.read(preferencesProvider).getCustomPlan(id);
    final title = customPlan?['title'] ?? 'Custom Plan';
    return GestureDetector(
      onTap: () {
         Navigator.of(context).push(CupertinoPageRoute(builder: (_) => ReadingPlanBrowser(planId: id)));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.description_outlined, color: theme.primaryColor),
             const Spacer(),
             Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCuratedPlanCard(BuildContext context, WidgetRef ref, ThemeData theme, PlanMetadata plan) {
    return GestureDetector(
      onTap: () {
         Navigator.of(context).push(CupertinoPageRoute(builder: (_) => ReadingPlanBrowser(planId: plan.id)));
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               children: [
                 Expanded(child: Text(plan.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis)),
                 Icon(Icons.auto_awesome_rounded, color: theme.primaryColor, size: 20),
               ],
             ),
             const Spacer(),
             Text('Full Plan', style: theme.textTheme.labelMedium?.copyWith(color: theme.primaryColor)),
             const SizedBox(height: 4),
             Text(plan.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(ThemeData theme, String title) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold)),
      ),
    );
  }
}
