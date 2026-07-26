import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/search_provider.dart';
import '../../state/search_engine.dart';
import '../../state/nav_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/glass_ui_provider.dart';
import '../../state/bible_provider.dart';
import '../widgets/textured_glass_container.dart';

class NewSearchScreen extends ConsumerStatefulWidget {
  const NewSearchScreen({super.key});

  @override
  ConsumerState<NewSearchScreen> createState() => _NewSearchScreenState();
}

class _NewSearchScreenState extends ConsumerState<NewSearchScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _focusTimer;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Hydrate text field with current query if any
      final initialQuery = ref.read(searchStateProvider).query;
      if (initialQuery.isNotEmpty) {
        _controller.text = initialQuery;
      }
    });
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onResultTap(SearchResult result) {
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
  Widget build(BuildContext context) {
    ref.listen<int>(navProvider, (previous, next) {
      if (next == 2 && previous != 2) {
        // Automatically request focus when switching to the Search tab
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) _focusNode.requestFocus();
          });
        }
      }
    });

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
                  Text(
                    'Search',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
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
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: results.length,
                      // Reverse it so results flow upwards from the bottom? No, standard top-down scrolling is better, 
                      // but bottom bar is fixed.
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () => _onResultTap(result),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (isRecent) ...[
                                        Icon(Icons.history, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          result.title,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildResultBadge(result, theme),
                                    ],
                                  ),
                                  if (result.snippet.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      result.snippet,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        height: 1.4,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // FIXED BOTTOM SEARCH BAR
            AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              // Add bottom padding for keyboard + safe area (bottom nav)
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 
                        (MediaQuery.of(context).viewInsets.bottom == 0 ? 116.0 : 16.0), // ~116px clears nav bar with clean unified spacing
                left: 16,
                right: 16,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ADVANCED FILTERS PANEL
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: _showFilters
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                      onPressed: () => setState(() => _showFilters = false),
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

                  // TEXT FIELD
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        if (isGlassy)
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: _focusNode.hasFocus ? 0.35 : 0.15),
                            blurRadius: _focusNode.hasFocus ? 32 : 16,
                            spreadRadius: _focusNode.hasFocus ? 4 : 0,
                            offset: _focusNode.hasFocus ? const Offset(0, 8) : const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: TexturedGlassContainer(
                      borderRadius: BorderRadius.circular(32),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: (val) => ref.read(searchStateProvider.notifier).setQuery(val),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search the Bible...',
                                hintStyle: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              cursorColor: theme.colorScheme.primary,
                              cursorRadius: const Radius.circular(2),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              onPressed: () {
                                _controller.clear();
                                ref.read(searchStateProvider.notifier).setQuery('');
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              _showFilters ? Icons.tune : Icons.tune_outlined,
                              color: _showFilters 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _showFilters = !_showFilters;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
