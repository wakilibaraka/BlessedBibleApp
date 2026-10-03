import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/reading_plan_provider.dart';
import '../../state/theme_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import 'custom_plan_builder_v2_screen.dart';
import 'reading_plan_detail_v2_screen.dart';
import 'plans_hub_v2_screen.dart' show availablePlans, PlanMetadata;

/// Redesigned reading-plans hub (V3). Shown when the study-design flag is on.
///
/// Differences from V2 [PlansHubV2Screen]:
/// - Active-slot counter (n/3) is visible up front; Start disables at 3/3
///   instead of failing with a SnackBar after the tap.
/// - Library has search + category filter.
/// - Every card exposes a visible ••• manage menu — long-press is never the
///   only path.
/// - Opening a plan goes to the rebuilt [ReadingPlanDetailV2Screen].
/// - Same providers/ids as V1/V2: safe to toggle back and forth.
class PlansHubV3Screen extends ConsumerStatefulWidget {
  const PlansHubV3Screen({super.key});

  @override
  ConsumerState<PlansHubV3Screen> createState() => _PlansHubV3ScreenState();
}

class _PlansHubV3ScreenState extends ConsumerState<PlansHubV3Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _query = '';
  String _category = 'All';

  static const _categories = [
    'All',
    'Classic / 1-Year',
    'Whole Bible',
    'Chronological',
    'Gospels & NT',
    'Wisdom',
    'OT & NT',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _openDetail(String id) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (_) => ReadingPlanDetailV2Screen(planId: id),
    ));
  }

  Future<void> _startPlan(PlanMetadata meta) async {
    HapticFeedback.selectionClick();
    final added =
        ref.read(activePlanIdsProvider.notifier).addPlan(meta.id);
    if (!added) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'All 3 plan slots are in use. Pause a plan to free a slot — progress is kept.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // Start immediately with defaults; start-date/rest/reminder can be
    // refined inside the detail screen. startPlan honours startDate.
    ref.read(readingPlanProvider(meta.id).notifier).startPlan(
          planId: meta.id,
          paceMode: 'scheduled',
          startDate: DateTime.now(),
        );
    if (!mounted) return;
    _tabs.animateTo(0);
    _openDetail(meta.id);
  }

  void _showManage(String id, String title, bool isCustom) {
    final activeIds = ref.read(activePlanIdsProvider);
    final isActive = activeIds.contains(id);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.star_outline_rounded),
                title: Text('Make primary — $title',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  ref
                      .read(activePlanIdsProvider.notifier)
                      .makePrimary(id);
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: Icon(isActive
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded),
                title: Text(isActive
                    ? 'Pause (keeps all progress)'
                    : 'Resume (dates re-anchor, progress kept)'),
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (isActive) {
                    ref
                        .read(activePlanIdsProvider.notifier)
                        .removePlan(id);
                  } else {
                    final ok = ref
                        .read(activePlanIdsProvider.notifier)
                        .addPlan(id);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All 3 slots are in use.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt_rounded),
                title: const Text('Restart from Day 1…'),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: const Text('Restart plan?'),
                      content: const Text(
                          'Completed days will be cleared. This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(d).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(d).pop(true),
                          child: const Text('Restart'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref
                        .read(readingPlanProvider(id).notifier)
                        .restartPlan();
                  }
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
              ),
              if (isCustom)
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded,
                      color: theme.colorScheme.error),
                  title: Text('Delete custom plan…',
                      style:
                          TextStyle(color: theme.colorScheme.error)),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (d) => AlertDialog(
                        title: const Text('Delete plan?'),
                        content: const Text(
                            'The plan definition and its progress are removed.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(d).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(d).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      ref
                          .read(activePlanIdsProvider.notifier)
                          .removePlan(id);
                      ref
                          .read(preferencesProvider)
                          .deleteCustomPlan(id);
                      ref
                          .read(readingPlanProvider(id).notifier)
                          .deletePlanProgress();
                    }
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeIds = ref.watch(activePlanIdsProvider);
    final appThemeMode = ref.watch(themeProvider);

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const SharedAppBar(title: Text('Reading Plans')),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grow at a pace you can keep.',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            _SlotDots(
                                used: activeIds.length, total: 3),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${activeIds.length} of 3 plan slots used',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      V2PillTabs(
                        controller: _tabs,
                        tabs: [
                          'My Plans (${activeIds.length})',
                          'Library',
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _MyPlansTab(
                        onOpen: _openDetail,
                        onManage: (id, title) =>
                            _showManage(id, title, false),
                      ),
                      _LibraryTab(
                        query: _query,
                        category: _category,
                        onQuery: (v) =>
                            setState(() => _query = v),
                        onCategory: (v) =>
                            setState(() => _category = v),
                        onStart: _startPlan,
                        onOpen: _openDetail,
                        onManage: (id, title) =>
                            _showManage(id, title, false),
                        atCapacity: activeIds.length >= 3,
                      ),
                    ],
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
}

