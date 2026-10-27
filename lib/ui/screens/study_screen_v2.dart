import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/firebase_setup.dart';
import '../../state/journal_provider.dart';
import '../../state/notes_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/streak_provider.dart';
import '../../state/study_layout_provider.dart';
import '../../state/wotd_provider.dart';
import 'today_screen.dart';
import 'votd_archive_screen.dart';
import 'wotd_archive_screen.dart';
import '../../data/study_greetings.dart';
import '../../state/user_data_provider.dart'
    show bookmarksProvider, highlightsProvider;
import '../../data/local_storage/preferences_service.dart';
import '../widgets/account_menu.dart';
import '../widgets/plan_flow.dart';
import '../widgets/plans_library_widgets.dart'
    show PlanCoverPlaceholder, planInitials;
import '../widgets/study_v2_widgets.dart';
import 'bible_stories_screen.dart';
import 'commentary_library_v2_screen.dart';
import 'concordance_screen.dart';
import 'dictionary_v2_screen.dart';
import 'plans_library_screen.dart';
import 'reading_plan_detail_v2_screen.dart';
import 'your_space_screen.dart';
import '../../data/curated_plans.dart';
import '../../l10n/l10n.dart';
import '../../state/home_provider.dart';
import '../../theme/design_tokens.dart';

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
  'concordance',
  'commentary',
  'wotd',
  'votd_archive',
  'streak',
];

