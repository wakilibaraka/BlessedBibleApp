import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/theme_provider.dart';
import '../../state/glass_ui_provider.dart';
import '../../theme/app_colors.dart';

class TexturedGlassContainer extends ConsumerWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double sigmaX;
  final double sigmaY;
  final double borderOpacity;

  const TexturedGlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.sigmaX = 35.0,
    this.sigmaY = 35.0,
    this.borderOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);
    final isGlassy = ref.watch(glassUiProvider);
    final radius = borderRadius ?? BorderRadius.circular(24);

    Color fillColor;
    if (isGlassy) {
      switch (appTheme.resolve(context)) {
        case AppThemeMode.sepia:
          fillColor = Colors.white.withValues(alpha: 0.35);
          break;
        case AppThemeMode.light:
          fillColor = Colors.black.withValues(alpha: 0.08);
          break;
        case AppThemeMode.dark:
        case AppThemeMode.automatic:
          fillColor = Colors.black.withValues(alpha: 0.15);
          break;
      }
    } else {
      switch (appTheme.resolve(context)) {
        case AppThemeMode.sepia:
          fillColor = AppColors.sepiaSurface;
          break;
        case AppThemeMode.light:
          fillColor = AppColors.lightSurface;
          break;
        case AppThemeMode.dark:
        case AppThemeMode.automatic:
          fillColor = AppColors.darkSurface;
          break;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: isGlassy
            ? RepaintBoundary(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
                  child: CustomPaint(
                    foregroundPainter: _NoisePainter(),
                    child: Container(
                      padding: padding,
                      decoration: BoxDecoration(
                        color: fillColor,
                        border: Border.all(
                          width: 0.5,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        borderRadius: radius,
                      ),
                      child: child,
                    ),
                  ),
                ),
              )
            : Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: fillColor,
                  border: Border.all(
                    width: 0.5,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  borderRadius: radius,
                ),
                child: child,
              ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
