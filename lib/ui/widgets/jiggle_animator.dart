import 'dart:math' as math;
import 'package:flutter/material.dart';

class JiggleAnimator extends StatefulWidget {
  final Widget child;
  final bool isJiggling;
  final double maxAngle;
  final Duration duration;

  const JiggleAnimator({
    super.key,
    required this.child,
    this.isJiggling = false,
    this.maxAngle = 0.015,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<JiggleAnimator> createState() => _JiggleAnimatorState();
}

class _JiggleAnimatorState extends State<JiggleAnimator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _randomOffset;

  @override
  void initState() {
    super.initState();
    _randomOffset = math.Random().nextDouble();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: -widget.maxAngle, end: widget.maxAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.isJiggling) {
      _startJiggling();
    }
  }

  @override
  void didUpdateWidget(JiggleAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isJiggling && !oldWidget.isJiggling) {
      _startJiggling();
    } else if (!widget.isJiggling && oldWidget.isJiggling) {
      _controller.stop();
      _controller.animateTo(0.5, duration: const Duration(milliseconds: 100)); // Return to center (0 angle is at 0.5 value)
    }
  }

  void _startJiggling() {
    _controller.value = _randomOffset;
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Transform value to have 0 rotation when not jiggling. 
        // When not jiggling, we animated value to 0.5, where tween is 0.
        final angle = widget.isJiggling ? _animation.value : 0.0;
        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
