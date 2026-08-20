import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/pericope_entry.dart';
import 'package:the_blessed_bible/models/reading_plan.dart';
import 'package:the_blessed_bible/services/pace_remap_service.dart';
import 'package:the_blessed_bible/services/plan_generator.dart';
import 'package:the_blessed_bible/services/word_count_service.dart';

void main() {
  late WordCountService wcs;
  late List<PericopeEntry> allPericopes;
  late PlanGenerator generator;
  late PaceRemapService remapService;

  // A simple single-track covering Genesis (50 chapters, well-known boundaries)
  final genesisTrack = [
    PlanRange(
      book: 'Genesis',
      startChapter: 1,
      startVerse: 1,
      endChapter: 50,
      endVerse: 26,
    )
  ];

  // A longer track (Genesis + Exodus) to stress-test straddle logic
  final genExodusTrack = [
    PlanRange(book: 'Genesis', startChapter: 1, startVerse: 1, endChapter: 50, endVerse: 26),
    PlanRange(book: 'Exodus', startChapter: 1, startVerse: 1, endChapter: 40, endVerse: 38),
  ];

  setUpAll(() async {
    final wcJson = File('assets/data/word_counts.json').readAsStringSync();
    wcs = WordCountService();
    await wcs.initFromJson(wcJson);

    final pList = jsonDecode(File('assets/data/pericopes.json').readAsStringSync()) as List;
    allPericopes = pList.map((j) => PericopeEntry.fromJson(j)).toList();

    generator = PlanGenerator(wordCountService: wcs, allPericopes: allPericopes);
    remapService = PaceRemapService(wordCountService: wcs, allPericopes: allPericopes);
  });

  // ─── Guard ────────────────────────────────────────────────────────────────

  test('unavailableReason: plan with null tracks → noTracks', () {
    final plan = generator.generatePlan(
      id: 'x', title: 'X', tracks: [genesisTrack], days: 30);
    // Manually nullify tracks to simulate old plan
    final oldPlan = ReadingPlan(
      id: plan.id, title: plan.title, days: plan.days,
      cadence: plan.cadence, schedule: plan.schedule, tracks: null,
    );
    expect(remapService.unavailableReason(oldPlan), PaceAdjustUnavailableReason.noTracks);
  });

  test('unavailableReason: plan with tracks → null (available)', () {
    final plan = generator.generatePlan(
      id: 'x', title: 'X', tracks: [genesisTrack], days: 30);
    expect(remapService.unavailableReason(plan), isNull);
  });

  test('remap throws ArgumentError for plan without tracks', () {
    final plan = generator.generatePlan(
      id: 'x', title: 'X', tracks: [genesisTrack], days: 30);
    final noTrackPlan = ReadingPlan(
      id: plan.id, title: plan.title, days: plan.days,
      cadence: plan.cadence, schedule: plan.schedule, tracks: null,
    );
    expect(
      () => remapService.remap(oldPlan: noTrackPlan, oldCompleted: {}, newDayCount: 60),
      throwsArgumentError,
    );
  });

  // ─── No-op: same day count ─────────────────────────────────────────────────

  test('same day count → schedule and completed readings unchanged', () {
    final plan = generator.generatePlan(
      id: 'gen30', title: 'Genesis 30', tracks: [genesisTrack], days: 30);
    final completed = {1, 2, 3, 4, 5};

    final result = remapService.remap(
      oldPlan: plan, oldCompleted: completed, newDayCount: 30);

    // Same number of days
    expect(result.newPlan.schedule.length, plan.schedule.length);
    // Exact same completed day count
    expect(result.newCompletedReadings.length, completed.length);
    // The same day numbers are complete (same schedule = same mapping)
    expect(result.newCompletedReadings, equals(completed));
  });

  // ─── Lengthen (30 → 60) ──────────────────────────────────────────────────

  test('lengthen 30→60: completed-verse content preserved; no false completions', () {
    final plan30 = generator.generatePlan(
      id: 'gen30', title: 'Genesis 30', tracks: [genesisTrack], days: 30);

    // Mark first 10 days complete (~1/3 of Genesis)
    final completed30 = Set<int>.from(List.generate(10, (i) => i + 1));

    final result = remapService.remap(
      oldPlan: plan30, oldCompleted: completed30, newDayCount: 60);

    expect(result.newPlan.schedule.length, greaterThan(30));
    expect(result.newPlan.tracks, equals(plan30.tracks));

    // ── No false completion: every marked-complete new day must have
    //    ALL its verses in the old completed set.
    final completedVersesBefore = remapService.buildCompletedVerseSetPublic(
        plan30.schedule, completed30);
    for (final dayNum in result.newCompletedReadings) {
      final day = result.newPlan.schedule.firstWhere((d) => d.dayNumber == dayNum);
      expect(remapService.isDayFullyCompletedPublic(day, completedVersesBefore), isTrue,
          reason: 'Day $dayNum is marked complete but has uncompleted verses');
    }

    // ── No verse beyond the completed content should be marked complete.
    final completedVersesAfter = remapService.buildCompletedVerseSetPublic(
        result.newPlan.schedule, result.newCompletedReadings);
    // The after set should be a SUBSET of the before set.
    expect(completedVersesAfter.every((v) => completedVersesBefore.contains(v)), isTrue,
        reason: 'Progress remap added verses that were not previously complete');
  });

  // ─── Shorten (60 → 30): straddle day stays INCOMPLETE ────────────────────

  test('shorten 60→30: straddle day is incomplete, no false completion', () {
    final plan60 = generator.generatePlan(
      id: 'gen60', title: 'Genesis 60', tracks: [genesisTrack], days: 60);

    // Mark first 15 days complete (roughly 25% of 60)
    final completed60 = Set<int>.from(List.generate(15, (i) => i + 1));

    final result = remapService.remap(
      oldPlan: plan60, oldCompleted: completed60, newDayCount: 30);

    expect(result.newPlan.schedule.length, lessThanOrEqualTo(30));

    // ── No false completion ──────────────────────────────────────────────────
    final completedVersesBefore = remapService.buildCompletedVerseSetPublic(
        plan60.schedule, completed60);
    for (final dayNum in result.newCompletedReadings) {
      final day = result.newPlan.schedule.firstWhere((d) => d.dayNumber == dayNum);
      expect(remapService.isDayFullyCompletedPublic(day, completedVersesBefore), isTrue,
          reason: 'Day $dayNum marked complete but has uncompleted verses');
    }

    // ── The after completed set must not exceed the before set ───────────────
    final completedVersesAfter = remapService.buildCompletedVerseSetPublic(
        result.newPlan.schedule, result.newCompletedReadings);
    expect(completedVersesAfter.every((v) => completedVersesBefore.contains(v)), isTrue);

    // ── There must be at least one incomplete day in the new plan ─────────────
    // (the straddle day or days beyond the progress frontier)
    final totalNewDays = result.newPlan.schedule.length;
    expect(result.newCompletedReadings.length, lessThan(totalNewDays),
        reason: 'Expected at least one incomplete day after shortening');
  });

  // ─── Coverage integrity ───────────────────────────────────────────────────

  test('coverage integrity: new schedule covers same total words as tracks', () {
    // Calculate the word count that the track covers
    int trackWords = 0;
    for (final range in genesisTrack) {
      trackWords += wcs.wordsInRange(
          range.book, range.startChapter, range.startVerse,
          range.endChapter, range.endVerse);
    }

    // Re-pace from 30→45
    final plan30 = generator.generatePlan(
      id: 'gen30', title: 'Genesis 30', tracks: [genesisTrack], days: 30);
    final result = remapService.remap(
      oldPlan: plan30, oldCompleted: {}, newDayCount: 45);

    int newPlanWords = 0;
    for (final day in result.newPlan.schedule) {
      for (final p in day.portions) {
        newPlanWords += wcs.wordsInRange(
            p.book, p.startChapter, p.startVerse, p.endChapter, p.endVerse);
      }
    }

    expect(newPlanWords, equals(trackWords),
        reason: 'Word count mismatch: new plan does not cover same content as tracks');
  });

  // ─── Coverage integrity: multi-track ──────────────────────────────────────

  test('coverage integrity: multi-track (Genesis+Exodus) 60→90', () {
    int trackWords = 0;
    for (final range in genExodusTrack) {
      trackWords += wcs.wordsInRange(
          range.book, range.startChapter, range.startVerse,
          range.endChapter, range.endVerse);
    }

    final plan60 = generator.generatePlan(
      id: 'genex60', title: 'Gen+Ex 60', tracks: [genExodusTrack], days: 60);
    final result = remapService.remap(
      oldPlan: plan60, oldCompleted: {}, newDayCount: 90);

    int newWords = 0;
    for (final day in result.newPlan.schedule) {
      for (final p in day.portions) {
        newWords += wcs.wordsInRange(
            p.book, p.startChapter, p.startVerse, p.endChapter, p.endVerse);
      }
    }
    expect(newWords, equals(trackWords));
  });

  // ─── Absolute verse index sanity ─────────────────────────────────────────

  test('absoluteVerseIndex: Gen 1:1 = 0', () {
    expect(remapService.absoluteVerseIndex('Genesis', 1, 1), 0);
  });

  test('absoluteVerseIndex: Gen 1:2 = 1', () {
    expect(remapService.absoluteVerseIndex('Genesis', 1, 2), 1);
  });

  test('absoluteVerseIndex: Gen 1:31 = 30 (last verse of Gen 1)', () {
    // Gen 1 has 31 verses → index of verse 31 = 30
    expect(remapService.absoluteVerseIndex('Genesis', 1, 31), 30);
  });

  test('absoluteVerseIndex: Gen 2:1 = 31 (first verse of Gen 2)', () {
    expect(remapService.absoluteVerseIndex('Genesis', 2, 1), 31);
  });

  test('absoluteVerseIndex: Rev 22:21 = 31101', () {
    expect(remapService.absoluteVerseIndex('Revelation', 22, 21), 31101);
  });
}
