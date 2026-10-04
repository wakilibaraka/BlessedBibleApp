import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_storage/preferences_service.dart';
import '../../state/auth_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import '../widgets/plans_library_widgets.dart';
import '../widgets/library_calendar_rail.dart';
import 'custom_plan_builder_v2_screen.dart';
import 'plans_hub_v2_screen.dart' show availablePlans, PlanMetadata;
import 'reading_plan_detail_v2_screen.dart';

/// Preset book plans for the Books tab: a title, an inclusive book range
/// (matched by book name) and a day count. Tapping one opens the custom
/// plan builder pre-filled — starting it saves a real custom plan, which
/// then lives in My Plans like everything else.
class BookPlanPreset {
  final String title;
  final String startBook;
  final String endBook;
  final int days;
  const BookPlanPreset({
    required this.title,
    required this.startBook,
    required this.endBook,
    required this.days,
  });
}

const bookPlanPresets = [
  BookPlanPreset(
      title: 'Genesis in 30 days',
      startBook: 'Genesis',
      endBook: 'Genesis',
      days: 30),
  BookPlanPreset(
      title: 'Psalms in 30 days',
      startBook: 'Psalms',
      endBook: 'Psalms',
      days: 30),
  BookPlanPreset(
      title: 'Proverbs in 31 days',
      startBook: 'Proverbs',
      endBook: 'Proverbs',
      days: 31),
  BookPlanPreset(
      title: 'Matthew in 28 days',
      startBook: 'Matthew',
      endBook: 'Matthew',
      days: 28),
  BookPlanPreset(
      title: 'John in 21 days',
      startBook: 'John', endBook: 'John', days: 21),
  BookPlanPreset(
      title: 'Acts in 28 days',
      startBook: 'Acts', endBook: 'Acts', days: 28),
  BookPlanPreset(
      title: 'Romans in 16 days',
      startBook: 'Romans', endBook: 'Romans', days: 16),
  BookPlanPreset(
      title: 'Gospels in 90 days',
      startBook: 'Matthew',
      endBook: 'John',
      days: 90),
];

/// Plans Library: Reading (all curated plans) · Books (book presets +
/// custom book plans) · My Plans (active plans). Replaces the previous
/// plans hub when the plans-design flag is on; both share providers/prefs.
class PlansLibraryScreen extends ConsumerStatefulWidget {
  const PlansLibraryScreen({super.key});

  @override
  ConsumerState<PlansLibraryScreen> createState() =>
      _PlansLibraryScreenState();
}

