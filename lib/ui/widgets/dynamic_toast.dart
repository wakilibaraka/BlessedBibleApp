import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import 'package:flutter/services.dart';
import 'textured_glass_container.dart';

class DynamicToast {
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    HapticFeedback.lightImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    final hasAction = actionLabel != null && onAction != null;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        message: message,
        icon: icon,
        // An action (Undo) needs a little longer to be reachable.
        duration: duration ??
            (hasAction
                ? const Duration(seconds: 5)
                : const Duration(milliseconds: 2500)),
        actionLabel: hasAction ? actionLabel : null,
        onAction: hasAction ? onAction : null,
        onDismissed: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  const _ToastOverlay({
    required this.message,
    this.icon,
    required this.duration,
    this.actionLabel,
    this.onAction,
    required this.onDismissed,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: Motion.slow,
    );

    _slideAnimation = Tween<double>(begin: -100, end: 64).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeInBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Curves.easeIn,
          reverseCurve: Curves.easeOut),
    );

    Future.delayed(widget.duration, _dismiss);
  }

  bool _dismissing = false;

  void _dismiss() {
    if (!mounted || _dismissing) return;
    _dismissing = true;
    _controller.reverse().then((_) {
      widget.onDismissed();
    });
  }

  void _runAction() {
    if (_dismissing) return;
    HapticFeedback.selectionClick();
    widget.onAction?.call();
    _dismiss();
  }

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _controller
      ..duration = Motion.of(context, const Duration(milliseconds: 600))
      ..reverseDuration = Motion.of(context, Motion.slow)
      ..forward();
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
      builder: (context, child) {
        return Positioned(
          top: _slideAnimation.value,
          left: 16,
          right: 16,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: SafeArea(
        child: Semantics(
          liveRegion: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TexturedGlassContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                borderRadius: BorderRadius.circular(Radii.xxxl),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon,
                          size: 20, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _runAction,
                        child: Text(widget.actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
