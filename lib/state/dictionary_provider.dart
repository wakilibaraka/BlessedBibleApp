import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'read_settings_provider.dart';
import '../data/models/bible_model.dart';
import '../services/bible_database_service.dart';

final dictionaryWordsProvider =
    FutureProvider<Map<String, String>>((ref) async {
  try {
    final jsonString =
        await rootBundle.loadString('assets/data/dictionary_words.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, value.toString()));
  } catch (e) {
    return {};
  }
});

/// Biblical proper names (derived from KJV mid-verse capitalization;
/// see tool/build_dictionary_tiers.py). Powers the "difficult + names"
/// scope. Empty on load failure -> names branch simply never matches.
final dictionaryNamesProvider = FutureProvider<Set<String>>((ref) async {
  try {
    final jsonString =
        await rootBundle.loadString('assets/data/dictionary_names.json');
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => e.toString()).toSet();
  } catch (e) {
    return {};
  }
});

/// Token -> normalized_word for contested words defined under another
/// headword (baptize -> baptism, kingdom -> kingdomofgod). Verified at
/// generation time so every underline stays resolvable.
final dictionaryAliasesProvider =
    FutureProvider<Map<String, String>>((ref) async {
  try {
    final jsonString =
        await rootBundle.loadString('assets/data/dictionary_aliases.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, value.toString()));
  } catch (e) {
    return {};
  }
});

class ChapterUnderlineArgs {
  final int bookNumber;
  final int chapterNumber;
  final List<BibleVerse> verses;
  final bool isEnglish;
  final String translationId;

  ChapterUnderlineArgs({
    required this.bookNumber,
    required this.chapterNumber,
    required this.verses,
    required this.isEnglish,
    required this.translationId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterUnderlineArgs &&
          runtimeType == other.runtimeType &&
          bookNumber == other.bookNumber &&
          chapterNumber == other.chapterNumber &&
          isEnglish == other.isEnglish &&
          translationId == other.translationId;

  @override
  int get hashCode =>
      bookNumber.hashCode ^
      chapterNumber.hashCode ^
      isEnglish.hashCode ^
      translationId.hashCode;
}

// Map of verseNumber -> Set of token indices.
//
// Tier contract (see tool/build_dictionary_tiers.py):
// - `term`: every dictionary headword (names, topics, easy nouns).
// - `tricky`: KJV false friends (conversation, prevent, suffer, ...).
// - `common`: genuinely archaic grammar (thou, hath, whence, ...).
// - `contested`: theologically disputed or misleading words
//   (hell, baptism, easter, ghost, lord, ...). Matches classic scopes
//   exactly as `term` did, so classic behavior is unchanged.
final chapterUnderlineMapProvider =
    Provider.family<Map<int, Set<int>>, ChapterUnderlineArgs>((ref, args) {
  if (!args.isEnglish) return {};

  final dictWordsAsync = ref.watch(dictionaryWordsProvider);
  final namesAsync = ref.watch(dictionaryNamesProvider);
  final scope =
      ref.watch(readSettingsProvider.select((s) => s.dictionaryScope));
  final nonKjvMode =
      ref.watch(readSettingsProvider.select((s) => s.nonKjvDictionaryMode));
  final isEnabled = ref
      .watch(readSettingsProvider.select((s) => s.dictionaryUnderlinesEnabled));

  if (!isEnabled ||
      dictWordsAsync.value == null ||
      namesAsync.value == null ||
      args.verses.isEmpty) {
    return {};
  }

  if (args.translationId != 'kjv') {
    // Other English versions (BBE, WEB, ...): BBE's Basic-English
    // vocabulary needs almost no archaic marking, and KJV false
    // friends (let, save, tell) would mislead there, so only
    // contested words mark by default. `followScope` restores the
    // KJV behavior for anyone who wants it.
    if (nonKjvMode == NonKjvDictionaryMode.off) return {};
    if (nonKjvMode == NonKjvDictionaryMode.contestedOnly) {
      return _markTiers(args.verses, dictWordsAsync.value!, {'contested'});
    }
  }

  final dictWords = dictWordsAsync.value!;
  final names = namesAsync.value!;
  final Map<int, Set<int>> resultMap = {};
  final Set<String> seenWords = {};

  final wordRegex = RegExp(r'[a-zA-Z]+');

  bool eligible(String word, String tier) {
    switch (scope) {
      case DictionaryScope.term:
        return tier == 'term' || tier == 'contested';
      case DictionaryScope.termAndTricky:
        return tier == 'term' || tier == 'tricky' || tier == 'contested';
      case DictionaryScope.everything:
        return true;
      case DictionaryScope.difficult:
        // Archaic + false friends + contested only. Easy nouns
        // (god, son, man, day, ...) are `term`-tier non-names, so they
        // never mark here.
        return tier == 'tricky' || tier == 'common' || tier == 'contested';
      case DictionaryScope.difficultAndNames:
        if (tier == 'tricky' || tier == 'common' || tier == 'contested') {
          return true;
        }
        // Proper names only — the names list is ratio-verified (true
        // names, not sentence-case commons), so no frequency gate needed.
        return tier == 'term' && names.contains(word);
    }
  }

  for (final v in args.verses) {
    final int verseNum = v.number;
    // Strip Strong's tags before matching so index aligns with read_screen.dart
    final String text = v.text.replaceAll(RegExp(r'\[[HG]\d+\]'), '');

    final matches = wordRegex.allMatches(text);
    int matchIndex = 0;

    for (final match in matches) {
      final word = match.group(0)!.toLowerCase();
      final tier = dictWords[word];

      if (tier != null) {
        if (eligible(word, tier) && !seenWords.contains(word)) {
          seenWords.add(word);
          resultMap.putIfAbsent(verseNum, () => {}).add(matchIndex);
        }
      }
      matchIndex++;
    }
  }

  return resultMap;
});

/// Shared first-per-chapter marking pass for a fixed tier set.
/// Keeps the non-KJV `contestedOnly` path consistent with the main pass
/// (same regex, same Strong's stripping, same dedupe).
Map<int, Set<int>> _markTiers(
    List<BibleVerse> verses, Map<String, String> dictWords, Set<String> tiers) {
  final Map<int, Set<int>> resultMap = {};
  final Set<String> seenWords = {};
  final wordRegex = RegExp(r'[a-zA-Z]+');

  for (final v in verses) {
    final String text = v.text.replaceAll(RegExp(r'\[[HG]\d+\]'), '');
    final matches = wordRegex.allMatches(text);
    int matchIndex = 0;
    for (final match in matches) {
      final word = match.group(0)!.toLowerCase();
      final tier = dictWords[word];
      if (tier != null && tiers.contains(tier) && !seenWords.contains(word)) {
        seenWords.add(word);
        resultMap.putIfAbsent(v.number, () => {}).add(matchIndex);
      }
      matchIndex++;
    }
  }
  return resultMap;
}

class DictionaryDefinition {
  final String normalizedWord;
  final String displayHeadword;
  final String source;
  final String definition;

  DictionaryDefinition({
    required this.normalizedWord,
    required this.displayHeadword,
    required this.source,
    required this.definition,
  });
}

final dictionaryDefinitionProvider =
    FutureProvider.family<List<DictionaryDefinition>, String>(
        (ref, word) async {
  // Contested words defined under another headword resolve through the
  // alias table first (baptize -> baptism, kingdom -> kingdomofgod).
  final aliases = await ref.watch(dictionaryAliasesProvider.future);
  final lookup = aliases[word] ?? word;
  final db = await bibleDbService.database;
  final results = await db.query(
    'dictionary',
    where: 'normalized_word = ?',
    whereArgs: [lookup],
  );

  return results
      .map((r) => DictionaryDefinition(
            normalizedWord: r['normalized_word'] as String,
            displayHeadword: r['display_headword'] as String,
            source: r['source'] as String,
            definition: r['definition'] as String,
          ))
      .toList();
});

class BookmarkedWordsNotifier extends AsyncNotifier<Set<String>> {
  static const _key = 'bookmarked_dictionary_words';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> toggleBookmark(String word) async {
    final currentSet = state.asData?.value ?? {};
    final newSet = Set<String>.from(currentSet);

    if (newSet.contains(word)) {
      newSet.remove(word);
    } else {
      newSet.add(word);
    }

    state = AsyncData(newSet);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newSet.toList());
  }
}

final bookmarkedWordsProvider =
    AsyncNotifierProvider<BookmarkedWordsNotifier, Set<String>>(
        BookmarkedWordsNotifier.new);
