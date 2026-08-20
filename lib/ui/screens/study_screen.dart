import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/study_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/commentary_provider.dart';
import '../../state/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/your_space_hero.dart';

import '../../state/study_layout_provider.dart';
import '../widgets/account_button.dart';
import '../widgets/jiggle_animator.dart';
import '../../state/reading_plan_provider.dart';
import 'reading_plans_hub_screen.dart';
import 'commentary_hub_screen.dart';
import 'commentary_library_screen.dart';
import '../../state/streak_provider.dart';
import '../../state/auth_provider.dart';
import 'admin/admin_constants.dart';
import 'admin/admin_dashboard_screen.dart';
import '../widgets/plan_row_widget.dart';
import '../../state/plans_hub_style_provider.dart';
import 'plans_hub_v2_screen.dart';
class _ParsedRef {
  final String book;
  final int chapter;
  final int? verse;
  _ParsedRef(this.book, this.chapter, this.verse);
}

_ParsedRef _parseReference(String refStr) {
  final lastSpaceIdx = refStr.lastIndexOf(' ');
  if (lastSpaceIdx != -1) {
    final bookName = refStr.substring(0, lastSpaceIdx);
    final refParts = refStr.substring(lastSpaceIdx + 1).split(':');
    final chapterNum =
        int.tryParse(refParts.isNotEmpty ? refParts[0] : '') ?? 1;
    final verseNum = refParts.length > 1 ? int.tryParse(refParts[1]) : null;
    return _ParsedRef(bookName, chapterNum, verseNum);
  }
  return _ParsedRef(refStr, 1, null);
}

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
  bool _hasFiredArmedHaptic = false;

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
      case AppThemeMode.priestlyPurple:
      case AppThemeMode.galileeBlue:
      case AppThemeMode.scarletRed:
      case AppThemeMode.dawn:
      case AppThemeMode.lilies:
      case AppThemeMode.roses:
      case AppThemeMode.olives:
      case AppThemeMode.fresh:
        subGreeting = "Embrace the light of His word.";
        break;
      case AppThemeMode.dark:
      case AppThemeMode.oled:
      case AppThemeMode.dusk:
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
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_isEditing) setState(() => _isEditing = false);
        },
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    if (notification.metrics.pixels < -80 &&
                        !_hasFiredArmedHaptic &&
                        notification.dragDetails != null) {
                      _hasFiredArmedHaptic = true;
                      HapticFeedback.mediumImpact();
                    } else if (notification.metrics.pixels >= -80 &&
                        _hasFiredArmedHaptic) {
                      _hasFiredArmedHaptic = false;
                    }
                  } else if (notification is ScrollEndNotification) {
                    if (notification.metrics.pixels < -80) {
                      ref.read(navProvider.notifier).setIndex(4);
                    }
                    _hasFiredArmedHaptic = false;
                  }
                  return false;
                },
                child: ReorderableListView.builder(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 32.0, bottom: 180.0),
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
                          final authState = ref.watch(authStateProvider);
                          final user = authState.value;
                          final isLit = streak.readToday;
                          final glowColor = isLit
                              ? AppColors.goldAccent
                              : Colors.grey.withValues(alpha: 0.5);

                          return Row(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(streak.count > 0
                                          ? '${streak.count} Day Streak! Keep it up!'
                                          : 'Read today to start your streak!'),
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
                                          isLit
                                              ? Icons
                                                  .local_fire_department_rounded
                                              : Icons
                                                  .local_fire_department_outlined,
                                          color: glowColor,
                                          shadows: isLit
                                              ? [
                                                  Shadow(
                                                    color: glowColor.withValues(
                                                        alpha: 0.6),
                                                    blurRadius: 10 +
                                                        (streak.count
                                                            .clamp(0, 10)
                                                            .toDouble()),
                                                  )
                                                ]
                                              : null,
                                          size: 24),
                                      const SizedBox(width: 4),
                                      Text('${streak.count}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isLit
                                                  ? theme.colorScheme.onSurface
                                                  : theme.colorScheme.onSurface
                                                      .withValues(alpha: 0.6))),
                                    ],
                                  ],
                                ),
                              ),
                              if (streak.count > 0 || isLit)
                                const SizedBox(width: 16),
                              const AccountButton(),
                            ],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 32),
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
                      cardWidget = ReadingPlanBanner(size: config.size);
                      break;
                    case 'commentary':
                      cardWidget = CommentaryBanner(size: config.size);
                      break;
                    default:
                      cardWidget = const SizedBox.shrink();
                  }

                  final card = KeyedSubtree(
                    key: ValueKey(config.id),
                    child: _KeepAliveWrapper(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
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
                                      color:
                                          Colors.black.withValues(alpha: 0.5),
                                      shape: const CircleBorder(),
                                      child: PopupMenuButton<CardSize>(
                                        icon: const Icon(
                                            Icons.more_horiz_rounded,
                                            color: Colors.white,
                                            size: 20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        color: theme.colorScheme.surface,
                                        onSelected: (newSize) {
                                          ref
                                              .read(
                                                  studyLayoutProvider.notifier)
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
                                                        fontWeight: config
                                                                    .size ==
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
                                                        fontWeight: config
                                                                    .size ==
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
                                                        fontWeight: config
                                                                    .size ==
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

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});
  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class ReadingPlanBanner extends ConsumerStatefulWidget {
  final CardSize size;
  const ReadingPlanBanner({super.key, required this.size});
  @override
  ConsumerState<ReadingPlanBanner> createState() => _ReadingPlanBannerState();
}

class _ReadingPlanBannerState extends ConsumerState<ReadingPlanBanner>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
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
        child: RepaintBoundary(
          child: TexturedGlassContainer(
            isScrollable: true,
            borderRadius: BorderRadius.circular(24),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    onTap: () {
                      final useNewHub = ref.read(plansHubStyleProvider);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => useNewHub ? const PlansHubV2Screen() : const ReadingPlansHubScreen()));
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
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: theme.primaryColor.withValues(alpha: 0.5)),
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
                          final useNewHub = ref.read(plansHubStyleProvider);
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (_) => useNewHub ? const PlansHubV2Screen() : const ReadingPlansHubScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.menu_book_rounded,
                                  size: 40,
                                  color: theme.primaryColor
                                      .withValues(alpha: 0.8)),
                              const SizedBox(height: 16),
                              Text('Start a reading plan',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor)),
                              const SizedBox(height: 4),
                              Text('Grow in the Word daily.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else ...[
                  ...activePlanIds.map((planId) {
                    return PlanRowWidget(planId: planId);
                  }),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommentaryBanner extends ConsumerWidget {
  final CardSize size;
  const CommentaryBanner({super.key, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeVerse = ref.watch(activeStudyVerseProvider);
    final commentaryAsync = ref.watch(commentaryProvider);

    String displayAuthor = 'Commentary';
    String displayReference = activeVerse != null
        ? '${_parseReference(activeVerse).book} ${_parseReference(activeVerse).chapter}'
        : 'Genesis 1';
    String displaySnippet = 'Explore commentary for this chapter.';

    if (activeVerse != null && commentaryAsync.value != null) {
      final entries = commentaryAsync.value!;
      final parsed = _parseReference(activeVerse);

      final matchingEntries = entries
          .where((e) =>
              e.scope.book?.toLowerCase() == parsed.book.toLowerCase() &&
              e.scope.chapter == parsed.chapter)
          .toList();

      if (matchingEntries.isNotEmpty) {
        final entry = matchingEntries.first;
        displayAuthor = entry.author;
        displaySnippet = '"${entry.text.split('. ').take(2).join('. ')}..."';
      } else {
        displaySnippet =
            'Explore commentary for ${parsed.book} ${parsed.chapter}.';
      }
    }

    final parsedRef = activeVerse != null
        ? _parseReference(activeVerse)
        : _ParsedRef('Genesis', 1, null);
    final hasChapterCommentary = ref.watch(
        commentaryForChapterProvider((parsedRef.book, parsedRef.chapter)));

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: RepaintBoundary(
        child: TexturedGlassContainer(
          isScrollable: true,
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
                  if (!hasChapterCommentary) {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) => const CommentaryLibraryScreen()));
                    return;
                  }
                  final refStr = activeVerse ?? 'Genesis 1';
                  String bookName = '';
                  int chapterNum = 1;
                  final lastSpaceIdx = refStr.lastIndexOf(' ');
                  if (lastSpaceIdx != -1) {
                    bookName = refStr.substring(0, lastSpaceIdx);
                    final refParts =
                        refStr.substring(lastSpaceIdx + 1).split(':');
                    if (refParts.isNotEmpty) {
                      chapterNum = int.tryParse(refParts[0]) ?? 1;
                    }
                  } else {
                    bookName = refStr;
                  }

                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => CommentaryHubScreen(
                            book: bookName,
                            chapter: chapterNum,
                            verse: null,
                          )));
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
                        maxLines: size == CardSize.small
                            ? 3
                            : (size == CardSize.medium ? 6 : 10),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (size == CardSize.large) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hasChapterCommentary
                                    ? 'Read Full Commentary'
                                    : 'Browse Available Commentary',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 16, color: theme.primaryColor),
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
      ),
    );
  }
}

