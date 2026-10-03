import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedMeshGradient extends StatefulWidget {
  final Widget? child;
  final double borderRadius;

  const AnimatedMeshGradient({
    super.key,
    this.child,
    this.borderRadius = 0.0,
  });

  @override
  State<AnimatedMeshGradient> createState() => _AnimatedMeshGradientState();
}

class _AnimatedMeshGradientState extends State<AnimatedMeshGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine colors based on theme
    final color1 = theme.primaryColor.withValues(alpha: isDark ? 0.3 : 0.15);
    final color2 = theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.3 : 0.15);
    final color3 = theme.colorScheme.secondary.withValues(alpha: isDark ? 0.2 : 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: [
          Container(
            color: theme.colorScheme.surface,
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final val = _controller.value;
              return Stack(
                children: [
                  Positioned(
                    top: -100 + 50 * math.sin(val * 2 * math.pi),
                    left: -50 + 50 * math.cos(val * 2 * math.pi),
                    width: 300,
                    height: 300,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color1,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -150 + 50 * math.cos(val * 2 * math.pi),
                    right: -50 + 50 * math.sin(val * 2 * math.pi),
                    width: 350,
                    height: 350,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color2,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50 + 30 * math.sin(val * 2 * math.pi + math.pi),
                    right: -100 + 60 * math.cos(val * 2 * math.pi),
                    width: 250,
                    height: 250,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color3,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Heavy blur to melt the colors together
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          if (widget.child != null)
            Positioned.fill(child: widget.child!),
        ],
      ),
    );
  }
}

