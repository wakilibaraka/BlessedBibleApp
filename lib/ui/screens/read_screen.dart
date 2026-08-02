import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../theme/app_colors.dart';
import '../widgets/pinch_to_zoom_font_wrapper.dart';
import '../widgets/pill_segmented_control.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data/models/bible_model.dart';
import '../../state/bible_provider.dart';

import '../../state/read_settings_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/streak_provider.dart';
import '../../state/most_read_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../../data/models/translation_model.dart';
import '../../state/hints_provider.dart';
import '../../utils/bible_sections.dart';
import '../../services/share_service.dart';
import 'notes_list_screen.dart';

import '../../state/notes_provider.dart';
import '../sheets/translation_picker_sheet.dart';

import '../widgets/day_complete_celebration.dart';
import '../../state/theme_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/chapter_titles_provider.dart';
import '../../state/immersive_mode_provider.dart';
import '../../state/read_selection_provider.dart';
import '../../state/commentary_provider.dart';
import '../../state/bible_nav_settings_provider.dart';
import '../../state/read_location_provider.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/bouncy_entrance.dart';
import '../../state/nav_settings_provider.dart';
import '../../state/translation_provider.dart';
import '../../theme/reading_tokens.dart';
import '../widgets/commentary_view.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LazyPageScrollPhysics extends PageScrollPhysics {
  final GestureSensitivity sensitivity;

  const LazyPageScrollPhysics({
    super.parent,
    this.sensitivity = GestureSensitivity.fluid,
  });

  @override
  LazyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return LazyPageScrollPhysics(
      parent: buildParent(ancestor),
      sensitivity: sensitivity,
    );
  }

  double _getCustomPage(ScrollMetrics position) {
    return position.pixels / position.viewportDimension;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return page * position.viewportDimension;
  }

  double _getCustomTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getCustomPage(position);
    
    // Very relaxed swipe thresholds for a "lazy" feel.
    // Flick threshold: 50 px/s (very light flick)
    if (velocity < -50.0) {
      page -= 0.5;
    } else if (velocity > 50.0) {
      page += 0.5;
    } else {
      // Distance threshold: only need to drag 15% of the screen to snap to the next page.
      double fraction = page - page.roundToDouble();
      if (fraction > 0.15) {
        page = page.roundToDouble() + 1.0;
      } else if (fraction < -0.15) {
        page = page.roundToDouble() - 1.0;
      }
    }
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if (sensitivity == GestureSensitivity.fluid) {
      return super.createBallisticSimulation(position, velocity);
    }

    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getCustomTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return SpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
    }
    return null;
  }

  @override
  SpringDescription get spring {
    if (sensitivity == GestureSensitivity.fluid) {
      return super.spring;
    }
    return SpringDescription.withDampingRatio(
      mass: 0.25,
      stiffness: 280.0,
      ratio: 0.95,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}

class ExpandedChipsNotifier extends Notifier<Map<int, String?>> {
  @override
  Map<int, String?> build() => {};

  void toggle(int verseNumber) {
    if (state.containsKey(verseNumber)) {
      state = {...state}..remove(verseNumber);
    } else {
      state = {...state, verseNumber: null};
    }
  }

  void setLanguage(int verseNumber, String languageId) {
    state = {...state, verseNumber: languageId};
  }

  void clear(int verseNumber) {
    if (state.containsKey(verseNumber)) {
      state = {...state}..remove(verseNumber);
    }
  }
}

final expandedChipsProvider = NotifierProvider<ExpandedChipsNotifier, Map<int, String?>>(ExpandedChipsNotifier.new);

String _getTranslationGlyph(String languageName) {
  switch (languageName.toLowerCase()) {
    case 'english': return '英';
    case 'french': return '法';
    case 'chinese': return '中';
    case 'korean': return '韓';
    case 'russian': return '俄';
    case 'german': return '德';
    case 'spanish': return '西';
    case 'japanese': return '日';
    case 'arabic': return '阿';
    case 'hindi': return '印';
    case 'italian': return '意';
    case 'portuguese': return '葡';
    case 'dutch': return '荷';
    case 'ukrainian': return '烏';
    case 'polish': return '波';
    case 'swahili': return '斯';
    case 'tagalog': return '塔';
    default: return languageName.isNotEmpty ? languageName[0].toUpperCase() : 'A';
  }
}

String _getLanguageAbbr(String languageName) {
  switch (languageName.toLowerCase()) {
    case 'english': return 'EN';
    case 'swahili': return 'SW';
    case 'french': return 'FR';
    case 'italian': return 'IT';
    case 'spanish': return 'ES';
    case 'tagalog': return 'TL';
    case 'arabic': return 'AR';
    case 'chinese': return 'ZH';
    case 'hindi': return 'HI';
    case 'korean': return 'KO';
    case 'russian': return 'RU';
    case 'german': return 'DE';
    case 'japanese': return 'JA';
    case 'portuguese': return 'PT';
    case 'dutch': return 'NL';
    case 'romanian': return 'RO';
    case 'ukrainian': return 'UK';
    case 'polish': return 'PL';
    case 'indonesian': return 'ID';
    default: return languageName.length >= 2 ? languageName.substring(0, 2).toUpperCase() : languageName.toUpperCase();
  }
}

String _getTranslationLabel(String translationId, List<TranslationInfo> allInstalled, {String? defaultName}) {
  try {
    final info = allInstalled.firstWhere((t) => t.translationId == translationId);
    final sameLanguageVersions = allInstalled.where((t) => t.languageName == info.languageName).toList();
    if (sameLanguageVersions.length > 1) {
      return info.abbreviation.toUpperCase();
    }
    return _getLanguageAbbr(info.languageName);
  } catch (_) {
    if (defaultName != null) return _getLanguageAbbr(defaultName);
    return translationId.toUpperCase();
  }
}

String _getTranslationCombinedLabel(String translationId, List<TranslationInfo> allInstalled, {String? defaultName}) {
  try {
    final info = allInstalled.firstWhere((t) => t.translationId == translationId);
    final label = _getTranslationLabel(translationId, allInstalled);
    return '${_getTranslationGlyph(info.languageName)} $label';
  } catch (_) {
    final name = defaultName ?? translationId;
    return '${_getTranslationGlyph(name)} ${_getTranslationLabel(translationId, allInstalled, defaultName: defaultName)}';
  }
}

String _toHeadingCase(String text) {
  if (text.isEmpty) return text;
  final minorWords = {
    'a',
    'an',
    'the',
    'and',
    'but',
    'or',
    'for',
    'nor',
    'on',
    'at',
    'to',
    'from',
    'by',
    'in',
    'of',
    'with'
  };
  final words = text.toLowerCase().split(' ');
  for (int i = 0; i < words.length; i++) {
    if (words[i].isEmpty) continue;
    if (i == 0 || i == words.length - 1 || !minorWords.contains(words[i])) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1);
    }
  }
  return words.join(' ');
}

class ReadScreen extends ConsumerStatefulWidget {
  const ReadScreen({super.key});

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  bool _hasInitialJumped = false;
  int _currentPageIndex = 0;
  final Map<int, ItemScrollController> _itemScrollControllers = {};
  final Map<int, ItemPositionsListener> _itemPositionsListeners = {};
  int? _navigatedVerseIndex;
  Timer? _scrollDebounceTimer;
  Timer? _visitTimer;
  Timer? _scrollEndTimer;
  Timer? _navRevealTimer;
  Timer? _headerRevealTimer;
  Timer? _pageDebounceTimer;
  bool _delayHeaderReveal = false;
  final ValueNotifier<bool> _isScrolling = ValueNotifier(false);

  // ── Hints ────────────────────────────────────────────────────────
  String? _currentHintId;
  String? _currentHintMessage;
  Timer? _hintTimer;

