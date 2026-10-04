import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class VerseLinker {
  static const List<String> _books = [
    'Genesis',
    'Exodus',
    'Leviticus',
    'Numbers',
    'Deuteronomy',
    'Joshua',
    'Judges',
    'Ruth',
    '1 Samuel',
    '2 Samuel',
    '1 Kings',
    '2 Kings',
    '1 Chronicles',
    '2 Chronicles',
    'Ezra',
    'Nehemiah',
    'Esther',
    'Job',
    'Psalms',
    'Psalm',
    'Proverbs',
    'Ecclesiastes',
    'Song of Solomon',
    'Song of Songs',
    'Isaiah',
    'Jeremiah',
    'Lamentations',
    'Ezekiel',
    'Daniel',
    'Hosea',
    'Joel',
    'Amos',
    'Obadiah',
    'Jonah',
    'Micah',
    'Nahum',
    'Habakkuk',
    'Zephaniah',
    'Haggai',
    'Zechariah',
    'Malachi',
    'Matthew',
    'Mark',
    'Luke',
    'John',
    'Acts',
    'Romans',
    '1 Corinthians',
    '2 Corinthians',
    'Galatians',
    'Ephesians',
    'Philippians',
    'Colossians',
    '1 Thessalonians',
    '2 Thessalonians',
    '1 Timothy',
    '2 Timothy',
    'Titus',
    'Philemon',
    'Hebrews',
    'James',
    '1 Peter',
    '2 Peter',
    '1 John',
    '2 John',
    '3 John',
    'Jude',
    'Revelation'
  ];

  static final RegExp _regex = () {
    final booksPattern = _books.join('|');
    // Group 1: Book name
    // Group 2: Numbers — chapter only ("Genesis 1"), verse ("John 3:16"),
    //   same-chapter range ("John 3:16-18") or cross-chapter range
    //   ("Genesis 1:1-3:24").
    return RegExp(
        r'\b(' + booksPattern + r')\s+(\d+(?::\d+(?:-\d+(?::\d+)?)?)?)\b');
  }();

  /// Parses a string and returns a list of TextSpans, separating normal text from Bible references.
  static List<InlineSpan> parse(
    String text, {
    TextStyle? defaultStyle,
    TextStyle? referenceStyle,
    TextStyle? numberStyle,
    GestureRecognizer Function(String reference)? recognizerBuilder,
  }) {
    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in _regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }

      final reference = match.group(0)!;
      final bookName = match.group(1)!;
      final numbers = match.group(2)!;

      // NOTE: the recognizer must live on the leaf spans, not the parent:
      // Flutter's hit test only consults the deepest span under the
      // pointer, so a parent-only recognizer never fires.
      final recognizer = recognizerBuilder?.call(reference);
      spans.add(TextSpan(
        style: referenceStyle ?? defaultStyle,
        children: [
          TextSpan(text: bookName, recognizer: recognizer),
          TextSpan(text: ' ', recognizer: recognizer),
          TextSpan(
            text: numbers,
            style: numberStyle,
            recognizer: recognizer,
          ),
        ],
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    return spans;
  }
}
