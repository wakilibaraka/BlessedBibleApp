import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TypographyState {
  final String fontFamily;
  final double fontSize;
  final double lineHeight;

  const TypographyState({
    this.fontFamily = 'Lexend',
    this.fontSize = 18.0,
    this.lineHeight = 1.5,
  });

  TypographyState copyWith({
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
  }) {
    return TypographyState(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}

class TypographyNotifier extends Notifier<TypographyState> {
  static const _fontFamilyKey = 'typography_font_family';
  static const _fontSizeKey = 'typography_font_size';
  static const _lineHeightKey = 'typography_line_height';

  @override
  TypographyState build() {
    _loadSettings();
    return const TypographyState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final family = prefs.getString(_fontFamilyKey);
    final size = prefs.getDouble(_fontSizeKey);
    final height = prefs.getDouble(_lineHeightKey);

    if (family != null || size != null || height != null) {
      state = state.copyWith(
        fontFamily: family,
        fontSize: size,
        lineHeight: height,
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

  Future<void> setLineHeight(double height) async {
    state = state.copyWith(lineHeight: height);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineHeightKey, height);
  }
}

final typographyProvider = NotifierProvider<TypographyNotifier, TypographyState>(TypographyNotifier.new);
