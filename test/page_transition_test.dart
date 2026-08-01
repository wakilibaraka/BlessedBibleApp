import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/ui/screens/main_nav_screen.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';

void main() {
  testWidgets('Page transition test', (tester) async {
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

    // Tap the 'Study' tab
    await tester.tap(find.text('Study'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });
}
