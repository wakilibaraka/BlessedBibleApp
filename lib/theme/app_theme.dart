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
    
    final backgroundColor = isAmoled ? const Color(0xFF000000) : AppColors.darkBackground;
    final surfaceColor = isAmoled ? const Color(0xFF101010) : AppColors.darkSurface;

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

  static ThemeData popTheme(double baseFontSize) {
    final textTheme = AppTypography.getTheme(
      AppColors.popTextPrimary,
      AppColors.popTextSecondary,
      baseFontSize,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.popBackground,
      canvasColor: AppColors.popSurface,
      primaryColor: AppColors.popPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.popPrimary,
        secondary: AppColors.popAccent,
        surface: AppColors.popSurface,
        onSurface: AppColors.popTextPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.popBackground,
        foregroundColor: AppColors.popTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.popSurface,
        modalBackgroundColor: AppColors.popSurface,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.popSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.popSurface,
        selectedItemColor: AppColors.popPrimary,
        unselectedItemColor: AppColors.popTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.popBorder),
      extensions: const [
        ReadingTokens(
          readingPaper: Color(0xFFFAFAFC),
          readingSurface: Color(0xFFFFFFFF),
          readingInk: Color(0xFF23222B),
          readingInkMuted: Color(0xFF696873),
          readingAccent: Color(0xFF6320E0), // Adjusted
          readingBorder: Color(0xFFE8E8EE),
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
}
