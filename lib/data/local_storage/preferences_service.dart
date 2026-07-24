import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../state/search_engine.dart';

class PreferencesService {
  static const String _searchHistoryKey = 'search_history';
  static const String _bookmarksKey = 'bookmarks';
  static const String _favoritesKey = 'favorites';
  static const String _highlightsKey = 'highlights';

  Future<void> saveSearchHistory(List<SearchResult> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_searchHistoryKey, jsonEncode(jsonList));
  }

  Future<List<SearchResult>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_searchHistoryKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((e) => SearchResult.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Future<void> saveBookmarks(List<String> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarksKey, bookmarks);
  }

  Future<List<String>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarksKey) ?? [];
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> saveHighlights(Map<String, int> highlights) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_highlightsKey, jsonEncode(highlights));
  }

  Future<Map<String, int>> getHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_highlightsKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((key, value) => MapEntry(key, value as int));
      } catch (e) {
        return {};
      }
    }
    return {};
  }
}

final preferencesService = PreferencesService();
