// Story reader: opens on the story (no inline passage by default), the
// save and read buttons toggle, and the bottom bar names the next story.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/data/models/devotional_story.dart';
import 'package:the_blessed_bible/l10n/l10n.dart';
import 'package:the_blessed_bible/services/devotional_service.dart';
import 'package:the_blessed_bible/state/devotional_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/bible_story_reader_screen.dart';
import 'package:the_blessed_bible/ui/widgets/stories_space_segment.dart';

void main() {
  late List<DevotionalStory> all;
  late PreferencesService prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = PreferencesService(await SharedPreferences.getInstance());
  });

  Future<ProviderContainer> pump(WidgetTester tester, Widget home) async {
    final container = ProviderContainer(overrides: [
      preferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);
    await tester.runAsync(() async {
      all = await DevotionalService().loadAllStoryRefs();
      await container.read(devotionalStoriesProvider.future);
    });
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme(16),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      ),
    ));
    await tester.pump();
    return container;
  }

  testWidgets('reader is story-first and its buttons toggle', (tester) async {
    await tester.runAsync(() async {
      all = await DevotionalService().loadAllStoryRefs();
    });
    final story = all.firstWhere((s) => s.id == 'JDG-008');
    final container =
        await pump(tester, BibleStoryReaderScreen(initialStory: story));
    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.text(story.title), findsOneWidget);
    expect(find.text(l10n.storiesTheStory), findsNothing);
    expect(
        find.text(l10n.storiesNextUp(
            all[all.indexWhere((s) => s.id == story.id) + 1].title)),
        findsOneWidget);
    // Opening alone no longer marks the story read.
    expect(container.read(devotionalReadProvider), isNot(contains(story.id)));

    await tester.tap(find.byTooltip(l10n.storiesFavorite));
    await tester.pump();
    expect(container.read(devotionalFavoritesProvider), contains(story.id));

    await tester.tap(find.byTooltip(l10n.storiesMarkAsRead));
    await tester.pump();
    expect(container.read(devotionalReadProvider), contains(story.id));
    await tester.tap(find.byTooltip(l10n.storiesMarkAsUnread));
    await tester.pump();
    expect(container.read(devotionalReadProvider), isNot(contains(story.id)));
  });

  testWidgets('Your Space lists saved stories and marks', (tester) async {
    await tester.runAsync(() async {
      all = await DevotionalService().loadAllStoryRefs();
    });
    final story = all.firstWhere((s) => s.id == 'JDG-008');
    final container = ProviderContainer(overrides: [
      preferencesProvider.overrideWithValue(prefs),
    ]);
    container.read(devotionalFavoritesProvider.notifier).toggle(story.id);
    container.read(storyMarksProvider.notifier).add(story.id,
        const StoryMark(start: 0, end: 12, kind: StoryMarkKind.highlight));
    container.dispose();

    await pump(
      tester,
      Builder(
        builder: (context) =>
            Scaffold(body: StoriesSpaceSegment(theme: Theme.of(context))),
      ),
    );
    expect(find.text(story.title), findsNWidgets(2));
  });
}
