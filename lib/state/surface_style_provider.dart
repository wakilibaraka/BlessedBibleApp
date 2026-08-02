import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SurfaceStyle { flat, frosted, threeDimensional }

class SurfaceStyleNotifier extends Notifier<SurfaceStyle> {
  static const _surfaceStyleKey = 'app_surface_style';

  @override
  SurfaceStyle build() {
    _loadState();
    return SurfaceStyle.frosted;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_surfaceStyleKey);
    if (savedIndex != null && savedIndex >= 0 && savedIndex < SurfaceStyle.values.length) {
      state = SurfaceStyle.values[savedIndex];
    }
  }

  Future<void> setStyle(SurfaceStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_surfaceStyleKey, style.index);
  }
}

final surfaceStyleProvider = NotifierProvider<SurfaceStyleNotifier, SurfaceStyle>(SurfaceStyleNotifier.new);
