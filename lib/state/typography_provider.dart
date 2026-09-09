import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TextAlignMode { left, center, right, justified }

class TypographyState {
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final double marginPercent;
  final TextAlignMode textAlignMode;
  final bool italicEnabled;

  const TypographyState({
    this.fontFamily = 'Alegreya',
    this.fontSize = 18.0,
    this.lineHeight = 1.5,
    this.marginPercent = 3.0,
    this.textAlignMode = TextAlignMode.left,
    this.italicEnabled = false,
  });

  FontStyle get fontStyle => italicEnabled ? FontStyle.italic : FontStyle.normal;

  TypographyState copyWith({
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    double? marginPercent,
    TextAlignMode? textAlignMode,
    bool? italicEnabled,
  }) {
    return TypographyState(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      marginPercent: marginPercent ?? this.marginPercent,
      textAlignMode: textAlignMode ?? this.textAlignMode,
      italicEnabled: italicEnabled ?? this.italicEnabled,
    );
  }
}

class TypographyNotifier extends Notifier<TypographyState> {
  static const _fontFamilyKey = 'typography_font_family';
  static const _fontSizeKey = 'typography_font_size';
  static const _lineHeightKey = 'typography_line_height';
  static const _marginModeKey = 'typography_margin_mode';
  static const _textAlignModeKey = 'typography_text_align_mode';
  static const _italicEnabledKey = 'typography_italic_enabled';

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
    final isItalic = prefs.getBool(_italicEnabledKey);

    // Migrate margin from old String enum representation if it exists
    double? marginPercent;
    if (prefs.containsKey(_marginModeKey)) {
      final marginValue = prefs.get(_marginModeKey);
      if (marginValue is String) {
        if (marginValue == 'narrow') {
          marginPercent = 4.0;
        } else if (marginValue == 'standard') {
          marginPercent = 8.0;
        } else if (marginValue == 'wide') {
          marginPercent = 16.0;
        } else {
          marginPercent = double.tryParse(marginValue);
        }
      } else if (marginValue is double) {
        marginPercent = marginValue;
      } else if (marginValue is int) {
        marginPercent = marginValue.toDouble();
      }
    }

    final alignStr = prefs.getString(_textAlignModeKey);
    final textAlignMode = alignStr != null
        ? TextAlignMode.values.firstWhere((e) => e.name == alignStr,
            orElse: () => TextAlignMode.left)
        : TextAlignMode.left;

    if (family != null ||
        size != null ||
        height != null ||
        marginPercent != null ||
        alignStr != null ||
        isItalic != null) {
      state = state.copyWith(
        fontFamily: family,
        fontSize: size,
        lineHeight: height,
        marginPercent: marginPercent,
        textAlignMode: textAlignMode,
        italicEnabled: isItalic,
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

  Future<void> setMarginPercent(double percent) async {
    state = state.copyWith(marginPercent: percent);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_marginModeKey, percent);
  }

  Future<void> setTextAlignMode(TextAlignMode mode) async {
    state = state.copyWith(textAlignMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_textAlignModeKey, mode.name);
  }

  Future<void> setItalicEnabled(bool enabled) async {
    state = state.copyWith(italicEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_italicEnabledKey, enabled);
  }
}

final typographyProvider =
    NotifierProvider<TypographyNotifier, TypographyState>(
        TypographyNotifier.new);
