import 'package:flutter/material.dart';

/// Spacing scale. Use these instead of raw numbers in padding, margins and
/// gaps so the app keeps one rhythm.
abstract final class Space {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

/// Corner radii for cards, sheets, buttons and inputs.
abstract final class Radii {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double pill = 999;

  static BorderRadius all(double r) => BorderRadius.circular(r);
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(xxl));
}

/// Type scale for interface text. Reading text sizes come from the
/// typography settings instead.
abstract final class TypeScale {
  static const double micro = 10;
  static const double caption = 12;
  static const double body = 14;
  static const double bodyLarge = 16;
  static const double title = 18;
  static const double titleLarge = 20;
  static const double headline = 24;
  static const double display = 32;
}

/// Durations, so motion feels the same everywhere and can be switched off
/// in one place when the system asks for reduced motion.
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// [d], or zero when the platform asks to reduce motion.
  static Duration of(BuildContext context, Duration d) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false ? Duration.zero : d;
}

/// Minimum touch target (Material 48 dp; also clears Apple's 44 pt).
const double kMinTouchTarget = 48;

/// Semantic colours that every theme provides. Themes may register their
/// own [AppPalette]; otherwise one is derived from the colour scheme, so
/// all 14 themes get sensible values without hand-tuning each one.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.success,
    required this.warning,
    required this.danger,
    required this.onAccent,
    required this.textMuted,
    required this.textFaint,
    required this.divider,
    required this.scrim,
    required this.shadow,
    required this.overlay,
  });

  /// Positive state, e.g. a completed day.
  final Color success;

  /// Caution, e.g. a missed reading.
  final Color warning;

  /// Destructive actions and errors.
  final Color danger;

  /// Text and icons on top of the accent colour.
  final Color onAccent;

  /// Secondary text (subtitles, hints).
  final Color textMuted;

  /// Tertiary text (timestamps, disabled).
  final Color textFaint;

  final Color divider;

  /// Behind modal sheets and dialogs.
  final Color scrim;

  final Color shadow;

  /// Subtle fill for chips, pressed rows and glass surfaces.
  final Color overlay;

  factory AppPalette.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final ink = scheme.onSurface;
    return AppPalette(
      success: dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
      warning: dark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
      danger: dark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
      onAccent: ThemeData.estimateBrightnessForColor(scheme.primary) ==
              Brightness.dark
          ? Colors.white
          : Colors.black,
      textMuted: ink.withValues(alpha: 0.7),
      textFaint: ink.withValues(alpha: 0.5),
      divider: ink.withValues(alpha: 0.12),
      scrim: Colors.black.withValues(alpha: dark ? 0.6 : 0.4),
      shadow: Colors.black.withValues(alpha: dark ? 0.5 : 0.12),
      overlay: ink.withValues(alpha: dark ? 0.08 : 0.05),
    );
  }

  static AppPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppPalette>() ?? AppPalette.fromTheme(theme);
  }

  @override
  AppPalette copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? onAccent,
    Color? textMuted,
    Color? textFaint,
    Color? divider,
    Color? scrim,
    Color? shadow,
    Color? overlay,
  }) =>
      AppPalette(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        onAccent: onAccent ?? this.onAccent,
        textMuted: textMuted ?? this.textMuted,
        textFaint: textFaint ?? this.textFaint,
        divider: divider ?? this.divider,
        scrim: scrim ?? this.scrim,
        shadow: shadow ?? this.shadow,
        overlay: overlay ?? this.overlay,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      success: l(success, other.success),
      warning: l(warning, other.warning),
      danger: l(danger, other.danger),
      onAccent: l(onAccent, other.onAccent),
      textMuted: l(textMuted, other.textMuted),
      textFaint: l(textFaint, other.textFaint),
      divider: l(divider, other.divider),
      scrim: l(scrim, other.scrim),
      shadow: l(shadow, other.shadow),
      overlay: l(overlay, other.overlay),
    );
  }
}

extension DesignTokensContext on BuildContext {
  /// Semantic colours for the current theme.
  AppPalette get palette => AppPalette.of(this);
}
