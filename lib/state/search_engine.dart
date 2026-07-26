
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/bible_model.dart';
import '../data/models/commentary_model.dart';
import '../data/models/home_data.dart';
import 'bible_provider.dart';
import 'study_provider.dart';
import 'notes_provider.dart';

enum SearchResultType { reference, bible, commentary, history, note }

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

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'snippet': snippet,
    'type': type.name,
    'metadata': metadata,
  };

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    title: json['title'],
    subtitle: json['subtitle'],
    snippet: json['snippet'],
    type: SearchResultType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => SearchResultType.bible,
    ),
    metadata: json['metadata'] ?? {},
  );
}

class SearchItem {
  final int id;
  final SearchResultType type;
  final String title;
  final String subtitle;
  final String text;
  final Map<String, dynamic> metadata;

  SearchItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.text,
    required this.metadata,
  });
}

class IndexData {
  final List<SearchItem> corpus;
  final Map<String, List<int>> invertedIndex;
  
  IndexData(this.corpus, this.invertedIndex);
}

class IndexBuildArgs {
  final List<BibleBook>? bibleBooks;
  final Map<String, Map<String, Map<String, List<CommentaryEntry>>>>? commentaryData;
  final List<PersonalNote> notes;
  
  IndexBuildArgs(this.bibleBooks, this.commentaryData, this.notes);
}

class SearchQueryArgs {
  final String query;
  final IndexData indexData;
  final bool includeOt;
  final bool includeNt;
  final bool includeCommentary;
  final bool includeNotes;
  final List<BibleBook>? bibleBooks; // Needed for reference matching
  final List<PersonalNote> notes;
  
  SearchQueryArgs(this.query, this.indexData, this.includeOt, this.includeNt, this.includeCommentary, this.includeNotes, this.bibleBooks, this.notes);
}

List<String> _tokenize(String text) {
  // Lowercase and replace non-alphanumeric (except spaces) with spaces, then split
  return text.toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ').split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
}

IndexData buildIndexIsolate(IndexBuildArgs args) {
  final corpus = <SearchItem>[];
  final index = <String, List<int>>{};
  int nextId = 0;

  void addTokens(int id, String text) {
    final tokens = _tokenize(text);
    // Use a set to avoid duplicate document IDs for the same token
    for (final token in tokens.toSet()) {
      index.putIfAbsent(token, () => []).add(id);
    }
  }

  // 1. Bible Books
  if (args.bibleBooks != null) {
    for (int i = 0; i < args.bibleBooks!.length; i++) {
      final book = args.bibleBooks![i];
      final isOt = i < 39;
      for (final chapter in book.chapters) {
        for (final verse in chapter.verses) {
          final item = SearchItem(
            id: nextId++,
            type: SearchResultType.bible,
            title: '${book.name} ${chapter.number}:${verse.number}',
            subtitle: 'Bible Verse',
            text: verse.text,
            metadata: {
              'book': book.name,
              'bookAbbrev': book.abbreviation,
              'chapter': chapter.number,
              'verse': verse.number,
              'text': verse.text,
              'isOt': isOt,
            },
          );
          corpus.add(item);
          addTokens(item.id, '${item.title} ${item.text}');
        }
      }
    }
  }

  // 2. Commentary
  if (args.commentaryData != null) {
    for (final bookEntry in args.commentaryData!.entries) {
      final bookName = bookEntry.key;
      for (final chapterEntry in bookEntry.value.entries) {
        final chapterNum = chapterEntry.key;
        for (final verseEntry in chapterEntry.value.entries) {
          final verseNum = verseEntry.key;
          int parsedVerse = 1;
          if (verseNum.contains('-')) {
            parsedVerse = int.tryParse(verseNum.split('-').first) ?? 1;
          } else {
            parsedVerse = int.tryParse(verseNum) ?? 1;
          }

          for (final entry in verseEntry.value) {
            String authorLabel = entry.title.isNotEmpty ? '${entry.title} Commentary' : 'Commentary';

            final item = SearchItem(
              id: nextId++,
              type: SearchResultType.commentary,
              title: '$bookName $chapterNum:$verseNum',
              subtitle: authorLabel,
              text: (entry.title.isNotEmpty ? '«${entry.title}» ' : '') + entry.text,
              metadata: {
                'book': bookName,
                'chapter': int.tryParse(chapterNum) ?? 1,
                'verse': parsedVerse,
                'author': entry.title,
              },
            );
            corpus.add(item);
            addTokens(item.id, '${item.title} ${item.text}');
          }
        }
      }
    }
  }

  // Notes are now indexed separately during search to avoid full re-index

  return IndexData(corpus, index);
}

