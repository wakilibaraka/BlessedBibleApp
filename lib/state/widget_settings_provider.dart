import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

enum WidgetBackgroundStyle {
  gradientDusk('gradient_dusk', 'Celestial Dusk 🌌', [Color(0xFF1A102F), Color(0xFF4A154B)]),
  gradientDawn('gradient_dawn', 'Morning Dawn 🌅', [Color(0xFFFF6B6B), Color(0xFF6C5B7B)]),
  gradientEmerald('gradient_emerald', 'Sanctuary Emerald 🌿', [Color(0xFF064E3B), Color(0xFF0F766E)]),
  gradientGolden('gradient_golden', 'Sacred Amber 🍯', [Color(0xFF78350F), Color(0xFFD97706)]),
  gradientRoyal('gradient_royal', 'Royal Sapphire ⚓', [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
  glassLight('glass_light', 'Frosted Glass ❄️', [Color(0xCCFFFFFF), Color(0x99FFFFFF)]),
  glassDark('glass_dark', 'Obsidian Glass 🌑', [Color(0xCC18181B), Color(0x9918181B)]),
  solidLight('solid_light', 'Clean Paper 📄', [Color(0xFFFFFFFF), Color(0xFFF4F4F5)]),
  solidDark('solid_dark', 'Deep Charcoal 🖤', [Color(0xFF121214), Color(0xFF18181B)]),
  transparent('transparent', 'Clear Wallpaper 🪟', [Colors.transparent, Colors.transparent]);

  final String id;
  final String label;
  final List<Color> previewColors;

  const WidgetBackgroundStyle(this.id, this.label, this.previewColors);

  static WidgetBackgroundStyle fromId(String id) {
    return WidgetBackgroundStyle.values.firstWhere(
      (e) => e.id == id,
      orElse: () => WidgetBackgroundStyle.gradientDusk,
    );
  }
}

enum WidgetTextMode {
  auto('auto', 'Auto (Recommended)'),
  light('light', 'Force Dark Text (For light wallpaper)'),
  dark('dark', 'Force Crisp White (For dark wallpaper)');

  final String id;
  final String label;

  const WidgetTextMode(this.id, this.label);

  static WidgetTextMode fromId(String id) {
    return WidgetTextMode.values.firstWhere(
      (e) => e.id == id,
      orElse: () => WidgetTextMode.auto,
    );
  }
}

class WidgetSettingsState {
  final WidgetBackgroundStyle backgroundStyle;
  final WidgetTextMode textMode;

  const WidgetSettingsState({
    this.backgroundStyle = WidgetBackgroundStyle.gradientDusk,
    this.textMode = WidgetTextMode.auto,
  });

  WidgetSettingsState copyWith({
    WidgetBackgroundStyle? backgroundStyle,
    WidgetTextMode? textMode,
  }) {
    return WidgetSettingsState(
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      textMode: textMode ?? this.textMode,
    );
  }
}

class WidgetSettingsNotifier extends Notifier<WidgetSettingsState> {
  static const String _bgStyleKey = 'widget_bg_style';
  static const String _textModeKey = 'widget_text_mode';

  @override
  WidgetSettingsState build() {
    final prefs = ref.watch(preferencesProvider).prefs;
    final bgStyleId = prefs.getString(_bgStyleKey) ?? WidgetBackgroundStyle.gradientDusk.id;
    final textModeId = prefs.getString(_textModeKey) ?? WidgetTextMode.auto.id;

    return WidgetSettingsState(
      backgroundStyle: WidgetBackgroundStyle.fromId(bgStyleId),
      textMode: WidgetTextMode.fromId(textModeId),
    );
  }

  void setBackgroundStyle(WidgetBackgroundStyle style) {
    final prefs = ref.read(preferencesProvider).prefs;
    prefs.setString(_bgStyleKey, style.id);
    state = state.copyWith(backgroundStyle: style);
  }

  void setTextMode(WidgetTextMode mode) {
    final prefs = ref.read(preferencesProvider).prefs;
    prefs.setString(_textModeKey, mode.id);
    state = state.copyWith(textMode: mode);
  }
}

final widgetSettingsProvider =
    NotifierProvider<WidgetSettingsNotifier, WidgetSettingsState>(WidgetSettingsNotifier.new);
