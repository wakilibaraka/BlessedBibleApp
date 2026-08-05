import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/theme_provider.dart';
import '../../state/surface_style_provider.dart';
import '../../theme/reading_tokens.dart';

// FROSTED GLASS TUNING CONSTANTS
const double _kBlurSigma = 40.0;
const double _kTintLightAlpha = 0.70;
const double _kTintDarkAlpha = 0.65;
const double _kRimLightAlpha = 0.55;
const double _kRimDarkAlpha = 0.30;
const double _kNoiseAlphaDark = 0.030;
const double _kNoiseAlphaLight = 0.025;
const double _kNoiseDensity = 0.015;

class TexturedGlassContainer extends ConsumerWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double sigmaX;
  final double sigmaY;
  final double borderOpacity;
  final bool isScrollable;

  const TexturedGlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.sigmaX = _kBlurSigma,
    this.sigmaY = _kBlurSigma,
    this.borderOpacity = 0.5,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);
    final surfaceStyle = ref.watch(surfaceStyleProvider);
    final radius = borderRadius ?? BorderRadius.circular(24);

    final isDepth3D = surfaceStyle == SurfaceStyle.depth3D;
    final useBlur = (surfaceStyle == SurfaceStyle.frosted || isDepth3D) && !isScrollable;
    final is3D = surfaceStyle == SurfaceStyle.threeDimensional;

    final tokens = Theme.of(context).extension<ReadingTokens>()!;

    Color fillColor;
    bool isDarkPanel = false;

    if (useBlur) {
      switch (appTheme.resolve(context)) {
        case AppThemeMode.sepia:
          fillColor =
              const Color(0xFFF5EAD0).withValues(alpha: _kTintLightAlpha);
          isDarkPanel = false;
          break;
        case AppThemeMode.light:
        case AppThemeMode.priestlyPurple:
        case AppThemeMode.galileeBlue:
        case AppThemeMode.scarletRed:
        case AppThemeMode.dawn:
        case AppThemeMode.lilies:
        case AppThemeMode.roses:
        case AppThemeMode.olives:
        case AppThemeMode.fresh:
          fillColor = Colors.white.withValues(alpha: _kTintLightAlpha);
          isDarkPanel = false;
          break;
        case AppThemeMode.dusk:
        case AppThemeMode.dark:
        case AppThemeMode.oled:
        case AppThemeMode.automatic:
          fillColor = Colors.black.withValues(alpha: _kTintDarkAlpha);
          isDarkPanel = true;
          break;
      }
    } else if ((surfaceStyle == SurfaceStyle.frosted || isDepth3D) && isScrollable) {
      fillColor = tokens.readingSurface.withValues(alpha: 0.95);
      isDarkPanel = tokens.readingSurface.computeLuminance() < 0.4;
    } else {
      fillColor = tokens.readingSurface;
      isDarkPanel = tokens.readingSurface.computeLuminance() < 0.4;
    }

    final bgLuminance = tokens.readingSurface.computeLuminance();
    final isDarkBg = bgLuminance < 0.4;

    final List<BoxShadow> shadows;
    if (isDepth3D) {
      if (useBlur) {
        // Tier 3: Floating Modals / Hero Headers
        shadows = isDarkBg
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.50),
                    offset: const Offset(0, 16),
                    blurRadius: 32,
                    spreadRadius: -8),
              ]
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    offset: const Offset(0, 16),
                    blurRadius: 32,
                    spreadRadius: -8),
              ];
      } else {
        // Tier 2: Raised Cards
        shadows = isDarkBg
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.40),
                    offset: const Offset(0, 6),
                    blurRadius: 20,
                    spreadRadius: -4),
              ]
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                    spreadRadius: -2),
              ];
      }
    } else if (is3D) {
      shadows = isDarkBg
          ? [
              BoxShadow(
                  color: Colors.white.withValues(alpha: 0.08),
                  offset: const Offset(-2.0, -2.0),
                  blurRadius: 4),
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.40),
                  offset: const Offset(4.0, 4.0),
                  blurRadius: 6),
            ]
          : [
              BoxShadow(
                  color: Colors.white.withValues(alpha: 0.90),
                  offset: const Offset(-2.0, -2.0),
                  blurRadius: 4),
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(4.0, 4.0),
                  blurRadius: 6),
            ];
    } else if (surfaceStyle == SurfaceStyle.frosted) {
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkBg ? 0.45 : 0.18),
          blurRadius: 36,
          spreadRadius: -4,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkBg ? 0.20 : 0.06),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 3),
        ),
      ];
    } else {
      shadows = [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2)),
      ];
    }

    final rimAlpha = isDarkPanel ? _kRimDarkAlpha : _kRimLightAlpha;

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: radius,
        border: useBlur
            ? null
            : isDepth3D
                ? Border.all(
                    width: 1.0,
                    color: isDarkBg
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.05),
                  )
                : Border.all(
                    width: is3D ? 0.0 : 0.5,
                    color: is3D ? Colors.transparent : tokens.readingBorder,
                  ),
      ),
      child: child,
    );

    if (useBlur) {
      content = CustomPaint(
        foregroundPainter: _RimAndNoisePainter(
          borderRadius: radius,
          rimAlpha: rimAlpha,
          isDark: isDarkPanel,
        ),
        child: content,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: RepaintBoundary(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: useBlur ? sigmaX : 0.001,
              sigmaY: useBlur ? sigmaY : 0.001,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _RimAndNoisePainter extends CustomPainter {
  final BorderRadius borderRadius;
  final double rimAlpha;
  final bool isDark;

  _RimAndNoisePainter({
    required this.borderRadius,
    required this.rimAlpha,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size);

    canvas.save();
    canvas.clipRRect(rrect);

    final random = math.Random(42);
    final count =
        (size.width * size.height * _kNoiseDensity).toInt().clamp(0, 800);
    final darkPoints = <Offset>[];
    final lightPoints = <Offset>[];
    for (int i = 0; i < count; i++) {
      darkPoints.add(Offset(
          random.nextDouble() * size.width, random.nextDouble() * size.height));
      lightPoints.add(Offset(
          random.nextDouble() * size.width, random.nextDouble() * size.height));
    }
    canvas.drawPoints(
        PointMode.points,
        darkPoints,
        Paint()
          ..color = Colors.black.withValues(alpha: _kNoiseAlphaDark)
          ..strokeWidth = 1.0);
    canvas.drawPoints(
        PointMode.points,
        lightPoints,
        Paint()
          ..color = Colors.white.withValues(alpha: _kNoiseAlphaLight)
          ..strokeWidth = 1.0);

    final rimPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: rimAlpha),
          Colors.white.withValues(alpha: rimAlpha * 0.25),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.6],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(
      borderRadius.toRRect(
          Rect.fromLTWH(0.6, 0.6, size.width - 1.2, size.height - 1.2)),
      rimPaint,
    );

    if (!isDark) {
      canvas.drawRRect(
        borderRadius.toRRect(
            Rect.fromLTWH(0.4, 0.4, size.width - 0.8, size.height - 0.8)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RimAndNoisePainter old) =>
      old.rimAlpha != rimAlpha || old.isDark != isDark;
}
