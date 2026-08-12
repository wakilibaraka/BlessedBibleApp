import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinchToNavWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onPinchNav;

  const PinchToNavWrapper({
    super.key,
    required this.child,
    required this.onPinchNav,
  });

  @override
  State<PinchToNavWrapper> createState() => _PinchToNavWrapperState();
}

class _PinchToNavWrapperState extends State<PinchToNavWrapper> {
  final Map<int, Offset> _activePointers = {};
  double _initialDistance = 0.0;
  bool _hasTriggeredPinch = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _activePointers[event.pointer] = event.position;
        if (_activePointers.length == 2) {
          final pts = _activePointers.values.toList();
          _initialDistance = (pts[0] - pts[1]).distance;
          _hasTriggeredPinch = false;
        }
      },
      onPointerMove: (event) {
        if (_activePointers.containsKey(event.pointer)) {
          _activePointers[event.pointer] = event.position;
        }

        if (_activePointers.length == 2 && _initialDistance > 0 && !_hasTriggeredPinch) {
          final pts = _activePointers.values.toList();
          final currentDistance = (pts[0] - pts[1]).distance;
          final scale = currentDistance / _initialDistance;

          // Guard against accidental triggers:
          // 1. MUST have exactly 2 active pointers (handled by length == 2 check above).
          // 2. MUST have a significant scale change. A typical tap/scroll won't have 2 fingers,
          //    and accidental multi-touch during scrolling won't create a large scale difference.
          if (scale < 0.7 || scale > 1.3) {
            _hasTriggeredPinch = true;
            HapticFeedback.mediumImpact();
            widget.onPinchNav();
          }
        }
      },
      onPointerUp: (event) {
        _activePointers.remove(event.pointer);
        if (_activePointers.length < 2) {
          _initialDistance = 0.0;
          _hasTriggeredPinch = false;
        }
      },
      onPointerCancel: (event) {
        _activePointers.remove(event.pointer);
        if (_activePointers.length < 2) {
          _initialDistance = 0.0;
          _hasTriggeredPinch = false;
        }
      },
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
