import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/commentary_entry.dart';
import '../data/local_storage/preferences_service.dart';

// Parse JSON completely in the background to prevent main thread blocking
List<CommentaryEntry> _parseCommentaryJson(Uint8List bytes) {
  try {
    final jsonString = utf8.decode(bytes);
    final decoded = jsonDecode(jsonString);

    List<dynamic> entriesList;
    if (decoded is Map<String, dynamic> && decoded.containsKey('entries')) {
      entriesList = decoded['entries'] as List<dynamic>;
    } else if (decoded is List) {
      entriesList = decoded;
    } else {
      return [];
    }

    return entriesList
        .map((e) => CommentaryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

class CommentaryBook {
  final String title;
  final String author;
  final String id;
  final bool isComingSoon;

  const CommentaryBook({
    required this.title,
    required this.author,
    required this.id,
    this.isComingSoon = false,
  });
}

const List<CommentaryBook> kAvailableCommentaries = [
  CommentaryBook(
    title: 'Daniel and the Revelation',
    author: 'Uriah Smith',
    id: 'daniel_revelation',
  ),
  CommentaryBook(
    title: 'The Epistle to the Hebrews',
    author: 'M.L. Andreasen',
    id: 'hebrews',
  ),
  CommentaryBook(
    title: 'The Glad Tidings',
    author: 'E.J. Waggoner',
    id: 'glad_tidings',
    isComingSoon: true,
  ),
  CommentaryBook(
    title: 'The Cross and Its Shadow',
    author: 'S.N. Haskell',
    id: 'cross_shadow',
    isComingSoon: true,
  ),
  CommentaryBook(
    title: 'The Three Angels\' Messages',
    author: 'J.N. Andrews',
    id: 'three_angels',
    isComingSoon: true,
  ),
];

class CommentaryNotifier extends AsyncNotifier<List<CommentaryEntry>> {
  @override
  Future<List<CommentaryEntry>> build() async {
    return _loadCommentary();
  }

  Future<List<CommentaryEntry>> _loadCommentary() async {
    try {
      final byteData =
          await rootBundle.load('assets/commentary/commentary.json');
      return await compute(
          _parseCommentaryJson, byteData.buffer.asUint8List());
    } catch (e) {
      // If the file is missing or empty, do not crash; return empty list
      return [];
    }
  }

  List<CommentaryEntry> commentaryForVerse(
      String book, int chapter, int verse) {
    final list = state.value ?? [];
    return list
        .where((e) =>
            e.scope.type == 'verse' &&
            e.scope.book?.toLowerCase() == book.toLowerCase() &&
            e.scope.chapter == chapter &&
            e.scope.verse == verse)
        .toList();
  }

  List<CommentaryEntry> commentaryForChapterVerses(String book, int chapter) {
    final list = state.value ?? [];
    final entries = list
        .where((e) =>
            e.scope.type == 'verse' &&
            e.scope.book?.toLowerCase() == book.toLowerCase() &&
            e.scope.chapter == chapter)
        .toList();
    entries.sort((a, b) => (a.scope.verse ?? 0).compareTo(b.scope.verse ?? 0));
    return entries;
  }

  List<CommentaryEntry> commentaryForChapter(String book, int chapter) {
    final list = state.value ?? [];
    return list
        .where((e) =>
            e.scope.type == 'chapter' &&
            e.scope.book?.toLowerCase() == book.toLowerCase() &&
            e.scope.chapter == chapter)
        .toList();
  }

  List<CommentaryEntry> commentaryForBook(String book) {
    final list = state.value ?? [];
    return list
        .where((e) =>
            e.scope.type == 'book' &&
            e.scope.book?.toLowerCase() == book.toLowerCase())
        .toList();
  }

  List<CommentaryEntry> commentaryForTopic(String topic) {
    final list = state.value ?? [];
    return list
        .where((e) =>
            e.scope.type == 'topic' &&
            e.scope.topic?.toLowerCase() == topic.toLowerCase())
        .toList();
  }

  bool hasCommentary(String book, int chapter, int? verse) {
    final list = state.value ?? [];
    return list.any((e) =>
        (e.scope.type == 'verse' &&
            e.scope.book?.toLowerCase() == book.toLowerCase() &&
            e.scope.chapter == chapter &&
            e.scope.verse == verse) ||
        (e.scope.type == 'chapter' &&
            e.scope.book?.toLowerCase() == book.toLowerCase() &&
            e.scope.chapter == chapter) ||
        (e.scope.type == 'book' &&
            e.scope.book?.toLowerCase() == book.toLowerCase()));
  }

  List<String>? _versesCache;

  List<String> get versesWithCommentary {
    if (_versesCache != null) return _versesCache!;
    
    final list = state.value ?? [];
    final verses = <String>{};
    for (final e in list) {
      if (e.scope.type == 'verse' &&
          e.scope.book != null &&
          e.scope.chapter != null &&
          e.scope.verse != null) {
        // Format exactly like standard references
        verses.add('${e.scope.book} ${e.scope.chapter}:${e.scope.verse}');
      }
    }
    _versesCache = verses.toList()..sort();
    return _versesCache!;
  }
}

final commentaryProvider =
    AsyncNotifierProvider<CommentaryNotifier, List<CommentaryEntry>>(
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

final commentaryBookmarksProvider =
    NotifierProvider<CommentaryBookmarksNotifier, Set<String>>(
  CommentaryBookmarksNotifier.new,
);
