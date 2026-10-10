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
  final bool isActive;

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
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);
    final surfaceStyle = ref.watch(surfaceStyleProvider);

    final is3D = surfaceStyle == SurfaceStyle.threeDimensional;
    final isPaperlike = surfaceStyle == SurfaceStyle.paperlike;
    final isClaymorphic = surfaceStyle == SurfaceStyle.claymorphic;
    final isFrutigerAero = surfaceStyle == SurfaceStyle.frutigerAero;
    final isSkeuomorphic = surfaceStyle == SurfaceStyle.skeuomorphic;
    final isFrosted = surfaceStyle == SurfaceStyle.frosted;
    final useBlur = isFrosted && !isScrollable;

    BorderRadius radius;
    if (isClaymorphic) {
      final minR = borderRadius != null && borderRadius!.topLeft.x > 24
          ? borderRadius!.topLeft.x
          : 28.0;
      radius = BorderRadius.circular(minR);
    } else if (isSkeuomorphic) {
      if (borderRadius != null && borderRadius!.topLeft.x < 28) {
        radius = BorderRadius.circular(28);
      } else {
        radius = borderRadius ?? BorderRadius.circular(28);
      }
    } else {
      radius = borderRadius ?? BorderRadius.circular(24);
    }

    final tokens = Theme.of(context).extension<ReadingTokens>()!;

    Color fillColor;
    bool isDarkPanel = false;

    if (isSkeuomorphic) {
      final baseColor = tokens.readingSurface;
      final isDark = baseColor.computeLuminance() < 0.4;
      isDarkPanel = isDark;
      fillColor = isActive
          ? baseColor.withValues(alpha: isDark ? 0.8 : 0.9)
          : baseColor;
    } else if (isClaymorphic) {
      fillColor = tokens.readingSurface;
      isDarkPanel = tokens.readingSurface.computeLuminance() < 0.4;
    } else if (isFrutigerAero) {
      final baseColor = tokens.readingSurface;
      isDarkPanel = baseColor.computeLuminance() < 0.4;
      fillColor = isDarkPanel
          ? baseColor.withValues(alpha: 0.82)
          : baseColor.withValues(alpha: 0.78);
    } else if (useBlur) {
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
    } else if (isFrosted && isScrollable) {
      fillColor = tokens.readingSurface.withValues(alpha: 0.92);
      isDarkPanel = tokens.readingSurface.computeLuminance() < 0.4;
    } else {
      fillColor = tokens.readingSurface;
      isDarkPanel = tokens.readingSurface.computeLuminance() < 0.4;
    }

    final bgLuminance = tokens.readingSurface.computeLuminance();
    final isDarkBg = bgLuminance < 0.4;

    final List<BoxShadow> shadows;
    if (isClaymorphic) {
      final primary = Theme.of(context).primaryColor;
      final dropColor = isDarkBg
          ? Colors.black.withValues(alpha: 0.45)
          : primary.withValues(alpha: 0.22);
      final floorColor = isDarkBg
          ? Colors.black.withValues(alpha: 0.25)
          : Colors.black.withValues(alpha: 0.10);
      shadows = [
        BoxShadow(
          color: dropColor,
          offset: const Offset(0, 10),
          blurRadius: 20,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: floorColor,
          offset: const Offset(0, 3),
          blurRadius: 6,
        ),
      ];
    } else if (isFrutigerAero) {
      final glassBlue =
          Colors.lightBlue.withValues(alpha: isDarkBg ? 0.30 : 0.20);
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkBg ? 0.45 : 0.18),
          blurRadius: 28,
          spreadRadius: -2,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: glassBlue,
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];
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
    } else if (isFrosted) {
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
    } else if (isPaperlike) {
      shadows = [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1)),
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

    Border? containerBorder;
    if (useBlur || isClaymorphic) {
      containerBorder = null;
    } else if (isSkeuomorphic) {
      containerBorder = Border.all(
        width: 1.0,
        color: isDarkBg
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.15),
      );
    } else if (isFrutigerAero) {
      containerBorder = Border.all(
        width: 1.5,
        color: Colors.lightBlue.withValues(alpha: isDarkBg ? 0.25 : 0.40),
      );
    } else {
      containerBorder = Border.all(
        width: is3D ? 0.0 : (isPaperlike ? 0.8 : 0.5),
        color: is3D
            ? Colors.transparent
            : (isPaperlike
                ? tokens.readingBorder.withValues(alpha: 0.4)
                : tokens.readingBorder),
      );
    }

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: radius,
        border: containerBorder,
      ),
      child: child,
    );

    if (isSkeuomorphic) {
      content = CustomPaint(
        foregroundPainter: _SkeuomorphicPainter(
          borderRadius: radius,
          isDark: isDarkPanel,
          baseColor: fillColor,
        ),
        child: content,
      );
    } else if (isClaymorphic) {
      content = CustomPaint(
        foregroundPainter: _ClaymorphicPainter(
          borderRadius: radius,
          isDark: isDarkPanel,
          fillColor: fillColor,
        ),
        child: content,
      );
    } else if (isFrutigerAero) {
      content = CustomPaint(
        foregroundPainter: _FrutigerAeroPainter(
          borderRadius: radius,
          isDark: isDarkPanel,
        ),
        child: content,
      );
    } else if (useBlur) {
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
          child: (useBlur || isFrutigerAero)
              ? BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: isFrutigerAero
                        ? (isScrollable ? 0.001 : 16.0)
                        : (useBlur ? sigmaX : 0.001),
                    sigmaY: isFrutigerAero
                        ? (isScrollable ? 0.001 : 16.0)
                        : (useBlur ? sigmaY : 0.001),
                  ),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PAINTERS
