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
import 'reading_plan_browser.dart';

class PlanMetadata {
  final String id;
  final String title;
  final String description;
  final String category;
  final String badge;
  final int durationDays;
  final String dailyCommitment;
  final bool isAvailable;

  const PlanMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.badge,
    this.durationDays = 365,
    this.dailyCommitment = '~15 min/day',
    this.isAvailable = true,
  });
}

const List<PlanMetadata> availablePlans = [
  PlanMetadata(
    id: 'mccheyne_1yr',
    title: "M'Cheyne 1-Year Plan",
    description: "Robert Murray M'Cheyne's beloved classic: 4 daily readings spanning the OT once and NT & Psalms twice.",
    category: 'Classic / 1-Year',
    badge: '4 Passages/day',
    durationDays: 365,
    dailyCommitment: '~15-20 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'chronological_1yr',
    title: 'Chronological — Bible in a Year',
    description: 'Read the Bible in the historical order that events actually occurred throughout biblical history.',
    category: 'Chronological',
    badge: 'Historical Order',
    durationDays: 365,
    dailyCommitment: '~15 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'horner_10_chapters',
    title: "Professor Grant Horner's System",
    description: 'Immerse deeply in Scripture with 10 chapters every day from 10 distinct biblical lists simultaneously.',
    category: 'Classic / 1-Year',
    badge: '10 Chapters/day',
    durationDays: 365,
    dailyCommitment: '~35-45 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_through_the_bible',
    title: 'Through The Bible in a Year',
    description: 'A balanced daily reading program that journeys systematically through both the Old and New Testaments.',
    category: 'Whole Bible',
    badge: '2 Passages/day',
    durationDays: 365,
    dailyCommitment: '~10-12 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_everyday_in_word',
    title: 'Every Day In The Word',
    description: 'Four readings each day: from the Old Testament, the New Testament, Psalms, and Proverbs.',
    category: 'Whole Bible',
    badge: '4 Passages/day',
    durationDays: 365,
    dailyCommitment: '~15 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_gospels_and_epistles',
    title: 'Gospels & Epistles',
    description: 'Dedicated focus on Jesus Christ’s life, teaching, and the foundational letters of the apostles.',
    category: 'Gospels & NT',
    badge: '1 Passage/day',
    durationDays: 365,
    dailyCommitment: '~5 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_psalms_and_wisdom',
    title: 'Psalms & Wisdom Literature',
    description: 'Devotional immersion in the poetry, prayers, and wisdom of Psalms, Proverbs, Job, and Ecclesiastes.',
    category: 'Wisdom',
    badge: '1 Passage/day',
    durationDays: 365,
    dailyCommitment: '~5 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_pentateuch_and_history',
    title: 'Pentateuch & History of Israel',
    description: 'From the dawn of Creation through the Law and the rise and fall of the kingdom of Israel.',
    category: 'OT & NT',
    badge: '1 Passage/day',
    durationDays: 365,
    dailyCommitment: '~8 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'esv_chronicles_and_prophets',
    title: 'Chronicles & The Prophets',
    description: 'Journey through 1 & 2 Chronicles harmonized alongside the major and minor Hebrew prophets.',
    category: 'OT & NT',
    badge: '1 Passage/day',
    durationDays: 365,
    dailyCommitment: '~8 min/day',
    isAvailable: true,
  ),
  PlanMetadata(
    id: 'heartlight_ot_nt',
    title: 'Heartlight Old & New Testament',
    description: 'Harmonious parallel daily reading pairing Old Testament narrative with New Testament revelation.',
    category: 'Whole Bible',
    badge: '2 Passages/day',
    durationDays: 365,
    dailyCommitment: '~10 min/day',
    isAvailable: true,
  ),
];

class PlansHubV2Screen extends ConsumerStatefulWidget {
  const PlansHubV2Screen({super.key});

  @override
  ConsumerState<PlansHubV2Screen> createState() => _PlansHubV2ScreenState();
}

