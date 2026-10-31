// Phase 6 chunk 8: golden snapshots of key screens, so visual changes show
// up in review instead of on a device. Regenerate after an intended change:
//
//   flutter test --update-goldens test/goldens_test.dart
//
// Tests render text with Flutter's test font (blocks, not glyphs), which is
// the same on every machine, so the images compare cleanly in CI.

import 'package:blessed_account/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/state/theme_provider.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/l10n/generated/app_localizations.dart';
import 'package:the_blessed_bible/state/auth_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/onboarding_screen.dart';
import 'package:the_blessed_bible/ui/screens/settings_screen.dart';
import 'package:the_blessed_bible/ui/widgets/state_views.dart';

// Only screens whose pixels don't depend on today's date or on
// asynchronously restored settings, so the images stay stable.
final _screens = <String, Widget Function()>{
  'error_state': () => const Scaffold(body: ErrorState(onRetry: _noop)),
  'empty_state': () => const Scaffold(
        body: EmptyState(
          icon: Icons.bookmark_border_rounded,
          title: 'No bookmarks yet',
          message: 'Tap a verse and choose Bookmark to keep it here.',
          actionLabel: 'Start reading',
          onAction: _noop,
        ),
      ),
};

void _noop() {}

class _FixedAutoTheme extends AutoThemeInputsNotifier {
  @override
  AutoThemeInputs build() {
    const inputs = AutoThemeInputs(day: 0, brightness: Brightness.light);
    AutoTheme.latest = inputs;
    return inputs;
  }
}

final _themes = <String, ThemeData Function()>{
  'light': () => AppTheme.lightTheme(1.0),
  'dark': () => AppTheme.darkTheme(1.0),
  'sepia': () => AppTheme.sepiaTheme(1.0),
};

Future<void> _pump(WidgetTester tester, Widget screen, ThemeData theme,
    {Locale locale = const Locale('en'),
    Map<String, Object> prefsValues = const {}}) async {
  tester.view.physicalSize = const Size(1170, 2532); // 390x844 @3x
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      authGatewayProvider.overrideWithValue(FakeAuthGateway()),
      // Daily rotation depends on the date: pin it so goldens never drift.
      autoThemeInputsProvider.overrideWith(_FixedAutoTheme.new),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  ));
  // Fixed frames rather than pumpAndSettle: backgrounds animate forever,
  // and the fake clock makes these frames identical on every run.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  for (final s in _screens.entries) {
    for (final t in _themes.entries) {
      testWidgets('${s.key} ${t.key}', (tester) async {
        await _pump(tester, s.value(), t.value());
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('goldens/${s.key}_${t.key}.png'));
      });
    }
  }

  // Onboarding steps (they draw their own fixed palette, so one theme).
  // Step 3 is left out: its live theme preview restores asynchronously.
  for (final page in [0, 1, 3, 4]) {
    testWidgets('onboarding step ${page + 1}', (tester) async {
      await _pump(tester, const OnboardingScreen(), AppTheme.lightTheme(1.0),
          prefsValues: {OnboardingScreen.pageKey: page});
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('goldens/onboarding_step${page + 1}.png'));
    });
  }

  // Longest translations, to catch clipped or overflowing labels. No
  // image: settings restores its surface style asynchronously, so its
  // pixels depend on test order.
  for (final lang in ['fr', 'sw']) {
    testWidgets('settings in $lang lays out without overflow', (tester) async {
      await _pump(tester, const SettingsScreen(), AppTheme.lightTheme(1.0),
          locale: Locale(lang));
      expect(tester.takeException(), isNull);
    });
  }
}
