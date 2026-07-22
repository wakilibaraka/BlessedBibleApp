import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../data/models/commentary_model.dart';

class ActiveStudyVerseNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setVerse(String? verse) {
    state = verse;
  }
}

final activeStudyVerseProvider = NotifierProvider<ActiveStudyVerseNotifier, String?>(ActiveStudyVerseNotifier.new);

final commentaryDataProvider = FutureProvider<Map<String, Map<String, Map<String, List<CommentaryEntry>>>>>((ref) async {
  final assetPaths = [
    'assets/data/uriah_smith_daniel.json',
    'assets/data/uriah_smith_revelation.json',
    'assets/data/egw_genesis.json',
  ];

  Map<String, Map<String, Map<String, List<CommentaryEntry>>>> result = {};

  for (final path in assetPaths) {
    try {
      final jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      for (var bookKey in jsonData.keys) {
        result.putIfAbsent(bookKey, () => {});
        final chapters = jsonData[bookKey] as Map<String, dynamic>;
        
        for (var chapterKey in chapters.keys) {
          result[bookKey]!.putIfAbsent(chapterKey, () => {});
          final verses = chapters[chapterKey] as Map<String, dynamic>;
          
          for (var verseKey in verses.keys) {
            final entriesData = verses[verseKey] as List<dynamic>;
            final entries = entriesData.map((e) => CommentaryEntry.fromJson(e as Map<String, dynamic>)).toList();
            
            result[bookKey]![chapterKey]!.putIfAbsent(verseKey, () => []);
            result[bookKey]![chapterKey]![verseKey]!.addAll(entries);
          }
        }
      }
    } catch (e) {
      print('Error loading commentary file $path: $e');
    }
  }
  
  return result;
});
