import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/bible_model.dart';

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
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final List<dynamic> versesList = jsonMap['verses'];
      
      final Map<String, BibleBook> booksMap = {};
      
      for (var v in versesList) {
        final bookName = v['book_name'] as String;
        final chapterNum = v['chapter'] as int;
        final verseNum = v['verse'] as int;
        String text = v['text'] as String;
        
        // Strip paragraph markers, preserve bracketed words
        text = text.replaceAll('¶ ', '').replaceAll('¶', '');
        
        booksMap.putIfAbsent(bookName, () => BibleBook(
          name: bookName,
          abbreviation: bookName.substring(0, 3), // Fallback abbreviation
          chapters: [],
        ));
        
        final book = booksMap[bookName]!;
        
        // Ensure chapter exists
        while (book.chapters.length < chapterNum) {
          book.chapters.add(BibleChapter(number: book.chapters.length + 1, verses: []));
        }
        
        final chapter = book.chapters[chapterNum - 1];
        chapter.verses.add(BibleVerse(number: verseNum, text: text));
      }
      
      state = state.copyWith(isLoading: false, books: booksMap.values.toList());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load Bible: $e');
    }
  }
}

final bibleProvider = NotifierProvider<BibleNotifier, BibleState>(BibleNotifier.new);
