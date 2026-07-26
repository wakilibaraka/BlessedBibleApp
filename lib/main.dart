import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/theme_provider.dart';
import 'state/typography_provider.dart';
import 'theme/app_theme.dart';
import 'ui/screens/main_nav_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'data/local_storage/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
      child: const TheBlessedBibleApp(),
    ),
  );
}

class TheBlessedBibleApp extends ConsumerWidget {
  const TheBlessedBibleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final typography = ref.watch(typographyProvider);

    return MaterialApp(
      title: 'The Blessed Bible',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: const Duration(milliseconds: 250),
      themeAnimationCurve: Curves.easeInOut,
      themeMode: switch (themeMode) {
        AppThemeMode.automatic => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.sepia => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      theme: themeMode == AppThemeMode.sepia 
          ? AppTheme.sepiaTheme(typography.fontSize, typography.fontFamily)
          : AppTheme.lightTheme(typography.fontSize, typography.fontFamily),
      darkTheme: AppTheme.darkTheme(typography.fontSize, typography.fontFamily),
      home: const MainNavScreen(),
    );
  }
}
