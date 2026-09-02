import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/reading_plan_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/account_button.dart';
import '../widgets/plan_row_widget.dart';
import '../sheets/custom_plan_action_sheet.dart';
import '../sheets/curated_plan_action_sheet.dart';
import 'custom_plan_builder_screen.dart';




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

const List<PlanMetadata> availablePlans = [
  PlanMetadata(
    id: 'chronological_1yr',
    title: 'Chronological — Bible in a Year',
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
        leading: const BackButton(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: AccountButton(),
          ),
        ],
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
              Tab(text: 'Library'),
              Tab(text: 'My Plans'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LibraryTab(tabController: _tabController),
                _MyPlansTab(),
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
    final gold = theme.primaryColor;

    if (activePlanIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, size: 48, color: gold.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('No Active Plans', style: theme.textTheme.titleMedium?.copyWith(color: gold, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Go to the Library tab to start a reading plan.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      itemCount: activePlanIds.length,
      itemBuilder: (context, index) {
        final planId = activePlanIds.elementAt(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: PlanRowWidget(planId: planId),
        );
      },
    );
  }
}

class _LibraryTab extends ConsumerWidget {
  final TabController tabController;
  const _LibraryTab({required this.tabController});

  void _activatePlan(BuildContext context, WidgetRef ref, String id, {bool isCustom = false}) {
    final added = ref.read(activePlanIdsProvider.notifier).addPlan(id);
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You have 3 active plans. Deactivate one to add another.')));
      return;
    }
    
    if (isCustom) {
      final customPlan = ref.read(preferencesProvider).getCustomPlan(id);
      ref.read(readingPlanProvider(id).notifier).startPlan(
            planId: id,
            paceMode: customPlan?['paceMode'] ?? 'scheduled',
            restDay: customPlan?['restDay'] as int?,
          );
    } else {
      ref.read(readingPlanProvider(id).notifier).startPlan(
            planId: id,
            paceMode: 'scheduled',
          );
    }
    
    ref.read(currentActivePlanIdProvider.notifier).setContext(id);
    tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final prefs = ref.watch(preferencesProvider);
    final customPlanIds = prefs.getCustomPlanIds();
    final hiddenIds = ref.watch(hiddenPlanIdsProvider);
    final visiblePlans = availablePlans.where((p) => !hiddenIds.contains(p.id)).toList();
    final hiddenPlans = availablePlans.where((p) => hiddenIds.contains(p.id)).toList();

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
              _buildCreateCustomPlanCard(context, theme, gold, customPlanIds.isEmpty),
              for (final id in customPlanIds)
                _buildCustomPlanCard(context, ref, theme, id),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Curated Plans Section
        _buildSectionTitle(theme, 'Curated Plans'),
        const SizedBox(height: 12),
        if (visiblePlans.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('All curated plans are hidden.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          )
        else
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: visiblePlans.map((plan) => _buildCuratedPlanCard(context, ref, theme, plan)).toList(),
            ),
          ),
        const SizedBox(height: 24),

        // Hidden Plans section (only shown when something is hidden)
        if (hiddenPlans.isNotEmpty) ...[
          _HiddenPlansSection(hiddenPlans: hiddenPlans, onActivate: (id) => _activatePlan(context, ref, id)),
          const SizedBox(height: 24),
        ],

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

  Widget _buildCreateCustomPlanCard(BuildContext context, ThemeData theme, Color gold, bool isFullWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const CustomPlanBuilderScreen()));
      },
      child: Container(
        width: isFullWidth ? MediaQuery.of(context).size.width - 32 : 140,
        margin: EdgeInsets.only(right: isFullWidth ? 0 : 12),
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
      onTap: () => _activatePlan(context, ref, id, isCustom: true),
      onLongPress: () => CustomPlanActionSheet.show(context, ref, id),
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
      onTap: () => _activatePlan(context, ref, plan.id),
      onLongPress: () => CuratedPlanActionSheet.show(context, ref, plan.id),
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

// ─── Hidden Plans Section ────────────────────────────────────────────────────

class _HiddenPlansSection extends ConsumerStatefulWidget {
  final List<PlanMetadata> hiddenPlans;
  final void Function(String id) onActivate;

  const _HiddenPlansSection({required this.hiddenPlans, required this.onActivate});

  @override
  ConsumerState<_HiddenPlansSection> createState() => _HiddenPlansSectionState();
}

class _HiddenPlansSectionState extends ConsumerState<_HiddenPlansSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text('Hidden Plans (${widget.hiddenPlans.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 12),
          for (final plan in widget.hiddenPlans)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => widget.onActivate(plan.id),
                  onLongPress: () => CuratedPlanActionSheet.show(context, ref, plan.id),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off_outlined,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(plan.title,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(hiddenPlanIdsProvider.notifier).removePlan(plan.id);
                          },
                          child: const Text('Unhide'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

