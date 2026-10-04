import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/journal_provider.dart';
import '../../state/notes_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/plans_design_provider.dart';
import '../../state/streak_provider.dart';
import '../../state/study_layout_provider.dart';
import '../../state/wotd_provider.dart';
import 'today_screen.dart';
import 'votd_archive_screen.dart';
import '../../state/theme_provider.dart';
import '../../state/user_data_provider.dart'
    show bookmarksProvider, highlightsProvider;
import '../../data/local_storage/preferences_service.dart';
import '../widgets/account_menu.dart';
import '../widgets/study_v2_widgets.dart';
import 'bible_stories_screen.dart';
import 'commentary_library_v2_screen.dart';
import 'dictionary_v2_screen.dart';
import 'plans_hub_v3_screen.dart';
import 'plans_library_screen.dart';
import 'reading_plan_detail_v2_screen.dart';
import 'your_space_screen.dart';
import 'plans_hub_v2_screen.dart' show availablePlans;

/// Redesigned Study hub (V2): Large by default, every card the same
/// size.
///
/// - Card order + per-card size persist via [studyLayoutProvider];
///   long-press any card for the size + Move up/down sheet. The v5
///   default view is Your Space, Plans live (both full), Stories +
///   Dictionary (halves), Commentary (full), VOTD + Streak (halves).
/// - Long-press a card to pick Large / Extra Large / Half. No persistent
///   resize dots, no edit mode.
/// - No Continue Reading card (resume lives in the plan snapshot + Read
///   tab).
/// - Top banner is Your Space: live bookmark/highlight/note/journal counts.
/// - Header avatar opens the account menu (login, settings, backup,
///   restore, reset).
class StudyScreenV2 extends ConsumerStatefulWidget {
  const StudyScreenV2({super.key});

  @override
  ConsumerState<StudyScreenV2> createState() => _StudyScreenV2State();
}

const _v2CardIds = [
  'your_space',
  'plans_live',
  'bible_stories',
  'dictionary',
  'commentary',
  'votd_archive',
  'streak',
];

List<StudyCardConfig> _orderedCards(List<StudyCardConfig> stored) {
  final out = <StudyCardConfig>[];
  var plansLiveAdded = false;
  for (final c in stored) {
    // Merged widget: the old reading_plan + plans cards become one
    // plans_live card at the first of their positions.
    final id = (c.id == 'reading_plan' || c.id == 'plans')
        ? 'plans_live'
        : c.id;
    if (!_v2CardIds.contains(id)) continue;
    if (id == 'plans_live') {
      if (plansLiveAdded) continue;
      plansLiveAdded = true;
      out.add(StudyCardConfig(
        id: id,
        size: c.size,
        span: c.span == CardSpan.quarter ? CardSpan.full : c.span,
        expanded: c.expanded,
      ));
      continue;
    }
    out.add(c);
  }
  // Missing defaults are appended — checked against the merged list
  // (not the raw stored ids) so the reading_plan/plans -> plans_live
  // mapping above never yields a duplicate card.
  final present = {for (final c in out) c.id};
  for (final def in StudyLayoutNotifier.defaultLayoutV2()) {
    if (!present.contains(def.id)) out.add(def);
  }
  return out;
}

class _StudyScreenV2State extends ConsumerState<StudyScreenV2> {
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

