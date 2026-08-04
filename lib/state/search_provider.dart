import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_engine.dart';

import '../data/local_storage/preferences_service.dart';

class SearchState {
  final String query;
  final bool filterOt;
  final bool filterNt;
  final bool filterCommentary;
  final bool filterNotes;
  final bool exactMatch;
  final List<SearchResult> results;
  final bool isSearching;
  final List<SearchResult> recentPlaces;
  final bool showFilters;

  SearchState({
    this.query = '',
    this.filterOt = true,
    this.filterNt = true,
    this.filterCommentary = true,
    this.filterNotes = true,
    this.exactMatch = false,
    this.results = const [],
    this.isSearching = false,
    this.recentPlaces = const [],
    this.showFilters = false,
  });

  SearchState copyWith({
    String? query,
    bool? filterOt,
    bool? filterNt,
    bool? filterCommentary,
    bool? filterNotes,
    bool? exactMatch,
    List<SearchResult>? results,
    bool? isSearching,
    List<SearchResult>? recentPlaces,
    bool? showFilters,
  }) {
    return SearchState(
      query: query ?? this.query,
      filterOt: filterOt ?? this.filterOt,
      filterNt: filterNt ?? this.filterNt,
      filterCommentary: filterCommentary ?? this.filterCommentary,
      filterNotes: filterNotes ?? this.filterNotes,
      exactMatch: exactMatch ?? this.exactMatch,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      recentPlaces: recentPlaces ?? this.recentPlaces,
      showFilters: showFilters ?? this.showFilters,
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

    final prefs = ref.watch(preferencesProvider);
    final history = prefs.getSearchHistory();

    return SearchState(
      recentPlaces: history,
      filterOt: prefs.prefs.getBool('search_filter_ot') ?? true,
      filterNt: prefs.prefs.getBool('search_filter_nt') ?? true,
      filterCommentary: prefs.prefs.getBool('search_filter_comm') ?? true,
      filterNotes: prefs.prefs.getBool('search_filter_notes') ?? true,
      exactMatch: prefs.prefs.getBool('search_exact_match') ?? false,
    );
  }

  void _saveFilters() {
    final prefs = ref.read(preferencesProvider).prefs;
    prefs.setBool('search_filter_ot', state.filterOt);
    prefs.setBool('search_filter_nt', state.filterNt);
    prefs.setBool('search_filter_comm', state.filterCommentary);
    prefs.setBool('search_filter_notes', state.filterNotes);
    prefs.setBool('search_exact_match', state.exactMatch);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query, isSearching: true);

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void toggleFilters() {
    state = state.copyWith(showFilters: !state.showFilters);
  }

  void toggleOtFilter() {
    state = state.copyWith(filterOt: !state.filterOt);
    _performSearch();
    _saveFilters();
  }

  void toggleNtFilter() {
    state = state.copyWith(filterNt: !state.filterNt);
    _performSearch();
    _saveFilters();
  }

  void toggleCommentaryFilter() {
    state = state.copyWith(filterCommentary: !state.filterCommentary);
    _performSearch();
    _saveFilters();
  }

  void toggleNotesFilter() {
    state = state.copyWith(filterNotes: !state.filterNotes);
    _performSearch();
    _saveFilters();
  }

  void toggleExactMatch() {
    state = state.copyWith(exactMatch: !state.exactMatch);
    _performSearch();
    _saveFilters();
  }

  void addRecentPlace(SearchResult result) {
    final updatedList = [
      result,
      ...state.recentPlaces.where((r) => r.title != result.title)
    ].take(10).toList();
    state = state.copyWith(recentPlaces: updatedList);
    ref.read(preferencesProvider).saveSearchHistory(updatedList);
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
      includeOt: state.filterOt,
      includeNt: state.filterNt,
      includeCommentary: state.filterCommentary,
      includeNotes: state.filterNotes,
      exactMatch: state.exactMatch,
    );

    // If query changed while searching, don't update results
    final currentQuery = ref.read(searchStateProvider).query;
    if (currentQuery != state.query) return;

    state = state.copyWith(results: results, isSearching: false);
  }
}

final searchStateProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
