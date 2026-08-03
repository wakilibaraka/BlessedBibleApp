import 'package:flutter/material.dart';

class ActionIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double size;

  const ActionIcon({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
    this.onLongPress,
    this.size = 28,
  });

  @override
  State<ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<ActionIcon> {
  bool _showCheck = false;

  void _handleTap() {
    widget.onTap();
    if (mounted) {
      setState(() => _showCheck = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _showCheck = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: InkResponse(
        onTap: _handleTap,
        onLongPress: widget.onLongPress,
        radius: 24,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              _showCheck ? Icons.check_circle_rounded : widget.icon,
              key: ValueKey(_showCheck),
              size: widget.size,
              color: _showCheck ? Colors.green.shade400 : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
