import 'package:flutter/material.dart';

class AppColors {
  // Shared
  static const Color goldAccent = Color(0xFFC9A227);
  static const Color transparent = Colors.transparent;

  // Light Theme (Modern Glass Ivory)
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1D1D1F);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
  static const Color lightBorder = Color(0xFFE5E5EA);
  static const Color lightAccent = Color(0xFFB8860B);

  // Sepia Theme
  static const Color sepiaBackground = Color(0xFFF0E5D1);
  static const Color sepiaSurface = Color(0xFFF8EFE0);
  static const Color sepiaTextPrimary = Color(0xFF4A3B32);
  static const Color sepiaTextSecondary = Color(0xFF7A6B62);
  static const Color sepiaBorder = Color(0xFFD6C8B3);

  // Warm Gold / Amber Glow Theme (Matte Sepia)
  static const Color warmGoldBackground = Color(0xFFF4EAD5);
  static const Color warmGoldSurface    = Color(0xFFEFE3C3);
  static const Color warmGoldTextPrimary    = Color(0xFF2C221E);
  static const Color warmGoldTextSecondary  = Color(0xFF5C4B41);
  static const Color warmGoldBorder     = Color(0xFFD8CDB6);
  static const Color warmGoldAccent     = Color(0xFF9E6B00);

  // Dark Theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFEAE6E1);
  static const Color darkTextSecondary = Color(0xFFAFAAA3);
  static const Color darkBorder = Color(0xFF3F3C39);

  // 3D Pop Theme (Palette A "Pop")
  static const Color popBackground = Color(0xFFF4F5F7);
  static const Color popSurface = Color(0xFFFFFFFF);
  static const Color popTextPrimary = Color(0xFF000000);
  static const Color popTextSecondary = Color(0xFF4A4A52);
  static const Color popBorder = Color(0xFFE2E2EB);
  static const Color popPrimary = Color(0xFF752FFF);
  static const Color popAccent = Color(0xFFFE3A3A);
  static const Color popHighlight = Color(0xFFFFBB01);

  // 3D Pop Theme (Palette B "Dusk")
  static const Color duskBackground = Color(0xFF312C51);
  static const Color duskSurface = Color(0xFF48426D);
  static const Color duskTextPrimary = Color(0xFFFFFFFF);
  static const Color duskTextSecondary = Color(0xFFB4A8D6);
  static const Color duskBorder = Color(0xFF5A5288);
  static const Color duskPrimary = Color(0xFFF1AA9D);
  static const Color duskAccent = Color(0xFFF0D39E);
  static const Color duskHighlight = Color(0xFFF0D39E);

  // 3D Pop Theme (Palette C "Fresh")
  static const Color freshBackground = Color(0xFF132C33);
  static const Color freshSurface = Color(0xFF1C404A);
  static const Color freshTextPrimary = Color(0xFFFFFFFF);
  static const Color freshTextSecondary = Color(0xFF90B3B9);
  static const Color freshBorder = Color(0xFF265460);
  static const Color freshPrimary = Color(0xFFD8B4E2); // lavender
  static const Color freshAccent = Color(0xFFFFD3B6); // peach
  static const Color freshHighlight = Color(0xFFD4E157); // lime

  /// Helper to ensure highlight colors render beautifully and with adequate WCAG AA contrast against specific backgrounds.
  /// For example, the default yellow highlight clashes with the Sepia/Cream backgrounds.
  static Color getRenderedHighlightColor(Color baseColor, Brightness brightness, Color scaffoldBackgroundColor) {
    if (baseColor == const Color(0xFFFEF08A)) {
      if (scaffoldBackgroundColor == sepiaBackground || scaffoldBackgroundColor == warmGoldBackground) {
        return Colors.amber.shade700; // Deeper, more saturated yellow-gold for sepia themes
      }
    }
    return baseColor;
  }
}