// ══════════════════════════════════════════════════════════════════════════════

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

class _ClaymorphicPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final bool isDark;
  final Color fillColor;

  _ClaymorphicPainter({
    required this.borderRadius,
    required this.isDark,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size);
    canvas.save();
    canvas.clipRRect(rrect);

    final topHighlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.28 : 0.55),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.50));
    canvas.drawRRect(
      borderRadius
          .toRRect(Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3)),
      topHighlightPaint,
    );

    final bottomShadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.black.withValues(alpha: isDark ? 0.32 : 0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45));
    canvas.drawRRect(rrect, bottomShadowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ClaymorphicPainter old) =>
      old.isDark != isDark || old.fillColor != fillColor;
}

class _FrutigerAeroPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final bool isDark;

  _FrutigerAeroPainter({
    required this.borderRadius,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size);
    canvas.save();
    canvas.clipRRect(rrect);

    final glareRect = Rect.fromLTWH(
      size.width * 0.08,
      size.height * -0.1,
      size.width * 0.84,
      size.height * 0.52,
    );
    final glarePath = Path()..addOval(glareRect);
    canvas.drawPath(
      glarePath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.4),
          radius: 0.65,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.45 : 0.55),
            Colors.white.withValues(alpha: isDark ? 0.08 : 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(glareRect),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.12 : 0.22),
            Colors.transparent,
            Colors.lightBlue.withValues(alpha: isDark ? 0.06 : 0.10),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawRRect(
      borderRadius.toRRect(
          Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.55 : 0.70),
            Colors.lightBlue.withValues(alpha: isDark ? 0.20 : 0.35),
            Colors.cyan.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.40, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FrutigerAeroPainter old) =>
      old.isDark != isDark;
}

class _SkeuomorphicPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final bool isDark;
  final Color baseColor;

  _SkeuomorphicPainter({
    required this.borderRadius,
    required this.isDark,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size);
    canvas.save();
    canvas.clipRRect(rrect);

    final random = math.Random(12345);
    final count = (size.width * size.height * 0.08).toInt().clamp(0, 15000);
    final darkPoints = <Offset>[];
    final lightPoints = <Offset>[];
    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      if (random.nextBool()) {
        darkPoints.add(Offset(x, y));
      } else {
        lightPoints.add(Offset(x, y));
      }
    }
    final noiseAlphaDark = isDark ? 0.08 : 0.04;
    final noiseAlphaLight = isDark ? 0.04 : 0.15;
    canvas.drawPoints(
        PointMode.points,
        darkPoints,
        Paint()
          ..color = Colors.black.withValues(alpha: noiseAlphaDark)
          ..strokeWidth = 1.2);
    canvas.drawPoints(
        PointMode.points,
        lightPoints,
        Paint()
          ..color = Colors.white.withValues(alpha: noiseAlphaLight)
          ..strokeWidth = 1.2);

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.10 : 0.35),
            Colors.transparent,
            Colors.black.withValues(alpha: isDark ? 0.40 : 0.05),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawRRect(
      borderRadius.toRRect(
          Rect.fromLTWH(1.5, 1.5, size.width - 3.0, size.height * 0.18)),
      Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.12 : 0.40)
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SkeuomorphicPainter old) =>
      old.isDark != isDark || old.baseColor != baseColor;
}