class _PlansHubV2ScreenState extends ConsumerState<PlansHubV2Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void disposeBack() {
    _tabController.dispose();
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
        title: const Text('Reading Plans'),
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
            unselectedLabelColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                _MyPlansTab(tabController: _tabController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPlansTab extends ConsumerWidget {
  final TabController tabController;
  const _MyPlansTab({required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlanIds = ref.watch(activePlanIdsProvider);
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    if (activePlanIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book_rounded,
                    size: 38, color: gold.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 20),
              Text(
                'No Active Plans',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore our curated library or build a custom plan to start your daily journey in the Word.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => tabController.animateTo(0),
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: const Text('Browse Library'),
                style: FilledButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: activePlanIds.length,
      itemBuilder: (context, index) {
        final planId = activePlanIds.elementAt(index);
        return PlanRowWidget(planId: planId);
      },
    );
  }
}

class _LibraryTab extends ConsumerStatefulWidget {
  final TabController tabController;
  const _LibraryTab({required this.tabController});

  @override
  ConsumerState<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<_LibraryTab> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Classic / 1-Year',
    'Whole Bible',
    'Chronological',
    'Gospels & NT',
    'Wisdom',
    'OT & NT',
    'Custom Plans',
  ];

  void _activatePlan(BuildContext context, WidgetRef ref, String id,
      {bool isCustom = false}) {
    final activeIds = ref.read(activePlanIdsProvider);
    if (activeIds.contains(id)) {
      Navigator.of(context).push(CupertinoPageRoute(
        builder: (_) => ReadingPlanBrowser(planId: id),
      ));
      return;
    }

    final added = ref.read(activePlanIdsProvider.notifier).addPlan(id);
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'You already have 3 active plans. Deactivate one to start another.')));
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
    widget.tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final prefs = ref.watch(preferencesProvider);
    final customPlanIds = prefs.getCustomPlanIds();
    final activeIds = ref.watch(activePlanIdsProvider);
    final hiddenIds = ref.watch(hiddenPlanIdsProvider);

    final visiblePlans = availablePlans.where((p) {
      if (hiddenIds.contains(p.id)) return false;
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Custom Plans') return false;
      return p.category == _selectedCategory;
    }).toList();

    final hiddenPlans =
        availablePlans.where((p) => hiddenIds.contains(p.id)).toList();

