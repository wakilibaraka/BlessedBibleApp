import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/devotional_service.dart';
import '../../state/devotional_provider.dart';

/// Presentation widgets for the Plans Library redesign.
///
/// All colors come from the active theme (primary/surface/onSurface), so the
/// screenshot layout automatically remaps to each theme's palette — light,
/// dark and gold. Only the mascot character keeps its own fixed friendly
/// colors (it is an illustration, not chrome).

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December',
];
String libraryDateHeader(DateTime day) =>
    '${_monthNames[day.month - 1]} ${day.day}, ${day.year}';

/// Greeting row: "Hello," + name on the left, a year-progress / verse
/// button on the right. Both blocks share a baseline so the row reads as
/// two balanced halves (the old three-part row drifted out of alignment).
class LibraryGreetingHeader extends StatelessWidget {
  final String name;

  /// Day-of-year progress, e.g. "Day 277 of 365".
  final String progressLabel;

  /// Remaining days, e.g. "89 days left".
  final String remainingLabel;

  final VoidCallback onReadPressed;
  const LibraryGreetingHeader({
    super.key,
    required this.name,
    required this.progressLabel,
    required this.remainingLabel,
    required this.onReadPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hello,',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // 44pt min target, two lines of context, no magic offsets.
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onReadPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      progressLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      remainingLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
            color: const Color(0xFF4CAF50).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(3),
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
        borderRadius: BorderRadius.circular(14),
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
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Center(
            child: Text(
              initials,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.0,
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
  final words =
      title.replaceAll(RegExp(r'[^\w\s]'), '').split(RegExp(r'\s+'))
        ..removeWhere((w) => w.isEmpty);
  if (words.isEmpty) return 'BB';
  if (words.length == 1) {
    final w = words.first;
    return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}

/// Full-width artwork band: one bundled public-domain Doré plate for
/// today, with its caption as an eyebrow. Replaces the old mascot
/// placeholder, which made the header row lopsided.
///
/// The band is decorative-but-tappable: it opens the plate's story.
class LibraryPlateBand extends ConsumerWidget {
  final DateTime day;
  final Future<void> Function(StoryPlate plate) onOpen;
  final double height;

  const LibraryPlateBand({
    super.key,
    required this.day,
    required this.onOpen,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plate = ref.watch(_dailyPlateProvider(day));

    return plate.when(
      loading: () => SizedBox(height: height),
      error: (_, __) => const SizedBox.shrink(),
      data: (p) {
        if (p == null) return const SizedBox.shrink();
        return Semantics(
          button: true,
          label: 'Open story: ${p.caption}',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onOpen(p),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      p.assetPath,
                      fit: BoxFit.cover,
                      // A missing plate must not break the header.
                      errorBuilder: (_, __, ___) =>
                          Container(color: theme.colorScheme.surface),
                    ),
                    // Scrim so the caption stays legible on light plates.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.62),
                            Colors.black.withValues(alpha: 0.12),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Bible story',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Cached per-day plate lookup (service already caches the artwork map).
final _dailyPlateProvider =
    FutureProvider.family<StoryPlate?, DateTime>((ref, day) async {
  return ref.watch(devotionalServiceProvider).plateForDay(day);
});
