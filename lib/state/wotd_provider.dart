import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import '../services/bible_database_service.dart';
import '../utils/log.dart';

class WordOfTheDay {
  final String word;
  final String snippet;

  /// Normalized headword used for dictionary lookups (the display word
  /// may carry casing/parentheses that won't match the DB key).
  final String normalized;
  WordOfTheDay(this.word, this.snippet, {String? normalized})
      : normalized = normalized ?? word.toLowerCase();

  Map<String, dynamic> toJson() => {
        'word': word,
        'snippet': snippet,
        'normalized': normalized,
      };

  factory WordOfTheDay.fromJson(Map<String, dynamic> json) => WordOfTheDay(
        json['word'] as String? ?? '',
        json['snippet'] as String? ?? '',
        normalized: json['normalized'] as String?,
      );
}

final wordForDateProvider =
    FutureProvider.family<WordOfTheDay?, DateTime>((ref, date) async {
  final dateKey =
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  PreferencesService? prefs;
  try {
    final p = ref.watch(preferencesProvider);
    prefs = p;
    final cached = p.getDailyCacheJson('wotd_$dateKey', dateKey);
    if (cached != null && (cached['word'] as String? ?? '').isNotEmpty) {
      return WordOfTheDay.fromJson(cached);
    }
  } catch (_) {
    // preferencesProvider may not be overridden in isolated unit tests.
  }

  // Deterministic random based on date
  final dayIndex = DateTime(date.year, date.month, date.day)
      .difference(DateTime(2026, 1, 1))
      .inDays;

  final random = Random(dayIndex);
  final pickIndex = random.nextInt(1000000);
  final picked =
      await bibleDbService.getDictionaryWordForSeed(dayIndex, pickIndex);
  if (picked == null || picked.displayHeadword.isEmpty) {
    logDebug('wordForDateProvider: dictionary is empty');
    return null;
  }

  // Get a clean snippet of the definition
  String snippet = picked.definition
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (snippet.length > 150) {
    snippet = '${snippet.substring(0, 150)}...';
  }

  final result = WordOfTheDay(
    picked.displayHeadword,
    snippet,
    normalized: picked.normalizedWord,
  );
  if (prefs != null) {
    unawaited(
        prefs.saveDailyCacheJson('wotd_$dateKey', dateKey, result.toJson()));
  }
  return result;
});

final wordOfTheDayProvider = FutureProvider<WordOfTheDay?>((ref) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return ref.watch(wordForDateProvider(today).future);
});

/// Last 7 days of words of the day (today down to 6 days ago).
final pastWordsOfTheDayProvider =
    FutureProvider<List<(DateTime, WordOfTheDay?)>>((ref) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dates = List.generate(7, (i) => today.subtract(Duration(days: i)));
  final results = <(DateTime, WordOfTheDay?)>[];
  for (final date in dates) {
    final wotd = await ref.watch(wordForDateProvider(date).future);
    results.add((date, wotd));
  }
  return results;
});
