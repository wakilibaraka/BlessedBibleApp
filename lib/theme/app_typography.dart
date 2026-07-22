import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  /// Serif for Headings and Body
  static TextTheme serifTextTheme(Color textColor, Color captionColor) {
    return GoogleFonts.merriweatherTextTheme(
      TextTheme(
        displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textColor, fontSize: 18, height: 1.6),
        bodyMedium: TextStyle(color: textColor, fontSize: 16, height: 1.5),
        bodySmall: TextStyle(color: textColor, fontSize: 14, height: 1.4),
        // Overridden below with Sans-serif for captions
        labelLarge: TextStyle(color: captionColor),
        labelMedium: TextStyle(color: captionColor),
        labelSmall: TextStyle(color: captionColor),
      ),
    );
  }

  /// Sans-serif for Captions, Overlines, and small UI elements
  static TextStyle sansCaption(Color color) {
    return GoogleFonts.inter(
      color: color,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    );
  }

  static TextStyle sansLabel(Color color) {
    return GoogleFonts.inter(
      color: color,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
  }
}
