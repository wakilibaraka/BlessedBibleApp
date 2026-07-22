import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/bible_model.dart';
import '../data/models/commentary_model.dart';
import 'bible_provider.dart';
import 'study_provider.dart';

// Represents a search result
class SearchResult {
  final String title;
  final String subtitle;
  final String snippet;
  final SearchResultType type;
  final Map<String, dynamic> metadata;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.snippet,
    required this.type,
    this.metadata = const {},
  });
}

enum SearchResultType { bible, commentary, history }

// The Search Engine handles the actual query logic
class SearchEngine {
  final List<BibleBook>? bibleBooks;
  final Map<String, Map<String, Map<String, List<CommentaryEntry>>>>? commentaryData;

  SearchEngine({this.bibleBooks, this.commentaryData});

  List<SearchResult> search(String query, {bool includeBible = true, bool includeCommentary = true}) {
    if (query.trim().isEmpty) return [];
    
    final queryLower = query.toLowerCase().trim();
    final results = <SearchResult>[];

    // 1. Search Bible
    if (includeBible && bibleBooks != null) {
      for (final book in bibleBooks!) {
        final bookName = book.name;
        for (final chapter in book.chapters) {
          for (final verse in chapter.verses) {
            if (verse.text.toLowerCase().contains(queryLower)) {
              results.add(SearchResult(
                title: '$bookName ${chapter.number}:${verse.number}',
                subtitle: 'Bible Verse',
                snippet: _highlightSnippet(verse.text, queryLower),
                type: SearchResultType.bible,
                metadata: {
                  'book': bookName,
                  'chapter': chapter.number,
                  'verse': verse.number,
                  'text': verse.text,
                },
              ));
            }
          }
        }
      }
    }

    // 2. Search Commentary
    if (includeCommentary && commentaryData != null) {
      for (final bookEntry in commentaryData!.entries) {
        final bookName = bookEntry.key;
        for (final chapterEntry in bookEntry.value.entries) {
          final chapterNum = chapterEntry.key;
          for (final verseEntry in chapterEntry.value.entries) {
            final verseNum = verseEntry.key;
            for (final entry in verseEntry.value) {
              if (entry.text.toLowerCase().contains(queryLower) || entry.title.toLowerCase().contains(queryLower)) {
                results.add(SearchResult(
                  title: '$bookName $chapterNum:$verseNum - ${entry.title}',
                  subtitle: 'Commentary Note',
                  snippet: _highlightSnippet(entry.text, queryLower),
                  type: SearchResultType.commentary,
                  metadata: {
                    'book': bookName,
                    'chapter': int.tryParse(chapterNum) ?? 1,
                    'verse': int.tryParse(verseNum) ?? 1,
                    'author': entry.title,
                  },
                ));
              }
            }
          }
        }
      }
    }

    // Return top 100 matches
    return results.take(100).toList();
  }

  String _highlightSnippet(String text, String query) {
    final index = text.toLowerCase().indexOf(query);
    if (index == -1) return text.length > 100 ? '${text.substring(0, 100)}...' : text;
    
    final start = (index - 40).clamp(0, text.length);
    final end = (index + query.length + 40).clamp(0, text.length);
    
    String snippet = text.substring(start, end).replaceAll('\n', ' ');
    if (start > 0) snippet = '...$snippet';
    if (end < text.length) snippet = '$snippet...';
    
    return snippet;
  }
}

final searchEngineProvider = Provider<SearchEngine>((ref) {
  final bibleState = ref.watch(bibleProvider);
  final commentaryAsync = ref.watch(commentaryDataProvider);

  return SearchEngine(
    bibleBooks: bibleState.books,
    commentaryData: commentaryAsync.asData?.value,
  );
});
