import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWarmGold = Theme.of(context).scaffoldBackgroundColor == AppColors.warmGoldBackground;
    final radius = borderRadius ?? BorderRadius.circular(24);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : isWarmGold
                      ? Colors.white.withOpacity(0.65) // More opaque for sharper text in sepia
                      : Colors.white.withOpacity(0.40),
              borderRadius: radius,
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : isWarmGold
                        ? Colors.white.withOpacity(0.40)
                        : Colors.white.withOpacity(0.60),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
