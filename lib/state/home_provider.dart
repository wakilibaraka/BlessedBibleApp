import 'dart:async';
import '../utils/prose.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/content_sync_service.dart';
import '../data/models/home_data.dart';
import 'notes_provider.dart';
import '../state/commentary_provider.dart';
import '../state/bible_provider.dart';
import '../data/models/bible_model.dart';
import '../models/study_content_category.dart';
import 'package:collection/collection.dart'; // for firstOrNull

// How much of a commentary entry the home card shows: a short paragraph
// rather than a single clipped line. The character budget keeps the card a
// predictable height across sources with very uneven sentence lengths.
const _snippetMaxSentences = 6;
const _snippetMaxChars = 420;

/// Excerpt of a commentary entry shown on the Verse-of-the-Day card: whole
/// sentences up to [_snippetMaxSentences] / [_snippetMaxChars], so the card
/// shows a paragraph instead of a clipped first line. Never cuts mid-word.
String extractVotdSnippet(String text) {
  // Join the packs' hard wraps before splitting sentences; otherwise the
  // excerpt carries source line breaks and stray bold markers.
  final plain = normalizeProse(text).replaceAll('**', '').replaceAll('__', '');
  final matches = RegExp(r'[^.!?]+[.!?]').allMatches(plain);
  if (matches.isEmpty) return plain;

  // The splitter breaks on every stop, so abbreviations such as "A.D. 508"
  // arrive as stubs ("A.", "D.", "508."). Fold a stub back into the
  // sentence it belongs to; otherwise one date eats three excerpt slots and
  // the card visibly stops mid-thought.
  final sentences = <String>[];
  for (final match in matches) {
    final fragment = match.group(0)!.trim();
    if (fragment.isEmpty) continue;
    final words = fragment.split(RegExp(r'\s+'));
    final isStub = fragment.length <= 12 && words.length <= 2;
    if (sentences.isNotEmpty && isStub) {
      sentences[sentences.length - 1] = '${sentences.last} $fragment';
    } else {
      sentences.add(fragment);
    }
  }

  final buffer = StringBuffer();
  var taken = 0;
  for (final sentence in sentences) {
    if (taken == _snippetMaxSentences) break;
    // Always keep the first sentence; stop before exceeding the budget.
    if (taken > 0 && buffer.length + 1 + sentence.length > _snippetMaxChars) {
      break;
    }
    if (taken > 0) buffer.write(' ');
    buffer.write(sentence);
    taken++;
  }
  return buffer.toString();
}

final votdPoolProvider = Provider<List<VerseOfTheDay>>((ref) {
  final commentaryState = ref.watch(commentaryProvider);
  final bibleState = ref.watch(bibleProvider);

  final defaultFallback = [
    VerseOfTheDay(
      'Revelation 14:12',
      'Here is the patience of the saints: here are they that keep the commandments of God, and the faith of Jesus.',
      commentarySnippet: 'Here is the patience of the saints.',
    )
  ];

  if (commentaryState.isLoading ||
      bibleState.isLoading ||
      bibleState.books.isEmpty) {
    return defaultFallback;
  }

  final commentaries = commentaryState.value ?? [];

  // Lookups by name and number instead of scanning the whole Bible for every
  // entry. With ~22k verse entries the old scans (plus a duplicate check
  // over the growing pool and an excerpt per entry) took seconds on the UI
  // isolate, which is the freeze people saw right as Home appeared.
  final booksByName = <String, BibleBook>{
    for (final b in bibleState.books) b.name.toLowerCase(): b,
  };
  final versesByChapter = <BibleChapter, Map<int, BibleVerse>>{};
  BibleVerse? findVerse(String bookName, int chapterNum, int verseNum) {
    final book = booksByName[bookName.toLowerCase()];
    if (book == null) return null;
    final chapter =
        book.chapters.firstWhereOrNull((c) => c.number == chapterNum);
    if (chapter == null) return null;
    final verses = versesByChapter.putIfAbsent(
        chapter, () => {for (final v in chapter.verses) v.number: v});
    return verses[verseNum];
  }

  // First usable entry per reference wins, as before.
  final byReference = <String, VerseOfTheDay>{};

  for (final entry in commentaries) {
    final isDevotional = entry.category == StudyContentCategory.devotional;
    final isCommentary = entry.category == StudyContentCategory.commentary;
    if (!isDevotional && !isCommentary) continue;

    if (entry.scope.type == 'verse' &&
        entry.scope.book != null &&
        entry.scope.chapter != null &&
        entry.scope.verse != null) {
      final bookName = entry.scope.book!;
      final chapterNum = entry.scope.chapter!;
      final verseNum = entry.scope.verse!;

      final refStr = '$bookName $chapterNum:$verseNum';
      if (byReference.containsKey(refStr)) continue;

      final verse = findVerse(bookName, chapterNum, verseNum);
      if (verse == null || verse.text.isEmpty) continue;
      // Same test as a non-blank excerpt, without building the excerpt.
      if (!hasVisibleProse(
          entry.text.replaceAll('**', '').replaceAll('__', ''))) {
        continue;
      }
      final source = entry.text;
      byReference[refStr] = VerseOfTheDay.lazy(
        refStr,
        verse.text,
        commentarySnippet: () => extractVotdSnippet(source),
        author: entry.author,
        sourceTitle: entry.source,
        isDevotional: isDevotional,
      );
    }
  }

  final pool = byReference.values.toList();

  if (pool.isEmpty) return defaultFallback;

  // Sort to make it deterministic and readable
  pool.sort((a, b) => a.reference.compareTo(b.reference));
  return pool;
});

