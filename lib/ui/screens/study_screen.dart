import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/study_provider.dart';
import '../../state/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/your_space_hero.dart';
import 'votd_archive_screen.dart';
import '../../state/study_layout_provider.dart';
import '../widgets/jiggle_animator.dart';
import '../../state/reading_plan_provider.dart';
import 'reading_plans_hub_screen.dart';
import 'commentary_hub_screen.dart';
import '../../state/streak_provider.dart';
import 'plan_reader_screen.dart';
import 'reading_plan_browser.dart';
import '../../data/local_storage/preferences_service.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  int _currentAuthorIndex = 0;
  final List<String> _commentaryAuthors = ['Uriah Smith'];
  Timer? _timer;
  bool _isEditing = false;


  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentAuthorIndex =
              (_currentAuthorIndex + 1) % _commentaryAuthors.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final layoutConfig = ref.watch(studyLayoutProvider);

    String subGreeting;
    switch (appThemeMode.resolve(context)) {
      case AppThemeMode.light:
        subGreeting = "Embrace the light of His word.";
        break;
      case AppThemeMode.dark:
      case AppThemeMode.oled:
      case AppThemeMode.automatic:
        subGreeting = "Rest in the peace of His promises.";
        break;
      case AppThemeMode.sepia:
        subGreeting = "Reflect on the ancient wisdom.";
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          if (_isEditing) setState(() => _isEditing = false);
        },
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 16.0, bottom: 180.0),
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final animValue =
                          Curves.easeInOut.transform(animation.value);
                      return Transform.scale(
                        scale: 1.0 + (animValue * 0.05),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.15 * animValue),
                                blurRadius: 20 * animValue,
                                spreadRadius: 5 * animValue,
                                offset: Offset(0, 10 * animValue),
                              )
                            ],
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER ──────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Peace be with you,',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subGreeting,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Consumer(builder: (context, ref, child) {
                          final streak = ref.watch(streakProvider);
                          final isLit = streak.readToday;
                          final glowColor = isLit ? AppColors.goldAccent : Colors.grey.withValues(alpha: 0.5);
                          final showNudge = !isLit && streak.count > 0;
                          
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(streak.count > 0 ? '${streak.count} Day Streak! Keep it up!' : 'Read today to start your streak!'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    if (streak.count > 0 || isLit) ...[
                                      Icon(
                                          isLit ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
                                          color: glowColor,
                                          shadows: isLit ? [
                                            Shadow(
                                              color: glowColor.withValues(alpha: 0.6),
                                              blurRadius: 10 + (streak.count.clamp(0, 10).toDouble()),
                                            )
                                          ] : null,
                                          size: 24),
                                      const SizedBox(width: 4),
                                      Text('${streak.count}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isLit ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                                    ],
                                  ],
                                ),
                              ),
                              if (streak.count > 0 || isLit) const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(showNudge ? 'Read today to save your streak!' : 'Notifications coming soon!'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Icon(Icons.notifications_none_rounded,
                                        size: 28,
                                        color: theme.colorScheme.onSurface),
                                    if (showNudge)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 2, right: 2),
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _isEditing = false),
                            icon: const Icon(Icons.check),
                            label: const Text('Done'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                itemCount: layoutConfig.length,
                onReorderItem: (int oldIndex, int newIndex) {
                  ref
                      .read(studyLayoutProvider.notifier)
                      .reorder(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final config = layoutConfig[index];
                  Widget cardWidget;

                  switch (config.id) {
                    case 'your_space':
                      cardWidget = YourSpaceHero(size: config.size);
                      break;
                    case 'reading_plan':
                      cardWidget =
                          _buildReadingPlanBanner(context, theme, config.size, ref);
                      break;
                    case 'commentary':
                      cardWidget =
                          _buildCommentaryBanner(context, theme, config.size);
                      break;
                    case 'saved_verses':
                      cardWidget =
                          _buildVotdArchiveBanner(context, theme, config.size);
                      break;
                    default:
                      cardWidget = const SizedBox.shrink();
                  }

                  final card = KeyedSubtree(
                    key: ValueKey(config.id),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onLongPress: () {
                          if (!_isEditing) setState(() => _isEditing = true);
                        },
                        child: JiggleAnimator(
                          isJiggling: _isEditing,
                          child: Stack(
                            children: [
                              cardWidget,
                              if (_isEditing)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: const CircleBorder(),
                                    child: PopupMenuButton<CardSize>(
                                      icon: const Icon(Icons.more_horiz_rounded,
                                          color: Colors.white, size: 20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      color: theme.colorScheme.surface,
                                      onSelected: (newSize) {
                                        ref
                                            .read(studyLayoutProvider.notifier)
                                            .setSize(config.id, newSize);
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: CardSize.small,
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .photo_size_select_small_rounded,
                                                  color: config.size ==
                                                          CardSize.small
                                                      ? theme.primaryColor
                                                      : null),
                                              const SizedBox(width: 8),
                                              Text('Small',
                                                  style: TextStyle(
                                                      color: config.size ==
                                                              CardSize.small
                                                          ? theme.primaryColor
                                                          : null,
                                                      fontWeight: config.size ==
                                                              CardSize.small
                                                          ? FontWeight.bold
                                                          : null)),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: CardSize.medium,
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .photo_size_select_actual_rounded,
                                                  color: config.size ==
                                                          CardSize.medium
                                                      ? theme.primaryColor
                                                      : null),
                                              const SizedBox(width: 8),
                                              Text('Medium',
                                                  style: TextStyle(
                                                      color: config.size ==
                                                              CardSize.medium
                                                          ? theme.primaryColor
                                                          : null,
                                                      fontWeight: config.size ==
                                                              CardSize.medium
                                                          ? FontWeight.bold
                                                          : null)),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: CardSize.large,
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .photo_size_select_large_rounded,
                                                  color: config.size ==
                                                          CardSize.large
                                                      ? theme.primaryColor
                                                      : null),
                                              const SizedBox(width: 8),
                                              Text('Large',
                                                  style: TextStyle(
                                                      color: config.size ==
                                                              CardSize.large
                                                          ? theme.primaryColor
                                                          : null,
                                                      fontWeight: config.size ==
                                                              CardSize.large
                                                          ? FontWeight.bold
                                                          : null)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  if (_isEditing) {
                    return ReorderableDragStartListener(
                      key: ValueKey(config.id),
                      index: index,
                      child: card,
                    );
                  }
                  return card;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }



  String _getPlanTitle(String planId, WidgetRef ref) {
    if (planId == 'chronological_1yr') return 'Chronological Bible in a Year';
    if (planId == 'great_controversy') return 'The Great Controversy';
    if (planId == 'prophetic_timeline') return 'Prophetic Timeline';
    final customPlan = ref.read(preferencesProvider).getCustomPlan(planId);
    return customPlan?['title'] ?? 'Custom Plan';
  }

  Widget _buildCircularProgress(double pct, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: pct),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.15)),
              ),
              CircularProgressIndicator(
                value: value,
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPlanRow(BuildContext context, ThemeData theme, WidgetRef ref, String planId, {required bool isHero}) {
    final planState = ref.watch(readingPlanProvider(planId));
    final title = _getPlanTitle(planId, ref);
    final pct = planState.percentComplete;
    
    bool isRestDayToday = false;
    if (planState.currentDay > 0 && planState.currentDay <= planState.planData.length) {
      final dayData = planState.planData[planState.currentDay - 1];
      isRestDayToday = dayData.passages.isEmpty;
    }

    if (isHero) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => ReadingPlanBrowser(planId: planId),
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              'Day ${planState.currentDay} of ${planState.planData.length}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildCircularProgress(pct, theme.primaryColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (planState.isLoading)
                    Text('Loading...', style: theme.textTheme.bodyMedium)
                  else if (planState.currentDay == 0)
                    Text('Not Started', style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.w600))
                  else if (planState.isPlanComplete)
                    Text('Plan Completed!', style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600))
                  else if (isRestDayToday)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.self_improvement_rounded, color: theme.primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Rest & Reflection Day', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Today\'s Reading', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                          const SizedBox(height: 8),
                          ...planState.planData[planState.currentDay - 1].passages.take(2).map((p) => 
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Icon(Icons.menu_book_rounded, color: theme.primaryColor, size: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(p.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                                ],
                              ),
                            )
                          ),
                          if (planState.planData[planState.currentDay - 1].passages.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('+ ${planState.planData[planState.currentDay - 1].passages.length - 2} more', style: theme.textTheme.labelSmall?.copyWith(color: theme.primaryColor)),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (planState.currentDay == 0) {
                        ref.read(readingPlanProvider(planId).notifier).startPlan();
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => PlanReaderScreen(planId: planId, dayNum: 1, initialPassageIndex: 0),
                        ));
                      } else if (planState.isPlanComplete) {
                         Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => ReadingPlanBrowser(planId: planId),
                        ));
                      } else {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => PlanReaderScreen(planId: planId, dayNum: planState.currentDay, initialPassageIndex: 0),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(planState.currentDay == 0 ? 'Start Plan' : (planState.isPlanComplete ? 'View Plan' : 'Today\'s Reading')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Compact Row
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => ReadingPlanBrowser(planId: planId),
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  _buildCircularProgress(pct, theme.primaryColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        if (planState.isLoading)
                          Text('Loading...', style: theme.textTheme.bodySmall)
                        else if (planState.currentDay == 0)
                          Text('Not Started', style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor))
                        else if (planState.isPlanComplete)
                          Text('Completed', style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor, fontStyle: FontStyle.italic))
                        else if (isRestDayToday)
                          Text('Rest Day', style: theme.textTheme.bodySmall?.copyWith(color: theme.primaryColor))
                        else
                          Text(planState.planData[planState.currentDay - 1].passages.map((p) => p.label).join(', '), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildReadingPlanBanner(BuildContext context, ThemeData theme, CardSize size, WidgetRef ref) {
    final activePlanIds = ref.watch(activePlanIdsProvider);
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark 
                 ? Colors.black.withValues(alpha: 0.3)
                 : AppColors.goldAccent.withValues(alpha: 0.1),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TexturedGlassContainer(
          borderRadius: BorderRadius.circular(24),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const ReadingPlansHubScreen())
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reading Plans',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.primaryColor.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
              
              if (activePlanIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ReadingPlansHubScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.menu_book_rounded, size: 40, color: theme.primaryColor.withValues(alpha: 0.8)),
                            const SizedBox(height: 16),
                            Text('Start a reading plan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                            const SizedBox(height: 4),
                            Text('Grow in the Word daily.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else ...[
                ...activePlanIds.asMap().entries.map((entry) {
                  return _buildPlanRow(context, theme, ref, entry.value, isHero: entry.key == 0);
                }),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentaryBanner(
      BuildContext context, ThemeData theme, CardSize size) {
    final activeVerse = ref.watch(activeStudyVerseProvider);
    final commentaryAsync = ref.watch(combinedCommentaryProvider);

    String displayAuthor = 'Commentary';
    String displayReference = activeVerse ?? 'Genesis 1:1';
    String displaySnippet =
        'No commentary available yet.';

    if (activeVerse != null &&
        commentaryAsync is AsyncData<CombinedCommentaryState>) {
      final state = commentaryAsync.value;

      final parts = activeVerse.split(' ');
      if (parts.length >= 2) {
        final bookName = parts[0];
        final refParts = parts[1].split(':');
        if (refParts.length >= 2) {
          final chapter = refParts[0];
          final verse = refParts[1];

          final entries = state.data[bookName]?[chapter]?[verse];
          if (entries != null && entries.isNotEmpty) {
            final entry = entries.first;
            displayAuthor = 'Commentary';
            displaySnippet =
                '"${entry.text.split('. ').take(2).join('. ')}..."';
          } else {
            displaySnippet = 'No commentary available for this verse.';
          }
        }
      }
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: TexturedGlassContainer(
        borderRadius: BorderRadius.circular(28),
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.1),
                Colors.transparent,
                theme.primaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                final refStr = activeVerse ?? 'Revelation 14:12';
                Navigator.of(context).push(CupertinoPageRoute(builder: (_) => CommentaryHubScreen(reference: refStr)));
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.library_books_rounded,
                            size: 20, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          displayAuthor,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.primaryColor,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayReference,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displaySnippet,
                      maxLines: size == CardSize.small ? 3 : (size == CardSize.medium ? 6 : 10),
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (size == CardSize.large) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read Full Commentary',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 16, color: theme.primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVotdArchiveBanner(
      BuildContext context, ThemeData theme, CardSize size) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: TexturedGlassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const VotdArchiveScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.surface.withValues(alpha: 0.3),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history_rounded,
                            color: theme.primaryColor, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verse of the Day Archive',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Catch up on verses from days you missed.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_right_rounded,
                            color: theme.primaryColor),
                      ],
                    ),
                    if (size == CardSize.medium || size == CardSize.large) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome,
                                color:
                                    theme.primaryColor.withValues(alpha: 0.7),
                                size: 16),
                            const SizedBox(width: 8),
                            Text('Explore your past daily verses',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                    ],
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

void showNotesPopover(BuildContext context, ThemeData theme) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return TexturedGlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'My Notes',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Icon(Icons.edit_note_rounded,
                size: 48, color: theme.primaryColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No notes yet.',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      );
    },
  );
}
