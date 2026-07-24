import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../utils/verse_linker.dart';
import 'verse_preview_modal.dart';

class VerseLinkText extends StatefulWidget {
  final String text;
  final TextStyle? defaultStyle;
  final TextStyle? referenceStyle;
  final TextStyle? numberStyle;
  final TextAlign textAlign;

  const VerseLinkText({
    super.key,
    required this.text,
    this.defaultStyle,
    this.referenceStyle,
    this.numberStyle,
    this.textAlign = TextAlign.start,
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
        oldWidget.numberStyle != widget.numberStyle) {
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
    _spans = VerseLinker.parse(
      widget.text,
      defaultStyle: widget.defaultStyle,
      referenceStyle: widget.referenceStyle,
      numberStyle: widget.numberStyle,
      recognizerBuilder: (reference) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => _handleTap(reference);
        _recognizers.add(recognizer);
        return recognizer;
      },
    );
  }
  
  void _handleTap(String reference) {
    // Parse the reference string (e.g. "Song of Solomon 2:1-4")
    // This simple parsing assumes VerseLinker output format.
    final match = RegExp(r'(.+?)\s+(\d+):(\d+)(?:-(\d+))?').firstMatch(reference);
    if (match != null) {
      final bookName = match.group(1)!;
      final chapter = int.parse(match.group(2)!);
      final startVerse = int.parse(match.group(3)!);
      final endVerseStr = match.group(4);
      final endVerse = endVerseStr != null ? int.parse(endVerseStr) : null;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          // Wrap in a constrained box if needed, or let the modal handle max height
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: VersePreviewModal(
              reference: reference,
              bookName: bookName,
              chapter: chapter,
              startVerse: startVerse,
              endVerse: endVerse,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: widget.textAlign,
      text: TextSpan(children: _spans),
    );
  }
}
