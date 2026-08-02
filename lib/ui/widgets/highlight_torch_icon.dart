import 'package:flutter/material.dart';
import '../../theme/reading_tokens.dart';

class HighlightTorchIcon extends StatelessWidget {
  final double size;

  const HighlightTorchIcon({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<ReadingTokens>();
    final accentColor = tokens?.readingAccent ?? theme.colorScheme.primary;
    final inkColor = tokens?.readingInk ?? theme.colorScheme.onSurface;

    return CustomPaint(
      size: Size(size, size),
      painter: _TorchPainter(
        torchColor: inkColor,
        beamColor: accentColor,
      ),
    );
  }
}

class _TorchPainter extends CustomPainter {
  final Color torchColor;
  final Color beamColor;

  _TorchPainter({required this.torchColor, required this.beamColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Torch Body (bottom left pointing top right)
    final paintTorch = Paint()
      ..color = torchColor
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;

    final pathTorch = Path();
    pathTorch.moveTo(size.width * 0.15, size.height * 0.85); // bottom left base
    pathTorch.lineTo(size.width * 0.35, size.height * 0.95);
    pathTorch.lineTo(size.width * 0.50, size.height * 0.60); // top right edge of handle
    pathTorch.lineTo(size.width * 0.30, size.height * 0.50); // top left edge of handle
    pathTorch.close();
    canvas.drawPath(pathTorch, paintTorch);

    // Torch head
    final pathHead = Path();
    pathHead.moveTo(size.width * 0.28, size.height * 0.48);
    pathHead.lineTo(size.width * 0.52, size.height * 0.62);
    pathHead.lineTo(size.width * 0.65, size.height * 0.50);
    pathHead.lineTo(size.width * 0.40, size.height * 0.35);
    pathHead.close();
    canvas.drawPath(pathHead, paintTorch);

    // Light Beam
    final paintBeam = Paint()
      ..color = beamColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final pathBeam = Path();
    pathBeam.moveTo(size.width * 0.42, size.height * 0.35); // top of head
    pathBeam.lineTo(size.width * 0.62, size.height * 0.48); // bottom of head
    pathBeam.lineTo(size.width * 0.95, size.height * 0.25); // bottom right of beam
    pathBeam.quadraticBezierTo(size.width * 0.8, size.height * 0.05, size.width * 0.65, size.height * 0.05); // curve at top right
    pathBeam.close();
    canvas.drawPath(pathBeam, paintBeam);

    // Three dots in front of beam
    final dotRadius = size.width * 0.05;
    // Align them vertically near the top right
    
    // Red dot
    final paintRed = Paint()..color = Colors.red..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.20), dotRadius, paintRed);
    
    // Yellow dot
    final paintYellow = Paint()..color = Colors.amber..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.35), dotRadius, paintYellow);
    
    // Green dot
    final paintGreen = Paint()..color = Colors.green..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.50), dotRadius, paintGreen);
  }

  @override
  bool shouldRepaint(covariant _TorchPainter oldDelegate) {
    return oldDelegate.torchColor != torchColor || oldDelegate.beamColor != beamColor;
  }
}
