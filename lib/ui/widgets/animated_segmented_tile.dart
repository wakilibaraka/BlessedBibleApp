import 'package:flutter/material.dart';

class AnimatedSegmentedTile<T> extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final T selectedValue;
  final List<MapEntry<T, String>> options;
  final ValueChanged<T> onChanged;

  const AnimatedSegmentedTile({
    super.key,
    this.title,
    this.subtitle,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) Text(title!, style: const TextStyle(fontSize: 16)),
          if (title != null && subtitle != null) const SizedBox(height: 4),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          if (title != null || subtitle != null) const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: options.map((option) {
                final isSelected = selectedValue == option.key;
                return _SegmentItem<T>(
                  option: option,
                  isSelected: isSelected,
                  onChanged: onChanged,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
class _SegmentItem<T> extends StatefulWidget {
  final MapEntry<T, String> option;
  final bool isSelected;
  final ValueChanged<T> onChanged;

  const _SegmentItem({
    required this.option,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  State<_SegmentItem<T>> createState() => _SegmentItemState<T>();
}

class _SegmentItemState<T> extends State<_SegmentItem<T>> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onChanged(widget.option.key);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected ? theme.colorScheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: Text(
              widget.option.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                color: widget.isSelected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
