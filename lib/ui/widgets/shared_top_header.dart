import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/theme_provider.dart';
import '../sheets/theme_picker_sheet.dart';

class SharedTopHeader extends ConsumerWidget {
  final Widget? leading;
  final Widget centerContent;
  final Widget? trailing;

  const SharedTopHeader({
    super.key,
    this.leading,
    required this.centerContent,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading strictly sized — identical vertical center to trailing
          SizedBox(
            width: 48,
            height: 48,
            child: leading ?? _buildDefaultLeading(theme, isDarkMode),
          ),

          // Center truly expanded — content is centered within all remaining space
          Expanded(
            child: Center(
              child: centerContent,
            ),
          ),

          // Trailing strictly sized — equal width/height to leading
          SizedBox(
            width: 48,
            height: 48,
            child: trailing ?? _buildDefaultTrailing(context, ref, theme, appThemeMode),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLeading(ThemeData theme, bool isDarkMode) {
    return Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: Icon(
          Icons.menu_book_rounded,
          size: 26,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDefaultTrailing(BuildContext context, WidgetRef ref, ThemeData theme, AppThemeMode appThemeMode) {
    return Center(
      child: GestureDetector(
        onTap: () {
          ThemePickerSheet.show(context);
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween<double>(begin: 0.75, end: 1.0).animate(anim),
            child: FadeTransition(opacity: anim, alwaysIncludeSemantics: true, child: child),
          ),
          child: switch (appThemeMode) {
            AppThemeMode.automatic => Icon(
                Icons.brightness_auto,
                key: const ValueKey('automatic'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.light => Icon(
                Icons.wb_sunny_outlined,
                key: const ValueKey('light'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.dark => Icon(
              Icons.dark_mode_rounded,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            AppThemeMode.oled => Icon(
                Icons.nightlight_round,
                key: const ValueKey('dark'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.sepia => Icon(
                Icons.cloud_outlined,
                key: const ValueKey('sepia'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.dawn => Icon(
                Icons.wb_twilight_outlined,
                key: const ValueKey('dawn'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.lilies => Icon(
                Icons.spa_outlined,
                key: const ValueKey('lilies'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.roses => Icon(
                Icons.local_florist_outlined,
                key: const ValueKey('roses'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.olives => Icon(
                Icons.eco_outlined,
                key: const ValueKey('olives'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.dusk => Icon(
                Icons.nature_outlined,
                key: const ValueKey('dusk'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.fresh => Icon(
                Icons.nights_stay_rounded,
                key: const ValueKey('fresh'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.priestlyPurple => Icon(
                Icons.church_outlined,
                key: const ValueKey('priestlyPurple'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.galileeBlue => Icon(
                Icons.water_drop_outlined,
                key: const ValueKey('galileeBlue'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.scarletRed => Icon(
                Icons.local_fire_department_outlined,
                key: const ValueKey('scarletRed'),
                size: 26,
                color: theme.primaryColor,
              ),
          },
        ),
      ),
    );
  }
}
