import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChapterTitlesNotifier extends Notifier<Map<String, Map<String, String>>> {
  @override
  Map<String, Map<String, String>> build() {
    _loadTitles();
    return {};
  }

  Future<void> _loadTitles() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/chapter_titles.json');
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      
      final Map<String, Map<String, String>> result = {};
      for (final entry in decoded.entries) {
        final bookName = entry.key;
        final chapters = entry.value as Map<String, dynamic>;
        result[bookName] = chapters.map((k, v) => MapEntry(k, v.toString()));
      }
      state = result;
    } catch (e) {
      // Ignored
    }
  }

  String? getTitle(String bookName, int chapter) {
    if (state.isEmpty) return null;
    final bookData = state[bookName];
    if (bookData == null) return null;
    return bookData[chapter.toString()];
  }
}

final chapterTitlesProvider = NotifierProvider<ChapterTitlesNotifier, Map<String, Map<String, String>>>(ChapterTitlesNotifier.new);
