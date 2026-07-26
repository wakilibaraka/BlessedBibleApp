import 'dart:math';
import 'package:flutter/material.dart';

class AppTypography {
  /// Generates a proportionally scaled TextTheme based on a baseFontSize
  /// Ratio: 1.25 (Major Third)
  /// Headings & Body: Gentium Book Plus
  /// Captions: Inter (sans-serif)
  static TextTheme getTheme(Color textColor, Color captionColor, double baseFontSize, String fontFamily) {
    const double ratio = 1.25;
    final String? resolvedFontFamily = fontFamily == 'System' ? null : fontFamily;

    return TextTheme(
      // Display/Headings
      displayLarge: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 4), fontWeight: FontWeight.bold, height: 1.2),
      displayMedium: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 3), fontWeight: FontWeight.bold, height: 1.2),
      displaySmall: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 2), fontWeight: FontWeight.w600, height: 1.2),
      headlineLarge: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 1.5), fontWeight: FontWeight.w600, height: 1.2),
      headlineMedium: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 1.25), fontWeight: FontWeight.w600, height: 1.2),
      headlineSmall: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize * ratio, fontWeight: FontWeight.w600, height: 1.3),
      
      // Titles
      titleLarge: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize * ratio, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 0.5), fontWeight: FontWeight.bold, height: 1.4),
      titleSmall: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize, fontWeight: FontWeight.bold, height: 1.4),
      
      // Body
      bodyLarge: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize * pow(ratio, 0.5), height: 1.6),
      bodyMedium: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize, height: 1.6),
      bodySmall: TextStyle(fontFamily: resolvedFontFamily, color: textColor, fontSize: baseFontSize / pow(ratio, 0.5), height: 1.5),
      
      // Captions / Labels (Sans-serif)
      labelLarge: TextStyle(fontFamily: 'Inter', color: captionColor, fontSize: baseFontSize / ratio, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelMedium: TextStyle(fontFamily: 'Inter', color: captionColor, fontSize: baseFontSize / pow(ratio, 1.5), fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: TextStyle(fontFamily: 'Inter', color: captionColor, fontSize: baseFontSize / pow(ratio, 2), fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }
}
