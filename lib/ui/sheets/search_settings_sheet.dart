import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/search_provider.dart';
import '../../state/search_settings_provider.dart';

class SearchSettingsSheet extends ConsumerWidget {
  const SearchSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);
    final searchSettings = ref.watch(searchSettingsProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'MATCH TYPE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Exact Match'),
                    subtitle: const Text('Only match the exact phrase'),
                    value: searchState.exactMatch,
                    onChanged: (val) {
                      ref.read(searchStateProvider.notifier).toggleExactMatch();
                    },
                    secondary: const Icon(Icons.format_quote_rounded),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16).copyWith(bottom: 8),
                    child: Text(
                      'SCOPE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Old Testament'),
                    subtitle: searchState.filterBook != null ? const Text('Disabled (Book Filter Active)') : null,
                    value: searchState.filterOt,
                    onChanged: searchState.filterBook != null ? null : (val) {
                      ref.read(searchStateProvider.notifier).toggleOtFilter();
                    },
                    secondary: const Icon(Icons.history_edu_rounded),
                  ),
                  SwitchListTile(
                    title: const Text('New Testament'),
                    subtitle: searchState.filterBook != null ? const Text('Disabled (Book Filter Active)') : null,
                    value: searchState.filterNt,
                    onChanged: searchState.filterBook != null ? null : (val) {
                      ref.read(searchStateProvider.notifier).toggleNtFilter();
                    },
                    secondary: const Icon(Icons.menu_book_rounded),
                  ),
                  SwitchListTile(
                    title: const Text('Commentary'),
                    value: searchState.filterCommentary,
                    onChanged: (val) {
                      ref.read(searchStateProvider.notifier).toggleCommentaryFilter();
                    },
                    secondary: const Icon(Icons.library_books_rounded),
                  ),
                  SwitchListTile(
                    title: const Text('My Notes'),
                    value: searchState.filterNotes,
                    onChanged: (val) {
                      ref.read(searchStateProvider.notifier).toggleNotesFilter();
                    },
                    secondary: const Icon(Icons.sticky_note_2_outlined),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16).copyWith(bottom: 8),
                    child: Text(
                      'BEHAVIOR',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Auto-open Single Result'),
                    subtitle: const Text('Jump directly if only one result is found'),
                    value: searchSettings.autoOpenSingleSearchResult,
                    onChanged: (val) {
                      ref.read(searchSettingsProvider.notifier).toggleAutoOpen(val);
                    },
                    secondary: const Icon(Icons.bolt_rounded),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
