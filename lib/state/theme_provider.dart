import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Three distinct visual modes cycling Sepia -> Dark -> Light
enum AppThemeMode { sepia, dark, light }

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => AppThemeMode.sepia; // Default

  /// Cycle forward through all three modes.
  void cycleTheme() {
    switch (state) {
      case AppThemeMode.sepia:
        state = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        state = AppThemeMode.light;
        break;
      case AppThemeMode.light:
        state = AppThemeMode.sepia;
        break;
    }
  }

  // Keep direct setters for programmatic access.
  void setTheme(AppThemeMode mode) => state = mode;

  // Legacy toggle kept for backward compatibility (Light ↔ Dark).
  void toggleTheme() {
    state = state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);
