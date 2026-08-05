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
  static const Color warmGoldSurface = Color(0xFFEFE3C3);
  static const Color warmGoldTextPrimary = Color(0xFF2C221E);
  static const Color warmGoldTextSecondary = Color(0xFF5C4B41);
  static const Color warmGoldBorder = Color(0xFFD8CDB6);
  static const Color warmGoldAccent = Color(0xFF9E6B00);

  // Dark Theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFEAE6E1);
  static const Color darkTextSecondary = Color(0xFFAFAAA3);
  static const Color darkBorder = Color(0xFF3F3C39);

  // Themed Sepia (Dawn - soft plum-grey twilight / peach sunrise)
  static const Color dawnBackground = Color(0xFF2E2A3A);
  static const Color dawnSurface = Color(0xFF3A3547);
  static const Color dawnTextPrimary = Color(0xFFEDE9F0);
  static const Color dawnTextSecondary = Color(0xFFA9A2B5);
  static const Color dawnBorder = Color(0xFF453F52);
  static const Color dawnPrimary = Color(0xFFE8A87C);
  static const Color dawnAccent = Color(0xFFE8A87C);
  static const Color dawnHighlight = Color(0xFFE8A87C);

  // 3D Pop Theme (Lilies - soft pastel pink / baby blue / pale claymorphic)
  static const Color liliesBackground = Color(0xFFFCE4EC);
  static const Color liliesSurface = Color(0xFFFDF6F8);
  static const Color liliesTextPrimary = Color(0xFF4A4045);
  static const Color liliesTextSecondary = Color(0xFF8E7C85);
  static const Color liliesBorder = Color(0xFFE8CEDB);
  static const Color liliesPrimary = Color(0xFF8CB9D1);
  static const Color liliesAccent = Color(0xFFF4A8C4);
  static const Color liliesHighlight = Color(0xFFBCE3F5);

  // 3D Pop Theme (Roses - coral / rose-gold / warm floral)
  static const Color rosesBackground = Color(0xFFFBE4D8);
  static const Color rosesSurface = Color(0xFFFFF2EB);
  static const Color rosesTextPrimary = Color(0xFF523326);
  static const Color rosesTextSecondary = Color(0xFF996B58);
  static const Color rosesBorder = Color(0xFFEACBB8);
  static const Color rosesPrimary = Color(0xFFDE7456);
  static const Color rosesAccent = Color(0xFFB95A4B);
  static const Color rosesHighlight = Color(0xFFFFC0A8);

  // 3D Pop Theme (Olives - muted olive / sage green / nature)
  static const Color olivesBackground = Color(0xFFE3E8DB);
  static const Color olivesSurface = Color(0xFFF0F2EB);
  static const Color olivesTextPrimary = Color(0xFF2F3E2F);
  static const Color olivesTextSecondary = Color(0xFF5F755F);
  static const Color olivesBorder = Color(0xFFCBD4C1);
  static const Color olivesPrimary = Color(0xFF556B2F);
  static const Color olivesAccent = Color(0xFF3A4D1F);
  static const Color olivesHighlight = Color(0xFFB8CBA1);

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
  static Color getRenderedHighlightColor(
      Color baseColor, Brightness brightness, Color scaffoldBackgroundColor) {
    Color finalColor = baseColor;
    
    if (baseColor == const Color(0xFFFEF08A)) {
      if (scaffoldBackgroundColor == sepiaBackground ||
          scaffoldBackgroundColor == warmGoldBackground) {
        finalColor = Colors.amber.shade700; // Deeper, more saturated yellow-gold for sepia themes
      }
    }
    
    // Reduce the intensity for readability. 
    // In dark themes, bright pastels need very low opacity to not wash out the white text.
    // In light themes, they need moderate opacity so the dark text remains readable.
    if (brightness == Brightness.dark) {
      return finalColor.withValues(alpha: 0.35); // 50% reduction from 0.85
    } else {
      return finalColor.withValues(alpha: 0.55); // ~30% reduction from 0.85
    }
  }
}
