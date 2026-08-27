import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'reading_tokens.dart';

class AppTheme {
  static ThemeData lightTheme(double baseFontSize) {
    final textTheme = AppTypography.getTheme(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightAccent,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAccent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightAccent,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder),
      extensions: const [
        ReadingTokens(
          readingPaper: AppColors.lightBackground,
          readingSurface: AppColors.lightSurface,
          readingInk: AppColors.lightTextPrimary,
          readingInkMuted: AppColors.lightTextSecondary,
          readingAccent: AppColors.lightAccent,
          readingBorder: AppColors.lightBorder,
        ),
      ],
    );
  }

  static ThemeData sepiaTheme(double baseFontSize) {
    final textTheme = AppTypography.getTheme(
      AppColors.sepiaTextPrimary,
      AppColors.sepiaTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.warmGoldBackground,
      primaryColor: AppColors.warmGoldAccent,
      colorScheme: const ColorScheme.light(
        primary: AppColors.warmGoldAccent,
        surface: AppColors.warmGoldSurface,
        onSurface: AppColors.warmGoldTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmGoldBackground,
        foregroundColor: AppColors.warmGoldTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.warmGoldSurface,
        selectedItemColor: AppColors.warmGoldAccent,
        unselectedItemColor: AppColors.warmGoldTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.warmGoldBorder),
      extensions: const [
        ReadingTokens(
          readingPaper: AppColors.warmGoldBackground,
          readingSurface: AppColors.warmGoldSurface,
          readingInk: AppColors.sepiaTextPrimary,
          readingInkMuted: AppColors.sepiaTextSecondary,
          readingAccent: AppColors.warmGoldAccent,
          readingBorder: AppColors.warmGoldBorder,
        ),
      ],
    );
  }

  static ThemeData darkTheme(double baseFontSize, {bool isAmoled = false}) {
    final textTheme = AppTypography.getTheme(
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
      baseFontSize,
    );

    final backgroundColor =
        isAmoled ? const Color(0xFF000000) : AppColors.darkBackground;
    final surfaceColor =
        isAmoled ? const Color(0xFF101010) : AppColors.darkSurface;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: AppColors.goldAccent,
      colorScheme: ColorScheme.dark(
        primary: AppColors.goldAccent,
        surface: surfaceColor,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: AppColors.goldAccent,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder),
      extensions: [
        ReadingTokens(
          readingPaper: backgroundColor,
          readingSurface: surfaceColor,
          readingInk: AppColors.darkTextPrimary,
          readingInkMuted: AppColors.darkTextSecondary,
          readingAccent: AppColors.goldAccent,
          readingBorder: AppColors.darkBorder,
        ),
      ],
    );
  }

  static ThemeData dawnTheme(double baseFontSize) {
    final textTheme = AppTypography.getTheme(
      AppColors.dawnTextPrimary,
      AppColors.dawnTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dawnBackground,
      canvasColor: AppColors.dawnSurface,
      primaryColor: AppColors.dawnPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.dawnPrimary,
        secondary: AppColors.dawnAccent,
        surface: AppColors.dawnSurface,
        onSurface: AppColors.dawnTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.dawnBackground,
        foregroundColor: AppColors.dawnTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.dawnSurface,
        modalBackgroundColor: AppColors.dawnSurface,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.dawnSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.dawnSurface,
        selectedItemColor: AppColors.dawnPrimary,
        unselectedItemColor: AppColors.dawnTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.dawnBorder),
      extensions: const [
        ReadingTokens(
          readingPaper: Color(0xFF26232F),
          readingSurface: Color(0xFF302C3A),
          readingInk: Color(0xFFE8E4EC),
          readingInkMuted: Color(0xFF9E97AA),
          readingAccent: Color(0xFFE8A87C),
          readingBorder: Color(0xFF3A3546),
        ),
      ],
    );
  }

  static ThemeData liliesTheme(double baseFontSize) {
    final textTheme = AppTypography.getTheme(
      AppColors.liliesTextPrimary,
      AppColors.liliesTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.liliesBackground,
      canvasColor: AppColors.liliesSurface,
      primaryColor: AppColors.liliesPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.liliesPrimary,
        secondary: AppColors.liliesAccent,
        surface: AppColors.liliesSurface,
        onSurface: AppColors.liliesTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.liliesBackground,
        foregroundColor: AppColors.liliesTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.liliesSurface,
        modalBackgroundColor: AppColors.liliesSurface,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.liliesSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.liliesSurface,
        selectedItemColor: AppColors.liliesPrimary,
        unselectedItemColor: AppColors.liliesTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.liliesBorder),
      extensions: const [
        ReadingTokens(
          readingPaper: AppColors.liliesBackground,
          readingSurface: AppColors.liliesSurface,
          readingInk: AppColors.liliesTextPrimary,
          readingInkMuted: AppColors.liliesTextSecondary,
          readingAccent: AppColors.liliesPrimary,
          readingBorder: AppColors.liliesBorder,
        ),
      ],
    );
  }

  static ThemeData rosesTheme(double baseFontSize) {
    final textTheme = AppTypography.getTheme(
      AppColors.rosesTextPrimary,
      AppColors.rosesTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.rosesBackground,
      canvasColor: AppColors.rosesSurface,
      primaryColor: AppColors.rosesPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.rosesPrimary,
        secondary: AppColors.rosesAccent,
        surface: AppColors.rosesSurface,
        onSurface: AppColors.rosesTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.rosesBackground,
        foregroundColor: AppColors.rosesTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.rosesSurface,
        modalBackgroundColor: AppColors.rosesSurface,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.rosesSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.rosesSurface,
        selectedItemColor: AppColors.rosesPrimary,
        unselectedItemColor: AppColors.rosesTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.rosesBorder),
      extensions: const [
        ReadingTokens(
          readingPaper: AppColors.rosesBackground,
          readingSurface: AppColors.rosesSurface,
          readingInk: AppColors.rosesTextPrimary,
          readingInkMuted: AppColors.rosesTextSecondary,
          readingAccent: AppColors.rosesPrimary,
          readingBorder: AppColors.rosesBorder,
        ),
      ],
    );
  }

  static ThemeData olivesTheme(double baseFontSize) {
    final textTheme = AppTypography.getTheme(
      AppColors.olivesTextPrimary,
      AppColors.olivesTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.olivesBackground,
      canvasColor: AppColors.olivesSurface,
      primaryColor: AppColors.olivesPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.olivesPrimary,
        secondary: AppColors.olivesAccent,
        surface: AppColors.olivesSurface,
        onSurface: AppColors.olivesTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.olivesBackground,
        foregroundColor: AppColors.olivesTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.olivesSurface,
        selectedItemColor: AppColors.olivesPrimary,
        unselectedItemColor: AppColors.olivesTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.olivesBorder),
      extensions: const [
        ReadingTokens(
          readingPaper: AppColors.olivesBackground,
          readingSurface: AppColors.olivesSurface,
          readingInk: AppColors.olivesTextPrimary,
          readingInkMuted: AppColors.olivesTextSecondary,
          readingAccent: AppColors.olivesPrimary,
          readingBorder: AppColors.olivesBorder,
        ),
      ],
    );
  }

  static ThemeData duskTheme(double baseFontSize) {
    final textTheme = AppTypography.getTheme(
      AppColors.duskTextPrimary,
      AppColors.duskTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.duskBackground,
      canvasColor: AppColors.duskSurface,
      primaryColor: AppColors.duskPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.duskPrimary,
        secondary: AppColors.duskAccent,
        surface: AppColors.duskSurface,
        onSurface: AppColors.duskTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.duskBackground,
        foregroundColor: AppColors.duskTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.duskSurface,
        modalBackgroundColor: AppColors.duskSurface,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.duskSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.duskSurface,
        selectedItemColor: AppColors.duskPrimary,
        unselectedItemColor: AppColors.duskTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.duskBorder),
      extensions: const [
        ReadingTokens(
          readingPaper: Color(0xFF1A1826),
          readingSurface: Color(0xFF232133),
          readingInk: Color(0xFFE6E5ED),
          readingInkMuted: Color(0xFF9D9AA8),
          readingAccent: Color(0xFFF0C14B), // Adjusted to warm gold
          readingBorder: Color(0xFF38354A),
        ),
      ],
    );
  }

  static ThemeData freshTheme(double baseFontSize) {
    final textTheme = AppTypography.getTheme(
      AppColors.freshTextPrimary,
      AppColors.freshTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.freshBackground,
      canvasColor: AppColors.freshSurface,
      primaryColor: AppColors.freshPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.freshPrimary,
        secondary: AppColors.freshAccent,
        surface: AppColors.freshSurface,
        onSurface: AppColors.freshTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.freshBackground,
        foregroundColor: AppColors.freshTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.freshSurface,
        modalBackgroundColor: AppColors.freshSurface,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.freshSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.freshSurface,
        selectedItemColor: AppColors.freshPrimary,
        unselectedItemColor: AppColors.freshTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.freshBorder),
      extensions: const [
        ReadingTokens(
          readingPaper: Color(0xFF0F1A1C),
          readingSurface: Color(0xFF172629),
          readingInk: Color(0xFFE3EAEB),
          readingInkMuted: Color(0xFF8FA3A6),
          readingAccent: Color(0xFFD8B4E2),
          readingBorder: Color(0xFF283A3D),
        ),
      ],
    );
  }

  static ThemeData customAccentTheme(double baseFontSize, Color accentColor) {
    final textTheme = AppTypography.getTheme(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: accentColor,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: accentColor,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: accentColor,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder),
      extensions: [
        ReadingTokens(
          readingPaper: AppColors.lightBackground,
          readingSurface: AppColors.lightSurface,
          readingInk: AppColors.lightTextPrimary,
          readingInkMuted: AppColors.lightTextSecondary,
          readingAccent: accentColor,
          readingBorder: AppColors.lightBorder,
        ),
      ],
    );
  }

  static ThemeData priestlyPurpleTheme(double baseFontSize) =>
      customAccentTheme(baseFontSize, const Color(0xFF673AB7));
  static ThemeData galileeBlueTheme(double baseFontSize) =>
      customAccentTheme(baseFontSize, const Color(0xFF2196F3));
  static ThemeData scarletRedTheme(double baseFontSize) =>
      customAccentTheme(baseFontSize, const Color(0xFFE53935));
}

