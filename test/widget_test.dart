// App smoke test: boots the real navigation shell with mocked prefs and
// verifies the four main tabs render. Mirrors the harness in
// page_transition_test.dart (preferencesProvider must be overridden — it
// throws UnimplementedError by default).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/main_nav_screen.dart';

void main() {
  testWidgets('Main nav renders all four tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(1.0),
        home: const MainNavScreen(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Read'), findsWidgets);
    expect(find.text('Study'), findsWidgets);
    expect(find.text('Search'), findsWidgets);

    await tester.pump(const Duration(seconds: 1));
  });
}
