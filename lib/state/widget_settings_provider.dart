import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';
import '../l10n/l10n.dart';

enum WidgetBackgroundStyle {
  gradientDusk('gradient_dusk', '🌌', [Color(0xFF1A102F), Color(0xFF4A154B)]),
  gradientDawn('gradient_dawn', '🌅', [Color(0xFFFF6B6B), Color(0xFF6C5B7B)]),
  gradientEmerald(
      'gradient_emerald', '🌿', [Color(0xFF064E3B), Color(0xFF0F766E)]),
  gradientGolden(
      'gradient_golden', '🍯', [Color(0xFF78350F), Color(0xFFD97706)]),
  gradientRoyal('gradient_royal', '⚓', [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
  glassLight('glass_light', '❄️', [Color(0xCCFFFFFF), Color(0x99FFFFFF)]),
  glassDark('glass_dark', '🌑', [Color(0xCC18181B), Color(0x9918181B)]),
  solidLight('solid_light', '📄', [Color(0xFFFFFFFF), Color(0xFFF4F4F5)]),
  solidDark('solid_dark', '🖤', [Color(0xFF121214), Color(0xFF18181B)]),
  transparent('transparent', '🪟', [Colors.transparent, Colors.transparent]);

  final String id;
  final String emoji;
  final List<Color> previewColors;

  const WidgetBackgroundStyle(this.id, this.emoji, this.previewColors);

  /// Display name in the interface language, with the style's emoji.
  String label(AppLocalizations l10n) {
    final name = switch (this) {
      gradientDusk => l10n.widgetStyleDusk,
      gradientDawn => l10n.widgetStyleDawn,
      gradientEmerald => l10n.widgetStyleEmerald,
      gradientGolden => l10n.widgetStyleGolden,
      gradientRoyal => l10n.widgetStyleRoyal,
      glassLight => l10n.widgetStyleGlassLight,
      glassDark => l10n.widgetStyleGlassDark,
      solidLight => l10n.widgetStyleSolidLight,
      solidDark => l10n.widgetStyleSolidDark,
      transparent => l10n.widgetStyleTransparent,
    };
    return '$name $emoji';
  }

  static WidgetBackgroundStyle fromId(String id) {
    return WidgetBackgroundStyle.values.firstWhere(
      (e) => e.id == id,
      orElse: () => WidgetBackgroundStyle.gradientDusk,
    );
  }
}

enum WidgetTextMode {
  auto('auto'),
  light('light'),
  dark('dark');

  final String id;

  const WidgetTextMode(this.id);

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
    final bgStyleId =
        prefs.getString(_bgStyleKey) ?? WidgetBackgroundStyle.gradientDusk.id;
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
    NotifierProvider<WidgetSettingsNotifier, WidgetSettingsState>(
        WidgetSettingsNotifier.new);