    final showCustomPlansSection =
        _selectedCategory == 'All' || _selectedCategory == 'Custom Plans';

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        // ── Filter Chips Row ──
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: gold.withValues(alpha: 0.15),
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(
                  color: isSelected
                      ? gold
                      : theme.dividerColor.withValues(alpha: 0.15),
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? gold : theme.colorScheme.onSurface,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = cat);
                  }
                },
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // ── Custom Plans Section ──
        if (showCustomPlansSection) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Custom & Paced Plans',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Your Pace',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCreateCustomPlanCard(context, theme, gold),
                _buildDynamicPacedCard(context, theme, gold),
                for (final id in customPlanIds)
                  _buildCustomPlanCard(context, ref, theme, id, activeIds),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],

        // ── Curated Plans Section Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                _selectedCategory == 'All'
                    ? 'Curated Reading Plans'
                    : '$_selectedCategory Plans',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${visiblePlans.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: gold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Curated Plan Cards ──
        if (visiblePlans.isEmpty && !showCustomPlansSection)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No plans found in this category.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: visiblePlans
                  .map((plan) => _buildCuratedPlanCard(
                      context, ref, theme, gold, plan, activeIds))
                  .toList(),
            ),
          ),

        const SizedBox(height: 20),

        // ── Hidden Plans section ──
        if (hiddenPlans.isNotEmpty) ...[
          _HiddenPlansSection(
            hiddenPlans: hiddenPlans,
            onActivate: (id) => _activatePlan(context, ref, id),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildCreateCustomPlanCard(
      BuildContext context, ThemeData theme, Color gold) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => const CustomPlanBuilderScreen()));
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gold.withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune_rounded, color: gold, size: 20),
            ),
            const Spacer(),
            Text(
              'Book Selector',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Select books & rest days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicPacedCard(
      BuildContext context, ThemeData theme, Color gold) {
    return GestureDetector(
      onTap: () => _showPacedPlanDialog(context),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gold.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.speed_rounded, color: gold, size: 20),
            ),
            const Spacer(),
            Text(
              'Paced Generator',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: gold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '30, 90, 180, 365 days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPacedPlanDialog(BuildContext context) {
    final durations = [30, 90, 180, 365];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generate Dynamic Paced Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Read the entire Bible balanced perfectly across your chosen duration.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 18),
                for (final d in durations)
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text('$d Days Journey'),
                    subtitle: Text(
                        '~${(1189 / d).ceil()} chapters per day across all books.'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.pop(ctx);
                      _generateAndStartPacedPlan(d);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.edit_calendar_rounded),
                  title: const Text('Custom Duration...'),
                  subtitle: const Text('Enter any number of days.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () async {
                    Navigator.pop(ctx);
                    _showCustomDaysPrompt(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustomDaysPrompt(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Custom Duration'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Number of days (e.g. 120)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final days = int.tryParse(controller.text.trim());
              if (days != null && days > 0) {
                Navigator.pop(c);
                _generateAndStartPacedPlan(days);
              }
            },
            child: const Text('Create Plan'),
          ),
        ],
      ),
    );
  }

  void _generateAndStartPacedPlan(int totalDays) {
    final planId = 'custom_paced_$totalDays';
    final customPlan = {
      'id': planId,
      'title': 'Bible in $totalDays Days',
      'durationDays': totalDays,
      'paceMode': 'scheduled',
      'books': [
        'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
        'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
        '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles',
        'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
        'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah',
        'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel',
        'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum',
        'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
        'Matthew', 'Mark', 'Luke', 'John', 'Acts',
        'Romans', '1 Corinthians', '2 Corinthians', 'Galatians',
        'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians',
        '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus',
        'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter',
        '1 John', '2 John', '3 John', 'Jude', 'Revelation'
      ],
    };
    ref.read(preferencesProvider).saveCustomPlan(planId, customPlan);
    _activatePlan(context, ref, planId, isCustom: true);
  }

  Widget _buildCustomPlanCard(BuildContext context, WidgetRef ref,
      ThemeData theme, String id, Set<String> activeIds) {
    final customPlan = ref.read(preferencesProvider).getCustomPlan(id);
    final title = customPlan?['title'] ?? 'Custom Plan';
    final isActive = activeIds.contains(id);

    return GestureDetector(
      onTap: () => _activatePlan(context, ref, id, isCustom: true),
      onLongPress: () => CustomPlanActionSheet.show(context, ref, id),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? theme.primaryColor
                : theme.dividerColor.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bookmark_outline_rounded,
                    color: theme.primaryColor, size: 20),
                const Spacer(),
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isActive ? 'Active' : 'Tap to start',
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuratedPlanCard(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      Color gold,
      PlanMetadata plan,
      Set<String> activeIds) {
    final isActive = activeIds.contains(plan.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? gold.withValues(alpha: 0.6)
              : theme.dividerColor.withValues(alpha: 0.15),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _activatePlan(context, ref, plan.id),
          onLongPress: () => CuratedPlanActionSheet.show(context, ref, plan.id),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Category tag & badges
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
                        plan.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan.badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      plan.dailyCommitment,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  plan.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  plan.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),

                // Bottom row: Active status indicator & Start button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isActive)
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 16, color: gold),
                          const SizedBox(width: 6),
                          Text(
                            'Active in My Plans',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: gold,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${plan.durationDays} Days',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    FilledButton(
                      onPressed: () => _activatePlan(context, ref, plan.id),
                      style: FilledButton.styleFrom(
                        backgroundColor: isActive
                            ? theme.colorScheme.surface
                            : gold,
                        foregroundColor: isActive
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        minimumSize: const Size(80, 34),
                        side: isActive
                            ? BorderSide(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.2))
                            : BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isActive ? 'Open' : 'Start Plan',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hidden Plans Section ────────────────────────────────────────────────────

class _HiddenPlansSection extends ConsumerStatefulWidget {
  final List<PlanMetadata> hiddenPlans;
  final void Function(String id) onActivate;

  const _HiddenPlansSection(
      {required this.hiddenPlans, required this.onActivate});

  @override
  ConsumerState<_HiddenPlansSection> createState() =>
      _HiddenPlansSectionState();
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
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => widget.onActivate(plan.id),
                  onLongPress: () =>
                      CuratedPlanActionSheet.show(context, ref, plan.id),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off_outlined,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                            size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(plan.title,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(hiddenPlanIdsProvider.notifier)
                                .removePlan(plan.id);
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