  /// Long-press card sheet: size (Large, Extra Large, Half) + reorder.
  /// The only customization UI — no persistent handles, no edit mode.
  void _showCardSize(
      StudyCardConfig card, List<StudyCardConfig> cards) {
    final isLarge =
        card.span == CardSpan.full && !card.expanded;
    final isXLarge =
        card.span == CardSpan.full && card.expanded;
    final isHalf = card.span == CardSpan.half;
    final index = cards.indexWhere((c) => c.id == card.id);
    final canUp = index > 0;
    final canDown = index >= 0 && index < cards.length - 1;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        Widget option({
          required String label,
          required String hint,
          required IconData icon,
          required bool selected,
          required VoidCallback onPick,
        }) {
          return ListTile(
            leading: Icon(
              icon,
              color: selected
                  ? theme.primaryColor
                  : theme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
            ),
            title: Text(label),
            subtitle: Text(hint),
            trailing: selected
                ? Icon(Icons.check_rounded,
                    color: theme.primaryColor)
                : null,
            onTap: () {
              HapticFeedback.selectionClick();
              onPick();
              Navigator.of(ctx).pop();
            },
          );
        }

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
              option(
                label: 'Large',
                hint: 'Full width, same size as everything',
                icon: Icons.crop_landscape_rounded,
                selected: isLarge,
                onPick: () => ref
                    .read(studyLayoutProvider.notifier)
                    .setCardSize(card.id,
                        span: CardSpan.full, expanded: false),
              ),
              option(
                label: 'Extra Large',
                hint: 'Full width, roomier content',
                icon: Icons.aspect_ratio_rounded,
                selected: isXLarge,
                onPick: () => ref
                    .read(studyLayoutProvider.notifier)
                    .setCardSize(card.id,
                        span: CardSpan.full, expanded: true),
              ),
              option(
                label: 'Half',
                hint: 'Compact, two per row',
                icon: Icons.splitscreen_rounded,
                selected: isHalf,
                onPick: () => ref
                    .read(studyLayoutProvider.notifier)
                    .setCardSize(card.id,
                        span: CardSpan.half, expanded: false),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: V2Eyebrow('Position'),
              ),
              if (canUp)
                option(
                  label: 'Move up',
                  hint: 'Swap with the card above',
                  icon: Icons.arrow_upward_rounded,
                  selected: false,
                  onPick: () => ref
                      .read(studyLayoutProvider.notifier)
                      .move(card.id, cards[index - 1].id),
                ),
              if (canDown)
                option(
                  label: 'Move down',
                  hint: 'Swap with the card below',
                  icon: Icons.arrow_downward_rounded,
                  selected: false,
                  onPick: () => ref
                      .read(studyLayoutProvider.notifier)
                      .move(card.id, cards[index + 1].id),
                ),
            ],
          ),
        );
      },
    );
  }


  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final subGreeting = appThemeMode.resolve(context).subGreeting;
    final layout = ref.watch(studyLayoutProvider);
    final cards = _orderedCards(layout);

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
                // Greeting + account.
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
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        showAccountMenu(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        // 40 avatar + 2x2 padding = 44pt target.
                        child: AccountAvatar(size: 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Cards (Large default; halves pair up).
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 12.0;
                    final halfW =
                        (constraints.maxWidth - gap) / 2;

                    Widget cardBox(StudyCardConfig card,
                        {double? width}) {
                      final body = _CardBody(
                        id: card.id,
                        span: card.span,
                        expanded: card.expanded,
                        planTitle: _planTitle,
                        onOpen: _push,
                      );
                      final framed = width == null
                          ? body
                          : SizedBox(width: width, child: body);
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          _showCardSize(card, cards);
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: 12),
                          child: framed,
                        ),
                      );
                    }

                    // Pack halves into pairs; full cards own rows.
                    final rows = <List<StudyCardConfig>>[];
                    StudyCardConfig? pendingHalf;
                    for (final card in cards) {
                      if (card.span == CardSpan.half) {
                        if (pendingHalf == null) {
                          pendingHalf = card;
                        } else {
                          rows.add([pendingHalf, card]);
                          pendingHalf = null;
                        }
                      } else {
                        if (pendingHalf != null) {
                          rows.add([pendingHalf]);
                          pendingHalf = null;
                        }
                        rows.add([card]);
                      }
                    }
                    if (pendingHalf != null) {
                      rows.add([pendingHalf]);
                    }

                    return Column(
                      children: [
                        for (final row in rows)
                          if (row.length == 2)
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 12),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                        child: cardBox(row[0])),
                                    const SizedBox(width: gap),
                                    Expanded(
                                        child: cardBox(row[1])),
                                  ],
                                ),
                              ),
                            )
                          else if (row[0].span == CardSpan.half)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: halfW,
                                child: cardBox(row[0]),
                              ),
                            )
                          else
                            cardBox(row[0]),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders one hub card. Large = full width, Half = compact half
