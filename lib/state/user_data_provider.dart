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
  Colors.yellow,
  Colors.lightGreen,
  Colors.lightBlue,
  Colors.pinkAccent,
  Colors.orange,
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



const bool kHighlightDebug = false;

class HighlightsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    return Map.from(ref.watch(preferencesProvider).getHighlights());
  }

  void toggleHighlight(String reference, int colorIndex) {
    if (kHighlightDebug) {
      debugPrint('[HIGHLIGHT_DEBUG] NOTIFIER toggleHighlight reference=$reference colorIndex=$colorIndex oldState=$state');
    }
    final newState = Map<String, int>.from(state);
    if (newState.containsKey(reference) && newState[reference] == colorIndex) {
      if (kHighlightDebug) debugPrint('[HIGHLIGHT_DEBUG] NOTIFIER removing highlight for $reference');
      newState.remove(reference); // Toggle off if tapping the same color
    } else {
      if (kHighlightDebug) debugPrint('[HIGHLIGHT_DEBUG] NOTIFIER adding highlight for $reference -> $colorIndex');
      newState[reference] = colorIndex; // Update or add highlight
    }
    state = newState;
    if (kHighlightDebug) {
      debugPrint('[HIGHLIGHT_DEBUG] NOTIFIER state updated. newState=$state (len=${state.length})');
    }
    ref.read(preferencesProvider).saveHighlights(newState);
  }
}

final highlightsProvider = NotifierProvider<HighlightsNotifier, Map<String, int>>(HighlightsNotifier.new);

