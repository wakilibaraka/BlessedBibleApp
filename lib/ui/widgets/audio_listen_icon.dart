import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// The reader's listen control.
///
/// Idle it is a headphones glyph; while a chapter is playing it morphs into
/// three equalizer bars that move, so the state is visible without opening
/// the player. Under reduced motion the bars are drawn still.
class AudioListenIcon extends StatelessWidget {
  const AudioListenIcon({
    super.key,
    required this.playing,
    required this.color,
    this.size = 17,
  });

  final bool playing;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final duration = Motion.of(context, const Duration(milliseconds: 260));
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: playing
            ? _EqualizerBars(
                key: const ValueKey('audio-playing'),
                color: color,
                size: size,
                animate: duration != Duration.zero,
              )
            : Icon(
                Icons.headphones_rounded,
                key: const ValueKey('audio-idle'),
                size: size,
                color: color,
              ),
      ),
    );
  }
}

class _EqualizerBars extends StatefulWidget {
  const _EqualizerBars({
    super.key,
    required this.color,
    required this.size,
    required this.animate,
  });

  final Color color;
  final double size;
  final bool animate;

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _EqualizerPainter(
          color: widget.color,
          phase: _controller.value,
          animate: widget.animate,
        ),
      ),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  const _EqualizerPainter({
    required this.color,
    required this.phase,
    required this.animate,
  });

  final Color color;
  final double phase;
  final bool animate;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const bars = 3;
    final gap = size.width * 0.14;
    final barWidth = (size.width - gap * (bars - 1)) / bars;
    final radius = Radius.circular(barWidth / 2);
    for (var i = 0; i < bars; i++) {
      // Each bar is out of phase with its neighbours, so the group reads as
      // sound rather than a single pulsing block.
      final wave = animate
          ? 0.55 + 0.45 * math.sin((phase * 2 * math.pi) + i * 1.7)
          : 0.55 + 0.2 * (i % 2);
      final height = size.height * (0.35 + 0.65 * wave);
      final left = i * (barWidth + gap);
      final top = (size.height - height) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, height),
          radius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EqualizerPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.color != color ||
      oldDelegate.animate != animate;
}
