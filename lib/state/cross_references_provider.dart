import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bible_database_service.dart';

/// A single cross-reference link from one verse to another.
class CrossRef {
  final int toBookNumber;
  final int toChapter;
  final int toVerse;
  final int votes; // relevance weight from dataset

  const CrossRef({
    required this.toBookNumber,
    required this.toChapter,
    required this.toVerse,
    this.votes = 0,
  });
}

typedef CrossRefKey = ({
  int bookNumber,
  int chapter,
  int verse,
});

/// Fetches cross-references for a specific verse.
/// Returns an empty list gracefully if the table doesn't exist yet.
final crossReferencesProvider =
    FutureProvider.family<List<CrossRef>, CrossRefKey>((ref, key) async {
  try {
    final db = await bibleDbService.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='cross_references';",
    );
    if (tables.isEmpty) return [];

    final rows = await db.rawQuery(
      '''
      SELECT to_book_number, to_chapter, to_verse, votes
      FROM cross_references
      WHERE from_book_number = ? AND from_chapter = ? AND from_verse = ?
      ORDER BY votes DESC
      LIMIT 20
      ''',
      [key.bookNumber, key.chapter, key.verse],
    );

    return rows
        .map((r) => CrossRef(
              toBookNumber: r['to_book_number'] as int,
              toChapter: r['to_chapter'] as int,
              toVerse: r['to_verse'] as int,
              votes: r['votes'] as int? ?? 0,
            ))
        .toList();
  } catch (_) {
    return [];
  }
});
