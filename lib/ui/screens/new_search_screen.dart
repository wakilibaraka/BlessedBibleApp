import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/search_provider.dart';
import '../../state/search_engine.dart';
import '../../state/nav_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/glass_ui_provider.dart';
import '../../state/bible_provider.dart';

class NewSearchScreen extends ConsumerWidget {
  const NewSearchScreen({super.key});

  void _onResultTap(SearchResult result, WidgetRef ref) {
    ref.read(searchStateProvider.notifier).addRecentPlace(result);
    
    if (result.type == SearchResultType.bible || result.type == SearchResultType.reference) {
      ref.read(navProvider.notifier).setIndex(1); // Read Screen
      ref.read(readLocationProvider.notifier).updateLocation(
        bookAbbrev: result.metadata['bookAbbrev'],
        bookName: result.metadata['bookName'] ?? result.metadata['book'],
        chapter: result.metadata['chapter'],
        verse: result.metadata['verse'],
      );
    } else if (result.type == SearchResultType.commentary) {
      ref.read(navProvider.notifier).setIndex(1); // Read Screen
      final books = ref.read(bibleProvider).books;
      final bookName = result.metadata['book'] as String;
      final book = books.firstWhere((b) => b.name == bookName, orElse: () => books.first);
      ref.read(readLocationProvider.notifier).updateLocation(
        bookAbbrev: book.abbreviation,
        bookName: bookName,
        chapter: result.metadata['chapter'],
        verse: result.metadata['verse'],
        openCommentary: true,
      );
    }
  }

  Widget _buildResultBadge(SearchResult result, ThemeData theme) {
    Color badgeColor;
    String badgeText;

    switch (result.type) {
      case SearchResultType.bible:
      case SearchResultType.reference:
        badgeColor = theme.colorScheme.primary;
        badgeText = 'Bible';
        break;
      case SearchResultType.commentary:
        badgeColor = Colors.purple.shade400;
        badgeText = result.subtitle; // Contains author info
        break;
      case SearchResultType.note:
        badgeColor = Colors.orange.shade400;
        badgeText = 'Note';
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        badgeText.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);
    final theme = Theme.of(context);
    final isGlassy = ref.watch(glassUiProvider);

    final results = searchState.query.isEmpty ? searchState.recentPlaces : searchState.results;
    final isRecent = searchState.query.isEmpty && results.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false, // We'll manage bottom padding with MediaQuery for the keyboard
        child: Column(
          children: [
            // TOP HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 8),
                  Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), size: 24),
                  const Spacer(),
                  if (searchState.isSearching)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (searchState.isSearching) const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), size: 28),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      // No-op: search input state managed by SearchScreen
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // RESULTS LIST (Fills available space)
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        searchState.query.isEmpty
                            ? 'Search the Bible, Commentary, or your Notes'
                            : 'No results found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          elevation: isGlassy ? 0 : 1,
                          color: isGlassy ? theme.colorScheme.surface.withValues(alpha: 0.4) : theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isGlassy ? BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)) : BorderSide.none,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _onResultTap(result, ref),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      _buildResultBadge(result, theme),
                                      if (isRecent) ...[
                                        const SizedBox(width: 8),
                                        Icon(Icons.history, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                                      ],
                                      const Spacer(),
                                      Text(
                                        result.title,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    result.snippet,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // FIXED BOTTOM AREA (Filters only)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 116.0, // clear nav bar
                left: 16,
                right: 16,
                top: 8,
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: searchState.showFilters
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Advanced Filters',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () => ref.read(searchStateProvider.notifier).toggleFilters(),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilterChip(
                                  label: const Text('Old Testament'),
                                  selected: searchState.filterOt,
                                  onSelected: (_) => ref.read(searchStateProvider.notifier).toggleOtFilter(),
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: theme.colorScheme.primaryContainer,
                                ),
                                FilterChip(
                                  label: const Text('New Testament'),
                                  selected: searchState.filterNt,
                                  onSelected: (_) => ref.read(searchStateProvider.notifier).toggleNtFilter(),
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: theme.colorScheme.primaryContainer,
                                ),
                                FilterChip(
                                  label: const Text('Commentary'),
                                  selected: searchState.filterCommentary,
                                  onSelected: (_) => ref.read(searchStateProvider.notifier).toggleCommentaryFilter(),
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: Colors.purple.shade100,
                                ),
                                FilterChip(
                                  label: const Text('Notes'),
                                  selected: searchState.filterNotes,
                                  onSelected: (_) => ref.read(searchStateProvider.notifier).toggleNotesFilter(),
                                  backgroundColor: theme.colorScheme.surface,
                                  selectedColor: Colors.orange.shade100,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
