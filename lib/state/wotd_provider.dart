import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dictionary_provider.dart';
import 'dictionary_search_provider.dart';

class WordOfTheDay {
  final String word;
  final String snippet;
  WordOfTheDay(this.word, this.snippet);
}

final wordOfTheDayProvider = FutureProvider<WordOfTheDay?>((ref) async {
  final allWords = await ref.watch(dictionaryIndexProvider.future);
  if (allWords.isEmpty) return null;
  
  // Deterministic random based on date
  final now = DateTime.now();
  final dayIndex = DateTime(now.year, now.month, now.day).difference(DateTime(2026, 1, 1)).inDays;
  
  final random = Random(dayIndex);
  final index = random.nextInt(allWords.length);
  final headword = allWords[index];
  
  final defs = await ref.watch(dictionaryDefinitionProvider(headword.normalizedWord).future);
  if (defs.isEmpty) return null;
  
  final def = defs.first;
  // Get a snippet of the definition
  String snippet = def.definition;
  if (snippet.length > 150) {
    snippet = '${snippet.substring(0, 150)}...';
  }
  
  return WordOfTheDay(def.displayHeadword, snippet);
});
