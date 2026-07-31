import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isScrollable;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWarmGold = Theme.of(context).scaffoldBackgroundColor == AppColors.warmGoldBackground;
    final radius = borderRadius ?? BorderRadius.circular(24);

    return Container(
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
        child: isScrollable
            ? Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.55)
                      : isWarmGold
                          ? const Color(0xFFF4ECD8).withValues(alpha: 0.85) // cream
                          : Colors.white.withValues(alpha: 0.85),
                  borderRadius: radius,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.50),
                    width: 1.0,
                  ),
                ),
                child: child,
              )
            : RepaintBoundary(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: padding,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : isWarmGold
                              ? Colors.white.withValues(alpha: 0.65)
                              : Colors.white.withValues(alpha: 0.65),
                      borderRadius: radius,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : isWarmGold
                                ? Colors.white.withValues(alpha: 0.40)
                                : Colors.white.withValues(alpha: 0.40),
                        width: 1.0,
                      ),
                    ),
                    child: child,
                  ),
                ),
              ),
      ),
    );
  }
}
