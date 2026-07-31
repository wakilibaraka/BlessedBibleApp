import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../state/theme_provider.dart';
import '../../theme/app_colors.dart';

class ThemePickerSheet extends ConsumerWidget {
  const ThemePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(themeProvider);

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handlebar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Themes',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Match system appearance'),
                value: currentMode == AppThemeMode.automatic,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  if (value) {
                    ref.read(themeProvider.notifier).setTheme(AppThemeMode.automatic);
                  } else {
                    final resolved = AppThemeMode.automatic.resolve(context);
                    ref.read(themeProvider.notifier).setTheme(resolved);
                  }
                },
              ),
              const SizedBox(height: 16),

              Text(
                'CLASSIC',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.primaryColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ThemePill(
                    label: 'Light',
                    mode: AppThemeMode.light,
                    currentMode: currentMode,
                    swatchColors: const [AppColors.lightBackground, AppColors.lightSurface, AppColors.lightAccent],
                  ),
                  _ThemePill(
                    label: 'Sepia',
                    mode: AppThemeMode.sepia,
                    currentMode: currentMode,
                    swatchColors: const [AppColors.sepiaBackground, AppColors.sepiaSurface, AppColors.sepiaTextPrimary],
                  ),
                  _ThemePill(
                    label: 'Dark',
                    mode: AppThemeMode.dark,
                    currentMode: currentMode,
                    swatchColors: const [AppColors.darkBackground, AppColors.darkSurface, AppColors.darkTextPrimary],
                  ),
                  _ThemePill(
                    label: 'OLED',
                    mode: AppThemeMode.oled,
                    currentMode: currentMode,
                    swatchColors: const [Colors.black, Colors.black87, Colors.white],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                '3D POP',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.primaryColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ThemePill(
                    label: 'Purple',
                    mode: AppThemeMode.pop,
                    currentMode: currentMode,
                    swatchColors: const [AppColors.popPrimary, AppColors.popAccent, AppColors.popHighlight],
                  ),
                  _ThemePill(
                    label: 'Dusk',
                    mode: AppThemeMode.dusk,
                    currentMode: currentMode,
                    swatchColors: const [AppColors.duskPrimary, AppColors.duskAccent, AppColors.duskBackground],
                  ),
                  _ThemePill(
                    label: 'Fresh',
                    mode: AppThemeMode.fresh,
                    currentMode: currentMode,
                    swatchColors: const [AppColors.freshPrimary, AppColors.freshAccent, AppColors.freshHighlight],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePill extends ConsumerWidget {
  final String label;
  final AppThemeMode mode;
  final AppThemeMode currentMode;
  final List<Color> swatchColors;

  const _ThemePill({
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.swatchColors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = currentMode == mode || (currentMode == AppThemeMode.automatic && mode == AppThemeMode.automatic.resolve(context) && mode != AppThemeMode.automatic);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(themeProvider.notifier).setTheme(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withValues(alpha: 0.15) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: theme.primaryColor, width: 2) : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(colors: [...swatchColors, swatchColors.first]),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.2), width: 1),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
