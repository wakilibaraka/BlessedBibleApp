import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_storage/preferences_service.dart';
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
    // Read synchronously when preferences are already loaded (they are
    // before runApp), so the first frame already has the saved surface
    // instead of flashing Earth and then switching.
    final SharedPreferences prefs;
    try {
      prefs = ref.read(preferencesProvider).prefs;
    } catch (_) {
      _loadAsync();
      return EarthHeavenStyle.earth;
    }
    return _readSaved(prefs);
  }

  Future<void> _loadAsync() async {
    final prefs = await SharedPreferences.getInstance();
    state = _readSaved(prefs);
  }

  static EarthHeavenStyle _readSaved(SharedPreferences prefs) {
    // Fresh install: deal a random surface so day one feels personal.
    // Runs once — the pick is persisted like any manual choice.
    if (prefs.getInt(_surfaceStyleKey) == null &&
        !(prefs.getBool(_migrationKey) ?? false)) {
      final pick = EarthHeavenStyle
          .values[Random().nextInt(EarthHeavenStyle.values.length)];
      prefs.setInt(_surfaceStyleKey, pick.index);
      prefs.setBool(_migrationKey, true);
      return pick;
    }

    if (!(prefs.getBool(_migrationKey) ?? false)) {
      prefs.setBool(_migrationKey, true);
    }
    final savedIndex = prefs.getInt(_surfaceStyleKey);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < EarthHeavenStyle.values.length) {
      return EarthHeavenStyle.values[savedIndex];
    }
    // Fallback for previous Aero (4) or Physical (5) to Earth
    return EarthHeavenStyle.earth;
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
    final resolved = ref.watch(resolvedThemeProvider);
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
  return resolveEarthSurface(ref.watch(resolvedThemeProvider));
});
