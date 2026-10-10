import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/commentary_entry.dart';
import '../../models/study_content_category.dart';
import '../../state/commentary_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              Text('${chapters.length} chapters with content',
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
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(CupertinoPageRoute<void>(
                          builder: (_) =>
                              CommentaryHubV2Screen(book: book, chapter: ch),
                        ));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
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
        appBar: const SharedAppBar(title: Text('Commentary Library')),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: asyncEntries.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 60),
                    Icon(Icons.cloud_off_rounded,
                        size: 44,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load commentary.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$e',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: FilledButton.tonal(
                        onPressed: () => ref.invalidate(commentaryProvider),
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
                data: (entries) {
                  // book -> chapter -> entry count
                  final Map<String, Map<int, int>> books = {};
                  final Map<String, String> authors = {};
                  for (final e in entries) {
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
                  if (names.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 60),
                        Icon(Icons.search_off_rounded,
                            size: 44,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          entries.isEmpty
                              ? 'No commentary available yet.'
                              : 'No books match "$_query".',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                    itemCount: names.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search ${books.length} books…',
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    BorderSide(color: theme.dividerColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    BorderSide(color: theme.dividerColor),
                              ),
                            ),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        );
                      }
                      final book = names[i - 1];
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
                                  borderRadius: BorderRadius.circular(13),
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
                                      '${authors[book] ?? 'Classic sources'} · ${chapters.length} ch',
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
  const CommentaryHubV2Screen({
    super.key,
    required this.book,
    required this.chapter,
    this.verse,
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
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'Reading · ${widget.book} ${widget.chapter}:${widget.verse}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All sources',
                                selected: _filter == null,
                                onTap: () => setState(() => _filter = null),
                              ),
                              const SizedBox(width: 8),
                              for (final c in StudyContentCategory.values)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _FilterChip(
                                    label: c.displayName,
                                    selected: _filter == c,
                                    onTap: () => setState(() =>
                                        _filter = _filter == c ? null : c),
                                  ),
                                ),
                              _FilterChip(
                                label: 'Verse-level',
                                selected: _verseOnly,
                                onTap: () =>
                                    setState(() => _verseOnly = !_verseOnly),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            hintText:
                                'Search within ${widget.book} ${widget.chapter}…',
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
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: asyncEntries.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Could not load entries.\n$e',
                                textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton.tonal(
                              onPressed: () =>
                                  ref.invalidate(commentaryProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                      data: (entries) {
                        var list = entries
                            .where((e) =>
                                e.scope.book == widget.book &&
                                e.scope.chapter == widget.chapter)
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
                                'No entries match these filters.\nTry All sources, or browse the library.',
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.onSurface
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? theme.colorScheme.onSurface : theme.dividerColor,
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
                V2Badge(
                    isVerseLevel && verse != null ? 'Verse $verse' : 'Chapter'),
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
                  visualDensity: VisualDensity.compact,
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
