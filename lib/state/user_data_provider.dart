import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

/// Canonical key for persistent verse data (bookmarks, highlights, etc.).
/// Uses the 3-letter abbreviation (e.g. 'GEN', '1CO') which is unique and
/// collision-free — avoids the '1 Corinthians' vs '1 Chronicles' problem.
String generateVerseKey(String bookAbbrev, int chapterNum, int verseNum) {
  return '${bookAbbrev.toUpperCase()}_$chapterNum:$verseNum';
}

const List<Color> highlightPalette = [
  Color(0xFFE9D5FF), // Purple pastel
  Color(0xFFBBF7D0), // Green pastel
  Color(0xFFBAE6FD), // Blue pastel
  Color(0xFFFBCFE8), // Pink pastel
  Color(0xFFFECACA), // Red pastel
];

const List<String> highlightPaletteNames = [
  'Purple',
  'Green',
  'Blue',
  'Pink',
  'Red',
];

class BookmarksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final prefs = ref.watch(preferencesProvider);
    final b = prefs.getBookmarks().toSet();
    final f = prefs.getFavorites().toSet();
    final merged = {...b, ...f};
    
    if (merged.length > b.length) {
      Future.microtask(() => prefs.saveBookmarks(merged.toList()));
    }
    return merged;
  }

  void toggle(String reference) {
    if (state.contains(reference)) {
      state = {...state}..remove(reference);
    } else {
      state = {...state, reference};
    }
    ref.read(preferencesProvider).saveBookmarks(state.toList());
  }
}

final bookmarksProvider = NotifierProvider<BookmarksNotifier, Set<String>>(BookmarksNotifier.new);



const bool kHighlightDebug = true;

class HighlightsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    final prefs = ref.watch(preferencesProvider);
    final data = prefs.getHighlights();
    if (kHighlightDebug) {
      debugPrint('[HIGHLIGHT_DEBUG] NOTIFIER init: loaded ${data.length} highlights');
    }
    return data;
  }

  void toggleHighlight(String reference, int colorIndex) {
    if (kHighlightDebug) {
      debugPrint('[HIGHLIGHT_DEBUG] NOTIFIER toggleHighlight called: ref=$reference, color=$colorIndex');
    }
    final current = Map<String, int>.from(state);
    if (current.containsKey(reference) && current[reference] == colorIndex) {
      current.remove(reference);
      if (kHighlightDebug) debugPrint('[HIGHLIGHT_DEBUG] NOTIFIER removing highlight for $reference');
    } else {
      current[reference] = colorIndex;
      if (kHighlightDebug) debugPrint('[HIGHLIGHT_DEBUG] NOTIFIER adding highlight for $reference -> $colorIndex');
    }
    state = current;
    ref.read(preferencesProvider).saveHighlights(current);
    if (kHighlightDebug) {
      debugPrint('[HIGHLIGHT_DEBUG] NOTIFIER map after write: $current');
    }
  }
}

final highlightsProvider = NotifierProvider<HighlightsNotifier, Map<String, int>>(HighlightsNotifier.new);
