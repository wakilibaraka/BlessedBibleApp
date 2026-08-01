import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { automatic, light, dark, sepia, oled, dawn, dusk, fresh, lilies, roses, olives, priestlyPurple, galileeBlue, scarletRed }

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

const List<AppThemeMode> kDefaultRotationPool = [
  AppThemeMode.dawn,
  AppThemeMode.fresh,
  AppThemeMode.dusk,
  AppThemeMode.lilies,
  AppThemeMode.roses,
  AppThemeMode.olives,
  AppThemeMode.priestlyPurple,
  AppThemeMode.galileeBlue,
  AppThemeMode.scarletRed,
];

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _themeKey = 'app_theme_mode';
  static const _isSingleThemeKey = 'theme_is_single';
  static const _isMatchSystemKey = 'theme_is_match_system';
  static const _lockedThemeKey = 'theme_locked_mode';
  static const _rotationPoolKey = 'theme_rotation_pool_v2';

  bool _isSingleTheme = false;
  bool _isMatchSystem = false;
  AppThemeMode _lockedTheme = AppThemeMode.sepia;
  List<AppThemeMode> _rotationPool = List.from(kDefaultRotationPool);

  bool get isSingleTheme => _isSingleTheme;
  bool get isMatchSystem => _isMatchSystem;
  AppThemeMode get lockedTheme => _lockedTheme;
  List<AppThemeMode> get rotationPool => List.unmodifiable(_rotationPool);

  @override
  AppThemeMode build() {
    _loadTheme();
    return AppThemeMode.sepia;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isMatchSystem = prefs.getBool(_isMatchSystemKey) ?? false;
    _isSingleTheme = prefs.getBool(_isSingleThemeKey) ?? false;

    final lockedIndex = prefs.getInt(_lockedThemeKey);
    if (lockedIndex != null && lockedIndex >= 0 && lockedIndex < AppThemeMode.values.length) {
      _lockedTheme = AppThemeMode.values[lockedIndex];
    }

    final savedPool = prefs.getStringList(_rotationPoolKey);
    if (savedPool != null && savedPool.isNotEmpty) {
      final loadedPool = <AppThemeMode>[];
      for (final name in savedPool) {
        try {
          final mode = AppThemeMode.values.firstWhere((e) => e.name == name);
          loadedPool.add(mode);
        } catch (_) {}
      }
      if (loadedPool.isNotEmpty) {
        _rotationPool = loadedPool;
      }
    }

    // Migration logic for old theme key
    final oldIndex = prefs.getInt(_themeKey);
    if (oldIndex != null && oldIndex >= 0 && oldIndex < AppThemeMode.values.length) {
      final oldMode = AppThemeMode.values[oldIndex];
      if (oldMode == AppThemeMode.automatic) {
        _isMatchSystem = true;
      } else {
        _lockedTheme = oldMode;
      }
    }

    _updateState();
  }

  AppThemeMode getTodayRotationTheme() {
    if (_rotationPool.isEmpty) {
      return AppThemeMode.sepia;
    }
    final now = DateTime.now();
    final dayNumber = now.year * 366 + now.month * 31 + now.day;
    final index = dayNumber % _rotationPool.length;
    return _rotationPool[index];
  }

  void _updateState() {
    if (_isMatchSystem) {
      state = AppThemeMode.automatic;
    } else if (_isSingleTheme) {
      state = _lockedTheme;
    } else {
      state = getTodayRotationTheme();
    }
  }

  Future<void> setMatchSystem(bool enabled) async {
    _isMatchSystem = enabled;
    if (enabled) {
      _isSingleTheme = false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isMatchSystemKey, enabled);
    await prefs.setBool(_isSingleThemeKey, _isSingleTheme);
    _updateState();
  }

  Future<void> setSingleTheme(bool enabled) async {
    _isSingleTheme = enabled;
    if (enabled) {
      _isMatchSystem = false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSingleThemeKey, enabled);
    await prefs.setBool(_isMatchSystemKey, _isMatchSystem);
    _updateState();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    if (mode == AppThemeMode.automatic) {
      await setMatchSystem(true);
      return;
    }

    // Tapping a theme pill locks Single Theme mode ON
    _isMatchSystem = false;
    _isSingleTheme = true;
    _lockedTheme = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isMatchSystemKey, false);
    await prefs.setBool(_isSingleThemeKey, true);
    await prefs.setInt(_lockedThemeKey, mode.index);
    await prefs.setInt(_themeKey, mode.index);

    _updateState();
  }

  Future<void> toggleThemeInPool(AppThemeMode mode) async {
    if (_rotationPool.contains(mode)) {
      if (_rotationPool.length > 1) {
        _rotationPool.remove(mode);
      }
    } else {
      _rotationPool.add(mode);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_rotationPoolKey, _rotationPool.map((e) => e.name).toList());
    _updateState();
  }

  bool isThemeInPool(AppThemeMode mode) {
    return _rotationPool.contains(mode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);

final isSingleThemeProvider = Provider<bool>((ref) {
  ref.watch(themeProvider);
  return ref.read(themeProvider.notifier).isSingleTheme;
});

final isMatchSystemProvider = Provider<bool>((ref) {
  ref.watch(themeProvider);
  return ref.read(themeProvider.notifier).isMatchSystem;
});

final rotationPoolProvider = Provider<List<AppThemeMode>>((ref) {
  ref.watch(themeProvider);
  return ref.read(themeProvider.notifier).rotationPool;
});
