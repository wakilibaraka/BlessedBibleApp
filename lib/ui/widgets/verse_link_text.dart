import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

/// Splits `**bold**` markers out of plain text. Unmatched markers are kept
/// as literal text. Shared by commentary and story surfaces.
List<BoldSegment> splitBoldSegments(String text) {
  final segments = <BoldSegment>[];
  final exp = RegExp(r'\*\*(.*?)\*\*');
  var start = 0;
  for (final match in exp.allMatches(text)) {
    if (match.start > start) {
      segments.add((text: text.substring(start, match.start), bold: false));
    }
    segments.add((text: match.group(1) ?? '', bold: true));
    start = match.end;
  }
  if (start < text.length) {
    segments.add((text: text.substring(start), bold: false));
  }
  if (segments.isEmpty) {
    segments.add((text: text, bold: false));
  }
  return segments;
}

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

  const VerseLinkText({
    super.key,
    required this.text,
    this.defaultStyle,
    this.referenceStyle,
    this.numberStyle,
    this.textAlign = TextAlign.start,
    this.parseBold = false,
    this.boldStyle,
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
        oldWidget.boldStyle != widget.boldStyle) {
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
    final segments = widget.parseBold
        ? splitBoldSegments(widget.text)
        : [(text: widget.text, bold: false)];
    for (final segment in segments) {
      final segmentStyle = segment.bold
          ? (widget.boldStyle ??
              widget.defaultStyle?.copyWith(fontWeight: FontWeight.bold))
          : widget.defaultStyle;
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

  void _handleTap(String reference) {
    // Parse VerseLinker output: "Book C", "Book C:V", "Book C:V-V" or
    // "Book C:V-C:V". Unparseable refs are ignored (no dead taps).
    final match = RegExp(
      r'(.+?)\s+(\d+)(?::(\d+)(?:-(\d+)(?::(\d+))?)?)?$',
    ).firstMatch(reference.trim());
    if (match == null) return;
    final bookName = match.group(1)!;
    final chapter = int.parse(match.group(2)!);
    final startVerseStr = match.group(3);
    final wholeChapter = startVerseStr == null;
    final startVerse = startVerseStr == null ? 1 : int.parse(startVerseStr);
    final midChapterStr = match.group(4);
    final endVerseStr = match.group(5);
    final int? endChapter = midChapterStr != null && endVerseStr != null
        ? int.parse(midChapterStr)
        : null;
    final int? endVerse = endChapter != null
        ? int.parse(endVerseStr!)
        : (midChapterStr != null ? int.parse(midChapterStr) : null);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        // Wrap in a constrained box if needed, or let the modal handle max height
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: VersePreviewModal(
            reference: reference,
            bookName: bookName,
            chapter: chapter,
            startVerse: startVerse,
            endVerse: endVerse,
            endChapter: endChapter,
            wholeChapter: wholeChapter,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: widget.textAlign,
      text: TextSpan(children: _spans),
    );
  }
}
