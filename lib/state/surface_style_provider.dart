import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';

enum EarthHeavenStyle { 
  earth, 
  heaven, 
  paperlike, 
  neumorphic, 
  claymorphic, 
  frutigerAero, 
  skeuomorphic 
}

enum SurfaceStyle { 
  flat, 
  frosted, 
  threeDimensional, 
  paperlike, 
  neumorphic, 
  claymorphic, 
  frutigerAero, 
  skeuomorphic 
}

// Earth is now uniformly flat for ALL 14 themes.
// SurfaceStyle.frosted is currently unrouted, kept in codebase per request.
SurfaceStyle resolveEarthSurface(AppThemeMode theme) => SurfaceStyle.flat;

class EarthHeavenStyleNotifier extends Notifier<EarthHeavenStyle> {
  static const _surfaceStyleKey = 'app_surface_style';
  static const _migrationKey = 'surface_migrated_v2';

  @override
  EarthHeavenStyle build() {
    _loadState();
    return EarthHeavenStyle.earth;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    final migrated = prefs.getBool(_migrationKey) ?? false;
    if (!migrated) {
      final savedIndex = prefs.getInt(_surfaceStyleKey);
      if (savedIndex == 2) {
        state = EarthHeavenStyle.paperlike;
      } else if (savedIndex == 1) {
        state = EarthHeavenStyle.heaven;
      } else if (savedIndex == 0) {
        state = EarthHeavenStyle.earth;
      }
      // Migrate v1 logic if it hasn't run either.
      final migratedV1 = prefs.getBool('surface_migrated_v1') ?? false;
      if (!migratedV1 && savedIndex == 2 && state != EarthHeavenStyle.paperlike) {
         state = EarthHeavenStyle.heaven;
      }
      await prefs.setBool(_migrationKey, true);
      await prefs.setBool('surface_migrated_v1', true);
    } else {
      final savedIndex = prefs.getInt(_surfaceStyleKey);
      if (savedIndex != null &&
          savedIndex >= 0 &&
          savedIndex < EarthHeavenStyle.values.length) {
        state = EarthHeavenStyle.values[savedIndex];
      }
    }
  }

  Future<void> setStyle(EarthHeavenStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_surfaceStyleKey, style.index);
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
    return SurfaceStyle.paperlike;
  }
  if (eh == EarthHeavenStyle.neumorphic) {
    return SurfaceStyle.neumorphic;
  }
  if (eh == EarthHeavenStyle.claymorphic) {
    return SurfaceStyle.claymorphic;
  }
  if (eh == EarthHeavenStyle.frutigerAero) {
    return SurfaceStyle.frutigerAero;
  }
  if (eh == EarthHeavenStyle.skeuomorphic) {
    return SurfaceStyle.skeuomorphic;
  }
  final theme = ref.watch(themeProvider);
  return resolveEarthSurface(theme);
});
