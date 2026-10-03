import 'package:flutter/material.dart';

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
const List<String> _weekdayNames = [
  'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
];

String libraryDateHeader(DateTime day) =>
    '${_monthNames[day.month - 1]} ${day.day}, ${day.year}';

/// Monday-first week containing the given `day`.
List<DateTime> libraryWeekDays(DateTime day) {
  final monday = day.subtract(Duration(days: day.weekday - 1));
  return List.generate(7, (i) => monday.add(Duration(days: i)));
}

/// Greeting row: "Hello," + name + "Let's Read" pill + mascot placeholder.
class LibraryGreetingHeader extends StatelessWidget {
  final String name;
  final VoidCallback onReadPressed;
  const LibraryGreetingHeader({
    super.key,
    required this.name,
    required this.onReadPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello,',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onReadPressed,
          child: Container(
            margin: const EdgeInsets.only(top: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text(
              "Let's Read",
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const MascotPlaceholder(size: 64),
      ],
    );
  }
}

/// Week strip: day numbers over MON..SUN labels, today in accent.
class LibraryWeekStrip extends StatelessWidget {
  final DateTime today;
  const LibraryWeekStrip({super.key, required this.today});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = libraryWeekDays(today);
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Builder(builder: (_) {
              final d = days[i];
              final isToday = d.year == today.year &&
                  d.month == today.month &&
                  d.day == today.day;
              final color = isToday
                  ? theme.primaryColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.45);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${d.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          isToday ? FontWeight.w800 : FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _weekdayNames[i],
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight:
                          isToday ? FontWeight.w800 : FontWeight.w500,
                      letterSpacing: 0.6,
                      color: color,
                    ),
                  ),
                ],
              );
            }),
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
