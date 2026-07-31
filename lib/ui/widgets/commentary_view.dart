import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/reading_tokens.dart';
import '../../state/commentary_provider.dart';
import '../../state/bible_provider.dart';
import '../../models/commentary_entry.dart';
import 'textured_glass_container.dart';
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
        (b) => b.name.toLowerCase() == widget.book.toLowerCase() || b.abbreviation.toLowerCase() == widget.book.toLowerCase(),
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

    final bookName = widget.book;
    final chapterNum = widget.chapter;
    final displayVerse = widget.verse ?? _currentVerseNum;

    final referenceString = displayVerse != null
        ? '$bookName $chapterNum:$displayVerse'
        : '$bookName $chapterNum';

    final isBookmarked = ref.read(commentaryBookmarksProvider.notifier).isBookmarked(bookName, chapterNum, displayVerse);
    final fetchedVerseText = _lookupVerseText(ref, displayVerse);

    List<CommentaryEntry> verseEntries = [];
    List<CommentaryEntry> chapterEntries = [];
    List<CommentaryEntry> bookEntries = [];

    if (widget.verse != null) {
      verseEntries = commentaryNotifier.commentaryForVerse(bookName, chapterNum, widget.verse!);
    } else {
      verseEntries = commentaryNotifier.commentaryForChapterVerses(bookName, chapterNum);
    }
    chapterEntries = commentaryNotifier.commentaryForChapter(bookName, chapterNum);
    bookEntries = commentaryNotifier.commentaryForBook(bookName);

    final hasContent = verseEntries.isNotEmpty || chapterEntries.isNotEmpty || bookEntries.isNotEmpty;

    return PinchToZoomFontWrapper(
      child: Column(
        children: [
          // Pinned Header Section
          Container(
            color: tokens.readingSurface, // Ensure header is opaque
            padding: EdgeInsets.fromLTRB(
              widget.isCompact ? 20 : 68, // Leave room for back button if full screen
              widget.isCompact ? 16 : MediaQuery.paddingOf(context).top + 8, 
              20, 
              16
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        referenceString,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tokens.readingAccent,
                        ),
                      ),
                    ),
                    // Bookmark toggle button
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: isBookmarked ? tokens.readingAccent : tokens.readingInkMuted,
                      ),
                      tooltip: isBookmarked ? 'Remove Bookmark' : 'Bookmark Commentary',
                      onPressed: () {
                        ref.read(commentaryBookmarksProvider.notifier).toggleBookmark(bookName, chapterNum, displayVerse);
                      },
                    ),
                    // Expand button in compact mode
                    if (widget.isCompact && widget.onExpand != null)
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
                if (fetchedVerseText != null)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.readingSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: tokens.readingBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '"$fetchedVerseText"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                        color: tokens.readingInk,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Scrollable Content
          Expanded(
            child: NotificationListener<ScrollNotification>(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: _buildEmptyState(theme, tokens),
                      ),
                    )
                  else ...[
                    if (verseEntries.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final key = _entryKeys.putIfAbsent(index, () => GlobalKey());
                            return Padding(
                              key: key,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: _buildEntryCard(theme, tokens, verseEntries[index]),
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
                          onToggle: () => setState(() => _showBook = !_showBook),
                        ),
                      ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 60)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ReadingTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.readingSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.readingBorder),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 56, color: tokens.readingAccent.withValues(alpha: 0.4)),
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
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: RepaintBoundary(
        child: TexturedGlassContainer(
          isScrollable: true,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
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
                      Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: tokens.readingAccent),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                  child: Column(
                    children: entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: _buildEntryContent(theme, tokens, entry),
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(ThemeData theme, ReadingTokens tokens, CommentaryEntry entry) {
    return RepaintBoundary(
      child: TexturedGlassContainer(
        isScrollable: true,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildEntryContent(theme, tokens, entry),
        ),
      ),
    );
  }

  Widget _buildEntryContent(ThemeData theme, ReadingTokens tokens, CommentaryEntry entry) {
    final paragraphs = entry.text.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...paragraphs.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            p.trim(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.7,
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
      final tokens = Theme.of(context).extension<ReadingTokens>()!;
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: tokens.readingSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
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
}
