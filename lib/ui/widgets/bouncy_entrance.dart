import 'package:flutter/material.dart';
import 'dart:async';

class BouncyEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final bool isVisible;
  final Duration duration;
  final bool animateIn;

  const BouncyEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.isVisible = true,
    this.duration = const Duration(milliseconds: 500),
    this.animateIn = true,
  });

  @override
  State<BouncyEntrance> createState() => _BouncyEntranceState();
}

class _BouncyEntranceState extends State<BouncyEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: (widget.isVisible && !widget.animateIn) ? 1.0 : 0.0,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ),
    );

    if (widget.isVisible && widget.animateIn) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(BouncyEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _startAnimation();
      } else {
        _delayTimer?.cancel();
        _controller.reverse();
      }
    }
  }

  void _startAnimation() {
    _delayTimer?.cancel();
    if (widget.delay > Duration.zero) {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isVisible ? 1.0 : 0.0,
        child: widget.child,
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
