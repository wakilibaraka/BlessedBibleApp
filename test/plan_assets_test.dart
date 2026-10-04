// Guardrails for bundled reading-plan content (Phase A).
//
// Every ref in every curated asset must resolve to real verses (bounds
// checked against word_counts.json), days must be sequential, and the two
// whole-canon plans must cover the entire canon with nothing missing.
// Pure Dart + File reads: hermetic, no platform channels.

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

const _bookAliases = {
  'jud': 'Jude',
  'joh': 'John',
  '2 joh': '2 John',
  '3 joh': '3 John',
  'psalm': 'Psalms',
  '1 thes': '1 Thessalonians',
  '2 thes': '2 Thessalonians',
  'song of songs': 'Song of Solomon',
};

final _refPattern = RegExp(
    r'^(.*?)\s+(\d+)(?::(\d+)(?:\s*[-–—]\s*(?:(\d+):)?(\d+))?|\s*[-–—]\s*(\d+)(?::(\d+))?)?$');

/// Canon bounds: book -> chapter -> sorted verse numbers.
Map<String, Map<int, List<int>>> loadCanon() {
  final jsonMap =
      jsonDecode(File('assets/data/word_counts.json').readAsStringSync())
          as Map<String, dynamic>;
  final canon = <String, Map<int, List<int>>>{};
  jsonMap.forEach((book, chapters) {
    final chMap = <int, List<int>>{};
    (chapters as Map<String, dynamic>).forEach((ch, info) {
      final verses = ((info as Map<String, dynamic>)['verses']
              as Map<String, dynamic>)
          .keys
          .map(int.parse)
          .toList()
        ..sort();
      chMap[int.parse(ch)] = verses;
    });
    canon[book] = chMap;
  });
  return canon;
}

List<String> wholeBook(
    Map<String, Map<int, List<int>>> canon, String book) {
  final out = <String>[];
  final chapters = canon[book]!.keys.toList()..sort();
  for (final ch in chapters) {
    for (final v in canon[book]![ch]!) {
      out.add('$book|$ch|$v');
    }
  }
  return out;
}

/// Expands one asset ref string to canon keys `Book|chapter|verse`.
/// Throws [FormatException] on anything unresolvable.
List<String> expandRef(
    Map<String, Map<int, List<int>>> canon, String ref) {
  final r = ref.trim();
  // Bare book name (with or without abbreviation): whole book.
  for (final name in canon.keys) {
    if (name.toLowerCase() == r.toLowerCase()) return wholeBook(canon, name);
  }
  if (_bookAliases.containsKey(r.toLowerCase())) {
    return wholeBook(canon, _bookAliases[r.toLowerCase()]!);
  }
  final m = _refPattern.firstMatch(r);
  if (m == null) throw FormatException('unparseable ref: $r');
  var book = m.group(1)!;
  if (!canon.containsKey(book)) {
    final alias = _bookAliases[book.toLowerCase()];
    if (alias == null) throw FormatException('unknown book: $book in $r');
    book = alias;
  }
  final chapters = canon[book]!;
  int c1 = int.parse(m.group(2)!);
  final v1s = m.group(3);
  final c2s = m.group(4);
  final v2s = m.group(5);
  final cendS = m.group(6);
  final vendS = m.group(7);
  if (v1s == null && cendS != null && chapters.length == 1) {
    // Single-chapter book: "Book A-B" is always verses A..B
    // ("Philemon 4-7", "Jude 1-25").
    final only = chapters.keys.single;
    final vs = chapters[only]!;
    final hi = int.parse(cendS!);
    if (c1 < 1 || hi > vs.last || c1 > hi) {
      throw FormatException('verse out of range: $r');
    }
    return [for (var v = c1; v <= hi; v++) '$book|$only|$v'];
  }
  if (!chapters.containsKey(c1)) {
    throw FormatException('bad chapter: $r');
  }
  List<String> chapterVerses(int ch, int lo, int hi) {
    final verses = chapters[ch]!;
    if (lo < verses.first || hi > verses.last) {
      throw FormatException('verse out of range: $r');
    }
    return [for (var v = lo; v <= hi; v++) '$book|$ch|$v'];
  }

  if (v1s == null && cendS == null) {
    // Whole chapter.
    final vs = chapters[c1]!;
    return [for (final v in vs) '$book|$c1|$v'];
  }
  if (v1s == null) {
    // Chapter range, optional end verse: C1-C2[:V2].
    final c2 = int.parse(cendS!);
    if (!chapters.containsKey(c2)) {
      throw FormatException('bad chapter: $r');
    }
    final out = <String>[];
    for (var ch = c1; ch <= c2; ch++) {
      final vs = chapters[ch]!;
      final hi = (ch == c2 && vendS != null)
          ? int.parse(vendS)
          : vs.last;
      out.addAll(chapterVerses(ch, 1, hi));
    }
    return out;
  }
  // Verse range, optionally crossing chapters: C1:V1[-C2:V2].
  final v1 = int.parse(v1s);
  final c2 = c2s == null ? c1 : int.parse(c2s);
  final v2 = v2s == null ? v1 : int.parse(v2s);
  if (!chapters.containsKey(c2)) {
    throw FormatException('bad chapter: $r');
  }
  final out = <String>[];
  for (var ch = c1; ch <= c2; ch++) {
    final vs = chapters[ch]!;
    final lo = ch == c1 ? v1 : vs.first;
    final hi = ch == c2 ? v2 : vs.last;
    out.addAll(chapterVerses(ch, lo, hi));
  }
  return out;
}

