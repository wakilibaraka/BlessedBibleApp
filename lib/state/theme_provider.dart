import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

enum AppThemeMode { automatic, light, dark, sepia, oled, pop, dusk, fresh }

extension AppThemeModeExtension on AppThemeMode {
  AppThemeMode resolve(BuildContext context) {
    if (this == AppThemeMode.automatic) {
      return Theme.of(context).brightness == Brightness.dark 
          ? AppThemeMode.dark 
          : AppThemeMode.light;
    }
    return this;
  }
}

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _themeKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    _loadTheme();
    return AppThemeMode.sepia; // Default for new users
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeKey);
    if (index != null && index >= 0 && index < AppThemeMode.values.length) {
      state = AppThemeMode.values[index];
    }
    
    // Migrate old AMOLED flag
    final amoledOn = prefs.getBool('amoled_dark_mode');
    if (amoledOn != null) {
      if (amoledOn == true && (state == AppThemeMode.dark || state == AppThemeMode.automatic)) {
        state = AppThemeMode.oled;
        await prefs.setInt(_themeKey, state.index);
      }
      await prefs.remove('amoled_dark_mode');
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// Cycle forward through all modes.
  void cycleTheme() {
    switch (state) {
      case AppThemeMode.automatic:
        setTheme(AppThemeMode.light);
        break;
      case AppThemeMode.light:
        setTheme(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        setTheme(AppThemeMode.sepia);
        break;
      case AppThemeMode.sepia:
        setTheme(AppThemeMode.oled);
        break;
      case AppThemeMode.oled:
        setTheme(AppThemeMode.pop);
        break;
      case AppThemeMode.pop:
        setTheme(AppThemeMode.dusk);
        break;
      case AppThemeMode.dusk:
        setTheme(AppThemeMode.fresh);
        break;
      case AppThemeMode.fresh:
        setTheme(AppThemeMode.automatic);
        break;
    }
  }

  // Legacy toggle kept for backward compatibility.
  void toggleTheme() {
    setTheme(state == AppThemeMode.dark || state == AppThemeMode.oled ? AppThemeMode.light : AppThemeMode.dark);
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);
