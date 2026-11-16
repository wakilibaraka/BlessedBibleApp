import 'package:blessed_account/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/auth_provider.dart';
import 'package:the_blessed_bible/state/locale_provider.dart';
import 'package:the_blessed_bible/state/read_location_provider.dart';
import 'package:the_blessed_bible/ui/screens/onboarding_screen.dart';

Future<SharedPreferences> _pump(WidgetTester tester,
    [Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      authGatewayProvider.overrideWithValue(FakeAuthGateway()),
    ],
    child: const MaterialApp(home: OnboardingScreen()),
  ));
  await tester.pump(const Duration(milliseconds: 100));
  return prefs;
}

/// Lets the page animation run frame by frame (pumpAndSettle would wait
/// on the endless background animations).
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.byType(FilledButton));
  await _settle(tester);
}

void main() {
  testWidgets('steps forward and back, keeping the language choice',
      (tester) async {
    final prefs = await _pump(tester);
    await tester.tap(find.text('Français'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(prefs.getString(AppLocaleNotifier.key), 'fr');

    await _next(tester);
    expect(prefs.getInt(OnboardingScreen.pageKey), 1);
    expect(prefs.getString('active_translation'), isNull);

    await _next(tester);
    expect(prefs.getInt(OnboardingScreen.pageKey), 2);

    await tester.tap(find.byTooltip('Back'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Back'));
    await _settle(tester);
    expect(prefs.getInt(OnboardingScreen.pageKey), 0);
    expect(find.text('Français'), findsOneWidget);
  });

  testWidgets('resumes on the step it was closed on', (tester) async {
    await _pump(tester, {OnboardingScreen.pageKey: 2});
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 3 of 4'), findsOneWidget);
  });

  testWidgets('the last step has the tour, reminder and optional sign-in',
      (tester) async {
    await _pump(tester, {OnboardingScreen.pageKey: 3});
    expect(find.bySemanticsLabel('Step 4 of 4'), findsOneWidget);
    expect(find.text('Everything for your daily walk'), findsOneWidget);
    expect(find.text('A gentle daily reminder'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sign in with Google'), 200,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    expect(find.text('Keep your notes safe'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
    expect(find.text('Begin reading'), findsOneWidget);
  });

  testWidgets('an old saved step past the end resumes on the last page',
      (tester) async {
    // Onboarding used to have five steps.
    await _pump(tester, {OnboardingScreen.pageKey: 4});
    expect(find.text('Begin reading'), findsOneWidget);
  });

  testWidgets(
      'Bible page displays Spanish and Portuguese bundled Bibles from static catalog',
      (tester) async {
    await _pump(tester, {OnboardingScreen.pageKey: 1});
    expect(find.text('Reina-Valera 1909'), findsWidgets);
    expect(find.text('Bíblia Livre'), findsWidgets);
  });

  test(
      'ReadLocationNotifier restores chapter without forcing requestedVerse on cold start and persists chapter changes immediately',
      () async {
    SharedPreferences.setMockInitialValues({});
    final rawPrefs = await SharedPreferences.getInstance();
    final prefsService = PreferencesService(rawPrefs);
    prefsService.saveLastReadLocation(
      bookAbbrev: 'jn',
      bookName: 'John',
      chapter: 3,
      verseIndex: 15,
    );
    prefsService.saveChapterScrollPosition('jn', 3, 15);

    final container = ProviderContainer(overrides: [
      preferencesProvider.overrideWithValue(prefsService),
    ]);
    addTearDown(container.dispose);

    final initial = container.read(readLocationProvider);
    expect(initial.bookAbbrev, 'jn');
    expect(initial.bookName, 'John');
    expect(initial.chapter, 3);
    expect(initial.requestedVerse, isNull);

    container.read(readLocationProvider.notifier).updateLocation(
          bookAbbrev: 'ps',
          bookName: 'Psalms',
          chapter: 23,
        );
    final saved = prefsService.getLastReadLocation();
    expect(saved?['bookAbbrev'], 'ps');
    expect(saved?['bookName'], 'Psalms');
    expect(saved?['chapter'], 23);
  });
}