List<SearchResult> _searchIsolate(SearchQueryArgs args) {
  final query = args.query.trim();
  if (query.isEmpty) return [];

  final queryLower = query.toLowerCase();
  final queryTokens = _tokenize(query);
  if (queryTokens.isEmpty) return [];

  final results = <SearchResult>[];

  // Dynamically index notes
  final noteCorpus = <SearchItem>[];
  final noteIndex = <String, List<int>>{};
  int nextNoteId = args.indexData.corpus.length;

  void addNoteTokens(int id, String text) {
    final tokens = _tokenize(text);
    for (final token in tokens.toSet()) {
      noteIndex.putIfAbsent(token, () => []).add(id);
    }
  }

  if (args.includeNotes) {
    for (final note in args.notes) {
      final item = SearchItem(
        id: nextNoteId++,
        type: SearchResultType.note,
        title: note.title,
        subtitle: 'Note • ${note.date}',
        text: note.content,
        metadata: {'title': note.title},
      );
      noteCorpus.add(item);
      addNoteTokens(item.id, '${item.title} ${item.text}');
    }
  }

  // Helper for snippet
  String highlightSnippet(String text, String queryLower) {
    final index = text.toLowerCase().indexOf(queryLower);
    if (index == -1) return text.length > 100 ? '${text.substring(0, 100)}...' : text;
    
    final start = (index - 30).clamp(0, text.length);
    final end = (index + queryLower.length + 30).clamp(0, text.length);
    
    String snippet = text.substring(start, end);
    if (start > 0) snippet = '...$snippet';
    if (end < text.length) snippet = '$snippet...';
    
    return snippet;
  }

  // 0. Exact Reference Match (highest priority)
  if ((args.includeOt || args.includeNt) && args.bibleBooks != null) {
    final regex = RegExp(r'^((?:\d\s*)?[a-z]+(?:\s+[a-z]+)*)\s*(?:(\d+)[\s:.]*(\d+)?)?$');
    final match = regex.firstMatch(queryLower);
    
    if (match != null) {
      final bookStr = match.group(1)?.trim() ?? '';
      final chapterStr = match.group(2);
      final verseStr = match.group(3);

      for (final book in args.bibleBooks!) {
        final nameLower = book.name.toLowerCase();
        final abbrevLower = book.abbreviation.toLowerCase();

        if (nameLower.startsWith(bookStr) || abbrevLower.startsWith(bookStr)) {
          int? chapter;
          int? verse;

          if (chapterStr != null) {
            chapter = int.tryParse(chapterStr);
            if (chapter != null) {
              chapter = chapter.clamp(1, book.chapters.length);
            }
          }
          
          if (chapter != null && verseStr != null) {
            verse = int.tryParse(verseStr);
            if (verse != null) {
              final maxVerse = book.chapters[chapter - 1].verses.length;
              verse = verse.clamp(1, maxVerse);
            }
          }

          String title = book.name;
          if (chapter != null) title += ' $chapter';
          if (verse != null) title += ':$verse';

          results.add(SearchResult(
            title: title,
            subtitle: 'Jump To',
            snippet: 'Go to ${book.name} Chapter ${chapter ?? 1}${verse != null ? ' Verse $verse' : ''}',
            type: SearchResultType.reference,
            metadata: {
              'bookAbbrev': book.abbreviation,
              'bookName': book.name,
              'chapter': chapter ?? 1,
              if (verse != null) 'verse': verse,
            },
          ));
        }
      }
    }
  }

  // 1. Predictive Prefix Matching via Inverted Index
  // For each token in the query, we find all documents that contain a word starting with that token.
  final index = args.indexData.invertedIndex;
  final corpus = args.indexData.corpus;
  
  // Start with null for intersection
  Set<int>? matchingIds;
  
  // Store matching metadata for ranking later
  final matchQuality = <int, int>{}; // id -> score (higher is better)

  for (final token in queryTokens) {
    final currentTokenMatches = <int>{};
    
    // Exact matches
    if (index.containsKey(token)) {
      for (final id in index[token]!) {
        currentTokenMatches.add(id);
        matchQuality[id] = (matchQuality[id] ?? 0) + 10; // Exact word match = 10 pts
      }
    }
    if (noteIndex.containsKey(token)) {
      for (final id in noteIndex[token]!) {
        currentTokenMatches.add(id);
        matchQuality[id] = (matchQuality[id] ?? 0) + 10;
      }
    }
    
    // Prefix matches (only if token is reasonably long, e.g., > 1 char to avoid exploding)
    if (token.isNotEmpty) {
      for (final key in index.keys) {
        if (key != token && key.startsWith(token)) {
          for (final id in index[key]!) {
            currentTokenMatches.add(id);
            matchQuality[id] = (matchQuality[id] ?? 0) + 1; // Prefix match = 1 pt
          }
        }
      }
      for (final key in noteIndex.keys) {
        if (key != token && key.startsWith(token)) {
          for (final id in noteIndex[key]!) {
            currentTokenMatches.add(id);
            matchQuality[id] = (matchQuality[id] ?? 0) + 1;
          }
        }
      }
    }
    
    if (matchingIds == null) {
      matchingIds = currentTokenMatches;
    } else {
      matchingIds = matchingIds.intersection(currentTokenMatches);
    }
    
    // If at any point the intersection is empty, we can abort early
    if (matchingIds.isEmpty) break;
  }
  
  if (matchingIds != null && matchingIds.isNotEmpty) {
    // Filter by requested types and gather items
    final matchedItems = <SearchItem>[];
    for (final id in matchingIds) {
      final SearchItem item;
      if (id >= corpus.length) {
        item = noteCorpus[id - corpus.length];
      } else {
        item = corpus[id];
      }
      if (item.type == SearchResultType.bible) {
        final isOt = item.metadata['isOt'] == true;
        if (isOt && !args.includeOt) continue;
        if (!isOt && !args.includeNt) continue;
      } else if (item.type == SearchResultType.commentary) {
        if (!args.includeCommentary) continue;
      } else if (item.type == SearchResultType.note) {
        if (!args.includeNotes) continue;
      }
      matchedItems.add(item);
    }
    
    // Add Exact Phrase boosting
    for (final item in matchedItems) {
      if (item.text.toLowerCase().contains(queryLower)) {
        matchQuality[item.id] = (matchQuality[item.id] ?? 0) + 50; // Exact phrase = 50 pts
      }
    }
    
    // Sort by match quality descending
    matchedItems.sort((a, b) {
      final scoreA = matchQuality[a.id] ?? 0;
      final scoreB = matchQuality[b.id] ?? 0;
      return scoreB.compareTo(scoreA); // Highest first
    });
    
    // Take top 100
    for (final item in matchedItems.take(100)) {
      results.add(SearchResult(
        title: item.title,
        subtitle: item.subtitle,
        snippet: highlightSnippet(item.text, queryLower),
        type: item.type,
        metadata: item.metadata,
      ));
    }
  }

  // The 'reference' matches added at the beginning are implicitly at the top.
  return results;
}

