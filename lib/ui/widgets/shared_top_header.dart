import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/theme_provider.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Leading strictly sized
            SizedBox(
              width: 48,
              height: 48,
              child: leading ?? _buildDefaultLeading(theme, isDarkMode),
            ),
            
            // Center expanded perfectly
            Expanded(
              child: Center(
                child: centerContent,
              ),
            ),
            
            // Trailing strictly sized
            SizedBox(
              width: 48,
              height: 48,
              child: trailing ?? _buildDefaultTrailing(ref, theme, appThemeMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLeading(ThemeData theme, bool isDarkMode) {
    return Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 26,
              color: theme.primaryColor,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFFAF9F6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.add_rounded,
                  size: 10,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultTrailing(WidgetRef ref, ThemeData theme, AppThemeMode appThemeMode) {
    return Center(
      child: GestureDetector(
        onTap: () => ref.read(themeProvider.notifier).cycleTheme(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween<double>(begin: 0.75, end: 1.0).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
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
                Icons.nightlight_round,
                key: const ValueKey('dark'),
                size: 26,
                color: theme.primaryColor,
              ),
            AppThemeMode.sepia => Icon(
                Icons.auto_awesome,
                key: const ValueKey('sepia'),
                size: 26,
                color: theme.primaryColor,
              ),
          },
        ),
      ),
    );
  }
}
