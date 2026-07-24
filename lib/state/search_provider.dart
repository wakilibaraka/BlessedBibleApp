import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_engine.dart';

class SearchState {
  final String query;
  final bool filterBible;
  final bool filterCommentary;
  final List<SearchResult> results;
  final bool isSearching;
  final List<SearchResult> recentPlaces;

  SearchState({
    this.query = '',
    this.filterBible = true,
    this.filterCommentary = true,
    this.results = const [],
    this.isSearching = false,
    this.recentPlaces = const [],
  });

  SearchState copyWith({
    String? query,
    bool? filterBible,
    bool? filterCommentary,
    List<SearchResult>? results,
    bool? isSearching,
    List<SearchResult>? recentPlaces,
  }) {
    return SearchState(
      query: query ?? this.query,
      filterBible: filterBible ?? this.filterBible,
      filterCommentary: filterCommentary ?? this.filterCommentary,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      recentPlaces: recentPlaces ?? this.recentPlaces,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    // Reactively update search results when commentary data resolves
    ref.listen(searchEngineProvider, (previous, next) {
      if (state.query.trim().isNotEmpty) {
        _performSearch();
      }
    });

    return SearchState(
      // Seed with some mock recent places
      recentPlaces: [
        SearchResult(
          title: 'Revelation 14:1',
          subtitle: 'Bible Verse',
          snippet: 'And I looked, and, lo, a Lamb stood on the mount Sion...',
          type: SearchResultType.bible,
          metadata: {'book': 'Revelation', 'chapter': 14, 'verse': 1},
        ),
        SearchResult(
          title: 'Genesis 1:1 - Uriah Smith',
          subtitle: 'Commentary Note',
          snippet: 'God spoke, and His words created His works...',
          type: SearchResultType.commentary,
          metadata: {'book': 'Genesis', 'chapter': 1, 'verse': 1},
        ),
      ]
    );
  }

  void setQuery(String query) {
    state = state.copyWith(query: query, isSearching: true);
    _performSearch();
  }

  void toggleBibleFilter() {
    state = state.copyWith(filterBible: !state.filterBible);
    _performSearch();
  }

  void toggleCommentaryFilter() {
    state = state.copyWith(filterCommentary: !state.filterCommentary);
    _performSearch();
  }

  void addRecentPlace(SearchResult result) {
    final updatedList = [result, ...state.recentPlaces.where((r) => r.title != result.title)].take(10).toList();
    state = state.copyWith(recentPlaces: updatedList);
  }

  void _performSearch() {
    if (state.query.trim().isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    final engine = ref.read(searchEngineProvider);
    final results = engine.search(
      state.query,
      includeBible: state.filterBible,
      includeCommentary: state.filterCommentary,
    );

    state = state.copyWith(results: results, isSearching: false);
  }
}

final searchStateProvider = NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
