// ─────────────────────────────────────────────────────────────────────────────
// PlanReaderScreen — in-plan passage reader
//
// Architecture (anti-crash):
//   • ConsumerStatefulWidget pushed as its own route — NO ReadScreen reuse.
//   • Passage flow: setState(_passageIndex) over List<_PassageData> in memory.
//     NO PageView, NO PageController, NO route-push per passage.
//   • Verse list: plain ListView.builder — NO ScrollablePositionedList.
//   • NO synchronous scrollTo during layout. ListView.builder with ValueKey
//     resets scroll naturally on passage change — no controller needed.
//   • highlights/bookmarks resolved before the itemBuilder lambda; they are
//     not watched inside the builder (no Consumer inside list builder).
//   • Verse keys: generateVerseKey(book.abbreviation, chapterNum, verseNum)
//     — identical to main reader → highlights/bookmarks are shared.
//   • VerseActionLogic static methods reused directly.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bible_model.dart';
import '../../state/bible_provider.dart';
import '../../state/reading_plan_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/theme_provider.dart';
import '../../theme/app_colors.dart';
import 'read_screen.dart' show VerseActionLogic, CommentaryBottomSheetContent;

// ─────────────────────────────────────────────────────────────────────────────
// Data model for one resolved passage
// ─────────────────────────────────────────────────────────────────────────────

class _PassageData {
  final String label;
  final BibleBook book;
  final BibleChapter chapter;
  final int chapterNum;
  final int? startVerse;
  final int? endVerse;

  const _PassageData({
    required this.label,
    required this.book,
    required this.chapter,
    required this.chapterNum,
    this.startVerse,
    this.endVerse,
  });

