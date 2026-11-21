// Plan tracking: completion dates, read-today, plan streak, and the repace
// atom rebuild. Dates are additive history; they must never decide whether a
// day is complete.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/models/reading_plan.dart';
import 'package:the_blessed_bible/state/reading_plan_provider.dart';

List<PlanDayData> _days(int n) => [
      for (var d = 1; d <= n; d++)
        PlanDayData(
          day: d,
          week: 1,
          title: 'Day $d',
          passages: [
            PlanPassage(label: 'Genesis $d', refs: ['Genesis $d'])
          ],
        ),
    ];

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _daysAgo(int n) =>
    DateTime(_today().year, _today().month, _today().day - n);

ReadingPlanState _state({
  required Map<int, DateTime> completedOn,
  Set<int> completed = const {},
  int dayCount = 5,
}) =>
    ReadingPlanState(
      planId: 'p',
      planStartedOn: _today(),
      planData: _days(dayCount),
      completedReadings: completed,
      completedOn: completedOn,
    );

Map<String, dynamic> _customPlan() => {
      'id': 'track-1',
      'title': 'Genesis in 2 days',
      'schedule': [
        {
          'dayNumber': 1,
          'portions': [
            {
              'book': 'Genesis',
              'startChapter': 1,
              'startVerse': 1,
              'endChapter': 1,
              'endVerse': 5,
            },
          ],
        },
        {
          'dayNumber': 2,
          'portions': [
            {
              'book': 'Genesis',
              'startChapter': 1,
              'startVerse': 6,
              'endChapter': 2,
              'endVerse': 3,
            },
          ],
        },
      ],
    };

Future<ReadingPlanState> _waitForPlan(
    ProviderContainer container, String planId) async {
  var state = container.read(readingPlanProvider(planId));
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (state.isLoading && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    state = container.read(readingPlanProvider(planId));
  }
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('state getters', () {
    test('readToday is true only when today has a completion', () {
      expect(_state(completedOn: {1: _today()}).readToday, isTrue);
      expect(_state(completedOn: {1: _daysAgo(1)}).readToday, isFalse);
      expect(_state(completedOn: const {}).readToday, isFalse);
    });

    test('streak counts consecutive days ending today', () {
      final s = _state(completedOn: {
        1: _daysAgo(2),
        2: _daysAgo(1),
        3: _today(),
      });
      expect(s.readingStreak, 3);
    });

    test('today unread does not break the streak', () {
      final s = _state(completedOn: {1: _daysAgo(2), 2: _daysAgo(1)});
      expect(s.readingStreak, 2);
    });

    test('a gap breaks the streak', () {
      final s = _state(completedOn: {1: _daysAgo(3), 2: _today()});
      expect(s.readingStreak, 1);
    });

    test('a stale date with nothing recent gives no streak', () {
      final s = _state(completedOn: {1: _daysAgo(4)});
      expect(s.readingStreak, 0);
    });

    test('lastReadOn and completedAt expose history', () {
      final s = _state(completedOn: {1: _daysAgo(2), 2: _daysAgo(1)});
      expect(s.lastReadOn, _daysAgo(1));
      expect(s.completedAt(1), _daysAgo(2));
      expect(s.completedAt(9), isNull);
    });

    test('dateKey is a zero-padded ISO day', () {
      expect(ReadingPlanState.dateKey(DateTime(2026, 3, 7)), '2026-03-07');
    });
  });

  group('persistence', () {
    test('marks record a date, survive reload, and clear on undo', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService(await SharedPreferences.getInstance());
      prefs.saveCustomPlan('track-1', _customPlan());

      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final loaded = await _waitForPlan(container, 'track-1');
      expect(loaded.error, isNull);

      final notifier = container.read(readingPlanProvider('track-1').notifier);
      notifier.markReadingComplete(1);
      var state = container.read(readingPlanProvider('track-1'));
      expect(state.completedOn[1], _today());
      expect(state.readToday, isTrue);
      expect(state.readingStreak, 1);

      // Reload from scratch: the date comes back from prefs.
      final reopened = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(reopened.dispose);
      final restored = await _waitForPlan(reopened, 'track-1');
      expect(restored.completedOn[1], _today());
      expect(restored.isDayComplete(1), isTrue);

      notifier.markReadingIncomplete(1);
      state = container.read(readingPlanProvider('track-1'));
      expect(state.completedOn.containsKey(1), isFalse);
      expect(state.readToday, isFalse);
    });

    test('out-of-range day numbers are ignored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService(await SharedPreferences.getInstance());
      prefs.saveCustomPlan('track-1', _customPlan());
      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      await _waitForPlan(container, 'track-1');

      final notifier = container.read(readingPlanProvider('track-1').notifier);
      notifier.markReadingComplete(0);
      notifier.markReadingComplete(99);
      final state = container.read(readingPlanProvider('track-1'));
      expect(state.completedReadings, isEmpty);
      expect(state.completedOn, isEmpty);
    });

    test('catch-up dates the days it completes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService(await SharedPreferences.getInstance());
      prefs.saveCustomPlan('track-1', _customPlan());
      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      await _waitForPlan(container, 'track-1');

      final notifier = container.read(readingPlanProvider('track-1').notifier);
      notifier.markAllPreviousRead(2);
      final state = container.read(readingPlanProvider('track-1'));
      expect(state.isDayComplete(1), isTrue);
      expect(state.completedOn[1], _today());
      // The target day itself is never touched.
      expect(state.isDayComplete(2), isFalse);
    });

    test('legacy progress without dates loads with empty history', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService(await SharedPreferences.getInstance());
      prefs.saveReadingPlanState('track-1', {
        'planId': 'track-1',
        'completedReadings': [1],
      });
      prefs.saveCustomPlan('track-1', _customPlan());
      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final state = await _waitForPlan(container, 'track-1');
      expect(state.isDayComplete(1), isTrue);
      expect(state.completedOn, isEmpty);
      expect(state.readToday, isFalse);
    });
  });

  test('repace atom ids are rebuilt for the new schedule', () {
    final plan = ReadingPlan(
      id: 'p',
      title: 't',
      days: 2,
      cadence: 7,
      schedule: [
        PlanDay(
          dayNumber: 1,
          totalWords: 100,
          estimatedMinutes: 1,
          estimatedTimeDisplay: '1 min',
          portions: [
            PlanPortion(
              book: 'Genesis',
              startChapter: 1,
              startVerse: 1,
              endChapter: 1,
              endVerse: 10,
              wordCount: 100,
              pericopeTitles: const [],
            ),
          ],
        ),
        PlanDay(
          dayNumber: 2,
          totalWords: 100,
          estimatedMinutes: 1,
          estimatedTimeDisplay: '1 min',
          portions: [
            PlanPortion(
              book: 'Genesis',
              startChapter: 2,
              startVerse: 1,
              endChapter: 2,
              endVerse: 5,
              wordCount: 100,
              pericopeTitles: const [],
            ),
          ],
        ),
      ],
    );

    expect(atomsForCompletedDays(plan, {2}), {'Genesis|2|1|2|5'});
    expect(atomsForCompletedDays(plan, {1, 2}), hasLength(2));
    expect(atomsForCompletedDays(plan, const {}), isEmpty);
  });
}
