import 'dart:async';
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
      return Theme.of(context).brightness == Brightness.dark
          ? AppThemeMode.dark
          : AppThemeMode.light;
    }
    return this;
  }
}

enum ThemeEngineMode { locked, timeBased }

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _themeKey = 'app_theme_mode';
  static const _lockedThemeKey = 'theme_locked_mode';
  static const _engineModeKey = 'theme_engine_mode';
  static const _engineMigratedKey = 'engine_migrated_v1';
  static const _isSingleThemeKey = 'theme_is_single';
  static const _isMatchSystemKey = 'theme_is_match_system';

  ThemeEngineMode _engineMode = ThemeEngineMode.locked;
  AppThemeMode _lockedTheme = AppThemeMode.sepia;
  Timer? _timeWatcher;

  ThemeEngineMode get engineMode => _engineMode;
  AppThemeMode get lockedTheme => _lockedTheme;

  @override
  AppThemeMode build() {
    _loadTheme();

    ref.onDispose(() {
      _timeWatcher?.cancel();
    });

    return AppThemeMode.sepia;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final lockedIndex = prefs.getInt(_lockedThemeKey);
    if (lockedIndex != null &&
        lockedIndex >= 0 &&
        lockedIndex < AppThemeMode.values.length) {
      _lockedTheme = AppThemeMode.values[lockedIndex];
    } else {
      final oldIndex = prefs.getInt(_themeKey);
      if (oldIndex != null &&
          oldIndex >= 0 &&
          oldIndex < AppThemeMode.values.length) {
        _lockedTheme = AppThemeMode.values[oldIndex];
      }
    }

    final migrated = prefs.getBool(_engineMigratedKey) ?? false;
    if (!migrated) {
      final isSingle = prefs.getBool(_isSingleThemeKey) ?? false;
      final isMatchSystem = prefs.getBool(_isMatchSystemKey) ?? false;
      if (isSingle || isMatchSystem) {
        _engineMode = ThemeEngineMode.locked;
      } else {
        _engineMode = ThemeEngineMode.timeBased;
      }
      await prefs.setBool(_engineMigratedKey, true);
      await prefs.setInt(_engineModeKey, _engineMode.index);
    } else {
      final savedEngine = prefs.getInt(_engineModeKey);
      if (savedEngine != null &&
          savedEngine >= 0 &&
          savedEngine < ThemeEngineMode.values.length) {
        _engineMode = ThemeEngineMode.values[savedEngine];
      }
    }

    _updateState();
    _updateTimer();
  }

  void _updateTimer() {
    if (_engineMode == ThemeEngineMode.timeBased) {
      if (_timeWatcher == null || !_timeWatcher!.isActive) {
        _timeWatcher = Timer.periodic(const Duration(minutes: 1), (_) {
          _updateState();
        });
      }
    } else {
      _timeWatcher?.cancel();
      _timeWatcher = null;
    }
  }

  AppThemeMode _getTimeBasedTheme() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) {
      return AppThemeMode.light;
    } else if (hour >= 10 && hour < 17) {
      return AppThemeMode.sepia;
    } else if (hour >= 17 && hour < 21) {
      return AppThemeMode.dark;
    } else {
      return AppThemeMode.oled;
    }
  }

  void _updateState() {
    if (_engineMode == ThemeEngineMode.locked) {
      if (state != _lockedTheme) {
        state = _lockedTheme;
      }
    } else {
      final timeTheme = _getTimeBasedTheme();
      if (state != timeTheme) {
        state = timeTheme;
      }
    }
  }

  Future<void> setEngineMode(ThemeEngineMode mode) async {
    _engineMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_engineModeKey, mode.index);
    _updateState();
    _updateTimer();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _engineMode = ThemeEngineMode.locked;
    _lockedTheme = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_engineModeKey, ThemeEngineMode.locked.index);
    await prefs.setInt(_lockedThemeKey, mode.index);
    await prefs.setInt(_themeKey, mode.index);

    _updateState();
    _updateTimer();
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);

final engineModeProvider = Provider<ThemeEngineMode>((ref) {
  ref.watch(themeProvider);
  return ref.read(themeProvider.notifier).engineMode;
});

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
