import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data/models/bible_model.dart';
import '../../state/bible_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/study_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/immersive_mode_provider.dart';
import '../../state/read_selection_provider.dart';
import '../../state/read_location_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/bouncy_entrance.dart';

class ReadScreen extends ConsumerStatefulWidget {
  const ReadScreen({super.key});

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  int? _navigatedVerseIndex;

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

  void _scrollToVerse(int verse) {
    // Wait for the bottom sheet to fully dismiss before scrolling to avoid jank
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_itemScrollController.isAttached) {
        _itemScrollController.scrollTo(
          index: verse - 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.1,
        );
        // Highlight it faintly upon jumping
        if (mounted) {
          setState(() {
            _navigatedVerseIndex = verse - 1;
          });
        }
      }
    });
  }

  void _nextChapter(List<BibleBook> allBooks) {
    final loc = ref.read(readLocationProvider);
    final currentBookIndex = allBooks.indexWhere((b) => b.abbreviation == loc.bookAbbrev);
    if (currentBookIndex == -1) return;
    
    final book = allBooks[currentBookIndex];
    if (loc.chapter < book.chapters.length) {
      ref.read(readLocationProvider.notifier).updateLocation(chapter: loc.chapter + 1);
      _clearSelection();
    } else if (currentBookIndex < allBooks.length - 1) {
      final nextBook = allBooks[currentBookIndex + 1];
      ref.read(readLocationProvider.notifier).updateLocation(
        bookAbbrev: nextBook.abbreviation,
        bookName: nextBook.name,
        chapter: 1,
      );
      _clearSelection();
    }
  }

  void _previousChapter(List<BibleBook> allBooks) {
    final loc = ref.read(readLocationProvider);
    final currentBookIndex = allBooks.indexWhere((b) => b.abbreviation == loc.bookAbbrev);
    if (currentBookIndex == -1) return;

    if (loc.chapter > 1) {
      ref.read(readLocationProvider.notifier).updateLocation(chapter: loc.chapter - 1);
      _clearSelection();
    } else if (currentBookIndex > 0) {
      final prevBook = allBooks[currentBookIndex - 1];
      ref.read(readLocationProvider.notifier).updateLocation(
        bookAbbrev: prevBook.abbreviation,
        bookName: prevBook.name,
        chapter: prevBook.chapters.length,
      );
      _clearSelection();
    }
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
      builder: (context) {
        final loc = ref.read(readLocationProvider);
        return _BookChapterSelectorSheet(
          books: allBooks,
          selectedBookAbbrev: loc.bookAbbrev,
          selectedChapter: loc.chapter,
          onSelectionChanged: (abbrev, name, chapter, verse) {
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
            Navigator.pop(context);

            if (verse != null) {
              _scrollToVerse(verse);
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
    final selectedVerses = ref.watch(readSelectionProvider);
    final isImmersive = ref.watch(immersiveModeProvider);
    final commentaryDataAsync = ref.watch(commentaryDataProvider);

    final bibleState = ref.watch(bibleProvider);
    final isLoading = bibleState.isLoading;
    final allBooks = bibleState.books;

    ref.listen<ReadLocationState>(readLocationProvider, (previous, next) {
      if (next.requestedVerse != null) {
        _scrollToVerse(next.requestedVerse!);
        Future.microtask(() {
          ref.read(readLocationProvider.notifier).clearRequestedVerse();
        });
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
                  _showCommentaryBottomSheet(context, next.requestedVerse!, verseText);
                }
              });
            }
          } catch (_) {}
        }
        Future.microtask(() {
          ref.read(readLocationProvider.notifier).clearCommentary();
        });
      }
    });

    final loc = ref.watch(readLocationProvider);
    String currentBookName = loc.bookName;
    String currentBookAbbrev = loc.bookAbbrev;
    int currentChapter = loc.chapter;

    // Find active chapter
    List<BibleVerse> verses = [];
    if (!isLoading && allBooks.isNotEmpty) {
      try {
        final book = allBooks.firstWhere((b) => b.name == currentBookName || b.abbreviation == currentBookAbbrev,
            orElse: () => allBooks.first);
        currentBookName = book.name;
        currentBookAbbrev = book.abbreviation;

        if (currentChapter > book.chapters.length) {
          currentChapter = 1;
        }
        final chapter = book.chapters.firstWhere((c) => c.number == currentChapter,
            orElse: () => book.chapters.first);
        verses = chapter.verses;
      } catch (_) {}
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
                      : verses.isEmpty
                          ? Center(
                              child: Text('Passage not found.',
                                  style: theme.textTheme.bodyLarge),
                            )
                          : GestureDetector(
                              onTap: () {
                                if (selectedVerses.isNotEmpty) {
                                  _clearSelection();
                                }
                              },
                              onHorizontalDragEnd: (details) {
                                // Swipe left (negative velocity) -> next chapter
                                if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                                  _nextChapter(allBooks);
                                }
                                // Swipe right (positive velocity) -> prev chapter
                                else if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                                  _previousChapter(allBooks);
                                }
                              },
                              behavior: HitTestBehavior.translucent,
                              child: NotificationListener<UserScrollNotification>(
                                onNotification: (notification) {
                                  if (notification.direction == ScrollDirection.reverse) {
                                    if (!isImmersive) {
                                      // Using microtask to avoid setState during build
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
                                      itemScrollController: _itemScrollController,
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context).padding.top + 80.0,
                                          left: 24.0, right: 24.0, bottom: 400.0), // increased padding so verses can scroll above pills
                                      itemCount: verses.length,
                                      itemBuilder: (context, index) {
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
                                                commentaryDataAsync.whenData((commentaryData) {
                                                  final bookCommentary = commentaryData[currentBookName];
                                                  if (bookCommentary != null) {
                                                    final chapterCommentary = bookCommentary[currentChapter.toString()];
                                                    if (chapterCommentary != null) {
                                                      if (chapterCommentary.containsKey(verse.number.toString())) {
                                                        hasCommentary = true;
                                                      }
                                                    }
                                                  }
                                                });

                                                return GestureDetector(
                                                  onTap: () => _toggleVerseSelection(index),
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
                                                                  ? Colors.amber.withOpacity(0.20)
                                                                  : Colors.amber.withOpacity(0.15))
                                                              : (_navigatedVerseIndex == index
                                                                  ? (isDark
                                                                      ? Colors.amber.withOpacity(0.15)
                                                                      : Colors.amber.withOpacity(0.10))
                                                                  : (verse.isHighlighted
                                                                      ? Colors.amber.withOpacity(0.10)
                                                                      : Colors.transparent)),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: _buildNormalVerse(
                                                          verse,
                                                          theme,
                                                          typography,
                                                          appThemeMode,
                                                          hasCommentary: hasCommentary,
                                                          onCommentaryTap: () => _showCommentaryBottomSheet(context, verse.number, verse.text),
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
                            ),
                ),
                // Top Navigation Bar Layer (Floating above text)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),

                        // Top Navigation Bar
                        AnimatedSlide(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  offset: isImmersive ? const Offset(0, -1.5) : Offset.zero,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Top-Left Logo
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: theme.primaryColor,
                                size: 24,
                              ),
                            ),
                            
                            // Center Book/Chapter Picker
                            if (!isLoading)
                              Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () => _showSelectorBottomSheet(allBooks),
                                  child: GlassContainer(
                                    borderRadius: BorderRadius.circular(30),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$currentBookName $currentChapter',
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 20,
                                          color: theme.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // Top-Right Typography Toggle
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _showTypographyBottomSheet,
                                child: Text(
                                  'a',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
    );
  }

  Widget _buildActionIcon(
      IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      tooltip: tooltip,
      onPressed: onTap,
    );
  }

  void _showCommentaryBottomSheet(BuildContext context, int verseNumber, String verseText) {
    final loc = ref.read(readLocationProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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

}


enum SelectionMode { book, chapter, verse }

/// Modal Bottom Sheet for selecting Book, Chapter, and Verse
class _BookChapterSelectorSheet extends ConsumerStatefulWidget {
  final List<BibleBook> books;
  final String selectedBookAbbrev;
  final int selectedChapter;
  final Function(String abbrev, String name, int chapter, int? verse) onSelectionChanged;

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
  late BibleBook _tempBook;
  late int _tempChapter;
  int? _tempVerse;

  SelectionMode _mode = SelectionMode.book;
  bool _isOldTestament = true;

  @override
  void initState() {
    super.initState();
    _tempBook = widget.books.firstWhere((b) => b.abbreviation == widget.selectedBookAbbrev,
        orElse: () => widget.books.first);
    _tempChapter = widget.selectedChapter;
    // Determine testament based on book index
    final bookIndex = widget.books.indexOf(_tempBook);
    _isOldTestament = bookIndex < 39;
  }

  void _onBookSelected(BibleBook book) {
    setState(() {
      _tempBook = book;
      _tempChapter = 1;
      _tempVerse = null;
      _mode = SelectionMode.chapter; // Auto-advance to Chapter
    });
  }

  void _onChapterSelected(int chapter) {
    setState(() {
      _tempChapter = chapter;
      _tempVerse = null;
      _mode = SelectionMode.verse; // Auto-advance to Verse
    });
  }

  void _onVerseSelected(int verse) {
    setState(() {
      _tempVerse = verse;
    });
    // Auto-navigate immediately upon tapping a verse
    widget.onSelectionChanged(
        _tempBook.abbreviation,
        _tempBook.name,
        _tempChapter,
        _tempVerse);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BouncyEntrance(
      delay: const Duration(milliseconds: 50),
      child: Material(
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
                // Handlebar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Segmented Breadcrumb Header
                _buildBreadcrumbs(theme),
                const SizedBox(height: 16),

                // Dynamic Selection View & Floating Pill
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildSelectionView(theme),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: _buildBottomCTA(theme),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildBreadcrumbs(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildBreadcrumbSegment('Book', _tempBook.name, SelectionMode.book, theme),
          _buildBreadcrumbSegment('Chapter', '$_tempChapter', SelectionMode.chapter, theme),
          _buildBreadcrumbSegment('Verse', _tempVerse != null ? '$_tempVerse' : '-', SelectionMode.verse, theme),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbSegment(String label, String value, SelectionMode mode, ThemeData theme) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Column(
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: isSelected ? Colors.white.withOpacity(0.8) : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.8),
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

  Widget _buildSelectionView(ThemeData theme) {
    switch (_mode) {
      case SelectionMode.book:
        return _buildBookSelection(theme);
      case SelectionMode.chapter:
        return _buildChapterSelection(theme);
      case SelectionMode.verse:
        return _buildVerseSelection(theme);
    }
  }

  Widget _buildBookSelection(ThemeData theme) {
    final oldTestamentBooks = widget.books.take(39).toList();
    final newTestamentBooks = widget.books.skip(39).toList();
    final displayedBooks = _isOldTestament ? oldTestamentBooks : newTestamentBooks;

    return Column(
      children: [
        // Testament Toggles
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isOldTestament = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isOldTestament ? theme.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Old Testament',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isOldTestament ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isOldTestament = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isOldTestament ? theme.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'New Testament',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !_isOldTestament ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 2-Column Book Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: displayedBooks.length,
            itemBuilder: (context, index) {
              final book = displayedBooks[index];
              final isSel = book.abbreviation == _tempBook.abbreviation;
              return _buildGridTile(
                text: book.name,
                isSelected: isSel,
                onTap: () => _onBookSelected(book),
                theme: theme,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChapterSelection(ThemeData theme) {
    final chapters = _tempBook.chapters.length;
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 64,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: chapters,
      itemBuilder: (context, index) {
        final chapter = index + 1;
        final isSel = chapter == _tempChapter;
        return _buildGridTile(
          text: '$chapter',
          isSelected: isSel,
          onTap: () => _onChapterSelected(chapter),
          theme: theme,
        );
      },
    );
  }

  Widget _buildVerseSelection(ThemeData theme) {
    final chapterData = _tempBook.chapters.firstWhere((c) => c.number == _tempChapter, orElse: () => _tempBook.chapters.first);
    final verses = chapterData.verses.length;
    
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 64,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: verses,
      itemBuilder: (context, index) {
        final verse = index + 1;
        final isSel = verse == _tempVerse;
        return _buildGridTile(
          text: '$verse',
          isSelected: isSel,
          onTap: () => _onVerseSelected(verse),
          theme: theme,
        );
      },
    );
  }

  Widget _buildGridTile({required String text, required bool isSelected, required VoidCallback onTap, required ThemeData theme}) {
    if (!isSelected) {
      // Use TexturedGlassContainer for liquid glass look when unselected
      return GestureDetector(
        onTap: onTap,
        child: TexturedGlassContainer(
          borderRadius: BorderRadius.circular(30),
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              text,
              style: (text.length > 3 ? theme.textTheme.labelMedium : theme.textTheme.titleMedium)?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    
    // Solid theme-colored pill for selected state
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Text(
          text,
          style: (text.length > 3 ? theme.textTheme.labelMedium : theme.textTheme.titleMedium)?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomCTA(ThemeData theme) {
    return TexturedGlassContainer(
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Navigation Confirmation Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.onSelectionChanged(
                    _tempBook.abbreviation, _tempBook.name, _tempChapter, _tempVerse);
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _tempVerse != null
                      ? 'Go to ${_tempBook.name} $_tempChapter:$_tempVerse'
                      : 'Go to ${_tempBook.name} $_tempChapter',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Search Button inside the pill
          Consumer(
            builder: (context, ref, child) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  ref.read(navProvider.notifier).setIndex(2); // Jump to Search Tab
                  // Keyboard autofocuses automatically in SearchScreen's initState
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: theme.primaryColor,
                    size: 24,
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
              const SizedBox(height: 8),
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

class _CommentaryBottomSheetContent extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<_CommentaryBottomSheetContent> createState() => _CommentaryBottomSheetContentState();
}

class _CommentaryBottomSheetContentState extends ConsumerState<_CommentaryBottomSheetContent> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final commentaryDataAsync = ref.watch(combinedCommentaryProvider);

    return TexturedGlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
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
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header Row (Title)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                '${widget.bookName} ${widget.chapter}:${widget.verseNumber}',
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
                  '${widget.verseNumber} "${widget.verseText}"',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Pill Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildPillTab(0, 'Commentary', theme),
                    _buildPillTab(1, 'Cross-refs', theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Content & Floating CTA
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _tabIndex == 0
                          ? _buildCommentaryContent(commentaryDataAsync, theme, typography)
                          : const Center(child: Text('Cross-references coming soon.')),
                    ),
                  ),
                  
                  // Floating Action Pill
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 16,
                    child: TexturedGlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      borderRadius: BorderRadius.circular(30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.add, color: theme.colorScheme.onSurface.withOpacity(0.8), size: 20),
                              label: Text(
                                'Add Note',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(width: 1, height: 24, color: theme.dividerColor.withOpacity(0.2)),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.ios_share_rounded, color: theme.colorScheme.onSurface.withOpacity(0.8), size: 20),
                              label: Text(
                                'Share',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
        ),
      ),
    );
  }

  Widget _buildPillTab(int index, String title, ThemeData theme) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentaryContent(AsyncValue<CombinedCommentaryState> commentaryDataAsync, ThemeData theme, TypographyState typography) {
    return commentaryDataAsync.when(
      data: (state) {
        final entries = state.data[widget.bookName]?[widget.chapter.toString()]?[widget.verseNumber.toString()];
        
        if (entries == null || entries.isEmpty) {
          return const Center(child: Text('No commentary available.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 24.0, bottom: 100.0),
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
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
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
                  Text(
                    entry.text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.6,
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('Error loading commentary')),
    );
  }
}

