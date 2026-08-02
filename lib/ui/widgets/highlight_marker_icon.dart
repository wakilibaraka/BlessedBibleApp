import 'package:flutter/material.dart';
import '../../theme/reading_tokens.dart';

class HighlightMarkerIcon extends StatelessWidget {
  final double size;
  const HighlightMarkerIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HighlightMarkerPainter(context: context),
    );
  }
}

class _HighlightMarkerPainter extends CustomPainter {
  final BuildContext context;
  _HighlightMarkerPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final theme = Theme.of(context);
    final tokens = theme.extension<ReadingTokens>();
    final accentColor = tokens?.readingAccent ?? theme.colorScheme.primary;
    final inkColor = tokens?.readingInk ?? theme.colorScheme.onSurface;

    final double w = size.width;
    final double h = size.height;

    // Stroke underneath
    final strokePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.15
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.15, h * 0.85),
      Offset(w * 0.85, h * 0.85),
      strokePaint,
    );

    // Marker body (angled nib)
    final bodyPaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.fill;

    // Draw an angled marker
    canvas.save();
    canvas.translate(w / 2, h / 2 - h * 0.1);
    canvas.rotate(0.5); // Angled

    final path = Path();
    // Marker base
    path.moveTo(-w * 0.2, h * 0.2);
    path.lineTo(w * 0.2, h * 0.2);
    path.lineTo(w * 0.2, -h * 0.1);
    path.lineTo(-w * 0.2, -h * 0.1);
    path.close();

    // Marker tip (nib)
    final nibPath = Path();
    nibPath.moveTo(-w * 0.12, -h * 0.1);
    nibPath.lineTo(w * 0.12, -h * 0.1);
    nibPath.lineTo(w * 0.08, -h * 0.3);
    nibPath.lineTo(-w * 0.08, -h * 0.3);
    nibPath.close();

    canvas.drawPath(path, bodyPaint);
    canvas.drawPath(nibPath, bodyPaint);
    
    // Add a cap detail
    final capPaint = Paint()
      ..color = theme.colorScheme.surface
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTRB(-w * 0.2, h * 0.1, w * 0.2, h * 0.15), capPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Repaint on theme change
}
