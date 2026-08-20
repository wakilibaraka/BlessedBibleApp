import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/reading_plan_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/account_button.dart';
import '../widgets/plan_row_widget.dart';
import '../sheets/custom_plan_action_sheet.dart';
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
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AccountButton()
          )
        ),
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

class _MyPlansTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MyPlansTab> createState() => _MyPlansTabState();
}

class _MyPlansTabState extends ConsumerState<_MyPlansTab> {
  int _viewIndex = 0; // 0: Week, 1: Month, 2: Year
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
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

    final primaryPlanId = activePlanIds.first;
    final secondaryPlanIds = activePlanIds.skip(1).toList();
    final primaryState = ref.watch(readingPlanProvider(primaryPlanId));

    final realNow = DateTime.now();
    final isScheduled = primaryState.paceMode == 'scheduled';
    final scheduledMap = isScheduled ? buildDateToReadingMap(primaryState) : <String, int>{};

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        // Big Progress Ring
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: primaryState.percentComplete,
                  strokeWidth: 9,
                  backgroundColor: gold.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(gold),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${(primaryState.percentComplete * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontFamily: 'EB Garamond',
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: gold)),
                Text('Complete', style: theme.textTheme.labelSmall),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Primary Plan Card
        PlanRowWidget(planId: primaryPlanId),
        const SizedBox(height: 24),

        // View Switcher (Week / Month / Year)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                _buildViewTab('Week', 0, gold, theme),
                _buildViewTab('Month', 1, gold, theme),
                _buildViewTab('Year', 2, gold, theme),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Current View
        if (_viewIndex == 0)
          _buildWeekStrip(context, primaryState, theme, isScheduled, scheduledMap)
        else if (_viewIndex == 1)
          AdaptivePlanCalendar(
            planState: primaryState,
            displayMonth: _displayMonth,
            isYearView: false,
            onPrevMonth: _prevMonth,
            onNextMonth: _nextMonth,
            onJumpToMonth: (d) => setState(() => _displayMonth = d),
            onToggleYearView: () => setState(() => _viewIndex = 2),
            scheduledMap: scheduledMap,
            realToday: realNow,
            isScheduled: isScheduled,
            gold: gold,
            theme: theme,
            onDayTap: (dayNum) {
              Navigator.push(context, CupertinoPageRoute(builder: (_) => DayView(planId: primaryPlanId, dayNum: dayNum)));
            },
          )
        else if (_viewIndex == 2)
          PlanCompactCalendar(
            planState: primaryState,
            gold: gold,
            theme: theme,
            onDayTap: (dayNum) {
              Navigator.push(context, CupertinoPageRoute(builder: (_) => DayView(planId: primaryPlanId, dayNum: dayNum)));
            },
          ),
        
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

  Widget _buildViewTab(String title, int index, Color gold, ThemeData theme) {
    final isSelected = _viewIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? gold.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? gold : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekStrip(BuildContext context, ReadingPlanState state, ThemeData theme, bool isScheduled, Map<String, int> scheduledMap) {
    final now = DateTime.now();
    final todayWeekday = now.weekday == 7 ? 0 : now.weekday; 
    final startOfWeek = now.subtract(Duration(days: todayWeekday));
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final date = startOfWeek.add(Duration(days: index));
          final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
          
          bool isCompleted = false;
          int? readingDayNum;
          
          if (isScheduled && state.planStartedOn != null) {
            final logicalDay = date.difference(DateTime.utc(state.planStartedOn!.year, state.planStartedOn!.month, state.planStartedOn!.day)).inDays + 1;
            if (logicalDay > 0) {
                readingDayNum = readingDayForLogicalDay(logicalDay, state);
                if (readingDayNum != null && state.completedReadings.contains(readingDayNum)) {
                   isCompleted = true;
                }
            }
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
              GestureDetector(
                onTap: () {
                  if (readingDayNum != null) {
                     Navigator.push(context, CupertinoPageRoute(builder: (_) => DayView(planId: state.planId, dayNum: readingDayNum!)));
                  } else if (isToday) {
                     final rDay = state.todayReadingDay;
                     if (rDay != null) {
                        Navigator.push(context, CupertinoPageRoute(builder: (_) => DayView(planId: state.planId, dayNum: rDay)));
                     }
                  }
                },
                child: Container(
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
              ),
            ],
          );
        }),
      ),
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
