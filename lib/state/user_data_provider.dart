import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../data/models/bookmark_model.dart';
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
  Color(0xFFDC143C), // Crimson
];

const List<Color> highlightPaletteSwatches = [
  Color(0xFFE9D5FF), // Purple pastel
  Color(0xFFBBF7D0), // Green pastel
  Color(0xFFBAE6FD), // Blue pastel
  Color(0xFFFBCFE8), // Pink pastel
  Color(0xFFFECACA), // Red pastel (used for swatch rendering only)
];

const List<String> highlightPaletteNames = [
  'Purple',
  'Green',
  'Blue',
  'Pink',
  'Red',
];

class BookmarkDataNotifier extends Notifier<BookmarkData> {
  @override
  BookmarkData build() {
    final prefs = ref.watch(preferencesProvider);
    final jsonStr = prefs.getBookmarksV2();

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr);
        return BookmarkData.fromJson(decoded);
      } catch (e) {
        debugPrint('Error parsing bookmarks_v2: $e');
      }
    }

    // Migration
    final b = prefs.getBookmarks().toSet();
    final f = prefs.getFavorites().toSet();
    final legacyMerged = {...b, ...f};

    final nodes = <String, BookmarkNode>{};
    final now = DateTime.now();
    for (final ref in legacyMerged) {
      nodes[ref] = BookmarkNode(
        reference: ref,
        createdAt: now,
        folderId: null,
      );
    }

    final folders = [
      BookmarkFolder(id: 'folder_sermon', name: 'Sermon prep'),
      BookmarkFolder(id: 'folder_memorize', name: 'Memorize'),
      BookmarkFolder(id: 'folder_comfort', name: 'Comfort'),
      BookmarkFolder(id: 'folder_study', name: 'Study'),
    ];

    final newData = BookmarkData(folders: folders, nodes: nodes);

    // Initial migration save with read-back verification
    if (jsonStr == null || jsonStr.isEmpty) {
      Future.microtask(() {
        prefs.saveBookmarksV2(jsonEncode(newData.toJson()));

        // Read back check
        final readBackStr = prefs.getBookmarksV2();
        bool verificationPassed = false;
        if (readBackStr != null) {
          try {
            final readBack = BookmarkData.fromJson(jsonDecode(readBackStr));
            if (readBack.nodes.length == legacyMerged.length) {
              verificationPassed = true;
            }
          } catch (e) {
            debugPrint('Migration verification failed parsing: $e');
          }
        }

        if (!verificationPassed) {
          prefs.removeBookmarksV2();
          debugPrint('MIGRATION READ-BACK FAILED. Legacy data untouched. Migration reverted.');
        } else {
          debugPrint('MIGRATION SUCCESS: Read-back verified ${nodes.length} bookmarks.');
        }
      });
    }

    return newData;
  }

  void toggle(String reference) {
    final currentNodes = Map<String, BookmarkNode>.from(state.nodes);

    if (currentNodes.containsKey(reference)) {
      currentNodes.remove(reference);
    } else {
      currentNodes[reference] = BookmarkNode(
        reference: reference,
        createdAt: DateTime.now(),
        folderId: null,
      );
    }

    final newData = BookmarkData(folders: state.folders, nodes: currentNodes);
    state = newData;
    ref.read(preferencesProvider).saveBookmarksV2(jsonEncode(newData.toJson()));
  }
}

final bookmarkDataProvider =
    NotifierProvider<BookmarkDataNotifier, BookmarkData>(BookmarkDataNotifier.new);

class BookmarksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final data = ref.watch(bookmarkDataProvider);
    return data.nodes.keys.toSet();
  }

  void toggle(String reference) {
    ref.read(bookmarkDataProvider.notifier).toggle(reference);
  }
}

final bookmarksProvider =
    NotifierProvider<BookmarksNotifier, Set<String>>(BookmarksNotifier.new);

const bool kHighlightDebug = false;

class HighlightsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    final prefs = ref.watch(preferencesProvider);
    final data = prefs.getHighlights();

    bool needsCleanup = false;
    final keysToRemove = <String>[];
    for (final key in data.keys) {
      final underscoreIdx = key.indexOf('_');
      if (underscoreIdx > 3) {
        keysToRemove.add(key);
        needsCleanup = true;
      }
    }

    if (needsCleanup) {
      for (final key in keysToRemove) {
        data.remove(key);
      }
      Future.microtask(() => prefs.saveHighlights(data));
    }

    return data;
  }

  void toggleHighlight(String reference, int colorIndex) {
    final current = Map<String, int>.from(state);
    if (current.containsKey(reference) && current[reference] == colorIndex) {
      current.remove(reference);
    } else {
      current[reference] = colorIndex;
    }
    state = current;
    ref.read(preferencesProvider).saveHighlights(current);
  }

  void removeHighlight(String reference) {
    final current = Map<String, int>.from(state);
    if (current.containsKey(reference)) {
      current.remove(reference);
      state = current;
      ref.read(preferencesProvider).saveHighlights(current);
    }
  }
}

final highlightsProvider =
    NotifierProvider<HighlightsNotifier, Map<String, int>>(
        HighlightsNotifier.new);