extension PaperlikeTransform on ThemeData {
  ThemeData applyPaperlike() {
    final isDark = brightness == Brightness.dark;
    final tokens = extension<ReadingTokens>();
    if (tokens == null) return this;

    // Preserve light/dark character:
    // Light themes get a warm cream tint, dark themes get a warm charcoal/brown tint.
    final warmTint = isDark ? const Color(0xFF2D2520) : const Color(0xFFF9F5EC);

    Color transformBackground(Color original) {
      // Blend aggressively to ensure a matte, distinct paper feel
      return Color.alphaBlend(warmTint.withValues(alpha: 0.7), original);
    }

    final newPaper = transformBackground(tokens.readingPaper);
    final newSurface = transformBackground(tokens.readingSurface);

    // Boost reading contrast: push ink further towards pure black/white for focused reading
    Color boostInk(Color original) {
      return isDark
          ? Color.lerp(original, Colors.white, 0.45)!
          : Color.lerp(original, Colors.black, 0.45)!;
    }

    final newInk = boostInk(tokens.readingInk);
    final newInkMuted = boostInk(tokens.readingInkMuted);

    final newTokens = tokens.copyWith(
      readingPaper: newPaper,
      readingSurface: newSurface,
      readingInk: newInk,
      readingInkMuted: newInkMuted,
      readingBorder: transformBackground(tokens.readingBorder),
    );

    return copyWith(
      scaffoldBackgroundColor: newPaper,
      canvasColor: newSurface,
      colorScheme: colorScheme.copyWith(
        surface: newSurface,
        onSurface: newInk,
      ),
      extensions: [newTokens],
    );
  }
}
