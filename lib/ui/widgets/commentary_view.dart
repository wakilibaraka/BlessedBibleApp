import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/reading_tokens.dart';
import '../../state/commentary_provider.dart';
import '../../data/localized_book_names.dart';
import '../../state/bible_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/translation_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../state/theme_provider.dart';
import '../screens/read_screen.dart' show VerseActionLogic;

import '../../models/commentary_entry.dart';
import '../../models/share_content.dart';
import '../../models/study_content_category.dart';
import 'share_sheet.dart';

import '../screens/commentary_hub_screen.dart';
import '../../state/read_location_provider.dart';
import 'commentary_prose.dart';
import 'prose_text.dart';
import '../../l10n/l10n.dart';
import '../../theme/design_tokens.dart';
import 'state_views.dart';

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
  bool _userToggledChapter = false;
  bool _showBook = false;
  bool _userToggledBook = false;
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
    final appThemeMode = ref.watch(resolvedThemeProvider);
    final is3DTheme = appThemeMode == AppThemeMode.dawn ||
        appThemeMode == AppThemeMode.lilies ||
        appThemeMode == AppThemeMode.roses ||
        appThemeMode == AppThemeMode.olives ||
        appThemeMode == AppThemeMode.dusk ||
        appThemeMode == AppThemeMode.fresh;

    final chapterNum = widget.chapter;

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

    // Eagerly resolve the initial verse if missing, without mutating state during build
    final displayVerse = widget.verse ??
        _currentVerseNum ??
        (verseEntries.isNotEmpty ? verseEntries.first.scope.verse : null);

    if (_currentVerseNum == null && displayVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentVerseNum == null) {
          setState(() {
            _currentVerseNum = displayVerse;
          });
        }
      });
    }

    final panelBackgroundColor = widget.isCompact
        ? (theme.bottomSheetTheme.backgroundColor ??
            (is3DTheme ? theme.colorScheme.surface : tokens.readingSurface))
        : theme.scaffoldBackgroundColor;

    final referenceString = localizedReference(
        displayVerse != null
            ? '$bookName $chapterNum:$displayVerse'
            : '$bookName $chapterNum',
        Localizations.localeOf(context).languageCode);

    final isBookmarked = displayVerse != null
        ? ref
            .watch(bookmarksProvider)
            .any((b) => b.endsWith('_$chapterNum:$displayVerse'))
        : ref.watch(bookmarksProvider).any((b) => b.endsWith('_$chapterNum:1'));
    final fallbackVerseText = _lookupVerseText(ref, displayVerse);
    String? finalVerseText = fallbackVerseText;

    final settings = ref.watch(readSettingsProvider);
    ref.watch(readSettingsProvider.select((s) => s.commentaryStyle));
    final activeTransId = ref.watch(activeTranslationProvider);

    if (settings.syncSavedItemsLanguage &&
        activeTransId != 'kjv' &&
        displayVerse != null) {
      final bibleState = ref.watch(bibleProvider);
      int? bookNum;
      try {
        final b = bibleState.books.firstWhere(
          (b) =>
              b.name.toLowerCase() == widget.book.toLowerCase() ||
              b.abbreviation.toLowerCase() == widget.book.toLowerCase(),
        );
        bookNum = bibleState.books.indexOf(b) + 1;
      } catch (_) {}

      if (bookNum != null) {
        final request = (
          translationId: activeTransId,
          bookNumber: bookNum,
          chapter: chapterNum,
          verse: displayVerse
        );
        final verseAsync = ref.watch(verseTranslationProvider(request));
        finalVerseText = verseAsync.value?.text ?? fallbackVerseText;
      }
    }

    final hasContent = verseEntries.isNotEmpty ||
        chapterEntries.isNotEmpty ||
        bookEntries.isNotEmpty;

    return Column(
      children: [
        // 1. OPAQUE HEADER ZONE
        Container(
          color: panelBackgroundColor,
          padding: EdgeInsets.only(
            top: widget.isCompact ? 16 : MediaQuery.paddingOf(context).top + 16,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: theme.primaryColor),
                  onPressed: () => Navigator.pop(context),
                  tooltip: context.l10n.commonBack,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.xxxl),
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
                          ? context.l10n.studyRemoveBookmark
                          : context.l10n.studyBookmarkCommentary,
                      onPressed: () {
                        VerseActionLogic.handleBookmark(context, theme, ref,
                            bookName, chapterNum, [displayVerse ?? 1]);
                      },
                    ),
                    if (widget.onExpand != null)
                      IconButton(
                        icon: Icon(Icons.open_in_full_rounded,
                            color: tokens.readingAccent, size: 20),
                        tooltip: context.l10n.studyExpandFullScreen,
                        onPressed: widget.onExpand,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Base: Scrollable Content
        Expanded(
          child: _buildScrollableContent(
            verseEntries,
            chapterEntries,
            bookEntries,
            commentaryAsync,
            hasContent,
            theme,
            tokens,
            is3DTheme,
            typography,
            finalVerseText,
            bookName,
            chapterNum,
            displayVerse,
            referenceString,
          ),
        ),
      ],
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
    String? finalVerseText,
    String bookName,
    int chapterNum,
    int? displayVerse,
    String referenceString,
  ) {
    final refined = ref.read(readSettingsProvider).commentaryStyle ==
        CommentaryStyle.refined;
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
          // Verse Card (Scrolls with content)
          if (finalVerseText != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: CommentaryVerseCard(
                  reference: referenceString,
                  verseText: finalVerseText,
                  refined: refined,
                  ink: tokens.readingInk,
                  accent: tokens.readingAccent,
                  surface: tokens.readingSurface,
                  border: tokens.readingInkMuted.withValues(alpha: 0.15),
                  shadow: context.palette.shadow,
                  typography: typography,
                  onTap: () {
                    // Dismiss commentary hub back to root
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // Jump to verse in main reader
                    openReaderAtVerse(
                      ref,
                      bookName: bookName,
                      chapter: chapterNum,
                      verse: displayVerse,
                    );
                  },
                ),
              ),
            ),
          if (commentaryAsync.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: LoadingView(),
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
                    final key = _entryKeys.putIfAbsent(index, GlobalKey.new);
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
                  title: context.l10n.studyOnThisChapter,
                  isExpanded: _userToggledChapter
                      ? _showChapter
                      : (verseEntries.isEmpty || _showChapter),
                  entries: chapterEntries,
                  typography: typography,
                  onToggle: () => setState(() {
                    final currentlyExpanded = _userToggledChapter
                        ? _showChapter
                        : (verseEntries.isEmpty || _showChapter);
                    _userToggledChapter = true;
                    _showChapter = !currentlyExpanded;
                  }),
                ),
              ),
            if (bookEntries.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildCollapsibleSection(
                  theme: theme,
                  tokens: tokens,
                  title: context.l10n.studyOnThisBook,
                  isExpanded: _userToggledBook
                      ? _showBook
                      : (verseEntries.isEmpty && chapterEntries.isEmpty ||
                          _showBook),
                  entries: bookEntries,
                  typography: typography,
                  onToggle: () => setState(() {
                    final currentlyExpanded = _userToggledBook
                        ? _showBook
                        : (verseEntries.isEmpty && chapterEntries.isEmpty ||
                            _showBook);
                    _userToggledBook = true;
                    _showBook = !currentlyExpanded;
                  }),
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
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(
            color: is3DTheme
                ? theme.colorScheme.onSurface.withValues(alpha: 0.15)
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
            context.l10n.studyNoCommentaryTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.readingInk,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.studyNoCommentaryBody,
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
          Semantics(
            button: true,
            expanded: isExpanded,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(Radii.md),
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
    final isDevotional = entry.category == StudyContentCategory.devotional;
    final isStudyNote = entry.category == StudyContentCategory.studyNote;

    final bgColor = isDevotional
        ? tokens.readingAccent.withValues(alpha: 0.05)
        : isStudyNote
            ? tokens.readingInkMuted.withValues(alpha: 0.05)
            : Colors.transparent;

    final border = isDevotional
        ? Border.all(color: tokens.readingAccent.withValues(alpha: 0.2))
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: bgColor,
        border: border,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: _buildEntryContent(theme, tokens, entry, typography),
    );
  }

  void _shareEntry(CommentaryEntry entry) => shareCommentaryEntry(
        context,
        entry,
        book: widget.book,
        chapter: widget.chapter,
      );

  Widget _buildEntryContent(ThemeData theme, ReadingTokens tokens,
      CommentaryEntry entry, TypographyState typography) {
    final isDevotional = entry.category == StudyContentCategory.devotional;
    final isStudyNote = entry.category == StudyContentCategory.studyNote;

    final baseStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: typography.fontSize,
      height: typography.lineHeight,
      fontFamily: typography.fontFamily,
      fontStyle: typography.fontStyle,
      color: tokens.readingInk,
    );

    IconData sourceIcon = Icons.library_books_rounded;
    if (isDevotional) sourceIcon = Icons.favorite_rounded;
    if (isStudyNote) sourceIcon = Icons.edit_note_rounded;

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sourceIcon, size: 16, color: tokens.readingAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.source.isNotEmpty
                      ? entry.source
                      : context.l10n.studyCommentaryEyebrow,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: tokens.readingAccent,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                entry.author,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tokens.readingInkMuted,
                ),
              ),
              IconButton(
                tooltip: context.l10n.commonShare,
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                icon: Icon(
                  Icons.ios_share_rounded,
                  color: tokens.readingAccent.withValues(alpha: 0.8),
                ),
                onPressed: () => _shareEntry(entry),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProseText(
            text: entry.text,
            typography: typography,
            accent: tokens.readingAccent,
            baseStyle: baseStyle,
            refined: ref.read(readSettingsProvider).commentaryStyle ==
                CommentaryStyle.refined,
          ),
        ],
      ),
    );
  }
}

