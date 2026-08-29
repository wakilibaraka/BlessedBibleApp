import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchSettingsState {
  final bool autoOpenSingleSearchResult;
  final bool defaultSearchOt;
  final bool defaultSearchNt;
  final bool defaultSearchCommentary;
  final bool defaultSearchNotes;
  final bool includeNotesInSearch;
  final bool matchWholeWords;

  const SearchSettingsState({
    this.autoOpenSingleSearchResult = false,
    this.defaultSearchOt = true,
    this.defaultSearchNt = true,
    this.defaultSearchCommentary = true,
    this.defaultSearchNotes = false,
    this.includeNotesInSearch = false,
    this.matchWholeWords = false,
  });
}

class SearchSettingsNotifier extends Notifier<SearchSettingsState> {
  static const _autoOpenKey = 'search_auto_open_single';
  static const _defaultOtKey = 'search_default_ot';
  static const _defaultNtKey = 'search_default_nt';
  static const _defaultCommKey = 'search_default_comm';
  static const _defaultNotesKey = 'search_default_notes';
  static const _includeNotesKey = 'search_include_notes';
  static const _matchWholeWordsKey = 'search_match_whole_words';

  @override
  SearchSettingsState build() {
    _loadSettings();
    return const SearchSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SearchSettingsState(
      autoOpenSingleSearchResult: prefs.getBool(_autoOpenKey) ?? false,
      defaultSearchOt: prefs.getBool(_defaultOtKey) ?? true,
      defaultSearchNt: prefs.getBool(_defaultNtKey) ?? true,
      defaultSearchCommentary: prefs.getBool(_defaultCommKey) ?? true,
      defaultSearchNotes: prefs.getBool(_defaultNotesKey) ?? false,
      includeNotesInSearch: prefs.getBool(_includeNotesKey) ?? false,
      matchWholeWords: prefs.getBool(_matchWholeWordsKey) ?? false,
    );
  }

  Future<void> toggleAutoOpen(bool value) async {
    state = SearchSettingsState(
      autoOpenSingleSearchResult: value,
      defaultSearchOt: state.defaultSearchOt,
      defaultSearchNt: state.defaultSearchNt,
      defaultSearchCommentary: state.defaultSearchCommentary,
      defaultSearchNotes: state.defaultSearchNotes,
      includeNotesInSearch: state.includeNotesInSearch,
      matchWholeWords: state.matchWholeWords,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoOpenKey, value);
  }

  Future<void> toggleDefaultOt(bool value) async {
    state = SearchSettingsState(
      autoOpenSingleSearchResult: state.autoOpenSingleSearchResult,
      defaultSearchOt: value,
      defaultSearchNt: state.defaultSearchNt,
      defaultSearchCommentary: state.defaultSearchCommentary,
      defaultSearchNotes: state.defaultSearchNotes,
      includeNotesInSearch: state.includeNotesInSearch,
      matchWholeWords: state.matchWholeWords,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_defaultOtKey, value);
  }

  Future<void> toggleDefaultNt(bool value) async {
    state = SearchSettingsState(
      autoOpenSingleSearchResult: state.autoOpenSingleSearchResult,
      defaultSearchOt: state.defaultSearchOt,
      defaultSearchNt: value,
      defaultSearchCommentary: state.defaultSearchCommentary,
      defaultSearchNotes: state.defaultSearchNotes,
      includeNotesInSearch: state.includeNotesInSearch,
      matchWholeWords: state.matchWholeWords,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_defaultNtKey, value);
  }

  Future<void> toggleDefaultCommentary(bool value) async {
    state = SearchSettingsState(
      autoOpenSingleSearchResult: state.autoOpenSingleSearchResult,
      defaultSearchOt: state.defaultSearchOt,
      defaultSearchNt: state.defaultSearchNt,
      defaultSearchCommentary: value,
      defaultSearchNotes: state.defaultSearchNotes,
      includeNotesInSearch: state.includeNotesInSearch,
      matchWholeWords: state.matchWholeWords,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_defaultCommKey, value);
  }

  Future<void> toggleDefaultNotes(bool value) async {
    state = SearchSettingsState(
      autoOpenSingleSearchResult: state.autoOpenSingleSearchResult,
      defaultSearchOt: state.defaultSearchOt,
      defaultSearchNt: state.defaultSearchNt,
      defaultSearchCommentary: state.defaultSearchCommentary,
      defaultSearchNotes: value,
      includeNotesInSearch: state.includeNotesInSearch,
      matchWholeWords: state.matchWholeWords,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_defaultNotesKey, value);
  }

  Future<void> toggleIncludeNotes(bool value) async {
    state = SearchSettingsState(
      autoOpenSingleSearchResult: state.autoOpenSingleSearchResult,
      defaultSearchOt: state.defaultSearchOt,
      defaultSearchNt: state.defaultSearchNt,
      defaultSearchCommentary: state.defaultSearchCommentary,
      defaultSearchNotes: state.defaultSearchNotes,
      includeNotesInSearch: value,
      matchWholeWords: state.matchWholeWords,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_includeNotesKey, value);
  }

  Future<void> toggleMatchWholeWords(bool value) async {
    state = SearchSettingsState(
      autoOpenSingleSearchResult: state.autoOpenSingleSearchResult,
      defaultSearchOt: state.defaultSearchOt,
      defaultSearchNt: state.defaultSearchNt,
      defaultSearchCommentary: state.defaultSearchCommentary,
      defaultSearchNotes: state.defaultSearchNotes,
      includeNotesInSearch: state.includeNotesInSearch,
      matchWholeWords: value,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_matchWholeWordsKey, value);
  }
}

final searchSettingsProvider =
    NotifierProvider<SearchSettingsNotifier, SearchSettingsState>(
        SearchSettingsNotifier.new);
