import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bible_database_service.dart';

class DictionaryHeadword {
  final String normalizedWord;
  final String displayHeadword;
  final String sources;
  final String snippet;

  DictionaryHeadword({
    required this.normalizedWord,
    required this.displayHeadword,
    required this.sources,
    required this.snippet,
  });
}

final dictionaryIndexProvider = FutureProvider<List<DictionaryHeadword>>((ref) async {
  final db = await bibleDbService.database;
  
  final rows = await db.query(
    'dictionary',
    columns: ['display_headword', 'source', 'definition', 'normalized_word'],
    orderBy: 'display_headword ASC',
  );

  final Map<String, Map<String, dynamic>> grouped = {};
  
  for (final row in rows) {
    final headword = row['display_headword'] as String;
    if (!grouped.containsKey(headword)) {
      grouped[headword] = {
        'headword': headword,
        'normalized_word': row['normalized_word'] as String,
        'sources': <String>[],
        'definition': row['definition'] as String,
      };
    }
    (grouped[headword]!['sources'] as List<String>).add(row['source'] as String);
  }

  return grouped.values.map((g) {
    final headword = g['headword'] as String;
    final preview = g['definition'] as String;
    final normWord = g['normalized_word'] as String;
    final sourceList = (g['sources'] as List<String>).join(', ');
    
    var cleanSnippet = preview.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('\n', ' ');
    if (cleanSnippet.length > 80) {
      cleanSnippet = '${cleanSnippet.substring(0, 80)}...';
    }
    
    return DictionaryHeadword(
      normalizedWord: normWord,
      displayHeadword: headword,
      sources: sourceList,
      snippet: cleanSnippet,
    );
  }).toList();
});

final dictionarySearchProvider = FutureProvider.family<List<DictionaryHeadword>, String>((ref, query) async {
  if (query.trim().isEmpty) return ref.read(dictionaryIndexProvider.future);
  
  final db = await bibleDbService.database;
  final q = query.trim();
  final likeTerm = '%${q}%';
  
  final rows = await db.query(
    'dictionary',
    columns: ['display_headword', 'source', 'definition', 'normalized_word'],
    where: 'normalized_word LIKE ? OR display_headword LIKE ?',
    whereArgs: [likeTerm, likeTerm],
    orderBy: 'display_headword ASC',
    limit: 100,
  );

  final Map<String, Map<String, dynamic>> grouped = {};
  
  for (final row in rows) {
    final headword = row['display_headword'] as String;
    if (!grouped.containsKey(headword)) {
      grouped[headword] = {
        'headword': headword,
        'normalized_word': row['normalized_word'] as String,
        'sources': <String>[],
        'definition': row['definition'] as String,
      };
    }
    (grouped[headword]!['sources'] as List<String>).add(row['source'] as String);
  }

  return grouped.values.map((g) {
    final headword = g['headword'] as String;
    final preview = g['definition'] as String;
    final normWord = g['normalized_word'] as String;
    final sourceList = (g['sources'] as List<String>).join(', ');
    
    var cleanSnippet = preview.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('\n', ' ');
    if (cleanSnippet.length > 80) {
      cleanSnippet = '${cleanSnippet.substring(0, 80)}...';
    }
    
    return DictionaryHeadword(
      normalizedWord: normWord,
      displayHeadword: headword,
      sources: sourceList,
      snippet: cleanSnippet,
    );
  }).toList();
});