/// Reference shown on the share sheet for an entry's scope: verse, chapter,
/// whole book or a free-standing study note.
String commentaryEntryReference(CommentaryEntry entry,
    {required String book, required int chapter}) {
  final scope = entry.scope;
  final verse = scope.verse;
  if (scope.type == 'verse' && verse != null) return '$book $chapter:$verse';
  if (scope.type == 'chapter') return '$book $chapter';
  if (scope.type == 'book') return book;
  return entry.source.isNotEmpty ? entry.source : book;
}

/// Opens the share sheet (text, image card or PDF) for one commentary entry.
void shareCommentaryEntry(
  BuildContext context,
  CommentaryEntry entry, {
  required String book,
  required int chapter,
}) {
  showShareSheet(
    context: context,
    content: ShareContent.commentary(
      text: entry.text,
      reference: commentaryEntryReference(entry, book: book, chapter: chapter),
      source: entry.source,
      author: entry.author,
      eyebrow: context.l10n.studyCommentaryEyebrow.toUpperCase(),
    ),
  );
}

/// Utility function to display the commentary in a compact, draggable modal bottom sheet.
void showCommentaryBottomSheet(
  BuildContext context, {
  required String book,
  required int chapter,
  int? verse,
  String? verseText,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.palette.scrim,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final tokens = Theme.of(context).extension<ReadingTokens>()!;
          final theme = Theme.of(context);
          final appThemeMode = ref.watch(resolvedThemeProvider);
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
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Radii.xxxl)),
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
                            borderRadius: BorderRadius.circular(Radii.xs),
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
                              CupertinoPageRoute<void>(
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
