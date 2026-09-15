import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'read_settings_provider.dart';
import '../data/models/bible_model.dart';
import '../services/bible_database_service.dart';

final dictionaryWordsProvider = FutureProvider<Map<String, String>>((ref) async {
  try {
    final jsonString = await rootBundle.loadString('assets/data/dictionary_words.json');
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

  ChapterUnderlineArgs({
    required this.bookNumber, 
    required this.chapterNumber, 
    required this.verses,
    required this.isEnglish,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterUnderlineArgs &&
          runtimeType == other.runtimeType &&
          bookNumber == other.bookNumber &&
          chapterNumber == other.chapterNumber &&
          isEnglish == other.isEnglish;

  @override
  int get hashCode => bookNumber.hashCode ^ chapterNumber.hashCode ^ isEnglish.hashCode;
}

// Map of verseNumber -> Set of token indices
final chapterUnderlineMapProvider = Provider.family<Map<int, Set<int>>, ChapterUnderlineArgs>((ref, args) {
  if (!args.isEnglish) return {};
  
  final dictWordsAsync = ref.watch(dictionaryWordsProvider);
  final scope = ref.watch(readSettingsProvider.select((s) => s.dictionaryScope));
  final isEnabled = ref.watch(readSettingsProvider.select((s) => s.dictionaryUnderlinesEnabled));

  if (!isEnabled || dictWordsAsync.value == null || args.verses.isEmpty) {
    return {};
  }

  final dictWords = dictWordsAsync.value!;
  final Map<int, Set<int>> resultMap = {};
  final Set<String> seenWords = {};

  final wordRegex = RegExp(r'[a-zA-Z]+');

  for (final v in args.verses) {
    final int verseNum = v.number;
    final String text = v.text;
    
    // We match over plain text (no tags) so indices align with splitMapJoin later
    // Actually, if we use wordRegex.allMatches on the original text with tags stripped,
    // how does that align with `splitMapJoin` during rendering?
    // If we split by `[a-zA-Z]+` on the RAW text (with `‹` and `›`), the token index will still match!
    // Why? Because punctuation doesn't change the number of words. 
    // Wait! `splitMapJoin` on the raw text WILL include `‹` and `›` as non-matches.
    // Yes, the number of matches of `[a-zA-Z]+` is identical whether punctuation is there or not!
    // So we can just use `wordRegex.allMatches(text)` on the raw text.
    
    final matches = wordRegex.allMatches(text);
    int matchIndex = 0;
    
    for (final match in matches) {
      final word = match.group(0)!.toLowerCase();
      final tier = dictWords[word];
      
      if (tier != null) {
        bool eligible = false;
        if (scope == DictionaryScope.term && tier == 'term') {
          eligible = true;
        } else if (scope == DictionaryScope.termAndTricky && (tier == 'term' || tier == 'tricky')) {
          eligible = true;
        } else if (scope == DictionaryScope.everything) {
          eligible = true;
        }

        if (eligible && !seenWords.contains(word)) {
          seenWords.add(word);
          resultMap.putIfAbsent(verseNum, () => {}).add(matchIndex);
        }
      }
      matchIndex++;
    }
  }
  
  return resultMap;
});

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

final dictionaryDefinitionProvider = FutureProvider.family<List<DictionaryDefinition>, String>((ref, word) async {
  final db = await bibleDbService.database;
  final results = await db.query(
    'dictionary',
    where: 'normalized_word = ?',
    whereArgs: [word],
  );
  
  return results.map((r) => DictionaryDefinition(
    normalizedWord: r['normalized_word'] as String,
    displayHeadword: r['display_headword'] as String,
    source: r['source'] as String,
    definition: r['definition'] as String,
  )).toList();
});
