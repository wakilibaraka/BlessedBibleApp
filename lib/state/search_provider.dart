import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_engine.dart';
import '../data/local_storage/preferences_service.dart';
import 'search_settings_provider.dart';

class SearchState {
  final String query;
  final bool filterOt;
  final bool filterNt;
  final bool filterCommentary;
  final bool filterNotes;
  final bool exactMatch;
  final String? filterBook;
  final List<SearchResult> results;
  final bool isSearching;
  final List<SearchResult> recentPlaces;
  final List<String> recentQueries;
  final bool showFilters;

  SearchState({
    this.query = '',
    this.filterOt = true,
    this.filterNt = true,
    this.filterCommentary = true,
    this.filterNotes = false,
    this.exactMatch = false,
    this.filterBook,
    this.results = const [],
    this.isSearching = false,
    this.recentPlaces = const [],
    this.recentQueries = const [],
    this.showFilters = false,
  });

  SearchState copyWith({
    String? query,
    bool? filterOt,
    bool? filterNt,
    bool? filterCommentary,
    bool? filterNotes,
    bool? exactMatch,
    String? filterBook,
    bool clearFilterBook = false,
    List<SearchResult>? results,
    bool? isSearching,
    List<SearchResult>? recentPlaces,
    List<String>? recentQueries,
    bool? showFilters,
  }) {
    return SearchState(
      query: query ?? this.query,
      filterOt: filterOt ?? this.filterOt,
      filterNt: filterNt ?? this.filterNt,
      filterCommentary: filterCommentary ?? this.filterCommentary,
      filterNotes: filterNotes ?? this.filterNotes,
      exactMatch: exactMatch ?? this.exactMatch,
      filterBook: clearFilterBook ? null : (filterBook ?? this.filterBook),
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      recentPlaces: recentPlaces ?? this.recentPlaces,
      recentQueries: recentQueries ?? this.recentQueries,
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
    final settings = ref.watch(searchSettingsProvider);
    final history = prefs.getSearchHistory();
    final recentQueries = prefs.getRecentSearchQueries();

    return SearchState(
      recentPlaces: history,
      recentQueries: recentQueries,
      filterOt: settings.defaultSearchOt,
      filterNt: settings.defaultSearchNt,
      filterCommentary: settings.defaultSearchCommentary,
      filterNotes: settings.defaultSearchNotes,
      exactMatch: settings.matchWholeWords,
    );
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
  }

  void toggleNtFilter() {
    state = state.copyWith(filterNt: !state.filterNt);
    _performSearch();
  }

  void toggleCommentaryFilter() {
    state = state.copyWith(filterCommentary: !state.filterCommentary);
    _performSearch();
  }

  void toggleNotesFilter() {
    state = state.copyWith(filterNotes: !state.filterNotes);
    _performSearch();
  }

  void setFilterBook(String? bookName) {
    state = state.copyWith(filterBook: bookName, clearFilterBook: bookName == null);
    _performSearch();
  }

  void toggleExactMatch() {
    state = state.copyWith(exactMatch: !state.exactMatch);
    _performSearch();
  }

  void addRecentPlace(SearchResult result) {
    final updatedList = [
      result,
      ...state.recentPlaces.where((r) => r.title != result.title)
    ].take(10).toList();
    state = state.copyWith(recentPlaces: updatedList);
    ref.read(preferencesProvider).saveSearchHistory(updatedList);
    _addRecentQuery(state.query);
  }

  void _addRecentQuery(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final updatedQueries = [
      q,
      ...state.recentQueries.where((r) => r.toLowerCase() != q.toLowerCase())
    ].take(10).toList();
    state = state.copyWith(recentQueries: updatedQueries);
    ref.read(preferencesProvider).saveRecentSearchQueries(updatedQueries);
  }

  void clearRecentQueries() {
    state = state.copyWith(recentQueries: []);
    ref.read(preferencesProvider).saveRecentSearchQueries([]);
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
    final settings = ref.read(searchSettingsProvider);
    final results = await engine.search(
      state.query,
      includeOt: state.filterOt,
      includeNt: state.filterNt,
      includeCommentary: state.filterCommentary,
      includeNotes: state.filterNotes && settings.includeNotesInSearch,
      exactMatch: state.exactMatch,
      filterBook: state.filterBook,
    );

    // If query changed while searching, don't update results
    final currentQuery = ref.read(searchStateProvider).query;
    if (currentQuery != state.query) return;

    state = state.copyWith(results: results, isSearching: false);
  }
}

final searchStateProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
