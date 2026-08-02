import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/theme_provider.dart';
import '../../state/surface_style_provider.dart';
import '../../theme/reading_tokens.dart';

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
    this.sigmaX = 35.0,
    this.sigmaY = 35.0,
    this.borderOpacity = 0.5,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);
    final surfaceStyle = ref.watch(surfaceStyleProvider);
    final radius = borderRadius ?? BorderRadius.circular(24);

    final useBlur = surfaceStyle == SurfaceStyle.frosted && !isScrollable;
    final is3D = surfaceStyle == SurfaceStyle.threeDimensional;

    final tokens = Theme.of(context).extension<ReadingTokens>()!;
    Color fillColor;
    if (useBlur) {
      switch (appTheme.resolve(context)) {
        case AppThemeMode.sepia:
          fillColor = Colors.white.withValues(alpha: 0.55);
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
          fillColor = Colors.white.withValues(alpha: 0.45);
          break;
        case AppThemeMode.dusk:
        case AppThemeMode.dark:
        case AppThemeMode.oled:
        case AppThemeMode.automatic:
          fillColor = Colors.black.withValues(alpha: 0.55);
          break;
      }
    } else if (surfaceStyle == SurfaceStyle.frosted && isScrollable) {
      fillColor = tokens.readingSurface.withValues(alpha: 0.85);
    } else {
      fillColor = tokens.readingSurface;
    }

    final bgLuminance = tokens.readingSurface.computeLuminance();
    final isDarkBg = bgLuminance < 0.4;
    
    final List<BoxShadow> shadows;
    if (is3D) {
      shadows = isDarkBg
          ? [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.08),
                offset: const Offset(-2.0, -2.0),
                blurRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(4.0, 4.0),
                blurRadius: 6,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.9),
                offset: const Offset(-2.0, -2.0),
                blurRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(4.0, 4.0),
                blurRadius: 6,
              ),
            ];
    } else if (surfaceStyle == SurfaceStyle.frosted) {
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 10),
        ),
      ];
    } else {
      // Flat style - very minimal or no shadow
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];
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
              sigmaY: useBlur ? sigmaY : 0.001
            ),
            child: CustomPaint(
              foregroundPainter: _NoisePainter(drawNoise: useBlur),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: padding,
                decoration: BoxDecoration(
                  color: fillColor,
                  border: Border.all(
                    width: is3D ? 0.0 : (useBlur ? 1.0 : 0.5),
                    color: is3D ? Colors.transparent : (useBlur ? tokens.readingBorder : Colors.white.withValues(alpha: 0.15)),
                  ),
                  borderRadius: radius,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  final bool drawNoise;

  _NoisePainter({this.drawNoise = true});

  @override
  void paint(Canvas canvas, Size size) {
    if (!drawNoise) return;

    final random = math.Random(42); // Fixed seed prevents jitter
    final count = (size.width * size.height * 0.01).toInt().clamp(0, 500);

    final List<Offset> darkPoints = [];
    final List<Offset> lightPoints = [];

    for (int i = 0; i < count; i++) {
      darkPoints.add(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height));
      lightPoints.add(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height));
    }

    final darkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    final lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    canvas.drawPoints(PointMode.points, darkPoints, darkPaint);
    canvas.drawPoints(PointMode.points, lightPoints, lightPaint);
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) {
    return oldDelegate.drawNoise != drawNoise;
  }
}
