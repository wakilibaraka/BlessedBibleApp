import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';

enum EarthHeavenStyle {
  earth,
  heaven,
  paperlike,
  claymorphic,
}

enum SurfaceStyle {
  flat,
  frosted,
  threeDimensional,
  paperlike,
  claymorphic,
  frutigerAero,
  skeuomorphic
}

// Earth is now uniformly flat for ALL 14 themes.
// SurfaceStyle.frosted is currently unrouted, kept in codebase per request.
SurfaceStyle resolveEarthSurface(AppThemeMode theme) => SurfaceStyle.flat;

class EarthHeavenStyleNotifier extends Notifier<EarthHeavenStyle> {
  static const _surfaceStyleKey = 'app_surface_style';
  static const _migrationKey = 'surface_migrated_v3';

  @override
  EarthHeavenStyle build() {
    _loadState();
    return EarthHeavenStyle.earth;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Fresh install: deal a random surface so day one feels personal.
    // Runs once — the pick is persisted like any manual choice.
    if (prefs.getInt(_surfaceStyleKey) == null &&
        !(prefs.getBool(_migrationKey) ?? false)) {
      final pick = EarthHeavenStyle
          .values[Random().nextInt(EarthHeavenStyle.values.length)];
      state = pick;
      await prefs.setInt(_surfaceStyleKey, pick.index);
      await prefs.setBool(_migrationKey, true);
      return;
    }

    final migrated = prefs.getBool(_migrationKey) ?? false;
    if (!migrated) {
      final savedIndex = prefs.getInt(_surfaceStyleKey);
      if (savedIndex != null &&
          savedIndex >= 0 &&
          savedIndex < EarthHeavenStyle.values.length) {
        state = EarthHeavenStyle.values[savedIndex];
      } else {
        // Fallback for previous Aero (4) or Physical (5) to Earth
        state = EarthHeavenStyle.earth;
      }
      await prefs.setBool(_migrationKey, true);
    } else {
      final savedIndex = prefs.getInt(_surfaceStyleKey);
      if (savedIndex != null &&
          savedIndex >= 0 &&
          savedIndex < EarthHeavenStyle.values.length) {
        state = EarthHeavenStyle.values[savedIndex];
      } else {
        state = EarthHeavenStyle.earth;
      }
    }
  }

  Future<void> setStyle(EarthHeavenStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_surfaceStyleKey, style.index);
  }

  /// Surprise me: random surface (different from current), persisted.
  Future<EarthHeavenStyle> shuffleStyle() async {
    final pool = EarthHeavenStyle.values.where((s) => s != state).toList();
    final pick = pool.isEmpty ? state : pool[Random().nextInt(pool.length)];
    await setStyle(pick);
    return pick;
  }
}

final earthHeavenStyleProvider =
    NotifierProvider<EarthHeavenStyleNotifier, EarthHeavenStyle>(
        EarthHeavenStyleNotifier.new);

final surfaceStyleProvider = Provider<SurfaceStyle>((ref) {
  final eh = ref.watch(earthHeavenStyleProvider);
  if (eh == EarthHeavenStyle.heaven) {
    return SurfaceStyle.threeDimensional;
  }
  if (eh == EarthHeavenStyle.paperlike) {
    final theme = ref.watch(themeProvider);
    final resolved = theme.resolve();
    if (resolved.isFirmamentTheme) {
      return SurfaceStyle.skeuomorphic;
    }
    if (resolved.isSanctuaryTheme) {
      return SurfaceStyle.frutigerAero;
    }
    return SurfaceStyle.paperlike;
  }
  if (eh == EarthHeavenStyle.claymorphic) {
    return SurfaceStyle.claymorphic;
  }
  final theme = ref.watch(themeProvider);
  return resolveEarthSurface(theme);
});
