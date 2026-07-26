import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data/models/bible_model.dart';
import '../../state/bible_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/study_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../state/user_data_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../../services/share_service.dart';
import '../widgets/verse_link_text.dart';
import '../widgets/shared_top_header.dart';
import '../../data/models/commentary_model.dart';

import '../../state/theme_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/immersive_mode_provider.dart';
import '../../state/read_selection_provider.dart';
import '../../state/bible_nav_settings_provider.dart';
import '../../state/read_location_provider.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/bouncy_entrance.dart';
import '../../state/nav_settings_provider.dart';
import 'commentary_list_screen.dart';

class ReadScreen extends ConsumerStatefulWidget {
  const ReadScreen({super.key});

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen> {

  late PageController _pageController;
  bool _isPageControllerInitialized = false;
  int _currentPageIndex = 0;
  final Map<int, ItemScrollController> _itemScrollControllers = {};
  final Map<int, ItemPositionsListener> _itemPositionsListeners = {};
  int? _navigatedVerseIndex;
  Timer? _scrollDebounceTimer;

  @override
  void dispose() {
    if (_isPageControllerInitialized) {
      _pageController.dispose();
    }
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
      
      final targetIndex = flatChapters.indexWhere((fc) => fc.book.abbreviation == loc.bookAbbrev && fc.chapter.number == loc.chapter);
      if (targetIndex != -1) {
        final controller = _itemScrollControllers[targetIndex];
        if (controller != null && controller.isAttached) {
          controller.scrollTo(
            index: verse - 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: 0.15, // Account for top header
          );
          // Highlight it faintly upon jumping
          if (mounted) {
            setState(() {
              _navigatedVerseIndex = verse - 1;
            });
          }
        } else if (retries < 20) {
          Future.delayed(const Duration(milliseconds: 50), () => tryScroll(retries + 1));
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
      builder: (context) => const _TypographyBottomSheet(),
    );
  }

  void _showSelectorBottomSheet(List<BibleBook> allBooks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) {
        final loc = ref.read(readLocationProvider);
        return _BookChapterSelectorSheet(
          books: allBooks,
          selectedBookAbbrev: loc.bookAbbrev,
          selectedChapter: loc.chapter,
          onSelectionChanged: (abbrev, name, chapter, verse, {bool autoClose = true}) {
            bool changedChapter = loc.bookAbbrev != abbrev || loc.chapter != chapter;
            ref.read(readLocationProvider.notifier).updateLocation(
              bookAbbrev: abbrev,
              bookName: name,
              chapter: chapter,
            );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final isDark = appThemeMode == AppThemeMode.dark;
    final typography = ref.watch(typographyProvider);
    final readSettings = ref.watch(readSettingsProvider);
    final selectedVerses = ref.watch(readSelectionProvider);
    final isImmersive = ref.watch(immersiveModeProvider);
    final commentaryDataAsync = ref.watch(combinedCommentaryProvider);

    final bibleState = ref.watch(bibleProvider);
    final isLoading = bibleState.isLoading;
    final allBooks = bibleState.books;

    final flatChapters = ref.watch(flatChaptersProvider);
    final loc = ref.watch(readLocationProvider);

    if (flatChapters.isNotEmpty) {
      final targetIndex = flatChapters.indexWhere((fc) => fc.book.abbreviation == loc.bookAbbrev && fc.chapter.number == loc.chapter);
      final safeTarget = targetIndex != -1 ? targetIndex : 0;
      if (!_isPageControllerInitialized) {
        _pageController = PageController(initialPage: safeTarget);
        _isPageControllerInitialized = true;
        _currentPageIndex = safeTarget;
      } else if (!_pageController.hasClients && _pageController.initialPage != safeTarget) {
        _pageController = PageController(initialPage: safeTarget);
        _currentPageIndex = safeTarget;
      }
    }

    ref.listen<ReadLocationState>(readLocationProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (flatChapters.isNotEmpty && _isPageControllerInitialized) {
          final targetIndex = flatChapters.indexWhere((fc) => fc.book.abbreviation == next.bookAbbrev && fc.chapter.number == next.chapter);
          if (targetIndex != -1 && _pageController.hasClients) {
            final currentPage = _pageController.page?.round() ?? 0;
            if (currentPage != targetIndex) {
              if ((currentPage - targetIndex).abs() == 1) {
                _pageController.animateToPage(targetIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
              final book = allBooks.firstWhere((b) => b.abbreviation == next.bookAbbrev, orElse: () => allBooks.first);
              final chapter = book.chapters.firstWhere((c) => c.number == next.chapter, orElse: () => book.chapters.first);
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

    if (flatChapters.isNotEmpty && _currentPageIndex >= 0 && _currentPageIndex < flatChapters.length) {
      final fc = flatChapters[_currentPageIndex];
      currentBookName = fc.book.name;
      currentChapter = fc.chapter.number;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
                              controller: _pageController,
                              itemCount: flatChapters.length,
                              onPageChanged: (pageIndex) {
                                setState(() {
                                  _currentPageIndex = pageIndex;
                                });
                                final fc = flatChapters[pageIndex];
                                final currentLoc = ref.read(readLocationProvider);
                                if (currentLoc.bookAbbrev != fc.book.abbreviation || currentLoc.chapter != fc.chapter.number) {
                                  ref.read(readLocationProvider.notifier).updateLocation(
                                    bookAbbrev: fc.book.abbreviation,
                                    bookName: fc.book.name,
                                    chapter: fc.chapter.number,
                                  );
                                }
                                _clearSelection();
                              },
                              itemBuilder: (context, pageIndex) {
                                final fc = flatChapters[pageIndex];
                                final verses = fc.chapter.verses;
                                _itemScrollControllers[pageIndex] ??= ItemScrollController();
                                if (!_itemPositionsListeners.containsKey(pageIndex)) {
                                  final listener = ItemPositionsListener.create();
                                  _itemPositionsListeners[pageIndex] = listener;
                                  listener.itemPositions.addListener(() {
                                    final positions = listener.itemPositions.value;
                                    if (positions.isNotEmpty) {
                                      final firstVisible = positions.where((p) => p.itemTrailingEdge > 0).reduce((min, p) => p.itemLeadingEdge < min.itemLeadingEdge ? p : min);
                                      if (firstVisible.index < verses.length) {
                                        _scrollDebounceTimer?.cancel();
                                        _scrollDebounceTimer = Timer(const Duration(milliseconds: 500), () {
                                          if (!mounted) return;
                                          final currentBookName = fc.book.name;
                                          final currentChapter = fc.chapter.number;
                                          final currentAbbrev = fc.book.abbreviation;
                                          final prefs = ref.read(preferencesProvider);
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
                                      }
                                    }
                                  });
                                }
                                
                                return GestureDetector(
                                  onTap: () {
                                    if (selectedVerses.isNotEmpty) {
                                      _clearSelection();
                                    }
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: NotificationListener<UserScrollNotification>(
                                    onNotification: (notification) {
                                      final alwaysShow = ref.read(navSettingsProvider).alwaysShowNav;
                                      if (alwaysShow) return false;

                                      if (notification.direction == ScrollDirection.reverse) {
                                        if (!isImmersive) {
                                          Future.microtask(() => ref.read(immersiveModeProvider.notifier).set(true));
                                        }
                                      } else if (notification.direction == ScrollDirection.forward) {
                                        if (isImmersive) {
                                          Future.microtask(() => ref.read(immersiveModeProvider.notifier).set(false));
                                        }
                                      }
                                      return false;
                                    },
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 800),
                                        child: ScrollablePositionedList.builder(
                                          itemScrollController: _itemScrollControllers[pageIndex],
                                          itemPositionsListener: _itemPositionsListeners[pageIndex],
                                          initialScrollIndex: (pageIndex == _currentPageIndex ? _navigatedVerseIndex : null) ?? ref.read(preferencesProvider).getChapterScrollPosition(fc.book.abbreviation, fc.chapter.number) ?? 0,
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context).padding.top + 80.0,
                                              left: 24.0, right: 24.0, bottom: 400.0),
                                          itemCount: verses.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index == verses.length) {
                                              bool hasChapterCommentary = false;
                                              commentaryDataAsync.whenData((state) {
                                                final bookCommentary = state.data[fc.book.name];
                                                if (bookCommentary != null) {
                                                  final chapterCommentary = bookCommentary[fc.chapter.number.toString()];
                                                  if (chapterCommentary != null && chapterCommentary.isNotEmpty) {
                                                    hasChapterCommentary = true;
                                                  }
                                                }
                                              });
                                              return _buildEndOfChapterBlock(fc, pageIndex, theme, hasChapterCommentary);
                                            }
                                            final verse = verses[index];
                                            final isSelected = selectedVerses.contains(index);
                                            final isSelectionMode = selectedVerses.isNotEmpty;
                                            
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                // Check for commentary
                                                AnimatedOpacity(
                                                  duration: const Duration(milliseconds: 250),
                                                  opacity: (isSelectionMode && !isSelected) ? 0.25 : 1.0,
                                                  child: Builder(
                                                  builder: (context) {
                                                    bool hasCommentary = false;
                                                    commentaryDataAsync.whenData((state) {
                                                      final bookCommentary = state.data[fc.book.name];
                                                      if (bookCommentary != null) {
                                                        final chapterCommentary = bookCommentary[fc.chapter.number.toString()];
                                                        if (chapterCommentary != null) {
                                                          final targetVerse = verse.number;
                                                          for (final key in chapterCommentary.keys) {
                                                            if (key == targetVerse.toString()) {
                                                              hasCommentary = true;
                                                              break;
                                                            } else if (key.contains('-')) {
                                                              final parts = key.split('-');
                                                              if (parts.length == 2) {
                                                                final start = int.tryParse(parts[0]);
                                                                final end = int.tryParse(parts[1]);
                                                                if (start != null && end != null && targetVerse >= start && targetVerse <= end) {
                                                                  hasCommentary = true;
                                                                  break;
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    });
                                                    
                                                    final highlights = ref.watch(highlightsProvider);
                                                    final refStr = generateVerseKey(fc.book.name, fc.chapter.number, verse.number);
                                                    final savedColorIndex = highlights[refStr];
                                                    Color? highlightColor;
                                                    if (savedColorIndex != null && savedColorIndex >= 0 && savedColorIndex < highlightPalette.length) {
                                                      highlightColor = highlightPalette[savedColorIndex];
                                                    }

                                                return GestureDetector(
                                                  onTap: () => _toggleVerseSelection(index),
                                                  onLongPress: () {
                                                    _showVerseContextMenu(
                                                      context,
                                                      verse.number,
                                                      fc.chapter,
                                                      fc.book.name,
                                                      fc.chapter.number
                                                    );
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      AnimatedContainer(
                                                        duration:
                                                            const Duration(milliseconds: 250),
                                                        padding: const EdgeInsets.only(
                                                            top: 6.0,
                                                            bottom: 6.0,
                                                            left: 15.0,  // extra left space for accent bar
                                                            right: 12.0),
                                                        decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? (isDark
                                                                  ? Colors.amber.withValues(alpha: 0.20)
                                                                  : Colors.amber.withValues(alpha: 0.15))
                                                              : (_navigatedVerseIndex == index
                                                                  ? (isDark
                                                                      ? Colors.amber.withValues(alpha: 0.15)
                                                                      : Colors.amber.withValues(alpha: 0.10))
                                                                  : (highlightColor != null
                                                                      ? highlightColor.withValues(alpha: isDark ? 0.20 : 0.15)
                                                                      : Colors.transparent)),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: _buildNormalVerse(
                                                          verse,
                                                          theme,
                                                          typography,
                                                          appThemeMode,
                                                          hasCommentary: hasCommentary,
                                                          onCommentaryTap: () => _showCommentaryBottomSheet(verse.number, verse.text),
                                                        ),
                                                      ),
                                                      // Left accent bar — only visible when selected
                                                      if (isSelected)
                                                        Positioned(
                                                          left: 4,
                                                          top: 10,
                                                          bottom: 10,
                                                          child: Container(
                                                            width: 4.0,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(4),
                                                              gradient: LinearGradient(
                                                                begin: Alignment.topCenter,
                                                                end: Alignment.bottomCenter,
                                                                colors: [
                                                                  theme.primaryColor.withValues(alpha: 0.3),
                                                                  theme.primaryColor,
                                                                  theme.primaryColor.withValues(alpha: 0.3),
                                                                ],
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: theme.primaryColor.withValues(alpha: 0.2),
                                                                  blurRadius: 4,
                                                                  offset: const Offset(1, 0),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                  ),
                                );
                              },
                            ),
                ),
                // Top Navigation Bar Layer (Floating above text)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 350),
                    offset: (isImmersive && readSettings.readingViewMode == ReadingViewMode.immersive) ? const Offset(0, -1) : Offset.zero,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: (isImmersive && readSettings.readingViewMode == ReadingViewMode.immersive) ? 0.0 : 1.0,
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                          child: Container(
                            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
                            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 12),
                                // Top Navigation Bar
                                Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: SharedTopHeader(
                                    leading: GestureDetector(
                                      onTap: () {
                                        ref.read(navProvider.notifier).setIndex(0);
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Center(
                                        child: Icon(
                                          Icons.book_rounded,
                                          size: 26,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    centerContent: GestureDetector(
                                      onTap: () {
                                        if (isImmersive) {
                                          ref.read(immersiveModeProvider.notifier).set(false);
                                        } else {
                                          _showSelectorBottomSheet(allBooks);
                                        }
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surface.withValues(alpha: 0.6),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: ConstrainedBox(
                                                      constraints: const BoxConstraints(maxWidth: 180),
                                                      child: MediaQuery(
                                                        data: MediaQuery.of(context).copyWith(
                                                          textScaler: const TextScaler.linear(1.0),
                                                        ),
                                                        child: Text(
                                                          '$currentBookName $currentChapter',
                                                          style: theme.textTheme.titleSmall?.copyWith(
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: (theme.textTheme.titleSmall?.fontSize ?? 14).clamp(12.0, 18.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(Icons.keyboard_arrow_down_rounded, 
                                                  size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      trailing: GestureDetector(
                                      onTap: _showTypographyBottomSheet,
                                      behavior: HitTestBehavior.opaque,
                                      child: Center(
                                        child: Text(
                                          'aA',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                            letterSpacing: -1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
          ),


        ],
      ),
    );
  }



  void _showVerseContextMenu(BuildContext context, int verseNumber, dynamic chapterData, String bookName, int chapterNum) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: TexturedGlassContainer(
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$bookName $chapterNum:$verseNumber',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleSmall?.color?.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ContextMenuButton(
                          icon: Icons.copy_rounded,
                          label: 'Copy',
                          onTap: () {
                            Navigator.of(ctx).pop();
                            final text = ShareService.formatVerses(
                                bookName: bookName,
                                chapterNumber: chapterNum,
                                verseNumbers: [verseNumber],
                                chapterData: chapterData);
                            ShareService.copyText(context, text);
                          }
                        ),
                        const SizedBox(width: 40),
                        _ContextMenuButton(
                          icon: Icons.ios_share_rounded,
                          label: 'Share',
                          onTap: () {
                            Navigator.of(ctx).pop();
                            final text = ShareService.formatVerses(
                                bookName: bookName,
                                chapterNumber: chapterNum,
                                verseNumbers: [verseNumber],
                                chapterData: chapterData);
                            ShareService.shareText(body: text);
                          }
                        ),
                      ],
                    )
                  ]
                )
              )
            )
          )
        );
      }
    );
  }

  void _showCommentaryBottomSheet(int verseNumber, String verseText) {
    if (!mounted) return;
    final loc = ref.read(readLocationProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _CommentaryBottomSheetContent(
          bookName: loc.bookName,
          chapter: loc.chapter,
          verseNumber: verseNumber,
          verseText: verseText,
        );
      },
    );
  }

  Widget _buildNormalVerse(BibleVerse verse, ThemeData theme, TypographyState typography, AppThemeMode appThemeMode, {bool hasCommentary = false, VoidCallback? onCommentaryTap}) {
    final fontStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.6,
      letterSpacing: 0.15,
      color: theme.textTheme.bodyLarge?.color,
    );

    Color starColor;
    switch (appThemeMode) {
      case AppThemeMode.light:
        starColor = Colors.deepOrange.shade400;
        break;
      case AppThemeMode.sepia:
        starColor = Colors.deepOrange.shade600;
        break;
      case AppThemeMode.dark:
        starColor = Colors.amberAccent;
        break;
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${verse.number}  ',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 17.5) * 0.75, // Scale number down
            ),
          ),
          TextSpan(
            text: verse.text,
            style: fontStyle,
          ),
          if (hasCommentary)
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: GestureDetector(
                onTap: onCommentaryTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  // Generous padding increases the invisible tap target area for all finger sizes
                  padding: const EdgeInsets.only(left: 4.0, right: 8.0, top: 2.0, bottom: 8.0),
                  child: Icon(
                    Icons.star_rounded,
                    color: starColor,
                    size: typography.fontSize * 0.85, // Slightly larger star for visibility
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEndOfChapterBlock(FlatChapter fc, int pageIndex, ThemeData theme, bool hasChapterCommentary) {
    final flatChapters = ref.read(flatChaptersProvider);
    final hasPrevious = pageIndex > 0;
    final hasNext = pageIndex < flatChapters.length - 1;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 80.0, bottom: 120.0), // Above nav pill
      child: Column(
        children: [
          // Divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
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
              Container(width: 40, height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            ],
          ),
          const SizedBox(height: 32),
          
          // Commentary Button
          TextButton.icon(
            onPressed: hasChapterCommentary ? () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CommentaryListScreen(
                  bookName: fc.book.name,
                  chapterNumber: fc.chapter.number.toString(),
                ),
              ));
            } : null,
            icon: Icon(Icons.school_rounded, color: hasChapterCommentary ? theme.primaryColor : theme.disabledColor),
            label: Text(
              'Read commentary on this chapter',
              style: theme.textTheme.titleSmall?.copyWith(
                color: hasChapterCommentary ? theme.colorScheme.onSurface : theme.disabledColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    _pageController.animateToPage(pageIndex - 1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('‹ Previous', style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor)),
                )
              else
                const SizedBox(width: 100),

              const SizedBox(width: 24),

              if (hasNext)
                TextButton(
                  onPressed: () {
                    _pageController.animateToPage(pageIndex + 1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Next ›', style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor)),
                )
              else
                const SizedBox(width: 100),
            ],
          ),
        ],
      ),
    );
  }
}


enum SelectionMode { testament, book, chapter, verse }

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

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

  void init(BibleBook book, int chapter, bool isOldTestament, SelectionMode mode) {
    state = _SheetState(book: book, chapter: chapter, isOldTestament: isOldTestament, mode: mode);
  }

  void setTestament(bool isOld) {
    state = state.copyWith(isOldTestament: isOld, mode: SelectionMode.book);
  }

  void setBook(BibleBook book) {
    state = state.copyWith(book: book, chapter: 1, clearVerse: true, mode: SelectionMode.chapter);
  }

  void setChapter(int chapter, bool advanceToVerse) {
    state = state.copyWith(chapter: chapter, verse: 1, mode: advanceToVerse ? SelectionMode.verse : state.mode);
  }

  void setVerse(int verse) {
    state = state.copyWith(verse: verse);
  }

  void setMode(SelectionMode mode) {
    state = state.copyWith(mode: mode);
  }
}

final _sheetStateProvider = NotifierProvider.autoDispose<_SheetNotifier, _SheetState>(_SheetNotifier.new);

class _BookChapterSelectorSheet extends ConsumerStatefulWidget {
  final List<BibleBook> books;
  final String selectedBookAbbrev;
  final int selectedChapter;
  final void Function(String abbrev, String name, int chapter, int? verse, {bool autoClose}) onSelectionChanged;

  const _BookChapterSelectorSheet({
    required this.books,
    required this.selectedBookAbbrev,
    required this.selectedChapter,
    required this.onSelectionChanged,
  });

  @override
  ConsumerState<_BookChapterSelectorSheet> createState() => __BookChapterSelectorSheetState();
}

class __BookChapterSelectorSheetState extends ConsumerState<_BookChapterSelectorSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialBook = widget.books.firstWhere((b) => b.abbreviation == widget.selectedBookAbbrev, orElse: () => widget.books.first);
      final bookIndex = widget.books.indexOf(initialBook);
      final isOldTestament = bookIndex < 39;
      final settings = ref.read(bibleNavSettingsProvider);
      final mode = settings.depth == NavigationDepth.fourPart ? SelectionMode.testament : SelectionMode.book;
      
      ref.read(_sheetStateProvider.notifier).init(initialBook, widget.selectedChapter, isOldTestament, mode);
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
    final isInitialized = ref.watch(_sheetStateProvider.select((s) => s.book != null));

    if (!isInitialized) {
      return const SizedBox.shrink();
    }

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
              final isOld = ref.watch(_sheetStateProvider.select((s) => s.isOldTestament));
              final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
              return _buildBreadcrumbSegment('Testament', isOld ? 'OT' : 'NT', SelectionMode.testament, mode, theme);
            }),
          Consumer(builder: (context, ref, _) {
            final bookName = ref.watch(_sheetStateProvider.select((s) => s.book!.name));
            final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
            return _buildBreadcrumbSegment('Book', bookName, SelectionMode.book, mode, theme);
          }),
          Consumer(builder: (context, ref, _) {
            final chapter = ref.watch(_sheetStateProvider.select((s) => s.chapter));
            final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
            return _buildBreadcrumbSegment('Chapter', '$chapter', SelectionMode.chapter, mode, theme);
          }),
          if (settings.depth != NavigationDepth.twoPart)
            Consumer(builder: (context, ref, _) {
              final verse = ref.watch(_sheetStateProvider.select((s) => s.verse));
              final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
              return _buildBreadcrumbSegment('Verse', verse != null ? '$verse' : '1', SelectionMode.verse, mode, theme);
            }),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbSegment(String label, String value, SelectionMode targetMode, SelectionMode currentMode, ThemeData theme) {
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
                ? [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Column(
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: isSelected ? Colors.white.withValues(alpha: 0.8) : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
    final isOldTestament = ref.watch(_sheetStateProvider.select((s) => s.isOldTestament));
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

    switch (settings.layout) {
      case TestamentLayout.filterTabs:
        final isOldTestament = ref.watch(_sheetStateProvider.select((s) => s.isOldTestament));
        final displayedBooks = isOldTestament ? oldTestamentBooks : newTestamentBooks;
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref.read(_sheetStateProvider.notifier).setTestament(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isOldTestament ? theme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Old Testament',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isOldTestament ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref.read(_sheetStateProvider.notifier).setTestament(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isOldTestament ? theme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'New Testament',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !isOldTestament ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(builder: (context, ref, _) {
                final selectedBookAbbrev = ref.watch(_sheetStateProvider.select((s) => s.book!.abbreviation));
                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
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
                    );
                  },
                );
              }),
            ),
          ],
        );
      case TestamentLayout.sideBySide:
        return Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Old Testament', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Consumer(builder: (context, ref, _) {
                      final selectedBookAbbrev = ref.watch(_sheetStateProvider.select((s) => s.book!.abbreviation));
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: oldTestamentBooks.length,
                        itemExtent: 56,
                        itemBuilder: (context, index) {
                          final book = oldTestamentBooks[index];
                          final isSel = book.abbreviation == selectedBookAbbrev;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
                            child: _buildGridTile(text: book.name, isSelected: isSel, onTap: () => _onBookSelected(book, settings), theme: theme),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            Container(width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1), margin: const EdgeInsets.symmetric(horizontal: 8)),
            Expanded(
              child: Column(
                children: [
                  Text('New Testament', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Consumer(builder: (context, ref, _) {
                      final selectedBookAbbrev = ref.watch(_sheetStateProvider.select((s) => s.book!.abbreviation));
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: newTestamentBooks.length,
                        itemExtent: 56,
                        itemBuilder: (context, index) {
                          final book = newTestamentBooks[index];
                          final isSel = book.abbreviation == selectedBookAbbrev;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                            child: _buildGridTile(text: book.name, isSelected: isSel, onTap: () => _onBookSelected(book, settings), theme: theme),
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
      case TestamentLayout.stickySections:
        return Consumer(builder: (context, ref, _) {
          final selectedBookAbbrev = ref.watch(_sheetStateProvider.select((s) => s.book!.abbreviation));
          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  child: Container(
                    color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Old Testament', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ),
                ),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisExtent: 48,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = oldTestamentBooks[index];
                    final isSel = book.abbreviation == selectedBookAbbrev;
                    return _buildGridTile(text: book.name, isSelected: isSel, onTap: () => _onBookSelected(book, settings), theme: theme);
                  },
                  childCount: oldTestamentBooks.length,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  child: Container(
                    color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 24, bottom: 8),
                    child: Text('New Testament', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ),
                ),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisExtent: 48,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = newTestamentBooks[index];
                    final isSel = book.abbreviation == selectedBookAbbrev;
                    return _buildGridTile(text: book.name, isSelected: isSel, onTap: () => _onBookSelected(book, settings), theme: theme);
                  },
                  childCount: newTestamentBooks.length,
                ),
              ),
            ],
          );
        });
    }
  }

  Widget _buildChapterSelection(ThemeData theme, BibleNavSettingsState settings) {
    final book = ref.read(_sheetStateProvider).book!;
    final chapters = book.chapters.length;

    return Consumer(builder: (context, ref, _) {
      final selectedChapter = ref.watch(_sheetStateProvider.select((s) => s.chapter));
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 24),
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
    final chapterData = book.chapters.firstWhere((c) => c.number == selectedChapter, orElse: () => book.chapters.first);
    final verses = chapterData.verses.length;
    
    return Consumer(builder: (context, ref, _) {
      final selectedVerse = ref.watch(_sheetStateProvider.select((s) => s.verse));
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 24),
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

  Widget _buildGridTile({required String text, required bool isSelected, required VoidCallback onTap, required ThemeData theme}) {
    if (!isSelected) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: (text.length > 3 ? theme.textTheme.labelMedium : theme.textTheme.titleMedium)?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
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
          boxShadow: [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Text(
          text,
          style: (text.length > 3 ? theme.textTheme.labelMedium : theme.textTheme.titleMedium)?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
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

    final fonts = ['Inter', 'Gentium Book Plus', 'Lora', 'Literata'];

    return BouncyEntrance(
      delay: const Duration(milliseconds: 50),
      child: Material(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handlebar
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
              const SizedBox(height: 24),
              Text(
                'Typography',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Radial Balance: Color Mode Toggles
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColorModeToggle(context, ref, AppThemeMode.light, Icons.light_mode),
                    const SizedBox(width: 24),
                    _buildColorModeToggle(context, ref, AppThemeMode.sepia, Icons.auto_awesome),
                    const SizedBox(width: 24),
                    _buildColorModeToggle(context, ref, AppThemeMode.dark, Icons.dark_mode),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'FONT SIZE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.primaryColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('A', style: theme.textTheme.labelSmall),
                  Expanded(
                    child: Slider(
                      value: typography.fontSize,
                      min: 12.0,
                      max: 28.0,
                      activeColor: theme.primaryColor,
                      inactiveColor: theme.primaryColor.withValues(alpha: 0.2),
                      onChanged: (value) => typographyNotifier.setFontSize(value),
                    ),
                  ),
                  Text('A', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'FONT FAMILY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.primaryColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: fonts.length,
                itemBuilder: (context, index) {
                  final font = fonts[index];
                  final isSelected = typography.fontFamily == font;
                  
                  return InkWell(
                    onTap: () => typographyNotifier.setFontFamily(font),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? theme.primaryColor.withValues(alpha: 0.15) 
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? theme.primaryColor 
                              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        font,
                        style: GoogleFonts.getFont(font).copyWith(
                          color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildColorModeToggle(
      BuildContext context, WidgetRef ref, AppThemeMode mode, IconData icon) {
    final currentMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isSelected = currentMode == mode;
    final theme = Theme.of(context);

    Color bgColor;
    Color iconColor;
    if (mode == AppThemeMode.light) {
      bgColor = Colors.white;
      iconColor = Colors.orangeAccent;
    } else if (mode == AppThemeMode.sepia) {
      bgColor = const Color(0xFFF4ECD8);
      iconColor = Colors.brown;
    } else {
      bgColor = const Color(0xFF1E1E1E);
      iconColor = Colors.white70;
    }

    return GestureDetector(
      onTap: () => themeNotifier.setTheme(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: isSelected ? 64 : 56,
        height: isSelected ? 64 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            width: 2,
          ),
          gradient: isSelected
              ? RadialGradient(
                  colors: [
                    theme.primaryColor.withValues(alpha: 0.25),
                    bgColor,
                  ],
                  stops: const [0.1, 0.9],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
        ),
        child: Icon(
          icon,
          color: isSelected ? theme.primaryColor : iconColor,
          size: isSelected ? 30 : 26,
        ),
      ),
    );
  }
}

class _CommentaryBottomSheetContent extends ConsumerWidget {
  final String bookName;
  final int chapter;
  final int verseNumber;
  final String verseText;

  const _CommentaryBottomSheetContent({
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
  });

  void _showShareMenu(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TexturedGlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.primaryColor,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                      ),
                    ),
                    icon: Icon(Icons.bookmark_add_rounded, color: theme.primaryColor),
                    label: const Text('Save to Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved $bookName $chapter:$verseNumber to Notes')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.primaryColor,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                      ),
                    ),
                    icon: Icon(Icons.ios_share_rounded, color: theme.primaryColor),
                    label: const Text('Share to other apps', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share dialog opened')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final commentaryDataAsync = ref.watch(combinedCommentaryProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      snap: true,
      builder: (context, scrollController) {
        return TexturedGlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
          padding: EdgeInsets.zero,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Handlebar
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
                const SizedBox(height: 24),
                
                // Header Row (Title)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    '$bookName $chapter:$verseNumber',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Highlighted Verse Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TexturedGlassContainer(
                    padding: const EdgeInsets.all(20.0),
                    borderRadius: BorderRadius.circular(24),
                    child: Text(
                      '$verseNumber "$verseText"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Content & Floating CTA
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildCommentaryContent(commentaryDataAsync, theme, typography, scrollController),
                        ),
                      ),
                      
                      // Floating Action Pill
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 16,
                        child: TexturedGlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          borderRadius: BorderRadius.circular(30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Notes')));
                                },
                                icon: Icon(Icons.bookmark_add_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.8), size: 20),
                                label: Text('Save', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.8), size: 24),
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showShareMenu(context, theme),
                                icon: Icon(Icons.ios_share_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.8), size: 20),
                                label: Text('Share', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildCommentaryContent(AsyncValue<CombinedCommentaryState> commentaryDataAsync, ThemeData theme, TypographyState typography, ScrollController scrollController) {
    return commentaryDataAsync.when(
      data: (state) {
        final chapterData = state.data[bookName]?[chapter.toString()];
        final List<CommentaryEntry> entries = [];
        if (chapterData != null) {
          for (final key in chapterData.keys) {
            if (key == verseNumber.toString()) {
              entries.addAll(chapterData[key]!);
            } else if (key.contains('-')) {
              final parts = key.split('-');
              if (parts.length == 2) {
                final start = int.tryParse(parts[0]);
                final end = int.tryParse(parts[1]);
                if (start != null && end != null && verseNumber >= start && verseNumber <= end) {
                  entries.addAll(chapterData[key]!);
                }
              }
            }
          }
        }
        
        if (entries.isEmpty) {
          return ListView(
            controller: scrollController,
            children: const [
              SizedBox(height: 40),
              Center(child: Text('No commentary available.')),
            ],
          );
        }
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(top: 8.0, bottom: 100.0),
          itemCount: entries.length + (state.isEgwMissing ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == entries.length) {
              if (state.isEgwMissing) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
                  child: Text(
                    'Local EGW module not found. Place EGW JSON files in your local directory to enable this commentary.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  VerseLinkText(
                    text: entry.text,
                    defaultStyle: theme.textTheme.bodySmall?.copyWith(
                      height: 1.6,
                      color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
                    ),
                    referenceStyle: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                    numberStyle: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => ListView(controller: scrollController, children: const [SizedBox(height: 40), Center(child: CircularProgressIndicator())]),
      error: (error, stack) => ListView(controller: scrollController, children: const [SizedBox(height: 40), Center(child: Text('Error loading commentary'))]),
    );
  }
}

class _ContextMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContextMenuButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.onSurface, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

