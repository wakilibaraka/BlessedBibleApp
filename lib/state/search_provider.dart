import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_engine.dart';

import '../data/local_storage/preferences_service.dart';

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
  Timer? _debounce;

  @override
  SearchState build() {
    // Reactively update search results when commentary data resolves
    ref.listen(searchEngineProvider, (previous, next) {
      if (state.query.trim().isNotEmpty) {
        _performSearch();
      }
    });

    _loadRecentPlaces();

    return SearchState();
  }

  Future<void> _loadRecentPlaces() async {
    final history = await preferencesService.getSearchHistory();
    state = state.copyWith(recentPlaces: history);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query, isSearching: true);
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
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
    preferencesService.saveSearchHistory(updatedList);
  }

  Future<void> _performSearch() async {
    if (state.query.trim().isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    // Force isSearching to true again in case it was toggled by a filter change
    if (!state.isSearching) {
      state = state.copyWith(isSearching: true);
    }

    final engine = ref.read(searchEngineProvider);
    final results = await engine.search(
      state.query,
      includeBible: state.filterBible,
      includeCommentary: state.filterCommentary,
    );

    // If query changed while searching, don't update results
    final currentQuery = ref.read(searchStateProvider).query;
    if (currentQuery != state.query) return;

    state = state.copyWith(results: results, isSearching: false);
  }
}

final searchStateProvider = NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
