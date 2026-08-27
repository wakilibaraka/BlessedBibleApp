import 'dart:ui';
import 'package:flutter/material.dart';
import '../../state/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/read_settings_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/surface_style_provider.dart';

class AnimatedBackground extends ConsumerStatefulWidget {
  final AppThemeMode appThemeMode;
  final int? tabIndex;

  const AnimatedBackground({
    super.key,
    required this.appThemeMode,
    this.tabIndex,
  });

  @override
  ConsumerState<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends ConsumerState<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _bgAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final isRouteCurrent = route?.isCurrent ?? true;

    bool isTabActive = true;
    if (widget.tabIndex != null) {
      final currentIndex = ref.watch(navProvider);
      isTabActive = currentIndex == widget.tabIndex;
    }

    final readSettings = ref.watch(readSettingsProvider);
    final surfaceStyle = ref.watch(surfaceStyleProvider);
    final isReadTab = widget.tabIndex == 1;
    final isFull =
        readSettings.readingViewMode == ReadingViewMode.full;
    final disableGlow = surfaceStyle != SurfaceStyle.threeDimensional ||
        (isReadTab && isFull) ||
        !readSettings.isGlowEnabled;

    final shouldAnimate = isRouteCurrent && isTabActive && !disableGlow;

    if (shouldAnimate && !_bgAnimation.isAnimating) {
      _bgAnimation.repeat(reverse: true);
    } else if (!shouldAnimate && _bgAnimation.isAnimating) {
      _bgAnimation.stop();
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (_, __) {
          final hour = DateTime.now().hour;
          
          bool isTopGlow = true;
          double intensity = 0.5;

          if (hour >= 6 && hour < 10) {
            // Morning
            isTopGlow = true;
            intensity = 0.6;
          } else if (hour >= 10 && hour < 16) {
            // Midday
            isTopGlow = false;
            intensity = 1.0;
          } else if (hour >= 16 && hour < 20) {
            // Evening
            isTopGlow = true;
            intensity = 0.8;
          } else {
            // Night (20-6)
            isTopGlow = true;
            intensity = 0.3;
          }

          final t = _bgAnimation.value;

          // Slowly drift the focal point of the radial gradient
          final cx = lerpDouble(-0.3, 0.3, t);
          final cy = isTopGlow
              ? -1.0 + (lerpDouble(-0.4, 0.1, t)! * 0.2)
              : lerpDouble(-0.4, 0.1, t);
          final radius = isTopGlow ? 1.0 : 1.6;

          final List<Color> colors;
          switch (widget.appThemeMode.resolve(context)) {
            case AppThemeMode.dark:
            case AppThemeMode.oled:
            case AppThemeMode.automatic:
              // Warm amber glow at focal point, deep charcoal edges
              colors = [
                Color.lerp(
                    const Color(0xFF3D2B0A), const Color(0xFF251800), t)!,
                Color.lerp(
                    const Color(0xFF1E1C1A), const Color(0xFF0F0D0B), t)!,
                Theme.of(context).scaffoldBackgroundColor,
              ];
              break;
            case AppThemeMode.sepia:
              // Soft gold glow fading into matte sepia background
              colors = [
                Color.lerp(
                    const Color(0xFFE5CC98), const Color(0xFFDAB875), t)!,
                const Color(0xFFF4EAD5), // Fades to matte sepia
                const Color(0xFFF4EAD5),
              ];
              break;
            case AppThemeMode.light:
              // Very subtle warm glow that fades quickly into the pure ivory background
              colors = [
                Color.lerp(
                    const Color(0xFFFDF3D7), const Color(0xFFFDE4A9), t)!,
                const Color(0xFFFAF9F6), // Fades to Pure Ivory
                const Color(0xFFFAF9F6),
              ];
              break;
            case AppThemeMode.priestlyPurple:
            case AppThemeMode.galileeBlue:
            case AppThemeMode.scarletRed:
              colors = [
                Color.lerp(
                    const Color(0xFFFDF3D7), const Color(0xFFFDE4A9), t)!,
                const Color(0xFFFAF9F6),
                const Color(0xFFFAF9F6),
              ];
              break;
            case AppThemeMode.dawn:
              colors = [
                Color.lerp(const Color(0xFF453F52), const Color(0xFF3A3547),
                    t)!, // Center: dawnSurface
                const Color(0xFF2E2A3A), // Edges: dawnBackground
                const Color(0xFF2E2A3A),
              ];
              break;
            case AppThemeMode.lilies:
              colors = [
                Color.lerp(
                    const Color(0xFFBCE3F5), const Color(0xFF8CB9D1), t)!,
                const Color(0xFFFCE4EC),
                const Color(0xFFFCE4EC),
              ];
              break;
            case AppThemeMode.roses:
              colors = [
                Color.lerp(
                    const Color(0xFFFFC0A8), const Color(0xFFDE7456), t)!,
                const Color(0xFFFBE4D8),
                const Color(0xFFFBE4D8),
              ];
              break;
            case AppThemeMode.olives:
              colors = [
                Color.lerp(
                    const Color(0xFFB8CBA1), const Color(0xFF556B2F), t)!,
                const Color(0xFFE3E8DB),
                const Color(0xFFE3E8DB),
              ];
              break;
            case AppThemeMode.dusk:
              colors = [
                Color.lerp(
                    const Color(0xFF48426D), const Color(0xFF312C51), t)!,
                const Color(0xFF312C51),
                const Color(0xFF312C51),
              ];
              break;
            case AppThemeMode.fresh:
              colors = [
                Color.lerp(
                    const Color(0xFF1C404A), const Color(0xFF132C33), t)!,
                const Color(0xFF132C33),
                const Color(0xFF132C33),
              ];
              break;
          }

          final finalColors = colors
              .map((c) => Color.lerp(
                  Theme.of(context).scaffoldBackgroundColor, c, intensity)!)
              .toList();

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            child: Container(
              key: ValueKey(
                  '${widget.appThemeMode.resolve(context).name}_$disableGlow'),
              decoration: disableGlow
                  ? BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    )
                  : BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(cx!, cy!),
                        radius: radius,
                        colors: finalColors,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
