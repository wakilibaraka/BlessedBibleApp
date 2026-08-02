import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/bible_model.dart';
import '../utils/isolate_parsers.dart';
import '../utils/startup_stopwatch.dart'; // For startupStopwatch
import '../services/bible_database_service.dart';

class BibleState {
  final bool isLoading;
  final List<BibleBook> books;
  final String error;

  BibleState({
    this.isLoading = false,
    this.books = const [],
    this.error = '',
  });

  BibleState copyWith({
    bool? isLoading,
    List<BibleBook>? books,
    String? error,
  }) {
    return BibleState(
      isLoading: isLoading ?? this.isLoading,
      books: books ?? this.books,
      error: error ?? this.error,
    );
  }
}

class BibleNotifier extends Notifier<BibleState> {
  @override
  BibleState build() {
    _loadBible();
    return BibleState(isLoading: true);
  }

  Future<void> _loadBible() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/kjvbible.json');
      if (kStartupTrace) debugPrint('Bible JSON string loaded: ${startupStopwatch.elapsedMilliseconds} ms');
      
      final booksList = await compute(parseBibleJson, jsonString);
      if (kStartupTrace) debugPrint('Bible data ready: ${startupStopwatch.elapsedMilliseconds} ms');
      
      // Await DB copy/initialization so the splash screen stays active until DB is fully ready
      await bibleDbService.database;
      if (kStartupTrace) debugPrint('Database ready: ${startupStopwatch.elapsedMilliseconds} ms');
      
      state = state.copyWith(isLoading: false, books: booksList);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load Bible: $e');
    }
  }
}

final bibleProvider = NotifierProvider<BibleNotifier, BibleState>(BibleNotifier.new);

class FlatChapter {
  final BibleBook book;
  final BibleChapter chapter;
  FlatChapter(this.book, this.chapter);
}

final flatChaptersProvider = Provider<List<FlatChapter>>((ref) {
  final bibleState = ref.watch(bibleProvider);
  if (bibleState.isLoading || bibleState.books.isEmpty) return [];
  
  List<FlatChapter> chapters = [];
  for (final book in bibleState.books) {
    for (final chapter in book.chapters) {
      chapters.add(FlatChapter(book, chapter));
    }
  }
  return chapters;
});

typedef ChapterKey = ({String translationId, int bookNumber, int chapterNumber});

final translationChapterProvider = FutureProvider.family<List<BibleVerse>, ChapterKey>((ref, key) async {
  // If kjv, we could technically still use the loaded JSON, but DB is consistent.
  return await bibleDbService.getChapter(key.translationId, key.bookNumber, key.chapterNumber);
});
