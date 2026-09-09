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
import 'package:flutter/services.dart';
import '../../state/typography_provider.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchStateProvider).query,
    );
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
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
        result.type == SearchResultType.reference ||
        result.type == SearchResultType.pericope) {
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
      final bookName = (result.metadata['bookName'] ?? result.metadata['book']) as String;
      final book = books.firstWhere((b) => b.name == bookName,
          orElse: () => books.first);
      ref.read(readLocationProvider.notifier).updateLocation(
            bookAbbrev: book.abbreviation,
            bookName: bookName,
            chapter: result.metadata['chapter'],
            verse: result.metadata['verse'],
            openCommentary: true,
          );
    } else if (result.type == SearchResultType.note) {
      final refStr = result.metadata['reference'] as String?;
      if (refStr != null && refStr.isNotEmpty) {
        // Try to parse reference to navigate to verse
        final regex = RegExp(r'^((?:\d\s*)?[a-z]+(?:\s+[a-z]+)*)\s*(?:(\d+)[\s:.]*(\d+)?(?:-\d+)?)?$');
        final match = regex.firstMatch(refStr.toLowerCase());
        if (match != null) {
          final bookStr = match.group(1)?.trim() ?? '';
          final chapterStr = match.group(2);
          final verseStr = match.group(3);
          
          final books = ref.read(bibleProvider).books;
          for (final book in books) {
            if (book.name.toLowerCase().startsWith(bookStr) || book.abbreviation.toLowerCase().startsWith(bookStr)) {
              int chapter = 1;
              if (chapterStr != null) {
                chapter = int.tryParse(chapterStr) ?? 1;
                if (verseStr == null && book.chapters.length == 1) {
                  chapter = 1;
                }
              }
              int? verse = verseStr != null ? int.tryParse(verseStr) : null;
              if (chapterStr != null && verseStr == null && book.chapters.length == 1) {
                verse = int.tryParse(chapterStr);
              }
              
              ref.read(navProvider.notifier).setIndex(1);
              ref.read(readLocationProvider.notifier).updateLocation(
                bookAbbrev: book.abbreviation,
                bookName: book.name,
                chapter: chapter,
                verse: verse,
              );
              return;
            }
          }
        }
      }
      // If no valid reference or parsing failed, just go to Notes tab (Study)
      ref.read(navProvider.notifier).setIndex(3);
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
                                          label: searchState.filterBook ?? 'All Books',
                                          icon: Icons.menu_book_rounded,
                                          isActive: searchState.filterBook != null,
                                          onTap: () async {
                                            // Show book picker modal
                                            if (searchState.filterBook != null) {
                                              ref.read(searchStateProvider.notifier).setFilterBook(null);
                                              return;
                                            }
                                            // Need a way to pick a book. 
                                            // For simplicity, we could open a bottom sheet with a list of books.
                                            // Actually, the SettingsSheet might be a better place. But since N2 asks for it, let's keep it simple.
                                            // For now, let's just make it a chip that opens a modal.
                                            final books = ref.read(bibleProvider).books;
                                            showModalBottomSheet(
                                              context: context,
                                              backgroundColor: theme.scaffoldBackgroundColor,
                                              builder: (ctx) => ListView.builder(
                                                itemCount: books.length,
                                                itemBuilder: (c, i) => ListTile(
                                                  title: Text(books[i].name),
                                                  onTap: () {
                                                    ref.read(searchStateProvider.notifier).setFilterBook(books[i].name);
                                                    Navigator.pop(ctx);
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          theme: theme,
                                        ),
                                        if (searchState.filterBook == null) ...[
                                          const SizedBox(width: 8),
                                          _buildFilterChip(
                                            label: 'OT',
                                            icon: Icons.history_edu_rounded,
                                            isActive: searchState.filterOt,
                                            onTap: () => ref
                                                .read(searchStateProvider.notifier)
                                                .toggleOtFilter(),
                                            theme: theme,
                                          ),
                                        ],
                                        if (searchState.filterBook == null) ...[
                                          const SizedBox(width: 8),
                                          _buildFilterChip(
                                            label: 'NT',
                                            icon: Icons.menu_book_rounded,
                                            isActive: searchState.filterNt,
                                            onTap: () => ref
                                                .read(searchStateProvider.notifier)
                                                .toggleNtFilter(),
                                            theme: theme,
                                          ),
                                        ],
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
                                        Consumer(builder: (context, ref, _) {
                                          final includeNotes = ref.watch(searchSettingsProvider
                                              .select((s) => s.includeNotesInSearch));
                                          if (!includeNotes) return const SizedBox.shrink();
                                          return _buildFilterChip(
                                            label: 'My Notes',
                                            icon: Icons.sticky_note_2_outlined,
                                            isActive: searchState.filterNotes,
                                            onTap: () => ref
                                                .read(searchStateProvider.notifier)
                                                .toggleNotesFilter(),
                                            theme: theme,
                                          );
                                        }),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.settings_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                          iconSize: 20,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              backgroundColor: Colors.transparent,
                                              isScrollControlled: true,
                                              builder: (context) => const SearchSettingsSheet(),
                                            );
                                          },
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
                        child: GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            children: [
                              searchState.query.isEmpty
                                  ? _buildRecentPlaces(searchState, theme)
                                  : _buildSearchResults(searchState, theme),

                          ],
                        ),
                      ),
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

    if (state.recentPlaces.isEmpty && state.recentQueries.isEmpty && !showMostRead) {
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
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      children: [
        if (state.recentQueries.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT SEARCHES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(searchStateProvider.notifier).clearRecentQueries(),
                child: Text(
                  'CLEAR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.recentQueries.map((query) => GestureDetector(
              onTap: () {
                _controller.text = query;
                ref.read(searchStateProvider.notifier).setQuery(query);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      query,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (state.recentPlaces.isNotEmpty) ...[
          Text(
            'RECENT PLACES',
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

    final pericopeResults = state.results
        .where((r) => r.type == SearchResultType.pericope)
        .toList();

    return ListView(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
          child: Text(
            state.results.length >= 100 ? 'Showing top 100 results' : '${state.results.length} results found',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        if (pericopeResults.isNotEmpty) ...[
          _buildSectionHeader('STORIES (${pericopeResults.length})', theme),
          ...pericopeResults
              .map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 12),
        ],
        if (referenceResults.isNotEmpty) ...[
          _buildSectionHeader('JUMP TO (${referenceResults.length})', theme),
          ...referenceResults
              .map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 12),
        ],
        if (bibleResults.isNotEmpty) ...[
          _buildSectionHeader('VERSES (${bibleResults.length})', theme),
          ...bibleResults.map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 12),
        ],
        if (commentaryResults.isNotEmpty) ...[
          _buildSectionHeader('COMMENTARY (${commentaryResults.length})', theme),
          ...commentaryResults
              .map((r) => _buildResultItem(r, theme, state.query)),
          const SizedBox(height: 12),
        ],
        if (noteResults.isNotEmpty) ...[
          _buildSectionHeader('MY NOTES (${noteResults.length})', theme),
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
    } else if (result.type == SearchResultType.pericope) {
      icon = Icons.auto_stories_rounded;
    } else {
      icon = Icons.library_books_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => _onResultTap(result),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: '${result.title}\n${result.snippet.replaceAll('...', '')}'));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied to clipboard')),
          );
        },
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
    final typography = ref.watch(typographyProvider);
    
    // Scale down the reading font size proportionally for list view (e.g. 80%)
    // But keep a reasonable minimum size so it's readable.
    final resultFontSize = (typography.fontSize * 0.85).clamp(14.0, 24.0);
    
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      height: 1.5,
      fontSize: resultFontSize,
      fontFamily: typography.fontFamily,
      fontStyle: typography.fontStyle,
    );

    if (query.isEmpty) {
      return Text(text,
          style: baseStyle, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    
    if (!textLower.contains(queryLower)) {
      return Text(text,
          style: baseStyle, maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.amberAccent
        : Colors.amber.shade800;
    final highlightStyle = baseStyle?.copyWith(
      color: highlightColor,
      fontWeight: FontWeight.bold,
      backgroundColor: highlightColor.withValues(alpha: 0.12),
    );

    List<InlineSpan> spans = [];
    int start = 0;
    int idx;
    
    while ((idx = textLower.indexOf(queryLower, start)) != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
      }
      spans.add(TextSpan(
          text: text.substring(idx, idx + query.length),
          style: highlightStyle));
      start = idx + query.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: spans,
      ),
    );
  }
}
