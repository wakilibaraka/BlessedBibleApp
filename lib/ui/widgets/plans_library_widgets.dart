import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../../theme/design_tokens.dart';

/// Presentation widgets for the Plans Library redesign.
///
/// All colors come from the active theme (primary/surface/onSurface), so the
/// screenshot layout automatically remaps to each theme's palette — light,
/// dark and gold. Only the mascot character keeps its own fixed friendly
/// colors (it is an illustration, not chrome).

/// Short month and day for the hero, e.g. "October 22", for [locale].
String libraryMonthDay(DateTime day, [String? locale]) =>
    DateFormat.MMMMd(locale).format(day);

/// Weekday name for the hero's eyebrow label, e.g. "THURSDAY".
String libraryWeekday(DateTime day, [String? locale]) =>
    DateFormat.EEEE(locale).format(day).toUpperCase();

/// Plans hero header: a small weekday eyebrow over a large left-aligned
/// date, with a quiet year-progress line underneath (tap opens Let's Read)
/// and an optional streak chip on the right. The chip is hidden at 0 so an
/// empty streak never reads as a failure.
class LibraryHeroHeader extends StatelessWidget {
  final String weekday;
  final String date;

  /// Day-of-year progress, e.g. "Day 277 of 365".
  final String progressLabel;

  /// Consecutive reading days; the chip is hidden when this is 0.
  final int streakCount;

  final VoidCallback onProgressPressed;
  const LibraryHeroHeader({
    super.key,
    required this.weekday,
    required this.date,
    required this.progressLabel,
    required this.streakCount,
    required this.onProgressPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekday,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: theme.primaryColor,
                ),
              ),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              // Quiet text link: no box, so it doesn't compete with the
              // Today card below. 48dp tall for the touch target.
              Semantics(
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Radii.sm),
                  onTap: onProgressPressed,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minHeight: kMinTouchTarget),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            progressLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: palette.textMuted,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 18, color: palette.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (streakCount > 0) ...[
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Semantics(
              label: context.l10n.studyStreakDays(streakCount),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.warning.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        size: 18, color: palette.warning),
                    const SizedBox(width: 4),
                    Text(
                      '$streakCount',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: palette.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Placeholder vector for the mascot photo: a friendly toast character
/// with a green underline, drawn in code (no asset needed).
class MascotPlaceholder extends StatelessWidget {
  final double size;
  const MascotPlaceholder({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _ToastPainter()),
        ),
        const SizedBox(height: 4),
        Container(
          width: size * 0.55,
          height: 5,
          decoration: BoxDecoration(
            // Mascot art: fixed green underline, same in every theme.
            color: const Color(0xFF4CAF50).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(Radii.xs),
          ),
        ),
      ],
    );
  }
}

class _ToastPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Mascot illustration colours are fixed art, not theme chrome.
    final crust = Paint()..color = const Color(0xFFB0712E);
    final bread = Paint()..color = const Color(0xFFE9B36A);
    final dark = Paint()
      ..color = const Color(0xFF5B3A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    // Body: rounded toast slice.
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.08, w * 0.72, h * 0.72),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(body, crust);
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.14, w * 0.60, h * 0.60),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(inner, bread);

    // Eyes.
    final eye = Paint()..color = const Color(0xFF3A2410);
    canvas.drawCircle(Offset(w * 0.40, h * 0.40), w * 0.045, eye);
    canvas.drawCircle(Offset(w * 0.60, h * 0.40), w * 0.045, eye);

    // Smile.
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.50),
          width: w * 0.22,
          height: h * 0.16),
      0.15 * 3.14159,
      0.7 * 3.14159,
      false,
      dark,
    );

    // Blush.
    final blush = Paint()
      ..color = const Color(0xFFE2795B).withValues(alpha: 0.7);
    canvas.drawCircle(Offset(w * 0.32, h * 0.50), w * 0.05, blush);
    canvas.drawCircle(Offset(w * 0.68, h * 0.50), w * 0.05, blush);

    // Little feet.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.78, w * 0.16, h * 0.12),
        Radius.circular(w * 0.06),
      ),
      crust,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.56, h * 0.78, w * 0.16, h * 0.12),
        Radius.circular(w * 0.06),
      ),
      crust,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Placeholder vector for plan cover photos: per-plan hue, initials,
/// subtle motif. Deterministic from [seed] so covers are stable.
class PlanCoverPlaceholder extends StatelessWidget {
  final String seed;
  final String initials;
  final double width;
  final double height;
  const PlanCoverPlaceholder({
    super.key,
    required this.seed,
    required this.initials,
    this.width = 72,
    this.height = 88,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hue = (seed.hashCode % 360).abs().toDouble();
    final base = HSLColor.fromAHSL(1.0, hue, 0.45, 0.55).toColor();
    final deep = HSLColor.fromAHSL(1.0, hue, 0.55, 0.35).toColor();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.lg),
        gradient: LinearGradient(
          colors: [base, deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -width * 0.35,
            bottom: -height * 0.25,
            child: Container(
              width: width * 0.8,
              height: width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Highlight over the generated hue gradient (art).
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Decorative initials: the title is read elsewhere. Scales
          // down instead of wrapping at large text sizes.
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    initials,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      // Always on the mid/deep hue gradient, never the surface.
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Derives 1-2 stable initials from a plan title.
String planInitials(String title) {
  final words = title.replaceAll(RegExp(r'[^\w\s]'), '').split(RegExp(r'\s+'))
    ..removeWhere((w) => w.isEmpty);
  if (words.isEmpty) return 'BB';
  if (words.length == 1) {
    final w = words.first;
    return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}
