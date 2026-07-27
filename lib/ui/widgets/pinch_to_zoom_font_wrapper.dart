import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/typography_provider.dart';

class PinchToZoomFontWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const PinchToZoomFontWrapper({super.key, required this.child});

  @override
  ConsumerState<PinchToZoomFontWrapper> createState() => _PinchToZoomFontWrapperState();
}

class _PinchToZoomFontWrapperState extends ConsumerState<PinchToZoomFontWrapper> {
  final Map<int, Offset> _activePointers = {};
  double _initialDistance = 0.0;
  double _initialFontSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _activePointers[event.pointer] = event.position;
        if (_activePointers.length == 2) {
          final pts = _activePointers.values.toList();
          _initialDistance = (pts[0] - pts[1]).distance;
          _initialFontSize = ref.read(typographyProvider).fontSize;
        }
      },
      onPointerMove: (event) {
        if (_activePointers.containsKey(event.pointer)) {
          _activePointers[event.pointer] = event.position;
        }

        if (_activePointers.length == 2 && _initialDistance > 0) {
          final pts = _activePointers.values.toList();
          final currentDistance = (pts[0] - pts[1]).distance;
          final scale = currentDistance / _initialDistance;

          // Map scale to font size: e.g. scale 1.1 -> +10% font size
          final newFontSize = (_initialFontSize * scale).clamp(12.0, 32.0);
          
          final currentFontSize = ref.read(typographyProvider).fontSize;
          if ((newFontSize - currentFontSize).abs() > 0.5) {
            // Update live but debounced by distance threshold
            ref.read(typographyProvider.notifier).setFontSize(newFontSize);
          }
        }
      },
      onPointerUp: (event) {
        _activePointers.remove(event.pointer);
        if (_activePointers.length < 2) {
          _initialDistance = 0.0;
        }
      },
      onPointerCancel: (event) {
        _activePointers.remove(event.pointer);
        if (_activePointers.length < 2) {
          _initialDistance = 0.0;
        }
      },
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
