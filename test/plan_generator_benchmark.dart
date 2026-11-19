// Whole-Bible plan-generation benchmark. Run explicitly (not part of CI,
// and not picked up by `flutter test` because the name has no _test suffix):
//
//   fvm flutter test test/plan_generator_benchmark.dart
//
// One harness for before/after comparisons: the same input, the same warm-up
// and the same repeated measured runs. Swap lib/services/plan_generator.dart
// between implementations and diff the printed BENCH lines; the schedule
// fingerprint must not change.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/pericope_entry.dart';
import 'package:the_blessed_bible/models/reading_plan.dart';
import 'package:the_blessed_bible/services/plan_generator.dart';
import 'package:the_blessed_bible/services/word_count_service.dart';

void main() {
  test('whole Bible in 3 days: median generation time', () async {
    final wordCounts = WordCountService();
    await wordCounts
        .initFromJson(File('assets/data/word_counts.json').readAsStringSync());

    final pericopes =
        (jsonDecode(File('assets/data/pericopes.json').readAsStringSync())
                as List<dynamic>)
            .map((e) => PericopeEntry.fromJson(e as Map<String, dynamic>))
            .toList();

    // Whole-Bible track derived from the pericope data itself: one range per
    // book it covers, in the canonical order the data lists them, from 1:1 to
    // that book's last pericope.
    final pericopesByBook = <String, List<PericopeEntry>>{};
    for (final p in pericopes) {
      pericopesByBook.putIfAbsent(p.book, () => []).add(p);
    }
    final ranges = [
      for (final entry in pericopesByBook.entries)
        PlanRange(
          book: entry.key,
          startChapter: 1,
          startVerse: 1,
          endChapter: entry.value.last.endChapter,
          endVerse: entry.value.last.endVerse,
        ),
    ];

    final generator = PlanGenerator(
      wordCountService: wordCounts,
      allPericopes: pericopes,
    );

    ReadingPlan generate() => generator.generatePlan(
          id: 'bench',
          title: 'Whole Bible in 3 Days',
          tracks: [ranges],
          days: 3,
          cadence: 7,
        );

    // Warm-up: not measured.
    for (var i = 0; i < 3; i++) {
      generate();
    }

    const int measuredRuns = 11;
    final samples = <int>[];
    late ReadingPlan plan;
    for (var i = 0; i < measuredRuns; i++) {
      final watch = Stopwatch()..start();
      plan = generate();
      watch.stop();
      samples.add(watch.elapsedMicroseconds);
    }
    final sorted = [...samples]..sort();
    final median = sorted[sorted.length ~/ 2];

    final expectedWords = ranges.fold<int>(
      0,
      (total, r) =>
          total +
          wordCounts.wordsInRange(
              r.book, r.startChapter, r.startVerse, r.endChapter, r.endVerse),
    );
    final plannedWords =
        plan.schedule.fold<int>(0, (total, day) => total + day.totalWords);
    expect(plannedWords, expectedWords);

    final fingerprint = plan.schedule
        .map((day) => day.portions
            .map((p) => '${p.book} ${p.startChapter}:${p.startVerse}-'
                '${p.endChapter}:${p.endVerse}:${p.wordCount}')
            .join('|'))
        .join(';');

    debugPrint('BENCH samples_us=${sorted.join(",")}');
    debugPrint('BENCH median_us=$median min_us=${sorted.first} '
        'max_us=${sorted.last} runs=$measuredRuns');
    debugPrint('BENCH words=$plannedWords days=${plan.days} schedule_sha='
        '${sha256.convert(utf8.encode(fingerprint)).toString().substring(0, 16)}');
  });
}
