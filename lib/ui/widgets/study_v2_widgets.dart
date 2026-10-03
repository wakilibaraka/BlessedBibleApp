import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../state/theme_provider.dart';
import '../../theme/reading_tokens.dart';
import 'animated_background.dart';

/// Shared presentation primitives for the redesigned (V2) Study screens.
///
/// Rules (mirror Home/Read patterns):
/// - Surfaces come from [ReadingTokens] + theme, never hardcoded colors.
/// - Accent is always `theme.primaryColor` / `tokens.readingAccent`.
/// - Opacity via `withValues`, never grey/white/black literals.

ReadingTokens _tokens(BuildContext context) =>
    Theme.of(context).extension<ReadingTokens>()!;

/// Page shell for pushed V2 routes.
///
/// Tab screens (Home/Read/Study/Search) sit inside MainNavScreen's Stack,
/// which already paints [AnimatedBackground] behind them. Pushed routes are
/// opaque — nothing beneath them paints — so a transparent Scaffold would
/// show the black window void (dark app-bar titles become invisible, dim
/// labels unreadable). This shell repaints the exact same themed background
/// behind the page. `tabIndex` stays null so the glow never wrongly
/// deactivates with tab switches.
class V2PageShell extends StatelessWidget {
  final AppThemeMode appThemeMode;
  final Widget page;
  const V2PageShell(
      {super.key, required this.appThemeMode, required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBackground(appThemeMode: appThemeMode),
        ),
        page,
      ],
    );
  }
}

/// Inverted pill tab bar: surface container with a visible border, selected
/// pill uses on-surface bg + surface text so it reads on light AND dark
/// backgrounds. (onSurface-at-low-alpha containers vanish on black.)
class V2PillTabs extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  const V2PillTabs(
      {super.key, required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: theme.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(999),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: theme.colorScheme.surface,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.7),
        tabs: [for (final t in tabs) Tab(text: t)],
      ),
    );
  }
}

/// Small uppercase section eyebrow, e.g. "ACTIVE PLAN · M'CHEYNE 1-YEAR".
class V2Eyebrow extends StatelessWidget {
  final String text;
  const V2Eyebrow(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Theme.of(context).primaryColor,
          ),
    );
  }
}

/// Muted uppercase section label, e.g. "STUDY TOOLS".
class V2SectionLabel extends StatelessWidget {
  final String text;
  const V2SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 0),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

/// Card shell used by every V2 screen: surface bg, 1px themed border,
/// 24px radius. Optional accent border for featured/hero cards.
class V2Card extends StatelessWidget {
  final Widget child;
  final bool featured;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const V2Card({
    super.key,
    required this.child,
    this.featured = false,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = _tokens(context);
    final card = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: featured
              ? theme.primaryColor.withValues(alpha: 0.35)
              : tokens.readingBorder,
        ),
      ),
      padding: padding,
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

/// Words-based progress ring. Shows fraction; caption is rendered by caller
/// (e.g. "Day 154 of 365 · 12.4k/29.4k words").
class V2ProgressRing extends StatelessWidget {
  final double fraction;
  final double size;
  const V2ProgressRing({super.key, required this.fraction, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction.clamp(0.0, 1.0),
          track: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          accent: theme.primaryColor,
        ),
        child: Center(
          child: Text(
            '${(fraction.clamp(0.0, 1.0) * 100).round()}%',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color track;
  final Color accent;
  _RingPainter(
      {required this.fraction, required this.track, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final accentPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      fraction * 2 * math.pi,
      false,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.track != track ||
      old.accent != accent;
}

/// Accent pill badge, e.g. "42%" / "SCHEDULED" / "2 BEHIND".
class V2Badge extends StatelessWidget {
  final String text;
  const V2Badge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}

/// Muted pill badge for neutral metadata, e.g. "~18 MIN TODAY".
class V2MetaChip extends StatelessWidget {
  final String text;
  const V2MetaChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Thin linear progress bar using the theme accent.
class V2ProgressBar extends StatelessWidget {
  final double fraction;
  const V2ProgressBar({super.key, required this.fraction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.08),
        valueColor: AlwaysStoppedAnimation(theme.primaryColor),
      ),
    );
  }
}