class _PlansLibraryScreenState extends ConsumerState<PlansLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final GlobalKey<LibraryCalendarRailState> _railKey =
      GlobalKey<LibraryCalendarRailState>();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _push(Widget page) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }

  String _planTitle(String id) {
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

  void _openDetail(String id) {
    _push(ReadingPlanDetailV2Screen(planId: id));
  }

  /// Start a curated plan (start-wipe guard included): an already-active
  /// plan is just opened, never reset. Respects the 3-slot limit.
  void _startCurated(PlanMetadata meta) {
    HapticFeedback.selectionClick();
    final existing = ref.read(readingPlanProvider(meta.id));
    if (existing.isActive) {
      _openDetail(meta.id);
      return;
    }
    final added = ref.read(activePlanIdsProvider.notifier).addPlan(meta.id);
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
    ref.read(readingPlanProvider(meta.id).notifier).startPlan(
          planId: meta.id,
          paceMode: 'scheduled',
          startDate: DateTime.now(),
        );
    if (!mounted) return;
    _openDetail(meta.id);
  }

  /// Resume a paused plan without wiping progress, then open it.
  void _resumePlan(String id) {
    HapticFeedback.selectionClick();
    final added = ref.read(activePlanIdsProvider.notifier).addPlan(id);
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
    if (!mounted) return;
    _openDetail(id);
  }

  void _pausePlan(String id) {
    HapticFeedback.selectionClick();
    ref.read(activePlanIdsProvider.notifier).removePlan(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan paused — all progress is kept.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openPreset(BookPlanPreset preset) {
    _push(CustomPlanBuilderV2Screen(
      initialDays: preset.days,
      initialStartBook: preset.startBook,
      initialEndBook: preset.endBook,
      initialTitle: preset.title,
    ));
  }

  /// Header date tap: pick any date, then slide the rail to that week.
  Future<void> _pickDateAndScroll() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    _railKey.currentState?.scrollToDate(picked);
  }

  void _openToday() {
    final activeIds = ref.read(activePlanIdsProvider);
    if (activeIds.isEmpty) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Browse Reading to start your first plan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _openDetail(activeIds.first);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final now = DateTime.now();
    final rawName =
        ref.watch(authStateProvider).value?.displayName?.trim() ?? '';
    final name =
        rawName.isEmpty ? 'Friend' : rawName.split(RegExp(r'\s+')).first;
    final activeIds = ref.watch(activePlanIdsProvider);
    final activeCount = activeIds.length;
    // First active plan drives the calendar's completion dots.
    // readingPlanProvider is a Notifier (not Async): it exposes
    // isLoading/error inline, and planData is empty until built.
    final activePlan =
        activeIds.isEmpty ? null : ref.watch(readingPlanProvider(activeIds.first));

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const SharedAppBar(title: Text('Plans')),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Date header doubles as a picker: choosing a date
                    // scrolls the calendar rail to that week.
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pickDateAndScroll,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              libraryDateHeader(now),
                              style:
                                  theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit_calendar_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.45)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    LibraryGreetingHeader(
                      name: name,
                      onReadPressed: _openToday,
                    ),
                    const SizedBox(height: 14),
                    LibraryCalendarRail(
                      key: _railKey,
                      today: now,
                      plan: activePlan,
                    ),
                    const SizedBox(height: 14),
                    V2PillTabs(
                      controller: _tabs,
                      tabs: [
                        'Reading',
                        'Books',
                        'My Plans ($activeCount)',
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        controller: _tabs,
                        children: [
                          _ReadingTab(
                            onOpen: _openDetail,
                            onStart: _startCurated,
                            onResume: _resumePlan,
                            onPause: _pausePlan,
                          ),
                          _BooksTab(
                            onOpen: _openDetail,
                            onPreset: _openPreset,
                            titleFor: _planTitle,
                          ),
                          _MyPlansTab(
                            onOpen: _openDetail,
                            onPause: _pausePlan,
                            titleFor: _planTitle,
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
      ),
    );
  }
}

/// One plan row: cover placeholder, title, status line, progress + menu.
class _LibraryCard extends StatelessWidget {
  final String seed;
  final String title;
  final String statusLine;
  final double fraction;
  final bool featured;
  final VoidCallback onOpen;
  final List<PopupMenuEntry<String>> Function(BuildContext context)
      menuBuilder;
  final void Function(String action) onMenu;
  const _LibraryCard({
    required this.seed,
    required this.title,
    required this.statusLine,
    required this.fraction,
    required this.featured,
    required this.onOpen,
    required this.menuBuilder,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: V2Card(
        featured: featured,
        onTap: onOpen,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            PlanCoverPlaceholder(
              seed: seed,
              initials: planInitials(title),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusLine,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: V2ProgressBar(fraction: fraction),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(fraction.clamp(0.0, 1.0) * 100).round()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              onSelected: onMenu,
              itemBuilder: menuBuilder,
            ),
          ],
        ),
      ),
    );
  }
}

List<PopupMenuEntry<String>> _openMenu(BuildContext context) => [
      const PopupMenuItem(value: 'open', child: Text('Open')),
    ];

