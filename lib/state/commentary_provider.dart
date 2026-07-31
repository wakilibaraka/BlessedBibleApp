import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/commentary_entry.dart';

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
}

final commentaryProvider = AsyncNotifierProvider<CommentaryNotifier, List<CommentaryEntry>>(
  CommentaryNotifier.new,
);