class VotdOverrideNotifier extends AsyncNotifier<Map<String, String>> {
  late final ContentSyncService<String> _syncService;

  @override
  Future<Map<String, String>> build() async {
    _syncService = ContentSyncService<String>(
      collectionName: 'VOTD',
      cacheFileName: 'votd_overrides.json',
      fromJson: (json) => json['reference'] as String,
      toJson: (ref) => {'reference': ref},
    );

    final localCache = await _syncService.loadLocalCache();

    // Fire and forget background sync
    unawaited(_syncService.syncDeltas((newCache) {
      state = AsyncData(newCache);
    }));

    return localCache;
  }
}

final votdOverrideProvider =
    AsyncNotifierProvider<VotdOverrideNotifier, Map<String, String>>(
        VotdOverrideNotifier.new);

class HomeNotifier extends Notifier<HomeData> {
  @override
  HomeData build() {
    final notes = ref.watch(notesProvider);
    return _fetchData(notes);
  }

  HomeData _fetchData(List<PersonalNote> notes) {
    final pool = ref.watch(votdPoolProvider);
    final overridesAsync = ref.watch(votdOverrideProvider);
    final overrides = overridesAsync.value ?? {};
    final bibleState = ref.watch(bibleProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayIndex =
        today.difference(DateTime(2026, 1, 1)).inDays % pool.length;
    VerseOfTheDay votd = pool[dayIndex];

    final todayString =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (overrides.containsKey(todayString)) {
      final overrideRef = overrides[todayString]!;

      final pooledOverride = pool.firstWhereOrNull(
          (v) => v.reference.toLowerCase() == overrideRef.toLowerCase());
      if (pooledOverride != null) {
        votd = pooledOverride;
      } else {
        final books = bibleState.books;
        if (books.isNotEmpty) {
          final lastSpace = overrideRef.lastIndexOf(' ');
          if (lastSpace != -1) {
            final bookName = overrideRef.substring(0, lastSpace);
            final parts = overrideRef.substring(lastSpace + 1).split(':');
            if (parts.isNotEmpty) {
              final chapterNum = int.tryParse(parts[0]) ?? 1;
              final verseNum =
                  int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;

              final book = books.firstWhereOrNull(
                  (b) => b.name.toLowerCase() == bookName.toLowerCase());
              if (book != null) {
                final chapter = book.chapters
                    .firstWhereOrNull((c) => c.number == chapterNum);
                if (chapter != null) {
                  final verse = chapter.verses
                      .firstWhereOrNull((v) => v.number == verseNum);
                  if (verse != null && verse.text.isNotEmpty) {
                    votd = VerseOfTheDay(overrideRef, verse.text);
                  }
                }
              }
            }
          }
        }
      }
    }

    // Show the 3 most recent notes
    final recentNotes = notes.reversed.take(3).toList();

    return HomeData(
      verseOfTheDay: votd,
      activeStudy: null,
      quickLinks: ["John 3:16", "Psalm 23:1", "Hebrews 11:1"],
      recentNotes: recentNotes,
      mostReadVerses: [],
    );
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeData>(HomeNotifier.new);
