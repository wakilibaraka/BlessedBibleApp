import 'dart:ui';
import 'package:flutter/material.dart';
import '../../state/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/read_settings_provider.dart';
import '../../state/nav_provider.dart';

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

class _AnimatedBackgroundState extends ConsumerState<AnimatedBackground> with SingleTickerProviderStateMixin {
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
    final isReadTab = widget.tabIndex == 1;
    final isImmersiveOn = readSettings.readingViewMode == ReadingViewMode.immersive;
    final disableGlow = isReadTab && isImmersiveOn;

    final shouldAnimate = isRouteCurrent && isTabActive && !disableGlow;
    
    if (shouldAnimate && !_bgAnimation.isAnimating) {
      _bgAnimation.repeat(reverse: true);
    } else if (!shouldAnimate && _bgAnimation.isAnimating) {
      _bgAnimation.stop();
    }

    if (disableGlow) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        color: Theme.of(context).scaffoldBackgroundColor,
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (_, __) {
          final glowStyle = ref.read(readSettingsProvider).backgroundGlowStyle;
          final isTopGlow = glowStyle == BackgroundGlowStyle.top;
          
          final t = _bgAnimation.value;

          // Slowly drift the focal point of the radial gradient
          final cx = lerpDouble(-0.3, 0.3, t);
          final cy = isTopGlow ? -1.0 + (lerpDouble(-0.4, 0.1, t)! * 0.2) : lerpDouble(-0.4, 0.1, t);
          final radius = isTopGlow ? 1.0 : 1.6;

          final List<Color> colors;
          switch (widget.appThemeMode.resolve(context)) {
            case AppThemeMode.dark:
      case AppThemeMode.oled:
            case AppThemeMode.automatic:
              // Warm amber glow at focal point, deep charcoal edges
              colors = [
                Color.lerp(const Color(0xFF3D2B0A), const Color(0xFF251800), t)!,
                Color.lerp(const Color(0xFF1E1C1A), const Color(0xFF0F0D0B), t)!,
                Theme.of(context).scaffoldBackgroundColor,
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

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            child: Container(
              key: ValueKey(widget.appThemeMode.resolve(context)),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(cx!, cy!),
                  radius: radius,
                  colors: colors,
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