/// width, Extra Large = full width with expanded content.
class _CardBody extends ConsumerWidget {
  final String id;
  final CardSpan span;
  final bool expanded;
  final String Function(String id) planTitle;
  final void Function(Widget page) onOpen;
  const _CardBody({
    required this.id,
    required this.span,
    this.expanded = false,
    required this.planTitle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (id) {
      case 'your_space':
        return _YourSpaceCard(
            span: span, expanded: expanded, onOpen: onOpen);
      case 'plans_live':
        return _PlansLiveCard(
            span: span,
            expanded: expanded,
            planTitle: planTitle,
            onOpen: onOpen);
      case 'commentary':
        return _ToolCard(
          span: span,
          expanded: expanded,
          icon: Icons.library_books_rounded,
          eyebrow: 'Commentary',
          title: 'Verse-by-verse insight',
          snippet:
              'Historicist commentary with chapter + verse filters.',
          cta: 'Open Commentary',
          onTap: () => onOpen(
              const CommentaryLibraryV2Screen()),
        );
      case 'dictionary':
        return _ToolCard(
          span: span,
          expanded: expanded,
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
          expanded: expanded,
          icon: Icons.auto_stories_rounded,
          eyebrow: 'Bible stories',
          title: 'Narratives retold',
          snippet: '66 stories across every book.',
          cta: 'Read stories',
          onTap: () =>
              onOpen(const BibleStoriesScreen()),
        );
      case 'votd_archive':
        return _VotdArchiveCard(
            span: span, expanded: expanded, onOpen: onOpen);
      case 'streak':
        return _StreakCard(
            span: span, expanded: expanded, onOpen: onOpen);
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Your Space banner: live counts → deep-link into YourSpaceScreen tabs.
class _YourSpaceCard extends ConsumerWidget {
  final CardSpan span;
  final bool expanded;
  final void Function(Widget page) onOpen;
  const _YourSpaceCard(
      {required this.span, this.expanded = false, required this.onOpen});

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
      padding: EdgeInsets.all(expanded ? 22 : 18),
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
/// Merged plans widget: a swipeable live snapshot (page 1) plus a
/// browse entry (page 2). Replaces the old reading-plan + plans cards.
class _PlansLiveCard extends ConsumerStatefulWidget {
  final CardSpan span;
  final bool expanded;
  final String Function(String id) planTitle;
  final void Function(Widget page) onOpen;
  const _PlansLiveCard({
    required this.span,
    this.expanded = false,
    required this.planTitle,
    required this.onOpen,
  });

  @override
  ConsumerState<_PlansLiveCard> createState() => _PlansLiveCardState();
}

class _PlansLiveCardState extends ConsumerState<_PlansLiveCard> {
  late final PageController _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeIds = ref.watch(activePlanIdsProvider);
    final useNewLibrary = ref.watch(plansDesignProvider);
    void openLibrary() => widget.onOpen(useNewLibrary
        ? const PlansLibraryScreen()
        : const PlansHubV3Screen());
    void openDetail(String id) =>
        widget.onOpen(ReadingPlanDetailV2Screen(planId: id));

    final hasActive = activeIds.isNotEmpty;
    final planId = hasActive ? activeIds.first : null;
    final plan = planId == null
        ? null
        : ref.watch(readingPlanProvider(planId));
    final total = plan?.planData.length ?? 0;
    final current = plan?.todayReadingDay ?? total;
    final behind = plan?.missedDays.length ?? 0;

    Widget livePage() {
      if (!hasActive) {
        return Row(
          children: [
            Icon(Icons.menu_book_rounded,
                size: 32, color: theme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
        );
      }
      return Row(
        children: [
          V2ProgressRing(
              fraction: plan!.percentComplete,
              size: widget.span == CardSpan.full ? 56.0 : 48.0),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const V2Eyebrow('Active plan'),
                const SizedBox(height: 2),
                Text(
                  widget.planTitle(planId!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: V2ProgressBar(
                          fraction: plan.percentComplete),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      total == 0
                          ? '…'
                          : 'Day $current of $total',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                if (behind > 0) ...[
                  const SizedBox(height: 4),
                  V2MetaChip('$behind behind'),
                ],
              ],
            ),
          ),
        ],
      );
    }

    Widget browsePage() {
      return Row(
        children: [
          Icon(Icons.manage_search_rounded,
              size: 32, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const V2Eyebrow('Plans'),
                const SizedBox(height: 2),
                Text('Guided reading',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 2),
                Text('Curated, paced and custom',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    )),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      );
    }

    void handleTap() {
      if (_page == 1 || !hasActive) {
        openLibrary();
      } else {
        openDetail(planId!);
      }
    }

    return V2Card(
      featured: widget.span == CardSpan.full,
      onTap: handleTap,
      padding: EdgeInsets.all(widget.expanded ? 22 : 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 132,
            child: PageView(
              controller: _pages,
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                Center(child: livePage()),
                Center(child: browsePage()),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 2; i++)
                Container(
                  width: 6,
                  height: 6,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface
                            .withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          if (widget.expanded && hasActive && total > 0) ...[
            const SizedBox(height: 12),
            _TodayRow(
                planId: planId!, current: current, total: total),
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

class _ToolCard extends StatelessWidget {
  final CardSpan span;
  final bool expanded;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String snippet;
  final String cta;
  final VoidCallback onTap;
  const _ToolCard({
    required this.span,
    this.expanded = false,
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
    final iconBox = expanded ? 52.0 : 34.0;
    return V2Card(
      featured: span == CardSpan.full,
      onTap: onTap,
      padding: EdgeInsets.all(expanded ? 20 : 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon,
                size: expanded ? 24 : 18,
                color: theme.primaryColor),
          ),
          const SizedBox(height: 8),
          V2Eyebrow(eyebrow),
          const SizedBox(height: 2),
          Text(title,
              style: (expanded
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.titleSmall)
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (span == CardSpan.full || expanded) ...[
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

/// Word-of-the-day card: today's word with an archive entry point.
/// Mirrors the _ToolCard half/full structure for row symmetry.
class _VotdArchiveCard extends ConsumerWidget {
  final CardSpan span;
  final bool expanded;
  final void Function(Widget page) onOpen;
  const _VotdArchiveCard({
    required this.span,
    this.expanded = false,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wotdAsync = ref.watch(wordOfTheDayProvider);
    void open() => onOpen(const VotdArchiveScreen());

    Widget body(String title, String? snippet, {bool showSnippet = true}) {
      final iconBox = expanded ? 52.0 : 34.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(Icons.spellcheck_rounded,
                size: expanded ? 24 : 18,
                color: theme.primaryColor),
          ),
          const SizedBox(height: 8),
          const V2Eyebrow('Word of the day'),
          const SizedBox(height: 2),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: (expanded
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.titleSmall)
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (showSnippet && snippet != null && snippet.isNotEmpty) ...[
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
          Text('Archive →',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
              )),
        ],
      );
    }

    return wotdAsync.when(
      data: (wotd) {
        if (wotd == null) {
          return V2Card(
            featured: span == CardSpan.full,
            onTap: open,
            padding: EdgeInsets.all(expanded ? 20 : 15),
            child: body('Word of the day', null,
                showSnippet: false),
          );
        }
        return V2Card(
          featured: span == CardSpan.full,
          onTap: open,
          padding: EdgeInsets.all(expanded ? 20 : 15),
          child: body(wotd.word, wotd.snippet,
              showSnippet:
                  span == CardSpan.full || expanded),
        );
      },
      loading: () => V2Card(
        featured: span == CardSpan.full,
        padding: const EdgeInsets.all(15),
        child: Text('Loading…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            )),
      ),
      error: (_, __) => V2Card(
        featured: span == CardSpan.full,
        onTap: open,
        padding: const EdgeInsets.all(15),
        child: body('Word of the day', 'Unavailable right now',
            showSnippet: false),
      ),
    );
  }
}

/// Reading-streak card: flame count with a TodayScreen entry point.
/// Mirrors the _ToolCard half/full structure for row symmetry.
class _StreakCard extends ConsumerWidget {
  final CardSpan span;
  final bool expanded;
  final void Function(Widget page) onOpen;
  const _StreakCard({
    required this.span,
    this.expanded = false,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streak = ref.watch(streakProvider);
    final count = streak.count;
    final iconBox = expanded ? 52.0 : 34.0;
    return V2Card(
      featured: span == CardSpan.full,
      onTap: () => onOpen(const TodayScreen()),
      padding: EdgeInsets.all(expanded ? 20 : 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(Icons.local_fire_department_rounded,
                size: expanded ? 24 : 18,
                color: count > 0
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface
                        .withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 8),
          const V2Eyebrow('Reading streak'),
          const SizedBox(height: 2),
          Text(
              count == 0
                  ? 'Start your streak'
                  : '$count day${count == 1 ? '' : 's'}',
              style: (expanded
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.titleSmall)
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (span == CardSpan.full || expanded) ...[
            const SizedBox(height: 4),
            Text(
                count > 0
                    ? 'Open daily to grow it.'
                    : 'Complete a reading each day.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                )),
          ],
          const SizedBox(height: 6),
          Text('View progress →',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
              )),
        ],
      ),
    );
  }
}
