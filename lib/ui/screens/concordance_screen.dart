import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/bible_books.dart';
import '../../data/concordance_terms.dart';
import '../../services/bible_database_service.dart';
import '../../state/read_location_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import '../../l10n/l10n.dart';
import '../../theme/design_tokens.dart';

/// Standalone concordance (V2): word -> every KJV verse containing it.
///
/// Features:
/// - Curated directory of prominent Biblical keywords with occurrence counts
/// - Category browsing (Salvation, Spiritual Life, Christian Walk, God & Spirit)
/// - Instant search across KJV verses
/// - Testament filtering (All, Old Testament, New Testament)
/// - Matched keyword highlighting in verse text
/// - Deep-linking to verse in Bible reader
class ConcordanceScreen extends ConsumerStatefulWidget {
  final String? initialWord;

  const ConcordanceScreen({super.key, this.initialWord});

  @override
  ConsumerState<ConcordanceScreen> createState() => _ConcordanceScreenState();
}

class _ConcordanceHit {
  final int bookNumber;
  final int chapter;
  final int verse;
  final String text;

  const _ConcordanceHit({
    required this.bookNumber,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  String get reference => '${kBibleBookNames[bookNumber - 1]} $chapter:$verse';
  bool get isOldTestament => bookNumber <= 39;
}

enum _TestamentFilter { all, ot, nt }

class _ConcordanceScreenState extends ConsumerState<ConcordanceScreen> {
  static const _limit = 250;

  final _controller = TextEditingController();
  List<_ConcordanceHit>? _hits;
  bool _searching = false;
  bool _truncated = false;
  String _searched = '';
  String _selectedCategory = 'All';
  _TestamentFilter _testamentFilter = _TestamentFilter.all;

  @override
  void initState() {
    super.initState();
    if (widget.initialWord != null && widget.initialWord!.isNotEmpty) {
      _controller.text = widget.initialWord!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _search(widget.initialWord!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _hits = null;
      _searched = '';
      _searching = false;
      _testamentFilter = _TestamentFilter.all;
    });
  }

  Future<void> _search(String raw) async {
    final clean = raw.trim().toLowerCase();
    final word = clean.split(RegExp(r'\s+')).first;
    if (word.isEmpty) {
      _clearSearch();
      return;
    }

    if (!RegExp(r'^[a-z]+$').hasMatch(word)) {
      setState(() {
        _hits = null;
        _searched = word;
      });
      return;
    }

    setState(() {
      _searching = true;
      _searched = word;
      _testamentFilter = _TestamentFilter.all;
    });

    final boundary =
        RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false);
    final hits = <_ConcordanceHit>[];
    try {
      final db = await bibleDbService.database;
      final rows = await db.query(
        'verses',
        columns: const ['book_number', 'chapter', 'verse', 'text'],
        where: "translation_id = 'kjv' AND text LIKE ?",
        whereArgs: ['%$word%'],
        limit: _limit + 1,
      );
      for (final r in rows) {
        final text =
            (r['text'] as String).replaceAll(RegExp(r'\[[HG]\d+\]'), '');
        if (!boundary.hasMatch(text)) continue;
        hits.add(_ConcordanceHit(
          bookNumber: r['book_number'] as int,
          chapter: r['chapter'] as int,
          verse: r['verse'] as int,
          text: text,
        ));
        if (hits.length > _limit) break;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _hits = null;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _searching = false;
      _truncated = hits.length > _limit;
      _hits = hits.take(_limit).toList();
    });
  }

  void _openHit(_ConcordanceHit hit) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    openReaderAtVerse(
      ref,
      bookName: kBibleBookNames[hit.bookNumber - 1],
      chapter: hit.chapter,
      verse: hit.verse,
    );
  }

