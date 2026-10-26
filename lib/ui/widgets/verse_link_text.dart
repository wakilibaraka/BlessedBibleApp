import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../utils/passage.dart';
import '../../utils/span_marks.dart';
import '../../utils/verse_linker.dart';
import 'verse_preview_modal.dart';

/// Reserved visual style for dictionary words (future hook): dotted
/// gray underline — deliberately distinct from the solid accent
/// underline of tappable verse numbers. Not applied anywhere yet;
/// Read keeps its existing dotted-primary dictionary underlines.
TextStyle dictionaryWordStyle(BuildContext context, TextStyle? base) {
  final theme = Theme.of(context);
  return (base ?? const TextStyle()).copyWith(
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.dotted,
    decorationColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
  );
}

/// One bold-markup segment: `**text**` becomes bold, asterisks hidden.
typedef BoldSegment = ({String text, bool bold});

/// One formatted markup segment: `**text**` is bold, `__text__` underlined.
typedef MarkupSegment = ({String text, bool bold, bool underline});

final RegExp _markupExp = RegExp(r'\*\*(.+?)\*\*|__(.+?)__');

/// Splits `**bold**` and `__underline__` markers out of plain text. Unmatched
/// markers are kept as literal text. Shared by commentary and story surfaces.
List<MarkupSegment> splitMarkupSegments(String text) {
  final segments = <MarkupSegment>[];
  var start = 0;
  for (final match in _markupExp.allMatches(text)) {
    if (match.start > start) {
      segments.add((
        // Stray `**` runs come from OCR in the older content packs; strip
        // them so they never show up mid-sentence.
        text: text.substring(start, match.start).replaceAll('**', ''),
        bold: false,
        underline: false
      ));
    }
    final bold = match.group(1);
    segments.add((
      text: (bold ?? match.group(2)) ?? '',
      bold: bold != null,
      underline: bold == null,
    ));
    start = match.end;
  }
  if (start < text.length) {
    segments.add((
      text: text.substring(start).replaceAll('**', ''),
      bold: false,
      underline: false
    ));
  }
  if (segments.isEmpty) {
    segments.add((text: text, bold: false, underline: false));
  }
  return segments;
}

/// Bold-only view of [splitMarkupSegments], kept for callers that render
/// underline themselves.
List<BoldSegment> splitBoldSegments(String text) => splitMarkupSegments(text)
    .map((segment) => (text: segment.text, bold: segment.bold))
    .toList(growable: false);

class VerseLinkText extends StatefulWidget {
  final String text;
  final TextStyle? defaultStyle;
  final TextStyle? referenceStyle;
  final TextStyle? numberStyle;
  final TextAlign textAlign;

  /// When true, `**bold**` markers are parsed first (asterisks hidden,
  /// bold applied) and verse links are detected inside every segment —
  /// including bold ones.
  final bool parseBold;
  final TextStyle? boldStyle;

  /// When true, `**bold**` and `__underline__` are both parsed before verse
  /// links are detected. Supersedes [parseBold].
  final bool parseMarkup;
  final TextStyle? underlineStyle;

  /// Styled ranges (highlights, underlines) over the rendered text, i.e.
  /// after markup is stripped. See [applySpanMarks].
  final List<SpanMark> marks;

  const VerseLinkText({
    super.key,
    required this.text,
    this.defaultStyle,
    this.referenceStyle,
    this.numberStyle,
    this.textAlign = TextAlign.start,
    this.parseBold = false,
    this.boldStyle,
    this.parseMarkup = false,
    this.underlineStyle,
    this.marks = const [],
  });

  @override
  State<VerseLinkText> createState() => _VerseLinkTextState();
}

class _VerseLinkTextState extends State<VerseLinkText> {
  final List<TapGestureRecognizer> _recognizers = [];
  late List<InlineSpan> _spans;

  @override
  void initState() {
    super.initState();
    _buildSpans();
  }

  @override
  void didUpdateWidget(VerseLinkText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.defaultStyle != widget.defaultStyle ||
        oldWidget.referenceStyle != widget.referenceStyle ||
        oldWidget.numberStyle != widget.numberStyle ||
        oldWidget.parseBold != widget.parseBold ||
        oldWidget.boldStyle != widget.boldStyle ||
        oldWidget.parseMarkup != widget.parseMarkup ||
        oldWidget.underlineStyle != widget.underlineStyle) {
      _disposeRecognizers();
      _buildSpans();
    }
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _buildSpans() {
    _spans = [];
    final List<MarkupSegment> segments;
    if (widget.parseMarkup) {
      segments = splitMarkupSegments(widget.text);
    } else if (widget.parseBold) {
      segments = splitBoldSegments(widget.text)
          .map((s) => (text: s.text, bold: s.bold, underline: false))
          .toList(growable: false);
    } else {
      segments = [(text: widget.text, bold: false, underline: false)];
    }
    for (final segment in segments) {
      var segmentStyle = widget.defaultStyle;
      if (segment.bold) {
        segmentStyle = widget.boldStyle ??
            widget.defaultStyle?.copyWith(fontWeight: FontWeight.bold);
      }
      if (segment.underline) {
        segmentStyle = widget.underlineStyle ??
            (segmentStyle ?? const TextStyle()).copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
            );
      }
      _spans.addAll(
        VerseLinker.parse(
          segment.text,
          defaultStyle: segmentStyle,
          referenceStyle: widget.referenceStyle,
          numberStyle: widget.numberStyle,
          recognizerBuilder: (reference) {
            final recognizer = TapGestureRecognizer()
              ..onTap = () => _handleTap(reference);
            _recognizers.add(recognizer);
            return recognizer;
          },
        ),
      );
    }
  }

  void _handleTap(String reference) =>
      showVersePreviewSheet(context, reference);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: widget.textAlign,
      // RichText ignores the system text size unless told otherwise.
      textScaler: MediaQuery.textScalerOf(context),
      // Selectable inside a SelectionArea; no effect elsewhere.
      selectionRegistrar: SelectionContainer.maybeOf(context),
      selectionColor: DefaultSelectionStyle.of(context).selectionColor ??
          DefaultSelectionStyle.defaultColor,
      text: TextSpan(children: applySpanMarks(_spans, widget.marks)),
    );
  }
}

/// Opens [reference] ("Book C", "Book C:V", "Book C:V-V" or "Book C:V-C:V")
/// in the verse preview sheet. Unparseable refs are ignored (no dead taps).
/// [heightFactor] caps the sheet's height as a share of the screen.
void showVersePreviewSheet(
  BuildContext context,
  String reference, {
  double heightFactor = 0.6,
}) {
  final passage = PassageRef.parse(reference);
  if (passage == null) return;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * heightFactor),
        child: VersePreviewModal(
          reference: reference,
          bookName: passage.bookName,
          chapter: passage.chapter,
          startVerse: passage.startVerse,
          endVerse: passage.endVerse,
          endChapter: passage.endChapter,
          wholeChapter: passage.wholeChapter,
        ),
      );
    },
  );
}
