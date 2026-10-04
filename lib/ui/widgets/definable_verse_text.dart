import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Wraps a verse [RichText] so long-pressing any word reports it
/// (Olive-Tree-style lookup), marked or not.
///
/// Gesture contract: this detector claims long-presses only, so verse
/// tap (select), double-tap (bookmark) and taps on underlined
/// dictionary words keep working untouched. Against the ancestor verse
/// long-press (verse menu), the inner detector wins the arena, so a
/// long-press on a word defines it while a long-press on verse
/// whitespace/padding still opens the menu.
class DefinableVerseText extends StatefulWidget {
  final TextSpan textSpan;
  final TextAlign textAlign;
  final ValueChanged<String> onWordLongPress;

  const DefinableVerseText({
    super.key,
    required this.textSpan,
    this.textAlign = TextAlign.start,
    required this.onWordLongPress,
  });

  @override
  State<DefinableVerseText> createState() => _DefinableVerseTextState();
}

class _DefinableVerseTextState extends State<DefinableVerseText> {
  final GlobalKey _textKey = GlobalKey();

  static final RegExp _wordRegex = RegExp(r'[a-zA-Z]+');

  void _handleLongPressStart(LongPressStartDetails details) {
    final render = _textKey.currentContext?.findRenderObject();
    if (render is! RenderParagraph) return;
    late TextPosition pos;
    try {
      pos = render.getPositionForOffset(
        render.globalToLocal(details.globalPosition),
      );
    } catch (_) {
      return;
    }
    // Offsets align with the rendered paragraph (verse-number prefix
    // included); placeholder chars from icon WidgetSpans never match.
    final plain = render.text.toPlainText();
    for (final match in _wordRegex.allMatches(plain)) {
      if (pos.offset >= match.start && pos.offset < match.end) {
        widget.onWordLongPress(match.group(0)!.toLowerCase());
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: _handleLongPressStart,
      child: RichText(
        key: _textKey,
        textAlign: widget.textAlign,
        text: widget.textSpan,
      ),
    );
  }
}
