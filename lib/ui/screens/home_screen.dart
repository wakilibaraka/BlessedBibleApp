import 'dart:async';
import '../../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../utils/prose.dart';
import '../../data/localized_book_names.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/wotd_provider.dart';
import '../widgets/dictionary_entry_sheet.dart';

import '../../data/models/home_data.dart';
import '../../state/home_provider.dart';
import '../../state/votd_tracker_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/bible_nav_settings_provider.dart';
import '../../state/read_location_provider.dart';
import '../sheets/appearance_settings_sheet.dart';
import '../widgets/shared_top_header.dart';
import '../widgets/glass_container.dart';
import '../widgets/bouncy_entrance.dart';
import '../widgets/commentary_view.dart';
import '../../state/commentary_provider.dart';
import '../../models/share_content.dart';
import '../../state/devotional_provider.dart';
import '../widgets/share_sheet.dart';
import '../../utils/log.dart';
import 'package:intl/intl.dart';
import '../../data/models/devotional_story.dart';
import '../../state/story_of_the_day_provider.dart';
import 'bible_story_reader_screen.dart';

class StrictHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  Offset _totalDelta = Offset.zero;
  bool _rejected = false;

  StrictHorizontalDragGestureRecognizer();

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _totalDelta = Offset.zero;
    _rejected = false;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    // Once rejected, the drag recognizer is back in its ready state and
    // must not see more events for this pointer (it asserts otherwise).
    if (_rejected) return;
    if (event is PointerMoveEvent) {
      _totalDelta += event.delta;
      final dy = _totalDelta.dy.abs();
      final dx = _totalDelta.dx.abs();

      // Strict threshold: mostly horizontal (at least 45 deg angle)
      if (dy > 3 && dy >= dx * 1.2) {
        _rejected = true;
        resolve(GestureDisposition.rejected);
        stopTrackingPointer(event.pointer);
        return;
      }
    }
    super.handleEvent(event);
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  // Bounce/shimmer for the verse text
  late final AnimationController _verseController;
  late final Animation<double> _verseFade;

  // Pull-down-to-settings gesture state
  static const double _kOverscrollThreshold = 80.0;
  final ScrollController _scrollController = ScrollController();
  double _dragStartY = 0.0;
  bool _isDragging = false;
  double _overscrollAccum = 0.0;
  bool _hasFiredArmedHaptic = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(votdTrackerProvider.notifier).markViewed(DateTime.now());
    });

    // Verse fade-in on load
    _verseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _verseFade = CurvedAnimation(
      parent: _verseController,
      curve: Curves.easeOut,
    );
  }

  bool _verseStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Started here (not initState) so the reduced-motion flag is readable.
    if (_verseStarted) return;
    _verseStarted = true;
    _verseController
      ..duration = Motion.of(context, const Duration(milliseconds: 900))
      ..forward();
  }

  @override
  void dispose() {
    _verseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Verse-of-the-day share: text flavors plus an image card whose
  /// artwork option reuses today's bundled Doré plate.
  Future<void> _shareVotd(VerseOfTheDay votd) async {
    unawaited(HapticFeedback.selectionClick());
    final plate =
        await ref.read(devotionalServiceProvider).plateForDay(DateTime.now());
    if (!mounted) return;
    await showShareSheet(
      context: context,
      content: ShareContent.verse(
        reference: votd.reference,
        texts: [votd.text],
        translationTag: 'KJV',
        eyebrow: context.l10n.homeVerseOfTheDay,
        artworkPath: plate?.assetPath,
        imageFilename: 'verse-of-the-day',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final appThemeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Layer 2: Content ───────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Listener(
              onPointerDown: (e) {
                _dragStartY = e.position.dy;
                _isDragging = true;
              },
              onPointerMove: (e) {
                if (!_isDragging) return;
                bool isAtTop = true;
                if (_scrollController.hasClients) {
                  isAtTop = _scrollController.offset <= 16.0;
                }
                if (!isAtTop) return;
                final dy = e.position.dy - _dragStartY;
                if (dy < -10) {
                  _isDragging = false;
                  _overscrollAccum = 0.0;
                  if (mounted) setState(() {});
                  return;
                }
                if (dy > 0) {
                  _overscrollAccum = dy;
                  if (_overscrollAccum >= _kOverscrollThreshold &&
                      !_hasFiredArmedHaptic) {
                    _hasFiredArmedHaptic = true;
                    HapticFeedback.mediumImpact();
                  }
                  if (mounted) setState(() {});
                }
              },
              onPointerUp: (e) {
                _isDragging = false;
                if (_overscrollAccum >= _kOverscrollThreshold &&
                    ref.read(bibleNavSettingsProvider).homePullDownEnabled) {
                  HapticFeedback.mediumImpact();
                  if (ref.read(bibleNavSettingsProvider).homePullDownTarget ==
                      HomePullDownTarget.appearance) {
                    AppearanceSettingsSheet.show(context,
                        initialTab: AppearanceTab.typography);
                  } else {
                    ref.read(navProvider.notifier).setIndex(4); // Settings
                  }
                }
                _overscrollAccum = 0.0;
                _hasFiredArmedHaptic = false;
                if (mounted) setState(() {});
              },
              onPointerCancel: (e) {
                _isDragging = false;
                _overscrollAccum = 0.0;
                _hasFiredArmedHaptic = false;
                if (mounted) setState(() {});
              },
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: {
                  StrictHorizontalDragGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                          StrictHorizontalDragGestureRecognizer>(
                    StrictHorizontalDragGestureRecognizer.new,
                    (StrictHorizontalDragGestureRecognizer instance) {
                      instance
                        ..onUpdate = (details) {}
                        ..onEnd = (details) {
                          if (details.primaryVelocity == null) return;
                          // Swipe Left → go to Read tab (configurable)
                          if (details.primaryVelocity! < -300 &&
                              ref
                                  .read(bibleNavSettingsProvider)
                                  .homeSwipeLeftEnabled) {
                            HapticFeedback.selectionClick();
                            ref.read(navProvider.notifier).setIndex(1);
                          }
                        };
                    },
                  ),
                },
                child: RefreshIndicator.adaptive(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onRefresh: () async {
                    // CMS: fetch remote content here in future
                    await Future<void>.delayed(
                        const Duration(milliseconds: 500));
                    ref.invalidate(homeProvider);
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: FadeTransition(
                      opacity: _verseFade,
                      child: _buildPage(context, homeState, appThemeMode),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
      BuildContext context, HomeData data, AppThemeMode appThemeMode) {
    final theme = Theme.of(context);

    // Get dynamic commentary snippet for VOTD
    final String? excerpt = data.verseOfTheDay.commentarySnippet;

    // Parse VOTD reference for availability check
    final votdRef = data.verseOfTheDay.reference;
    final votdLastSpace = votdRef.lastIndexOf(' ');
    final votdBook =
        votdLastSpace != -1 ? votdRef.substring(0, votdLastSpace) : votdRef;
    final votdChapterStr = votdLastSpace != -1
        ? votdRef.substring(votdLastSpace + 1).split(':').first
        : '1';
    final votdChapter = int.tryParse(votdChapterStr) ?? 1;
    final hasVotdCommentary =
        ref.watch(commentaryForChapterProvider((votdBook, votdChapter)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          // ── Header Row ────────────────────────────────────────────────
          SharedTopHeader(
            centerContent: Text(
              _todayLabel(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // ── Spacer pushes verse downward to balance the layout ────────────
          const SizedBox(height: 56),

          // ── Verse of the Day ──────────────────────────────────────────
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final refParts = votdRef.split(':');
                final verseNum =
                    refParts.length > 1 ? int.tryParse(refParts.last) : 1;
                openReaderAtVerse(
                  ref,
                  bookName: votdBook,
                  chapter: votdChapter,
                  verse: verseNum,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BouncyEntrance(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      context.l10n.homeVerseOfTheDay,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.primaryColor,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BouncyEntrance(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      '\u201c${data.verseOfTheDay.text}\u201d',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  BouncyEntrance(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      context.referenceInLocale(data.verseOfTheDay.reference),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Unified Reflection + Action Card ─────────────────────────
          BouncyEntrance(
            delay: const Duration(milliseconds: 400),
            child: GlassContainer(
              isScrollable: true,
              borderRadius: BorderRadius.circular(Radii.xxl),
              // Tighter vertical padding so the card fits without nav overlap
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Commentary / Devotional text excerpt (clean view: content text only)
                  if (excerpt != null) ...[
                    Text(
                      excerpt,
                      maxLines: 12,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.60,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Primary action row: Go Deeper + Share + Bookmark
                  Row(
                    children: [
                      if (hasVotdCommentary)
                        Expanded(
                          flex: 3,
                          child: _PillButton(
                            label: context.l10n.homeGoDeeper,
                            filled: true,
                            onPressed: () {
                              final refStr = data.verseOfTheDay.reference;
                              final lastSpaceIdx = refStr.lastIndexOf(' ');
                              final bookName = lastSpaceIdx != -1
                                  ? refStr.substring(0, lastSpaceIdx)
                                  : refStr;
                              final refParts = lastSpaceIdx != -1
                                  ? refStr
                                      .substring(lastSpaceIdx + 1)
                                      .split(':')
                                  : <String>[];
                              final chapterNum = refParts.isNotEmpty
                                  ? (int.tryParse(refParts[0]) ?? 1)
                                  : 1;
                              final verseNum = refParts.length > 1
                                  ? int.tryParse(refParts[1])
                                  : null;

                              showCommentaryBottomSheet(
                                context,
                                book: bookName,
                                chapter: chapterNum,
                                verse: verseNum,
                                verseText: data.verseOfTheDay.text,
                              );
                            },
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _PillButton(
                          label: context.l10n.commonShare,
                          filled: false,
                          onPressed: () => _shareVotd(data.verseOfTheDay),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Word of the Day Section ──────────────
          const WordOfTheDaySection(),

          const SizedBox(height: 16),

          // ── Story of the Day Section ──────────────
          const StoryOfTheDaySection(),

          // Clearance above the floating nav bar
          const SizedBox(height: 140),
        ],
      ),
    );
  }
}

// ── Reusable pill-shaped button used inside the action cluster ──────────
class _PillButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onPressed;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.pill),
    );

    if (filled) {
      // Min (not fixed) 48 so the label is not clipped at large text.
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTouchTarget),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: context.palette.onAccent,
            elevation: 0,
            shape: shape,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
                color: context.palette.onAccent, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTouchTarget),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: gold,
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? gold.withValues(alpha: 0.55)
                  // Hand-tuned deeper bronze for outline contrast on light
                  // paper; kept literal on purpose.
                  : const Color(0xFF8C6300).withValues(alpha: 0.8),
            ),
            shape: shape,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: gold, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }
  }
}

class WordOfTheDaySection extends ConsumerWidget {
  const WordOfTheDaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wotdAsync = ref.watch(wordOfTheDayProvider);

    return wotdAsync.when(
      data: (wotd) {
        if (wotd == null) {
          return _WotdFallback(
            context.l10n.homeWotdEmpty,
          );
        }

        return BouncyEntrance(
          delay: const Duration(milliseconds: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.homeWordOfTheDayHeading,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.primaryColor,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                wotd.word,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.42,
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                isScrollable: false,
                borderRadius: BorderRadius.circular(Radii.xxl),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 14.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      wotd.snippet,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.60,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _PillButton(
                            label: context.l10n.homeReadFullDefinition,
                            filled: true,
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => DictionaryEntrySheet(
                                    normalizedWord: wotd.normalized),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PillButton(
                            label: context.l10n.commonShare,
                            filled: false,
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              showShareSheet(
                                context: context,
                                content: ShareContent.word(
                                  word: wotd.word,
                                  definition: wotd.snippet,
                                  sourceName: context.l10n.homeWordOfTheDay,
                                  eyebrow: context.l10n.homeWordOfTheDayHeading,
                                  imageFilename: 'word-of-the-day',
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) {
        logDebug('wordOfTheDayProvider error: $e\n$st');
        return _WotdFallback(context.l10n.homeWotdUnavailableNow);
      },
    );
  }
}

/// Quiet, visible fallback so a Word of the Day failure is never silent.
class _WotdFallback extends StatelessWidget {
  final String message;
  const _WotdFallback(this.message);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.homeWordOfTheDayHeading,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.primaryColor,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          isScrollable: false,
          borderRadius: BorderRadius.circular(Radii.xxl),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.60,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }
}

/// Today's date in the interface language, e.g. "Wednesday · July 22".
String _todayLabel(BuildContext context) {
  final now = DateTime.now();
  final locale = Localizations.localeOf(context).toString();
  try {
    return '${DateFormat.EEEE(locale).format(now)} · '
        '${DateFormat.MMMMd(locale).format(now)}';
  } catch (_) {
    return '${DateFormat.EEEE('en').format(now)} · '
        '${DateFormat.MMMMd('en').format(now)}';
  }
}

/// Daily Bible Story section with title, scripture reference, narrative summary snippet,
/// and [Read story] and [Share] action pills.
class StoryOfTheDaySection extends ConsumerWidget {
  final bool showArtwork;

  const StoryOfTheDaySection({super.key, this.showArtwork = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final storyAsync = ref.watch(storyOfTheDayProvider);

    return storyAsync.when(
      data: (story) {
        if (story == null) return const SizedBox.shrink();

        final snippet = normalizeProse(story.retelling.trim().isNotEmpty
            ? story.retelling
            : story.keyVerse);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.homeStoryOfTheDayHeading,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.primaryColor,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              story.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.referenceInLocale(story.ref),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              isScrollable: false,
              borderRadius: BorderRadius.circular(Radii.xxl),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showArtwork && story.plateSlug != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.lg),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          'assets/devotional/art/${story.plateSlug}.webp',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    snippet,
                    maxLines: 7,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.60,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _PillButton(
                          label: context.l10n.homeReadStory,
                          filled: true,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    BibleStoryReaderScreen(initialStory: story),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PillButton(
                          label: context.l10n.commonShare,
                          filled: false,
                          onPressed: () => _shareStory(context, story),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) {
        logDebug('storyOfTheDayProvider error: $e\n$st');
        return const SizedBox.shrink();
      },
    );
  }

  void _shareStory(BuildContext context, DevotionalStory story) {
    HapticFeedback.selectionClick();
    final summary = story.retelling.trim().isNotEmpty
        ? story.retelling.trim()
        : story.keyVerse.trim();
    showShareSheet(
      context: context,
      content: ShareContent.story(
        title: story.title,
        body: summary,
        reference: story.ref,
        eyebrow: context.l10n.homeStoryOfTheDay,
        keyVerse: story.keyVerse,
        keyVerseRef: story.keyVerseRef,
        artworkPath: story.plateSlug != null
            ? 'assets/devotional/art/${story.plateSlug}.webp'
            : null,
        imageFilename: 'story-of-the-day',
      ),
    );
  }
}
