import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/commentary_entry.dart';
import '../../models/study_content_category.dart';
import '../../state/commentary_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import '../../l10n/l10n.dart';
import '../../theme/design_tokens.dart';
import '../widgets/state_views.dart';

/// Redesigned commentary library (V2).
///
/// Differences from V1 [CommentaryLibraryScreen]:
/// - Search across books (66-book list is unusable without it).
/// - Books show chapter counts + author badges, sorted with
///   content-bearing books first.
/// - Tapping a book opens a chapter sheet, then the rebuilt hub.
/// - Loading/error states are honest (V1 collapsed both to a false empty).
class CommentaryLibraryV2Screen extends ConsumerStatefulWidget {
  const CommentaryLibraryV2Screen({super.key});

  @override
  ConsumerState<CommentaryLibraryV2Screen> createState() =>
      _CommentaryLibraryV2ScreenState();
}

class _CommentaryLibraryV2ScreenState
    extends ConsumerState<CommentaryLibraryV2Screen> {
  String _query = '';
  String _selectedSource = '';

  void _openBook(String book, Map<int, int> chapterCounts) {
    final chapters = chapterCounts.keys.toList()..sort();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(Radii.xxl)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 4),
              Text(context.l10n.studyChaptersWithContent(chapters.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  )),
              const SizedBox(height: 12),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: chapters.length,
                  itemBuilder: (context, i) {
                    final ch = chapters[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(Radii.md),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(CupertinoPageRoute<void>(
                          builder: (_) => CommentaryHubV2Screen(
                            book: book,
                            chapter: ch,
                            source: _selectedSource.isEmpty
                                ? null
                                : _selectedSource,
                          ),
                        ));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Radii.md),
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '$ch',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncEntries = ref.watch(commentaryProvider);
    final appThemeMode = ref.watch(themeProvider);

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SharedAppBar(title: Text(context.l10n.studyCommentaryLibrary)),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: asyncEntries.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorState(
                  error: e,
                  message: context.l10n.studyCommentaryLoadError,
                  onRetry: () => ref.invalidate(commentaryProvider),
                ),
                data: (entries) {
                  final sources = entries.map((e) => e.source).toSet().toList()
                    ..sort();
                  final visibleEntries = _selectedSource.isEmpty
                      ? entries
                      : entries.where((e) => e.source == _selectedSource).toList();
                  // book -> chapter -> entry count
                  final Map<String, Map<int, int>> books = {};
                  final Map<String, String> authors = {};
                  for (final e in visibleEntries) {
                    final b = e.scope.book;
                    final c = e.scope.chapter;
                    if (b == null || c == null) continue;
                    books.putIfAbsent(b, () => {});
                    books[b]!.update(c, (n) => n + 1, ifAbsent: () => 1);
                    authors.putIfAbsent(b, () => e.author);
                  }
                  var names = books.keys.toList()..sort();
                  if (_query.isNotEmpty) {
                    final q = _query.toLowerCase();
                    names = names
                        .where((b) => b.toLowerCase().contains(q))
                        .toList();
                  }
                  if (names.isEmpty && _query.isNotEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: entries.isEmpty
                          ? context.l10n.studyNoCommentaryYet
                          : context.l10n.studyNoBooksMatch(_query),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                    itemCount: names.length + 2,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSource,
                            decoration: InputDecoration(
                              labelText: context.l10n.creditsCommentary,
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Radii.lg),
                                borderSide: BorderSide(color: theme.dividerColor),
                              ),
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: '',
                                child: Text(context.l10n.studyAllSources),
                              ),
                              for (final source in sources)
                                DropdownMenuItem<String>(
                                  value: source,
                                  child: Text(source),
                                ),
                            ],
                            onChanged: (value) => setState(
                              () => _selectedSource = value ?? '',
                            ),
                          ),
                        );
                      }
                      if (i == 1) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: context.l10n
                                  .studySearchBooksCount(books.length),
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Radii.lg),
                                borderSide:
                                    BorderSide(color: theme.dividerColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Radii.lg),
                                borderSide:
                                    BorderSide(color: theme.dividerColor),
                              ),
                            ),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        );
                      }
                      final book = names[i - 2];
                      final chapters = books[book]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: V2Card(
                          onTap: () => _openBook(book, chapters),
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(Radii.md),
                                  border: Border.all(
                                    color: theme.primaryColor
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Icon(
                                  Icons.library_books_rounded,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.l10n.studyBookAuthorChapters(
                                          authors[book] ??
                                              context.l10n.studyClassicSources,
                                          chapters.length),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              V2Badge('${chapters.length} ch'),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Redesigned commentary hub (V2): verse-anchored, filterable, searchable.
class CommentaryHubV2Screen extends ConsumerStatefulWidget {
  final String book;
  final int chapter;
  final int? verse;
  final String? source;
  const CommentaryHubV2Screen({
    super.key,
    required this.book,
    required this.chapter,
    this.verse,
    this.source,
  });

  @override
  ConsumerState<CommentaryHubV2Screen> createState() =>
      _CommentaryHubV2ScreenState();
}

class _CommentaryHubV2ScreenState extends ConsumerState<CommentaryHubV2Screen> {
  StudyContentCategory? _filter;
  bool _verseOnly = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Deep links from a verse land pre-filtered to verse level.
    _verseOnly = widget.verse != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncEntries = ref.watch(commentaryProvider);
    final appThemeMode = ref.watch(themeProvider);

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SharedAppBar(title: Text('${widget.book} ${widget.chapter}')),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: [
                        // Verse anchor — V1 accepted verse props but never showed them.
                        if (widget.verse != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(Radii.lg),
                              border: Border.all(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              context.l10n.studyReadingRef(
                                  '${widget.book} ${widget.chapter}:${widget.verse}'),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        // 10dp gaps minus the chips' 4dp hit padding.
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: context.l10n.studyAllSources,
                                selected: _filter == null,
                                onTap: () => setState(() => _filter = null),
                              ),
                              const SizedBox(width: 8),
                              for (final c in StudyContentCategory.values)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _FilterChip(
                                    label: studyCategoryLabel(context.l10n, c),
                                    selected: _filter == c,
                                    onTap: () => setState(() =>
                                        _filter = _filter == c ? null : c),
                                  ),
                                ),
                              _FilterChip(
                                label: context.l10n.studyVerseLevel,
                                selected: _verseOnly,
                                onTap: () =>
                                    setState(() => _verseOnly = !_verseOnly),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          decoration: InputDecoration(
                            hintText: context.l10n.studySearchWithin(
                                '${widget.book} ${widget.chapter}'),
                            prefixIcon: const Icon(Icons.search_rounded),
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
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: asyncEntries.when(
                      loading: () => const LoadingView(),
                      error: (e, _) => ErrorState(
                        error: e,
                        message: context.l10n.studyEntriesLoadFailed,
                        onRetry: () => ref.invalidate(commentaryProvider),
                      ),
                      data: (entries) {
                        var list = entries
                            .where((e) =>
                                e.scope.book == widget.book &&
                                e.scope.chapter == widget.chapter &&
                                (widget.source == null ||
                                    e.source == widget.source))
                            .toList();
                        if (_filter != null) {
                          list =
                              list.where((e) => e.category == _filter).toList();
                        }
                        if (_verseOnly) {
                          list = list
                              .where((e) =>
                                  e.scope.type == 'verse' &&
                                  (widget.verse == null ||
                                      e.scope.verse == widget.verse))
                              .toList();
                        }
                        if (_query.isNotEmpty) {
                          final q = _query.toLowerCase();
                          list = list
                              .where((e) =>
                                  e.text.toLowerCase().contains(q) ||
                                  e.source.toLowerCase().contains(q) ||
                                  e.author.toLowerCase().contains(q))
                              .toList();
                        }
                        if (list.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                context.l10n.studyNoEntriesMatch,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                          itemCount: list.length,
                          itemBuilder: (context, i) =>
                              _EntryCard(entry: list[i]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // Invisible vertical hit padding: 48dp target.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(
                color:
                    selected ? theme.colorScheme.onSurface : theme.dividerColor,
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? theme.colorScheme.surface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends ConsumerWidget {
  final CommentaryEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final verse = entry.scope.verse;
    final isVerseLevel = entry.scope.type == 'verse';
    final bookmarked = ref.watch(commentaryBookmarksProvider).contains(
        '${entry.scope.book}|${entry.scope.chapter}|${verse ?? "all"}');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: V2Card(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(entry.category.icon, size: 16, color: theme.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                V2Badge(isVerseLevel && verse != null
                    ? context.l10n.studyVerseN(verse)
                    : context.l10n.studyChapter),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              entry.text,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.65),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.author,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: bookmarked
                      ? context.l10n.studyRemoveBookmark
                      : context.l10n.studyBookmarkCommentary,
                  icon: Icon(
                    bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: bookmarked
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    ref
                        .read(commentaryBookmarksProvider.notifier)
                        .toggleBookmark(entry.scope.book ?? '',
                            entry.scope.chapter ?? 1, verse);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Localized label for a commentary [StudyContentCategory].
String studyCategoryLabel(AppLocalizations l10n, StudyContentCategory c) {
  switch (c) {
    case StudyContentCategory.commentary:
      return l10n.studyCategoryCommentary;
    case StudyContentCategory.devotional:
      return l10n.studyCategoryDevotional;
    case StudyContentCategory.studyNote:
      return l10n.studyCategoryStudyNote;
  }
}
