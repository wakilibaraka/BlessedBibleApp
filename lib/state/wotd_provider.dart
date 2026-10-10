import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dictionary_provider.dart';
import 'dictionary_search_provider.dart';
import '../data/content_fallbacks.dart';

class WordOfTheDay {
  final String word;
  final String snippet;

  /// Normalized headword used for dictionary lookups (the display word
  /// may carry casing/parentheses that won't match the DB key).
  final String normalized;
  WordOfTheDay(this.word, this.snippet, {String? normalized})
      : normalized = normalized ?? word.toLowerCase();
}

/// Deterministic per-day index shared by the live and fallback pickers.
int _wotdDayIndex() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day)
      .difference(DateTime(2026, 1, 1))
      .inDays;
}

/// Compile-time Word of the Day (real bundled dictionary text). Used when
/// the dictionary cannot be read, so the Home card is never blank.
WordOfTheDay fallbackWordOfTheDay() {
  final i = _wotdDayIndex().abs() % kFallbackWotdPool.length;
  return kFallbackWotdPool[i];
}

/// Never null, never empty: resolves to today's dictionary word, or to the
/// compiled-in fallback if the dictionary is unreadable or empty.
final wordOfTheDayProvider = FutureProvider<WordOfTheDay>((ref) async {
  try {
    final allWords = await ref.watch(dictionaryIndexProvider.future);
    if (allWords.isEmpty) {
      debugPrint('wordOfTheDayProvider: dictionary index is empty');
      return fallbackWordOfTheDay();
    }

    // Deterministic random based on date. Try a few picks so one headword
    // with a missing/blank definition can't blank the card.
    final random = Random(_wotdDayIndex());
    for (var attempt = 0; attempt < 5; attempt++) {
      final headword = allWords[random.nextInt(allWords.length)];
      final defs = await ref
          .watch(dictionaryDefinitionProvider(headword.normalizedWord).future);
      final def = defs.firstWhereOrNull((d) => d.definition.trim().isNotEmpty);
      if (def == null) {
        debugPrint(
            'wordOfTheDayProvider: no definition for "${headword.normalizedWord}"');
        continue;
      }
      var snippet = def.definition.trim();
      if (snippet.length > 150) {
        snippet = '${snippet.substring(0, 150)}...';
      }
      return WordOfTheDay(def.displayHeadword, snippet,
          normalized: headword.normalizedWord);
    }
    return fallbackWordOfTheDay();
  } catch (e) {
    debugPrint('wordOfTheDayProvider: falling back after error: $e');
    return fallbackWordOfTheDay();
  }
});
