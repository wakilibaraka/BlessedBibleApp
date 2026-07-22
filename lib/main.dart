import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/theme_provider.dart';
import 'theme/app_theme.dart';
import 'ui/screens/main_nav_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TheBlessedBibleApp(),
    ),
  );
}

class TheBlessedBibleApp extends ConsumerWidget {
  const TheBlessedBibleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'The Blessed Bible',
      debugShowCheckedModeBanner: false,
      themeMode: switch (themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.sepia => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      theme: themeMode == AppThemeMode.sepia 
          ? AppTheme.sepiaTheme 
          : AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainNavScreen(),
    );
  }
}
