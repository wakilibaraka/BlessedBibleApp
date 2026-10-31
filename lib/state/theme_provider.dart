import 'dart:math';

import '../theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_storage/preferences_service.dart';

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

/// Picks the theme shown while the user is on [AppThemeMode.automatic]
/// ("Daily rotation").
///
/// The rule is deliberately simple so it is predictable:
/// * one theme per local calendar day (it changes at the user's midnight,
///   not at midnight UTC), and
/// * the pool follows the phone's light/dark setting, so a phone in dark
///   mode only ever rotates through dark themes and vice versa.
class AutoTheme {
  AutoTheme._();

  static const lightCycle = [
    AppThemeMode.light,
    AppThemeMode.sepia,
    AppThemeMode.lilies,
    AppThemeMode.roses,
    AppThemeMode.olives,
    AppThemeMode.priestlyPurple,
    AppThemeMode.galileeBlue,
    AppThemeMode.scarletRed,
  ];

  static const darkCycle = [
    AppThemeMode.dusk,
    AppThemeMode.dawn,
    AppThemeMode.fresh,
    AppThemeMode.dark,
  ];

  /// Days since 1970-01-01 for the *local* date of [time].
  static int dayNumber(DateTime time) {
    final local = time.toLocal();
    return DateTime.utc(local.year, local.month, local.day)
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  static AppThemeMode pick(int day, Brightness brightness) {
    final cycle = brightness == Brightness.dark ? darkCycle : lightCycle;
    return cycle[day % cycle.length];
  }

  /// What [resolve] uses when no provider is at hand. Kept in step with
  /// [autoThemeInputsProvider] so both always agree on today's theme.
  static AutoThemeInputs latest = AutoThemeInputs.now();
}

/// The two things the daily rotation depends on.
@immutable
class AutoThemeInputs {
  final int day;
  final Brightness brightness;

  const AutoThemeInputs({required this.day, required this.brightness});

  factory AutoThemeInputs.now() => AutoThemeInputs(
        day: AutoTheme.dayNumber(DateTime.now()),
        brightness:
            WidgetsBinding.instance.platformDispatcher.platformBrightness,
      );

  @override
  bool operator ==(Object other) =>
      other is AutoThemeInputs &&
      other.day == day &&
      other.brightness == brightness;

  @override
  int get hashCode => Object.hash(day, brightness);
}

/// Tracks the day and the phone's light/dark setting for the daily rotation.
///
/// A light/dark switch on the phone applies straight away. The day only moves
/// on when the app comes back to the foreground, so the theme never changes
/// under someone who is reading across midnight.
class AutoThemeInputsNotifier extends Notifier<AutoThemeInputs>
    with WidgetsBindingObserver {
  @override
  AutoThemeInputs build() {
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    ref.onDispose(() => binding.removeObserver(this));
    return _publish(AutoThemeInputs.now());
  }

  AutoThemeInputs _publish(AutoThemeInputs inputs) {
    AutoTheme.latest = inputs;
    return inputs;
  }

  @override
  void didChangePlatformBrightness() {
    state = _publish(AutoThemeInputs(
      day: state.day,
      brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      this.state = _publish(AutoThemeInputs.now());
    }
  }
}

final autoThemeInputsProvider =
    NotifierProvider<AutoThemeInputsNotifier, AutoThemeInputs>(
        AutoThemeInputsNotifier.new);

/// The theme actually on screen: the user's pick, or today's theme from the
/// daily rotation. Anything that draws with theme colours should watch this
/// rather than [themeProvider], which is the user's *choice* (and may be
/// [AppThemeMode.automatic]).
final resolvedThemeProvider = Provider<AppThemeMode>((ref) {
  final mode = ref.watch(themeProvider);
  if (mode != AppThemeMode.automatic) return mode;
  final inputs = ref.watch(autoThemeInputsProvider);
  return AutoTheme.pick(inputs.day, inputs.brightness);
});

extension AppThemeModeExtension on AppThemeMode {
  /// Today's theme for [AppThemeMode.automatic], otherwise this mode.
  /// Prefer watching [resolvedThemeProvider], which also rebuilds when the
  /// phone switches between light and dark.
  AppThemeMode resolve([BuildContext? context]) {
    if (this != AppThemeMode.automatic) return this;
    final inputs = AutoTheme.latest;
    final brightness = (context == null
            ? null
            : MediaQuery.maybePlatformBrightnessOf(context)) ??
        inputs.brightness;
    return AutoTheme.pick(inputs.day, brightness);
  }

  /// Whether this theme is drawn on a dark background.
  bool get isDark {
    switch (resolve()) {
      case AppThemeMode.dark:
      case AppThemeMode.oled:
      case AppThemeMode.dawn:
      case AppThemeMode.dusk:
      case AppThemeMode.fresh:
        return true;
      default:
        return false;
    }
  }

  bool get isFirmamentTheme {
    final mode = resolve();
    return mode == AppThemeMode.dawn ||
        mode == AppThemeMode.fresh ||
        mode == AppThemeMode.dusk;
  }

  bool get isSanctuaryTheme {
    final mode = resolve();
    return mode == AppThemeMode.priestlyPurple ||
        mode == AppThemeMode.galileeBlue ||
        mode == AppThemeMode.scarletRed;
  }

  String get subGreeting {
    switch (resolve()) {
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
    final mode = resolve();
    return mode == AppThemeMode.dawn ||
        mode == AppThemeMode.lilies ||
        mode == AppThemeMode.roses ||
        mode == AppThemeMode.olives ||
        mode == AppThemeMode.dusk ||
        mode == AppThemeMode.fresh;
  }

  Color get backgroundColor {
    switch (resolve()) {
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
    switch (resolve()) {
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
    switch (resolve()) {
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
  static const _migratedKey = 'engine_migrated_v3';

  @override
  AppThemeMode build() {
    // Preferences are loaded before runApp, so the saved theme is known on
    // the very first frame. Reading it later (async) painted one frame in
    // the default theme and then animated to the saved one on every launch.
    final SharedPreferences prefs;
    try {
      prefs = ref.read(preferencesProvider).prefs;
    } catch (_) {
      // No preferences in this scope (some tests): load them async.
      _loadAsync();
      return AppThemeMode.automatic;
    }
    return _readSaved(prefs);
  }

  Future<void> _loadAsync() async {
    final prefs = await SharedPreferences.getInstance();
    state = _readSaved(prefs);
  }

  static AppThemeMode _readSaved(SharedPreferences prefs) {
    // Migration from the old time-based engine: it becomes Daily rotation.
    if (!(prefs.getBool(_migratedKey) ?? false)) {
      if (prefs.getInt(_engineModeKey) == 1) {
        prefs.setInt(_themeKey, AppThemeMode.automatic.index);
      }
      prefs.setBool(_migratedKey, true);
    }

    final saved = prefs.getInt(_themeKey) ?? prefs.getInt(_lockedThemeKey);
    if (saved != null && saved >= 0 && saved < AppThemeMode.values.length) {
      return AppThemeMode.values[saved];
    }
    // Default: Daily rotation.
    return AppThemeMode.automatic;
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
