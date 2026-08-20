import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeadingOverride {
  final String book;
  final int chapter;
  final String chapterTitle;
  final String pericopeTitle;
  final String decision;
  final String mergedText;

  HeadingOverride({
    required this.book,
    required this.chapter,
    required this.chapterTitle,
    required this.pericopeTitle,
    required this.decision,
    required this.mergedText,
  });

  factory HeadingOverride.fromJson(Map<String, dynamic> json) {
    return HeadingOverride(
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      chapterTitle: json['chapter_title'] as String? ?? '',
      pericopeTitle: json['pericope_title'] as String? ?? '',
      decision: json['decision'] as String,
      mergedText: json['merged_text'] as String? ?? '',
    );
  }
}

Map<String, HeadingOverride> _parseOverrides(String jsonString) {
  final List<dynamic> data = jsonDecode(jsonString);
  final map = <String, HeadingOverride>{};
  for (final item in data) {
    final entry = HeadingOverride.fromJson(item as Map<String, dynamic>);
    final key = '${entry.book}_${entry.chapter}';
    map[key] = entry;
  }
  return map;
}

class HeadingOverridesNotifier extends Notifier<Map<String, HeadingOverride>> {
  @override
  Map<String, HeadingOverride> build() {
    _loadData();
    return {};
  }

  Future<void> _loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/heading_overrides.json');
      final data = await compute(_parseOverrides, jsonString);
      state = data;
    } catch (e) {
      debugPrint('Failed to load heading overrides: $e');
    }
  }

  HeadingOverride? getOverrideForChapter(String book, int chapter) {
    return state['${book}_$chapter'];
  }
}

final headingOverridesProvider = NotifierProvider<HeadingOverridesNotifier, Map<String, HeadingOverride>>(
  HeadingOverridesNotifier.new,
);
