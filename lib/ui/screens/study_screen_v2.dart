import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/journal_provider.dart';
import '../../state/notes_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/streak_provider.dart';
import '../../state/plans_design_provider.dart';
import '../../state/study_layout_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/user_data_provider.dart'
    show bookmarksProvider, highlightsProvider;
import '../../data/local_storage/preferences_service.dart';
import '../widgets/jiggle_animator.dart';
import '../widgets/study_v2_widgets.dart';
import 'bible_stories_screen.dart';
import 'commentary_library_v2_screen.dart';
import 'dictionary_v2_screen.dart';
import 'plans_hub_v3_screen.dart';
import 'plans_library_screen.dart';
import 'reading_plan_detail_v2_screen.dart';
import 'your_space_screen.dart';
import 'plans_hub_v2_screen.dart' show availablePlans;

/// Redesigned Study hub (V2) with layout-v2: resizable, reorderable cards.
///
/// - Order + span (quarter/half/full) persist via [studyLayoutProvider].
/// - Long-press a card to enter edit mode (jiggle + drag + resize);
///   the ••• resize handle shows on each card only while editing.
/// - No persistent Edit button. No Continue Reading card (resume lives in
///   the plan snapshot + Read tab).
/// - Top banner is Your Space: live bookmark/highlight/note/journal counts.
class StudyScreenV2 extends ConsumerStatefulWidget {
  const StudyScreenV2({super.key});

  @override
  ConsumerState<StudyScreenV2> createState() => _StudyScreenV2State();
}

const _v2CardIds = [
  'your_space',
  'reading_plan',
  'commentary',
  'plans',
  'dictionary',
  'bible_stories',
];

/// Minimum span per card (quarters would be unusable for these).
const _minSpan = {
  'your_space': CardSpan.half,
  'reading_plan': CardSpan.half,
};

List<StudyCardConfig> _orderedCards(List<StudyCardConfig> stored) {
  final byId = {for (final c in stored) c.id: c};
  final out = <StudyCardConfig>[];
  for (final c in stored) {
    if (_v2CardIds.contains(c.id)) out.add(c);
  }
  for (final def in StudyLayoutNotifier.defaultLayoutV2()) {
    if (!byId.containsKey(def.id)) out.add(def);
  }
  return out;
}

class _StudyScreenV2State extends ConsumerState<StudyScreenV2> {
  bool _editing = false;

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

