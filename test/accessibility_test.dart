// Phase 6 chunk 6: Flutter's accessibility guidelines on key screens, in a
// light and a dark theme, plus a largest-text pass that fails on layout
// overflow.

import 'package:blessed_account/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/auth_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/onboarding_screen.dart';
import 'package:the_blessed_bible/ui/screens/plans_library_screen.dart';
import 'package:the_blessed_bible/ui/screens/settings_screen.dart';

final _screens = <String, Widget Function()>{
  'onboarding': () => const OnboardingScreen(),
  'plans library': () => const PlansLibraryScreen(),
  'settings': () => const SettingsScreen(),
};

final _themes = <String, ThemeData Function()>{
  'light': () => AppTheme.lightTheme(1.0),
  'dark': () => AppTheme.darkTheme(1.0),
};

Future<void> _pump(WidgetTester tester, Widget screen, ThemeData theme,
    {double textScale = 1.0}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      authGatewayProvider.overrideWithValue(FakeAuthGateway()),
    ],
    child: MaterialApp(
      theme: theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: screen,
    ),
  ));
  // pump, not pumpAndSettle: themed backgrounds animate forever.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  for (final s in _screens.entries) {
    for (final t in _themes.entries) {
      testWidgets('${s.key} (${t.key}) meets tap-target and label guidelines',
          (tester) async {
        final handle = tester.ensureSemantics();
        await _pump(tester, s.value(), t.value());
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('${s.key} lays out at 2x text without overflow',
        (tester) async {
      await _pump(tester, s.value(), AppTheme.lightTheme(1.0), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  }
}