  void _showHint(String id, String message) {
    if (mounted && _currentHintId == null) {
      setState(() {
        _currentHintId = id;
        _currentHintMessage = message;
      });
      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(seconds: 8), _dismissHint);
    }
  }

  void _dismissHint() {
    if (mounted && _currentHintId != null) {
      ref.read(hintsProvider.notifier).markSeen(_currentHintId!);
      setState(() {
        _currentHintId = null;
        _currentHintMessage = null;
      });
    }
  }

  void _tryShowHint(String id, String message) {
    if (ref.read(preferencesProvider).showReadingTips) {
      ref.read(hintsProvider.notifier).maybeShowHint(id, () {
        Future.microtask(() => _showHint(id, message));
      });
    }
  }
  // ────────────────────────────────────────────────────────────────

  // ── Deliberate-drag-to-nav gate ──────────────────────────────────
  // A fast flick must NOT open navigation. Only a slow, sustained pull
  // past a distance threshold that has been held for a minimum duration
  // qualifies as an intentional gesture.
  //
  // Thresholds (tuned for feel):
  //   Distance  : 60 logical pixels of overscroll accumulated
  //   Hold time : 700 ms — the drag must be held for at least this long
  //   Max vel   : 250 px/s  — any faster is a flick, not a deliberate drag
  static const double _kOverscrollDistanceThreshold = 60.0;
  static const int _kHoldMillis = 700;

  double _overscrollAccum = 0.0; // total negative overscroll pixels seen
  Timer? _continuousScrollTimerStage1;
  Timer? _continuousScrollTimerStage2;
  bool _isScrollingDown = false;
  DateTime? _overscrollStart; // when the drag crossed the first threshold
  bool _navTriggeredThisDrag = false;
  bool _hasFiredArmedHaptic = false;

  /// Called from the indicator widget to provide the current pull fraction
  /// (0.0 → 1.0, capped) so a subtle indicator can be drawn.
  double get _overscrollFraction =>
      (_overscrollAccum / _kOverscrollDistanceThreshold).clamp(0.0, 1.0);

  void _resetOverscrollGate() {
    _overscrollAccum = 0.0;
    _overscrollStart = null;
    _navTriggeredThisDrag = false;
    _hasFiredArmedHaptic = false;
    if (mounted) setState(() {});
  }
  // ────────────────────────────────────────────────────────────────

  int? _contextMenuVerse;
  dynamic _contextMenuChapterData;
  String? _contextMenuBookName;
  int? _contextMenuChapterNum;

  void _dismissContextMenu() {
    if (_contextMenuVerse != null && mounted) {
      setState(() {
        _contextMenuVerse = null;
        _contextMenuChapterData = null;
        _contextMenuBookName = null;
        _contextMenuChapterNum = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(streakProvider.notifier).markReadToday();

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          final prefs = ref.read(preferencesProvider);
          if (!prefs.showReadingTips) return;

          final hints = ref.read(hintsProvider);
          if (!hints.contains('seen_highlight_hint')) {
            _tryShowHint('seen_highlight_hint',
                'Long-press a verse to highlight or take notes');
          } else if (!hints.contains('seen_commentary_hint')) {
            _tryShowHint('seen_commentary_hint',
                'Tap the bulb icon next to a verse for commentary');
          }
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release wakelock when app goes to background, re-enable on resume
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      WakelockPlus.disable();
    } else if (state == AppLifecycleState.resumed) {
      final readSettings = ref.read(readSettingsProvider);
      if (readSettings.keepScreenAwake) WakelockPlus.enable();
    }
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    _visitTimer?.cancel();
    _scrollEndTimer?.cancel();
    _navRevealTimer?.cancel();
    _headerRevealTimer?.cancel();
    _pageDebounceTimer?.cancel();
    _isScrolling.dispose();
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable(); // Release wakelock
    super.dispose();
  }

  void _toggleVerseSelection(int index) {
    setState(() {
      _navigatedVerseIndex = null;
    });
    ref.read(readSelectionProvider.notifier).toggle(index);
  }

  void _clearSelection() {
    setState(() {
      _navigatedVerseIndex = null;
    });
    ref.read(readSelectionProvider.notifier).clear();
  }

  void _scrollToVerse(int verse, ReadLocationState loc) {
    void tryScroll(int retries) {
      if (!mounted) return;
      final flatChapters = ref.read(flatChaptersProvider);
      if (flatChapters.isEmpty) return;

      final targetIndex = flatChapters.indexWhere((fc) =>
          (fc.book.abbreviation.toLowerCase() == loc.bookAbbrev.toLowerCase() ||
              fc.book.name.toLowerCase() == loc.bookName.toLowerCase()) &&
          fc.chapter.number == loc.chapter);
      if (targetIndex != -1) {
        final controller = _itemScrollControllers[targetIndex];
        final listener = _itemPositionsListeners[targetIndex];

        if (controller != null && controller.isAttached) {
          final versesCount = flatChapters[targetIndex].chapter.verses.length;

          controller.scrollTo(
            index: verse - 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: 0.15, // Account for top header
          );

          if (listener != null) {
            bool adjusted = false;
            void checkOverscroll() {
              if (adjusted || !mounted) return;

              final positions = listener.itemPositions.value;
              // Footer is at index == versesCount
              final footerPos =
                  positions.where((p) => p.index == versesCount).firstOrNull;

              if (footerPos != null && footerPos.itemTrailingEdge < 1.0) {
                adjusted = true;
                controller.scrollTo(
                  index: versesCount,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  alignment: 1.0,
                );
              }
            }

            listener.itemPositions.addListener(checkOverscroll);

            // Clean up the listener after the initial animation is done
            Future.delayed(const Duration(milliseconds: 650), () {
              if (mounted) {
                listener.itemPositions.removeListener(checkOverscroll);
              }
            });
          }

          // Highlight it faintly upon jumping
          if (mounted) {
            setState(() {
              _navigatedVerseIndex = verse - 1;
            });
            // Clear navigated verse after a short delay so the highlight fades out
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _navigatedVerseIndex = null;
                });
              }
            });
          }
        } else if (retries < 20) {
          Future.delayed(
              const Duration(milliseconds: 50), () => tryScroll(retries + 1));
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tryScroll(0);
    });
  }

  void _showTypographyBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const _TypographyBottomSheet(),
    );
  }

  void _showSelectorBottomSheet(List<BibleBook> allBooks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: false,
      builder: (context) {
        final loc = ref.read(readLocationProvider);
        return _BookChapterSelectorSheet(
          books: allBooks,
          selectedBookAbbrev: loc.bookAbbrev,
          selectedChapter: loc.chapter,
          onSelectionChanged: (abbrev, name, chapter, verse,
              {bool autoClose = true}) {
            bool changedChapter =
                loc.bookAbbrev != abbrev || loc.chapter != chapter;
            ref.read(readLocationProvider.notifier).updateLocation(
                  bookAbbrev: abbrev,
                  bookName: name,
                  chapter: chapter,
                );
            ref.read(activePlanContextProvider.notifier).setContext(null);
            if (changedChapter) {
              // Chapter changed, list will rebuild automatically
            }
            _clearSelection();
            if (autoClose) {
              Navigator.pop(context);
            }

            if (verse != null) {
              _scrollToVerse(verse, ref.read(readLocationProvider));
            }
          },
        );
      },
    );
  }

  Widget _buildThemedPill(
      {required Widget child,
      required ReadingTokens tokens,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: const SizedBox.shrink(),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: tokens.readingPaper.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: tokens.readingBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideButton(BuildContext context, ReadingTokens tokens,
      Widget child, VoidCallback onTap, bool isImmersiveMode) {
    _itemPositionsListeners[_currentPageIndex] ??=
        ItemPositionsListener.create();
    final listenable =
        _itemPositionsListeners[_currentPageIndex]!.itemPositions;

    return ValueListenableBuilder<bool>(
      valueListenable: _isScrolling,
      builder: (context, isScrolling, _) {
        return ValueListenableBuilder<Iterable<ItemPosition>>(
          valueListenable: listenable,
          builder: (context, positions, _) {
            bool isAtTop = false;
            if (positions.isNotEmpty) {
              final firstPos = positions.where((p) => p.index == 0);
              if (firstPos.isNotEmpty &&
                  firstPos.first.itemLeadingEdge >= -0.05) {
                isAtTop = true;
              }
            }

            final isAtTopRest = isAtTop && !isScrolling;
            final shouldHide =
                (isImmersiveMode || _delayHeaderReveal) && !isAtTopRest;

            return IgnorePointer(
              ignoring: shouldHide,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                offset: shouldHide ? const Offset(0, -1) : Offset.zero,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  opacity: shouldHide ? 0.01 : 1.0,
                  alwaysIncludeSemantics: true,
                  child: _buildThemedPill(
                    child: child,
                    tokens: tokens,
                    onTap: onTap,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopRow(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      String currentBookName,
      int currentChapter,
      List<BibleBook> allBooks,
      bool isImmersiveMode) {
    final tokens = theme.extension<ReadingTokens>()!;

    final centerPill = _buildThemedPill(
      tokens: tokens,
      onTap: () => _showSelectorBottomSheet(allBooks),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  '$currentBookName $currentChapter',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.readingInk,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: tokens.readingInk.withValues(alpha: 0.7),
          ),
        ],
      ),
    );

    final leadingButton = Consumer(builder: (context, ref, _) {
      final activeTransId = ref.watch(activeTranslationProvider);
      final installed = ref.watch(availableTranslationsProvider).value ?? [];
      final activeTransLabel = _getTranslationLabel(activeTransId, installed);
      
      return _buildSideButton(
          context,
          tokens,
          Text(
            activeTransLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.readingInk,
            ),
          ), () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => const TranslationPickerSheet(),
        );
      }, isImmersiveMode);
    });

    final trailingButton = _buildSideButton(
        context,
        tokens,
        Text(
          'Aa',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: tokens.readingInk,
            letterSpacing: -0.5,
          ),
        ),
        _showTypographyBottomSheet,
        isImmersiveMode);

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: leadingButton,
          ),
          Align(
            alignment: Alignment.center,
            child: centerPill,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: trailingButton,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final typography = ref.watch(typographyProvider);
    final chapterTitles = ref.watch(chapterTitlesProvider);
    final readSettings = ref.watch(readSettingsProvider);
    final selectedVerses = ref.watch(readSelectionProvider);
    final isImmersive = ref.watch(immersiveModeProvider);

    final commentaryState = ref.watch(commentaryProvider);
    final Set<String> versesWithCommentary = {};
    final Set<String> chaptersWithCommentary = {};
    if (commentaryState.value != null) {
      for (final entry in commentaryState.value!) {
        final b = entry.scope.book;
        final c = entry.scope.chapter;
        final v = entry.scope.verse;
        if (b != null && c != null) {
          if (entry.scope.type == 'chapter') {
            chaptersWithCommentary.add('$b|$c');
          }
          if (entry.scope.type == 'verse' && v != null) {
            versesWithCommentary.add('$b|$c|$v');
          }
        }
      }
    }

    final bibleState = ref.watch(bibleProvider);
    final isLoading = bibleState.isLoading;
    final allBooks = bibleState.books;

    final flatChapters = ref.watch(flatChaptersProvider);
    final loc = ref.watch(readLocationProvider);
    final bibleNavSettings = ref.watch(bibleNavSettingsProvider);

    if (flatChapters.isNotEmpty) {
      final targetIndex = flatChapters.indexWhere((fc) =>
          (fc.book.abbreviation.toLowerCase() == loc.bookAbbrev.toLowerCase() ||
              fc.book.name.toLowerCase() == loc.bookName.toLowerCase()) &&
          fc.chapter.number == loc.chapter);
      final safeTarget = targetIndex != -1 ? targetIndex : 0;
      if (!_hasInitialJumped) {
        _hasInitialJumped = true;
        _currentPageIndex = safeTarget;
        if (!_pageController.hasClients) {
          _pageController.dispose();
          _pageController = PageController(initialPage: safeTarget);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _pageController.hasClients) {
              _pageController.jumpToPage(safeTarget);
            }
          });
        }
      }
    }

    ref.listen<ReadLocationState>(readLocationProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (flatChapters.isNotEmpty && _hasInitialJumped) {
          final targetIndex = flatChapters.indexWhere((fc) =>
              (fc.book.abbreviation.toLowerCase() ==
                      next.bookAbbrev.toLowerCase() ||
                  fc.book.name.toLowerCase() == next.bookName.toLowerCase()) &&
              fc.chapter.number == next.chapter);
          if (targetIndex != -1 && _pageController.hasClients) {
            final currentPage = _pageController.page?.round() ?? 0;
            if (currentPage != targetIndex) {
              if ((currentPage - targetIndex).abs() == 1) {
                _pageController.animateToPage(targetIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              } else {
                _pageController.jumpToPage(targetIndex);
              }
            }
          }
        }

        if (next.requestedVerse != null) {
          _scrollToVerse(next.requestedVerse!, next);
          ref.read(readLocationProvider.notifier).clearRequestedVerse();
        }
        if (next.openCommentary && next.requestedVerse != null) {
          if (!isLoading && allBooks.isNotEmpty) {
            try {
              int bookIdx =
                  allBooks.indexWhere((b) => b.abbreviation == next.bookAbbrev);
              if (bookIdx == -1) bookIdx = 0;
              final book = allBooks[bookIdx];

              if (book.chapters.isEmpty) return;
              int chapIdx =
                  book.chapters.indexWhere((c) => c.number == next.chapter);
              if (chapIdx == -1) chapIdx = 0;
              final chapter = book.chapters[chapIdx];
              if (next.requestedVerse! <= chapter.verses.length) {
                final verseText = chapter.verses[next.requestedVerse! - 1].text;
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _showCommentaryBottomSheet(next.requestedVerse!, verseText);
                  }
                });
              }
            } catch (_) {}
          }
          ref.read(readLocationProvider.notifier).clearCommentary();
        }
      });
    });

    String currentBookName = loc.bookName;
    int currentChapter = loc.chapter;

    if (flatChapters.isNotEmpty &&
        _currentPageIndex >= 0 &&
        _currentPageIndex < flatChapters.length) {
      final fc = flatChapters[_currentPageIndex];
      currentBookName = fc.book.name;
      currentChapter = fc.chapter.number;
    }

    final tokens = theme.extension<ReadingTokens>()!;
    Color getThemeBackgroundColor() {
      switch (appThemeMode) {
        case AppThemeMode.dawn:
          return AppColors.dawnBackground;
        case AppThemeMode.lilies:
          return AppColors.liliesBackground;
        case AppThemeMode.roses:
          return AppColors.rosesBackground;
        case AppThemeMode.olives:
          return AppColors.olivesBackground;
        case AppThemeMode.dusk:
          return const Color(0xFF312C51);
        case AppThemeMode.fresh:
          return const Color(0xFF132C33);
        default:
          return tokens.readingPaper;
      }
    }

    return Scaffold(
      backgroundColor: getThemeBackgroundColor(),
      body: PinchToZoomFontWrapper(
        child: Stack(
          children: [
            // ── Scripture Content Layer ──────────────────────────────────
            Positioned.fill(
              child: Stack(
                children: [
                  // Scripture View
                  Positioned.fill(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: theme.primaryColor,
                            ),
                          )
                        : flatChapters.isEmpty
                            ? Center(
                                child: Text('Passage not found.',
                                    style: theme.textTheme.bodyLarge),
                              )
                            : PageView.builder(
                                physics: LazyPageScrollPhysics(
                                  sensitivity: ref.watch(readSettingsProvider.select((s) => s.gestureSensitivity)),
                                ),
                                controller: _pageController,
                                itemCount: flatChapters.length,
                                onPageChanged: (pageIndex) {
                                  debugPrint(
                                      'STEP0: onPageChanged gesture started for page $pageIndex');
                                  setState(() {
                                    _currentPageIndex = pageIndex;
                                  });

                                  _pageDebounceTimer?.cancel();
                                  _pageDebounceTimer = Timer(
                                      const Duration(milliseconds: 300), () {
                                    if (!mounted) return;
                                    final fc = flatChapters[pageIndex];
                                    final currentLoc =
                                        ref.read(readLocationProvider);
                                    if ((currentLoc.bookAbbrev.toLowerCase() !=
                                                fc.book.abbreviation
                                                    .toLowerCase() &&
                                            currentLoc.bookName.toLowerCase() !=
                                                fc.book.name.toLowerCase()) ||
                                        currentLoc.chapter !=
                                            fc.chapter.number) {
                                      ref
                                          .read(readLocationProvider.notifier)
                                          .updateLocation(
                                            bookAbbrev: fc.book.abbreviation,
                                            bookName: fc.book.name,
                                            chapter: fc.chapter.number,
                                          );
                                    }
                                  });
                                  _clearSelection();
                                },
                                itemBuilder: (context, pageIndex) {
                                  final buildStartMs =
                                      DateTime.now().millisecondsSinceEpoch;
                                  final fc = flatChapters[pageIndex];

                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    final paintMs =
                                        DateTime.now().millisecondsSinceEpoch -
                                            buildStartMs;
                                    debugPrint(
                                        'STEP0: Chapter ${fc.book.abbreviation} ${fc.chapter.number} painted in $paintMs ms');
                                  });
                                  _itemScrollControllers[pageIndex] ??=
                                      ItemScrollController();
                                  if (!_itemPositionsListeners
                                      .containsKey(pageIndex)) {
                                    final listener =
                                        ItemPositionsListener.create();
                                    _itemPositionsListeners[pageIndex] =
                                        listener;
                                    listener.itemPositions.addListener(() {
                                      final positions =
                                          listener.itemPositions.value;
                                      if (positions.isNotEmpty) {
                                        final activeTrans =
                                            ref.read(activeTranslationProvider);
                                        final bookNum =
                                            allBooks.indexOf(fc.book) + 1;
                                        final currentVersesAsync = ref
                                            .read(translationChapterProvider((
                                          translationId: activeTrans,
                                          bookNumber: bookNum,
                                          chapterNumber: fc.chapter.number,
                                        )));
                                        final currentVerses =
                                            currentVersesAsync.value ??
                                                fc.chapter.verses;

                                        final firstVisible = positions
                                            .where(
                                                (p) => p.itemTrailingEdge > 0)
                                            .reduce((min, p) =>
                                                p.itemLeadingEdge <
                                                        min.itemLeadingEdge
                                                    ? p
                                                    : min);
                                        if (firstVisible.index <
                                            currentVerses.length) {
                                          _scrollDebounceTimer?.cancel();
                                          _visitTimer?.cancel();
                                          _scrollDebounceTimer = Timer(
                                              const Duration(milliseconds: 500),
                                              () {
                                            if (!mounted) return;
                                            final currentBookName =
                                                fc.book.name;
                                            final currentChapter =
                                                fc.chapter.number;
                                            final currentAbbrev =
                                                fc.book.abbreviation;
                                            final prefs =
                                                ref.read(preferencesProvider);
                                            prefs.saveLastReadLocation(
                                              bookAbbrev: currentAbbrev,
                                              bookName: currentBookName,
                                              chapter: currentChapter,
                                              verseIndex: firstVisible.index,
                                            );
                                            prefs.saveChapterScrollPosition(
                                              currentAbbrev,
                                              currentChapter,
                                              firstVisible.index,
                                            );
                                          });
                                          _visitTimer = Timer(
                                              const Duration(seconds: 4), () {
                                            if (!mounted) return;
                                            ref
                                                .read(mostReadProvider.notifier)
                                                .incrementVisit(
                                                  fc.book.abbreviation,
                                                  fc.book.name,
                                                  fc.chapter.number,
                                                  currentVerses[
                                                          firstVisible.index]
                                                      .number,
                                                );
                                          });
                                        }
                                      }
                                    });
                                  }

                                  return Consumer(
                                    builder: (context, ref, child) {
                                      final activeTrans =
                                          ref.watch(activeTranslationProvider);
                                      final secondaryTrans =
                                          ref.watch(secondaryTranslationProvider);
                                      final readingLayout =
                                          ref.watch(readSettingsProvider).readingLayout;
                                      final bookNum =
                                          allBooks.indexOf(fc.book) + 1;
                                      final chapterData =
                                          ref.watch(translationChapterProvider((
                                        translationId: activeTrans,
                                        bookNumber: bookNum,
                                        chapterNumber: fc.chapter.number,
                                      )));
                                      
                                      List<BibleVerse>? secondaryVerses;
                                      if (secondaryTrans != null && readingLayout != ReadingLayout.single) {
                                        final secondaryChapterData =
                                            ref.watch(translationChapterProvider((
                                          translationId: secondaryTrans,
                                          bookNumber: bookNum,
                                          chapterNumber: fc.chapter.number,
                                        )));
                                        secondaryVerses = secondaryChapterData.value;
                                      }
                                      
                                      final verses = chapterData.value ??
                                          fc.chapter.verses;
                                          
                                      final secondaryVerseMap = <int, BibleVerse>{};
                                      if (secondaryVerses != null) {
                                        for (final v in secondaryVerses) {
                                          secondaryVerseMap[v.number] = v;
                                        }
                                      }

                                      return RepaintBoundary(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (selectedVerses.isNotEmpty) {
                                              _clearSelection();
                                            }
                                          },
                                          behavior: HitTestBehavior.translucent,
                                          child: NotificationListener<
                                              ScrollNotification>(
                                            onNotification: (notification) {
                                              if (notification
                                                      is ScrollStartNotification ||
                                                  notification
                                                      is ScrollUpdateNotification) {
                                                if (!_isScrolling.value) {
                                                  _isScrolling.value = true;
                                                }
                                                _scrollEndTimer?.cancel();
                                              } else if (notification
                                                  is ScrollEndNotification) {
                                                _scrollEndTimer?.cancel();
                                                _scrollEndTimer = Timer(
                                                    const Duration(
                                                        milliseconds: 150), () {
                                                  if (mounted) {
                                                    _isScrolling.value = false;
                                                  }
                                                });
                                              }

                                              final navSettings =
                                                  ref.read(navSettingsProvider);

                                              // ── Deliberate-drag gate for navigation ──
                                              if (bibleNavSettings
                                                  .swipeDownToNav) {
                                                if (notification
                                                        is OverscrollNotification &&
                                                    notification.overscroll <
                                                        0) {
                                                  // Reject inertial overscrolls (flicks) — dragDetails is null
                                                  // when the user's finger is no longer on the screen.
                                                  if (notification
                                                          .dragDetails ==
                                                      null) {
                                                    _resetOverscrollGate();
                                                    return false;
                                                  }

                                                  // Elastic resistance (rubber-banding)
                                                  final delta =
                                                      -notification.overscroll;
                                                  final resistance = (1.0 -
                                                      (_overscrollAccum /
                                                              (_kOverscrollDistanceThreshold *
                                                                  2.5))
                                                          .clamp(0.0, 0.8));

                                                  if (_overscrollAccum == 0.0 &&
                                                      delta > 4.0) {
                                                    _overscrollStart =
                                                        DateTime.now();
                                                  }

                                                  _overscrollAccum +=
                                                      delta * resistance;

                                                  if (_overscrollAccum >=
                                                          _kOverscrollDistanceThreshold &&
                                                      !_hasFiredArmedHaptic) {
                                                    _hasFiredArmedHaptic = true;
                                                    HapticFeedback
                                                        .mediumImpact();
                                                  }

                                                  if (mounted) setState(() {});

                                                  // Check if both thresholds are satisfied
                                                  if (!_navTriggeredThisDrag &&
                                                      _overscrollAccum >=
                                                          _kOverscrollDistanceThreshold &&
                                                      _overscrollStart !=
                                                          null &&
                                                      DateTime.now().difference(
                                                              _overscrollStart!) >=
                                                          Duration(
                                                              milliseconds:
                                                                  _kHoldMillis) &&
                                                      ModalRoute.of(context)
                                                              ?.isCurrent ==
                                                          true) {
                                                    _navTriggeredThisDrag =
                                                        true;
                                                    _resetOverscrollGate();
                                                    _showSelectorBottomSheet(
                                                        allBooks);
                                                  }
                                                } else if (notification
                                                    is ScrollEndNotification) {
                                                  // Drag released
                                                  if (_overscrollAccum > 0) {
                                                    if (_overscrollAccum >=
                                                            _kOverscrollDistanceThreshold &&
                                                        !_navTriggeredThisDrag &&
                                                        ModalRoute.of(context)
                                                                ?.isCurrent ==
                                                            true) {
                                                      _navTriggeredThisDrag =
                                                          true;
                                                      _showSelectorBottomSheet(
                                                          allBooks);
                                                    }
                                                    _resetOverscrollGate();
                                                  }
                                                } else if (notification
                                                        is ScrollUpdateNotification &&
                                                    _overscrollAccum > 0) {
                                                  // Scroll changed direction
                                                  _resetOverscrollGate();
                                                }
                                              }

                                              if (navSettings.alwaysShowNav) {
                                                return false;
                                              }

                                              if (notification
                                                  is UserScrollNotification) {
                                                if (notification.direction ==
                                                    ScrollDirection.forward) {
                                                  _isScrollingDown = false;
                                                  _continuousScrollTimerStage1
                                                      ?.cancel();
                                                  _continuousScrollTimerStage2
                                                      ?.cancel();
                                                  final isManualHidden = ref
                                                      .read(
                                                          readSettingsProvider)
                                                      .isManualNavHidden;

                                                  // Reveal nav immediately if not manually hidden
                                                  if (!isManualHidden) {
                                                    if (mounted) {
                                                      ref
                                                          .read(
                                                              navHiddenProvider
                                                                  .notifier)
                                                          .set(false);
                                                    }

                                                    // Delay the top header chrome slightly so it's not jarring
                                                    _delayHeaderReveal = true;
                                                    _headerRevealTimer
                                                        ?.cancel();
                                                    _headerRevealTimer = Timer(
                                                        const Duration(
                                                            seconds: 1), () {
                                                      if (mounted) {
                                                        setState(() =>
                                                            _delayHeaderReveal =
                                                                false);
                                                      }
                                                    });
                                                  }
                                                  // Always exit full immersive when scrolling up
                                                  if (mounted) {
                                                    ref
                                                        .read(
                                                            immersiveModeProvider
                                                                .notifier)
                                                        .set(false);
                                                  }
                                                } else if (notification
                                                        .direction ==
                                                    ScrollDirection.reverse) {
                                                  _isScrollingDown = true;

                                                  // Start stage 1 timer (3 seconds -> hide nav)
                                                  if (_continuousScrollTimerStage1 ==
                                                          null ||
                                                      !_continuousScrollTimerStage1!
                                                          .isActive) {
                                                    _continuousScrollTimerStage1 =
                                                        Timer(
                                                            const Duration(
                                                                seconds: 3),
                                                            () {
                                                      if (mounted &&
                                                          _isScrollingDown) {
                                                        ref
                                                            .read(
                                                                navHiddenProvider
                                                                    .notifier)
                                                            .set(true);
                                                        _delayHeaderReveal =
                                                            false;
                                                      }
                                                    });
                                                  }

                                                  // Start stage 2 timer (5 seconds -> full immersive)
                                                  if (ref
                                                          .read(
                                                              readSettingsProvider)
                                                          .readingViewMode ==
                                                      ReadingViewMode
                                                          .immersive) {
                                                    if (_continuousScrollTimerStage2 ==
                                                            null ||
                                                        !_continuousScrollTimerStage2!
                                                            .isActive) {
                                                      _continuousScrollTimerStage2 =
                                                          Timer(
                                                              const Duration(
                                                                  seconds: 5),
                                                              () {
                                                        if (mounted &&
                                                            _isScrollingDown) {
                                                          ref
                                                              .read(
                                                                  immersiveModeProvider
                                                                      .notifier)
                                                              .set(true);
                                                        }
                                                      });
                                                    }
                                                  }
                                                } else if (notification
                                                        .direction ==
                                                    ScrollDirection.idle) {
                                                  _isScrollingDown = false;
                                                  _continuousScrollTimerStage1
                                                      ?.cancel();
                                                  _continuousScrollTimerStage2
                                                      ?.cancel();
                                                }
                                              } else if (notification
                                                  is ScrollEndNotification) {
                                                _isScrollingDown = false;
                                                _continuousScrollTimerStage1
                                                    ?.cancel();
                                                _continuousScrollTimerStage2
                                                    ?.cancel();
                                              }
                                              return false;
                                            },
                                            child: Directionality(
                                              textDirection: () {
                                                final availableTrans = ref
                                                        .watch(
                                                            availableTranslationsProvider)
                                                        .value ??
                                                    [];
                                                final activeTransId = ref.watch(
                                                    activeTranslationProvider);
                                                final transInfo =
                                                    availableTrans.firstWhere(
                                                        (t) =>
                                                            t.translationId ==
                                                            activeTransId,
                                                        orElse: () => availableTrans
                                                                .isNotEmpty
                                                            ? availableTrans
                                                                .first
                                                            : throw Exception(
                                                                'No translation'));
                                                final isRtl = [
                                                  'ar',
                                                  'he',
                                                  'fa',
                                                  'ur'
                                                ].contains(
                                                    transInfo.languageCode);
                                                return isRtl
                                                    ? TextDirection.rtl
                                                    : TextDirection.ltr;
                                              }(),
                                              child: Center(
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 800),
                                                  child:
                                                      ScrollablePositionedList
                                                          .builder(
                                                    itemScrollController:
                                                        _itemScrollControllers[
                                                            pageIndex],
                                                    itemPositionsListener:
                                                        _itemPositionsListeners[
                                                            pageIndex],
                                                    initialScrollIndex: (pageIndex ==
                                                                _currentPageIndex
                                                            ? _navigatedVerseIndex
                                                            : null) ??
                                                        ref
                                                            .read(
                                                                preferencesProvider)
                                                            .getChapterScrollPosition(
                                                                fc.book
                                                                    .abbreviation,
                                                                fc.chapter
                                                                    .number) ??
                                                        0,
                                                    padding: EdgeInsets.only(
                                                        top: MediaQuery.of(context).padding.top +
                                                            80.0,
                                                        left: math.max(
                                                            MediaQuery.of(context)
                                                                .padding
                                                                .left,
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                (typography.marginPercent /
                                                                    100.0)),
                                                        right: math.max(
                                                            MediaQuery.of(context)
                                                                .padding
                                                                .right,
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                (typography.marginPercent /
                                                                    100.0)),
                                                        bottom:
                                                            MediaQuery.of(context).padding.bottom + 80.0),
                                                    itemCount:
                                                        verses.length + 1,
                                                    itemBuilder:
                                                        (context, index) {
                                                      if (index ==
                                                          verses.length) {
                                                        bool
                                                            hasChapterCommentary =
                                                            chaptersWithCommentary
                                                                .contains(
                                                                    '${fc.book.name}|${fc.chapter.number}');
                                                        return _buildEndOfChapterBlock(
                                                            fc,
                                                            pageIndex,
                                                            theme,
                                                            hasChapterCommentary);
                                                      }
                                                      final verse =
                                                          verses[index];
                                                      final isSelected =
                                                          selectedVerses
                                                              .contains(
                                                                  verse.number);
                                                      final isSelectionMode =
                                                          selectedVerses
                                                              .isNotEmpty;

                                                      final bookData =
                                                          chapterTitles[
                                                              fc.book.name];
                                                      final chapterTitle =
                                                          bookData?[fc
                                                              .chapter.number
                                                              .toString()];

                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          if (index == 0 &&
                                                              chapterTitle !=
                                                                  null) ...[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 16.0,
                                                                      bottom:
                                                                          8.0,
                                                                      left:
                                                                          15.0,
                                                                      right:
                                                                          12.0),
                                                              child: Text(
                                                                _toHeadingCase(
                                                                    chapterTitle),
                                                                style: theme
                                                                    .textTheme
                                                                    .titleSmall
                                                                    ?.copyWith(
                                                                  color: theme
                                                                      .primaryColor,
                                                                  fontSize:
                                                                      typography
                                                                              .fontSize *
                                                                          1.25,
                                                                  fontFamily:
                                                                      typography
                                                                          .fontFamily,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  letterSpacing:
                                                                      0.2,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                            ),
                                                          ],
                                                          // Check for commentary
                                                          AnimatedOpacity(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        250),
                                                            opacity:
                                                                (isSelectionMode &&
                                                                        !isSelected)
                                                                    ? 0.85
                                                                    : 1.0,
                                                            alwaysIncludeSemantics:
                                                                true,
                                                            child: Consumer(
                                                                builder:
                                                                    (context,
                                                                        itemRef,
                                                                        _) {
                                                              bool
                                                                  hasCommentary =
                                                                  versesWithCommentary
                                                                      .contains(
                                                                          '${fc.book.name}|${fc.chapter.number}|${verse.number}');

                                                              final highlights =
                                                                  itemRef.watch(
                                                                      highlightsProvider);
                                                              final bookmarks =
                                                                  itemRef.watch(
                                                                      bookmarksProvider);
                                                              final refStr =
                                                                  generateVerseKey(
                                                                      fc.book
                                                                          .abbreviation,
                                                                      fc.chapter
                                                                          .number,
                                                                      verse
                                                                          .number);
                                                              final isBookmarked =
                                                                  bookmarks
                                                                      .contains(
                                                                          refStr);
                                                              final savedColorIndex =
                                                                  highlights[
                                                                      refStr];
                                                              Color?
                                                                  highlightColor;
                                                              if (savedColorIndex !=
                                                                      null &&
                                                                  savedColorIndex >=
                                                                      0 &&
                                                                  savedColorIndex <
                                                                      highlightPalette
                                                                          .length) {
                                                                highlightColor = AppColors.getRenderedHighlightColor(
                                                                    highlightPalette[
                                                                        savedColorIndex],
                                                                    theme
                                                                        .brightness,
                                                                    theme
                                                                        .scaffoldBackgroundColor);
                                                              }

                                                              if (kHighlightDebug) {
                                                                debugPrint(
                                                                    '[HIGHLIGHT_DEBUG] RENDER verse key=$refStr found=${highlights.containsKey(refStr)} color=$savedColorIndex highlightColor=$highlightColor isBookmarked=$isBookmarked timestamp=${DateTime.now().millisecondsSinceEpoch}');
                                                              }

                                                              if (kHighlightDebug &&
                                                                  (isBookmarked ||
                                                                      highlightColor !=
                                                                          null)) {
                                                                debugPrint(
                                                                    'DEBUG RENDER: $refStr isBookmarked=$isBookmarked, highlightColor=$highlightColor');
                                                              }

                                                              return GestureDetector(
                                                                onTap: () =>
                                                                    _toggleVerseSelection(
                                                                        verse
                                                                            .number),
                                                                onLongPress:
                                                                    () {
                                                                  _showVerseContextMenu(
                                                                      context,
                                                                      verse
                                                                          .number,
                                                                      fc
                                                                          .chapter,
                                                                      fc.book
                                                                          .name,
                                                                      fc.chapter
                                                                          .number);
                                                                },
                                                                child: Stack(
                                                                  children: [
                                                                    AnimatedContainer(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              250),
                                                                      clipBehavior:
                                                                          Clip.antiAlias,
                                                                      padding: const EdgeInsets.only(
                                                                          top:
                                                                              6.0,
                                                                          bottom:
                                                                              6.0,
                                                                          left:
                                                                              12.0,
                                                                          right:
                                                                              12.0),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: isSelected
                                                                            ? (highlightColor != null
                                                                                ? highlightColor.withValues(alpha: 0.35)
                                                                                : theme.primaryColor.withValues(alpha: 0.15))
                                                                            : (_navigatedVerseIndex == index ? theme.primaryColor.withValues(alpha: 0.15) : (highlightColor != null ? highlightColor.withValues(alpha: 0.35) : Colors.transparent)),
                                                                        borderRadius:
                                                                            BorderRadius.circular(12),
                                                                        border: (isSelected &&
                                                                                highlightColor != null)
                                                                            ? Border.all(color: theme.primaryColor.withValues(alpha: 0.5), width: 1.5)
                                                                            : Border.all(color: Colors.transparent, width: 1.5),
                                                                      ),
                                                                      child:
                                                                        _buildReadingLayoutVerse(
                                                                      context,
                                                                      ref,
                                                                      verse,
                                                                      secondaryVerseMap[verse.number],
                                                                      allBooks.indexOf(fc.book) + 1,
                                                                      fc.chapter.number,
                                                                        readSettings.readingLayout,
                                                                        theme,
                                                                        typography,
                                                                        appThemeMode,
                                                                        hasCommentary:
                                                                            hasCommentary,
                                                                        onCommentaryTap: () => _showCommentaryBottomSheet(
                                                                            verse.number,
                                                                            verse.text),
                                                                        isBookmarked:
                                                                            isBookmarked,
                                                                        isRedLetterEnabled:
                                                                            readSettings.isRedLetterEnabled,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                  ),
                  // Top Navigation Bar Layer (Floating pills allowing text to flow behind)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 8.0,
                        left: 24.0,
                        right: 24.0,
                      ),
                      child: _buildTopRow(
                        context,
                        ref,
                        theme,
                        currentBookName,
                        currentChapter,
                        allBooks,
                        isImmersive &&
                            readSettings.readingViewMode ==
                                ReadingViewMode.immersive,
                      ),
                    ),
                  ),

                  // ── Pull-to-navigate progressive indicator ──────────────────────
                  // Fades in and grows as the user sustains a deliberate downward
                  // drag from the top edge. Vanishes if they release early.
                  if (bibleNavSettings.swipeDownToNav &&
                      _overscrollFraction > 0.01)
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          65, // Positioned in the gap between header and chapter title
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _overscrollFraction,
                          alwaysIncludeSemantics: true,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(
                                      alpha: 0.12 + 0.18 * _overscrollFraction),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.primaryColor.withValues(
                                        alpha: 0.25 * _overscrollFraction),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      size: 16,
                                      color: theme.primaryColor.withValues(
                                          alpha:
                                              0.4 + 0.6 * _overscrollFraction),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _overscrollFraction >= 1.0
                                          ? 'Release to navigate'
                                          : 'Pull to navigate',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: theme.primaryColor.withValues(
                                            alpha: 0.5 +
                                                0.5 * _overscrollFraction),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // ────────────────────────────────────────────────────────────────
                  // ────────────────────────────────────────────────────────────────
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        if (child.key == const ValueKey('empty')) {
                          return const SizedBox.shrink();
                        }
                        return Stack(
                          children: [
                            FadeTransition(
                              opacity: animation,
                              alwaysIncludeSemantics: true,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: _dismissContextMenu,
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          ],
                        );
                      },
                      child: _contextMenuVerse != null
                          ? VerseContextMenuContent(
                              key: ValueKey('content_$_contextMenuVerse'),
                              verseNumber: _contextMenuVerse!,
                              chapterData: _contextMenuChapterData,
                              bookName: _contextMenuBookName!,
                              chapterNum: _contextMenuChapterNum!,
                              bookAbbrev:
                                  ref.read(readLocationProvider).bookAbbrev,
                              onDismiss: _dismissContextMenu,
                            )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                  ),

                  // ── Hints UI ──────────────────────────────────────────────────
                  if (_currentHintMessage != null)
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: AnimatedOpacity(
                        opacity: _currentHintMessage != null ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        alwaysIncludeSemantics: true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_rounded,
                                  color: AppColors.goldAccent, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _currentHintMessage!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close_rounded,
                                    size: 16,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6)),
                                onPressed: _dismissHint,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
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

  void _showVerseContextMenu(BuildContext context, int verseNumber,
      dynamic chapterData, String bookName, int chapterNum) {
    setState(() {
      _contextMenuVerse = verseNumber;
      _contextMenuChapterData = chapterData;
      _contextMenuBookName = bookName;
      _contextMenuChapterNum = chapterNum;
    });
  }

  void _showCommentaryBottomSheet(int verseNumber, String verseText) {
    if (!mounted) return;
    final loc = ref.read(readLocationProvider);
    showCommentaryBottomSheet(
      context,
      book: loc.bookName,
      chapter: loc.chapter,
      verse: verseNumber,
      verseText: verseText,
    );
  }

  Widget _buildReadingLayoutVerse(
      BuildContext context,
      WidgetRef ref,
      BibleVerse primaryVerse,
      BibleVerse? secondaryVerse,
      int bookNumber,
      int chapterNumber,
      ReadingLayout layout,
      ThemeData theme,
      TypographyState typography,
      AppThemeMode appThemeMode,
      {bool hasCommentary = false,
      VoidCallback? onCommentaryTap,
      bool isBookmarked = false,
      bool isRedLetterEnabled = true}) {
    final primary = _buildNormalVerse(
      primaryVerse,
      theme,
      typography,
      appThemeMode,
      hasCommentary: hasCommentary,
      onCommentaryTap: onCommentaryTap,
      isBookmarked: isBookmarked,
      isRedLetterEnabled: isRedLetterEnabled,
    );

    if (secondaryVerse == null || layout == ReadingLayout.single) {
      return primary;
    }

    if (layout == ReadingLayout.interleaved) {
      final tokens = theme.extension<ReadingTokens>()!;
      final secondaryColor = tokens.readingInk.withValues(alpha: 0.65);
      
      final secondaryTypography = typography.copyWith(
        fontSize: typography.fontSize * 0.95,
      );

      final installedTranslations = ref.watch(availableTranslationsProvider).value ?? [];
      final secondaryId = ref.read(secondaryTranslationProvider) ?? '';
      final badgeLabel = _getTranslationCombinedLabel(secondaryId, installedTranslations);

      final secondary = _buildNormalVerse(
        secondaryVerse,
        theme,
        secondaryTypography,
        appThemeMode,
        hasCommentary: false,
        isBookmarked: false,
        isRedLetterEnabled: isRedLetterEnabled,
        overrideColor: secondaryColor,
        hideVerseNumber: true,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badgeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: secondaryColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                secondary,
              ],
            ),
          ),
        ],
      );
    }
    
    if (layout == ReadingLayout.sideBySide) {
      final tokens = theme.extension<ReadingTokens>()!;
      final secondaryColor = tokens.readingInk.withValues(alpha: 0.75);
      
      final secondaryTypography = typography.copyWith(
        fontSize: typography.fontSize * 0.95,
      );

      final installedTranslations = ref.watch(availableTranslationsProvider).value ?? [];
      final secondaryId = ref.read(secondaryTranslationProvider) ?? '';
      final badgeLabel = _getTranslationCombinedLabel(secondaryId, installedTranslations);

      final secondary = _buildNormalVerse(
        secondaryVerse,
        theme,
        secondaryTypography,
        appThemeMode,
        hasCommentary: false,
        isBookmarked: false,
        isRedLetterEnabled: isRedLetterEnabled,
        overrideColor: secondaryColor,
        hideVerseNumber: true,
      );

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: primary),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badgeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: secondaryColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                secondary,
              ],
            ),
          ),
        ],
      );
    }
    
    if (layout == ReadingLayout.chips) {
      final expandedChipsMap = ref.watch(expandedChipsProvider);
      final activeChipId = expandedChipsMap[primaryVerse.number];
      
      final tokens = theme.extension<ReadingTokens>()!;
      final secondaryColor = tokens.readingInk.withValues(alpha: 0.75);
      
      final secondaryTypography = typography.copyWith(
        fontSize: typography.fontSize * 0.95,
      );

      final targetLanguages = {
        'English': 'EN',
        'Swahili': 'SW',
        'French': 'FR',
        'Italian': 'IT',
        'Spanish': 'ES',
        'Tagalog': 'TL',
      };
      
      final installedTranslations = ref.watch(availableTranslationsProvider).value ?? [];
      final availableChips = <String, String>{}; 
      for (final t in installedTranslations) {
        if (targetLanguages.containsKey(t.languageName)) {
          final label = targetLanguages[t.languageName]!;
          if (!availableChips.containsKey(label)) {
            availableChips[label] = t.translationId;
          }
        }
      }

      Widget? activeTranslationWidget;
      if (activeChipId != null) {
        final verseAsync = ref.watch(verseTranslationProvider((
          translationId: activeChipId,
          bookNumber: bookNumber,
          chapter: chapterNumber,
          verse: primaryVerse.number,
        )));
        
        activeTranslationWidget = verseAsync.when(
          data: (verse) {
            if (verse == null) return const SizedBox.shrink();
            return _buildNormalVerse(
              verse,
              theme,
              secondaryTypography,
              appThemeMode,
              hasCommentary: false,
              isBookmarked: false,
              isRedLetterEnabled: isRedLetterEnabled,
              overrideColor: secondaryColor,
              hideVerseNumber: true,
            );
          },
          loading: () => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 16, width: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final langEntry in targetLanguages.entries)
                  Builder(
                    builder: (context) {
                      final isInstalled = availableChips.containsKey(langEntry.value);
                      final translationId = availableChips[langEntry.value];
                      final isSelected = activeChipId == translationId;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Material(
                          color: isSelected
                              ? theme.primaryColor.withValues(alpha: 0.15)
                              : theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.primaryColor.withValues(alpha: 0.5)
                                  : theme.colorScheme.onSurface.withValues(alpha: isInstalled ? 0.15 : 0.05),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              if (isInstalled) {
                                if (isSelected) {
                                  ref.read(expandedChipsProvider.notifier).clear(primaryVerse.number);
                                } else {
                                  ref.read(expandedChipsProvider.notifier).setLanguage(primaryVerse.number, translationId!);
                                }
                              } else {
                                // Uninstalled: Prompt download by opening picker
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useRootNavigator: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => const TranslationPickerSheet(),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getTranslationCombinedLabel(
                                      isInstalled ? translationId! : langEntry.value, 
                                      installedTranslations, 
                                      defaultName: langEntry.key
                                    ),
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: isSelected
                                          ? theme.primaryColor
                                          : theme.colorScheme.onSurface.withValues(alpha: isInstalled ? 0.7 : 0.3),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (!isInstalled) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.download_rounded, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  ),
              ],
            ),
          ),
          if (activeTranslationWidget != null) ...[
            const SizedBox(height: 12),
            activeTranslationWidget,
          ],
        ],
      );
    }
    
    // Fallback for other modes not implemented yet
    return primary;
  }

  Widget _buildNormalVerse(BibleVerse verse, ThemeData theme,
      TypographyState typography, AppThemeMode appThemeMode,
      {bool hasCommentary = false,
      VoidCallback? onCommentaryTap,
      bool isBookmarked = false,
      bool isRedLetterEnabled = true,
      Color? overrideColor,
      bool hideVerseNumber = false}) {
    final tokens = theme.extension<ReadingTokens>()!;
    final fontStyle = theme.textTheme.bodyMedium?.copyWith(
          fontFamily: typography.fontFamily,
          fontSize: typography.fontSize,
          height: typography.lineHeight,
          letterSpacing: 0.15,
          color: overrideColor ?? tokens.readingInk,
          decoration: isBookmarked ? TextDecoration.underline : null,
          decorationColor: isBookmarked ? theme.primaryColor : null,
          decorationStyle: isBookmarked ? TextDecorationStyle.solid : null,
          decorationThickness: isBookmarked ? 2.0 : null,
        ) ??
        const TextStyle();

    Color starColor;
    Color redLetterColor;
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
        starColor = Colors.deepOrange.shade400;
        redLetterColor = const Color(0xFFB33A3A); // Soft crimson
        break;
      case AppThemeMode.dark:
      case AppThemeMode.oled:
      case AppThemeMode.dusk:
      case AppThemeMode.automatic:
        starColor = Colors.amber.shade400;
        redLetterColor = const Color(0xFFD46A6A); // Lighter muted red
        break;
      case AppThemeMode.sepia:
        starColor = Colors.orange.shade700;
        redLetterColor = const Color(0xFFA63C3C); // Warm crimson
        break;
    }

    final redLetterStyle = fontStyle.copyWith(color: redLetterColor);
    List<TextSpan> textSpans = [];
    String text = verse.text;
    int currentIndex = 0;

    while (currentIndex < text.length) {
      int startIndex = text.indexOf('‹', currentIndex);
      if (startIndex == -1) {
        textSpans.add(
            TextSpan(text: text.substring(currentIndex), style: fontStyle));
        break;
      }

      if (startIndex > currentIndex) {
        textSpans.add(TextSpan(
            text: text.substring(currentIndex, startIndex), style: fontStyle));
      }

      int endIndex = text.indexOf('›', startIndex + 1);
      if (endIndex == -1) {
        textSpans.add(TextSpan(
            text: text.substring(startIndex + 1),
            style: isRedLetterEnabled ? redLetterStyle : fontStyle));
        break;
      }

      textSpans.add(TextSpan(
          text: text.substring(startIndex + 1, endIndex),
          style: isRedLetterEnabled ? redLetterStyle : fontStyle));

      currentIndex = endIndex + 1;
    }

    return RichText(
      textAlign: () {
        switch (typography.textAlignMode) {
          case TextAlignMode.left:
            return TextAlign.start;
          case TextAlignMode.center:
            return TextAlign.center;
          case TextAlignMode.right:
            return TextAlign.end;
          case TextAlignMode.justified:
            return TextAlign.justify;
        }
      }(),
      text: TextSpan(
        style: fontStyle,
        children: [
          if (ref.watch(readSettingsProvider).showVerseNumbers && !hideVerseNumber)
            TextSpan(
              text: '${verse.number}  ',
              style: theme.textTheme.titleMedium?.copyWith(
                color: tokens.readingAccent,
                fontWeight: FontWeight.bold,
                fontSize: typography.fontSize * 0.75, // Scale number down
              ),
            ),
          ...textSpans,
          if (hasCommentary)
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: GestureDetector(
                onTap: onCommentaryTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  // Generous padding increases the invisible tap target area for all finger sizes
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 8.0, top: 2.0, bottom: 8.0),
                  child: Icon(
                    Icons.star_rounded,
                    color: starColor,
                    size: typography.fontSize *
                        0.85, // Slightly larger star for visibility
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEndOfChapterBlock(FlatChapter fc, int pageIndex, ThemeData theme,
      bool hasChapterCommentary) {
    final flatChapters = ref.read(flatChaptersProvider);
    final hasPrevious = pageIndex > 0;
    final hasNext = pageIndex < flatChapters.length - 1;
    final tokens = theme.extension<ReadingTokens>()!;

    return Padding(
      padding:
          const EdgeInsets.only(top: 80.0, bottom: 160.0), // Above nav pill
      child: Column(
        children: [
          // Divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: tokens.readingBorder),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '· End of ${fc.book.name} ${fc.chapter.number} ·',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Container(
                  width: 40,
                  height: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            ],
          ),
          const SizedBox(height: 32),

          // Commentary Button
          TextButton.icon(
            onPressed: hasChapterCommentary
                ? () {
                    showCommentaryBottomSheet(
                      context,
                      book: fc.book.name,
                      chapter: fc.chapter.number,
                      verse: null,
                    );
                  }
                : null,
            icon: Icon(Icons.school_rounded,
                color: hasChapterCommentary
                    ? tokens.readingAccent
                    : theme.disabledColor),
            label: Text(
              'Read commentary on this chapter',
              style: theme.textTheme.titleSmall?.copyWith(
                color: hasChapterCommentary
                    ? tokens.readingInk
                    : theme.disabledColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: tokens.readingInk.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 32),

          // Prev/Next Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasPrevious)
                TextButton(
                  onPressed: () {
                    _pageController.animateToPage(pageIndex - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: Text('‹ Previous',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: tokens.readingAccent)),
                )
              else
                const SizedBox(width: 100),
              const SizedBox(width: 24),
              if (hasNext)
                TextButton(
                  onPressed: () {
                    _pageController.animateToPage(pageIndex + 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: Text('Next ›',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: tokens.readingAccent)),
                )
              else
                const SizedBox(width: 100),
            ],
          ),

          // Plan End-of-Chapter Prompt
          Consumer(
            builder: (context, ref, child) {
              final activePlanDay = ref.watch(activePlanContextProvider);
              if (activePlanDay == null) return const SizedBox.shrink();

              final activePlanIds = ref.watch(activePlanIdsProvider);
              if (activePlanIds.isEmpty) return const SizedBox.shrink();
              final primaryPlanId = activePlanIds.first;
              final planState = ref.watch(readingPlanProvider(primaryPlanId));
              if (activePlanDay < 1 ||
                  activePlanDay > planState.planData.length) {
                return const SizedBox.shrink();
              }

              final dayTarget = planState.planData[activePlanDay - 1];
              final chapterId = '${fc.book.name}_${fc.chapter.number}';

              final isPartOfDay =
                  dayTarget.chapters.any((c) => c.id == chapterId);
              if (!isPartOfDay) return const SizedBox.shrink();

              final isCompleted =
                  planState.completedChapters.contains(chapterId);
              if (isCompleted) {
                return const Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: Center(
                      child: Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 32)),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                child: TexturedGlassContainer(
                  borderRadius: BorderRadius.circular(24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        'Reading Plan · Day $activePlanDay',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          onPressed: () {
                            final notifier = ref.read(
                                readingPlanProvider(primaryPlanId).notifier);
                            final chapterToMark = PlanChapter(
                                bookName: fc.book.name,
                                chapterNum: fc.chapter.number);
                            notifier.markChapterComplete(chapterToMark);

                            final updatedPlanState =
                                ref.read(readingPlanProvider(primaryPlanId));
                            if (updatedPlanState.isDayComplete(activePlanDay)) {
                              ref
                                  .read(activePlanContextProvider.notifier)
                                  .setContext(null);
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dialogContext) =>
                                      DayCompleteCelebration(
                                          day: activePlanDay,
                                          onComplete: () {
                                            final nav =
                                                Navigator.of(dialogContext);
                                            final messenger =
                                                ScaffoldMessenger.of(context);

                                            nav.pop();
                                            if (!mounted) return;

                                            notifier
                                                .markDayComplete(activePlanDay);

                                            final finalState = ref.read(
                                                readingPlanProvider(
                                                    primaryPlanId));
                                            if (finalState.isPlanComplete) {
                                              messenger.showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Plan completed! Congratulations! 🎉')));
                                            } else {
                                              final nextDay =
                                                  finalState.currentDay;
                                              if (nextDay > 0 &&
                                                  nextDay <=
                                                      finalState
                                                          .planData.length) {
                                                ref
                                                    .read(
                                                        activePlanContextProvider
                                                            .notifier)
                                                    .setContext(nextDay);
                                                final nextDayTarget = finalState
                                                    .planData[nextDay - 1];
                                                PlanChapter? firstUnread;
                                                for (final c
                                                    in nextDayTarget.chapters) {
                                                  if (!finalState
                                                      .completedChapters
                                                      .contains(c.id)) {
                                                    firstUnread = c;
                                                    break;
                                                  }
                                                }
                                                firstUnread ??=
                                                    nextDayTarget.chapters.last;
                                                final fcList = ref
                                                    .read(flatChaptersProvider);
                                                final match = fcList
                                                    .where((c) =>
                                                        c.book.name
                                                                .toLowerCase() ==
                                                            firstUnread!
                                                                .bookName
                                                                .toLowerCase() &&
                                                        c.chapter.number ==
                                                            firstUnread
                                                                .chapterNum)
                                                    .toList();
                                                if (match.isNotEmpty) {
                                                  ref
                                                      .read(readLocationProvider
                                                          .notifier)
                                                      .updateLocation(
                                                          bookAbbrev: match
                                                              .first
                                                              .book
                                                              .abbreviation,
                                                          chapter: firstUnread
                                                              .chapterNum,
                                                          verse: 1);
                                                }
                                              }
                                            }
                                          }));
                            } else {
                              PlanChapter? nextUnread;
                              for (final c in dayTarget.chapters) {
                                if (!updatedPlanState.completedChapters
                                    .contains(c.id)) {
                                  nextUnread = c;
                                  break;
                                }
                              }
                              if (nextUnread != null) {
                                final fcList = ref.read(flatChaptersProvider);
                                final match = fcList
                                    .where((c) =>
                                        c.book.name.toLowerCase() ==
                                            nextUnread!.bookName
                                                .toLowerCase() &&
                                        c.chapter.number ==
                                            nextUnread.chapterNum)
                                    .toList();
                                if (match.isNotEmpty) {
                                  ref
                                      .read(readLocationProvider.notifier)
                                      .updateLocation(
                                          bookAbbrev:
                                              match.first.book.abbreviation,
                                          chapter: nextUnread.chapterNum,
                                          verse: 1);
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          label: Text(
                              'Mark ${fc.book.name} ${fc.chapter.number} done & continue',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum SelectionMode { testament, book, chapter, verse }

/// Modal Bottom Sheet for selecting Book, Chapter, and Verse

class _SheetState {
  final BibleBook? book;
  final int chapter;
  final int? verse;
  final SelectionMode mode;
  final bool isOldTestament;

  const _SheetState({
    this.book,
    this.chapter = 1,
    this.verse,
    this.mode = SelectionMode.book,
    this.isOldTestament = true,
  });

  _SheetState copyWith({
    BibleBook? book,
    int? chapter,
    int? verse,
    SelectionMode? mode,
    bool? isOldTestament,
    bool clearVerse = false,
  }) {
    return _SheetState(
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: clearVerse ? null : (verse ?? this.verse),
      mode: mode ?? this.mode,
      isOldTestament: isOldTestament ?? this.isOldTestament,
    );
  }
}

class _SheetNotifier extends Notifier<_SheetState> {
  @override
  _SheetState build() => const _SheetState();

  void init(
      BibleBook book, int chapter, bool isOldTestament, SelectionMode mode) {
    state = _SheetState(
        book: book,
        chapter: chapter,
        isOldTestament: isOldTestament,
        mode: mode);
  }

  void setTestament(bool isOld) {
    state = state.copyWith(isOldTestament: isOld, mode: SelectionMode.book);
  }

  void setBook(BibleBook book) {
    state = state.copyWith(
        book: book, chapter: 1, clearVerse: true, mode: SelectionMode.chapter);
  }

  void setChapter(int chapter, bool advanceToVerse) {
    state = state.copyWith(
        chapter: chapter,
        verse: 1,
        mode: advanceToVerse ? SelectionMode.verse : state.mode);
  }

  void setVerse(int verse) {
    state = state.copyWith(verse: verse);
  }

  void setMode(SelectionMode mode) {
    state = state.copyWith(mode: mode);
  }
}

final _sheetStateProvider =
    NotifierProvider.autoDispose<_SheetNotifier, _SheetState>(
        _SheetNotifier.new);

class _BookChapterSelectorSheet extends ConsumerStatefulWidget {
  final List<BibleBook> books;
  final String selectedBookAbbrev;
  final int selectedChapter;
  final void Function(String abbrev, String name, int chapter, int? verse,
      {bool autoClose}) onSelectionChanged;

  const _BookChapterSelectorSheet({
    required this.books,
    required this.selectedBookAbbrev,
    required this.selectedChapter,
    required this.onSelectionChanged,
  });

  @override
  ConsumerState<_BookChapterSelectorSheet> createState() =>
      __BookChapterSelectorSheetState();
}

class __BookChapterSelectorSheetState
    extends ConsumerState<_BookChapterSelectorSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.books.isEmpty) return;
      int bookIndex = widget.books
          .indexWhere((b) => b.abbreviation == widget.selectedBookAbbrev);
      if (bookIndex == -1) bookIndex = 0;
      final initialBook = widget.books[bookIndex];
      final isOldTestament = bookIndex < 39;
      final settings = ref.read(bibleNavSettingsProvider);
      final mode = settings.depth == NavigationDepth.fourPart
          ? SelectionMode.testament
          : SelectionMode.book;

      ref
          .read(_sheetStateProvider.notifier)
          .init(initialBook, widget.selectedChapter, isOldTestament, mode);
    });
  }

  void _onTestamentSelected(bool isOld) {
    ref.read(_sheetStateProvider.notifier).setTestament(isOld);
  }

  void _onBookSelected(BibleBook book, BibleNavSettingsState settings) {
    ref.read(_sheetStateProvider.notifier).setBook(book);
    ref.read(_sheetStateProvider.notifier).setMode(SelectionMode.chapter);
  }

  void _onChapterSelected(int chapter, BibleNavSettingsState settings) {
    if (settings.depth == NavigationDepth.twoPart) {
      ref.read(_sheetStateProvider.notifier).setChapter(chapter, false);
      final book = ref.read(_sheetStateProvider).book!;
      widget.onSelectionChanged(
        book.abbreviation,
        book.name,
        chapter,
        1,
        autoClose: true,
      );
    } else {
      ref.read(_sheetStateProvider.notifier).setChapter(chapter, true);
    }
  }

  void _onVerseSelected(int verse, BibleNavSettingsState settings) {
    ref.read(_sheetStateProvider.notifier).setVerse(verse);
    final sheetState = ref.read(_sheetStateProvider);
    widget.onSelectionChanged(
      sheetState.book!.abbreviation,
      sheetState.book!.name,
      sheetState.chapter,
      verse,
      autoClose: settings.autoCloseOnFinalSelection,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(bibleNavSettingsProvider);
    final isInitialized =
        ref.watch(_sheetStateProvider.select((s) => s.book != null));

    if (!isInitialized) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: TexturedGlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBreadcrumbs(theme, settings),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildSelectionView(theme, settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs(ThemeData theme, BibleNavSettingsState settings) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          if (settings.depth == NavigationDepth.fourPart)
            Consumer(builder: (context, ref, _) {
              final isOld = ref
                  .watch(_sheetStateProvider.select((s) => s.isOldTestament));
              final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
              return _buildBreadcrumbSegment('Testament', isOld ? 'OT' : 'NT',
                  SelectionMode.testament, mode, theme);
            }),
          Consumer(builder: (context, ref, _) {
            final bookName =
                ref.watch(_sheetStateProvider.select((s) => s.book!.name));
            final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
            return _buildBreadcrumbSegment(
                'Book', bookName, SelectionMode.book, mode, theme);
          }),
          Consumer(builder: (context, ref, _) {
            final chapter =
                ref.watch(_sheetStateProvider.select((s) => s.chapter));
            final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
            return _buildBreadcrumbSegment(
                'Chapter', '$chapter', SelectionMode.chapter, mode, theme);
          }),
          if (settings.depth != NavigationDepth.twoPart)
            Consumer(builder: (context, ref, _) {
              final verse =
                  ref.watch(_sheetStateProvider.select((s) => s.verse));
              final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
              return _buildBreadcrumbSegment(
                  'Verse',
                  verse != null ? '$verse' : '1',
                  SelectionMode.verse,
                  mode,
                  theme);
            }),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbSegment(String label, String value,
      SelectionMode targetMode, SelectionMode currentMode, ThemeData theme) {
    final isSelected = currentMode == targetMode;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(_sheetStateProvider.notifier).setMode(targetMode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionView(ThemeData theme, BibleNavSettingsState settings) {
    final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
    switch (mode) {
      case SelectionMode.testament:
        return _buildTestamentSelection(theme);
      case SelectionMode.book:
        return _buildBookSelection(theme, settings);
      case SelectionMode.chapter:
        return _buildChapterSelection(theme, settings);
      case SelectionMode.verse:
        return _buildVerseSelection(theme, settings);
    }
  }

  Widget _buildTestamentSelection(ThemeData theme) {
    final isOldTestament =
        ref.watch(_sheetStateProvider.select((s) => s.isOldTestament));
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildGridTile(
              text: 'Old\nTestament',
              isSelected: isOldTestament,
              onTap: () => _onTestamentSelected(true),
              theme: theme,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildGridTile(
              text: 'New\nTestament',
              isSelected: !isOldTestament,
              onTap: () => _onTestamentSelected(false),
              theme: theme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookSelection(ThemeData theme, BibleNavSettingsState settings) {
    final oldTestamentBooks = widget.books.take(39).toList();
    final newTestamentBooks = widget.books.skip(39).toList();

    if (settings.depth == NavigationDepth.fourPart) {
      final isOldTestament =
          ref.watch(_sheetStateProvider.select((s) => s.isOldTestament));
      final displayedBooks =
          isOldTestament ? oldTestamentBooks : newTestamentBooks;
      return Consumer(builder: (context, ref, _) {
        final selectedBookAbbrev =
            ref.watch(_sheetStateProvider.select((s) => s.book!.abbreviation));
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 4),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 48,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: displayedBooks.length,
          itemBuilder: (context, index) {
            final book = displayedBooks[index];
            final isSel = book.abbreviation == selectedBookAbbrev;
            return _buildGridTile(
              text: book.name,
              isSelected: isSel,
              onTap: () => _onBookSelected(book, settings),
              theme: theme,
              backgroundColor: getSectionColor(
                  book.name, theme.brightness == Brightness.dark),
            );
          },
        );
      });
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text('Old Testament',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer(builder: (context, ref, _) {
                  final selectedBookAbbrev = ref.watch(
                      _sheetStateProvider.select((s) => s.book!.abbreviation));
                  return ListView.builder(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 4),
                    itemCount: oldTestamentBooks.length,
                    itemExtent: 50,
                    itemBuilder: (context, index) {
                      final book = oldTestamentBooks[index];
                      final isSel = book.abbreviation == selectedBookAbbrev;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0, right: 4.0),
                        child: _buildGridTile(
                            text: book.name,
                            isSelected: isSel,
                            onTap: () => _onBookSelected(book, settings),
                            theme: theme,
                            backgroundColor: getSectionColor(book.name,
                                theme.brightness == Brightness.dark)),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        Container(
            width: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            margin: const EdgeInsets.symmetric(horizontal: 8)),
        Expanded(
          child: Column(
            children: [
              Text('New Testament',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer(builder: (context, ref, _) {
                  final selectedBookAbbrev = ref.watch(
                      _sheetStateProvider.select((s) => s.book!.abbreviation));
                  return ListView.builder(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 4),
                    itemCount: newTestamentBooks.length,
                    itemExtent: 50,
                    itemBuilder: (context, index) {
                      final book = newTestamentBooks[index];
                      final isSel = book.abbreviation == selectedBookAbbrev;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                        child: _buildGridTile(
                            text: book.name,
                            isSelected: isSel,
                            onTap: () => _onBookSelected(book, settings),
                            theme: theme,
                            backgroundColor: getSectionColor(book.name,
                                theme.brightness == Brightness.dark)),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapterSelection(
      ThemeData theme, BibleNavSettingsState settings) {
    final book = ref.read(_sheetStateProvider).book!;
    final chapters = book.chapters.length;

    return Consumer(builder: (context, ref, _) {
      final selectedChapter =
          ref.watch(_sheetStateProvider.select((s) => s.chapter));
      return GridView.builder(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 64,
          mainAxisExtent: 64,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: chapters,
        itemBuilder: (context, index) {
          final chapter = index + 1;
          final isSel = chapter == selectedChapter;
          return _buildGridTile(
            text: '$chapter',
            isSelected: isSel,
            onTap: () => _onChapterSelected(chapter, settings),
            theme: theme,
          );
        },
      );
    });
  }

  Widget _buildVerseSelection(ThemeData theme, BibleNavSettingsState settings) {
    final book = ref.read(_sheetStateProvider).book!;
    final selectedChapter = ref.read(_sheetStateProvider).chapter;

    if (book.chapters.isEmpty) return const SizedBox.shrink();
    int chapIdx = book.chapters.indexWhere((c) => c.number == selectedChapter);
    if (chapIdx == -1) chapIdx = 0;
    final chapterData = book.chapters[chapIdx];
    final verses = chapterData.verses.length;

    return Consumer(builder: (context, ref, _) {
      final selectedVerse =
          ref.watch(_sheetStateProvider.select((s) => s.verse));
      return GridView.builder(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 64,
          mainAxisExtent: 64,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: verses,
        itemBuilder: (context, index) {
          final verse = index + 1;
          final isSel = verse == selectedVerse;
          return _buildGridTile(
            text: '$verse',
            isSelected: isSel,
            onTap: () => _onVerseSelected(verse, settings),
            theme: theme,
          );
        },
      );
    });
  }

  Widget _buildGridTile(
      {required String text,
      required bool isSelected,
      required VoidCallback onTap,
      required ThemeData theme,
      Color? backgroundColor}) {
    // Determine if it's a book name (contains letters) to apply serif font consistency
    final isBook = text.contains(RegExp(r'[a-zA-Z]'));

    final textStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
      fontFamily: isBook
          ? theme.textTheme.bodyMedium?.fontFamily
          : null, // Font consistency for books
      color: isSelected
          ? Colors.white
          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
    );

    final textWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: textStyle,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (!isSelected) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ??
                theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: textWidget,
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: textWidget,
      ),
    );
  }
}

class _TypographyBottomSheet extends ConsumerWidget {
  const _TypographyBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final typographyNotifier = ref.read(typographyProvider.notifier);




    final fonts = [
      'EB Garamond',
      'Inter',
      'Gentium Book Plus',
      'Lora',
      'Literata',
      'Lexend'
    ];

    final handlebarColor = theme.colorScheme.onSurface.withValues(alpha: 0.2);

    final sectionLabelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.primaryColor,
      letterSpacing: 1.2,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    final valueStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.primaryColor,
      fontWeight: FontWeight.bold,
    );
    final iconColor = theme.primaryColor;

    return BouncyEntrance(
      delay: const Duration(milliseconds: 50),
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: TexturedGlassContainer(
          sigmaX: 45.0,
          sigmaY: 45.0,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          padding: EdgeInsets.zero,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: handlebarColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Typography',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.text_increase_rounded,
                              size: 16, color: iconColor),
                          const SizedBox(width: 8),
                          Text('FONT SIZE', style: sectionLabelStyle),
                        ],
                      ),
                      Text('${typography.fontSize.clamp(12.0, 32.0).round()}',
                          style: valueStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final v = (typography.fontSize - 1).clamp(12.0, 32.0);
                          if (v != typography.fontSize) {
                            HapticFeedback.selectionClick();
                            typographyNotifier.setFontSize(v);
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.25)),
                          ),
                          child: Center(
                            child: Text('A−',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                    height: 1.0)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7),
                            tickMarkShape: const RoundSliderTickMarkShape(
                                tickMarkRadius: 1.5),
                            activeTickMarkColor: theme.scaffoldBackgroundColor
                                .withValues(alpha: 0.6),
                            inactiveTickMarkColor:
                                theme.primaryColor.withValues(alpha: 0.3),
                          ),
                          child: Slider(
                            value: typography.fontSize.clamp(12.0, 32.0),
                            min: 12.0,
                            max: 32.0,
                            divisions: 20,
                            activeColor: theme.primaryColor,
                            inactiveColor:
                                theme.primaryColor.withValues(alpha: 0.2),
                            onChanged: (value) {
                              if (value != typography.fontSize) {
                                HapticFeedback.selectionClick();
                                typographyNotifier.setFontSize(value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          final v = (typography.fontSize + 1).clamp(12.0, 32.0);
                          if (v != typography.fontSize) {
                            HapticFeedback.selectionClick();
                            typographyNotifier.setFontSize(v);
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.25)),
                          ),
                          child: Center(
                            child: Text('A+',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                    height: 1.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_line_spacing_rounded,
                              size: 16, color: iconColor),
                          const SizedBox(width: 8),
                          Text('LINE SPACING', style: sectionLabelStyle),
                        ],
                      ),
                      Text(
                        typography.lineHeight <= 1.4
                            ? 'Compact'
                            : (typography.lineHeight >= 1.8
                                ? 'Relaxed'
                                : 'Normal'),
                        style: valueStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: PillSegmentedControl(
                      segments: const ['Compact', 'Normal', 'Relaxed'],
                      selectedIndex: typography.lineHeight <= 1.4
                          ? 0
                          : (typography.lineHeight >= 1.8 ? 2 : 1),
                      onSegmentSelected: (index) {
                        HapticFeedback.selectionClick();
                        typographyNotifier
                            .setLineHeight([1.3, 1.6, 1.9][index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.padding_rounded,
                              size: 16, color: iconColor),
                          const SizedBox(width: 8),
                          Text('MARGINS', style: sectionLabelStyle),
                        ],
                      ),
                      Text('${typography.marginPercent.toStringAsFixed(0)}%',
                          style: valueStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 7),
                      tickMarkShape:
                          const RoundSliderTickMarkShape(tickMarkRadius: 1.5),
                      activeTickMarkColor:
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                      inactiveTickMarkColor:
                          theme.primaryColor.withValues(alpha: 0.3),
                    ),
                    child: Slider(
                      value: typography.marginPercent.clamp(0.0, 16.0),
                      min: 0.0,
                      max: 16.0,
                      divisions: 16,
                      activeColor: theme.primaryColor,
                      inactiveColor: theme.primaryColor.withValues(alpha: 0.2),
                      onChanged: (value) {
                        if (value != typography.marginPercent) {
                          HapticFeedback.selectionClick();
                          typographyNotifier.setMarginPercent(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_align_left_rounded,
                              size: 16, color: iconColor),
                          const SizedBox(width: 8),
                          Text('ALIGNMENT', style: sectionLabelStyle),
                        ],
                      ),
                      Text(
                        () {
                          switch (typography.textAlignMode) {
                            case TextAlignMode.left:
                              return 'Left';
                            case TextAlignMode.center:
                              return 'Center';
                            case TextAlignMode.right:
                              return 'Right';
                            case TextAlignMode.justified:
                              return 'Justified';
                          }
                        }(),
                        style: valueStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AlignmentButton(
                        icon: Icons.format_align_left_rounded,
                        isSelected:
                            typography.textAlignMode == TextAlignMode.left,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          typographyNotifier
                              .setTextAlignMode(TextAlignMode.left);
                        },
                      ),
                      const SizedBox(width: 12),
                      _AlignmentButton(
                        icon: Icons.format_align_center_rounded,
                        isSelected:
                            typography.textAlignMode == TextAlignMode.center,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          typographyNotifier
                              .setTextAlignMode(TextAlignMode.center);
                        },
                      ),
                      const SizedBox(width: 12),
                      _AlignmentButton(
                        icon: Icons.format_align_right_rounded,
                        isSelected:
                            typography.textAlignMode == TextAlignMode.right,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          typographyNotifier
                              .setTextAlignMode(TextAlignMode.right);
                        },
                      ),
                      const SizedBox(width: 12),
                      _AlignmentButton(
                        icon: Icons.format_align_justify_rounded,
                        isSelected:
                            typography.textAlignMode == TextAlignMode.justified,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          typographyNotifier
                              .setTextAlignMode(TextAlignMode.justified);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.font_download_rounded,
                          size: 16, color: iconColor),
                      const SizedBox(width: 8),
                      Text('FONT FAMILY', style: sectionLabelStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: fonts.length,
                    itemBuilder: (context, index) {
                      final font = fonts[index];
                      final isSelected = typography.fontFamily == font;
                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          typographyNotifier.setFontFamily(font);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            font,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: font,
                              color: isSelected
                                  ? theme.colorScheme.surface
                                  : theme.primaryColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlignmentButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlignmentButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? theme.colorScheme.surface : theme.primaryColor,
        ),
      ),
    );
  }
}

class _ContextMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  const _ContextMenuButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.onLongPress,
      this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color != null
                  ? color!.withValues(alpha: 0.15)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: color ?? theme.colorScheme.onSurface, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class VerseActionLogic {
  static void _showFeedback(
      BuildContext context, ThemeData theme, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onInverseSurface,
                fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showHighlightPaletteModal(
      BuildContext context,
      ThemeData theme,
      WidgetRef ref,
      String bookName,
      int chapterNum,
      List<int> targetVerses,
      VoidCallback onClearSelection) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose Highlight Color',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(highlightPalette.length, (i) {
                  final color = AppColors.getRenderedHighlightColor(
                      highlightPaletteSwatches[i],
                      theme.brightness,
                      theme.scaffoldBackgroundColor);
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(readSettingsProvider.notifier)
                          .setActiveHighlightColorIndex(i);
                      VerseActionLogic.handleHighlight(ctx, theme, ref,
                          bookName, chapterNum, targetVerses, i);
                      Navigator.of(ctx).pop();
                      onClearSelection();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.black.withValues(alpha: 0.2),
                                width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1)
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(highlightPaletteNames[i],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            )),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  static void handleHighlightInteraction({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeData theme,
    required String bookName,
    required int chapterNum,
    required List<int> targetVerses,
    required bool isLongPress,
    required VoidCallback onClearSelection,
  }) {
    final primaryIndex =
        ref.read(readSettingsProvider).primaryHighlightColorIndex;

    if (primaryIndex == -1 || isLongPress) {
      showHighlightPaletteModal(context, theme, ref, bookName, chapterNum,
          targetVerses, onClearSelection);
    } else {
      // Guard against invalid array accesses for primaryIndex if it somehow became out of bounds (but not -1)
      final safeIndex =
          (primaryIndex >= 0 && primaryIndex < highlightPalette.length)
              ? primaryIndex
              : 0;
      handleHighlight(
          context, theme, ref, bookName, chapterNum, targetVerses, safeIndex);
      onClearSelection();
    }
  }

  static void handleHighlight(
      BuildContext context,
      ThemeData theme,
      WidgetRef ref,
      String canonicalBookName,
      int chapterNum,
      List<int> targetVerses,
      int activeIndex) {
    if (kHighlightDebug) {
      debugPrint(
          '[HIGHLIGHT_DEBUG] WRITE handleHighlight: canonicalBookName=$canonicalBookName, chapterNum=$chapterNum, targetVerses=$targetVerses, activeIndex=$activeIndex');
    }
    bool isRemoving = targetVerses.every((v) {
      final refStr = generateVerseKey(canonicalBookName, chapterNum, v);
      return ref.read(highlightsProvider)[refStr] == activeIndex;
    });

    for (var v in targetVerses) {
      final refStr = generateVerseKey(canonicalBookName, chapterNum, v);
      if (kHighlightDebug) {
        debugPrint('[HIGHLIGHT_DEBUG] WRITE key=$refStr color=$activeIndex');
      }
      ref
          .read(highlightsProvider.notifier)
          .toggleHighlight(refStr, activeIndex);
    }
    if (kHighlightDebug) {
      debugPrint(
          '[HIGHLIGHT_DEBUG] MAP after write: ${ref.read(highlightsProvider)}');
    }
    final count = targetVerses.length;
    _showFeedback(
        context,
        theme,
        isRemoving
            ? '$count Highlight(s) removed'
            : '$count verse(s) highlighted');
  }

  static void handleBookmark(
      BuildContext context,
      ThemeData theme,
      WidgetRef ref,
      String canonicalBookName,
      int chapterNum,
      List<int> targetVerses) {
    final isAllBookmarked = targetVerses.every((v) => ref
        .read(bookmarksProvider)
        .contains(generateVerseKey(canonicalBookName, chapterNum, v)));
    for (var v in targetVerses) {
      final refStr = generateVerseKey(canonicalBookName, chapterNum, v);
      if (isAllBookmarked) {
        ref.read(bookmarksProvider.notifier).toggle(refStr);
      } else if (!ref.read(bookmarksProvider).contains(refStr)) {
        ref.read(bookmarksProvider.notifier).toggle(refStr);
      }
    }
    _showFeedback(
        context,
        theme,
        isAllBookmarked
            ? '${targetVerses.length} verse(s) removed from bookmarks'
            : '${targetVerses.length} verse(s) bookmarked!');
  }

  static Future<void> handleNote(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      String bookName,
      int chapterNum,
      List<int> targetVerses) async {
    final sorted = targetVerses.toList()..sort();
    final refStr = '$bookName $chapterNum:${sorted.join(', ')}';
    await showAddNoteSheet(context, ref, theme, initialReference: refStr);
  }

  static dynamic getChapterData(
      WidgetRef ref, String bookName, int chapterNum) {
    final flatChapters = ref.read(flatChaptersProvider);
    if (flatChapters.isNotEmpty) {
      try {
        return flatChapters
            .firstWhere(
              (c) => c.book.name == bookName && c.chapter.number == chapterNum,
              orElse: () => flatChapters.first,
            )
            .chapter;
      } catch (_) {}
    }
    return null;
  }

  static void handleCopy(BuildContext context, WidgetRef ref, String bookName,
      int chapterNum, List<int> targetVerses) {
    final chapterData = getChapterData(ref, bookName, chapterNum);
    final text = ShareService.formatVerses(
        bookName: bookName,
        chapterNumber: chapterNum,
        verseNumbers: targetVerses,
        chapterData: chapterData);
    ShareService.copyText(context, text);
  }

  static void handleCommentary(
      BuildContext context,
      WidgetRef ref,
      String bookName,
      int chapterNum,
      int verseNumberFallback,
      List<int> targetVerses) {
    final sorted = targetVerses.toList()..sort();
    final firstVerse = sorted.isNotEmpty ? sorted.first : verseNumberFallback;
    showCommentaryBottomSheet(
      context,
      book: bookName,
      chapter: chapterNum,
      verse: firstVerse,
    );
  }

  static Future<void> handleShare(BuildContext context, WidgetRef ref,
      String bookName, int chapterNum, List<int> targetVerses) async {
    final chapterData = getChapterData(ref, bookName, chapterNum);
    final text = ShareService.formatVerses(
        bookName: bookName,
        chapterNumber: chapterNum,
        verseNumbers: targetVerses,
        chapterData: chapterData);
    await ShareService.shareText(body: text);
  }
}

class VerseContextMenuContent extends ConsumerStatefulWidget {
  final int verseNumber;
  final dynamic chapterData;
  final String bookName;
  final int chapterNum;
  final String bookAbbrev;
  final VoidCallback onDismiss;

  const VerseContextMenuContent({
    super.key,
    required this.verseNumber,
    required this.chapterData,
    required this.bookName,
    required this.chapterNum,
    required this.bookAbbrev,
    required this.onDismiss,
  });

  @override
  ConsumerState<VerseContextMenuContent> createState() =>
      _VerseContextMenuContentState();
}

class _VerseContextMenuContentState
    extends ConsumerState<VerseContextMenuContent> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ref.read(hintsProvider.notifier).maybeShowHint('highlight_long_press',
          () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Long-press Highlight to change color'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    });

    ref.listen(readSelectionProvider, (previous, next) {
      if (previous != null && previous.isNotEmpty && next.isEmpty) {
        widget.onDismiss();
      }
    });

    final verseKey = generateVerseKey(
        widget.bookAbbrev, widget.chapterNum, widget.verseNumber);
    final selectedVerses = ref.watch(readSelectionProvider);
    final targetVerses = selectedVerses.isNotEmpty
        ? selectedVerses.toList()
        : [widget.verseNumber];

    final isBookmarked = ref.watch(bookmarksProvider).contains(verseKey);
    final hasNote =
        ref.watch(notesProvider).any((n) => n.reference == verseKey);
    final isHighlighted = ref.watch(highlightsProvider).containsKey(verseKey);
    final theme = Theme.of(context);

    final commentaryNotifier = ref.read(commentaryProvider.notifier);
    final bool hasCommentary = targetVerses.any((v) => commentaryNotifier
        .commentaryForVerse(widget.bookName, widget.chapterNum, v)
        .isNotEmpty);

    // Default icon row
    final actionButtons = [
      _ContextMenuButton(
          icon: isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          label: isBookmarked ? 'Saved' : 'Bookmark',
          color: isBookmarked ? theme.primaryColor : null,
          onTap: () {
            VerseActionLogic.handleBookmark(context, theme, ref,
                widget.bookName, widget.chapterNum, targetVerses);
            widget.onDismiss();
          }),
      _ContextMenuButton(
          icon: Icons.edit_document,
          label: hasNote ? 'Edit Note' : 'Note',
          color: hasNote ? Colors.blue.shade600 : null,
          onTap: () {
            widget.onDismiss();
            VerseActionLogic.handleNote(context, ref, theme, widget.bookName,
                widget.chapterNum, targetVerses);
          }),
      _ContextMenuButton(
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: () {
            widget.onDismiss();
            VerseActionLogic.handleCopy(
                context, ref, widget.bookName, widget.chapterNum, targetVerses);
          }),
      if (hasCommentary)
        _ContextMenuButton(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Commentary',
            onTap: () {
              widget.onDismiss();
              VerseActionLogic.handleCommentary(context, ref, widget.bookName,
                  widget.chapterNum, widget.verseNumber, targetVerses);
            }),
      _ContextMenuButton(
          icon: Icons.ios_share_rounded,
          label: 'Share',
          onTap: () {
            widget.onDismiss();
            VerseActionLogic.handleShare(
                context, ref, widget.bookName, widget.chapterNum, targetVerses);
          }),
    ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
          child: TexturedGlassContainer(
            borderRadius: BorderRadius.circular(32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedVerses.isNotEmpty
                            ? '${selectedVerses.length} verse${selectedVerses.length > 1 ? 's' : ''} selected'
                            : '${widget.bookName} ${widget.chapterNum}:${widget.verseNumber}',
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleSmall?.color
                                ?.withValues(alpha: 0.7)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: widget.onDismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _ContextMenuButton(
                          icon: Icons.highlight_rounded,
                          label: isHighlighted ? 'Highlighted' : 'Highlight',
                          color: isHighlighted ? Colors.amber.shade600 : null,
                          onTap: () {
                            VerseActionLogic.handleHighlightInteraction(
                              context: context,
                              ref: ref,
                              theme: theme,
                              bookName: widget.bookName,
                              chapterNum: widget.chapterNum,
                              targetVerses: targetVerses,
                              isLongPress: false,
                              onClearSelection: widget.onDismiss,
                            );
                          },
                          onLongPress: () {
                            VerseActionLogic.handleHighlightInteraction(
                              context: context,
                              ref: ref,
                              theme: theme,
                              bookName: widget.bookName,
                              chapterNum: widget.chapterNum,
                              targetVerses: targetVerses,
                              isLongPress: true,
                              onClearSelection: widget.onDismiss,
                            );
                          }),
                      ...actionButtons,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
