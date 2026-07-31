import 'package:flutter/material.dart';

class ReadingTokens extends ThemeExtension<ReadingTokens> {
  final Color readingPaper;
  final Color readingSurface;
  final Color readingInk;
  final Color readingInkMuted;
  final Color readingAccent;
  final Color readingBorder;

  const ReadingTokens({
    required this.readingPaper,
    required this.readingSurface,
    required this.readingInk,
    required this.readingInkMuted,
    required this.readingAccent,
    required this.readingBorder,
  });

  @override
  ThemeExtension<ReadingTokens> copyWith({
    Color? readingPaper,
    Color? readingSurface,
    Color? readingInk,
    Color? readingInkMuted,
    Color? readingAccent,
    Color? readingBorder,
  }) {
    return ReadingTokens(
      readingPaper: readingPaper ?? this.readingPaper,
      readingSurface: readingSurface ?? this.readingSurface,
      readingInk: readingInk ?? this.readingInk,
      readingInkMuted: readingInkMuted ?? this.readingInkMuted,
      readingAccent: readingAccent ?? this.readingAccent,
      readingBorder: readingBorder ?? this.readingBorder,
    );
  }

  @override
  ThemeExtension<ReadingTokens> lerp(ThemeExtension<ReadingTokens>? other, double t) {
    if (other is! ReadingTokens) return this;
    return ReadingTokens(
      readingPaper: Color.lerp(readingPaper, other.readingPaper, t)!,
      readingSurface: Color.lerp(readingSurface, other.readingSurface, t)!,
      readingInk: Color.lerp(readingInk, other.readingInk, t)!,
      readingInkMuted: Color.lerp(readingInkMuted, other.readingInkMuted, t)!,
      readingAccent: Color.lerp(readingAccent, other.readingAccent, t)!,
      readingBorder: Color.lerp(readingBorder, other.readingBorder, t)!,
    );
  }
}