  List<BibleVerse> get assignedVerses {
    if (startVerse == null) return chapter.verses;
    final s = (startVerse! - 1).clamp(0, chapter.verses.length - 1);
    final e = (endVerse ?? chapter.verses.length).clamp(s, chapter.verses.length);
    return chapter.verses.sublist(s, e);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ref-string parsing
// ─────────────────────────────────────────────────────────────────────────────

class _ParsedRef {
  final String bookName;
  final int chapter;
  final int? startVerse;
  final int? endVerse;
  const _ParsedRef({required this.bookName, required this.chapter, this.startVerse, this.endVerse});
}

_ParsedRef? _parseRef(String ref) {
  final re = RegExp(r'^(.+?)\s+(\d+)(?::(\d+)(?:-(\d+))?)?$');
  final m = re.firstMatch(ref.trim());
  if (m == null) return null;
  return _ParsedRef(
    bookName: m.group(1)!.trim(),
    chapter: int.parse(m.group(2)!),
    startVerse: m.group(3) != null ? int.tryParse(m.group(3)!) : null,
    endVerse: m.group(4) != null ? int.tryParse(m.group(4)!) : null,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen Widget
// ─────────────────────────────────────────────────────────────────────────────

class PlanReaderScreen extends ConsumerStatefulWidget {
  final int dayNum;
  final int initialPassageIndex;

  const PlanReaderScreen({
    super.key,
    required this.dayNum,
    required this.initialPassageIndex,
  });

  @override
  ConsumerState<PlanReaderScreen> createState() => _PlanReaderScreenState();
}

class _PlanReaderScreenState extends ConsumerState<PlanReaderScreen> {
  late int _passageIndex;
  bool _showFullChapter = false;
  final Set<int> _selectedVerses = {};
  List<_PassageData> _passages = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _passageIndex = widget.initialPassageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resolvePassages();
    });
  }

  void _resolvePassages() {
    final planState = ref.read(readingPlanProvider);
    if (planState.planData.isEmpty || widget.dayNum > planState.planData.length) return;
    final dayData = planState.planData[widget.dayNum - 1];
    final flatChapters = ref.read(flatChaptersProvider);
    if (flatChapters.isEmpty) return;

    final resolved = <_PassageData>[];
    for (final passage in dayData.passages) {
      for (final refStr in passage.refs) {
        final parsed = _parseRef(refStr);
        if (parsed == null) continue;

        BibleBook? book;
        try {
          book = flatChapters
              .map((fc) => fc.book)
              .firstWhere((b) => b.name.toLowerCase() == parsed.bookName.toLowerCase());
        } catch (_) {
          try {
            book = flatChapters
                .map((fc) => fc.book)
                .firstWhere((b) => b.name.toLowerCase().startsWith(parsed.bookName.toLowerCase()));
          } catch (_) {
            continue;
          }
        }

        final chapIdx = parsed.chapter - 1;
        if (chapIdx < 0 || chapIdx >= book.chapters.length) continue;
        final chapter = book.chapters[chapIdx];

        String label;
        if (parsed.startVerse != null && parsed.endVerse != null) {
          label = '${book.name} ${parsed.chapter}:${parsed.startVerse}–${parsed.endVerse}';
        } else if (parsed.startVerse != null) {
          label = '${book.name} ${parsed.chapter}:${parsed.startVerse}';
        } else {
          label = '${book.name} ${parsed.chapter}';
        }

        resolved.add(_PassageData(
          label: label,
          book: book,
          chapter: chapter,
          chapterNum: parsed.chapter,
          startVerse: parsed.startVerse,
          endVerse: parsed.endVerse,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _passages = resolved;
        _passageIndex = widget.initialPassageIndex.clamp(0, (resolved.length - 1).clamp(0, resolved.length));
        _loaded = true;
      });
    }
  }

  _PassageData? get _current => (_loaded && _passages.isNotEmpty && _passageIndex < _passages.length)
      ? _passages[_passageIndex]
      : null;

  bool get _isLastPassage => _passageIndex >= _passages.length - 1;

  void _goToPassage(int idx) {
    if (idx < 0 || idx >= _passages.length) return;
    HapticFeedback.lightImpact();
    setState(() {
      _passageIndex = idx;
      _selectedVerses.clear();
    });
  }

  void _markReadAndPop() {
    HapticFeedback.mediumImpact();
    ref.read(readingPlanProvider.notifier).markReadingComplete(widget.dayNum);
    if (mounted) Navigator.of(context).pop();
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

  void _showCommentary(int verseNum, String verseText, String bookName, int chapterNum) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CommentaryBottomSheetContent(
        bookName: bookName,
        chapter: chapterNum,
        verseNumber: verseNum,
        verseText: verseText,
      ),
    );
  }

  // ── Color palette bottom sheet (highlight bug fix) ─────────────────────────
  // Root cause: the _VerseActionBar used a single IconButton that called
  // handleHighlight with a fixed color index — the palette was never shown.
  // Fix: show a palette sheet with the same colors as the main reader.
  void _showHighlightPalette(List<int> targetVerses, String bookName, int chapterNum) {
    final theme = Theme.of(context);
    final gold = AppColors.goldAccent;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(highlightPalette.length, (i) {
                  final color = AppColors.getRenderedHighlightColor(
                      highlightPalette[i], theme.brightness, theme.scaffoldBackgroundColor);
                  return GestureDetector(
                    onTap: () {
                      ref.read(readSettingsProvider.notifier).setActiveHighlightColorIndex(i);
                      VerseActionLogic.handleHighlight(ctx, theme, ref, bookName, chapterNum, targetVerses, i);
                      Navigator.of(ctx).pop();
                      _clearSelection();
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
                            border: Border.all(color: gold.withValues(alpha: 0.3), width: 1.5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(highlightPaletteNames[i],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            )),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = AppColors.goldAccent;
    final typography = ref.watch(typographyProvider);
    final readSettings = ref.watch(readSettingsProvider);
    final appThemeMode = ref.watch(themeProvider);
    final isDone = ref.watch(readingPlanProvider).completedReadings.contains(widget.dayNum);

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

    if (_passages.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Passage not found'), backgroundColor: Colors.transparent),
        body: const Center(child: Text('Could not load passage data.')),
      );
    }

    final passage = _current!;
    final verses = _showFullChapter ? passage.chapter.verses : passage.assignedVerses;
    // Resolve highlights/bookmarks once before the builder — never inside it
    final highlights = ref.watch(highlightsProvider);
    final bookmarks = ref.watch(bookmarksProvider);

    // ── Nav footer widget (built once, appended to scroll content) ───────────
    final navFooter = Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 40),
      child: Row(
        children: [
          if (_passageIndex > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: OutlinedButton(
                onPressed: () => _goToPassage(_passageIndex - 1),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: gold),
                  foregroundColor: gold,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
          Expanded(
            child: _isLastPassage
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDone ? gold.withValues(alpha: 0.6) : gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isDone ? null : _markReadAndPop,
                    child: Text(
                      isDone ? '✓ Completed' : 'Mark as Read',
                      style: const TextStyle(
                          fontFamily: 'EB Garamond', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _goToPassage(_passageIndex + 1),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Next Passage',
                            style: TextStyle(
                                fontFamily: 'EB Garamond', fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          // ── Compact top bar ──────────────────────────────────────────────
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Passage counter — centered single line
                if (_passages.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'Passage ${_passageIndex + 1} of ${_passages.length}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: gold.withValues(alpha: 0.75),
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                // Main row: back | reference+KJV | full-chapter toggle
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              passage.label,
                              style: TextStyle(
                                fontFamily: 'EB Garamond',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'KJV',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              letterSpacing: 1.0,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Full chapter toggle — compact pill
                    GestureDetector(
                      onTap: () => setState(() => _showFullChapter = !_showFullChapter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _showFullChapter ? gold.withValues(alpha: 0.15) : Colors.transparent,
                          border: Border.all(
                              color: _showFullChapter ? gold : theme.dividerColor, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Full chapter',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _showFullChapter
                                ? gold
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1, thickness: 0.5),
              ],
            ),
          ),

          // ── Verse action bar (visible only when verses selected) ─────────
          if (_selectedVerses.isNotEmpty)
            _VerseActionBar(
              selectedVerses: _selectedVerses.toList()..sort(),
              bookName: passage.book.name,
              bookAbbrev: passage.book.abbreviation,
              chapterNum: passage.chapterNum,
              onDismiss: _clearSelection,
              onHighlight: () => _showHighlightPalette(
                  _selectedVerses.toList()..sort(), passage.book.name, passage.chapterNum),
              onCommentary: (verseNum) {
                final vIdx = verseNum - 1;
                final verseText = vIdx >= 0 && vIdx < passage.chapter.verses.length
                    ? passage.chapter.verses[vIdx].text
                    : '';
                _showCommentary(verseNum, verseText, passage.book.name, passage.chapterNum);
                _clearSelection();
              },
            ),

          // ── Verse list + nav footer ──────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < -300 && !_isLastPassage) {
                  _goToPassage(_passageIndex + 1);
                } else if (details.primaryVelocity! > 300 && _passageIndex > 0) {
                  _goToPassage(_passageIndex - 1);
                }
              },
              child: ListView.builder(
                // ValueKey resets scroll to top on passage/toggle change — no scrollTo needed
                key: ValueKey('$_passageIndex-$_showFullChapter'),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                // +1 for the nav footer appended after the last verse
                itemCount: verses.length + 1,
                itemBuilder: (context, i) {
                  // Last item = nav footer (next/mark-as-read)
                  if (i == verses.length) return navFooter;

                  final verse = verses[i];
                  final verseKey = generateVerseKey(
                      passage.book.abbreviation, passage.chapterNum, verse.number);
                  final isSelected = _selectedVerses.contains(verse.number);
                  final isBookmarked = bookmarks.contains(verseKey);
                  final savedColorIdx = highlights[verseKey];
                  Color? highlightColor;
                  if (savedColorIdx != null &&
                      savedColorIdx >= 0 &&
                      savedColorIdx < highlightPalette.length) {
                    highlightColor = AppColors.getRenderedHighlightColor(
                        highlightPalette[savedColorIdx],
                        theme.brightness,
                        theme.scaffoldBackgroundColor);
                  }

                  return GestureDetector(
                    onTap: () => _toggleVerseSelection(verse.number),
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _selectedVerses.add(verse.number));
                      // Immediately show palette on long-press (same as main reader)
                      _showHighlightPalette(
                          [verse.number], passage.book.name, passage.chapterNum);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (highlightColor != null
                                ? highlightColor.withValues(alpha: 0.4)
                                : theme.primaryColor.withValues(alpha: 0.15))
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
                          decoration: isBookmarked ? TextDecoration.underline : null,
                          decorationColor: isBookmarked ? theme.primaryColor : null,
                          decorationThickness: 2.0,
                        );

                        final List<TextSpan> spans = [];
                        final redStyle = fontStyle.copyWith(color: redLetterColor);
                        String text = verse.text;
                        int cur = 0;
                        while (cur < text.length) {
                          final s = text.indexOf('‹', cur);
                          if (s == -1) {
                            spans.add(TextSpan(text: text.substring(cur), style: fontStyle));
                            break;
                          }
                          if (s > cur) {
                            spans.add(TextSpan(text: text.substring(cur, s), style: fontStyle));
                          }
                          final e = text.indexOf('›', s + 1);
                          if (e == -1) {
                            spans.add(TextSpan(
                                text: text.substring(s + 1),
                                style: readSettings.isRedLetterEnabled ? redStyle : fontStyle));
                            break;
                          }
                          spans.add(TextSpan(
                              text: text.substring(s + 1, e),
                              style: readSettings.isRedLetterEnabled ? redStyle : fontStyle));
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
                                    fontSize: typography.fontSize * 0.75,
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
          ),
        ],
      ),
    );
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
  final void Function(int verseNum) onCommentary;

  const _VerseActionBar({
    required this.selectedVerses,
    required this.bookName,
    required this.bookAbbrev,
    required this.chapterNum,
    required this.onDismiss,
    required this.onHighlight,
    required this.onCommentary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gold = AppColors.goldAccent;

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.close_rounded, size: 20), onPressed: onDismiss),
          Text('${selectedVerses.length} selected', style: theme.textTheme.labelMedium),
          const Spacer(),
          // Highlight — opens color palette sheet
          IconButton(
            tooltip: 'Highlight',
            icon: Icon(Icons.highlight_rounded, color: gold),
            onPressed: onHighlight,
          ),
          // Bookmark
          IconButton(
            tooltip: 'Bookmark',
            icon: Icon(Icons.bookmark_rounded, color: gold),
            onPressed: () {
              VerseActionLogic.handleBookmark(context, theme, ref, bookName, chapterNum, selectedVerses);
              onDismiss();
            },
          ),
          // Note
          IconButton(
            tooltip: 'Add Note',
            icon: Icon(Icons.note_add_rounded, color: gold),
            onPressed: () async {
              await VerseActionLogic.handleNote(context, ref, theme, bookName, chapterNum, selectedVerses);
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
              await VerseActionLogic.handleShare(context, ref, bookName, chapterNum, selectedVerses);
              onDismiss();
            },
          ),
        ],
      ),
    );
  }
}