  void _push(Widget page) {
    HapticFeedback.selectionClick();
    try {
      Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open that screen. $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showResize(String id, CardSpan current) {
    final min = _minSpan[id] ?? CardSpan.quarter;
    final options = CardSpan.values
        .where((s) => s.index >= min.index)
        .toList();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // iOS-style grabber for the bottom sheet.
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  margin: const EdgeInsets.only(top: 6, bottom: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: V2Eyebrow('Card size'),
              ),
              for (final s in options)
                ListTile(
                  leading: Icon(
                    s == CardSpan.full
                        ? Icons.crop_landscape_rounded
                        : s == CardSpan.half
                            ? Icons.splitscreen_rounded
                            : Icons.grid_view_rounded,
                    color: s == current
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                  ),
                  title: Text(
                      s == CardSpan.full
                          ? 'Full width'
                          : s == CardSpan.half
                              ? 'Half (split row)'
                              : 'Quarter (4-across)'),
                  trailing: s == current
                      ? Icon(Icons.check_rounded,
                          color: theme.primaryColor)
                      : null,
                  onTap: () {
                    ref
                        .read(studyLayoutProvider.notifier)
                        .setSpan(id, s);
                    Navigator.of(ctx).pop();
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
    final appThemeMode = ref.watch(themeProvider);
    final subGreeting = appThemeMode.resolve(context).subGreeting;
    final streak = ref.watch(streakProvider);
    final layout = ref.watch(studyLayoutProvider);
    final cards = _orderedCards(layout);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 12.0;
                    final maxW = constraints.maxWidth - 40;
                    double spanWidth(CardSpan s) {
                      switch (s) {
                        case CardSpan.full:
                          return maxW;
                        case CardSpan.half:
                          return (maxW - gap) / 2;
                        case CardSpan.quarter:
                          return (maxW - gap * 3) / 4;
                      }
                    }

                    return ListView(
                      padding:
                          const EdgeInsets.fromLTRB(20, 32, 20, 180),
                      children: [
                        // ── Greeting + streak ───────────────
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Peace be with you.',
                                    style: theme
                                        .textTheme.titleLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subGreeting,
                                    style: theme
                                        .textTheme.labelMedium
                                        ?.copyWith(
                                      color: theme
                                          .colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      streak.count > 0
                                          ? '${streak.count}-day streak. Open daily to grow it.'
                                          : 'Complete a reading each day to start a streak.',
                                    ),
                                    behavior:
                                        SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 13,
                                        vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surface,
                                  borderRadius:
                                      BorderRadius.circular(999),
                                  border: Border.all(
                                      color: theme.dividerColor),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons
                                          .local_fire_department_rounded,
                                      size: 18,
                                      color: streak.count > 0
                                          ? theme.primaryColor
                                          : theme.colorScheme
                                              .onSurface
                                              .withValues(
                                                  alpha: 0.4),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${streak.count}',
                                      style: theme
                                          .textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      streak.count == 1
                                          ? 'day'
                                          : 'days',
                                      style: theme
                                          .textTheme.labelSmall
                                          ?.copyWith(
                                        color: theme
                                            .colorScheme.onSurface
                                            .withValues(
                                                alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_editing)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8),
                            child: Text(
                              'Edit mode — drag cards to reorder, tap ••• to resize.',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(
                                color: theme
                                    .colorScheme.onSurface
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                        // ── Span grid ───────────────────────
                        Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final card in cards)
                              SizedBox(
                                width: spanWidth(card.span),
                                child: DragTarget<String>(
                                  onWillAcceptWithDetails:
                                      (d) =>
                                          d.data != card.id,
                                  onAcceptWithDetails: (d) {
                                    ref
                                        .read(studyLayoutProvider
                                            .notifier)
                                        .move(
                                            d.data, card.id);
                                  },
                                  builder: (context, _, __) {
                                    final inner = _CardBody(
                                      id: card.id,
                                      span: card.span,
                                      planTitle: _planTitle,
                                      onOpen: _push,
                                      onResize: () => _showResize(
                                          card.id, card.span),
                                    );
                                    // passthrough: the card gets the
                                    // slot's tight width so every card
                                    // fills its span (no shrink-wrap).
                                    final framed = Stack(
                                      fit: StackFit.passthrough,
                                      children: [
                                        inner,
                                        if (_editing)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child:
                                                GestureDetector(
                                              behavior:
                                                  HitTestBehavior
                                                      .opaque,
                                              onTap: () =>
                                                  _showResize(
                                                      card.id,
                                                      card.span),
                                              // 10px hit padding + 6px
                                              // visual padding + 16px
                                              // icon = 48pt target.
                                              child:
                                                  const Padding(
                                                padding:
                                                    EdgeInsets
                                                        .all(10),
                                                child: _ResizeDots(),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                    return JiggleAnimator(
                                      isJiggling: _editing,
                                      child: LongPressDraggable<
                                          String>(
                                        data: card.id,
                                        onDragStarted: () {
                                          HapticFeedback
                                              .mediumImpact();
                                          if (!_editing) {
                                            setState(() =>
                                                _editing =
                                                    true);
                                          }
                                        },
                                        feedback: Material(
                                          color:
                                              Colors.transparent,
                                          child: SizedBox(
                                            width: spanWidth(
                                                card.span),
                                            child: Opacity(
                                              opacity: 0.9,
                                              child: inner,
                                            ),
                                          ),
                                        ),
                                        childWhenDragging:
                                            Opacity(
                                          opacity: 0.35,
                                          child: framed,
                                        ),
                                        child: framed,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                // ── Done chip (edit mode only) ──────────────
                if (_editing)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _editing = false),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.onSurface,
                            borderRadius:
                                BorderRadius.circular(999),
                          ),
                          child: Text(
                            '✓ Done',
                            style: theme.textTheme
                                .labelLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color:
                                  theme.colorScheme.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders one hub card at a given span.
class _CardBody extends ConsumerWidget {
  final String id;
  final CardSpan span;
  final String Function(String id) planTitle;
  final void Function(Widget page) onOpen;
  final VoidCallback onResize;
  const _CardBody({
    required this.id,
    required this.span,
    required this.planTitle,
    required this.onOpen,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useNewLibrary = ref.watch(plansDesignProvider);
    switch (id) {
      case 'your_space':
        return _YourSpaceCard(span: span, onOpen: onOpen);
      case 'reading_plan':
        return _PlanSnapshotCard(
            span: span, planTitle: planTitle, onOpen: onOpen);
      case 'commentary':
        return _ToolCard(
          span: span,
          icon: Icons.library_books_rounded,
          eyebrow: 'Commentary',
          title: 'Verse-by-verse insight',
          snippet:
              'Historicist commentary with chapter + verse filters.',
          cta: 'Open Commentary',
          onTap: () => onOpen(
              const CommentaryLibraryV2Screen()),
        );
      case 'plans':
        return _ToolCard(
          span: span,
          icon: Icons.manage_search_rounded,
          eyebrow: 'Plans',
          title: 'Guided reading',
          snippet:
              'Curated, paced and custom plans with catch-up.',
          cta: 'Browse plans',
          onTap: () => onOpen(useNewLibrary
              ? const PlansLibraryScreen()
              : const PlansHubV3Screen()),
        );
      case 'dictionary':
        return _ToolCard(
          span: span,
          icon: Icons.book_outlined,
          eyebrow: 'Dictionary',
          title: 'Words defined',
          snippet: 'Easton & Smith, offline, with saved words.',
          cta: 'Look up',
          onTap: () =>
              onOpen(const DictionaryV2Screen()),
        );
      case 'bible_stories':
        return _ToolCard(
          span: span,
          icon: Icons.auto_stories_rounded,
          eyebrow: 'Bible stories',
          title: 'Narratives retold',
          snippet: '66 stories across every book.',
          cta: 'Read stories',
          onTap: () =>
              onOpen(const BibleStoriesScreen()),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Your Space banner: live counts → deep-link into YourSpaceScreen tabs.
class _YourSpaceCard extends ConsumerWidget {
  final CardSpan span;
  final void Function(Widget page) onOpen;
  const _YourSpaceCard(
      {required this.span, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final counts = [
      (
        Icons.bookmark_rounded,
        'Saved',
        ref.watch(bookmarksProvider).length,
        1
      ),
      (
        Icons.highlight_rounded,
        'Marked',
        ref.watch(highlightsProvider).length,
        0
      ),
      (
        Icons.note_alt_rounded,
        'Notes',
        ref.watch(notesProvider).length,
        2
      ),
      (
        Icons.menu_book_rounded,
        'Journal',
        ref.watch(journalProvider).length,
        3
      ),
    ];
    void go(int tab) =>
        onOpen(YourSpaceScreen(initialTab: tab));

    if (span == CardSpan.quarter) {
      final total = counts.fold<int>(0, (s, c) => s + c.$3);
      return V2Card(
        onTap: () => go(0),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_special_rounded,
                color: theme.primaryColor, size: 22),
            const SizedBox(height: 6),
            Text('$total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                )),
            Text('Your Space',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.65),
                )),
          ],
        ),
      );
    }

    final tiles = [
      for (final c in counts)
        Expanded(
          child: GestureDetector(
            onTap: () => go(c.$4),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                children: [
                  Icon(c.$1,
                      size: 18, color: theme.primaryColor),
                  const SizedBox(height: 4),
                  Text('${c.$3}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
                  Text(c.$2,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      )),
                ],
              ),
            ),
          ),
        ),
    ];

    return V2Card(
      featured: true,
      onTap: () => go(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: V2Eyebrow('Your Space')),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bookmarks, highlights, notes & journal',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (span == CardSpan.full)
            Row(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  tiles[i],
                ],
              ],
            )
          else
            Column(
              children: [
                Row(children: [tiles[0], const SizedBox(width: 8), tiles[1]]),
                const SizedBox(height: 8),
                Row(children: [tiles[2], const SizedBox(width: 8), tiles[3]]),
              ],
            ),
        ],
      ),
    );
  }
}

/// Active-plan snapshot (full + half variants).
class _PlanSnapshotCard extends ConsumerWidget {
  final CardSpan span;
  final String Function(String id) planTitle;
  final void Function(Widget page) onOpen;
  const _PlanSnapshotCard({
    required this.span,
    required this.planTitle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeIds = ref.watch(activePlanIdsProvider);
    final useNewLibrary = ref.watch(plansDesignProvider);

    if (activeIds.isEmpty) {
      return V2Card(
        onTap: () => onOpen(useNewLibrary
            ? const PlansLibraryScreen()
            : const PlansHubV3Screen()),
        child: Row(
          children: [
            Icon(Icons.menu_book_rounded,
                size: 32, color: theme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const V2Eyebrow('Reading plan'),
                  const SizedBox(height: 2),
                  Text('Start a reading plan',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      );
    }

    final planId = activeIds.first;
    final plan = ref.watch(readingPlanProvider(planId));
    final total = plan.planData.length;
    final current = plan.todayReadingDay ?? total;
    final behind = plan.missedDays.length;
    void open() => onOpen(
        ReadingPlanDetailV2Screen(planId: planId));

    if (span == CardSpan.quarter) {
      return V2Card(
        onTap: open,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            V2ProgressRing(
                fraction: plan.percentComplete, size: 44),
            const SizedBox(height: 6),
            Text('Day $current/$total',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                )),
          ],
        ),
      );
    }

    final ringSize = span == CardSpan.full ? 64.0 : 52.0;
    return V2Card(
      featured: span == CardSpan.full,
      onTap: open,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const V2Eyebrow('Active plan'),
          const SizedBox(height: 4),
          Text(
            planTitle(planId),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              V2ProgressRing(
                  fraction: plan.percentComplete,
                  size: ringSize),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                    V2ProgressBar(
                        fraction: plan.percentComplete),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        V2Badge(
                            '${(plan.percentComplete * 100).round()}% complete'),
                        if (behind > 0)
                          V2MetaChip('$behind behind')
                        else
                          const V2MetaChip('On track ✓'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (span == CardSpan.full) ...[
            const SizedBox(height: 12),
            _TodayRow(
                planId: planId,
                current: current,
                total: total),
          ],
        ],
      ),
    );
  }
}

class _TodayRow extends ConsumerWidget {
  final String planId;
  final int current;
  final int total;
  const _TodayRow({
    required this.planId,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(readingPlanProvider(planId));
    String label = 'Ready to begin';
    if (total > 0 && current >= 1 && current <= total) {
      label = plan.planData[current - 1].passages
          .map((p) => p.label)
          .join(' · ');
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Today: $label',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) =>
                    ReadingPlanDetailV2Screen(planId: planId),
              ));
            },
            child: Text(plan.completedReadings.contains(current)
                ? 'Review'
                : 'Read'),
          ),
        ],
      ),
    );
  }
}

/// Circular ••• resize affordance on hub cards (edit mode only).
class _ResizeDots extends StatelessWidget {
  const _ResizeDots();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Icon(
        Icons.more_horiz_rounded,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final CardSpan span;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String snippet;
  final String cta;
  final VoidCallback onTap;
  const _ToolCard({
    required this.span,
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
    if (span == CardSpan.quarter) {
      return V2Card(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.primaryColor, size: 22),
            const SizedBox(height: 6),
            Text(title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                )),
          ],
        ),
      );
    }
    return V2Card(
      featured: span == CardSpan.full,
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
            child:
                Icon(icon, size: 18, color: theme.primaryColor),
          ),
          const SizedBox(height: 8),
          V2Eyebrow(eyebrow),
          const SizedBox(height: 2),
          Text(title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (span == CardSpan.full) ...[
            const SizedBox(height: 4),
            Text(snippet,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                )),
          ],
          const SizedBox(height: 6),
          Text('$cta →',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
              )),
        ],
      ),
    );
  }
}
