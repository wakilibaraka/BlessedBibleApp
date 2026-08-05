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

const bool kEnable3DMotion = true;

class TexturedGlassContainer extends ConsumerStatefulWidget {
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
  ConsumerState<TexturedGlassContainer> createState() => _TexturedGlassContainerState();
}

class _TexturedGlassContainerState extends ConsumerState<TexturedGlassContainer> with SingleTickerProviderStateMixin {
  late AnimationController _tiltController;
  late Animation<double> _tiltAnimation;
  Offset _tiltOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _tiltAnimation = CurvedAnimation(parent: _tiltController, curve: Curves.elasticOut);
    _tiltController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent event) {
    if (!kEnable3DMotion) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final dx = (event.localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (event.localPosition.dy - size.height / 2) / (size.height / 2);
    setState(() {
      _tiltOffset = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
    });
    _tiltController.stop();
  }

  void _onPointerUp(PointerEvent event) {
    if (!kEnable3DMotion) return;
    _tiltController.forward(from: 0.0).then((_) {
      _tiltOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(themeProvider);
    final appThemeResolved = appTheme.resolve(context);
    final surfaceStyle = ref.watch(surfaceStyleProvider);
    final isDepth3D = surfaceStyle == SurfaceStyle.depth3D;

    BorderRadius radius;
    if (isDepth3D) {
      if (widget.borderRadius != null && widget.borderRadius!.topLeft.x < 28) {
        radius = BorderRadius.circular(28);
      } else {
        radius = widget.borderRadius ?? BorderRadius.circular(28);
      }
    } else {
      radius = widget.borderRadius ?? BorderRadius.circular(24);
    }

    final useBlur = (surfaceStyle == SurfaceStyle.frosted || isDepth3D) && !widget.isScrollable;
    final is3D = surfaceStyle == SurfaceStyle.threeDimensional;

    final tokens = Theme.of(context).extension<ReadingTokens>()!;

    Color fillColor;
    bool isDarkPanel = false;

    if (useBlur) {
      switch (appThemeResolved) {
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
    } else if ((surfaceStyle == SurfaceStyle.frosted || isDepth3D) && widget.isScrollable) {
      fillColor = tokens.readingSurface.withValues(alpha: 0.95);
      isDarkPanel = tokens.readingSurface.computeLuminance() < 0.4;
    } else {
      fillColor = tokens.readingSurface;
      isDarkPanel = tokens.readingSurface.computeLuminance() < 0.4;
    }

    if (isDepth3D) {
      if (appThemeResolved == AppThemeMode.priestlyPurple) {
        fillColor = const Color(0xFF291040).withValues(alpha: useBlur ? 0.85 : 1.0);
        isDarkPanel = true;
      } else if (appThemeResolved == AppThemeMode.galileeBlue) {
        fillColor = const Color(0xFF082B44).withValues(alpha: useBlur ? 0.75 : 1.0);
        isDarkPanel = true;
      } else if (appThemeResolved == AppThemeMode.scarletRed) {
        fillColor = const Color(0xFF3D0C0C).withValues(alpha: useBlur ? 0.85 : 1.0);
        isDarkPanel = true;
      }
    }

    final bgLuminance = tokens.readingSurface.computeLuminance();
    final isDarkBg = bgLuminance < 0.4;

    final List<BoxShadow> shadows;
    if (isDepth3D) {
      Color highlightColor = isDarkBg ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.90);
      Color dropShadowColor = isDarkBg ? Colors.black.withValues(alpha: 0.60) : Colors.black.withValues(alpha: 0.15);
      Color glowColor = widget.isActive ? Theme.of(context).primaryColor.withValues(alpha: 0.40) : Colors.transparent;

      if (appThemeResolved == AppThemeMode.priestlyPurple) {
        highlightColor = const Color(0xFFFFD700).withValues(alpha: 0.15);
        dropShadowColor = const Color(0xFF10002B).withValues(alpha: 0.80);
        if (widget.isActive) glowColor = const Color(0xFFFFD700).withValues(alpha: 0.40);
      } else if (appThemeResolved == AppThemeMode.galileeBlue) {
        highlightColor = const Color(0xFF88CCFF).withValues(alpha: 0.20);
        dropShadowColor = const Color(0xFF001122).withValues(alpha: 0.70);
        if (widget.isActive) glowColor = const Color(0xFF00FFFF).withValues(alpha: 0.40);
      } else if (appThemeResolved == AppThemeMode.scarletRed) {
        highlightColor = const Color(0xFFFF8888).withValues(alpha: 0.15);
        dropShadowColor = const Color(0xFF220000).withValues(alpha: 0.85);
        if (widget.isActive) glowColor = const Color(0xFFFF3300).withValues(alpha: 0.50);
      }

      if (useBlur) {
        shadows = [
          BoxShadow(
              color: dropShadowColor,
              offset: const Offset(8, 12),
              blurRadius: 24,
              spreadRadius: -4),
          BoxShadow(
              color: highlightColor,
              offset: const Offset(-4, -4),
              blurRadius: 16,
              spreadRadius: 0),
          if (widget.isActive)
            BoxShadow(
                color: glowColor,
                offset: Offset.zero,
                blurRadius: 32,
                spreadRadius: 4),
        ];
      } else {
        shadows = [
          BoxShadow(
              color: dropShadowColor,
              offset: const Offset(4, 6),
              blurRadius: 12,
              spreadRadius: -2),
          BoxShadow(
              color: highlightColor,
              offset: const Offset(-2, -2),
              blurRadius: 8,
              spreadRadius: 0),
          if (widget.isActive)
            BoxShadow(
                color: glowColor,
                offset: Offset.zero,
                blurRadius: 16,
                spreadRadius: 2),
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

    Widget finalChild = widget.child;
    if (isDepth3D) {
      Color? overrideAccent;
      if (appThemeResolved == AppThemeMode.priestlyPurple) {
        overrideAccent = const Color(0xFFFFD700);
      } else if (appThemeResolved == AppThemeMode.galileeBlue) {
        overrideAccent = const Color(0xFF88CCFF);
      } else if (appThemeResolved == AppThemeMode.scarletRed) {
        overrideAccent = const Color(0xFFFF8888);
      } else if (isDarkPanel) {
        // All other dark themes (dark, AMOLED, dusk, fresh) also need
        // white-text override when the 3D surface is darkened.
        overrideAccent = Theme.of(context).primaryColor;
      }

      if (overrideAccent != null) {
        final overrideTokens = ReadingTokens(
          readingPaper: tokens.readingPaper,
          readingSurface: fillColor,
          readingInk: Colors.white,
          readingInkMuted: Colors.white.withValues(alpha: 0.80),
          readingAccent: overrideAccent,
          readingBorder: Colors.white.withValues(alpha: 0.15),
        );
        final theme = Theme.of(context);
        final darkTextTheme = theme.textTheme.copyWith(
          displayLarge: theme.textTheme.displayLarge?.copyWith(color: Colors.white),
          displayMedium: theme.textTheme.displayMedium?.copyWith(color: Colors.white),
          displaySmall: theme.textTheme.displaySmall?.copyWith(color: Colors.white),
          headlineLarge: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
          headlineMedium: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
          headlineSmall: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          titleLarge: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          titleMedium: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          titleSmall: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
          bodyLarge: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.95)),
          bodyMedium: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.90)),
          bodySmall: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.80)),
          labelLarge: theme.textTheme.labelLarge?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          labelMedium: theme.textTheme.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.80)),
          labelSmall: theme.textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
        );

        finalChild = Theme(
          data: theme.copyWith(
            brightness: Brightness.dark,
            primaryColor: overrideAccent,
            colorScheme: theme.colorScheme.copyWith(
              brightness: Brightness.dark,
              primary: overrideAccent,
              onSurface: Colors.white,
              onSurfaceVariant: Colors.white.withValues(alpha: 0.80),
              surface: fillColor,
            ),
            textTheme: darkTextTheme,
            iconTheme: theme.iconTheme.copyWith(color: Colors.white),
            extensions: [overrideTokens],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: finalChild,
          ),
        );
      }
    }

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: radius,
        border: useBlur
            ? null
            : isDepth3D
                ? Border.all(
                    width: 1.0,
                    color: appThemeResolved == AppThemeMode.priestlyPurple ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                        : appThemeResolved == AppThemeMode.galileeBlue ? const Color(0xFF88CCFF).withValues(alpha: 0.15)
                        : appThemeResolved == AppThemeMode.scarletRed ? const Color(0xFFFF8888).withValues(alpha: 0.15)
                        : isDarkBg
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03),
                  )
                : Border.all(
                    width: is3D ? 0.0 : 0.5,
                    color: is3D ? Colors.transparent : tokens.readingBorder,
                  ),
      ),
      child: finalChild,
    );

    if (useBlur) {
      content = CustomPaint(
        foregroundPainter: _RimAndNoisePainter(
          borderRadius: radius,
          rimAlpha: isDepth3D ? rimAlpha * 0.5 : rimAlpha,
          isDark: isDarkPanel,
        ),
        child: content,
      );
    }

    Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: widget.margin,
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
              sigmaX: useBlur ? widget.sigmaX : 0.001,
              sigmaY: useBlur ? widget.sigmaY : 0.001,
            ),
            child: content,
          ),
        ),
      ),
    );

    if (isDepth3D && useBlur && kEnable3DMotion) {
      final maxTilt = 0.05;
      final currentDx = _tiltOffset.dx * (1.0 - _tiltAnimation.value);
      final currentDy = _tiltOffset.dy * (1.0 - _tiltAnimation.value);

      final matrix = Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-currentDy * maxTilt)
        ..rotateY(currentDx * maxTilt);

      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerUp,
        child: Transform(
          transform: matrix,
          alignment: Alignment.center,
          child: container,
        ),
      );
    }

    return container;
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
