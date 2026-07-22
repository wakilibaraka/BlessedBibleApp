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
      final jsonString = await rootBundle.loadString('assets/bible/kjv.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      final books = jsonList.map((e) => BibleBook.fromJson(e as Map<String, dynamic>)).toList();
      
      state = state.copyWith(isLoading: false, books: books);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load Bible: $e');
    }
  }
}

final bibleProvider = NotifierProvider<BibleNotifier, BibleState>(BibleNotifier.new);
