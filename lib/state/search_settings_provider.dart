import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchSettingsState {
  final bool autoOpenSingleSearchResult;
  const SearchSettingsState({this.autoOpenSingleSearchResult = true});
}

class SearchSettingsNotifier extends Notifier<SearchSettingsState> {
  static const _autoOpenKey = 'search_auto_open_single';

  @override
  SearchSettingsState build() {
    _loadSettings();
    return const SearchSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final autoOpen = prefs.getBool(_autoOpenKey) ?? true;
    state = SearchSettingsState(autoOpenSingleSearchResult: autoOpen);
  }

  Future<void> toggleAutoOpen(bool value) async {
    state = SearchSettingsState(autoOpenSingleSearchResult: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoOpenKey, value);
  }
}

final searchSettingsProvider = NotifierProvider<SearchSettingsNotifier, SearchSettingsState>(SearchSettingsNotifier.new);
