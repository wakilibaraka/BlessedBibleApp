import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/typography_provider.dart';
import 'pill_segmented_control.dart';

class TypographyControls extends ConsumerWidget {
  const TypographyControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final typographyNotifier = ref.read(typographyProvider.notifier);

    final fonts = [
      'EB Garamond',
      'Inter',
      'Gentium Book Plus',
      'Lora',
      'Literata',
      'Lexend',
      'OpenDyslexic'
    ];

    final sectionLabelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.primaryColor,
      letterSpacing: 1.2,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    final valueStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.primaryColor,
      fontWeight: FontWeight.bold,
    );
    final iconColor = theme.primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.text_increase_rounded, size: 16, color: iconColor),
                const SizedBox(width: 8),
                Text('FONT SIZE', style: sectionLabelStyle),
              ],
            ),
            Text('${typography.fontSize.clamp(12.0, 32.0).round()}',
                style: valueStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                final v = (typography.fontSize - 1).clamp(12.0, 32.0);
                if (v != typography.fontSize) {
                  HapticFeedback.selectionClick();
                  typographyNotifier.setFontSize(v);
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.25)),
                ),
                child: Center(
                  child: Text('A−',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                          height: 1.0)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                  tickMarkShape:
                      const RoundSliderTickMarkShape(tickMarkRadius: 1.5),
                  activeTickMarkColor:
                      theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                  inactiveTickMarkColor:
                      theme.primaryColor.withValues(alpha: 0.3),
                ),
                child: Slider(
                  value: typography.fontSize.clamp(12.0, 32.0),
                  min: 12.0,
                  max: 32.0,
                  divisions: 20,
                  activeColor: theme.primaryColor,
                  inactiveColor: theme.primaryColor.withValues(alpha: 0.2),
                  onChanged: (value) {
                    if (value != typography.fontSize) {
                      typographyNotifier.setFontSize(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final v = (typography.fontSize + 1).clamp(12.0, 32.0);
                if (v != typography.fontSize) {
                  HapticFeedback.selectionClick();
                  typographyNotifier.setFontSize(v);
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.25)),
                ),
                child: Center(
                  child: Text('A+',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                          height: 1.0)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.format_line_spacing_rounded,
                    size: 16, color: iconColor),
                const SizedBox(width: 8),
                Text('LINE SPACING', style: sectionLabelStyle),
              ],
            ),
            Text(
              typography.lineHeight <= 1.4
                  ? 'Compact'
                  : (typography.lineHeight >= 1.8 ? 'Relaxed' : 'Normal'),
              style: valueStyle,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: PillSegmentedControl(
            segments: const ['Compact', 'Normal', 'Relaxed'],
            selectedIndex: typography.lineHeight <= 1.4
                ? 0
                : (typography.lineHeight >= 1.8 ? 2 : 1),
            onSegmentSelected: (index) {
              HapticFeedback.selectionClick();
              typographyNotifier.setLineHeight([1.3, 1.6, 1.9][index]);
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.padding_rounded, size: 16, color: iconColor),
                const SizedBox(width: 8),
                Text('MARGINS', style: sectionLabelStyle),
              ],
            ),
            Text('${typography.marginPercent.toStringAsFixed(0)}%',
                style: valueStyle),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.5),
            activeTickMarkColor:
                theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
            inactiveTickMarkColor: theme.primaryColor.withValues(alpha: 0.3),
          ),
          child: Slider(
            value: typography.marginPercent.clamp(0.0, 16.0),
            min: 0.0,
            max: 16.0,
            divisions: 16,
            activeColor: theme.primaryColor,
            inactiveColor: theme.primaryColor.withValues(alpha: 0.2),
            onChanged: (value) {
              if (value != typography.marginPercent) {
                typographyNotifier.setMarginPercent(value);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.format_align_left_rounded,
                    size: 16, color: iconColor),
                const SizedBox(width: 8),
                Text('ALIGNMENT', style: sectionLabelStyle),
              ],
            ),
            Text(
              () {
                switch (typography.textAlignMode) {
                  case TextAlignMode.left:
                    return 'Left';
                  case TextAlignMode.center:
                    return 'Center';
                  case TextAlignMode.right:
                    return 'Right';
                  case TextAlignMode.justified:
                    return 'Justified';
                }
              }(),
              style: valueStyle,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AlignmentButton(
              icon: Icons.format_align_left_rounded,
              isSelected: typography.textAlignMode == TextAlignMode.left,
              onTap: () {
                HapticFeedback.selectionClick();
                typographyNotifier.setTextAlignMode(TextAlignMode.left);
              },
            ),
            const SizedBox(width: 12),
            _AlignmentButton(
              icon: Icons.format_align_center_rounded,
              isSelected: typography.textAlignMode == TextAlignMode.center,
              onTap: () {
                HapticFeedback.selectionClick();
                typographyNotifier.setTextAlignMode(TextAlignMode.center);
              },
            ),
            const SizedBox(width: 12),
            _AlignmentButton(
              icon: Icons.format_align_right_rounded,
              isSelected: typography.textAlignMode == TextAlignMode.right,
              onTap: () {
                HapticFeedback.selectionClick();
                typographyNotifier.setTextAlignMode(TextAlignMode.right);
              },
            ),
            const SizedBox(width: 12),
            _AlignmentButton(
              icon: Icons.format_align_justify_rounded,
              isSelected: typography.textAlignMode == TextAlignMode.justified,
              onTap: () {
                HapticFeedback.selectionClick();
                typographyNotifier.setTextAlignMode(TextAlignMode.justified);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.font_download_rounded, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text('FONT FAMILY', style: sectionLabelStyle),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: fonts.length,
          itemBuilder: (context, index) {
            final font = fonts[index];
            final isSelected = typography.fontFamily == font;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                typographyNotifier.setFontFamily(font);
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                  ),
                ),
                child: Text(
                  font,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: font,
                    color: isSelected
                        ? theme.colorScheme.surface
                        : theme.primaryColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AlignmentButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlignmentButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? theme.colorScheme.surface : theme.primaryColor,
        ),
      ),
    );
  }
}

// In some UI setups, a custom segmented control is used.
// Let's assume PillSegmentedControl is part of animated_segmented_tile.dart or similar.
// Actually, it's defined in read_screen.dart, let's copy PillSegmentedControl here just in case,
// or extract it into a separate file if it's not exported.
// Let me check if PillSegmentedControl is in animated_segmented_tile.dart using grep.
