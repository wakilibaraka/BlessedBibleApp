// Typo-tolerant search fallback (Phase 4): a misspelled token finds
// nothing without fuzzy matching, and finds the right verse with it.
// Minimal hand-built index: hermetic, no platform channels.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/state/search_engine.dart';

SearchEngine testEngine() {
  final corpus = [
    SearchItem(
      id: 0,
      type: SearchResultType.bible,
      title: 'John 3:16',
      subtitle: 'Bible Verse',
      text: 'For God so loved the world',
      metadata: const {'isOt': false},
    ),
    SearchItem(
      id: 1,
      type: SearchResultType.bible,
      title: 'Psalm 23:1',
      subtitle: 'Bible Verse',
      text: 'The Lord is my shepherd',
      metadata: const {'isOt': true},
    ),
  ];
  final index = <String, List<int>>{
    'for': [0],
    'god': [0],
    'so': [0],
    'loved': [0],
    'the': [0, 1],
    'world': [0],
    'lord': [1],
    'is': [1],
    'my': [1],
    'shepherd': [1],
    'john': [0],
    'psalm': [1],
  };
  return SearchEngine(
    baseIndexFuture:
        Future.value(IndexData(corpus, index)),
  );
}

void main() {
  test('typo finds nothing without fuzzy matching', () async {
    final engine = testEngine();
    final results = await engine.search('jhon', fuzzyMatch: false);
    expect(results, isEmpty);
  });

  test('typo finds the verse with fuzzy matching', () async {
    final engine = testEngine();
    final results = await engine.search('jhon', fuzzyMatch: true);
    expect(results, isNotEmpty);
    expect(
        results.any((r) => r.title.contains('John 3:16')), isTrue);
  });

  test('exact queries are unaffected by the fuzzy flag', () async {
    final engine = testEngine();
    final plain =
        await engine.search('shepherd', fuzzyMatch: false);
    final fuzzy =
        await engine.search('shepherd', fuzzyMatch: true);
    expect(plain.map((r) => r.title),
        containsAll(fuzzy.map((r) => r.title)));
  });
}
