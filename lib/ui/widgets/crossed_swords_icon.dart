import 'dart:math';

import 'package:flutter/material.dart';

/// Crossed swords for the Settings tab button, drawn with a painter so
/// no image asset ships in the APK and the strokes follow the theme's
/// primary color exactly.
///
/// Entrance: the blades start collapsed at the button center (scale 0,
/// tips overlapped) and unfold into the crossed rest pose over
/// [kSwordsDuration] with an ease-out-back curve, then hold still — no
/// looping, no oscillation.
const Duration kSwordsDuration = Duration(milliseconds: 280);

class CrossedSwordsIcon extends StatefulWidget {
  final double size;
  final Color? color;

  const CrossedSwordsIcon({
    super.key,
    this.size = 28,
    this.color,
  });

  @override
  State<CrossedSwordsIcon> createState() => _CrossedSwordsIconState();
}

class _CrossedSwordsIconState extends State<CrossedSwordsIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: kSwordsDuration,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
          ).value;
          return CustomPaint(
            painter: _CrossedSwordsPainter(
              progress: t.clamp(0.0, 1.0),
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class _CrossedSwordsPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _CrossedSwordsPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Unfold: each sword rotates out of the vertical overlap and slides
    // to its diagonal rest angle while scaling up from the center.
    const restAngle = pi / 4;
    final blade = _SwordShape(
      // Tip reaches the far corner; grip sits near the center.
      length: min(w, h) * 0.46,
      width: min(w, h) * 0.085,
      hiltLength: min(w, h) * 0.17,
    );

    for (final dir in const [-1, 1]) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(dir * restAngle * progress);
      // Swords point away from each other along their own diagonal.
      canvas.scale(1, dir.toDouble());
      final matrix = Matrix4.identity()
        ..translateByDouble(
            0.0, -blade.length * (0.15 + 0.85 * progress), 0.0, 1.0)
        ..scaleByDouble(0.55 + 0.45 * progress, 0.55 + 0.45 * progress,
            0.55 + 0.45 * progress, 1.0);
      canvas.transform(matrix.storage);
      blade.paint(canvas, color);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CrossedSwordsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// One sword: tapered blade + crossguard + pommel, drawn pointing up.
class _SwordShape {
  final double length;
  final double width;
  final double hiltLength;

  const _SwordShape({
    required this.length,
    required this.width,
    required this.hiltLength,
  });

  void paint(Canvas canvas, Color color) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.42
      ..strokeCap = StrokeCap.round;

    final tip = Offset(0, -length);
    final bladeEnd = Offset(0, -hiltLength * 0.35);

    // Blade: a narrow lens shape (sharp tip, straight shoulders).
    final blade = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(width / 2, bladeEnd.dy - width * 0.9)
      ..lineTo(width / 2, bladeEnd.dy)
      ..lineTo(-width / 2, bladeEnd.dy)
      ..lineTo(-width / 2, bladeEnd.dy - width * 0.9)
      ..close();
    canvas.drawPath(blade, fill);

    // Fuller: a hairline down the middle reads as a blade, not a spike.
    canvas.drawLine(
      Offset(0, tip.dy + width * 1.6),
      Offset(0, bladeEnd.dy - width * 0.4),
      stroke..strokeWidth = width * 0.16,
    );

    // Crossguard.
    final guardY = bladeEnd.dy;
    canvas.drawLine(
      Offset(-width * 1.15, guardY + width * 0.1),
      Offset(width * 1.15, guardY + width * 0.1),
      stroke
        ..strokeWidth = width * 0.52
        ..strokeCap = StrokeCap.round,
    );

    // Grip + pommel.
    canvas.drawLine(
      Offset(0, guardY + width * 0.1),
      Offset(0, guardY + hiltLength),
      stroke..strokeWidth = width * 0.5,
    );
    canvas.drawCircle(
      Offset(0, guardY + hiltLength),
      width * 0.44,
      fill,
    );
  }
}
