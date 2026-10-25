import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_storage/preferences_service.dart';
import 'bible_provider.dart';
import 'nav_provider.dart';

class ReadLocationState {
  final String bookAbbrev;
  final String bookName;
  final int chapter;
  final int? requestedVerse;
  final bool openCommentary;

  const ReadLocationState({
    this.bookAbbrev = 'gn', // Matches JSON abbrev field (always lowercase)
    this.bookName = 'Genesis',
    this.chapter = 1,
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
      requestedVerse:
          clearVerse ? null : (requestedVerse ?? this.requestedVerse),
      openCommentary:
          clearCommentary ? false : (openCommentary ?? this.openCommentary),
    );
  }
}

class ReadLocationNotifier extends Notifier<ReadLocationState> {
  @override
  ReadLocationState build() {
    final prefs = ref.watch(preferencesProvider);
    final lastLoc = prefs.getLastReadLocation();

    if (lastLoc != null) {
      return ReadLocationState(
        bookAbbrev: (lastLoc['bookAbbrev'] as String? ?? 'gn').toLowerCase(),
        bookName: lastLoc['bookName'] as String? ?? 'Genesis',
        chapter: lastLoc['chapter'] as int? ?? 1,
        requestedVerse: (lastLoc['verseIndex'] as int? ?? 0) + 1,
      );
    }

    return const ReadLocationState();
  }

  void updateLocation({
    String? bookAbbrev,
    String? bookName,
    int? chapter,
    int? verse,
    bool openCommentary = false,
  }) {
    // Callers usually know only one half of the book identity: the commentary
    // sheet passes a name, the plan reader an abbreviation. Resolve the pair
    // together, because a stale half would otherwise keep pointing at the
    // previously read book ("Daniel 11" opening Genesis 11).
    String? abbrev = bookAbbrev;
    String? name = bookName;
    final wanted = (bookName ?? bookAbbrev)?.toLowerCase();
    if (wanted != null) {
      for (final book in ref.read(bibleProvider).books) {
        if (book.name.toLowerCase() == wanted ||
            book.abbreviation.toLowerCase() == wanted) {
          abbrev = book.abbreviation;
          name = book.name;
          break;
        }
      }
      abbrev ??= name;
      name ??= abbrev;
    }

    state = state.copyWith(
      bookAbbrev: abbrev,
      bookName: name,
      chapter: chapter,
      requestedVerse: verse,
      clearVerse: verse == null && (bookAbbrev != null || chapter != null),
      openCommentary: openCommentary,
      clearCommentary:
          !openCommentary && (bookAbbrev != null || chapter != null),
    );
  }

  void clearRequestedVerse() {
    state = state.copyWith(clearVerse: true);
  }

  void clearCommentary() {
    state = state.copyWith(clearCommentary: true);
  }
}

final readLocationProvider =
    NotifierProvider<ReadLocationNotifier, ReadLocationState>(
        ReadLocationNotifier.new);

/// Reusable trigger to jump to a specific verse in the reader.
/// Opens the reader tab (index 1), loads the requested book/chapter,
/// and sets the requestedVerse to trigger the scrolling/highlighting logic.
void openReaderAtVerse(WidgetRef ref,
    {required String bookName, required int chapter, int? verse}) {
  ref.read(readLocationProvider.notifier).updateLocation(
        bookName: bookName,
        chapter: chapter,
        verse: verse,
      );
  ref.read(navProvider.notifier).setIndex(1);
}
