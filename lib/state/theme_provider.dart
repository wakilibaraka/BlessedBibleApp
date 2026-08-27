import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  automatic,
  light,
  dark,
  sepia,
  oled,
  dawn,
  dusk,
  fresh,
  lilies,
  roses,
  olives,
  priestlyPurple,
  galileeBlue,
  scarletRed
}

extension AppThemeModeExtension on AppThemeMode {
  AppThemeMode resolve(BuildContext context) {
    if (this == AppThemeMode.automatic) {
      final days = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
      const cycle = [
        AppThemeMode.light, AppThemeMode.sepia, AppThemeMode.dawn, 
        AppThemeMode.fresh, AppThemeMode.lilies, AppThemeMode.roses, 
        AppThemeMode.olives, AppThemeMode.dusk, AppThemeMode.priestlyPurple, 
        AppThemeMode.galileeBlue, AppThemeMode.scarletRed
      ];
      return cycle[days % cycle.length];
    }
    return this;
  }
}

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _themeKey = 'app_theme_mode';
  static const _lockedThemeKey = 'theme_locked_mode'; // Legacy fallback
  static const _engineModeKey = 'theme_engine_mode'; // Legacy migration

  @override
  AppThemeMode build() {
    _loadTheme();
    return AppThemeMode.automatic;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Migration from old Time-Based engine
    final migrated = prefs.getBool('engine_migrated_v3') ?? false;
    if (!migrated) {
      final engineMode = prefs.getInt(_engineModeKey);
      if (engineMode == 1) { // 1 was ThemeEngineMode.timeBased
        await prefs.setInt(_themeKey, AppThemeMode.automatic.index);
      }
      await prefs.setBool('engine_migrated_v3', true);
    }

    final saved = prefs.getInt(_themeKey) ?? prefs.getInt(_lockedThemeKey);
    if (saved != null && saved >= 0 && saved < AppThemeMode.values.length) {
      state = AppThemeMode.values[saved];
    } else {
      state = AppThemeMode.automatic;
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    await prefs.setInt(_lockedThemeKey, mode.index); // Keep updated for backwards safety if ever downgraded
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