class _SlotDots extends StatelessWidget {
  final int used;
  final int total;
  const _SlotDots({required this.used, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        total,
        (i) => Container(
          width: 26,
          height: 8,
          margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: i < used
                ? theme.primaryColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}

class _MyPlansTab extends ConsumerWidget {
  final void Function(String id) onOpen;
  final void Function(String id, String title) onManage;
  const _MyPlansTab({required this.onOpen, required this.onManage});

  String _title(WidgetRef ref, String id) {
    for (final p in availablePlans) {
      if (p.id == id) return p.title;
    }
    try {
      final custom =
          ref.read(preferencesProvider).getCustomPlan(id);
      final t = custom?['title'] as String?;
      if (t != null && t.isNotEmpty) return t;
    } catch (_) {}
    return id.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeIds = ref.watch(activePlanIdsProvider);
    if (activeIds.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: theme.dividerColor, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.spa_rounded,
                    size: 32, color: theme.primaryColor),
                const SizedBox(height: 10),
                Text('No active plans',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 4),
                Text(
                  'Browse the library to start your first plan.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
      itemCount: activeIds.length,
      itemBuilder: (context, i) {
        final id = activeIds[i];
        final plan = ref.watch(readingPlanProvider(id));
        final total = plan.planData.length;
        final current = plan.todayReadingDay ?? total;
        String todayLabel = 'Ready to begin';
        if (total > 0 && current >= 1 && current <= total) {
          todayLabel =
              plan.planData[current - 1].passages.map((p) => p.label).join(' · ');
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: V2Card(
            onTap: () => onOpen(id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _title(ref, id),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    V2Badge(
                        '${(plan.percentComplete * 100).round()}%'),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.more_horiz_rounded),
                      onPressed: () => onManage(id, _title(ref, id)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'Loading…'
                      : 'Day $current of $total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                V2ProgressBar(fraction: plan.percentComplete),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Today: $todayLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: () => onOpen(id),
                        child: Text(plan.completedReadings
                                .contains(current)
                            ? 'Review'
                            : 'Read'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LibraryTab extends ConsumerWidget {
  final String query;
  final String category;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onCategory;
  final void Function(PlanMetadata meta) onStart;
  final void Function(String id) onOpen;
  final void Function(String id, String title) onManage;
  final bool atCapacity;
  const _LibraryTab({
    required this.query,
    required this.category,
    required this.onQuery,
    required this.onCategory,
    required this.onStart,
    required this.onOpen,
    required this.onManage,
    required this.atCapacity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeIds = ref.watch(activePlanIdsProvider);
    final hiddenIds = ref.watch(hiddenPlanIdsProvider);

    final visible = availablePlans.where((p) {
      if (hiddenIds.contains(p.id)) return false;
      if (category != 'All' && p.category != category) return false;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        return ('${p.title} ${p.description} ${p.badge}')
            .toLowerCase()
            .contains(q);
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search plans…',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
          ),
          onChanged: onQuery,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _PlansHubV3ScreenState._categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final c = _PlansHubV3ScreenState._categories[i];
              final selected = c == category;
              return ChoiceChip(
                label: Text(c),
                selected: selected,
                onSelected: (_) => onCategory(c),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) =>
                        const CustomPlanBuilderV2Screen(),
                  ));
                },
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Build custom plan'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final meta in visible)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: V2Card(
              featured: activeIds.contains(meta.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      V2Badge(meta.badge),
                      V2MetaChip(meta.category),
                      V2MetaChip('${meta.durationDays} days'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meta.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.65),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '⏱ ${meta.dailyCommitment}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (activeIds.contains(meta.id)) ...[
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => onOpen(meta.id),
                            child: const Text('Open'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz_rounded),
                          onPressed: () =>
                              onManage(meta.id, meta.title),
                        ),
                      ] else ...[
                        Expanded(
                          child: FilledButton(
                            onPressed: atCapacity
                                ? null
                                : () => onStart(meta),
                            child: Text(atCapacity
                                ? 'Slots full (3/3)'
                                : 'Start plan'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => onOpen(meta.id),
                          child: const Text('Preview'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              'No plans match. Try a different search or category.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}
