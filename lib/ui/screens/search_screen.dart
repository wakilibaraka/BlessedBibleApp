import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/search_provider.dart';
import '../../state/search_engine.dart';
import '../../state/nav_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/surface_style_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/search_settings_provider.dart';
import '../../state/most_read_provider.dart';
import '../../data/local_storage/preferences_service.dart';
import '../widgets/textured_glass_container.dart';
import '../sheets/search_settings_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _focusTimer;
  Timer? _debounceTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showSwipeHint = false;
  double _dragStartY = 0;
  bool _isDragging = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchStateProvider).query,
    );
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final prefs = ref.read(preferencesProvider);
      final seenHints = prefs.getSeenHints();
      if (!seenHints.contains('search_swipe_hint')) {
        setState(() => _showSwipeHint = true);
      }

      _animationController.forward();
      _focusTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) _focusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onResultTap(SearchResult result) {
    ref.read(searchStateProvider.notifier).addRecentPlace(result);

    if (result.type == SearchResultType.bible ||
        result.type == SearchResultType.reference) {
      ref.read(navProvider.notifier).setIndex(1);
      ref.read(readLocationProvider.notifier).updateLocation(
            bookAbbrev: result.metadata['bookAbbrev'],
            bookName: result.metadata['bookName'] ?? result.metadata['book'],
            chapter: result.metadata['chapter'],
            verse: result.metadata['verse'],
          );
    } else if (result.type == SearchResultType.commentary) {
      ref.read(navProvider.notifier).setIndex(1);
      final books = ref.read(bibleProvider).books;
      final bookName = result.metadata['book'] as String;
      final book = books.firstWhere((b) => b.name == bookName,
          orElse: () => books.first);
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
    final isGlassy = ref.watch(surfaceStyleProvider) == SurfaceStyle.frosted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Listener(
                  onPointerDown: (e) {
                    _dragStartY = e.position.dy;
                    _isDragging = true;
                  },
                  onPointerMove: (e) {
                    if (!_isDragging) return;

                    bool isAtTop = true;
                    if (_scrollController.hasClients) {
                      isAtTop = _scrollController.offset <= 16.0;
                    }

                    if (!isAtTop) return;

                    final dy = e.position.dy - _dragStartY;
                    if (dy < -10) {
                      _isDragging = false;
                      return;
                    }

                    if (dy > 40) {
                      _isDragging = false;
                      if (!_focusNode.hasFocus) {
                        _focusNode.requestFocus();
                      }
                      if (_showSwipeHint) {
                        setState(() => _showSwipeHint = false);
                        final prefs = ref.read(preferencesProvider);
                        final seen = prefs.getSeenHints();
                        if (!seen.contains('search_swipe_hint')) {
                          prefs.saveSeenHints([...seen, 'search_swipe_hint']);
                        }
                      }
                    }
                  },
                  onPointerUp: (e) => _isDragging = false,
                  onPointerCancel: (e) => _isDragging = false,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // ── Search bar + filter chips ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              if (isGlassy)
                                BoxShadow(
                                  color: theme.primaryColor.withValues(
                                    alpha: _focusNode.hasFocus ? 0.35 : 0.15,
                                  ),
                                  blurRadius: _focusNode.hasFocus ? 32 : 16,
                                  spreadRadius: _focusNode.hasFocus ? 4 : 0,
                                  offset: _focusNode.hasFocus
                                      ? const Offset(0, 8)
                                      : const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: TexturedGlassContainer(
                            borderRadius: BorderRadius.circular(32),
                            padding: EdgeInsets.zero,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Top: Search input
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _controller,
                                          focusNode: _focusNode,
                                          onChanged: (val) {
                                            ref
                                                .read(searchStateProvider
                                                    .notifier)
                                                .setQuery(val);
                                            _debounceTimer?.cancel();
                                            _debounceTimer = Timer(
                                              const Duration(milliseconds: 500),
                                              () {
                                                if (!mounted) return;
                                                final s = ref
                                                    .read(searchStateProvider);
                                                final settings = ref.read(
                                                    searchSettingsProvider);
                                                if (settings
                                                        .autoOpenSingleSearchResult &&
                                                    s.results.length == 1) {
                                                  _onResultTap(s.results.first);
                                                }
                                              },
                                            );
                                          },
                                          onSubmitted: (val) {
                                            final results = ref
                                                .read(searchStateProvider)
                                                .results;
                                            if (results.isNotEmpty) {
                                              _onResultTap(results.first);
                                            }
                                          },
                                          style: theme.textTheme.titleMedium,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Search verses, commentary…',
                                            hintStyle: theme
                                                .textTheme.titleMedium
                                                ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.4),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      if (_controller.text.isNotEmpty)
                                        GestureDetector(
                                          onTap: () {
                                            _controller.clear();
                                            ref
                                                .read(searchStateProvider
                                                    .notifier)
                                                .setQuery('');
                                          },
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 20,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Divider
                                Divider(
                                  height: 1,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.08),
                                ),

                                // Filter chips row
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 10.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildFilterChip(
                                          label: 'OT',
                                          icon: Icons.history_edu_rounded,
                                          isActive: searchState.filterOt,
                                          onTap: () => ref
                                              .read(
                                                  searchStateProvider.notifier)
                                              .toggleOtFilter(),
                                          theme: theme,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterChip(
                                          label: 'NT',
                                          icon: Icons.menu_book_rounded,
                                          isActive: searchState.filterNt,
                                          onTap: () => ref
                                              .read(
                                                  searchStateProvider.notifier)
                                              .toggleNtFilter(),
                                          theme: theme,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterChip(
                                          label: 'Commentary',
                                          icon: Icons.library_books_rounded,
                                          isActive:
                                              searchState.filterCommentary,
                                          onTap: () => ref
                                              .read(
                                                  searchStateProvider.notifier)
                                              .toggleCommentaryFilter(),
                                          theme: theme,
                                        ),
                                        const SizedBox(width: 8),
                                        _buildFilterChip(
                                          label: 'My Notes',
                                          icon: Icons.sticky_note_2_outlined,
                                          isActive: searchState.filterNotes,
                                          onTap: () => ref
                                              .read(
                                                  searchStateProvider.notifier)
                                              .toggleNotesFilter(),
                                          theme: theme,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Results ────────────────────────────────────────────
                      Expanded(
                        child: Stack(
                          children: [
                            searchState.query.isEmpty
                                ? _buildRecentPlaces(searchState, theme)
                                : _buildSearchResults(searchState, theme),
                            Positioned(
                              top: 16,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: _showSwipeHint ? 1.0 : 0.0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface
                                            .withValues(
                                                alpha: isGlassy ? 0.7 : 1.0),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.1),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            blurRadius: 10,
                                          )
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: 16,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Swipe down for keyboard',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Filter chip ────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive
                  ? theme.colorScheme.surface
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? theme.colorScheme.surface
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent places & Most Read ────────────────────────────────────────────
  Widget _buildRecentPlaces(SearchState state, ThemeData theme) {
    final mostRead = ref.watch(mostReadProvider);
    final showMostRead = mostRead.length >= 5;

    if (state.recentPlaces.isEmpty && !showMostRead) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Search the Bible, commentary\nand your notes',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      children: [
        if (state.recentPlaces.isNotEmpty) ...[
          Text(
            'RECENT',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...state.recentPlaces.map((place) => _buildResultItem(place, theme)),
          const SizedBox(height: 24),
        ],
        if (showMostRead) ...[
          Text(
            'MOST READ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // take top 5
          ...mostRead
              .take(5)
              .map((m) => _buildResultItem(m.toSearchResult(), theme)),
        ]
      ],
    );
  }

  // ── Search results ─────────────────────────────────────────────────────
  Widget _buildSearchResults(SearchState state, ThemeData theme) {
    if (state.isSearching && state.results.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.primaryColor,
          strokeWidth: 2,
        ),
      );
    }

    if (state.results.isEmpty && !state.isSearching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              'No results found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final referenceResults = state.results
        .where((r) => r.type == SearchResultType.reference)
        .toList();
    final bibleResults =
        state.results.where((r) => r.type == SearchResultType.bible).toList();
    final commentaryResults = state.results
        .where((r) => r.type == SearchResultType.commentary)
        .toList();
    final noteResults =
        state.results.where((r) => r.type == SearchResultType.note).toList();

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      children: [
        if (referenceResults.isNotEmpty) ...[
          _buildSectionHeader('JUMP TO', theme),
          ...referenceResults
              .map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 12),
        ],
        if (bibleResults.isNotEmpty) ...[
          _buildSectionHeader('VERSES', theme),
          ...bibleResults.map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 12),
        ],
        if (commentaryResults.isNotEmpty) ...[
          _buildSectionHeader('COMMENTARY', theme),
          ...commentaryResults
              .map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 12),
        ],
        if (noteResults.isNotEmpty) ...[
          _buildSectionHeader('MY NOTES', theme),
          ...noteResults.map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 12),
        ],
        // Bottom padding so last result is above nav bar
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4.0, top: 4.0),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildResultItem(SearchResult result, ThemeData theme,
      [String query = '']) {
    final IconData icon;
    if (result.type == SearchResultType.reference) {
      icon = Icons.keyboard_double_arrow_right_rounded;
    } else if (result.type == SearchResultType.bible) {
      icon = Icons.menu_book_rounded;
    } else if (result.type == SearchResultType.note) {
      icon = Icons.sticky_note_2_outlined;
    } else {
      icon = Icons.library_books_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
                  Icon(icon, size: 15, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      height: 1.5,
    );

    if (query.isEmpty) {
      return Text(text,
          style: style, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    final index = textLower.indexOf(queryLower);

    if (index == -1) {
      return Text(text,
          style: style, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.amberAccent
        : Colors.amber.shade800;
    final highlightStyle = style?.copyWith(
      color: highlightColor,
      fontWeight: FontWeight.bold,
      backgroundColor: highlightColor.withValues(alpha: 0.12),
    );

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
              text: text.substring(index, index + query.length),
              style: highlightStyle),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
