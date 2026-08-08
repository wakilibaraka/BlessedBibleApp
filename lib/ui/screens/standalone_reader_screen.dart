import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bible_model.dart';
import '../../state/bible_provider.dart';
import '../../state/read_settings_provider.dart';
import '../widgets/textured_glass_container.dart';
import '../../state/typography_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/commentary_view.dart';
import '../../theme/app_colors.dart';
import 'read_screen.dart' show VerseActionLogic;
import '../sheets/verse_context_menu_sheet.dart';

class StandaloneReaderScreen extends ConsumerStatefulWidget {
  final String bookName;
  final int chapterNum;
  final int? verseNum;

  const StandaloneReaderScreen({
    super.key,
    required this.bookName,
    required this.chapterNum,
    this.verseNum,
  });

  @override
  ConsumerState<StandaloneReaderScreen> createState() => _StandaloneReaderScreenState();
}

class _StandaloneReaderScreenState extends ConsumerState<StandaloneReaderScreen> {
  final Set<int> _selectedVerses = {};
  BibleBook? _book;
  BibleChapter? _chapter;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resolvePassage();
    });
  }

  void _resolvePassage() {
    final flatChapters = ref.read(flatChaptersProvider);
    if (flatChapters.isEmpty) return;

    BibleBook? book;
    try {
      book = flatChapters.map((fc) => fc.book).firstWhere(
          (b) => b.name.toLowerCase() == widget.bookName.toLowerCase());
    } catch (_) {
      try {
        book = flatChapters.map((fc) => fc.book).firstWhere((b) =>
            b.name.toLowerCase().startsWith(widget.bookName.toLowerCase()));
      } catch (_) {
        setState(() => _loaded = true);
        return;
      }
    }

    final chapIdx = widget.chapterNum - 1;
    if (chapIdx < 0 || chapIdx >= book.chapters.length) {
      setState(() => _loaded = true);
      return;
    }
    
    setState(() {
      _book = book;
      _chapter = book!.chapters[chapIdx];
      if (widget.verseNum != null) {
        // Gently highlight the requested verse without auto-scrolling
        _selectedVerses.add(widget.verseNum!);
      }
      _loaded = true;
    });
  }

  void _toggleVerseSelection(int verseNum) {
    setState(() {
      if (_selectedVerses.contains(verseNum)) {
        _selectedVerses.remove(verseNum);
      } else {
        _selectedVerses.add(verseNum);
      }
    });
  }

  void _clearSelection() => setState(() => _selectedVerses.clear());

  void _showCommentary(
      int verseNum, String verseText, String bookName, int chapterNum) {
    showCommentaryBottomSheet(
      context,
      book: bookName,
      chapter: chapterNum,
      verse: verseNum,
      verseText: verseText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final readSettings = ref.watch(readSettingsProvider);
    final appThemeMode = ref.watch(themeProvider);

    final resolvedMode = appThemeMode.resolve(context);
    final Color redLetterColor = resolvedMode == AppThemeMode.light
        ? const Color(0xFFB33A3A)
        : resolvedMode == AppThemeMode.sepia
            ? const Color(0xFFA63C3C)
            : const Color(0xFFD46A6A);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_book == null || _chapter == null) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('Passage not found'),
            backgroundColor: Colors.transparent),
        body: const Center(child: Text('Could not load passage data.')),
      );
    }

    final verses = _chapter!.verses;
    
    // Resolve highlights/bookmarks once before the builder
    final highlights = ref.watch(highlightsProvider);
    final bookmarks = ref.watch(bookmarksProvider);

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
          return theme.scaffoldBackgroundColor;
      }
    }

    final bool isOnlyTargetSelected = _selectedVerses.length == 1 && _selectedVerses.contains(widget.verseNum);

    return PopScope(
        canPop: _selectedVerses.isEmpty || isOnlyTargetSelected,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_selectedVerses.isNotEmpty && !isOnlyTargetSelected) {
            _clearSelection();
            if (widget.verseNum != null) {
              setState(() => _selectedVerses.add(widget.verseNum!));
            }
          } else if (isOnlyTargetSelected) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          backgroundColor: getThemeBackgroundColor(),
          body: Stack(
            children: [
              Column(
                children: [
                  // ── Compact top bar ──────────────────────────────────────────────
                  Container(
                    color: getThemeBackgroundColor(),
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_rounded,
                                      size: 22),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_book!.name} ${widget.chapterNum}',
                                        style: TextStyle(
                                          fontFamily: 'EB Garamond',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              theme.textTheme.bodyLarge?.color,
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'KJV',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                          letterSpacing: 1.0,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 1, thickness: 0.5),
                      ],
                    ),
                  ),

                  // ── Verse list ──────────────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                      itemCount: verses.length,
                      itemBuilder: (context, i) {
                        final verse = verses[i];
                        final verseKey = generateVerseKey(
                            _book!.abbreviation,
                            widget.chapterNum,
                            verse.number);
                        final isSelected =
                            _selectedVerses.contains(verse.number);
                        final isBookmarked = bookmarks.contains(verseKey);
                        final savedColorIdx = highlights[verseKey];
                        Color? highlightColor;
                        if (savedColorIdx != null &&
                            savedColorIdx >= 0 &&
                            savedColorIdx < highlightPalette.length) {
                          highlightColor =
                              AppColors.getRenderedHighlightColor(
                                  highlightPalette[savedColorIdx],
                                  theme.brightness,
                                  theme.scaffoldBackgroundColor);
                        }

                        return GestureDetector(
                          onTap: () => _toggleVerseSelection(verse.number),
                          onDoubleTap: () {
                            HapticFeedback.lightImpact();
                            VerseActionLogic.handleBookmark(
                                context,
                                theme,
                                ref,
                                _book!.name,
                                widget.chapterNum,
                                [verse.number]);
                          },
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              useRootNavigator: true,
                              builder: (ctx) => VerseContextMenuSheet(
                                verseNumber: verse.number,
                                bookName: _book!.name,
                                chapterNum: widget.chapterNum,
                                onCustomSelection: () {},
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (highlightColor != null
                                      ? highlightColor.withValues(alpha: 0.4)
                                      : theme.primaryColor
                                          .withValues(alpha: 0.15))
                                  : (highlightColor != null
                                      ? highlightColor.withValues(alpha: 0.3)
                                      : Colors.transparent),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Builder(builder: (ctx) {
                              final fontStyle = TextStyle(
                                fontFamily: 'EB Garamond',
                                fontSize: typography.fontSize,
                                height: typography.lineHeight,
                                letterSpacing: 0.15,
                                color: theme.textTheme.bodyLarge?.color,
                                decoration: isBookmarked
                                    ? TextDecoration.underline
                                    : null,
                                decorationColor:
                                    isBookmarked ? theme.primaryColor : null,
                                decorationThickness: 2.0,
                              );

                              final List<TextSpan> spans = [];
                              final redStyle =
                                  fontStyle.copyWith(color: redLetterColor);
                              String text = verse.text;
                              int cur = 0;
                              while (cur < text.length) {
                                final s = text.indexOf('‹', cur);
                                if (s == -1) {
                                  spans.add(TextSpan(
                                      text: text.substring(cur),
                                      style: fontStyle));
                                  break;
                                }
                                if (s > cur) {
                                  spans.add(TextSpan(
                                      text: text.substring(cur, s),
                                      style: fontStyle));
                                }
                                final e = text.indexOf('›', s + 1);
                                if (e == -1) {
                                  spans.add(TextSpan(
                                      text: text.substring(s + 1),
                                      style: readSettings.isRedLetterEnabled
                                          ? redStyle
                                          : fontStyle));
                                  break;
                                }
                                spans.add(TextSpan(
                                    text: text.substring(s + 1, e),
                                    style: readSettings.isRedLetterEnabled
                                        ? redStyle
                                        : fontStyle));
                                cur = e + 1;
                              }

                              return RichText(
                                text: TextSpan(
                                  style: fontStyle,
                                  children: [
                                    if (readSettings.showVerseNumbers)
                                      TextSpan(
                                        text: '${verse.number}  ',
                                        style: fontStyle.copyWith(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              typography.fontSize * 0.75,
                                        ),
                                      ),
                                    ...spans,
                                  ],
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // ── Verse action bar (bottom anchored) ───────────────────────────
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    if (child.key == const ValueKey('empty')) {
                      return const SizedBox.shrink();
                    }
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: _selectedVerses.isNotEmpty && !isOnlyTargetSelected // don't show bar if only the target verse is selected
                      ? SafeArea(
                          top: false,
                          key: const ValueKey('content'),
                          child: _VerseActionBar(
                            selectedVerses: _selectedVerses.toList()..sort(),
                            bookName: _book!.name,
                            bookAbbrev: _book!.abbreviation,
                            chapterNum: widget.chapterNum,
                            onDismiss: _clearSelection,
                            onHighlight: () =>
                                VerseActionLogic.handleHighlightInteraction(
                              context: context,
                              ref: ref,
                              theme: theme,
                              bookAbbrev: _book!.abbreviation,
                              chapterNum: widget.chapterNum,
                              targetVerses: _selectedVerses.toList()..sort(),
                              isLongPress: false,
                              onClearSelection: _clearSelection,
                            ),
                            onHighlightLongPress: () =>
                                VerseActionLogic.handleHighlightInteraction(
                              context: context,
                              ref: ref,
                              theme: theme,
                              bookAbbrev: _book!.abbreviation,
                              chapterNum: widget.chapterNum,
                              targetVerses: _selectedVerses.toList()..sort(),
                              isLongPress: true,
                              onClearSelection: _clearSelection,
                            ),
                            onCommentary: (verseNum) {
                              final vIdx = verseNum - 1;
                              final verseText = vIdx >= 0 &&
                                      vIdx < _chapter!.verses.length
                                  ? _chapter!.verses[vIdx].text
                                  : '';
                              _showCommentary(verseNum, verseText,
                                  _book!.name, widget.chapterNum);
                              _clearSelection();
                            },
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ),
            ],
          ),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verse Action Bar (no Consumer; reads/writes via passed callbacks)
// ─────────────────────────────────────────────────────────────────────────────

class _VerseActionBar extends ConsumerWidget {
  final List<int> selectedVerses;
  final String bookName;
  final String bookAbbrev;
  final int chapterNum;
  final VoidCallback onDismiss;
  final VoidCallback onHighlight;
  final VoidCallback onHighlightLongPress;
  final void Function(int verseNum) onCommentary;

  const _VerseActionBar({
    required this.selectedVerses,
    required this.bookName,
    required this.bookAbbrev,
    required this.chapterNum,
    required this.onDismiss,
    required this.onHighlight,
    required this.onHighlightLongPress,
    required this.onCommentary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gold = AppColors.goldAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
      child: TexturedGlassContainer(
        borderRadius: BorderRadius.circular(32),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('${selectedVerses.length} selected',
                  style: theme.textTheme.labelMedium),
            ),
            // Highlight — opens color palette sheet
            GestureDetector(
              onLongPress: onHighlightLongPress,
              child: IconButton(
                tooltip: 'Highlight',
                icon: Icon(Icons.highlight_rounded, color: gold),
                onPressed: onHighlight,
              ),
            ),
            // Bookmark
            IconButton(
              tooltip: 'Bookmark',
              icon: Icon(Icons.bookmark_rounded, color: gold),
              onPressed: () {
                VerseActionLogic.handleBookmark(
                    context, theme, ref, bookName, chapterNum, selectedVerses);
                onDismiss();
              },
            ),
            // Note
            IconButton(
              tooltip: 'Add Note',
              icon: Icon(Icons.note_add_rounded, color: gold),
              onPressed: () async {
                await VerseActionLogic.handleNote(
                    context, ref, theme, bookName, chapterNum, selectedVerses);
                onDismiss();
              },
            ),
            // Commentary (first selected verse)
            IconButton(
              tooltip: 'Commentary',
              icon: Icon(Icons.star_rounded, color: gold),
              onPressed: () => onCommentary(selectedVerses.first),
            ),
            // Share
            IconButton(
              tooltip: 'Share',
              icon: Icon(Icons.share_rounded, color: gold),
              onPressed: () async {
                await VerseActionLogic.handleShare(
                    context, ref, bookName, chapterNum, selectedVerses);
                onDismiss();
              },
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
