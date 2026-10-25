import 'package:flutter/material.dart';

import '../../state/typography_provider.dart';
import '../../utils/prose.dart';
import 'verse_link_text.dart';

/// Long-form body text with the content packs' hard wraps repaired.
///
/// Paragraphs come from [proseParagraphs] (blank lines only), `**bold**` and
/// `__underline__` are rendered, and scripture references stay tappable.
class ProseText extends StatelessWidget {
  final String text;
  final TypographyState typography;
  final TextStyle? baseStyle;
  final Color accent;
  final bool refined;

  /// Space below every paragraph but the last. Defaults to 18 (refined) or
  /// 16 (classic).
  final double? paragraphGap;

  const ProseText({
    super.key,
    required this.text,
    required this.typography,
    required this.accent,
    this.baseStyle,
    this.refined = true,
    this.paragraphGap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = baseStyle ??
        theme.textTheme.bodyLarge?.copyWith(
          fontSize: typography.fontSize,
          height: typography.lineHeight,
          fontFamily: typography.fontFamily,
          fontStyle: typography.fontStyle,
          fontWeight: typography.fontWeight,
        );
    final paragraphs = proseParagraphs(text);
    final gap = paragraphGap ?? (refined ? 18.0 : 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < paragraphs.length; i++)
          Padding(
            padding:
                EdgeInsets.only(bottom: i == paragraphs.length - 1 ? 0 : gap),
            child: VerseLinkText(
              text: paragraphs[i],
              parseMarkup: true,
              defaultStyle: style,
              referenceStyle: style?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
              numberStyle: style?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.solid,
              ),
              underlineStyle: style?.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: accent.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}
