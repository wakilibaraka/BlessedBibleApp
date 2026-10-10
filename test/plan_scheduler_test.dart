// Scheduler property tests (Phase A guardrails): exact coverage, no
// empty days, determinism, N=1, clamping, and multi-track disjointness.
// Hermetic File reads, same setup shape as plan_generator_test.dart.

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/pericope_entry.dart';
import 'package:the_blessed_bible/models/reading_plan.dart';
import 'package:the_blessed_bible/services/plan_generator.dart';
import 'package:the_blessed_bible/services/word_count_service.dart';

/// Expands one track range to canon keys `Book|chapter|verse`.
Set<String> expandRange(
  Map<String, Map<int, List<int>>> canon,
  PlanRange range,
) {
  final out = <String>{};
  final chapters = canon[range.book]!;
  for (var ch = range.startChapter; ch <= range.endChapter; ch++) {
    final verses = chapters[ch]!;
    final lo = ch == range.startChapter ? range.startVerse : verses.first;
    final hi = ch == range.endChapter ? range.endVerse : verses.last;
    for (var v = lo; v <= hi; v++) {
      out.add('${range.book}|$ch|$v');
    }
  }
  return out;
}

/// Union of all portion verses in a plan, via canon bounds lookup.
Set<String> unionOf(
  Map<String, Map<int, List<int>>> canon,
  ReadingPlan plan,
) {
  final out = <String>{};
  for (final day in plan.schedule) {
    for (final p in day.portions) {
      final chapters = canon[p.book]!;
      for (var ch = p.startChapter; ch <= p.endChapter; ch++) {
        final verses = chapters[ch]!;
        final lo = ch == p.startChapter ? p.startVerse : verses.first;
        final hi = ch == p.endChapter ? p.endVerse : verses.last;
        for (var v = lo; v <= hi; v++) {
          out.add('${p.book}|$ch|$v');
        }
      }
    }
  }
  return out;
}

