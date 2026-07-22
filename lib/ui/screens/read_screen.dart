import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/bible_model.dart';
import '../../state/bible_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/study_provider.dart';
import '../../data/models/commentary_model.dart';
import '../../state/theme_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/immersive_mode_provider.dart';
import '../../state/read_selection_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/textured_glass_container.dart';

class ReadScreen extends ConsumerStatefulWidget {
  const ReadScreen({super.key});

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen> {
  String _selectedBookName = 'Revelation';
  String _selectedBookAbbrev = 'REV';
  int _selectedChapter = 14;

  final Map<int, GlobalKey> _verseKeys = {};



  void _toggleVerseSelection(int index) {
    ref.read(readSelectionProvider.notifier).toggle(index);
  }

  void _clearSelection() {
    ref.read(readSelectionProvider.notifier).clear();
  }

  void _scrollToVerse(int verse) {
    // Wait for the bottom sheet to fully dismiss before scrolling to avoid jank
    Future.delayed(const Duration(milliseconds: 400), () {
      final key = _verseKeys[verse - 1];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.1,
        );
        // Highlight it upon jumping
        ref.read(readSelectionProvider.notifier).setSingle(verse - 1);
      }
    });
  }

  void _nextChapter(List<BibleBook> allBooks) {
    final currentBookIndex = allBooks.indexWhere((b) => b.abbreviation == _selectedBookAbbrev);
    if (currentBookIndex == -1) return;
    
    final book = allBooks[currentBookIndex];
    if (_selectedChapter < book.chapters.length) {
      setState(() {
        _selectedChapter++;
        _verseKeys.clear();
      });
      _clearSelection();
    } else if (currentBookIndex < allBooks.length - 1) {
      final nextBook = allBooks[currentBookIndex + 1];
      setState(() {
        _selectedBookAbbrev = nextBook.abbreviation;
        _selectedBookName = nextBook.name;
        _selectedChapter = 1;
        _verseKeys.clear();
      });
      _clearSelection();
    }
  }

  void _previousChapter(List<BibleBook> allBooks) {
    final currentBookIndex = allBooks.indexWhere((b) => b.abbreviation == _selectedBookAbbrev);
    if (currentBookIndex == -1) return;

    if (_selectedChapter > 1) {
      setState(() {
        _selectedChapter--;
        _verseKeys.clear();
      });
      _clearSelection();
    } else if (currentBookIndex > 0) {
      final prevBook = allBooks[currentBookIndex - 1];
      setState(() {
        _selectedBookAbbrev = prevBook.abbreviation;
        _selectedBookName = prevBook.name;
        _selectedChapter = prevBook.chapters.length;
        _verseKeys.clear();
      });
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
        return _BookChapterSelectorSheet(
          books: allBooks,
          selectedBookAbbrev: _selectedBookAbbrev,
          selectedChapter: _selectedChapter,
          onSelectionChanged: (abbrev, name, chapter, verse) {
            bool changedChapter = _selectedBookAbbrev != abbrev || _selectedChapter != chapter;
            setState(() {
              _selectedBookAbbrev = abbrev;
              _selectedBookName = name;
              _selectedChapter = chapter;
              if (changedChapter) {
                _verseKeys.clear();
              }
            });
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

    // Find active chapter
    List<BibleVerse> verses = [];
    if (!isLoading && allBooks.isNotEmpty) {
      try {
        final book = allBooks.firstWhere((b) => b.name == _selectedBookName || b.abbreviation == _selectedBookAbbrev,
            orElse: () => allBooks.first);
        _selectedBookName = book.name;
        _selectedBookAbbrev = book.abbreviation;

        if (_selectedChapter > book.chapters.length) {
          _selectedChapter = 1;
        }
        final chapter = book.chapters.firstWhere((c) => c.number == _selectedChapter,
            orElse: () => book.chapters.first);
        verses = chapter.verses;
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Background color matching theme ───────────────────────
          Positioned.fill(
            child: Container(
              color: theme.scaffoldBackgroundColor,
            ),
          ),

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
                                child: ListView.builder(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top + 80.0,
                                    left: 24.0, right: 24.0, bottom: 120.0),
                                itemCount: verses.length,
                                itemBuilder: (context, index) {
                                  if (!_verseKeys.containsKey(index)) {
                                    _verseKeys[index] = GlobalKey();
                                  }
                                  final verse = verses[index];
                                  final isSelected =
                                      selectedVerses.contains(index);

                                  return Column(
                                    key: _verseKeys[index],
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Check for commentary
                                      Builder(
                                        builder: (context) {
                                          bool hasCommentary = false;
                                          commentaryDataAsync.whenData((commentaryData) {
                                            final bookCommentary = commentaryData[_selectedBookName];
                                            if (bookCommentary != null) {
                                              final chapterCommentary = bookCommentary[_selectedChapter.toString()];
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
                                                    : (verse.isHighlighted
                                                        ? Colors.amber.withOpacity(0.10)
                                                        : Colors.transparent),
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
                                                left: 0,
                                                top: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 3.5,
                                                  decoration: BoxDecoration(
                                                    color: theme.primaryColor,
                                                    borderRadius:
                                                        const BorderRadius.horizontal(
                                                      left: Radius.circular(12),
                                                    ),
                                                  ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }
                                    ),
                                    ],
                                  );
                                },
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
                                          '$_selectedBookName $_selectedChapter',
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 15,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _CommentaryBottomSheetContent(
          bookName: _selectedBookName,
          chapter: _selectedChapter,
          verseNumber: verseNumber,
          verseText: verseText,
        );
      },
    );
  }

  Widget _buildNormalVerse(BibleVerse verse, ThemeData theme, TypographyState typography, AppThemeMode appThemeMode, {bool hasCommentary = false, VoidCallback? onCommentaryTap}) {
    final fontStyle = GoogleFonts.getFont(typography.fontFamily).copyWith(
      height: 1.6,
      fontSize: typography.fontSize,
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
              fontSize: typography.fontSize * 0.75, // Scale number down
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


/// Modal Bottom Sheet for selecting Book and Chapter
class _BookChapterSelectorSheet extends StatefulWidget {
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
  State<_BookChapterSelectorSheet> createState() =>
      __BookChapterSelectorSheetState();
}

class __BookChapterSelectorSheetState
    extends State<_BookChapterSelectorSheet> {
  late BibleBook _tempBook;
  late int _tempChapter;
  int? _tempVerse;

  @override
  void initState() {
    super.initState();
    _tempBook = widget.books.firstWhere((b) => b.abbreviation == widget.selectedBookAbbrev,
        orElse: () => widget.books.first);
    _tempChapter = widget.selectedChapter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              Text(
                'Navigate',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Books & Chapters Section
              Expanded(
                child: Row(
                  children: [
                    // Left Column: Books
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BOOK',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.primaryColor,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.books.length,
                              itemBuilder: (context, idx) {
                                final bk = widget.books[idx];
                                final isSel = bk.abbreviation == _tempBook.abbreviation;
                                return ListTile(
                                  dense: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  selectedTileColor:
                                      theme.primaryColor.withOpacity(0.12),
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  selected: isSel,
                                  title: Text(
                                    bk.name,
                                    style: TextStyle(
                                      fontWeight: isSel
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSel
                                          ? theme.primaryColor
                                          : theme.colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => setState(() {
                                    _tempBook = bk;
                                    _tempChapter = 1;
                                    _tempVerse = null;
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 16),

                    // Middle Column: Chapters Grid
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CH.',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.primaryColor,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: _tempBook.chapters.length,
                              itemBuilder: (context, idx) {
                                final ch = _tempBook.chapters[idx].number;
                                final isSel = ch == _tempChapter;
                                return InkWell(
                                  onTap: () => setState(() {
                                    _tempChapter = ch;
                                    _tempVerse = null;
                                  }),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? theme.primaryColor
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$ch',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSel
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 16),

                    // Right Column: Verses Grid
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VERSE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.primaryColor,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: _tempBook.chapters
                                  .firstWhere((c) => c.number == _tempChapter,
                                      orElse: () => _tempBook.chapters.first)
                                  .verses
                                  .length,
                              itemBuilder: (context, idx) {
                                final v = idx + 1;
                                final isSel = v == _tempVerse;
                                return InkWell(
                                  onTap: () {
                                    setState(() => _tempVerse = v);
                                    // Auto-navigate immediately upon tapping a verse
                                    widget.onSelectionChanged(
                                        _tempBook.abbreviation,
                                        _tempBook.name,
                                        _tempChapter,
                                        _tempVerse);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? theme.primaryColor
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$v',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSel
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Confirm & Search Button Row (For Chapter jump + Search)
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final appThemeMode = ref.watch(themeProvider);
                  final searchButtonColor = appThemeMode == AppThemeMode.dark
                      ? Colors.amberAccent
                      : appThemeMode == AppThemeMode.sepia
                          ? Colors.deepOrange.shade600
                          : Colors.deepOrange.shade400;
                  final iconColor = appThemeMode == AppThemeMode.dark ? Colors.black : Colors.white;

                  return Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
                              widget.onSelectionChanged(
                                  _tempBook.abbreviation, _tempBook.name, _tempChapter, _tempVerse);
                            },
                            child: Text(
                              _tempVerse != null
                                  ? 'Go to ${_tempBook.name} $_tempChapter:$_tempVerse'
                                  : 'Go to ${_tempBook.name} $_tempChapter',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close bottom sheet
                          ref.read(navProvider.notifier).setIndex(2); // Jump to Search Tab
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: searchButtonColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: searchButtonColor.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: iconColor,
                            size: 24,
                          ),
                        ),
                      ),
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

class _TypographyBottomSheet extends ConsumerWidget {
  const _TypographyBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final typographyNotifier = ref.read(typographyProvider.notifier);

    final fonts = ['Inter', 'Gentium Book Plus', 'Lora', 'Literata'];

    return Material(
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
                  const Text('A', style: TextStyle(fontSize: 14)),
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
                  const Text('A', style: TextStyle(fontSize: 24)),
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
                          fontSize: 15,
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
    final commentaryDataAsync = ref.watch(commentaryDataProvider);

    return TexturedGlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
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
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header Row (Title + Close)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  const SizedBox(width: 40), // Balance the close button
                  Expanded(
                    child: Text(
                      '${widget.bookName} ${widget.chapter}:${widget.verseNumber}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        textStyle: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Highlighted Verse Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${widget.verseNumber} "${widget.verseText}"',
                  style: GoogleFonts.gentiumBookPlus(
                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: typography.fontSize,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildTab(0, 'Commentary', theme),
                  _buildTab(1, 'Cross-refs', theme),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _tabIndex == 0
                    ? _buildCommentaryContent(commentaryDataAsync, theme, typography)
                    : const Center(child: Text('Cross-references coming soon.')),
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.add, color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
                      label: Text(
                        'Add Note',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 24, color: theme.dividerColor.withOpacity(0.2)),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.ios_share_rounded, color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
                      label: Text(
                        'Share',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
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

  Widget _buildTab(int index, String title, ThemeData theme) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentaryContent(AsyncValue commentaryDataAsync, ThemeData theme, TypographyState typography) {
    return commentaryDataAsync.when(
      data: (data) {
        final entries = data[widget.bookName]?[widget.chapter.toString()]?[widget.verseNumber.toString()];
        if (entries == null || entries.isEmpty) {
          return const Center(child: Text('No commentary available.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
          itemCount: entries.length,
          itemBuilder: (context, index) {
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
                    style: GoogleFonts.lora(
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: typography.fontSize - 1,
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                      ),
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

