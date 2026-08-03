import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';

enum EarthHeavenStyle { earth, heaven }

enum SurfaceStyle { flat, frosted, threeDimensional }

const Map<AppThemeMode, SurfaceStyle> _kEarthSurfaceMap = {
  AppThemeMode.dawn: SurfaceStyle.flat,
  AppThemeMode.fresh: SurfaceStyle.flat,
};

SurfaceStyle resolveEarthSurface(AppThemeMode theme) =>
    _kEarthSurfaceMap[theme] ?? SurfaceStyle.frosted;

class EarthHeavenStyleNotifier extends Notifier<EarthHeavenStyle> {
  static const _surfaceStyleKey = 'app_surface_style';
  static const _migrationKey = 'surface_migrated_v1';

  @override
  EarthHeavenStyle build() {
    _loadState();
    return EarthHeavenStyle.heaven;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    final migrated = prefs.getBool(_migrationKey) ?? false;
    if (!migrated) {
      final savedIndex = prefs.getInt(_surfaceStyleKey);
      if (savedIndex == 2) {
        state = EarthHeavenStyle.heaven;
      } else if (savedIndex == 0 || savedIndex == 1) {
        state = EarthHeavenStyle.earth;
      }
      await prefs.setBool(_migrationKey, true);
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
  final theme = ref.watch(themeProvider);
  return resolveEarthSurface(theme);
});
