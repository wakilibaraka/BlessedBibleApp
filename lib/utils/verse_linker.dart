import 'package:flutter/material.dart';

class VerseLinker {
  static const List<String> _books = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth',
    '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther',
    'Job', 'Psalms', 'Psalm', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Song of Songs', 'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel',
    'Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
    'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians',
    'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon',
    'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation'
  ];

  static final RegExp _regex = () {
    final booksPattern = _books.join('|');
    // Matches: "Book Chapter:Verse" or "Book Chapter:Verse-Verse"
    // e.g., "1 Corinthians 13:4-8", "Song of Solomon 2:1"
    return RegExp(r'\b(' + booksPattern + r')\s+\d+:\d+(?:-\d+)?\b');
  }();

  /// Parses a string and returns a list of TextSpans, separating normal text from Bible references.
  static List<InlineSpan> parse(String text, {TextStyle? defaultStyle, TextStyle? referenceStyle}) {
    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in _regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }

      // The matched reference
      final reference = match.group(0)!;
      spans.add(TextSpan(
        text: reference,
        style: referenceStyle ?? defaultStyle, // No visual change by default
        // In the future, a gesture recognizer will be added here
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
