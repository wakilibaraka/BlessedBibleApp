import '../data/bible_books.dart';
import 'commentary_entry.dart';

/// A published commentary volume as it appears in the library shelf: one
/// author + title, the scripture it covers, and how much of it there is.
///
/// The bundled data stores a *verse range* inside the `source` of some
/// imports ("Daniel and the Revelation (13:11-17)"), so a single physical
/// book arrives as ~90 different source strings. [commentaryWorkTitle]
/// folds those back into one title before grouping.
class CommentaryWork {
  CommentaryWork({
    required this.title,
    required this.author,
    required this.entryCount,
    Map<String, Map<int, int>> coverage = const {},
  }) : coverage = Map.unmodifiable({
          for (final entry in coverage.entries)
            entry.key: Map<int, int>.unmodifiable(entry.value),
        });

  /// Volume title, e.g. "Daniel and the Revelation".
  final String title;

  /// Author as printed in the library, e.g. "Uriah Smith".
  final String author;

  /// Total entries in this volume.
  final int entryCount;

  /// Book -> chapter -> entry count. Empty for topical-only material.
  final Map<String, Map<int, int>> coverage;

  /// Covered books in canonical scripture order.
  List<String> get books => coverage.keys.toList()..sort(compareBibleBookNames);

  /// Number of distinct chapters covered.
  int get chapterCount =>
      coverage.values.fold(0, (sum, chapters) => sum + chapters.length);

  @override
  String toString() => 'CommentaryWork($title, $author, $entryCount)';
}

/// Title of the volume [source] belongs to.
///
/// A trailing parenthetical that is nothing but a scripture reference is
/// dropped; anything else is left alone so titles that legitimately end in
/// brackets survive ("Bible Readings (Vol. 2)").
String commentaryWorkTitle(String source) {
  final trimmed = source.trim();
  final match = _trailingParenthetical.firstMatch(trimmed);
  if (match == null) return trimmed;
  final inner = match.group(2)!.trim();
  if (inner.isEmpty || !_referenceCharacters.hasMatch(inner)) return trimmed;
  final isReference = _digit.hasMatch(inner) &&
      (inner.contains(':') || inner.contains('-') || inner.contains('\u2013'));
  if (!isReference) return trimmed;
  final base = match.group(1)!.trim();
  return base.isEmpty ? trimmed : base;
}

/// Canonical scripture order, used to sort covered books. Names outside
/// [kBibleBookNames] sort last, alphabetically, so unexpected data never
/// jumps to the top of the shelf.
int compareBibleBookNames(String a, String b) {
  final ia = kBibleBookNames.indexOf(a);
  final ib = kBibleBookNames.indexOf(b);
  if (ia >= 0 && ib >= 0) return ia.compareTo(ib);
  if (ia >= 0) return -1;
  if (ib >= 0) return 1;
  return a.toLowerCase().compareTo(b.toLowerCase());
}

/// Groups [entries] into volumes, biggest first.
///
/// Entries with no book scope (topical extracts) still count towards their
/// volume but give it no coverage; a volume with no coverage at all has no
/// chapter to open, so it is only returned when [includeTopical] is set.
List<CommentaryWork> buildCommentaryWorks(
  List<CommentaryEntry> entries, {
  bool includeTopical = false,
}) {
  final counts = <String, int>{};
  final authors = <String, String>{};
  final titles = <String, String>{};
  final coverage = <String, Map<String, Map<int, int>>>{};

  for (final entry in entries) {
    final title = commentaryWorkTitle(entry.source);
    final key = '$title\u0000${entry.author}';
    titles[key] = title;
    authors[key] = entry.author;
    counts[key] = (counts[key] ?? 0) + 1;

    final book = entry.scope.book;
    final chapter = entry.scope.chapter;
    if (book == null || chapter == null) continue;
    final byBook = coverage.putIfAbsent(key, () => {});
    final byChapter = byBook.putIfAbsent(book, () => {});
    byChapter[chapter] = (byChapter[chapter] ?? 0) + 1;
  }

  final works = <CommentaryWork>[];
  for (final key in counts.keys) {
    final cover = coverage[key] ?? const <String, Map<int, int>>{};
    if (cover.isEmpty && !includeTopical) continue;
    works.add(CommentaryWork(
      title: titles[key]!,
      author: authors[key]!,
      entryCount: counts[key]!,
      coverage: cover,
    ));
  }
  works.sort((a, b) {
    final bySize = b.entryCount.compareTo(a.entryCount);
    return bySize != 0 ? bySize : a.title.compareTo(b.title);
  });
  return works;
}

final _trailingParenthetical = RegExp(r'^(.*\S)\s*\(([^()]*)\)$');
final _referenceCharacters = RegExp(r'^[A-Za-z0-9 .:;\u2013\u2014-]+$');
final _digit = RegExp(r'\d');
