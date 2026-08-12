import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/home_data.dart';
import 'notes_provider.dart';
import '../state/commentary_provider.dart';
import '../state/bible_provider.dart';
import 'package:collection/collection.dart'; // for firstOrNull

String _extractSnippet(String text) {
  final matches = RegExp(r'[^.!?]+[.!?]').allMatches(text);
  if (matches.isEmpty) return text.trim();
  
  final sentences = matches.map((m) => m.group(0)!.trim()).toList();
  final takeCount = sentences.length > 3 ? 3 : sentences.length;
  return sentences.take(takeCount).join(' ');
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

  if (commentaryState.isLoading || bibleState.isLoading || bibleState.books.isEmpty) {
    return defaultFallback;
  }
  
  final commentaries = commentaryState.value ?? [];
  final books = bibleState.books;
  
  final List<VerseOfTheDay> pool = [];
  
  for (final entry in commentaries) {
    if (entry.scope.type == 'verse' && entry.scope.book != null && entry.scope.chapter != null && entry.scope.verse != null) {
      final bookName = entry.scope.book!;
      final chapterNum = entry.scope.chapter!;
      final verseNum = entry.scope.verse!;
      
      final refStr = '$bookName $chapterNum:$verseNum';
      if (pool.any((v) => v.reference == refStr)) continue;
      
      final book = books.firstWhereOrNull((b) => b.name.toLowerCase() == bookName.toLowerCase());
      if (book != null) {
        final chapter = book.chapters.firstWhereOrNull((c) => c.number == chapterNum);
        if (chapter != null) {
          final verse = chapter.verses.firstWhereOrNull((v) => v.number == verseNum);
          if (verse != null && verse.text.isNotEmpty) {
             pool.add(VerseOfTheDay(
               refStr, 
               verse.text,
               commentarySnippet: _extractSnippet(entry.text),
             ));
          }
        }
      }
    }
  }
  
  if (pool.isEmpty) return defaultFallback;
  
  // Sort to make it deterministic and readable
  pool.sort((a, b) => a.reference.compareTo(b.reference));
  return pool;
});

class HomeNotifier extends Notifier<HomeData> {
  @override
  HomeData build() {
    final notes = ref.watch(notesProvider);
    return _fetchData(notes);
  }

  HomeData _fetchData(List<PersonalNote> notes) {
    final pool = ref.watch(votdPoolProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayIndex = today.difference(DateTime(2026, 1, 1)).inDays % pool.length;
    final votd = pool[dayIndex];

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
