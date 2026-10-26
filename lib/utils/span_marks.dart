import 'package:flutter/painting.dart';

/// A styled range over the plain text of a span tree: [start] inclusive,
/// [end] exclusive, in UTF-16 code units. [style] is merged over the
/// existing style of every character in range.
typedef SpanMark = ({int start, int end, TextStyle style});

/// Applies [marks] to [spans] without changing their text or recognizers,
/// so tappable references keep working inside a highlighted range.
List<InlineSpan> applySpanMarks(List<InlineSpan> spans, List<SpanMark> marks) {
  if (marks.isEmpty) return spans;
  var offset = 0;
  final out = <InlineSpan>[];
  for (final span in spans) {
    final (marked, next) = _mark(span, marks, offset);
    out.add(marked);
    offset = next;
  }
  return out;
}

(InlineSpan, int) _mark(
  InlineSpan span,
  List<SpanMark> marks,
  int offset,
) {
  if (span is! TextSpan) {
    // Placeholders (WidgetSpan) count as one character in a paragraph.
    return (span, offset + 1);
  }
  final text = span.text ?? '';
  final end = offset + text.length;

  final pieces = <InlineSpan>[];
  if (text.isNotEmpty) {
    // Cut points inside this span's text.
    final cuts = <int>{offset, end};
    for (final m in marks) {
      if (m.start > offset && m.start < end) cuts.add(m.start);
      if (m.end > offset && m.end < end) cuts.add(m.end);
    }
    final sorted = cuts.toList()..sort();
    for (var i = 0; i < sorted.length - 1; i++) {
      final a = sorted[i];
      final b = sorted[i + 1];
      TextStyle? extra;
      for (final m in marks) {
        if (m.start <= a && m.end >= b) {
          extra = extra == null ? m.style : extra.merge(m.style);
        }
      }
      pieces.add(TextSpan(
        text: text.substring(a - offset, b - offset),
        style: extra,
        recognizer: span.recognizer,
        mouseCursor: span.mouseCursor,
      ));
    }
  }

  var cursor = end;
  for (final child in span.children ?? const <InlineSpan>[]) {
    final (marked, next) = _mark(child, marks, cursor);
    pieces.add(marked);
    cursor = next;
  }

  final unchanged = pieces.length == 1 &&
      span.children == null &&
      (pieces.first as TextSpan).style == null;
  if (unchanged) return (span, cursor);

  return (
    TextSpan(
      style: span.style,
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      semanticsLabel: span.semanticsLabel,
      children: pieces,
    ),
    cursor,
  );
}
