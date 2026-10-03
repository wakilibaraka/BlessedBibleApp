import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/nav_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/streak_provider.dart';
import '../../state/theme_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/study_v2_widgets.dart';
import 'bible_stories_screen.dart';
import 'commentary_library_v2_screen.dart';
import 'plans_hub_v3_screen.dart';
import 'reading_plan_detail_v2_screen.dart';
import 'study_tools_v2_screen.dart';
import 'plans_hub_v2_screen.dart' show availablePlans;

/// Redesigned Study hub (V2). Shown when [studyDesignProvider] is enabled.
///
/// Differences from V1 [StudyScreen]:
/// - Streak pill is always visible (even at 0) and uses the theme accent.
/// - "Edit layout" is an explicit button, not a hidden long-press.
/// - Plan snapshot shows words-agnostic day progress + behind count and
///   deep-links into the rebuilt plan detail.
/// - Every tool card has a visible CTA. No dead timers or unused imports.
///
/// Data comes from the same providers as V1, so toggling the design flag
/// never loses progress.
class StudyScreenV2 extends ConsumerStatefulWidget {
  const StudyScreenV2({super.key});

  @override
  ConsumerState<StudyScreenV2> createState() => _StudyScreenV2State();
}

class _StudyScreenV2State extends ConsumerState<StudyScreenV2> {
  bool _isEditing = false;

  String _planTitle(String id) {
    for (final p in availablePlans) {
      if (p.id == id) return p.title;
    }
    try {
      final custom =
          ref.read(preferencesProvider).getCustomPlan(id);
      final title = custom?['title'] as String?;
      if (title != null && title.isNotEmpty) return title;
    } catch (_) {}
    return id.replaceAll('_', ' ');
  }

  void _openPlan(BuildContext context, String planId) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (_) => ReadingPlanDetailV2Screen(planId: planId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final subGreeting = appThemeMode.resolve(context).subGreeting;
    final streak = ref.watch(streakProvider);
    final readLoc = ref.watch(readLocationProvider);
    final activeIds = ref.watch(activePlanIdsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 180),
              children: [
                // ── Greeting + streak ─────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peace be with you.',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subGreeting,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              streak.count > 0
                                  ? '${streak.count}-day reading streak. Rest days are neutral — they never break it.'
                                  : 'Open the app and complete a reading each day to start a streak.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 18,
                              color: streak.count > 0
                                  ? theme.primaryColor
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${streak.count}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              streak.count == 1 ? 'day' : 'days',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isEditing = !_isEditing);
                      },
                      icon: Icon(
                          _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                          size: 16),
                      label: Text(_isEditing ? 'Done' : 'Edit layout'),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cards are fixed in this preview — reorder arrives with layout v2.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // ── Continue reading ──────────────────────────────
                const SizedBox(height: 14),
                V2Card(
                  featured: true,
                  onTap: () =>
                      ref.read(navProvider.notifier).setIndex(1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const V2Eyebrow('Continue reading'),
                      const SizedBox(height: 6),
                      Text(
                        '${readLoc.bookName} ${readLoc.chapter}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pick up where you left off in Read',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => ref
                                  .read(navProvider.notifier)
                                  .setIndex(1),
                              child: const Text('Resume →'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Active plan snapshot ──────────────────────────
                if (activeIds.isNotEmpty)
                  _ActivePlanSnapshot(
                    planId: activeIds.first,
                    title: _planTitle(activeIds.first),
                    onOpen: () => _openPlan(context, activeIds.first),
                    onBrowse: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) => const PlansHubV3Screen(),
                      ));
                    },
                  )
                else
                  V2Card(
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) => const PlansHubV3Screen(),
                      ));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.menu_book_rounded,
                            size: 40, color: theme.primaryColor),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const V2Eyebrow('Reading plan'),
                              const SizedBox(height: 4),
                              Text(
                                'Start a reading plan',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Word-balanced pacing with rest-day grace',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),

                // ── Study tools ───────────────────────────────────
                const V2SectionLabel('Study tools'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.92,
                  children: [
                    _ToolCard(
                      icon: Icons.library_books_rounded,
                      eyebrow: 'Commentary',
                      title: 'Verse-by-verse insight',
                      snippet:
                          'Historicist commentary with chapter + verse filters.',
                      cta: 'Open Commentary',
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) =>
                              const CommentaryLibraryV2Screen(),
                        ));
                      },
                    ),
                    _ToolCard(
                      icon: Icons.manage_search_rounded,
                      eyebrow: 'Plans',
                      title: 'Guided reading',
                      snippet:
                          'Curated, paced and custom plans with catch-up.',
                      cta: 'Browse plans',
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => const PlansHubV3Screen(),
                        ));
                      },
                    ),
                    _ToolCard(
                      icon: Icons.auto_stories_rounded,
                      eyebrow: 'Bible stories',
                      title: 'Narratives retold',
                      snippet:
                          '66 stories across every book of the Bible.',
                      cta: 'Read stories',
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => const BibleStoriesScreen(),
                        ));
                      },
                    ),
                    _ToolCard(
                      icon: Icons.bookmarks_rounded,
                      eyebrow: 'Dictionary & notes',
                      title: 'Words & memory',
                      snippet:
                          'Offline dictionary, bookmarks and highlights.',
                      cta: 'Open tools',
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => const StudyToolsV2Screen(),
                        ));
                      },
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

class _ActivePlanSnapshot extends ConsumerWidget {
  final String planId;
  final String title;
  final VoidCallback onOpen;
  final VoidCallback onBrowse;
  const _ActivePlanSnapshot({
    required this.planId,
    required this.title,
    required this.onOpen,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(readingPlanProvider(planId));
    final total = plan.planData.length;
    final current = plan.todayReadingDay ?? total;
    final behind = plan.missedDays.length;

    String todayLabel = 'Not started yet';
    if (total > 0 && current >= 1 && current <= total) {
      final day = plan.planData[current - 1];
      todayLabel = day.passages.map((p) => p.label).join(' · ');
    }

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: V2Card(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: V2Eyebrow('Active plan')),
                GestureDetector(
                  onTap: onBrowse,
                  child: Icon(Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                V2ProgressRing(fraction: plan.percentComplete),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        total == 0
                            ? 'Loading…'
                            : 'Day $current of $total',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      V2ProgressBar(fraction: plan.percentComplete),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          V2Badge(
                              '${(plan.percentComplete * 100).round()}%'),
                          V2MetaChip(plan.paceMode == 'flexible'
                              ? 'Flexible'
                              : 'Scheduled'),
                          if (behind > 0)
                            V2MetaChip(
                                '$behind behind'),
                          if (behind == 0 && total > 0)
                            const V2MetaChip('On track ✓'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book_outlined,
                      color: theme.primaryColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Today: $todayLabel',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String snippet;
  final String cta;
  final VoidCallback onTap;
  const _ToolCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.snippet,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return V2Card(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, size: 18, color: theme.primaryColor),
          ),
          const SizedBox(height: 8),
          V2Eyebrow(eyebrow),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              snippet,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Text(
            '$cta →',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