List<StudyCardConfig> _orderedCards(List<StudyCardConfig> stored) {
  final out = <StudyCardConfig>[];
  var plansLiveAdded = false;
  for (final c in stored) {
    // Merged widget: the old reading_plan + plans cards become one
    // plans_live card at the first of their positions.
    final id =
        (c.id == 'reading_plan' || c.id == 'plans') ? 'plans_live' : c.id;
    if (!_v2CardIds.contains(id)) continue;
    if (id == 'plans_live') {
      if (plansLiveAdded) continue;
      plansLiveAdded = true;
      out.add(StudyCardConfig(
        id: id,
        size: c.size,
        span: c.span == CardSpan.quarter ? CardSpan.full : c.span,
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
      Navigator.of(context)
          .push(CupertinoPageRoute<void>(builder: (_) => page));
    } catch (e) {
      reportNonFatal('study open screen', code: e.runtimeType.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.studyOpenScreenFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Long-press card sheet: size (Full or Half) + reorder.
  /// The only customization UI — no persistent handles, no edit mode.
  void _showCardSize(StudyCardConfig card, List<StudyCardConfig> cards) {
    final isFull = card.span == CardSpan.full;
    final isHalf = card.span == CardSpan.half;
    final index = cards.indexWhere((c) => c.id == card.id);
    final canUp = index > 0;
    final canDown = index >= 0 && index < cards.length - 1;
    showModalBottomSheet<void>(
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
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            title: Text(label),
            subtitle: Text(hint),
            trailing: selected
                ? Icon(Icons.check_rounded, color: theme.primaryColor)
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
                const BorderRadius.vertical(top: Radius.circular(Radii.xxl)),
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: V2Eyebrow(context.l10n.studyCardSize),
              ),
              option(
                label: context.l10n.studySizeFull,
                hint: context.l10n.studySizeFullHint,
                icon: Icons.crop_landscape_rounded,
                selected: isFull,
                onPick: () => ref
                    .read(studyLayoutProvider.notifier)
                    .setCardSize(card.id, span: CardSpan.full),
              ),
              option(
                label: context.l10n.studySizeHalf,
                hint: context.l10n.studySizeHalfHint,
                icon: Icons.splitscreen_rounded,
                selected: isHalf,
                onPick: () => ref
                    .read(studyLayoutProvider.notifier)
                    .setCardSize(card.id, span: CardSpan.half),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: V2Eyebrow(context.l10n.studyPosition),
              ),
              if (canUp)
                option(
                  label: context.l10n.studyMoveUp,
                  hint: context.l10n.studyMoveUpHint,
                  icon: Icons.arrow_upward_rounded,
                  selected: false,
                  onPick: () => ref
                      .read(studyLayoutProvider.notifier)
                      .move(card.id, cards[index - 1].id),
                ),
              if (canDown)
                option(
                  label: context.l10n.studyMoveDown,
                  hint: context.l10n.studyMoveDownHint,
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
    final streak = ref.watch(streakProvider);
    final now = DateTime.now();
    final greeting = greetingFor(
      l10n: context.l10n,
      now: now,
      streakCount: streak.count,
      distinctDaysThisYear: streak.distinctDaysThisYear,
    );
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
                // Greeting + account: eyebrow/title/subtitle rhythm
                // mirrors the cards below; avatar centers on the block.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          V2Eyebrow(greetingEyebrow(now, context.l10n)),
                          const SizedBox(height: 2),
                          Text(
                            greeting.title,
                            key: const Key('studyGreetingTitle'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            greeting.subtitle,
                            key: const Key('studyGreetingSubtitle'),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: context.l10n.accountAccount,
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          showAccountMenu(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          // 40 avatar + 2x4 padding = 48dp target.
                          child: AccountAvatar(size: 40),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Cards (Full default; halves pair up).
                Builder(
                  builder: (context) {
                    const gap = 12.0;

                    // Two sizes only: Full and Half. [span] overrides the
                    // stored span (an unpaired half renders Full).
                    Widget cardBox(StudyCardConfig card, {CardSpan? span}) {
                      final framed = _CardBody(
                        id: card.id,
                        span: span ?? card.span,
                        planTitle: _planTitle,
                        onOpen: _push,
                      );
                      return Semantics(
                        // Screen readers reach the long-press sheet by name.
                        customSemanticsActions: {
                          CustomSemanticsAction(
                                  label: context.l10n.studyCardSize):
                              () => _showCardSize(card, cards),
                        },
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            _showCardSize(card, cards);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: framed,
                          ),
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
                      // Stretch so a card whose content has no Expanded/
                      // Spacer still fills its row instead of collapsing to
                      // its text width (Full = full width, always).
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final row in rows)
                          if (row.length == 2)
                            // The cards carry the bottom gap themselves, so
                            // the row must not add a second one: every row
                            // in the column keeps the same 12dp rhythm.
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: cardBox(row[0])),
                                  const SizedBox(width: gap),
                                  Expanded(child: cardBox(row[1])),
                                ],
                              ),
                            )
                          else
                            // A lone half has no partner to match, so it
                            // takes the full row instead of leaving a gap.
                            cardBox(row[0], span: CardSpan.full),
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

/// Renders one hub card. Full = full width, Half = compact half width.
class _CardBody extends ConsumerWidget {
  final String id;
  final CardSpan span;
  final String Function(String id) planTitle;
  final void Function(Widget page) onOpen;
  const _CardBody({
    required this.id,
    required this.span,
    required this.planTitle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    switch (id) {
      case 'your_space':
        return _YourSpaceCard(span: span, onOpen: onOpen);
      case 'plans_live':
        return _PlansLiveCard(span: span, planTitle: planTitle, onOpen: onOpen);
      case 'commentary':
        return _ToolCard(
          span: span,
          icon: Icons.library_books_rounded,
          eyebrow: l10n.studyCommentaryEyebrow,
          title: l10n.studyCommentaryTitle,
          snippet: l10n.studyCommentarySnippet,
          cta: l10n.studyCommentaryCta,
          onTap: () => onOpen(const CommentaryLibraryV2Screen()),
        );
      case 'dictionary':
        return _ToolCard(
          span: span,
          icon: Icons.book_outlined,
          eyebrow: l10n.studyDictionaryEyebrow,
          title: l10n.studyDictionaryTitle,
          snippet: l10n.studyDictionarySnippet,
          cta: l10n.studyDictionaryCta,
          onTap: () => onOpen(const DictionaryV2Screen()),
        );
      case 'bible_stories':
        return _ToolCard(
          span: span,
          icon: Icons.auto_stories_rounded,
          eyebrow: l10n.studyStoriesEyebrow,
          title: l10n.studyStoriesTitle,
          snippet: l10n.studyStoriesSnippet,
          cta: l10n.studyStoriesCta,
          onTap: () => onOpen(const BibleStoriesScreen()),
        );
      case 'concordance':
        return _ConcordanceCard(span: span, onOpen: onOpen);
      case 'wotd':
        return _WotdCard(span: span, onOpen: onOpen);
      case 'votd_archive':
        return _VotdCard(span: span, onOpen: onOpen);
      case 'streak':
        return _StreakCard(span: span, onOpen: onOpen);
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Your Space banner: live counts → deep-link into YourSpaceScreen tabs.
class _YourSpaceCard extends ConsumerWidget {
  final CardSpan span;
  final void Function(Widget page) onOpen;
  const _YourSpaceCard({required this.span, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final counts = [
      (
        Icons.bookmark_rounded,
        l10n.studySpaceSaved,
        ref.watch(bookmarksProvider).length,
        1
      ),
      (
        Icons.highlight_rounded,
        l10n.studySpaceMarked,
        ref.watch(highlightsProvider).length,
        0
      ),
      (
        Icons.note_alt_rounded,
        l10n.studySpaceNotes,
        ref.watch(notesProvider).length,
        2
      ),
      (
        Icons.menu_book_rounded,
        l10n.studySpaceJournal,
        ref.watch(journalProvider).length,
        3
      ),
    ];
    void go(int tab) => onOpen(YourSpaceScreen(initialTab: tab));

    final tiles = [
      for (final c in counts)
        Expanded(
          child: Semantics(
            button: true,
            child: GestureDetector(
              onTap: () => go(c.$4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Radii.lg),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(c.$1, size: 18, color: theme.primaryColor),
                    const SizedBox(height: 4),
                    Text('${c.$3}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        )),
                    Text(c.$2,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: TypeScale.micro,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.65),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
    ];

    return V2Card(
      textured: true,
      featured: true,
      onTap: () => go(0),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: V2Eyebrow(l10n.studySpaceTitle)),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.studySpaceSubtitle,
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

/// Reading-plan widget. One card, no hidden pages, sized to its content:
/// - no plan: a short pitch, three plans to try, "Pick a plan";
/// - one plan: progress plus today's reading with a Read button that
///   opens the reader directly (two taps from Study to scripture);
/// - several plans: up to two rows, each with its own Read button.
/// Half span keeps the progress summary and a single Read button.
class _PlansLiveCard extends ConsumerWidget {
  final CardSpan span;
  final String Function(String id) planTitle;
  final void Function(Widget page) onOpen;

  const _PlansLiveCard({
    required this.span,
    required this.planTitle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIds = ref.watch(activePlanIdsProvider);
    final full = span == CardSpan.full;
    void openLibrary() => onOpen(const PlansLibraryScreen());
    void openDetail(String id) => onOpen(ReadingPlanDetailV2Screen(planId: id));

    final Widget child;
    VoidCallback onTap = openLibrary;
    if (activeIds.isEmpty) {
      child = _PlanPitch(full: full, onBrowse: openLibrary, onPlan: openDetail);
    } else if (!full) {
      child = _PlanSummaryHalf(planId: activeIds.first, title: planTitle);
      onTap = () => openDetail(activeIds.first);
    } else if (activeIds.length == 1) {
      child = _PlanSummaryFull(
        planId: activeIds.first,
        title: planTitle,
        onAll: openLibrary,
      );
      onTap = () => openDetail(activeIds.first);
    } else {
      child = _PlanStack(
        planIds: activeIds.take(2).toList(),
        count: activeIds.length,
        title: planTitle,
        onAll: openLibrary,
        onPlan: openDetail,
      );
    }

    return V2Card(
      textured: true,
      featured: full,
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: AnimatedSize(
        duration: Motion.of(context, Motion.normal),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }
}

/// Empty state: why a plan helps, three to try, and the way in.
class _PlanPitch extends StatelessWidget {
  final bool full;
  final VoidCallback onBrowse;
  final void Function(String id) onPlan;
  const _PlanPitch(
      {required this.full, required this.onBrowse, required this.onPlan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final picks = availablePlans.where((p) => p.isAvailable).take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  V2Eyebrow(l10n.studyReadingPlan),
                  const SizedBox(height: 4),
                  Text(
                    l10n.planFlowEmptyTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  if (full) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.planFlowEmptyBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.palette.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (full) ...[
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child:
                    Icon(Icons.auto_stories_rounded, color: theme.primaryColor),
              ),
            ],
          ],
        ),
        if (full && picks.isNotEmpty) ...[
          const SizedBox(height: 12),
          // One swipeable row of plans to try; each opens its Plan page,
          // where "Start & read day 1" is one more tap.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (final p in picks)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(Icons.menu_book_rounded,
                          size: 16, color: theme.primaryColor),
                      label: Text(p.title),
                      onPressed: () => onPlan(p.id),
                      shape: const StadiumBorder(),
                      side: BorderSide(color: context.palette.divider),
                      backgroundColor:
                          theme.primaryColor.withValues(alpha: 0.06),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(
              onPressed: onBrowse,
              style: planFilledStyle(context),
              child: Text(l10n.planFlowPickPlan),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ],
    );
  }
}

/// Ring, title, bar and day count for one plan.
class _PlanProgressHeader extends ConsumerWidget {
  final String planId;
  final String Function(String id) title;
  const _PlanProgressHeader({required this.planId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final plan = ref.watch(readingPlanProvider(planId));
    final total = plan.planData.length;
    final current = plan.todayReadingDay ?? total;
    return Row(
      children: [
        V2ProgressRing(fraction: plan.percentComplete, size: 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              V2Eyebrow(l10n.studyActivePlan),
              const SizedBox(height: 2),
              Text(
                title(planId),
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
                    child: V2ProgressBar(fraction: plan.percentComplete),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    total == 0 ? '…' : l10n.studyDayOfTotal(current, total),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.palette.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanSummaryFull extends ConsumerWidget {
  final String planId;
  final String Function(String id) title;
  final VoidCallback onAll;
  const _PlanSummaryFull(
      {required this.planId, required this.title, required this.onAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(readingPlanProvider(planId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlanProgressHeader(planId: planId, title: title),
        const SizedBox(height: 14),
        PlanTodayWell(child: PlanTodayPanel(planId: planId, compact: true)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (plan.planData.isNotEmpty) PlanStatusChip(plan: plan),
            const Spacer(),
            PlanLink(label: context.l10n.planFlowAllPlans, onTap: onAll),
          ],
        ),
      ],
    );
  }
}

class _PlanSummaryHalf extends ConsumerWidget {
  final String planId;
  final String Function(String id) title;
  const _PlanSummaryHalf({required this.planId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final plan = ref.watch(readingPlanProvider(planId));
    final total = plan.planData.length;
    final target = planTarget(plan);
    final canRead = total > 0 && target.kind != PlanTargetKind.complete;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            V2ProgressRing(fraction: plan.percentComplete, size: 44),
            const Spacer(),
            if (plan.missedDays.isNotEmpty) PlanStatusChip(plan: plan),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title(planId),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          total == 0 ? '…' : l10n.studyDayOfTotal(target.day, total),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.palette.textMuted,
          ),
        ),
        if (canRead) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => openPlanDay(context, planId, target.day),
              style: planTonalStyle(context),
              child: Text(target.kind == PlanTargetKind.doneToday
                  ? l10n.planFlowReadAhead
                  : l10n.studyRead),
            ),
          ),
        ],
      ],
    );
  }
}

/// Two or three active plans, each one row with its own Read button.
class _PlanStack extends ConsumerWidget {
  final List<String> planIds;
  final int count;
  final String Function(String id) title;
  final VoidCallback onAll;
  final void Function(String id) onPlan;
  const _PlanStack({
    required this.planIds,
    required this.count,
    required this.title,
    required this.onAll,
    required this.onPlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: V2Eyebrow(l10n.planFlowYourPlans(count))),
            PlanLink(label: l10n.planFlowAllPlans, onTap: onAll),
          ],
        ),
        for (final id in planIds)
          Builder(builder: (context) {
            final plan = ref.watch(readingPlanProvider(id));
            final total = plan.planData.length;
            final target = planTarget(plan);
            final done = target.kind == PlanTargetKind.doneToday ||
                target.kind == PlanTargetKind.complete;
            final palette = context.palette;
            return InkWell(
              borderRadius: BorderRadius.circular(Radii.lg),
              onTap: () => onPlan(id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    PlanCoverPlaceholder(
                      seed: id,
                      initials: planInitials(title(id)),
                      width: 44,
                      height: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title(id),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: V2ProgressBar(
                                    fraction: plan.percentComplete),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                done
                                    ? '✓'
                                    : total == 0
                                        ? '…'
                                        : l10n.plansDayN(target.day),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: done
                                      ? palette.success
                                      : target.kind == PlanTargetKind.catchUp
                                          ? palette.warning
                                          : palette.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (total > 0 && target.kind != PlanTargetKind.complete)
                      FilledButton(
                        onPressed: () => openPlanDay(context, id, target.day),
                        style: done
                            ? planTonalStyle(context)
                            : planFilledStyle(context),
                        child: Text(
                            done ? l10n.planFlowReadAhead : l10n.studyRead),
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
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
    const iconBox = 34.0;
    return V2Card(
      textured: true,
      featured: span == CardSpan.full,
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, size: 18, color: theme.primaryColor),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ],
          const SizedBox(height: 6),
          Text(context.l10n.studyCtaArrow(cta),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
              )),
        ],
      ),
    );
  }
}

/// Word-of-the-day card: today's word with definition and dictionary entry point.
class _WotdCard extends ConsumerWidget {
  final CardSpan span;
  final void Function(Widget page) onOpen;
  const _WotdCard({
    required this.span,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final wotdAsync = ref.watch(wordOfTheDayProvider);
    const iconBox = 34.0;

    void openArchive() => onOpen(const WotdArchiveScreen());

    Widget content(String word, String? snippet, String? normalized) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(Icons.spellcheck_rounded,
                size: 18, color: theme.primaryColor),
          ),
          const SizedBox(height: 8),
          V2Eyebrow(l10n.studyWordOfTheDayHistory),
          const SizedBox(height: 2),
          Text(word,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (span == CardSpan.full &&
              snippet != null &&
              snippet.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(snippet,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ],
          const SizedBox(height: 6),
          Text(context.l10n.studyCtaArrow(l10n.studyRecentWords),
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
            textured: true,
            featured: span == CardSpan.full,
            onTap: openArchive,
            padding: const EdgeInsets.all(15),
            child: content(l10n.studyWordOfTheDayHistory, null, null),
          );
        }
        return V2Card(
          textured: true,
          featured: span == CardSpan.full,
          onTap: openArchive,
          padding: const EdgeInsets.all(15),
          child: content(wotd.word, wotd.snippet, wotd.normalized),
        );
      },
      loading: () => V2Card(
        textured: true,
        featured: span == CardSpan.full,
        padding: const EdgeInsets.all(15),
        child: Text(l10n.studyLoading,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            )),
      ),
      error: (_, __) => V2Card(
        textured: true,
        featured: span == CardSpan.full,
        onTap: openArchive,
        padding: const EdgeInsets.all(15),
        child: content(
            l10n.studyWordOfTheDayHistory, l10n.studyUnavailableNow, null),
      ),
    );
  }
}

/// Verse-of-the-day card: today's scripture anchor with recent VOTDs archive entry.
class _VotdCard extends ConsumerWidget {
  final CardSpan span;
  final void Function(Widget page) onOpen;
  const _VotdCard({
    required this.span,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final pool = ref.watch(votdPoolProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final epoch = DateTime(2026, 1, 1);
    final dayIndex =
        pool.isEmpty ? 0 : today.difference(epoch).inDays % pool.length;
    final validIndex = dayIndex < 0 ? dayIndex + pool.length : dayIndex;
    final votdEntry = pool.isEmpty ? null : pool[validIndex];
    const iconBox = 34.0;

    void openArchive() => onOpen(const VotdArchiveScreen());

    return V2Card(
      textured: true,
      featured: span == CardSpan.full,
      onTap: openArchive,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(Icons.format_quote_rounded,
                size: 18, color: theme.primaryColor),
          ),
          const SizedBox(height: 8),
          V2Eyebrow(l10n.studyVerseOfTheDayHistory),
          const SizedBox(height: 2),
          Text(votdEntry?.reference ?? l10n.studyVerseOfTheDay,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (span == CardSpan.full && votdEntry != null) ...[
            const SizedBox(height: 4),
            Text(votdEntry.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ],
          const SizedBox(height: 6),
          Text(context.l10n.studyCtaArrow(l10n.studyRecentVerses),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
              )),
        ],
      ),
    );
  }
}

/// Concordance card with interactive quick-search keyword chips.
class _ConcordanceCard extends StatelessWidget {
  final CardSpan span;
  final void Function(Widget page) onOpen;
  const _ConcordanceCard({
    required this.span,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    const iconBox = 34.0;
    const quickWords = ['grace', 'faith', 'love', 'peace'];

    return V2Card(
      textured: true,
      featured: span == CardSpan.full,
      onTap: () => onOpen(const ConcordanceScreen()),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(Icons.find_in_page_rounded,
                    size: 18, color: theme.primaryColor),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          V2Eyebrow(l10n.studyConcordanceEyebrow),
          const SizedBox(height: 2),
          Text(l10n.studyConcordanceTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (span == CardSpan.full) ...[
            const SizedBox(height: 4),
            Text(l10n.studyConcordanceSnippet,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final w in quickWords)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onOpen(ConcordanceScreen(initialWord: w)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Radii.sm),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        '${w[0].toUpperCase()}${w.substring(1)}',
                        style: TextStyle(
                          fontSize: TypeScale.micro,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(context.l10n.studyCtaArrow(l10n.studyConcordanceCta),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
              )),
        ],
      ),
    );
  }
}

/// Reading-streak card: flame count with a TodayScreen entry point.
/// Mirrors the _ToolCard half/full structure for row symmetry.
class _StreakCard extends ConsumerWidget {
  final CardSpan span;
  final void Function(Widget page) onOpen;
  const _StreakCard({
    required this.span,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streak = ref.watch(streakProvider);
    final count = streak.count;
    const iconBox = 34.0;
    return V2Card(
      textured: true,
      featured: span == CardSpan.full,
      onTap: () => onOpen(const TodayScreen()),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(Icons.local_fire_department_rounded,
                size: 18,
                color: count > 0
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 8),
          V2Eyebrow(context.l10n.studyReadingStreak),
          const SizedBox(height: 2),
          Text(
              count == 0
                  ? context.l10n.studyStartStreak
                  : context.l10n.studyStreakDays(count),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          if (span == CardSpan.full) ...[
            const SizedBox(height: 4),
            Text(
                count > 0
                    ? context.l10n.studyStreakGrow
                    : context.l10n.studyStreakStart,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ],
          const SizedBox(height: 6),
          Text(context.l10n.studyViewProgress,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
              )),
        ],
      ),
    );
  }
}
