import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/dictionary_provider.dart';
import '../../state/dictionary_search_provider.dart';
import '../../state/notes_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/user_data_provider.dart'
    show bookmarksProvider, highlightsProvider, highlightPaletteSwatches;
import '../../theme/app_colors.dart';
import '../widgets/dictionary_entry_sheet.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';
import 'notes_list_screen.dart';

/// Redesigned study-tools screen (V2): dictionary, bookmarks, highlights
/// and notes in one tabbed shell.
///
/// Differences from the scattered V1 screens:
/// - Dictionary has source filter (Easton/Smith), saved-only toggle and
///   honest empty states. Entry sheets reuse [DictionaryEntrySheet].
/// - Highlights render through [AppColors.getRenderedHighlightColor] so
///   they stay legible on sepia/dark alike.
/// - Notes reuse the existing [NotesListScreen] editor (same data).
class StudyToolsV2Screen extends ConsumerStatefulWidget {
  const StudyToolsV2Screen({super.key});

  @override
  ConsumerState<StudyToolsV2Screen> createState() =>
      _StudyToolsV2ScreenState();
}

class _StudyToolsV2ScreenState extends ConsumerState<StudyToolsV2Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _query = '';
  String _source = 'All';
  bool _savedOnly = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _openEntry(String normalizedWord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          DictionaryEntrySheet(normalizedWord: normalizedWord),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appThemeMode = ref.watch(themeProvider);
    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const SharedAppBar(title: Text('Study Tools')),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: V2PillTabs(
                      controller: _tabs,
                      tabs: const [
                        'Dictionary',
                        'Bookmarks',
                        'Marks & Notes',
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        _DictionaryTab(
                          query: _query,
                          source: _source,
                          savedOnly: _savedOnly,
                          onQuery: (v) =>
                              setState(() => _query = v),
                          onSource: (v) =>
                              setState(() => _source = v),
                          onSavedOnly: (v) =>
                              setState(() => _savedOnly = v),
                          onOpen: _openEntry,
                        ),
                        const _BookmarksTab(),
                        const _MarksNotesTab(),
                      ],
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

class _DictionaryTab extends ConsumerWidget {
  final String query;
  final String source;
  final bool savedOnly;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onSource;
  final ValueChanged<bool> onSavedOnly;
  final void Function(String normalizedWord) onOpen;
  const _DictionaryTab({
    required this.query,
    required this.source,
    required this.savedOnly,
    required this.onQuery,
    required this.onSource,
    required this.onSavedOnly,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final results =
        ref.watch(dictionarySearchProvider(query));
    final savedWords =
        ref.watch(bookmarkedWordsProvider).asData?.value ?? {};

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search 3,400+ words…',
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
          onChanged: onQuery,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final s in const ['All', 'Easton', 'Smith'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: source == s,
                    onSelected: (_) => onSource(s),
                  ),
                ),
              FilterChip(
                label: const Text('★ Saved'),
                selected: savedOnly,
                onSelected: onSavedOnly,
                avatar: null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        results.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Dictionary unavailable.\n$e',
                textAlign: TextAlign.center),
          ),
          data: (words) {
            var list = words;
            if (source != 'All') {
              list = list
                  .where((w) => w.sources
                      .toLowerCase()
                      .contains(source.toLowerCase()))
                  .toList();
            }
            if (savedOnly) {
              list = list
                  .where((w) =>
                      savedWords.contains(w.normalizedWord))
                  .toList();
            }
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  query.isEmpty && !savedOnly
                      ? 'No headwords found.'
                      : 'No matches. Try “grace”, “atonement” or “wilderness”.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.75),
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${list.length} result${list.length == 1 ? '' : 's'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ),
                for (final w in list.take(100))
                  _WordCard(
                    word: w,
                    saved: savedWords
                        .contains(w.normalizedWord),
                    onOpen: () => onOpen(w.normalizedWord),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WordCard extends ConsumerWidget {
  final DictionaryHeadword word;
  final bool saved;
  final VoidCallback onOpen;
  const _WordCard(
      {required this.word,
      required this.saved,
      required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final head = word.displayHeadword;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: V2Card(
        onTap: onOpen,
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    head.isEmpty ? '(untitled entry)' : head,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.sources,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                saved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: saved
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
              ),
              onPressed: () {
                ref
                    .read(bookmarkedWordsProvider.notifier)
                    .toggleBookmark(word.normalizedWord);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarksTab extends ConsumerWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarks = ref.watch(bookmarksProvider);
    if (bookmarks.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 140),
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 44,
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.35)),
          const SizedBox(height: 12),
          Text(
            'No bookmarks yet.\nSelect a verse in Read, then tap Bookmark.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.75),
            ),
          ),
        ],
      );
    }
    final refs = bookmarks.toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
      itemCount: refs.length,
      itemBuilder: (context, i) {
        final r = refs[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: V2Card(
            padding: const EdgeInsets.symmetric(
                horizontal: 15, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.bookmark_rounded,
                    size: 18, color: theme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5)),
                  onPressed: () => ref
                      .read(bookmarksProvider.notifier)
                      .toggle(r),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MarksNotesTab extends ConsumerWidget {
  const _MarksNotesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final highlights = ref.watch(highlightsProvider);
    final notes = ref.watch(notesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
      children: [
        const V2SectionLabel('Highlights'),
        if (highlights.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No highlights yet. Long-press a verse in Read to highlight it.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.75),
              ),
            ),
          )
        else
          for (final e in highlights.entries)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border(
                  left: BorderSide(
                    color: AppColors.getRenderedHighlightColor(
                      highlightPaletteSwatches[
                          e.value % highlightPaletteSwatches.length],
                      theme.brightness,
                      theme.scaffoldBackgroundColor,
                    ),
                    width: 4,
                  ),
                  top: BorderSide(color: theme.dividerColor),
                  right: BorderSide(color: theme.dividerColor),
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Text(
                e.key,
                style: theme.textTheme.bodyMedium,
              ),
            ),
        Row(
          children: [
            const Expanded(child: V2SectionLabel('Notes')),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => const NotesListScreen(),
                ));
              },
              child: const Text('Open editor →'),
            ),
          ],
        ),
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No notes yet. Notes you write in Read appear here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.75),
              ),
            ),
          )
        else
          for (final n in notes)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: V2Card(
                padding: const EdgeInsets.all(15),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => const NotesListScreen(),
                  ));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title.isEmpty
                                ? '(untitled)'
                                : n.title,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (n.reference != null)
                          V2Badge(n.reference!),
                      ],
                    ),
                    if (n.content.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        n.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style:
                            theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      n.date,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