class SearchEngine {
  final List<BibleBook>? bibleBooks;
  final Future<IndexData> baseIndexFuture;
  final List<PersonalNote> notes;

  SearchEngine({this.bibleBooks, required this.baseIndexFuture, this.notes = const []});

  Future<List<SearchResult>> search(String query, {
    bool includeOt = true,
    bool includeNt = true,
    bool includeCommentary = true,
    bool includeNotes = true,
  }) async {
    final indexData = await baseIndexFuture;
    final args = SearchQueryArgs(query, indexData, includeOt, includeNt, includeCommentary, includeNotes, bibleBooks, notes);
    return await compute(_searchIsolate, args);
  }
}

final baseSearchIndexProvider = FutureProvider<IndexData>((ref) async {
  final bibleState = ref.watch(bibleProvider);

  // Don't build the index until Bible data is ready — avoids a pointless heavy
  // compute() call that would immediately be cancelled and re-triggered.
  if (bibleState.isLoading || bibleState.books.isEmpty) {
    return IndexData([], {});
  }

  // Commentary is optional — use whatever is already available without blocking
  final commentaryAsync = ref.watch(combinedCommentaryProvider);

  final args = IndexBuildArgs(
    bibleState.books,
    commentaryAsync.asData?.value.data,
    [], // Notes handled dynamically
  );
  return await compute(buildIndexIsolate, args);
});

final searchEngineProvider = Provider<SearchEngine>((ref) {
  final bibleState = ref.watch(bibleProvider);
  final baseIndexFuture = ref.watch(baseSearchIndexProvider.future);
  final notes = ref.watch(notesProvider);

  return SearchEngine(
    bibleBooks: bibleState.books,
    baseIndexFuture: baseIndexFuture,
    notes: notes,
  );
});