void main() {
  late WordCountService wordCountService;
  late List<PericopeEntry> allPericopes;
  late PlanGenerator generator;
  late Map<String, Map<int, List<int>>> canon;

  setUpAll(() async {
    final wcJson = File('assets/data/word_counts.json').readAsStringSync();
    wordCountService = WordCountService();
    await wordCountService.initFromJson(wcJson);

    final pList =
        jsonDecode(File('assets/data/pericopes.json').readAsStringSync())
            as List;
    allPericopes = pList.map((j) => PericopeEntry.fromJson(j)).toList();

    generator = PlanGenerator(
      wordCountService: wordCountService,
      allPericopes: allPericopes,
    );

    canon = {};
    final wcMap = jsonDecode(wcJson) as Map<String, dynamic>;
    wcMap.forEach((book, chapters) {
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
  });

  PlanRange genesis() => PlanRange(
        book: 'Genesis',
        startChapter: 1,
        startVerse: 1,
        endChapter: 50,
        endVerse: 26,
      );

  ReadingPlan generate(int wpm, int days, String id) => PlanGenerator(
        wordCountService: wordCountService,
        allPericopes: allPericopes,
        wpm: wpm,
      ).generatePlan(
        id: id,
        title: 'Genesis pace test',
        tracks: [
          [genesis()]
        ],
        days: days,
        cadence: 7,
      );

  test('single track covers the input range exactly once', () {
    final plan = generator.generatePlan(
      id: 'gen30',
      title: 'Genesis in 30 Days',
      tracks: [
        [genesis()]
      ],
      days: 30,
      cadence: 7,
    );
    expect(plan.schedule.length, 30);
    final expected = expandRange(canon, genesis());
    final actual = unionOf(canon, plan);
    expect(actual.difference(expected), isEmpty);
    expect(expected.difference(actual), isEmpty);
  });

  test('no day is empty', () {
    final plan = generator.generatePlan(
      id: 'gen30b',
      title: 'Genesis in 30 Days',
      tracks: [
        [genesis()]
      ],
      days: 30,
      cadence: 7,
    );
    for (final day in plan.schedule) {
      expect(day.portions, isNotEmpty, reason: 'day ${day.dayNumber}');
      expect(day.totalWords, greaterThan(0));
    }
  });

  test('generation is deterministic', () {
    ReadingPlan run(String id) => generator.generatePlan(
          id: id,
          title: 'Genesis in 30 Days',
          tracks: [
            [genesis()]
          ],
          days: 30,
          cadence: 7,
        );
    final a = jsonEncode(run('a')
        .schedule
        .map((d) => d.portions
            .map((p) =>
                '${p.book} ${p.startChapter}:${p.startVerse}-${p.endChapter}:${p.endVerse}')
            .toList())
        .toList());
    final b = jsonEncode(run('b')
        .schedule
        .map((d) => d.portions
            .map((p) =>
                '${p.book} ${p.startChapter}:${p.startVerse}-${p.endChapter}:${p.endVerse}')
            .toList())
        .toList());
    expect(a, b);
  });

  test('N=1 puts the whole range in a single day', () {
    final plan = generator.generatePlan(
      id: 'gen1',
      title: 'Genesis in 1 Day',
      tracks: [
        [genesis()]
      ],
      days: 1,
      cadence: 7,
    );
    expect(plan.schedule.length, 1);
    expect(unionOf(canon, plan), expandRange(canon, genesis()));
  });

  test('absurd day counts clamp instead of producing empty days', () {
    final plan = generator.generatePlan(
      id: 'gen5000',
      title: 'Genesis in 5000 Days',
      tracks: [
        [genesis()]
      ],
      days: 5000,
      cadence: 7,
    );
    expect(plan.wasClamped, isTrue);
    expect(plan.clampReason, isNotNull);
    expect(plan.schedule.length, greaterThanOrEqualTo(1));
    expect(plan.schedule.length, lessThanOrEqualTo(5000));
    for (final day in plan.schedule) {
      expect(day.portions, isNotEmpty);
    }
    expect(unionOf(canon, plan), expandRange(canon, genesis()));
  });

  test('wpm scales estimates without changing coverage', () {
    final slow = generate(100, 30, 'wpm-slow');
    final fast = generate(200, 30, 'wpm-fast');
    // Same content distribution...
    expect(unionOf(canon, slow), unionOf(canon, fast));
    // ...but fewer minutes per day for the faster reader.
    var strictlyLess = 0;
    for (var i = 0; i < slow.schedule.length; i++) {
      expect(fast.schedule[i].estimatedMinutes,
          lessThanOrEqualTo(slow.schedule[i].estimatedMinutes));
      if (fast.schedule[i].estimatedMinutes <
          slow.schedule[i].estimatedMinutes) {
        strictlyLess++;
      }
    }
    expect(strictlyLess, greaterThan(0));
  });

  test('wpm moves the clamp ceiling', () {
    final slow = generate(100, 5000, 'wpm-clamp-slow');
    final fast = generate(400, 5000, 'wpm-clamp-fast');
    expect(slow.wasClamped, isTrue);
    expect(fast.wasClamped, isTrue);
    // Higher wpm -> lower minimum-words floor -> fewer max days.
    expect(fast.schedule.length, lessThan(slow.schedule.length));
    // Coverage preserved under clamping for both.
    expect(unionOf(canon, fast), expandRange(canon, genesis()));
  });

  test('multi-track days stay disjoint and jointly complete', () {
    final exodus = PlanRange(
      book: 'Exodus',
      startChapter: 1,
      startVerse: 1,
      endChapter: 40,
      endVerse: 38,
    );
    final plan = generator.generatePlan(
      id: 'genex',
      title: 'Genesis + Exodus',
      tracks: [
        [genesis()],
        [exodus],
      ],
      days: 60,
      cadence: 7,
    );
    final expected = expandRange(canon, genesis())
      ..addAll(expandRange(canon, exodus));
    final actual = unionOf(canon, plan);
    expect(actual.difference(expected), isEmpty);
    expect(expected.difference(actual), isEmpty);
    // No verse twice within a single day (tracks are disjoint books here,
    // so any duplicate is a scheduler bug).
    for (final day in plan.schedule) {
      final seen = <String>{};
      for (final p in day.portions) {
        final chapters = canon[p.book]!;
        for (var ch = p.startChapter; ch <= p.endChapter; ch++) {
          final verses = chapters[ch]!;
          final lo = ch == p.startChapter ? p.startVerse : verses.first;
          final hi = ch == p.endChapter ? p.endVerse : verses.last;
          for (var v = lo; v <= hi; v++) {
            expect(seen.add('${p.book}|$ch|$v'), isTrue,
                reason: 'day ${day.dayNumber} overlaps itself');
          }
        }
      }
    }
  });
}
