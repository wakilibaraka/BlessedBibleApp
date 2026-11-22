// Stress cases for the plan engine: a full-year schedule, year-long streaks,
// hundreds of toggles, persistence at size, and repeated repace. These are
// scale/correctness tests, not benchmarks, so the only timing bound is a very
// generous guard against accidental quadratic behaviour.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/models/pericope_entry.dart';
import 'package:the_blessed_bible/models/reading_plan.dart';
import 'package:the_blessed_bible/services/pace_remap_service.dart';
import 'package:the_blessed_bible/services/plan_generator.dart';
import 'package:the_blessed_bible/services/word_count_service.dart';
import 'package:the_blessed_bible/state/reading_plan_provider.dart';
import 'package:the_blessed_bible/state/streak_provider.dart';

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _dayOffset(int days) {
  final t = _today();
  return DateTime(t.year, t.month, t.day + days);
}

/// [count] distinct single-verse Genesis ranges, so every day owns unique
/// content atoms (shared atoms would make toggling one day affect another).
List<Map<String, dynamic>> _uniqueVerses(WordCountService wcs, int count) {
  final ranges = <Map<String, dynamic>>[];
  for (var ch = 1; ranges.length < count; ch++) {
    final maxV = wcs.maxVerseInChapter('Genesis', ch);
    if (maxV == 0) break;
    for (var v = 1; v <= maxV && ranges.length < count; v++) {
      ranges.add({
        'book': 'Genesis',
        'startChapter': ch,
        'startVerse': v,
        'endChapter': ch,
        'endVerse': v,
      });
    }
  }
  return ranges;
}

Map<String, dynamic> _customPlan(List<Map<String, dynamic>> verses) => {
      'id': 'stress-1',
      'title': 'Stress plan',
      'schedule': [
        for (var i = 0; i < verses.length; i++)
          {
            'dayNumber': i + 1,
            'portions': [
              {
                'book': verses[i]['book'],
                'startChapter': verses[i]['startChapter'],
                'startVerse': verses[i]['startVerse'],
                'endChapter': verses[i]['endChapter'],
                'endVerse': verses[i]['endVerse'],
              }
            ],
          },
      ],
    };

