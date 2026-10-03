import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bible_database_service.dart';

class StrongsEntry {
  final String id;
  final String lemma;
  final String transliteration;
  final String pronunciation;
  final String definition;

  StrongsEntry({
    required this.id,
    required this.lemma,
    required this.transliteration,
    required this.pronunciation,
    required this.definition,
  });
}

final strongsProvider = FutureProvider.family<StrongsEntry?, String>((ref, id) async {
  final db = await bibleDbService.database;

  // Query the strongs_lexicon table
  final maps = await db.query(
    'strongs_lexicon',
    where: 'id = ?',
    whereArgs: [id.toUpperCase()],
  );

  if (maps.isEmpty) {
    return null;
  }

  final row = maps.first;
  return StrongsEntry(
    id: row['id'] as String,
    lemma: row['lemma'] as String? ?? '',
    transliteration: row['transliteration'] as String? ?? '',
    pronunciation: row['pronunciation'] as String? ?? '',
    definition: row['definition'] as String? ?? '',
  );
});
