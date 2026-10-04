// Regression test: custom (non-bundled) plans must load. Previously
// _loadData ran synchronously inside build() for custom ids (no await
// before the state assignment), throwing on the uninitialized provider and
// leaving the plan stuck on isLoading forever (detail-screen spinner).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/reading_plan_provider.dart';

Map<String, dynamic> testCustomPlan() => {
      'id': 'custom-1',
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

void main() {
  // rootBundle (canon index for atom building) needs a binding even in
  // plain unit tests. Real async (no FakeAsync), so asset reads complete.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('custom plan loads planData and clears isLoading', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
    addTearDown(container.dispose);

    container.read(preferencesProvider).saveCustomPlan(
          'custom-1',
          testCustomPlan(),
        );

    // Trigger provider creation (starts async load).
    container.read(readingPlanProvider('custom-1'));
    // Let the async load finish.
    await Future.delayed(const Duration(milliseconds: 200));

    final loaded = container.read(readingPlanProvider('custom-1'));
    expect(loaded.error, isNull);
    expect(loaded.isLoading, isFalse);
    expect(loaded.planData.length, 2);
    expect(
      loaded.planData.first.passages.first.label,
      'Genesis 1:1-5',
    );
  });

  test('legacy progress backfills to atoms on load', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
    addTearDown(container.dispose);

    // Legacy prefs: day numbers only, no atoms.
    container.read(preferencesProvider).saveReadingPlanState('custom-1', {
      'planId': 'custom-1',
      'completedReadings': [1],
    });
    container.read(preferencesProvider).saveCustomPlan(
          'custom-1',
          testCustomPlan(),
        );
    container.read(readingPlanProvider('custom-1'));
    await Future.delayed(const Duration(milliseconds: 200));

    final state = container.read(readingPlanProvider('custom-1'));
    expect(state.error, isNull);
    expect(state.completedAtomIds, isNotEmpty);
    // Atom rule agrees with the legacy rule after backfill.
    expect(state.isDayComplete(1), isTrue);
    expect(state.isDayComplete(2), isFalse);
    expect(state.progressDisagreement, isEmpty);
  });

  test('writers maintain day numbers and atoms together', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
    addTearDown(container.dispose);

    container.read(preferencesProvider).saveCustomPlan(
          'custom-1',
          testCustomPlan(),
        );
    container.read(readingPlanProvider('custom-1'));
    await Future.delayed(const Duration(milliseconds: 200));

    final notifier =
        container.read(readingPlanProvider('custom-1').notifier);
    notifier.markReadingComplete(2);

    var state = container.read(readingPlanProvider('custom-1'));
    expect(state.completedReadings, contains(2));
    final day2Atoms = state.dayAtoms[2]!;
    expect(day2Atoms, isNotEmpty);
    for (final a in day2Atoms) {
      expect(state.completedAtomIds, contains(a));
    }

    notifier.markReadingIncomplete(2);
    state = container.read(readingPlanProvider('custom-1'));
    expect(state.completedReadings, isNot(contains(2)));
    for (final a in day2Atoms) {
      expect(state.completedAtomIds, isNot(contains(a)));
    }
  });

  test('completion survives plan rebuilds via atoms, not labels', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
    addTearDown(container.dispose);

    container.read(preferencesProvider).saveCustomPlan(
          'custom-1',
          testCustomPlan(),
        );
    container.read(readingPlanProvider('custom-1'));
    await Future.delayed(const Duration(milliseconds: 200));

    final notifier =
        container.read(readingPlanProvider('custom-1').notifier);
    notifier.markReadingComplete(1);
    final state = container.read(readingPlanProvider('custom-1'));
    expect(state.isDayComplete(1), isTrue);
    final recorded = Set<String>.from(state.completedAtomIds);
    expect(recorded, isNotEmpty);

    // Simulate a rebuild (repace/reload): same content atoms re-attached
    // to rebuilt plan data while the legacy day-number set is cleared.
    // Completion must follow the atoms, not the labels.
    final rebuilt = state.copyWith(
      planData: state.planData,
      dayAtoms: {1: recorded.toList(), 2: const []},
      completedReadings: {},
    );
    expect(rebuilt.isDayComplete(1), isTrue);
    expect(rebuilt.isDayComplete(2), isFalse);

    // With atoms also gone, the legacy rule applies (day 1 cleared).
    final bare = rebuilt.copyWith(completedAtomIds: {});
    expect(bare.isDayComplete(1), isFalse);
  });

  test('markAllPreviousRead completes every day before the given day',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
    addTearDown(container.dispose);

    container.read(preferencesProvider).saveCustomPlan(
          'custom-1',
          testCustomPlan(),
        );
    container.read(readingPlanProvider('custom-1'));
    await Future.delayed(const Duration(milliseconds: 200));

    final notifier =
        container.read(readingPlanProvider('custom-1').notifier);
    notifier.markAllPreviousRead(2);

    final state = container.read(readingPlanProvider('custom-1'));
    expect(state.completedReadings, contains(1));
    expect(state.completedReadings, isNot(contains(2)));
  });
}
