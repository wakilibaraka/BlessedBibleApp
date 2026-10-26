import 'package:flutter/material.dart';

import '../../state/typography_provider.dart';
import '../../utils/prose.dart';
import '../../utils/span_marks.dart';
import 'verse_link_text.dart';

/// The text a paragraph renders as once `**bold**` / `__underline__` markup
/// is stripped; mark offsets are counted over this.
String renderedParagraph(String paragraph) =>
    splitMarkupSegments(paragraph).map((s) => s.text).join();

/// The whole of [text] as [ProseText] renders it: paragraphs joined by a
/// single newline. Mark offsets are counted over this string.
String renderedProse(String text) =>
    proseParagraphs(text).map(renderedParagraph).join('\n');

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

  /// Styled ranges over [renderedProse] of [text]: paragraphs joined by one
  /// newline, markup stripped. Used for story highlights and underlines.
  final List<SpanMark> marks;

  const ProseText({
    super.key,
    required this.text,
    required this.typography,
    required this.accent,
    this.baseStyle,
    this.refined = true,
    this.paragraphGap,
    this.marks = const [],
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
    final starts = <int>[];
    var cursor = 0;
    for (final p in paragraphs) {
      starts.add(cursor);
      cursor += renderedParagraph(p).length + 1;
    }
    List<SpanMark> marksFor(int i) {
      if (marks.isEmpty) return const [];
      final start = starts[i];
      final end = start + renderedParagraph(paragraphs[i]).length;
      return [
        for (final m in marks)
          if (m.end > start && m.start < end)
            (
              start: (m.start - start).clamp(0, end - start),
              end: (m.end - start).clamp(0, end - start),
              style: m.style,
            ),
      ];
    }

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
              marks: marksFor(i),
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
