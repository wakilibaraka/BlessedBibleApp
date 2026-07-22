import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/bible_model.dart';
import '../../state/bible_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/study_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/typography_provider.dart';
import '../widgets/glass_container.dart';

class ReadScreen extends ConsumerStatefulWidget {
  const ReadScreen({super.key});

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen> {
  String _selectedBookAbbrev = 'Gn';
  String _selectedBookName = 'Genesis';
  int _selectedChapter = 1;

  final Set<int> _selectedVerseIndices = {};
  final Map<int, GlobalKey> _verseKeys = {};

  // For the manuscript UI, provide classic subtitles for specific chapters
  String? _getChapterSubtitle(String bookName, int chapter) {
    if (bookName == 'Genesis' && chapter == 1) {
      return 'The Creation of the World';
    }
    if (bookName == 'Matthew' && chapter == 1) {
      return 'The Genealogy of Jesus Christ';
    }
    return null;
  }

  void _toggleVerseSelection(int index) {
    setState(() {
      if (_selectedVerseIndices.contains(index)) {
        _selectedVerseIndices.remove(index);
      } else {
        _selectedVerseIndices.add(index);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedVerseIndices.clear();
    });
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
        setState(() {
          _selectedVerseIndices.clear();
          _selectedVerseIndices.add(verse - 1);
        });
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
        _selectedVerseIndices.clear();
        _verseKeys.clear();
      });
    } else if (currentBookIndex < allBooks.length - 1) {
      final nextBook = allBooks[currentBookIndex + 1];
      setState(() {
        _selectedBookAbbrev = nextBook.abbreviation;
        _selectedBookName = nextBook.name;
        _selectedChapter = 1;
        _selectedVerseIndices.clear();
        _verseKeys.clear();
      });
    }
  }

  void _previousChapter(List<BibleBook> allBooks) {
    final currentBookIndex = allBooks.indexWhere((b) => b.abbreviation == _selectedBookAbbrev);
    if (currentBookIndex == -1) return;

    if (_selectedChapter > 1) {
      setState(() {
        _selectedChapter--;
        _selectedVerseIndices.clear();
        _verseKeys.clear();
      });
    } else if (currentBookIndex > 0) {
      final prevBook = allBooks[currentBookIndex - 1];
      setState(() {
        _selectedBookAbbrev = prevBook.abbreviation;
        _selectedBookName = prevBook.name;
        _selectedChapter = prevBook.chapters.length;
        _selectedVerseIndices.clear();
        _verseKeys.clear();
      });
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
              _selectedVerseIndices.clear();
            });
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
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      // Top-Left Logo
                      Icon(
                        Icons.menu_book_rounded,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                      
                      const Spacer(),

                      // Center Book/Chapter Picker
                      if (!isLoading)
                        GestureDetector(
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
                      
                      const Spacer(),

                      // Top-Right Typography Menu
                      GestureDetector(
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
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Scripture View
                Expanded(
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
                                if (_selectedVerseIndices.isNotEmpty) {
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
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                    left: 24.0, right: 24.0, bottom: 120.0),
                                itemCount: verses.length,
                                itemBuilder: (context, index) {
                                  if (!_verseKeys.containsKey(index)) {
                                    _verseKeys[index] = GlobalKey();
                                  }
                                  final verse = verses[index];
                                  final isSelected =
                                      _selectedVerseIndices.contains(index);

                                  return Column(
                                    key: _verseKeys[index],
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Manuscript Chapter Header (Only on Verse 1)
                                      if (index == 0) ...[
                                        _ChapterHeader(
                                          bookName: _selectedBookName,
                                          subtitle: _getChapterSubtitle(
                                              _selectedBookName, _selectedChapter),
                                          theme: theme,
                                        ),
                                        const SizedBox(height: 24),
                                      ],

                                      // Verse Text with Drop Cap on Verse 1
                                      GestureDetector(
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
                                              child: index == 0
                                                  ? _buildDropCapVerse(verse, theme, typography)
                                                  : _buildNormalVerse(verse, theme, typography),
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
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),

          // ── Vertical Floating Action Bar ─────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            right: _selectedVerseIndices.isNotEmpty ? 16 : -80,
            bottom: 160, // Moved up to clear bottom nav better
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              opacity: _selectedVerseIndices.isNotEmpty ? 1.0 : 0.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24), // slightly smaller radius
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.45),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_selectedVerseIndices.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildActionIcon(
                          Icons.bookmark_border_rounded,
                          'Bookmark',
                          theme.colorScheme.onSurface,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${_selectedVerseIndices.length} verse(s) bookmarked!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            _clearSelection();
                          },
                        ),
                        _buildActionIcon(
                          Icons.note_add_outlined,
                          'Note',
                          theme.colorScheme.onSurface,
                          () => _clearSelection(),
                        ),
                        IconButton(
                           icon: const Icon(Icons.auto_awesome),
                           color: Colors.redAccent,
                           tooltip: 'Deep Study',
                           padding: EdgeInsets.zero,
                           constraints: const BoxConstraints(),
                           visualDensity: VisualDensity.compact,
                           onPressed: () {
                             final sorted = _selectedVerseIndices.toList()..sort();
                             final vStr = sorted.map((i) => verses[i].number).join(', ');
                             final passage = '$_selectedBookName $_selectedChapter:$vStr';
                             ref.read(studyPassageProvider.notifier).setPassage(passage);
                             ref.read(navProvider.notifier).setIndex(3);
                             _clearSelection();
                           }
                        ),
                        const SizedBox(height: 4),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          onPressed: _clearSelection,
                        ),
                      ],
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

  Widget _buildActionIcon(
      IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      tooltip: tooltip,
      onPressed: onTap,
    );
  }

  Widget _buildNormalVerse(BibleVerse verse, ThemeData theme, TypographyState typography) {
    final fontStyle = GoogleFonts.getFont(typography.fontFamily).copyWith(
      height: 1.6,
      fontSize: typography.fontSize,
      letterSpacing: 0.15,
      color: theme.textTheme.bodyLarge?.color,
    );

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
        ],
      ),
    );
  }

  Widget _buildDropCapVerse(BibleVerse verse, ThemeData theme, TypographyState typography) {
    final fontStyle = GoogleFonts.getFont(typography.fontFamily).copyWith(
      height: 1.6,
      fontSize: typography.fontSize,
      letterSpacing: 0.15,
      color: theme.textTheme.bodyLarge?.color,
    );

    // Basic drop cap implementation using RichText
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${verse.number} ',
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w400,
              fontSize: typography.fontSize * 3.2, // Scale drop cap
              height: 1.0,
            ),
          ),
          TextSpan(
            text: verse.text,
            style: fontStyle,
          ),
        ],
      ),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  final String bookName;
  final String? subtitle;
  final ThemeData theme;

  const _ChapterHeader({
    required this.bookName,
    this.subtitle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Crest / Icon
        Icon(
          Icons.shield_outlined,
          size: 48,
          color: theme.primaryColor.withOpacity(0.8),
        ),
        const SizedBox(height: 24),
        // Book Title (All Caps)
        Text(
          bookName.toUpperCase(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 4.0,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        // Chapter Subtitle
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
      ],
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

              // Confirm Button (For Chapter jump)
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
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
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: fonts.map((font) {
                  final isSelected = typography.fontFamily == font;
                  return ChoiceChip(
                    label: Text(font, style: GoogleFonts.getFont(font)),
                    selected: isSelected,
                    selectedColor: theme.primaryColor.withValues(alpha: 0.15),
                    backgroundColor: theme.colorScheme.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        typographyNotifier.setFontFamily(font);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
