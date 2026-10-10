import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/bible_books.dart';
import '../../services/bible_database_service.dart';
import '../../state/read_location_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import '../../l10n/l10n.dart';

/// Standalone concordance (V2): word -> every KJV verse containing it.
///
/// Dictionary answers "what does it mean"; this answers "where else
/// does it occur". KJV-anchored like print concordances and Strong's
/// tooling; tapping a result jumps the reader to that verse in the
/// active translation.
class ConcordanceScreen extends ConsumerStatefulWidget {
  const ConcordanceScreen({super.key});

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
}

class _ConcordanceScreenState extends ConsumerState<ConcordanceScreen> {
  static const _limit = 200;

  final _controller = TextEditingController();
  List<_ConcordanceHit>? _hits;
  bool _searching = false;
  bool _truncated = false;
  String _searched = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String raw) async {
    final word = raw.trim().toLowerCase();
    if (!RegExp(r'^[a-z]+$').hasMatch(word)) {
      setState(() {
        _hits = null;
        _searched = raw.trim();
      });
      return;
    }
    setState(() {
      _searching = true;
      _searched = word;
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
      // Offline DB hiccup: fall through to the honest error state.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SharedAppBar(title: Text(context.l10n.studyConcordanceEyebrow)),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                children: [
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: context.l10n.studyConcordanceHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    onSubmitted: _search,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.studyConcordanceIntro,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_searching)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_hits == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        _searched.isEmpty
                            ? context.l10n.studyConcordanceEmpty
                            : context.l10n.studyConcordanceSingleWord,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  else if (_hits!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        context.l10n.studyConcordanceNoVerses(_searched),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      _truncated
                          ? context.l10n.studyConcordanceCountTruncated(
                              _hits!.length, _limit)
                          : context.l10n.studyConcordanceCount(_hits!.length),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final hit in _hits!)
                      _HitRow(hit: hit, onTap: () => _openHit(hit)),
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

class _HitRow extends StatelessWidget {
  final _ConcordanceHit hit;
  final VoidCallback onTap;

  const _HitRow({required this.hit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hit.reference,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hit.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
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
