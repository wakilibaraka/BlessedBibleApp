import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadLocationState {
  final String bookAbbrev;
  final String bookName;
  final int chapter;
  final int? requestedVerse;
  final bool openCommentary;

  const ReadLocationState({
    this.bookAbbrev = 'REV',
    this.bookName = 'Revelation',
    this.chapter = 14,
    this.requestedVerse,
    this.openCommentary = false,
  });

  ReadLocationState copyWith({
    String? bookAbbrev,
    String? bookName,
    int? chapter,
    int? requestedVerse,
    bool clearVerse = false,
    bool? openCommentary,
    bool clearCommentary = false,
  }) {
    return ReadLocationState(
      bookAbbrev: bookAbbrev ?? this.bookAbbrev,
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      requestedVerse: clearVerse ? null : (requestedVerse ?? this.requestedVerse),
      openCommentary: clearCommentary ? false : (openCommentary ?? this.openCommentary),
    );
  }
}

class ReadLocationNotifier extends Notifier<ReadLocationState> {
  @override
  ReadLocationState build() {
    return const ReadLocationState();
  }

  void updateLocation({
    String? bookAbbrev,
    String? bookName,
    int? chapter,
    int? verse,
    bool openCommentary = false,
  }) {
    state = state.copyWith(
      bookAbbrev: bookAbbrev,
      bookName: bookName,
      chapter: chapter,
      requestedVerse: verse,
      clearVerse: verse == null && (bookAbbrev != null || chapter != null),
      openCommentary: openCommentary,
      clearCommentary: !openCommentary && (bookAbbrev != null || chapter != null),
    );
  }

  void clearRequestedVerse() {
    state = state.copyWith(clearVerse: true);
  }

  void clearCommentary() {
    state = state.copyWith(clearCommentary: true);
  }
}

final readLocationProvider = NotifierProvider<ReadLocationNotifier, ReadLocationState>(ReadLocationNotifier.new);