/// Reading tab: every curated plan with live progress.
class _ReadingTab extends ConsumerWidget {
  final void Function(String id) onOpen;
  final void Function(PlanMetadata meta) onStart;
  final void Function(String id) onResume;
  final void Function(String id) onPause;
  const _ReadingTab({
    required this.onOpen,
    required this.onStart,
    required this.onResume,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIds = ref.watch(activePlanIdsProvider);
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 140),
      children: [
        for (final meta in availablePlans)
          Builder(builder: (_) {
            final st = ref.watch(readingPlanProvider(meta.id));
            final started = st.planStartedOn != null;
            final isActive = activeIds.contains(meta.id);
            final hasProgress = st.completedReadings.isNotEmpty;
            final total = st.planData.length;
            final current = started
                ? (st.todayReadingDay ?? total)
                : 0;
            final status = started
                ? (total > 0 ? 'Day $current of $total' : 'Started')
                : 'New readings';
            return _LibraryCard(
              seed: meta.id,
              title: meta.title,
              statusLine: status,
              fraction: started ? st.percentComplete : 0,
              featured: isActive,
              onOpen: () => onOpen(meta.id),
              menuBuilder: (_) => [
                const PopupMenuItem(
                    value: 'open', child: Text('Open')),
                PopupMenuItem(
                  value: isActive
                      ? 'pause'
                      : (hasProgress ? 'resume' : 'start'),
                  child: Text(isActive
                      ? 'Pause (keeps progress)'
                      : (hasProgress ? 'Resume' : 'Start')),
                ),
              ],
              onMenu: (action) {
                if (action == 'open') {
                  onOpen(meta.id);
                } else if (action == 'pause') {
                  onPause(meta.id);
                } else if (action == 'resume') {
                  onResume(meta.id);
                } else {
                  onStart(meta);
                }
              },
            );
          }),
      ],
    );
  }
}

/// Books tab: book presets (open the builder pre-filled) + the user's
/// saved custom plans.
class _BooksTab extends ConsumerWidget {
  final void Function(String id) onOpen;
  final void Function(BookPlanPreset preset) onPreset;
  final String Function(String id) titleFor;
  const _BooksTab({
    required this.onOpen,
    required this.onPreset,
    required this.titleFor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    List<String> customIds = const [];
    try {
      customIds =
          ref.watch(preferencesProvider).getCustomPlanIds();
    } catch (_) {}
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 140),
      children: [
        for (final preset in bookPlanPresets)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: V2Card(
              onTap: () => onPreset(preset),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  PlanCoverPlaceholder(
                    seed: preset.title,
                    initials: planInitials(preset.title),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          preset.title,
                          style:
                              theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${preset.days} days · tap to build',
                          style:
                              theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        if (customIds.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              'YOUR CUSTOM PLANS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          for (final id in customIds)
            Builder(builder: (_) {
              final st = ref.watch(readingPlanProvider(id));
              final started = st.planStartedOn != null;
              final total = st.planData.length;
              final current =
                  started ? (st.todayReadingDay ?? total) : 0;
              return _LibraryCard(
                seed: id,
                title: titleFor(id),
                statusLine: started
                    ? (total > 0
                        ? 'Day $current of $total'
                        : 'Started')
                    : 'Custom plan',
                fraction: started ? st.percentComplete : 0,
                featured: false,
                onOpen: () => onOpen(id),
                menuBuilder: _openMenu,
                onMenu: (_) => onOpen(id),
              );
            }),
        ],
      ],
    );
  }
}

/// My Plans tab: active plans with live progress (replaces Store).
class _MyPlansTab extends ConsumerWidget {
  final void Function(String id) onOpen;
  final void Function(String id) onPause;
  final String Function(String id) titleFor;
  const _MyPlansTab({
    required this.onOpen,
    required this.onPause,
    required this.titleFor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeIds = ref.watch(activePlanIdsProvider);
    if (activeIds.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 140),
        children: [
          V2Card(
            padding: const EdgeInsets.symmetric(
                vertical: 34, horizontal: 20),
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
                  'Browse Reading or Books to start your first plan.',
                  textAlign: TextAlign.center,
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
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 140),
      children: [
        for (final id in activeIds)
          Builder(builder: (_) {
            final st = ref.watch(readingPlanProvider(id));
            final total = st.planData.length;
            final current = st.todayReadingDay ?? total;
            return _LibraryCard(
              seed: id,
              title: titleFor(id),
              statusLine: total > 0
                  ? 'Day $current of $total'
                  : 'Started',
              fraction: st.percentComplete,
              featured: true,
              onOpen: () => onOpen(id),
              menuBuilder: (_) => const [
                PopupMenuItem(
                    value: 'open', child: Text('Open')),
                PopupMenuItem(
                    value: 'pause',
                    child: Text('Pause (keeps progress)')),
              ],
              onMenu: (action) {
                if (action == 'pause') {
                  onPause(id);
                } else {
                  onOpen(id);
                }
              },
            );
          }),
      ],
    );
  }
}
