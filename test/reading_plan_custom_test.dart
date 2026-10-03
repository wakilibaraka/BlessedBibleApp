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
