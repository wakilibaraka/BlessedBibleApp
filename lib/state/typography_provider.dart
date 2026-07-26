import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TypographyState {
  final String fontFamily;
  final double fontSize;

  const TypographyState({
    this.fontFamily = 'Lexend',
    this.fontSize = 18.0,
  });

  TypographyState copyWith({
    String? fontFamily,
    double? fontSize,
  }) {
    return TypographyState(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class TypographyNotifier extends Notifier<TypographyState> {
  static const _fontFamilyKey = 'typography_font_family';
  static const _fontSizeKey = 'typography_font_size';

  @override
  TypographyState build() {
    _loadSettings();
    return const TypographyState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final family = prefs.getString(_fontFamilyKey);
    final size = prefs.getDouble(_fontSizeKey);

    if (family != null || size != null) {
      state = state.copyWith(
        fontFamily: family,
        fontSize: size,
      );
    }
  }

  Future<void> setFontFamily(String family) async {
    state = state.copyWith(fontFamily: family);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, family);
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }
}

final typographyProvider = NotifierProvider<TypographyNotifier, TypographyState>(TypographyNotifier.new);
