import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/bible_model.dart';
import '../utils/isolate_parsers.dart';
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
  Completer<void> _loaded = _newCompleter();

  static Completer<void> _newCompleter() {
    final c = Completer<void>();
    // Errors are surfaced via [loaded] / [BibleState.error]; never report
    // them as unhandled when nobody is awaiting.
    c.future.ignore();
    return c;
  }

  /// Completes when the KJV backbone is in memory; completes with an error
  /// when it could not be loaded. The startup content gate awaits this so
  /// the app never opens on top of an empty Bible.
  Future<void> get loaded => _loaded.future;

  @override
  BibleState build() {
    _loadBible();
    return BibleState(isLoading: true);
  }

  /// Re-runs the load (used by the startup recovery screen's Retry).
  Future<void> reload() {
    if (_loaded.isCompleted) _loaded = _newCompleter();
    state = BibleState(isLoading: true);
    _loadBible();
    return loaded;
  }

  Future<void> _loadBible() async {
    try {
      // KJV backbone loads from the offline database (never JSON, never
      // network). The query below also drives DB install/verify/repair, so
      // the splash screen stays active until content is fully ready.
      final rows = await bibleDbService.getAllVerses('kjv');

      final booksList = await compute(parseBibleRows, rows);

      // A partial backbone is as bad as none: refuse to open on it.
      if (booksList.length != 66) {
        throw StateError(
            'KJV backbone incomplete (${booksList.length}/66 books).');
      }

      state = state.copyWith(isLoading: false, books: booksList, error: '');
      if (!_loaded.isCompleted) _loaded.complete();
    } catch (e, st) {
      state =
          state.copyWith(isLoading: false, error: 'Failed to load Bible: $e');
      if (!_loaded.isCompleted) _loaded.completeError(e, st);
    }
  }
}

final bibleProvider =
    NotifierProvider<BibleNotifier, BibleState>(BibleNotifier.new);

class FlatChapter {
  final BibleBook book;
  final int bookNumber;
  final BibleChapter chapter;
  FlatChapter(this.book, this.bookNumber, this.chapter);
}

final flatChaptersProvider = Provider<List<FlatChapter>>((ref) {
  final bibleState = ref.watch(bibleProvider);
  if (bibleState.isLoading || bibleState.books.isEmpty) return [];

  List<FlatChapter> chapters = [];
  for (int i = 0; i < bibleState.books.length; i++) {
    final book = bibleState.books[i];
    final bookNum = i + 1;
    for (final chapter in book.chapters) {
      chapters.add(FlatChapter(book, bookNum, chapter));
    }
  }
  return chapters;
});

typedef ChapterKey = ({
  String translationId,
  int bookNumber,
  int chapterNumber
});

final translationChapterProvider =
    FutureProvider.family<List<BibleVerse>, ChapterKey>((ref, key) async {
  // If kjv, we could technically still use the loaded JSON, but DB is consistent.
  return await bibleDbService.getChapter(
      key.translationId, key.bookNumber, key.chapterNumber);
});