const _assets = [
  'chronological_1yr',
  'mccheyne_1yr',
  'horner_10_chapters',
  'esv_through_the_bible',
  'esv_everyday_in_word',
  'esv_gospels_and_epistles',
  'esv_psalms_and_wisdom',
  'esv_pentateuch_and_history',
  'esv_chronicles_and_prophets',
  'heartlight_ot_nt',
];

void main() {
  late Map<String, Map<int, List<int>>> canon;
  late Map<String, List<String>> assetVerses;

  setUpAll(() {
    canon = loadCanon();
    assetVerses = {};
    for (final id in _assets) {
      final decoded = jsonDecode(
              File('assets/reading_plans/$id.json').readAsStringSync())
          as Map<String, dynamic>;
      final readings = decoded['readings'] as List;
      // Sequential days starting at 1.
      for (var i = 0; i < readings.length; i++) {
        final day = readings[i] as Map<String, dynamic>;
        expect(day['day'], i + 1, reason: '$id day order');
        final passages = day['passages'] as List;
        expect(passages, isNotEmpty, reason: '$id day ${day['day']}');
        for (final p in passages) {
          final pm = p as Map<String, dynamic>;
          expect((pm['label'] as String).isNotEmpty, isTrue);
          expect((pm['refs'] as List).isNotEmpty, isTrue);
        }
      }
      // Expand every ref (throws on anything unresolvable).
      final verses = <String>[];
      for (final day in readings) {
        for (final p in (day as Map<String, dynamic>)['passages'] as List) {
          for (final r in (p as Map<String, dynamic>)['refs'] as List) {
            verses.addAll(expandRef(canon, r as String));
          }
        }
      }
      assetVerses[id] = verses;
    }
  });

  test('all curated refs resolve to real verses', () {
    // Proven by setUpAll completing without FormatException.
    for (final id in _assets) {
      expect(assetVerses[id]!.isNotEmpty, isTrue, reason: id);
    }
  });

  test('chronological covers the whole canon with nothing missing', () {
    final canonKeys = <String>{};
    canon.forEach((book, chapters) {
      chapters.forEach((ch, verses) {
        for (final v in verses) {
          canonKeys.add('$book|$ch|$v');
        }
      });
    });
    final seen = assetVerses['chronological_1yr']!.toSet();
    expect(seen.difference(canonKeys), isEmpty);
    expect(canonKeys.difference(seen), isEmpty);
  });

  test('through-the-bible covers the whole canon exactly once', () {
    final canonKeys = <String>{};
    canon.forEach((book, chapters) {
      chapters.forEach((ch, verses) {
        for (final v in verses) {
          canonKeys.add('$book|$ch|$v');
        }
      });
    });
    final verses = assetVerses['esv_through_the_bible']!;
    expect(verses.length, canonKeys.length);
    expect(verses.toSet().difference(canonKeys), isEmpty);
    expect(canonKeys.difference(verses.toSet()), isEmpty);
  });
}
