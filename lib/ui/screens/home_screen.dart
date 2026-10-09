import 'package:flutter/material.dart';
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
import '../../services/share_service.dart';
import '../../state/devotional_provider.dart';
import '../widgets/share_card.dart';

class StrictHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  Offset _totalDelta = Offset.zero;

  StrictHorizontalDragGestureRecognizer();

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _totalDelta = Offset.zero;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _totalDelta += event.delta;
      final dy = _totalDelta.dy.abs();
      final dx = _totalDelta.dx.abs();

      // Strict threshold: mostly horizontal (at least 45 deg angle)
      if (dy > 3 && dy >= dx * 1.2) {
        resolve(GestureDisposition.rejected);
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
    _verseController.forward();
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
    HapticFeedback.selectionClick();
    final plate =
        await ref.read(devotionalServiceProvider).plateForDay(DateTime.now());
    if (!mounted) return;
    await showShareOptionsSheet(
      context: context,
      copyText: ShareService.formatVerse(
        texts: [votd.text],
        reference: votd.reference,
        translationTag: 'KJV',
      ),
      shareText: ShareService.formatVerse(
        texts: [votd.text],
        reference: votd.reference,
        translationTag: 'KJV',
        whatsapp: true,
      ),
      imageFilename: 'votd',
      buildCard: (backdrop, style) => ShareCard.verse(
        reference: votd.reference,
        body: ShareService.cleanVerseText(votd.text),
        translationTag: 'KJV',
        backdrop: backdrop,
        style: style,
        artworkPath: plate?.assetPath,
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
                  if (_overscrollAccum >= _kOverscrollThreshold && !_hasFiredArmedHaptic) {
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
                  if (ref
                          .read(bibleNavSettingsProvider)
                          .homePullDownTarget ==
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
                    () => StrictHorizontalDragGestureRecognizer(),
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
                    await Future.delayed(const Duration(milliseconds: 500));
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
    String? excerpt = data.verseOfTheDay.commentarySnippet;

    // Parse VOTD reference for availability check
    final votdRef = data.verseOfTheDay.reference;
    final votdLastSpace = votdRef.lastIndexOf(' ');
    final votdBook = votdLastSpace != -1 ? votdRef.substring(0, votdLastSpace) : votdRef;
    final votdChapterStr = votdLastSpace != -1 ? votdRef.substring(votdLastSpace + 1).split(':').first : '1';
    final votdChapter = int.tryParse(votdChapterStr) ?? 1;
    final hasVotdCommentary = ref.watch(
        commentaryForChapterProvider((votdBook, votdChapter)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          // ── Header Row ────────────────────────────────────────────────
          SharedTopHeader(
            centerContent: Text(
              'Wednesday · July 22',
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final refParts = votdRef.split(':');
              final verseNum = refParts.length > 1 ? int.tryParse(refParts.last) : 1;
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
                    'VERSE OF THE DAY',
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
                    data.verseOfTheDay.reference,
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

          const SizedBox(height: 24),

          // ── Unified Reflection + Action Card ─────────────────────────
          BouncyEntrance(
            delay: const Duration(milliseconds: 400),
            child: GlassContainer(
              isScrollable: true,
              borderRadius: BorderRadius.circular(24),
              // Tighter vertical padding so the card fits without nav overlap
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Commentary / Devotional text excerpt (fallback to omitted if none exists)
                  if (excerpt != null) ...[
                    Row(
                      children: [
                        Icon(
                          data.verseOfTheDay.isDevotional
                              ? Icons.favorite_rounded
                              : Icons.library_books_rounded,
                          size: 13,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (data.verseOfTheDay.isDevotional
                                    ? 'DEVOTIONAL'
                                    : 'COMMENTARY') +
                                (data.verseOfTheDay.author != null
                                    ? ' · ${data.verseOfTheDay.author}'
                                    : (data.verseOfTheDay.sourceTitle != null
                                        ? ' · ${data.verseOfTheDay.sourceTitle}'
                                        : '')),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: theme.primaryColor,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      excerpt,
                      maxLines: 8,
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
                            label: 'Go Deeper',
                            filled: true,
                            onPressed: () {
                              final refStr = data.verseOfTheDay.reference;
                              final lastSpaceIdx = refStr.lastIndexOf(' ');
                              final bookName = lastSpaceIdx != -1
                                  ? refStr.substring(0, lastSpaceIdx)
                                  : refStr;
                              final refParts = lastSpaceIdx != -1
                                  ? refStr.substring(lastSpaceIdx + 1).split(':')
                                  : [];
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
                          label: 'Share',
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
      borderRadius: BorderRadius.circular(50),
    );

    if (filled) {
      return SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: shape,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: gold,
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? gold.withValues(alpha: 0.55)
                  : const Color(0xFF8C6300).withValues(
                      alpha: 0.8), // Deeper bronze for sharper contrast
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
          return const _WotdFallback(
            'No word picked for today yet — try again later.',
          );
        }
        
        return BouncyEntrance(
          delay: const Duration(milliseconds: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'WORD OF THE DAY',
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
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
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
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _PillButton(
                            label: 'Read Full Definition',
                            filled: true,
                            onPressed: () {
                              showModalBottomSheet(
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
                            label: 'Share',
                            filled: false,
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              showShareOptionsSheet(
                                context: context,
                                copyText: ShareService.formatWord(
                                  word: wotd.word,
                                  definition: wotd.snippet,
                                  sourceName: 'Word of the day',
                                ),
                                shareText: ShareService.formatWord(
                                  word: wotd.word,
                                  definition: wotd.snippet,
                                  sourceName: 'Word of the day',
                                ),
                                imageFilename: 'wotd',
                                buildCard: (backdrop, style) =>
                                    ShareCard.word(
                                  eyebrow: 'Word of the day',
                                  word: wotd.word,
                                  definition: wotd.snippet,
                                  source: 'Word of the day',
                                  backdrop: backdrop,
                                  style: style,
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
        debugPrint('wordOfTheDayProvider error: $e\n$st');
        return _WotdFallback('Word of the day unavailable ($e).');
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
          'WORD OF THE DAY',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.primaryColor,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          isScrollable: false,
          borderRadius: BorderRadius.circular(24),
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