Future<ReadingPlanState> _load(ProviderContainer c, String id) async {
  var state = c.read(readingPlanProvider(id));
  final deadline = DateTime.now().add(const Duration(seconds: 40));
  while (state.isLoading && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    state = c.read(readingPlanProvider(id));
  }
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WordCountService wcs;
  late List<PericopeEntry> pericopes;

  setUpAll(() async {
    wcs = WordCountService();
    await wcs
        .initFromJson(File('assets/data/word_counts.json').readAsStringSync());
    pericopes =
        (jsonDecode(File('assets/data/pericopes.json').readAsStringSync())
                as List)
            .map((j) => PericopeEntry.fromJson(j as Map<String, dynamic>))
            .toList();
  });

  group('365-day plan', () {
    test('completes, persists at size, and reloads intact', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService(await SharedPreferences.getInstance());
      prefs.saveCustomPlan('stress-1', _customPlan(_uniqueVerses(wcs, 365)));

      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final loaded = await _load(container, 'stress-1');
      expect(loaded.error, isNull);
      expect(loaded.planData, hasLength(365));

      final notifier = container.read(readingPlanProvider('stress-1').notifier);
      // Start the plan first: an unstarted plan has no "today" at all, so the
      // schedule assertions below would be meaningless.
      notifier.startPlan(startDate: _dayOffset(-364));
      final watch = Stopwatch()..start();
      notifier.markAllPreviousRead(366); // clamps to the whole plan
      watch.stop();

      final state = container.read(readingPlanProvider('stress-1'));
      expect(state.isComplete, isTrue);
      expect(state.percentComplete, 1.0);
      expect(state.oldestUnread, 365);
      expect(state.todayReadingDay, isNull);
      expect(state.missedDays, isEmpty);
      expect(state.completedOn, hasLength(365));
      expect(state.readToday, isTrue);
      // Everything was caught up today, so the plan streak is 1, not 365.
      expect(state.readingStreak, 1);
      expect(watch.elapsed, lessThan(const Duration(seconds: 10)));

      final saved = prefs.getReadingPlanState('stress-1')!;
      expect(saved['completedOn'] as Map, hasLength(365));

      final reopened = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(reopened.dispose);
      final restored = await _load(reopened, 'stress-1');
      expect(restored.isComplete, isTrue);
      expect(restored.completedOn, hasLength(365));
      expect(restored.isDayComplete(180), isTrue);
    });

    test('183 unchecks and 183 rechecks leave no drift', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService(await SharedPreferences.getInstance());
      prefs.saveCustomPlan('stress-1', _customPlan(_uniqueVerses(wcs, 365)));
      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      await _load(container, 'stress-1');

      final notifier = container.read(readingPlanProvider('stress-1').notifier);
      notifier.markAllPreviousRead(366);

      // Day 1..365, odd days stay complete: 183 days.
      for (var d = 2; d <= 365; d += 2) {
        notifier.markReadingIncomplete(d);
      }
      var state = container.read(readingPlanProvider('stress-1'));
      expect(state.completedReadings.length, 183);
      expect(state.completedOn.length, 183);
      expect(state.isDayComplete(1), isTrue);
      expect(state.isDayComplete(2), isFalse);
      expect(state.isComplete, isFalse);

      for (var d = 2; d <= 365; d += 2) {
        notifier.markReadingComplete(d);
      }
      state = container.read(readingPlanProvider('stress-1'));
      expect(state.completedReadings.length, 365);
      expect(state.completedOn.length, 365);
      expect(state.isComplete, isTrue);
      expect(state.percentComplete, 1.0);
    });

    test('a year-long dated streak counts', () async {
      final dates = <int, DateTime>{
        for (var i = 0; i < 365; i++) i + 1: _dayOffset(-i),
      };
      final state = ReadingPlanState(
        planId: 'p',
        planStartedOn: _dayOffset(-364),
        planData: [
          for (var d = 1; d <= 365; d++)
            PlanDayData(day: d, week: 1, title: 'Day $d', passages: const []),
        ],
        completedReadings: dates.keys.toSet(),
        completedOn: dates,
      );
      expect(state.readingStreak, 365);
      expect(state.readToday, isTrue);
      expect(state.lastReadOn, _today());
      expect(state.percentComplete, 1.0);
    });
  });

  group('streak calculator at scale', () {
    test('20k unordered dates with duplicates and junk', () {
      final dates = <String>[];
      for (var i = 0; i < 20000; i++) {
        final d = DateTime(2026, 11, 21).subtract(Duration(days: i % 900));
        dates.add(
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
      }
      dates
        ..add('junk')
        ..add('')
        ..shuffle();
      // The contiguous run reaches back 899 days from 2026-11-21, which covers
      // every generated date, so the streak is the whole generated window.
      final watch = Stopwatch()..start();
      final s =
          StreakNotifier.calculateStreak(dates, now: DateTime(2026, 11, 21));
      watch.stop();
      expect(s.consecutiveDays, 900);
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
    });

    test('leap day is one step, not a gap', () {
      final s = StreakNotifier.calculateStreak(
        ['2024-02-28', '2024-02-29', '2024-03-01'],
        now: DateTime(2024, 3, 1),
      );
      expect(s.consecutiveDays, 3);
    });
  });

  group('repace at scale', () {
    test('365 -> 90 -> 365 loses no verses and stays complete', () async {
      final generator =
          PlanGenerator(wordCountService: wcs, allPericopes: pericopes);
      final remap =
          PaceRemapService(wordCountService: wcs, allPericopes: pericopes);

      final tracks = [
        [
          PlanRange(
              book: 'Genesis',
              startChapter: 1,
              startVerse: 1,
              endChapter: 50,
              endVerse: 26),
          PlanRange(
              book: 'Exodus',
              startChapter: 1,
              startVerse: 1,
              endChapter: 40,
              endVerse: 38),
        ]
      ];
      final original = generator.generatePlan(
        id: 'stress-repace',
        title: 'Stress repace',
        tracks: tracks,
        days: 365,
      );
      expect(original.schedule.length, greaterThan(100));

      final allOld = {for (final d in original.schedule) d.dayNumber};
      final oldVerses =
          remap.buildCompletedVerseSetPublic(original.schedule, allOld);

      final first = remap.remap(
        oldPlan: original,
        oldCompleted: allOld,
        newDayCount: 90,
      );
      expect(first.newCompletedReadings.length, first.newPlan.schedule.length,
          reason: 'every remapped day should be complete when all content was');
      expect(
        remap.buildCompletedVerseSetPublic(
            first.newPlan.schedule, first.newCompletedReadings),
        equals(oldVerses),
      );

      final back = remap.remap(
        oldPlan: first.newPlan,
        oldCompleted: first.newCompletedReadings,
        newDayCount: 365,
      );
      expect(back.newCompletedReadings.length, back.newPlan.schedule.length);
      expect(
        remap.buildCompletedVerseSetPublic(
            back.newPlan.schedule, back.newCompletedReadings),
        equals(oldVerses),
      );
    });
  });
}
