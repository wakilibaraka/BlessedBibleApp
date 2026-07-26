import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/bible_model.dart';
import '../utils/isolate_parsers.dart';

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
      final booksList = await compute(parseBibleJson, jsonString);
      
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
