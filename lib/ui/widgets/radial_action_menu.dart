import 'dart:math';

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter/services.dart';

/// Pure geometry for the radial verse menu, kept separate from painting
/// so the maths is unit-testable.
///
/// Items sit on a circle around the press point. The start angle points
/// away from the nearest screen edge so the ring opens into the screen
/// rather than off it, and the arc spans 360deg when there is room.
class RadialLayout {
  /// Item centres, relative to the anchor (the press point).
  final List<Offset> centres;

  /// Start angle in radians.
  final double startAngle;

  const RadialLayout({required this.centres, required this.startAngle});

  /// radius: distance from the anchor to each item's centre.
  /// [anchor] is in global/local screen coordinates.
  /// [count] is the number of actions.
  ///
  /// Items are evenly spaced on a full circle, then each centre is
  /// clamped inside the viewport (with [margin] to spare), so a press
  /// near an edge can never push an action off-screen. The radius is
  /// honoured exactly when the anchor has room all round.
  static RadialLayout around({
    required Offset anchor,
    required int count,
    required Size viewport,
    double radius = 78,
    double margin = 34,
  }) {
    if (count <= 0) {
      return const RadialLayout(centres: [], startAngle: 0);
    }

    final step = 2 * pi / count;
    // Bias the ring so the densest run of items faces the roomiest side;
    // clamping below guarantees visibility regardless.
    final angleToCentre = atan2(
      (anchor.dy - (viewport.height - anchor.dy)) / 2,
      (anchor.dx - (viewport.width - anchor.dx)) / 2,
    );

    final centres = <Offset>[];
    for (var i = 0; i < count; i++) {
      final a = angleToCentre + (i - (count - 1) / 2) * step;
      var p = Offset(cos(a) * radius, sin(a) * radius);
      // Clamp into the viewport so no target clips off-screen.
      final x = anchor.dx + p.dx;
      final y = anchor.dy + p.dy;
      p = Offset(
        (x.clamp(margin, viewport.width - margin) - anchor.dx),
        (y.clamp(margin, viewport.height - margin) - anchor.dy),
      );
      centres.add(p);
    }
    return RadialLayout(centres: centres, startAngle: angleToCentre);
  }
}

/// One action in the ring.
class RadialAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const RadialAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

/// Circular ring of actions anchored at a verse's press point.
///
/// Opened from a long-press when the verse action style is "Radial".
/// One gesture entry for the whole ring (so it wins the arena against the
/// verse's own long-press), outside-tap/scroll dismiss, and it closes on
/// any navigation.
class RadialActionMenu extends StatefulWidget {
  final Offset anchor;
  final List<RadialAction> actions;
  final double radius;

  const RadialActionMenu({
    super.key,
    required this.anchor,
    required this.actions,
    this.radius = 78,
  });

  /// Opens the ring. Returns once it closes.
  static Future<void> show(
    BuildContext context, {
    required Offset anchor,
    required List<RadialAction> actions,
  }) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.readVerseActions,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => RadialActionMenu(
        anchor: anchor,
        actions: actions,
      ),
      transitionBuilder: (context, anim, _, child) => FadeTransition(
        opacity: anim,
        child: child,
      ),
    );
  }

  @override
  State<RadialActionMenu> createState() => _RadialActionMenuState();
}

class _RadialActionMenuState extends State<RadialActionMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final layout = RadialLayout.around(
      anchor: widget.anchor,
      count: widget.actions.length,
      viewport: Size(media.size.width, media.size.height),
      radius: widget.radius,
    );

    // One full-screen gesture entry: absorbs the long-press, and a tap
    // anywhere outside an item dismisses.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _close,
      onLongPress: () {},
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_controller.value);
          return Stack(
            children: [
              for (var i = 0; i < widget.actions.length; i++)
                if (i < layout.centres.length)
                  Positioned(
                    left: widget.anchor.dx + layout.centres[i].dx - 30,
                    top: widget.anchor.dy + layout.centres[i].dy - 30,
                    child: Transform.scale(
                      scale: 0.6 + 0.4 * t,
                      child: _RadialItem(
                        action: widget.actions[i],
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _close();
                          widget.actions[i].onTap();
                        },
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _RadialItem extends StatelessWidget {
  final RadialAction action;
  final VoidCallback onTap;

  const _RadialItem({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = action.color ?? theme.primaryColor;
    return Semantics(
      button: true,
      label: action.label,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          // 60pt diameter keeps the tap target comfortable.
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              border: Border.all(color: color.withValues(alpha: 0.45)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(action.icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}
