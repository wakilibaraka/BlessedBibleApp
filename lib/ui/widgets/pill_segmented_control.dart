import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

class PillSegmentedControl extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onSegmentSelected;

  const PillSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Radii.xxl),
        border: Border.all(color: theme.dividerTheme.color ?? Colors.grey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(segments.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSegmentSelected(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.xxl),
              ),
              child: Center(
                child: Text(
                  segments[index],
                  style: TextStyle(
                    color: isSelected
                        ? context.palette.onAccent
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
