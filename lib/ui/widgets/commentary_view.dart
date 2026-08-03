import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/reading_tokens.dart';
import '../../state/commentary_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/typography_provider.dart';

import '../../state/theme_provider.dart';

import '../../models/commentary_entry.dart';

import 'pinch_to_zoom_font_wrapper.dart';
import '../screens/commentary_hub_screen.dart';

class CommentaryView extends ConsumerStatefulWidget {
  final String book;
  final int chapter;
  final int? verse;
  final String? verseText;
  final bool isCompact;
  final ScrollController? scrollController;
  final VoidCallback? onExpand;

  const CommentaryView({
    super.key,
    required this.book,
    required this.chapter,
    this.verse,
    this.verseText,
    this.isCompact = false,
    this.scrollController,
    this.onExpand,
  });

  @override
  ConsumerState<CommentaryView> createState() => _CommentaryViewState();
}

class _CommentaryViewState extends ConsumerState<CommentaryView> {
  bool _showChapter = false;
  bool _showBook = false;
  int? _currentVerseNum;
  final Map<int, GlobalKey> _entryKeys = {};

  @override
  void initState() {
    super.initState();
    _currentVerseNum = widget.verse;
  }

  String? _lookupVerseText(WidgetRef ref, int? verseNum) {
    if (widget.verseText != null && widget.verseText!.isNotEmpty) {
      return widget.verseText;
    }
    if (verseNum == null) return null;

    final bibleState = ref.watch(bibleProvider);
    if (bibleState.books.isEmpty) return null;

    try {
      final book = bibleState.books.firstWhere(
        (b) =>
            b.name.toLowerCase() == widget.book.toLowerCase() ||
            b.abbreviation.toLowerCase() == widget.book.toLowerCase(),
      );
      if (widget.chapter > 0 && widget.chapter <= book.chapters.length) {
        final chapter = book.chapters[widget.chapter - 1];
        if (verseNum > 0 && verseNum <= chapter.verses.length) {
          return chapter.verses[verseNum - 1].text;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<ReadingTokens>()!;
    final commentaryAsync = ref.watch(commentaryProvider);
    ref.watch(commentaryBookmarksProvider);
    final commentaryNotifier = ref.read(commentaryProvider.notifier);
    final typography = ref.watch(typographyProvider);

    final bookName = widget.book;
    final appThemeMode = ref.watch(themeProvider);
    final is3DTheme = appThemeMode == AppThemeMode.dawn ||
        appThemeMode == AppThemeMode.lilies ||
        appThemeMode == AppThemeMode.roses ||
        appThemeMode == AppThemeMode.olives ||
        appThemeMode == AppThemeMode.dusk ||
        appThemeMode == AppThemeMode.fresh;

    final chapterNum = widget.chapter;
    final displayVerse = widget.verse ?? _currentVerseNum;

    final referenceString = displayVerse != null
        ? '$bookName $chapterNum:$displayVerse'
        : '$bookName $chapterNum';

    final isBookmarked = ref
        .read(commentaryBookmarksProvider.notifier)
        .isBookmarked(bookName, chapterNum, displayVerse);
    final fetchedVerseText = _lookupVerseText(ref, displayVerse);

    List<CommentaryEntry> verseEntries = [];
    List<CommentaryEntry> chapterEntries = [];
    List<CommentaryEntry> bookEntries = [];

    if (widget.verse != null) {
      verseEntries = commentaryNotifier.commentaryForVerse(
          bookName, chapterNum, widget.verse!);
    } else {
      verseEntries =
          commentaryNotifier.commentaryForChapterVerses(bookName, chapterNum);
    }
    chapterEntries =
        commentaryNotifier.commentaryForChapter(bookName, chapterNum);
    bookEntries = commentaryNotifier.commentaryForBook(bookName);

    final hasContent = verseEntries.isNotEmpty ||
        chapterEntries.isNotEmpty ||
        bookEntries.isNotEmpty;

    return PinchToZoomFontWrapper(
      child: Stack(
        children: [
          // Base: Scrollable Content
          _buildScrollableContent(
              verseEntries,
              chapterEntries,
              bookEntries,
              commentaryAsync,
              hasContent,
              theme,
              tokens,
              is3DTheme,
              typography),

          // Floating Top Header
          Positioned(
            top: widget.isCompact ? 16 : MediaQuery.paddingOf(context).top + 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. TOP ROW
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: theme.primaryColor),
                        onPressed: () {
                          if (widget.isCompact) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        tooltip: 'Back',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: tokens.readingAccent.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        referenceString,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: tokens.readingAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_rounded,
                              color: isBookmarked
                                  ? tokens.readingAccent
                                  : tokens.readingInkMuted,
                            ),
                            tooltip: isBookmarked
                                ? 'Remove Bookmark'
                                : 'Bookmark Commentary',
                            onPressed: () {
                              ref
                                  .read(commentaryBookmarksProvider.notifier)
                                  .toggleBookmark(
                                      bookName, chapterNum, displayVerse);
                            },
                          ),
                          if (widget.onExpand != null)
                            IconButton(
                              icon: Icon(
                                Icons.open_in_full_rounded,
                                color: tokens.readingAccent,
                                size: 20,
                              ),
                              tooltip: 'Expand to full screen',
                              onPressed: widget.onExpand,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 2. FLOATING VERSE CARD
                if (fetchedVerseText != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      color: is3DTheme
                          ? theme.colorScheme.surface
                          : theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color:
                              tokens.readingInkMuted.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Text(
                      '\u201c$fetchedVerseText\u201d',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.42,
                        fontSize: typography.fontSize * 1.05,
                        fontFamily: typography.fontFamily,
                        color: tokens.readingInk,
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

  Widget _buildScrollableContent(
    List<CommentaryEntry> verseEntries,
    List<CommentaryEntry> chapterEntries,
    List<CommentaryEntry> bookEntries,
    AsyncValue<void> commentaryAsync,
    bool hasContent,
    ThemeData theme,
    ReadingTokens tokens,
    bool is3DTheme,
    TypographyState typography,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (widget.verse == null && verseEntries.isNotEmpty) {
          int? topVerse;
          double minDy = double.infinity;

          for (final entry in _entryKeys.entries) {
            final context = entry.value.currentContext;
            if (context != null) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final position = box.localToGlobal(Offset.zero).dy;
                if (position > 0 && position < minDy) {
                  minDy = position;
                  topVerse = verseEntries[entry.key].scope.verse;
                } else if (position <= 0 && position > -box.size.height) {
                  topVerse = verseEntries[entry.key].scope.verse;
                  break;
                }
              }
            }
          }

          if (topVerse != null && topVerse != _currentVerseNum) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _currentVerseNum != topVerse) {
                setState(() {
                  _currentVerseNum = topVerse;
                });
              }
            });
          }
        }
        return false;
      },
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          // Spacer for floating header
          SliverToBoxAdapter(
            child: SizedBox(
              height: widget.isCompact
                  ? 240.0
                  : MediaQuery.paddingOf(context).top + 240.0,
            ),
          ),
          if (commentaryAsync.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (!hasContent)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildEmptyState(theme, tokens, is3DTheme),
              ),
            )
          else ...[
            if (verseEntries.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final key =
                        _entryKeys.putIfAbsent(index, () => GlobalKey());
                    return KeyedSubtree(
                      key: key,
                      child: _buildEntryCard(
                          theme, tokens, verseEntries[index], typography),
                    );
                  },
                  childCount: verseEntries.length,
                ),
              ),
            if (chapterEntries.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildCollapsibleSection(
                  theme: theme,
                  tokens: tokens,
                  title: 'On this chapter',
                  isExpanded: _showChapter,
                  entries: chapterEntries,
                  typography: typography,
                  onToggle: () => setState(() => _showChapter = !_showChapter),
                ),
              ),
            if (bookEntries.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildCollapsibleSection(
                  theme: theme,
                  tokens: tokens,
                  title: 'On this book',
                  isExpanded: _showBook,
                  entries: bookEntries,
                  typography: typography,
                  onToggle: () => setState(() => _showBook = !_showBook),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      ThemeData theme, ReadingTokens tokens, bool is3DTheme) {
    return Container(
      decoration: BoxDecoration(
        color: is3DTheme ? theme.colorScheme.surface : tokens.readingSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: is3DTheme
                ? Colors.white.withValues(alpha: 0.15)
                : tokens.readingBorder),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded,
              size: 56, color: tokens.readingAccent.withValues(alpha: 0.4)),
          const SizedBox(height: 20),
          Text(
            'No commentary yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.readingInk,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We couldn\'t find specific commentary for this passage. Try exploring the chapter or book-level commentary below.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.readingInkMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required ThemeData theme,
    required ReadingTokens tokens,
    required String title,
    required bool isExpanded,
    required List<CommentaryEntry> entries,
    required TypographyState typography,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: tokens.readingInk,
                      ),
                    ),
                  ),
                  Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: tokens.readingAccent),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: _buildEntryContent(
                              theme, tokens, entry, typography),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(ThemeData theme, ReadingTokens tokens,
      CommentaryEntry entry, TypographyState typography) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: _buildEntryContent(theme, tokens, entry, typography),
    );
  }

  Widget _buildEntryContent(ThemeData theme, ReadingTokens tokens,
      CommentaryEntry entry, TypographyState typography) {
    final paragraphs = entry.text.split('\n\n');

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  p.trim(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: typography.fontSize,
                    height: typography.lineHeight,
                    fontFamily: typography.fontFamily,
                    color: tokens.readingInk,
                  ),
                ),
              )),
          const Divider(height: 24),
          Text(
            entry.author,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.readingAccent,
            ),
          ),
          if (entry.source.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              entry.source,
              style: theme.textTheme.labelMedium?.copyWith(
                color: tokens.readingInkMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Utility function to display the commentary in a compact, draggable modal bottom sheet.
void showCommentaryBottomSheet(
  BuildContext context, {
  required String book,
  required int chapter,
  int? verse,
  String? verseText,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final tokens = Theme.of(context).extension<ReadingTokens>()!;
          final theme = Theme.of(context);
          final appThemeMode = ref.watch(themeProvider);
          final is3DTheme = appThemeMode == AppThemeMode.dawn ||
              appThemeMode == AppThemeMode.lilies ||
              appThemeMode == AppThemeMode.roses ||
              appThemeMode == AppThemeMode.olives ||
              appThemeMode == AppThemeMode.dusk ||
              appThemeMode == AppThemeMode.fresh;

          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.35,
            maxChildSize: 0.92,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.bottomSheetTheme.backgroundColor ??
                      (is3DTheme
                          ? theme.colorScheme.surface
                          : tokens.readingSurface),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    children: [
                      // Drag handle bar
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 4),
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: tokens.readingBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CommentaryView(
                          book: book,
                          chapter: chapter,
                          verse: verse,
                          verseText: verseText,
                          isCompact: true,
                          scrollController: scrollController,
                          onExpand: () {
                            Navigator.of(context).pop(); // dismiss sheet
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => CommentaryHubScreen(
                                  book: book,
                                  chapter: chapter,
                                  verse: verse,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
