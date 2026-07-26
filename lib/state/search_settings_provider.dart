import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchSettingsState {
  final bool autoOpenSingleSearchResult;
  final bool useClassicSearch;
  
  const SearchSettingsState({
    this.autoOpenSingleSearchResult = true,
    this.useClassicSearch = false,
  });
}

class SearchSettingsNotifier extends Notifier<SearchSettingsState> {
  static const _autoOpenKey = 'search_auto_open_single';
  static const _useClassicSearchKey = 'search_use_classic_search';

  @override
  SearchSettingsState build() {
    _loadSettings();
    return const SearchSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final autoOpen = prefs.getBool(_autoOpenKey) ?? true;
    final classic = prefs.getBool(_useClassicSearchKey) ?? false;
    state = SearchSettingsState(
      autoOpenSingleSearchResult: autoOpen,
      useClassicSearch: classic,
    );
  }

  Future<void> toggleAutoOpen(bool value) async {
    state = SearchSettingsState(
      autoOpenSingleSearchResult: value,
      useClassicSearch: state.useClassicSearch,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoOpenKey, value);
  }

  Future<void> toggleClassicSearch(bool value) async {
    state = SearchSettingsState(
      autoOpenSingleSearchResult: state.autoOpenSingleSearchResult,
      useClassicSearch: value,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useClassicSearchKey, value);
  }
}

final searchSettingsProvider = NotifierProvider<SearchSettingsNotifier, SearchSettingsState>(SearchSettingsNotifier.new);
