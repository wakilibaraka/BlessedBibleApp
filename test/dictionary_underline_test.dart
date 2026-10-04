// Dictionary underline rules: classic scopes keep their exact behavior
// (contested words match as terms did), difficult scopes mark only
// archaic/false-friend/contested (+ names), and non-KJV English
// versions default to contested-only.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/data/models/bible_model.dart';
import 'package:the_blessed_bible/state/dictionary_provider.dart';
import 'package:the_blessed_bible/state/read_settings_provider.dart';

const _testWords = {
  'god': 'term',
  'jesus': 'term',
  'david': 'term',
  'lord': 'contested',
  'prevent': 'tricky',
  'thou': 'common',
  'baptize': 'contested',
};
const _testNames = {'jesus', 'david'};

List<BibleVerse> get _verses => [
      BibleVerse(
          number: 1,
          text: 'In the beginning God created, saith Jesus unto David'),
      BibleVerse(
          number: 2, text: 'Thou shalt not prevent the Lord of hosts'),
    ];

Future<ProviderContainer> makeContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      dictionaryWordsProvider.overrideWith((ref) async => _testWords),
      dictionaryNamesProvider.overrideWith((ref) async => _testNames),
    ],
  );
  // The underline map reads .value synchronously: resolve first.
  await container.read(dictionaryWordsProvider.future);
  await container.read(dictionaryNamesProvider.future);
  return container;
}

ChapterUnderlineArgs argsFor(String translationId) =>
    ChapterUnderlineArgs(
      bookNumber: 1,
      chapterNumber: 1,
      verses: _verses,
      isEnglish: true,
      translationId: translationId,
    );

/// Verse -> set of underlined word strings (decoded from token indices).
Map<int, Set<String>> markedWords(
    ProviderContainer c, ChapterUnderlineArgs args) {
  final map = c.read(chapterUnderlineMapProvider(args));
  final out = <int, Set<String>>{};
  for (final v in args.verses) {
    final tokens = RegExp(r'[a-zA-Z]+')
        .allMatches(v.text)
        .map((m) => m.group(0)!.toLowerCase())
        .toList();
    final idx = map[v.number] ?? {};
    out[v.number] = {for (final i in idx) tokens[i]};
  }
  return out;
}

void main() {
  // Asset-bundle reads need a binding in plain unit tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('classic termAndTricky: terms + tricky + contested-as-term',
      () async {
    final c = await makeContainer();
    addTearDown(c.dispose);

    final marked = markedWords(c, argsFor('kjv'));
    // god (term), prevent (tricky), lord (contested, matched as term).
    expect(marked[1], containsAll(['god', 'jesus']));
    expect(marked[2], containsAll(['prevent', 'lord']));
    // Archaic commons were never in this scope.
    expect(marked[2], isNot(contains('thou')));
  });

  test('difficult: archaic + tricky + contested, never easy terms',
      () async {
    final c = await makeContainer();
    addTearDown(c.dispose);
    await c
        .read(readSettingsProvider.notifier)
        .setDictionaryScope(DictionaryScope.difficult);

    final marked = markedWords(c, argsFor('kjv'));
    // Verse 1 holds only easy terms: nothing marks.
    expect(marked[1], isEmpty);
    expect(marked[2], containsAll(['thou', 'prevent', 'lord']));
  });

  test('difficultAndNames adds proper names, still skips easy nouns',
      () async {
    final c = await makeContainer();
    addTearDown(c.dispose);
    await c
        .read(readSettingsProvider.notifier)
        .setDictionaryScope(DictionaryScope.difficultAndNames);

    final marked = markedWords(c, argsFor('kjv'));
    expect(marked[1], containsAll(['jesus', 'david']));
    expect(marked[1], isNot(contains('god')));
  });

  test('non-KJV defaults to contested-only (BBE near-zero)', () async {
    final c = await makeContainer();
    addTearDown(c.dispose);

    final marked = markedWords(c, argsFor('bbe'));
    expect(marked[1], isEmpty);
    expect(marked[2], contains('lord'));
    expect(marked[2], isNot(contains('prevent')));
    expect(marked[2], isNot(contains('thou')));
  });

  test('non-KJV followScope restores full behavior', () async {
    final c = await makeContainer();
    addTearDown(c.dispose);
    await c
        .read(readSettingsProvider.notifier)
        .setNonKjvDictionaryMode(NonKjvDictionaryMode.followScope);

    final marked = markedWords(c, argsFor('bbe'));
    expect(marked[1], containsAll(['god', 'jesus']));
  });

  test('non-KJV off marks nothing', () async {
    final c = await makeContainer();
    addTearDown(c.dispose);
    await c
        .read(readSettingsProvider.notifier)
        .setNonKjvDictionaryMode(NonKjvDictionaryMode.off);

    expect(c.read(chapterUnderlineMapProvider(argsFor('bbe'))), isEmpty);
  });

  test('shipped assets: contested tiers, names, aliases resolve',
      () async {
    final wordsJson =
        json.decode(await rootBundle.loadString('assets/data/dictionary_words.json'))
            as Map<String, dynamic>;
    for (final w in [
      'hell', 'baptism', 'easter', 'ghost', 'lord', 'baptize', 'kingdom'
    ]) {
      expect(wordsJson[w], 'contested', reason: w);
    }
    // Easy nouns stay plain terms (never marked by difficult scopes).
    for (final w in ['god', 'son', 'man', 'day']) {
      expect(wordsJson[w], 'term', reason: w);
    }
    final names = (json.decode(await rootBundle
            .loadString('assets/data/dictionary_names.json')) as List)
        .cast<String>();
    expect(names, containsAll(['jesus', 'david', 'moses', 'jerusalem']));
    expect(names, isNot(contains('god')));
    expect(names, isNot(contains('brother')));
    final aliases = json.decode(await rootBundle
        .loadString('assets/data/dictionary_aliases.json')) as Map<String, dynamic>;
    expect(aliases, {
      'baptize': 'baptism',
      'gentile': 'gentiles',
      'kingdom': 'kingdomofgod',
      'seraph': 'seraphim',
    });
  });
}
