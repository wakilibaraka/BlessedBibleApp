import 'dart:math';

import '../theme/app_colors.dart';
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
  AppThemeMode resolve([BuildContext? context]) {
    if (this == AppThemeMode.automatic) {
      final days = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
      const cycle = [
        AppThemeMode.light,
        AppThemeMode.sepia,
        AppThemeMode.dawn,
        AppThemeMode.fresh,
        AppThemeMode.lilies,
        AppThemeMode.roses,
        AppThemeMode.olives,
        AppThemeMode.dusk,
        AppThemeMode.priestlyPurple,
        AppThemeMode.galileeBlue,
        AppThemeMode.scarletRed
      ];
      return cycle[days % cycle.length];
    }
    return this;
  }

  bool get isFirmamentTheme {
    return this == AppThemeMode.dawn ||
        this == AppThemeMode.fresh ||
        this == AppThemeMode.dusk;
  }

  bool get isSanctuaryTheme {
    return this == AppThemeMode.priestlyPurple ||
        this == AppThemeMode.galileeBlue ||
        this == AppThemeMode.scarletRed;
  }

  String get subGreeting {
    switch (this) {
      case AppThemeMode.dark:
      case AppThemeMode.oled:
      case AppThemeMode.dusk:
      case AppThemeMode.automatic:
        return "Rest in the peace of His promises.";
      case AppThemeMode.sepia:
        return "Reflect on the ancient wisdom.";
      default:
        return "Embrace the light of His word.";
    }
  }

  bool get is3DTheme {
    return this == AppThemeMode.dawn ||
        this == AppThemeMode.lilies ||
        this == AppThemeMode.roses ||
        this == AppThemeMode.olives ||
        this == AppThemeMode.dusk ||
        this == AppThemeMode.fresh;
  }

  Color get backgroundColor {
    switch (this) {
      case AppThemeMode.dawn:
        return AppColors.dawnBackground;
      case AppThemeMode.lilies:
        return AppColors.liliesBackground;
      case AppThemeMode.roses:
        return AppColors.rosesBackground;
      case AppThemeMode.olives:
        return AppColors.olivesBackground;
      case AppThemeMode.dusk:
        return const Color(0xFF312C51);
      case AppThemeMode.fresh:
        return const Color(0xFF132C33);
      default:
        return Colors
            .transparent; // callers will coalesce with theme.scaffoldBackgroundColor
    }
  }

  Color get redLetterColor {
    switch (this) {
      case AppThemeMode.dark:
      case AppThemeMode.oled:
      case AppThemeMode.dusk:
      case AppThemeMode.automatic:
        return const Color(0xFFD46A6A);
      case AppThemeMode.sepia:
        return const Color(0xFFA63C3C);
      default:
        return const Color(0xFFB33A3A);
    }
  }

  Color get starColor {
    switch (this) {
      case AppThemeMode.dark:
      case AppThemeMode.oled:
      case AppThemeMode.dusk:
      case AppThemeMode.automatic:
        return Colors.amber.shade400;
      case AppThemeMode.sepia:
        return Colors.orange.shade700;
      default:
        return Colors.deepOrange.shade400;
    }
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
      if (engineMode == 1) {
        // 1 was ThemeEngineMode.timeBased
        await prefs.setInt(_themeKey, AppThemeMode.automatic.index);
      }
      await prefs.setBool('engine_migrated_v3', true);
    }

    final saved = prefs.getInt(_themeKey) ?? prefs.getInt(_lockedThemeKey);
    if (saved != null && saved >= 0 && saved < AppThemeMode.values.length) {
      state = AppThemeMode.values[saved];
    } else if (prefs.getInt(_themeKey) == null &&
        prefs.getInt(_lockedThemeKey) == null) {
      // Fresh install: deal a random theme so day one feels personal.
      // Runs once — the pick is persisted like any manual choice.
      final pool = AppThemeMode.values
          .where((m) => m != AppThemeMode.automatic)
          .toList();
      final pick = pool[Random().nextInt(pool.length)];
      state = pick;
      await prefs.setInt(_themeKey, pick.index);
      await prefs.setInt(_lockedThemeKey, pick.index);
    } else {
      state = AppThemeMode.automatic;
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    await prefs.setInt(_lockedThemeKey,
        mode.index); // Keep updated for backwards safety if ever downgraded
  }

  /// Surprise me: random theme (anything but automatic), persisted.
  Future<AppThemeMode> shuffleTheme() async {
    final pool = AppThemeMode.values
        .where((m) => m != AppThemeMode.automatic && m != state)
        .toList();
    final pick = pool.isEmpty ? state : pool[Random().nextInt(pool.length)];
    await setTheme(pick);
    return pick;
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
