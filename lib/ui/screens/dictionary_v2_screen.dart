import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/dictionary_provider.dart';
import '../../state/dictionary_search_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/dictionary_entry_sheet.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/study_v2_widgets.dart';

/// Standalone dictionary (V2): just words — bookmarks, highlights and
/// notes moved to the Your Space banner.
class DictionaryV2Screen extends ConsumerStatefulWidget {
  const DictionaryV2Screen({super.key});

  @override
  ConsumerState<DictionaryV2Screen> createState() => _DictionaryV2ScreenState();
}

class _DictionaryV2ScreenState extends ConsumerState<DictionaryV2Screen> {
  String _query = '';
  String _source = 'All';
  bool _savedOnly = false;

  void _openEntry(String normalizedWord) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DictionaryEntrySheet(normalizedWord: normalizedWord),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final results = ref.watch(dictionarySearchProvider(_query));
    final savedWords = ref.watch(bookmarkedWordsProvider).asData?.value ?? {};

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const SharedAppBar(title: Text('Dictionary')),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
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
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
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
                              selected: _source == s,
                              onSelected: (_) => setState(() => _source = s),
                            ),
                          ),
                        FilterChip(
                          label: const Text('★ Saved'),
                          selected: _savedOnly,
                          onSelected: (v) => setState(() => _savedOnly = v),
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
                      if (_source != 'All') {
                        list = list
                            .where((w) => w.sources
                                .toLowerCase()
                                .contains(_source.toLowerCase()))
                            .toList();
                      }
                      if (_savedOnly) {
                        list = list
                            .where((w) => savedWords.contains(w.normalizedWord))
                            .toList();
                      }
                      if (list.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            _query.isEmpty && !_savedOnly
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
                            padding: const EdgeInsets.symmetric(vertical: 6),
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
                              saved: savedWords.contains(w.normalizedWord),
                              onOpen: () => _openEntry(w.normalizedWord),
                            ),
                        ],
                      );
                    },
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

class _WordCard extends ConsumerWidget {
  final DictionaryHeadword word;
  final bool saved;
  final VoidCallback onOpen;
  const _WordCard(
      {required this.word, required this.saved, required this.onOpen});

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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: saved
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
