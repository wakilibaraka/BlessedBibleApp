import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/search_engine.dart';

class PreferencesService {
  final SharedPreferences prefs;

  PreferencesService(this.prefs);

  static const String _searchHistoryKey = 'search_history';
  static const String _bookmarksKey = 'bookmarks';
  static const String _favoritesKey = 'favorites';
  static const String _highlightsKey = 'highlights';
  static const String _lastTabKey = 'last_tab';
  static const String _lastReadLocKey = 'last_read_loc';
  static const String _studyLayoutKey = 'study_layout';
  static const String _readingPlanStateKey = 'reading_plan_state';

  void saveSearchHistory(List<SearchResult> history) {
    final jsonList = history.map((e) => e.toJson()).toList();
    prefs.setString(_searchHistoryKey, jsonEncode(jsonList));
  }

  List<SearchResult> getSearchHistory() {
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

  void saveBookmarks(List<String> bookmarks) {
    prefs.setStringList(_bookmarksKey, bookmarks);
  }

  List<String> getBookmarks() {
    return prefs.getStringList(_bookmarksKey) ?? [];
  }

  void saveFavorites(List<String> favorites) {
    prefs.setStringList(_favoritesKey, favorites);
  }

  List<String> getFavorites() {
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  void saveHighlights(Map<String, int> highlights) {
    prefs.setString(_highlightsKey, jsonEncode(highlights));
  }

  Map<String, int> getHighlights() {
    final jsonString = prefs.getString(_highlightsKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return jsonMap.map((key, value) => MapEntry(key, value as int));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  void saveLastTab(int index) {
    prefs.setInt(_lastTabKey, index);
  }

  int? getLastTab() {
    return prefs.getInt(_lastTabKey);
  }

  void saveLastReadLocation({
    required String bookAbbrev,
    required String bookName,
    required int chapter,
    required int verseIndex,
  }) {
    final data = {
      'bookAbbrev': bookAbbrev,
      'bookName': bookName,
      'chapter': chapter,
      'verseIndex': verseIndex,
    };
    prefs.setString(_lastReadLocKey, jsonEncode(data));
  }

  Map<String, dynamic>? getLastReadLocation() {
    final jsonString = prefs.getString(_lastReadLocKey);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void saveStudyLayout(String jsonString) {
    prefs.setString(_studyLayoutKey, jsonString);
  }

  String? getStudyLayout() {
    return prefs.getString(_studyLayoutKey);
  }

  void saveReadingPlanState(Map<String, dynamic> state) {
    prefs.setString(_readingPlanStateKey, jsonEncode(state));
  }

  Map<String, dynamic>? getReadingPlanState() {
    final jsonString = prefs.getString(_readingPlanStateKey);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static const String _chapterPositionsKey = 'chapter_positions';
  static const int _expiryMillis = 7 * 24 * 60 * 60 * 1000; // 7 days

  void saveChapterScrollPosition(String bookAbbrev, int chapter, int verseIndex) {
    final jsonString = prefs.getString(_chapterPositionsKey);
    Map<String, dynamic> map = {};
    if (jsonString != null) {
      try {
        map = jsonDecode(jsonString);
      } catch (_) {}
    }
    
    final key = '${bookAbbrev}_$chapter';
    map[key] = {
      'verseIndex': verseIndex,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    prefs.setString(_chapterPositionsKey, jsonEncode(map));
  }

  int? getChapterScrollPosition(String bookAbbrev, int chapter) {
    final jsonString = prefs.getString(_chapterPositionsKey);
    if (jsonString == null) return null;
    
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final key = '${bookAbbrev}_$chapter';
      if (!map.containsKey(key)) return null;
      
      final data = map[key] as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final verseIndex = data['verseIndex'] as int;
      
      if (DateTime.now().millisecondsSinceEpoch - timestamp < _expiryMillis) {
        return verseIndex;
      } else {
        // Expired, clean it up
        map.remove(key);
        prefs.setString(_chapterPositionsKey, jsonEncode(map));
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}

final preferencesProvider = Provider<PreferencesService>((ref) => throw UnimplementedError());
