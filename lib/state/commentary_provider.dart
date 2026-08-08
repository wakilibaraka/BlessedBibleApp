
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/commentary_entry.dart';
import '../data/local_storage/preferences_service.dart';
import 'package:flutter/foundation.dart';
import '../utils/isolate_parsers.dart';

class CommentaryNotifier extends AsyncNotifier<List<CommentaryEntry>> {
  List<String> _cachedFormattedVerses = [];
  Set<String> _cachedVerses = {};
  Set<String> _cachedChapters = {};

  @override
  Future<List<CommentaryEntry>> build() async {
    return _loadCommentary();
  }

  Future<List<CommentaryEntry>> _loadCommentary() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/commentary/commentary.json');
      
      final entries = await compute(parseCommentaryJson, jsonString);

      final verses = <String>{};
      final vSet = <String>{};
      final cSet = <String>{};
      
      for (final e in entries) {
        final b = e.scope.book;
        final c = e.scope.chapter;
        final v = e.scope.verse;
        
        if (b != null && c != null) {
          if (e.scope.type == 'chapter') {
            cSet.add('$b|$c');
          }
          if (e.scope.type == 'verse' && v != null) {
            vSet.add('$b|$c|$v');
            verses.add('$b $c:$v');
          }
        }
      }
      
      _cachedChapters = cSet;
      _cachedVerses = vSet;
      _cachedFormattedVerses = verses.toList()..sort();
      
      return entries;
    } catch (e) {
      // If the file is missing or empty, do not crash; return empty list
      return [];
    }
  }

  Set<String> get versesWithCommentarySet => _cachedVerses;
  Set<String> get chaptersWithCommentarySet => _cachedChapters;

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

  List<String> get versesWithCommentary => _cachedFormattedVerses;
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

/// Returns true if ANY commentary entry exists for [book]/[chapter].
/// Widgets can call: ref.watch(commentaryForChapterProvider(('Hebrews', 12)))
final commentaryForChapterProvider =
    Provider.family<bool, (String, int)>((ref, args) {
  final (book, chapter) = args;
  final notifier = ref.watch(commentaryProvider.notifier);
  return notifier.hasCommentary(book, chapter, null);
});

/// Returns the set of books that have ANY commentary — used by Library.
final commentaryAvailableBooksProvider = Provider<Set<String>>((ref) {
  final list = ref.watch(commentaryProvider).value ?? [];
  return list
      .where((e) => e.scope.book != null)
      .map((e) => e.scope.book!)
      .toSet();
});
