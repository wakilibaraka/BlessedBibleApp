import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

/// Centralized key generator for persistent verse data (bookmarks, highlights, etc.)
String generateVerseKey(String bookName, int chapterNum, int verseNum) {
  return '$bookName $chapterNum:$verseNum';
}

const List<Color> highlightPalette = [
  Colors.yellow,
  Colors.lightGreen,
  Colors.lightBlue,
  Colors.pinkAccent,
  Colors.orange,
];

class BookmarksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final list = await preferencesService.getBookmarks();
    state = list.toSet();
  }

  void toggle(String reference) {
    if (state.contains(reference)) {
      state = {...state}..remove(reference);
    } else {
      state = {...state, reference};
    }
    preferencesService.saveBookmarks(state.toList());
  }
}

final bookmarksProvider = NotifierProvider<BookmarksNotifier, Set<String>>(BookmarksNotifier.new);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final list = await preferencesService.getFavorites();
    state = list.toSet();
  }

  void toggle(String reference) {
    if (state.contains(reference)) {
      state = {...state}..remove(reference);
    } else {
      state = {...state, reference};
    }
    preferencesService.saveFavorites(state.toList());
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

class HighlightsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final map = await preferencesService.getHighlights();
    state = Map.from(map);
  }

  void toggleHighlight(String reference, int colorIndex) {
    final newState = Map<String, int>.from(state);
    if (newState.containsKey(reference) && newState[reference] == colorIndex) {
      newState.remove(reference); // Toggle off if tapping the same color
    } else {
      newState[reference] = colorIndex; // Update or add highlight
    }
    state = newState;
    preferencesService.saveHighlights(newState);
  }
}

final highlightsProvider = NotifierProvider<HighlightsNotifier, Map<String, int>>(HighlightsNotifier.new);

