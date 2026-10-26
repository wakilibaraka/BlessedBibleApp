import '../data/models/bible_model.dart';

/// A parsed scripture reference: "Book C", "Book C:V", "Book C:V-V" or
/// "Book C:V-C:V".
class PassageRef {
  final String bookName;
  final int chapter;
  final int startVerse;
  final int? endVerse;

  /// Last chapter for cross-chapter ranges (Genesis 1:1-3:24).
  final int? endChapter;

  /// Whole-chapter reference ("Genesis 1"): every verse.
  final bool wholeChapter;

  const PassageRef({
    required this.bookName,
    required this.chapter,
    required this.startVerse,
    this.endVerse,
    this.endChapter,
    this.wholeChapter = false,
  });

  static final RegExp _exp =
      RegExp(r'(.+?)\s+(\d+)(?::(\d+)(?:-(\d+)(?::(\d+))?)?)?$');

  /// Parses [reference]; null when it is not a recognizable reference.
  static PassageRef? parse(String reference) {
    final match = _exp.firstMatch(reference.trim());
    if (match == null) return null;
    final startVerseStr = match.group(3);
    final midChapterStr = match.group(4);
    final endVerseStr = match.group(5);
    final endChapter = midChapterStr != null && endVerseStr != null
        ? int.parse(midChapterStr)
        : null;
    return PassageRef(
      bookName: match.group(1)!,
      chapter: int.parse(match.group(2)!),
      startVerse: startVerseStr == null ? 1 : int.parse(startVerseStr),
      endChapter: endChapter,
      endVerse: endChapter != null
          ? int.parse(endVerseStr!)
          : (midChapterStr != null ? int.parse(midChapterStr) : null),
      wholeChapter: startVerseStr == null,
    );
  }
}

/// One verse of a resolved passage. [label] is the verse number, or
/// "chapter:verse" when the passage spans chapters.
typedef PassageVerse = ({String label, String text});

/// Resolves [passage] against loaded [books]. Returns null when the book or
/// chapter is missing, and an empty list when no verse in range exists.
List<PassageVerse>? resolvePassage(List<BibleBook> books, PassageRef passage) {
  BibleBook? book;
  for (final b in books) {
    if (b.name == passage.bookName) {
      book = b;
      break;
    }
  }
  final chapter = passage.chapter;
  if (book == null || chapter <= 0 || chapter > book.chapters.length) {
    return null;
  }
  final lastChapter =
      (passage.endChapter ?? chapter).clamp(chapter, book.chapters.length);
  final out = <PassageVerse>[];
  for (var ch = chapter; ch <= lastChapter; ch++) {
    final chapterData = book.chapters[ch - 1];
    final firstV = ch == chapter ? passage.startVerse : 1;
    final lastV = ch == lastChapter
        ? (passage.wholeChapter
            ? chapterData.verses.length
            : (passage.endVerse ?? passage.startVerse))
        : chapterData.verses.length;
    for (final verse in chapterData.verses) {
      if (verse.number < firstV || verse.number > lastV) continue;
      out.add((
        label:
            lastChapter == chapter ? '${verse.number}' : '$ch:${verse.number}',
        text: verse.text,
      ));
    }
  }
  return out;
}
