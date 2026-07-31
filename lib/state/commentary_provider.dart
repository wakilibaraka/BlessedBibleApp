import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/commentary_entry.dart';
import '../data/local_storage/preferences_service.dart';

class CommentaryNotifier extends AsyncNotifier<List<CommentaryEntry>> {
  @override
  Future<List<CommentaryEntry>> build() async {
    return _loadCommentary();
  }

  Future<List<CommentaryEntry>> _loadCommentary() async {
    try {
      final jsonString = await rootBundle.loadString('assets/commentary/commentary.json');
      final decoded = jsonDecode(jsonString);
      
      List<dynamic> entriesList;
      if (decoded is Map<String, dynamic> && decoded.containsKey('entries')) {
        entriesList = decoded['entries'] as List<dynamic>;
      } else if (decoded is List) {
        entriesList = decoded;
      } else {
        return [];
      }

      return entriesList.map((e) => CommentaryEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // If the file is missing or empty, do not crash; return empty list
      return [];
    }
  }

  List<CommentaryEntry> commentaryForVerse(String book, int chapter, int verse) {
    final list = state.value ?? [];
    return list.where((e) =>
      e.scope.type == 'verse' &&
      e.scope.book?.toLowerCase() == book.toLowerCase() &&
      e.scope.chapter == chapter &&
      e.scope.verse == verse
    ).toList();
  }

  List<CommentaryEntry> commentaryForChapterVerses(String book, int chapter) {
    final list = state.value ?? [];
    final entries = list.where((e) =>
      e.scope.type == 'verse' &&
      e.scope.book?.toLowerCase() == book.toLowerCase() &&
      e.scope.chapter == chapter
    ).toList();
    entries.sort((a, b) => (a.scope.verse ?? 0).compareTo(b.scope.verse ?? 0));
    return entries;
  }

  List<CommentaryEntry> commentaryForChapter(String book, int chapter) {
    final list = state.value ?? [];
    return list.where((e) =>
      e.scope.type == 'chapter' &&
      e.scope.book?.toLowerCase() == book.toLowerCase() &&
      e.scope.chapter == chapter
    ).toList();
  }

  List<CommentaryEntry> commentaryForBook(String book) {
    final list = state.value ?? [];
    return list.where((e) =>
      e.scope.type == 'book' &&
      e.scope.book?.toLowerCase() == book.toLowerCase()
    ).toList();
  }

  List<CommentaryEntry> commentaryForTopic(String topic) {
    final list = state.value ?? [];
    return list.where((e) =>
      e.scope.type == 'topic' &&
      e.scope.topic?.toLowerCase() == topic.toLowerCase()
    ).toList();
  }

  bool hasCommentary(String book, int chapter, int? verse) {
    final list = state.value ?? [];
    return list.any((e) =>
      (e.scope.type == 'verse' && e.scope.book?.toLowerCase() == book.toLowerCase() && e.scope.chapter == chapter && e.scope.verse == verse) ||
      (e.scope.type == 'chapter' && e.scope.book?.toLowerCase() == book.toLowerCase() && e.scope.chapter == chapter) ||
      (e.scope.type == 'book' && e.scope.book?.toLowerCase() == book.toLowerCase())
    );
  }

  List<String> get versesWithCommentary {
    final list = state.value ?? [];
    final verses = <String>{};
    for (final e in list) {
      if (e.scope.type == 'verse' && e.scope.book != null && e.scope.chapter != null && e.scope.verse != null) {
        // Format exactly like standard references
        verses.add('${e.scope.book} ${e.scope.chapter}:${e.scope.verse}');
      }
    }
    final sorted = verses.toList()..sort();
    return sorted;
  }
}

final commentaryProvider = AsyncNotifierProvider<CommentaryNotifier, List<CommentaryEntry>>(
  CommentaryNotifier.new,
);

class CommentaryBookmarksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final prefs = ref.watch(preferencesProvider);
    return prefs.getCommentaryBookmarks().toSet();
  }

  void toggleBookmark(String book, int chapter, int? verse) {
    final key = '$book|$chapter|${verse ?? "all"}';
    final current = Set<String>.from(state);
    if (current.contains(key)) {
      current.remove(key);
    } else {
      current.add(key);
    }
    state = current;
    ref.read(preferencesProvider).saveCommentaryBookmarks(current.toList());
  }

  bool isBookmarked(String book, int chapter, int? verse) {
    final key = '$book|$chapter|${verse ?? "all"}';
    return state.contains(key);
  }
}

final commentaryBookmarksProvider = NotifierProvider<CommentaryBookmarksNotifier, Set<String>>(
  CommentaryBookmarksNotifier.new,
);
