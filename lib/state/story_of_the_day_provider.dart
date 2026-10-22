import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/devotional_story.dart';
import 'devotional_provider.dart';

/// Selection strategy for Story of the Day: randomized (default) or chronological sequence.
enum StorySelectionMode {
  randomized,
  chronological,
}

class StorySelectionModeNotifier extends Notifier<StorySelectionMode> {
  @override
  StorySelectionMode build() => StorySelectionMode.randomized;

  void setMode(StorySelectionMode mode) {
    state = mode;
  }
}

final storySelectionModeProvider =
    NotifierProvider<StorySelectionModeNotifier, StorySelectionMode>(
        StorySelectionModeNotifier.new);

/// Delivers today's Bible Story from the 500-story devotional collection.
/// Rotates every day based on the calendar date (seeded so it remains consistent all day).
final storyOfTheDayProvider = FutureProvider<DevotionalStory?>((ref) async {
  final stories = await ref.watch(devotionalStoriesProvider.future);
  if (stories.isEmpty) return null;

  final now = DateTime.now();
  final dayIndex = DateTime(now.year, now.month, now.day)
      .difference(DateTime(2026, 1, 1))
      .inDays;

  final mode = ref.watch(storySelectionModeProvider);

  if (mode == StorySelectionMode.randomized) {
    final random = Random(dayIndex);
    final index = random.nextInt(stories.length);
    return stories[index];
  } else {
    final index = dayIndex % stories.length;
    return stories[index.abs()];
  }
});
