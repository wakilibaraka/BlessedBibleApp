import 'package:blessed_account/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/auth_provider.dart';
import 'package:the_blessed_bible/state/locale_provider.dart';
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
    await _pump(tester, {OnboardingScreen.pageKey: 3});
    expect(find.text('A gentle daily reminder'), findsOneWidget);
  });

  testWidgets('the last step offers optional sign-in', (tester) async {
    await _pump(tester, {OnboardingScreen.pageKey: 5});
    expect(find.text('Keep your notes safe'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
    expect(find.text('Begin reading'), findsOneWidget);
  });
}
