import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/search_provider.dart';
import '../../state/search_engine.dart';
import '../../state/theme_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/read_selection_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/glass_ui_provider.dart';
import '../../state/bible_provider.dart';
import '../widgets/textured_glass_container.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _focusTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Delay focus and animation slightly to allow tab transition to complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _animationController.forward();
      // Auto-focus the search bar
      _focusTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) _focusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final isGlassy = ref.watch(glassUiProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Rely on app background
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
              children: [
                const SizedBox(height: 32),
                
                // Conjoined Search Pill and Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
                      padding: EdgeInsets.zero,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top: Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    onChanged: (val) {
                                      ref.read(searchStateProvider.notifier).setQuery(val);
                                    },
                                    style: theme.textTheme.titleMedium,
                                    decoration: InputDecoration(
                                      hintText: 'Search verses, commentary...',
                                      hintStyle: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                if (_controller.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _controller.clear();
                                      ref.read(searchStateProvider.notifier).setQuery('');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Divider
                          Container(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.1)),
                          
                          // Bottom: Advanced Filters (Conjoined Twins)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFilterChip(
                                  label: 'Bible',
                                  icon: Icons.menu_book_rounded,
                                  isActive: searchState.filterBible,
                                  onTap: () => ref.read(searchStateProvider.notifier).toggleBibleFilter(),
                                  theme: theme,
                                ),
                                const SizedBox(width: 12),
                                _buildFilterChip(
                                  label: 'Commentary',
                                  icon: Icons.library_books_rounded,
                                  isActive: searchState.filterCommentary,
                                  onTap: () => ref.read(searchStateProvider.notifier).toggleCommentaryFilter(),
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Results Area
                Expanded(
                  child: searchState.query.isEmpty
                      ? _buildRecentPlaces(searchState, theme)
                      : _buildSearchResults(searchState, theme),
                ),
              ],
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? theme.colorScheme.surface : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? theme.colorScheme.surface : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPlaces(SearchState state, ThemeData theme) {
    if (state.recentPlaces.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      children: [
        Text(
          'Recent Places',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...state.recentPlaces.map((place) => _buildResultItem(place, theme)).toList(),
      ],
    );
  }

  Widget _buildSearchResults(SearchState state, ThemeData theme) {
    if (state.results.isEmpty && !state.isSearching) {
      return Center(
        child: Text(
          'No results found.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }
    
    final referenceResults = state.results.where((r) => r.type == SearchResultType.reference).toList();
    final bibleResults = state.results.where((r) => r.type == SearchResultType.bible).toList();
    final commentaryResults = state.results.where((r) => r.type == SearchResultType.commentary).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      children: [
        if (referenceResults.isNotEmpty) ...[
          _buildSectionHeader('Jump To', theme),
          ...referenceResults.map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 16),
        ],
        if (bibleResults.isNotEmpty) ...[
          _buildSectionHeader('Verses', theme),
          ...bibleResults.map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 16),
        ],
        if (commentaryResults.isNotEmpty) ...[
          _buildSectionHeader('Commentary', theme),
          ...commentaryResults.map((r) => _buildResultItem(r, theme, state.query)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildResultItem(SearchResult result, ThemeData theme, [String query = '']) {
    IconData icon;
    if (result.type == SearchResultType.reference) icon = Icons.keyboard_double_arrow_right_rounded;
    else if (result.type == SearchResultType.bible) icon = Icons.menu_book_rounded;
    else icon = Icons.library_books_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () => _onResultTap(result),
        child: TexturedGlassContainer(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result.subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                result.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildSnippet(result.snippet, query, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSnippet(String text, String query, ThemeData theme) {
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
      height: 1.5,
    );

    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    final index = textLower.indexOf(queryLower);
    
    if (index == -1) {
      return Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    final highlightStyle = style?.copyWith(
      color: theme.brightness == Brightness.dark ? Colors.amberAccent : Colors.amber.shade800, 
      fontWeight: FontWeight.bold,
      backgroundColor: (theme.brightness == Brightness.dark ? Colors.amberAccent : Colors.amber.shade800).withOpacity(0.1),
    );

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(text: text.substring(index, index + query.length), style: highlightStyle),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
