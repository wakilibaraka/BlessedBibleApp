// Story of the Day: shuffled mode never repeats within a full cycle, read
// stories are skipped, the pick holds for the day, and the mode persists.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/data/models/devotional_story.dart';
import 'package:the_blessed_bible/state/devotional_provider.dart';
import 'package:the_blessed_bible/state/story_of_the_day_provider.dart';

DevotionalStory _story(int i) => DevotionalStory(
      id: 'S-$i',
      title: 'Story $i',
      ref: 'Genesis 1:$i',
      keyVerseRef: '',
      keyVerse: '',
      retelling: '',
      book: 'Genesis',
      prefix: 'GEN',
      testament: 'OT',
      grouping: 'Torah',
      order: 1,
      indexInBook: i,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final stories = List.generate(500, _story);
  final day0 = DateTime(2026, 1, 1);

  test('shuffled mode shows every story once per 500 days', () {
    final seen = <String>{
      for (var d = 0; d < 500; d++)
        pickStoryOfTheDay(stories, day0.add(Duration(days: d)),
            StorySelectionMode.randomized, const {}).id,
    };
    expect(seen.length, 500);
  });

  test('in-order mode follows the collection order', () {
    expect(
        pickStoryOfTheDay(
            stories, day0, StorySelectionMode.chronological, const {}).id,
        'S-0');
    expect(
        pickStoryOfTheDay(stories, day0.add(const Duration(days: 3)),
            StorySelectionMode.chronological, const {}).id,
        'S-3');
  });

  test('stories already read are skipped', () {
    final pick = pickStoryOfTheDay(
        stories, day0, StorySelectionMode.chronological, {'S-0', 'S-1'});
    expect(pick.id, 'S-2');
    final allRead = {for (final s in stories) s.id};
    expect(
        pickStoryOfTheDay(
                stories, day0, StorySelectionMode.chronological, allRead)
            .id,
        'S-0');
  });

  test('mode persists and read state toggles', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    ProviderContainer make() => ProviderContainer(overrides: [
          preferencesProvider.overrideWithValue(PreferencesService(prefs)),
        ]);

    final first = make();
    first
        .read(storySelectionModeProvider.notifier)
        .setMode(StorySelectionMode.chronological);
    final read = first.read(devotionalReadProvider.notifier);
    expect(read.toggle('S-1'), isTrue);
    expect(read.toggle('S-1'), isFalse);
    expect(first.read(devotionalReadProvider), isEmpty);
    first.dispose();

    final second = make();
    addTearDown(second.dispose);
    expect(second.read(storySelectionModeProvider),
        StorySelectionMode.chronological);
  });

  test('today\'s pick is kept after the story is read', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(prefs)),
    ]);
    addTearDown(container.dispose);

    final story = await container.read(storyOfTheDayProvider.future);
    expect(story, isNotNull);
    container.read(devotionalReadProvider.notifier).markRead(story!.id);
    container.invalidate(storyOfTheDayProvider);
    final again = await container.read(storyOfTheDayProvider.future);
    expect(again!.id, story.id);
  });
}
