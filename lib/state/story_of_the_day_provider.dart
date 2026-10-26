import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_storage/preferences_service.dart';
import '../data/models/devotional_story.dart';
import 'devotional_provider.dart';

/// Selection strategy for Story of the Day: randomized (default) or chronological sequence.
enum StorySelectionMode {
  randomized,
  chronological,
}

class StorySelectionModeNotifier extends Notifier<StorySelectionMode> {
  static const String _key = 'sotd_mode';

  @override
  StorySelectionMode build() {
    final saved = ref.watch(preferencesProvider).prefs.getString(_key);
    return saved == StorySelectionMode.chronological.name
        ? StorySelectionMode.chronological
        : StorySelectionMode.randomized;
  }

  void setMode(StorySelectionMode mode) {
    state = mode;
    ref.read(preferencesProvider).prefs.setString(_key, mode.name);
  }
}

final storySelectionModeProvider =
    NotifierProvider<StorySelectionModeNotifier, StorySelectionMode>(
        StorySelectionModeNotifier.new);

/// Today's calendar date. Moves on at midnight and when the app resumes on
/// a new day, so Story of the Day never goes stale while the app is open.
class TodayNotifier extends Notifier<DateTime> {
  Timer? _midnight;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  DateTime build() {
    final lifecycle = AppLifecycleListener(onResume: _refresh);
    ref.onDispose(() {
      _midnight?.cancel();
      lifecycle.dispose();
    });
    _schedule();
    return _today();
  }

  void _schedule() {
    _midnight?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now) + const Duration(seconds: 1), () {
      _refresh();
      _schedule();
    });
  }

  void _refresh() {
    final today = _today();
    if (today != state) state = today;
  }
}

final todayProvider =
    NotifierProvider<TodayNotifier, DateTime>(TodayNotifier.new);

/// Picks the story for [day]. Shuffled mode walks one fixed permutation of
/// all stories (so nothing repeats until every story has had its day); in
/// order mode walks the Bible's order. Either way, stories already read
/// are skipped, unless everything has been read.
DevotionalStory pickStoryOfTheDay(
  List<DevotionalStory> stories,
  DateTime day,
  StorySelectionMode mode,
  Set<String> read,
) {
  final order = List<int>.generate(stories.length, (i) => i);
  if (mode == StorySelectionMode.randomized) {
    order.shuffle(Random(20260101));
  }
  final dayIndex = DateTime.utc(day.year, day.month, day.day)
      .difference(DateTime.utc(2026, 1, 1))
      .inDays;
  final start = dayIndex % stories.length;
  for (var step = 0; step < stories.length; step++) {
    final story = stories[order[(start + step) % stories.length]];
    if (!read.contains(story.id)) return story;
  }
  return stories[order[start]];
}

/// Delivers today's Bible Story from the 500-story devotional collection.
/// The pick is remembered for the day, so reading today's story does not
/// swap it for another one.
final storyOfTheDayProvider = FutureProvider<DevotionalStory?>((ref) async {
  final stories = await ref.watch(devotionalStoriesProvider.future);
  if (stories.isEmpty) return null;

  final day = ref.watch(todayProvider);
  final mode = ref.watch(storySelectionModeProvider);
  final prefs = ref.read(preferencesProvider).prefs;
  final dayKey = '${day.year}-${day.month}-${day.day}/${mode.name}';

  if (prefs.getString('sotd_day') == dayKey) {
    final savedId = prefs.getString('sotd_id');
    for (final story in stories) {
      if (story.id == savedId) return story;
    }
  }
  final story =
      pickStoryOfTheDay(stories, day, mode, ref.read(devotionalReadProvider));
  await prefs.setString('sotd_day', dayKey);
  await prefs.setString('sotd_id', story.id);
  return story;
});
