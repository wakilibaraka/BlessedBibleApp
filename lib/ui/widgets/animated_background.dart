import 'dart:ui';
import 'package:flutter/material.dart';
import '../../state/theme_provider.dart';

class AnimatedBackground extends StatefulWidget {
  final AppThemeMode appThemeMode;

  const AnimatedBackground({
    super.key,
    required this.appThemeMode,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (_, __) {
        final t = _bgAnimation.value;

        // Slowly drift the focal point of the radial gradient
        final cx = lerpDouble(-0.3, 0.3, t);
        final cy = lerpDouble(-0.4, 0.1, t);

        final List<Color> colors;
        switch (widget.appThemeMode) {
          case AppThemeMode.dark:
            // Warm amber glow at focal point, deep charcoal edges
            colors = [
              Color.lerp(const Color(0xFF3D2B0A), const Color(0xFF251800), t)!,
              Color.lerp(const Color(0xFF1E1C1A), const Color(0xFF0F0D0B), t)!,
              const Color(0xFF080706),
            ];
            break;
          case AppThemeMode.sepia:
            // Soft gold glow fading into matte sepia background
            colors = [
              Color.lerp(const Color(0xFFE5CC98), const Color(0xFFDAB875), t)!,
              const Color(0xFFF4EAD5), // Fades to matte sepia
              const Color(0xFFF4EAD5),
            ];
            break;
          case AppThemeMode.light:
            // Very subtle warm glow that fades quickly into the pure ivory background
            colors = [
              Color.lerp(const Color(0xFFFDF3D7), const Color(0xFFFDE4A9), t)!,
              const Color(0xFFFAF9F6), // Fades to Pure Ivory
              const Color(0xFFFAF9F6),
            ];
        }

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(cx!, cy!),
              radius: 1.6,
              colors: colors,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
