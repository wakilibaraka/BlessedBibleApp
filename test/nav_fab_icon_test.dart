// FAB icon per tab: Home keeps the settings gear, Settings shows the
// crossed swords, and the other tabs keep their existing icons.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/nav_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/main_nav_screen.dart';
import 'package:the_blessed_bible/ui/widgets/crossed_swords_icon.dart';

void main() {
  Future<void> pumpAtTab(WidgetTester tester, int index) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(PreferencesService(prefs)),
        ],
        child: MaterialApp(
          // The bottom dock's TexturedGlassContainer requires the app's
          // ReadingTokens extension, so use the real theme.
          theme: AppTheme.lightTheme(1.0),
          home: const MainNavScreen(),
        ),
      ),
    );
    // Let the async settings load settle, then switch tabs.
    await tester.pump(const Duration(milliseconds: 400));
    final container = ProviderScope.containerOf(
        tester.element(find.byType(MainNavScreen)));
    container.read(navProvider.notifier).setIndex(index);
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('Home FAB keeps the settings gear', (tester) async {
    await pumpAtTab(tester, 0);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byType(CrossedSwordsIcon), findsNothing);
  });

  testWidgets('Settings FAB shows crossed swords, not a back arrow',
      (tester) async {
    await pumpAtTab(tester, 4);
    expect(find.byType(CrossedSwordsIcon), findsOneWidget);
    expect(
        find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
  });
}