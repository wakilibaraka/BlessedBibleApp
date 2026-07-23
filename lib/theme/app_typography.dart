import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  /// Generates a proportionally scaled TextTheme based on a baseFontSize
  /// Ratio: 1.25 (Major Third)
  /// Headings & Body: Gentium Book Plus
  /// Captions: Inter (sans-serif)
  static TextTheme getTheme(Color textColor, Color captionColor, double baseFontSize, String fontFamily) {
    const double ratio = 1.25;

    return TextTheme(
      // Display/Headings
      displayLarge: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 4), fontWeight: FontWeight.bold, height: 1.2),
      displayMedium: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 3), fontWeight: FontWeight.bold, height: 1.2),
      displaySmall: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 2), fontWeight: FontWeight.w600, height: 1.2),
      headlineLarge: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 1.5), fontWeight: FontWeight.w600, height: 1.2),
      headlineMedium: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 1.25), fontWeight: FontWeight.w600, height: 1.2),
      headlineSmall: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize * ratio, fontWeight: FontWeight.w600, height: 1.3),
      
      // Titles
      titleLarge: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize * ratio, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 0.5), fontWeight: FontWeight.bold, height: 1.4),
      titleSmall: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize, fontWeight: FontWeight.bold, height: 1.4),
      
      // Body
      bodyLarge: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 0.5), height: 1.6),
      bodyMedium: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize, height: 1.6),
      bodySmall: GoogleFonts.getFont(fontFamily, color: textColor, fontSize: baseFontSize / pow(ratio, 0.5), height: 1.5),
      
      // Captions / Labels (Sans-serif)
      labelLarge: GoogleFonts.inter(color: captionColor, fontSize: baseFontSize / ratio, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelMedium: GoogleFonts.inter(color: captionColor, fontSize: baseFontSize / pow(ratio, 1.5), fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: GoogleFonts.inter(color: captionColor, fontSize: baseFontSize / pow(ratio, 2), fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }
}
