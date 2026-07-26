import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import '../data/models/commentary_model.dart';
import '../utils/isolate_parsers.dart';
import 'egw_provider.dart';

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
  ];

  Map<String, Map<String, Map<String, List<CommentaryEntry>>>> result = {};

  for (final path in assetPaths) {
    try {
      final jsonString = await rootBundle.loadString(path);
      // Decode + parse on a background isolate — never blocks the UI thread
      final parsed = await compute(parseCommentaryJson, jsonString);

      // Merge parsed result into combined map
      for (final book in parsed.keys) {
        result.putIfAbsent(book, () => {});
        for (final chapter in parsed[book]!.keys) {
          result[book]!.putIfAbsent(chapter, () => {});
          for (final verse in parsed[book]![chapter]!.keys) {
            result[book]![chapter]!.putIfAbsent(verse, () => []);
            result[book]![chapter]![verse]!.addAll(parsed[book]![chapter]![verse]!);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading commentary file $path: $e');
    }
  }
  
  return result;
});

class CombinedCommentaryState {
  final Map<String, Map<String, Map<String, List<CommentaryEntry>>>> data;
  final bool isEgwMissing;
  CombinedCommentaryState({required this.data, required this.isEgwMissing});
}

final combinedCommentaryProvider = FutureProvider<CombinedCommentaryState>((ref) async {
  final uriahData = await ref.watch(commentaryDataProvider.future);
  final egwData = await ref.watch(egwCommentaryProvider.future);
  
  bool isEgwMissing = egwData.isEmpty;
  
  Map<String, Map<String, Map<String, List<CommentaryEntry>>>> combined = {};
  
  void merge(Map<String, Map<String, Map<String, List<CommentaryEntry>>>> source) {
    for (var book in source.keys) {
      combined.putIfAbsent(book, () => {});
      for (var chapter in source[book]!.keys) {
        combined[book]!.putIfAbsent(chapter, () => {});
        for (var verse in source[book]![chapter]!.keys) {
          combined[book]![chapter]!.putIfAbsent(verse, () => []);
          combined[book]![chapter]![verse]!.addAll(source[book]![chapter]![verse]!);
        }
      }
    }
  }
  
  merge(uriahData);
  merge(egwData);
  
  return CombinedCommentaryState(data: combined, isEgwMissing: isEgwMissing);
});
