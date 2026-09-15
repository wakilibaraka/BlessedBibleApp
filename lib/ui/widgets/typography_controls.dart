import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/typography_provider.dart';
import 'pill_segmented_control.dart';

// Fonts grouped by family for 3-per-row grid
const _fontGroups = [
  ['EB Garamond', 'Gentium Book Plus', 'Literata'],
  ['Lora', 'Bitter', 'Cardo'],
  ['Noto Serif', 'Alegreya', 'Inter'],
  ['Lexend', 'Source Sans 3', 'OpenDyslexic'],
];

const _weightLabels = ['Light', 'Regular', 'Medium', 'Bold'];
const _weightValues = [300, 400, 500, 700];

class TypographyControls extends ConsumerWidget {
  const TypographyControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final typographyNotifier = ref.read(typographyProvider.notifier);

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

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── FONT SIZE ────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.text_increase_rounded, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text('FONT SIZE', style: sectionLabelStyle),
            ]),
            Text('${typography.fontSize.clamp(12.0, 32.0).round()}', style: valueStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(children: [
          _IconStepButton(icon: Icons.remove, iconColor: iconColor, theme: theme, onTap: () {
            final v = (typography.fontSize - 1).clamp(12.0, 32.0);
            if (v != typography.fontSize) { HapticFeedback.selectionClick(); typographyNotifier.setFontSize(v); }
          }),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.5),
                activeTickMarkColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                inactiveTickMarkColor: theme.primaryColor.withValues(alpha: 0.3),
              ),
              child: Slider(
                value: typography.fontSize.clamp(12.0, 32.0),
                min: 12.0, max: 32.0, divisions: 20,
                activeColor: theme.primaryColor,
                inactiveColor: theme.primaryColor.withValues(alpha: 0.2),
                onChanged: (v) { if (v != typography.fontSize) typographyNotifier.setFontSize(v); },
              ),
            ),
          ),
          const SizedBox(width: 12),
          _IconStepButton(icon: Icons.add, iconColor: iconColor, theme: theme, onTap: () {
            final v = (typography.fontSize + 1).clamp(12.0, 32.0);
            if (v != typography.fontSize) { HapticFeedback.selectionClick(); typographyNotifier.setFontSize(v); }
          }),
        ]),

        const SizedBox(height: 14),
        // ── FONT WEIGHT ──────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.line_weight_rounded, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text('FONT WEIGHT', style: sectionLabelStyle),
            ]),
            Text(
              () {
                final idx = _weightValues.indexOf(typography.fontWeightValue);
                return idx >= 0 ? _weightLabels[idx] : 'Regular';
              }(),
              style: valueStyle,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_weightValues.length, (i) {
            final isSelected = typography.fontWeightValue == _weightValues[i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _weightValues.length - 1 ? 6 : 0),
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); typographyNotifier.setFontWeight(_weightValues[i]); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _weightLabels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.values.firstWhere((w) => w.value == _weightValues[i], orElse: () => FontWeight.normal),
                        color: isSelected ? theme.colorScheme.surface : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 14),
        // ── LINE SPACING ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.format_line_spacing_rounded, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text('LINE SPACING', style: sectionLabelStyle),
            ]),
            Text(typography.lineHeight <= 1.4 ? 'Compact' : (typography.lineHeight >= 1.8 ? 'Relaxed' : 'Normal'), style: valueStyle),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: PillSegmentedControl(
            segments: const ['Compact', 'Normal', 'Relaxed'],
            selectedIndex: typography.lineHeight <= 1.4 ? 0 : (typography.lineHeight >= 1.8 ? 2 : 1),
            onSegmentSelected: (idx) { HapticFeedback.selectionClick(); typographyNotifier.setLineHeight([1.3, 1.6, 1.9][idx]); },
          ),
        ),

        const SizedBox(height: 14),
        // ── MARGINS ──────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.padding_rounded, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text('MARGINS', style: sectionLabelStyle),
            ]),
            Text('${typography.marginPercent.toStringAsFixed(0)}%', style: valueStyle),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.5),
            activeTickMarkColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
            inactiveTickMarkColor: theme.primaryColor.withValues(alpha: 0.3),
          ),
          child: Slider(
            value: typography.marginPercent.clamp(0.0, 16.0),
            min: 0.0, max: 16.0, divisions: 16,
            activeColor: theme.primaryColor,
            inactiveColor: theme.primaryColor.withValues(alpha: 0.2),
            onChanged: (v) { if (v != typography.marginPercent) typographyNotifier.setMarginPercent(v); },
          ),
        ),

        const SizedBox(height: 14),
        // ── ALIGNMENT ────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.format_align_left_rounded, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text('ALIGNMENT', style: sectionLabelStyle),
            ]),
            Text(switch (typography.textAlignMode) {
              TextAlignMode.left => 'Left',
              TextAlignMode.center => 'Center',
              TextAlignMode.right => 'Right',
              TextAlignMode.justified => 'Justified',
            }, style: valueStyle),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AlignmentButton(icon: Icons.format_align_left_rounded,    isSelected: typography.textAlignMode == TextAlignMode.left,      onTap: () { HapticFeedback.selectionClick(); typographyNotifier.setTextAlignMode(TextAlignMode.left); }),
            const SizedBox(width: 12),
            _AlignmentButton(icon: Icons.format_align_center_rounded,  isSelected: typography.textAlignMode == TextAlignMode.center,    onTap: () { HapticFeedback.selectionClick(); typographyNotifier.setTextAlignMode(TextAlignMode.center); }),
            const SizedBox(width: 12),
            _AlignmentButton(icon: Icons.format_align_right_rounded,   isSelected: typography.textAlignMode == TextAlignMode.right,     onTap: () { HapticFeedback.selectionClick(); typographyNotifier.setTextAlignMode(TextAlignMode.right); }),
            const SizedBox(width: 12),
            _AlignmentButton(icon: Icons.format_align_justify_rounded, isSelected: typography.textAlignMode == TextAlignMode.justified, onTap: () { HapticFeedback.selectionClick(); typographyNotifier.setTextAlignMode(TextAlignMode.justified); }),
          ],
        ),

        const SizedBox(height: 14),
        // ── FONT FAMILY GRID ─────────────────────────
        Row(children: [
          Icon(Icons.font_download_rounded, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text('FONT FAMILY', style: sectionLabelStyle),
        ]),
        const SizedBox(height: 8),
        for (final group in _fontGroups)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(3, (i) {
                if (i >= group.length) return const Expanded(child: SizedBox.shrink());
                final font = group[i];
                final isSelected = typography.fontFamily == font;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    child: GestureDetector(
                      onTap: () { HapticFeedback.selectionClick(); typographyNotifier.setFontFamily(font); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Aa', style: TextStyle(
                              fontFamily: font,
                              fontSize: 18,
                              fontWeight: typography.fontWeight,
                              color: isSelected ? theme.colorScheme.surface : theme.colorScheme.onSurface.withValues(alpha: 0.85),
                            )),
                            const SizedBox(height: 2),
                            Text(font,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: isSelected ? theme.colorScheme.surface.withValues(alpha: 0.85) : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

        // ── ITALIC TOGGLE ────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 24.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              title: Row(children: [
                Icon(Icons.format_italic_rounded, size: 16, color: iconColor),
                const SizedBox(width: 8),
                Text('ITALIC READING TEXT', style: sectionLabelStyle),
              ]),
              value: typography.italicEnabled,
              onChanged: (val) { HapticFeedback.selectionClick(); typographyNotifier.setItalicEnabled(val); },
              activeTrackColor: theme.primaryColor.withValues(alpha: 0.5),
              activeThumbColor: theme.primaryColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconStepButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final ThemeData theme;
  final VoidCallback onTap;
  const _IconStepButton({required this.icon, required this.iconColor, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

class _AlignmentButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _AlignmentButton({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? theme.primaryColor : Colors.transparent),
        ),
        child: Icon(icon, size: 20, color: isSelected ? theme.colorScheme.surface : theme.primaryColor),
      ),
    );
  }
}
