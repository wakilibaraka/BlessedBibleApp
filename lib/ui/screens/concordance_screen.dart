import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' show Database;

import '../../data/bible_books.dart';
import '../../services/bible_database_service.dart';
import '../../services/translation_downloader.dart';
import '../../services/translation_pack_store.dart';
import '../../state/read_location_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/translation_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import '../../l10n/tr_text.dart';
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
  ConsumerState<ConcordanceScreen> createState() =>
      _ConcordanceScreenState();

  /// Letters, spaces and internal apostrophes/hyphens — so accented words
  /// (gracia, înțelepciune) and short phrases both pass, while a bare
  /// punctuation-only query is still rejected instead of scanning the bible.
  static final _queryPattern =
      RegExp(r"^[\p{L}][\p{L}\s'’-]*$", unicode: true);

  /// Whether [query] is worth a bible scan.
  static bool isSearchableQuery(String query) =>
      _queryPattern.hasMatch(query.trim().toLowerCase());

  /// Word-boundary match that also treats apostrophes/hyphens as internal,
  /// so "don't" or "au-dessus" don't false-match across the separator.
  /// Multi-word queries match runs of whitespace between words.
  static RegExp phraseMatcher(String query) => RegExp(
      '(?<![\\p{L}])'
      '${query.trim().toLowerCase().split(RegExp(r'\s+')).map(RegExp.escape).join(r'\s+')}'
      r'(?![\p{L}])',
      caseSensitive: false,
      unicode: true);
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

  String get reference =>
      '${kBibleBookNames[bookNumber - 1]} $chapter:$verse';
}

class _ConcordanceScreenState extends ConsumerState<ConcordanceScreen> {
  static const _limit = 200;

  final _controller = TextEditingController();
  List<_ConcordanceHit>? _hits;
  bool _searching = false;
  bool _truncated = false;
  String _searched = '';
  String _translationId = 'kjv';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Human-readable name for a translation id, from the download registry.
  String _translationName(String id) {
    if (id == 'kjv') return 'KJV';
    if (id == 'kjv_strongs') return "KJV with Strong's";
    for (final t in TranslationDownloader.downloadableTranslations) {
      if ((t['id'] as String?) == id) {
        return context.tr(t['name'] as String? ?? id);
      }
    }
    return id;
  }

  /// The database holding [translationId]'s text: the core database for
  /// KJV/KJV-Strong's, otherwise the installed pack. Falls back to KJV when
  /// the pack is missing so the screen never goes blank.
  Future<Database> _databaseFor(String translationId) async {
    if (TranslationPackStore.isCoreId(translationId)) {
      return bibleDbService.database;
    }
    try {
      return await TranslationPackStore().openPack(translationId);
    } catch (_) {
      return bibleDbService.database;
    }
  }

  Future<void> _search(String raw) async {
    final word = raw.trim().toLowerCase();
    if (!ConcordanceScreen.isSearchableQuery(word)) {
      setState(() {
        _hits = null;
        _searched = raw.trim();
      });
      return;
    }
    final translationId = ref.read(activeTranslationProvider);
    final searchable =
        TranslationPackStore.isCoreId(translationId) ? 'kjv' : translationId;
    setState(() {
      _searching = true;
      _searched = word;
      _translationId = searchable;
    });
    final boundary = ConcordanceScreen.phraseMatcher(word);
    final hits = <_ConcordanceHit>[];
    try {
      final db = await _databaseFor(translationId);
      final rows = await db.query(
        'verses',
        columns: const ['book_number', 'chapter', 'verse', 'text'],
        where: 'translation_id = ? AND text LIKE ?',
        whereArgs: [searchable, '%$word%'],
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
        appBar: const SharedAppBar(title: TrText('Concordance')),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 140),
                children: [
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: context.tr('Type a word (e.g., grace, covenant)…'),
                      prefixIcon:
                          const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: theme.dividerColor),
                      ),
                    ),
                    onSubmitted: _search,
                  ),
                  const SizedBox(height: 8),
                  TrText('Occurrences in {0} — tap a verse to read it in context.',
                    args: [_translationName(_translationId)],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_searching)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                          child: CircularProgressIndicator()),
                    )
                  else if (_hits == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: TrText(
                        _searched.isEmpty
                            ? 'Every verse containing your word, in canonical order.'
                            : 'Enter a word or phrase to search.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  else if (_hits!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: TrText('No verses contain "{0}".', args: [_searched],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  else ...[
                    TrText('{0} verse{1}{2}', args: [_hits!.length, _hits!.length == 1 ? '' : 's', _truncated ? ' (first $_limit shown)' : ''],
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
            TrText(
              hit.reference,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            TrText(
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
