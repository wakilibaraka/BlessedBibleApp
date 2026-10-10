import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/content_fallbacks.dart';
import '../services/bible_database_service.dart';
import 'bible_provider.dart';
import 'commentary_provider.dart';
import 'dictionary_search_provider.dart';
import 'home_provider.dart';
import 'wotd_provider.dart';

/// What the startup gate verified. Exposed mainly for logging/tests.
class ContentReadiness {
  final int books;
  final int commentaryEntries;
  final String wordOfTheDay;
  final String verseOfTheDay;
  final bool votdFromLiveData;

  const ContentReadiness({
    required this.books,
    required this.commentaryEntries,
    required this.wordOfTheDay,
    required this.verseOfTheDay,
    required this.votdFromLiveData,
  });
}

/// Startup content gate. The app shell ([MainNavScreen]) is never built
/// until this resolves, so no screen can render on top of missing data.
///
/// Order matters: the Bible load drives the database install / verify /
/// repair, and WOTD reads the same database.
///
/// - Bible text: required. Throws if the KJV backbone is not fully loaded.
/// - Commentary: required. Throws if the bundled JSON fails or is empty.
/// - Word of the Day: resolved here (the provider itself never throws and
///   falls back to compiled-in content).
/// - Verse of the Day: computed here from live data; falls back to the
///   compiled-in pool (real verse + commentary) only if the live pool is
///   empty.
final contentReadyProvider = FutureProvider<ContentReadiness>((ref) async {
  final bibleNotifier = ref.read(bibleProvider.notifier);
  await bibleNotifier.loaded;
  final books = ref.read(bibleProvider).books;
  if (books.length != 66) {
    throw StateError('Bible text incomplete (${books.length}/66 books).');
  }

  final commentary = await ref.read(commentaryProvider.future);
  if (commentary.isEmpty) {
    throw StateError('Commentary library is empty.');
  }

  final wotd = await ref.read(wordOfTheDayProvider.future);

  final pool = ref.read(votdPoolProvider);
  final votdLive = !identical(pool, kFallbackVotdPool);
  if (!votdLive) {
    debugPrint('contentReadyProvider: VOTD pool empty, using compiled pool');
  }
  final home = ref.read(homeProvider);

  return ContentReadiness(
    books: books.length,
    commentaryEntries: commentary.length,
    wordOfTheDay: wotd.word,
    verseOfTheDay: home.verseOfTheDay.reference,
    votdFromLiveData: votdLive,
  );
},
    // No automatic retries: a failure must surface the recovery screen
    // (user-driven Try again / Repair), not loop silently on the splash.
    retry: (retryCount, error) => null);

/// Re-runs the gate. With [repair] the on-disk database is deleted first so
/// it re-seeds from the bundled asset (fixes corrupt / stale copies).
Future<void> retryContentGate(WidgetRef ref, {bool repair = false}) async {
  if (repair) {
    await bibleDbService.resetForRepair();
  }
  // Clear every cached failure the gate depends on.
  ref.invalidate(commentaryProvider);
  ref.invalidate(dictionaryIndexProvider);
  ref.invalidate(wordOfTheDayProvider);
  ref.read(bibleProvider.notifier).reload();
  ref.invalidate(contentReadyProvider);
}
