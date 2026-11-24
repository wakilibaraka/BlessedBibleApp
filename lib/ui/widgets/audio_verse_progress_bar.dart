import 'package:flutter/material.dart';

import '../../services/audio_verse_timing.dart';

/// The chapter scrubber, with one tick per verse.
///
/// The ticks are the estimated verse starts from [AudioVerseTimeline], so the
/// bar shows where in the chapter a verse begins instead of an anonymous
/// line. Dragging scrubs; a tap seeks to that point.
class AudioVerseProgressBar extends StatefulWidget {
  const AudioVerseProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.timeline,
    required this.activeColor,
    required this.trackColor,
    required this.onSeek,
    this.onSeekToVerse,
    this.height = 30,
  });

  final Duration position;
  final Duration duration;
  final AudioVerseTimeline timeline;
  final Color activeColor;
  final Color trackColor;
  final ValueChanged<Duration> onSeek;

  /// Called with the verse nearest a tap, when the caller wants verse
  /// precision rather than a bare seek.
  final ValueChanged<int>? onSeekToVerse;
  final double height;

  @override
  State<AudioVerseProgressBar> createState() => _AudioVerseProgressBarState();
}

class _AudioVerseProgressBarState extends State<AudioVerseProgressBar> {
  bool _dragging = false;
  double? _dragFraction;

  double get _fraction {
    final total = widget.duration.inMilliseconds;
    if (total <= 0) return 0;
    final raw = (_dragFraction ?? widget.position.inMilliseconds / total)
        .clamp(0.0, 1.0);
    return raw.toDouble();
  }

  void _seekFraction(double fraction) {
    final total = widget.duration.inMilliseconds;
    if (total <= 0) return;
    widget.onSeek(
      Duration(milliseconds: (total * fraction.clamp(0.0, 1.0)).round()),
    );
  }

  void _handleTap(TapDownDetails details, double width) {
    final fraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
    final verse = widget.timeline.verseAt(
      Duration(
        milliseconds: (widget.duration.inMilliseconds * fraction).round(),
      ),
    );
    if (verse != null && widget.onSeekToVerse != null) {
      widget.onSeekToVerse!(verse);
    } else {
      _seekFraction(fraction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.duration > Duration.zero;
    // The thumb's inner dot follows the surface colour so it reads on any
    // theme without hard-coding white.
    final thumbFill = Theme.of(context).colorScheme.surface;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          slider: true,
          enabled: enabled,
          label: 'Audio progress',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled ? (details) => _handleTap(details, width) : null,
            onHorizontalDragStart: enabled
                ? (details) => setState(() {
                      _dragging = true;
                      _dragFraction =
                          (details.localPosition.dx / width).clamp(0.0, 1.0);
                    })
                : null,
            onHorizontalDragUpdate: enabled
                ? (details) => setState(() {
                      _dragFraction =
                          (details.localPosition.dx / width).clamp(0.0, 1.0);
                    })
                : null,
            onHorizontalDragEnd: enabled
                ? (_) {
                    final fraction = _dragFraction;
                    setState(() {
                      _dragging = false;
                      _dragFraction = null;
                    });
                    if (fraction != null) _seekFraction(fraction);
                  }
                : null,
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: CustomPaint(
                painter: _VerseBarPainter(
                  fraction: _fraction,
                  ticks: _tickFractions(),
                  activeColor: widget.activeColor,
                  trackColor: widget.trackColor,
                  thumbFill: thumbFill,
                  enabled: enabled,
                  dragging: _dragging,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Verse starts as fractions of the chapter, skipping the 0 tick (the bar
  /// starts there) and dropping ticks too close together to draw.
  List<double> _tickFractions() {
    final total = widget.duration.inMilliseconds;
    if (total <= 0 || widget.timeline.isEmpty) return const [];
    final out = <double>[];
    var last = 0.0;
    for (final span in widget.timeline.spans) {
      final fraction = span.start.inMilliseconds / total;
      if (fraction <= 0.001) continue;
      if (fraction - last < 0.012) continue;
      out.add(fraction);
      last = fraction;
    }
    return out;
  }
}

class _VerseBarPainter extends CustomPainter {
  const _VerseBarPainter({
    required this.fraction,
    required this.ticks,
    required this.activeColor,
    required this.trackColor,
    required this.thumbFill,
    required this.enabled,
    required this.dragging,
  });

  final double fraction;
  final List<double> ticks;
  final Color activeColor;
  final Color trackColor;
  final Color thumbFill;
  final bool enabled;
  final bool dragging;

  @override
  void paint(Canvas canvas, Size size) {
    const trackHeight = 4.0;
    final centerY = size.height / 2;
    final radius = Radius.circular(trackHeight);
    final trackRect =
        Rect.fromLTWH(0, centerY - trackHeight / 2, size.width, trackHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, radius),
      Paint()..color = trackColor,
    );

    final filled = (size.width * fraction).clamp(0.0, size.width);
    if (filled > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, centerY - trackHeight / 2, filled, trackHeight),
          radius,
        ),
        Paint()..color = activeColor,
      );
    }

    // Verse ticks: short marks above and below the track, so the bar stays
    // readable at small sizes.
    final tickPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.85)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (final tick in ticks) {
      final x = size.width * tick;
      canvas.drawLine(
        Offset(x, centerY - 7),
        Offset(x, centerY + 7),
        tickPaint,
      );
    }

    // Thumb.
    final thumbRadius = dragging ? 9.0 : 7.0;
    final thumbPaint = Paint()..color = activeColor;
    canvas.drawCircle(Offset(filled, centerY), thumbRadius, thumbPaint);
    canvas.drawCircle(
      Offset(filled, centerY),
      thumbRadius - 3.5,
      Paint()..color = thumbFill.withValues(alpha: enabled ? 0.9 : 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _VerseBarPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.dragging != dragging ||
      oldDelegate.enabled != enabled ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.thumbFill != thumbFill ||
      oldDelegate.ticks.length != ticks.length;
}