  List<_ConcordanceHit> get _filteredHits {
    if (_hits == null) return const [];
    switch (_testamentFilter) {
      case _TestamentFilter.all:
        return _hits!;
      case _TestamentFilter.ot:
        return _hits!.where((h) => h.isOldTestament).toList();
      case _TestamentFilter.nt:
        return _hits!.where((h) => !h.isOldTestament).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final l10n = context.l10n;

    final categories = const [
      'All',
      'Salvation',
      'Spiritual Life',
      'Christian Walk',
      'God & Spirit',
    ];

    final filteredTerms = _selectedCategory == 'All'
        ? kConcordanceTerms
        : kConcordanceTerms
            .where((t) => t.category == _selectedCategory)
            .toList();

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SharedAppBar(title: Text(l10n.studyConcordanceEyebrow)),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                children: [
                  // 1. Search Input Bar
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.studyConcordanceHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              tooltip: l10n.studyConcordanceClear,
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.lg),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.lg),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    onSubmitted: _search,
                    onChanged: (val) {
                      if (val.isEmpty && _hits != null) {
                        _clearSearch();
                      } else {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.studyConcordanceIntro,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Loading State
                  if (_searching)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  // 3. Search Results State
                  else if (_hits != null) ...[
                    if (_hits!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.studyConcordanceNoVerses(_searched),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.arrow_back_rounded,
                                    size: 16),
                                label: Text(l10n.studyConcordanceBrowseAll),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // Summary row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _truncated
                                  ? l10n.studyConcordanceCountTruncated(
                                      _hits!.length, _limit)
                                  : l10n.studyConcordanceCount(_hits!.length),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: Text(l10n.studyConcordanceClear),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Testament Filter Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text(l10n.studyConcordanceFilterAll),
                              selected:
                                  _testamentFilter == _TestamentFilter.all,
                              onSelected: (_) => setState(() =>
                                  _testamentFilter = _TestamentFilter.all),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(l10n.studyConcordanceFilterOT),
                              selected: _testamentFilter == _TestamentFilter.ot,
                              onSelected: (_) => setState(() =>
                                  _testamentFilter = _TestamentFilter.ot),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(l10n.studyConcordanceFilterNT),
                              selected: _testamentFilter == _TestamentFilter.nt,
                              onSelected: (_) => setState(() =>
                                  _testamentFilter = _TestamentFilter.nt),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Hits List
                      for (final hit in _filteredHits)
                        _HitRow(
                          hit: hit,
                          highlightWord: _searched,
                          onTap: () => _openHit(hit),
                        ),
                    ],
                  ]
                  // 4. Default Browsable Directory (Actual Content!)
                  else ...[
                    // Quick-tap suggested chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final term in kConcordanceTerms.take(8)) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(
                                  '${term.word[0].toUpperCase()}${term.word.substring(1)} (${term.countKjv})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: TypeScale.caption,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  _controller.text = term.word;
                                  _search(term.word);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section Heading: Featured Biblical Terms
                    Text(
                      l10n.studyConcordanceFeatured,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final cat in categories) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: _selectedCategory == cat,
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() => _selectedCategory = cat);
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Grid/List of Terms
                    for (final term in filteredTerms)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TermTile(
                          term: term,
                          onTap: () {
                            _controller.text = term.word;
                            _search(term.word);
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rich tile representing a concordance headword with verified count and definition.
class _TermTile extends StatelessWidget {
  final ConcordanceTerm term;
  final VoidCallback onTap;

  const _TermTile({required this.term, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final capitalized =
        '${term.word[0].toUpperCase()}${term.word.substring(1)}';

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.lg),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            capitalized,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(Radii.sm),
                            ),
                            child: Text(
                              '${term.countKjv} verses',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: TypeScale.micro,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            term.keyVerse,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        term.definition,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.primaryColor.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Single verse occurrence row with keyword highlighting.
class _HitRow extends StatelessWidget {
  final _ConcordanceHit hit;
  final String highlightWord;
  final VoidCallback onTap;

  const _HitRow({
    required this.hit,
    required this.highlightWord,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build highlighted text spans
    final spans = <InlineSpan>[];
    final text = hit.text;
    final regex =
        RegExp('\\b${RegExp.escape(highlightWord)}\\b', caseSensitive: false);
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: theme.textTheme.bodyMedium,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
          decoration: TextDecoration.underline,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: theme.textTheme.bodyMedium,
      ));
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  hit.reference,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text(
                    hit.isOldTestament ? 'OT' : 'NT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: TypeScale.micro,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(children: spans),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
