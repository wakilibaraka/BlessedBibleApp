// PlanSpec conversion tests (Phase B): curated assets convert to the
// single plan model and back without changing a byte of meaning.
// Hermetic File reads; no platform channels.

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/plan_spec.dart';

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
  'topical_prayer_21',
  'topical_faith_21',
  'topical_praise_14',
  'topical_covenant_7',
];

/// Order-insensitive deep equality for decoded JSON.
bool deepEquals(dynamic a, dynamic b) {
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || !deepEquals(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

CanonIndex loadCanon() {
  final jsonMap =
      jsonDecode(File('assets/data/word_counts.json').readAsStringSync())
          as Map<String, dynamic>;
  final canon = <String, Map<int, List<int>>>{};
  jsonMap.forEach((book, chapters) {
    final chMap = <int, List<int>>{};
    (chapters as Map<String, dynamic>).forEach((ch, info) {
      chMap[int.parse(ch)] =
          ((info as Map<String, dynamic>)['verses'] as Map<String, dynamic>)
              .keys
              .map(int.parse)
              .toList();
    });
    canon[book] = chMap;
  });
  return canon;
}

void main() {
  late CanonIndex canon;

  setUpAll(() {
    canon = loadCanon();
  });

  group('PlanRefSpec.parse', () {
    test('single verse, whole chapter, same-chapter range', () {
      var r = PlanRefSpec.parse('John 3:16', canon);
      expect((r.book, r.startChapter, r.startVerse, r.endChapter, r.endVerse),
          ('John', 3, 16, 3, 16));
      r = PlanRefSpec.parse('Genesis 1', canon);
      expect((r.startChapter, r.startVerse, r.endChapter, r.endVerse),
          (1, 1, 1, 31));
      r = PlanRefSpec.parse('Psalm 23:1-3', canon);
      expect(r.book, 'Psalms');
      expect((r.startVerse, r.endVerse), (1, 3));
    });

    test('cross-chapter, chapter ranges, bare books, aliases', () {
      var r = PlanRefSpec.parse('Genesis 1:1-3:24', canon);
      expect((r.startChapter, r.startVerse, r.endChapter, r.endVerse),
          (1, 1, 3, 24));
      r = PlanRefSpec.parse('1 Chronicles 1-2', canon);
      expect((r.startChapter, r.endChapter), (1, 2));
      r = PlanRefSpec.parse('Jude', canon);
      expect((r.book, r.startVerse, r.endVerse), ('Jude', 1, 25));
      r = PlanRefSpec.parse('Philemon 4-7', canon);
      expect((r.startVerse, r.endVerse), (4, 7));
      r = PlanRefSpec.parse('2 Joh', canon);
      expect(r.book, '2 John');
    });

    test('garbage throws', () {
      expect(() => PlanRefSpec.parse('Narnia 1', canon),
          throwsA(isA<FormatException>()));
      expect(() => PlanRefSpec.parse('Genesis 51', canon),
          throwsA(isA<FormatException>()));
      expect(() => PlanRefSpec.parse('3 John 1-15', canon),
          throwsA(isA<FormatException>()));
    });
  });

  group('curated asset round-trip', () {
    test('all assets convert and reproduce exactly', () {
      for (final id in _assets) {
        final source =
            jsonDecode(File('assets/reading_plans/$id.json').readAsStringSync())
                as Map<String, dynamic>;
        final spec = PlanSpec.fromCuratedJson(source, canon: canon);
        expect(spec.id, id);
        expect(spec.days.length, (source['readings'] as List).length);
        expect(spec.tracks.isNotEmpty, isTrue);
        expect(spec.cadenceDays, (source['readings'] as List).length);
        expect(spec.sourceDigest, isNotNull);
        final roundTripped = spec.toCuratedJson();
        expect(deepEquals(roundTripped, source), isTrue,
            reason: '$id round-trip differs');
      }
    });

    test('spec carries structure the scheduler can use', () {
      final source = jsonDecode(
              File('assets/reading_plans/mccheyne_1yr.json').readAsStringSync())
          as Map<String, dynamic>;
      final spec = PlanSpec.fromCuratedJson(source, canon: canon);
      // M'Cheyne reads 4 passages a day -> 4 parallel tracks.
      expect(spec.tracks.length, 4);
      final totalRefs = spec.days.fold<int>(0, (n, d) => n + d.passages.length);
      final trackRefs = spec.tracks.fold<int>(0, (n, t) => n + t.ranges.length);
      expect(trackRefs, totalRefs);
      // Every ref has parsed bounds.
      for (final t in spec.tracks) {
        for (final r in t.ranges) {
          expect(r.book.isNotEmpty, isTrue);
          expect(r.endChapter, greaterThanOrEqualTo(r.startChapter));
        }
      }
    });
  });
}
