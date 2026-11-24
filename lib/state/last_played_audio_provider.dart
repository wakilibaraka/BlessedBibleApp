import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The chapter that was last listened to, so Home can offer to resume it after
/// the app has been closed.
class LastPlayedAudio {
  const LastPlayedAudio({
    required this.book,
    required this.chapter,
    required this.position,
  });

  final String book;
  final int chapter;
  final Duration position;

  @override
  bool operator ==(Object other) =>
      other is LastPlayedAudio &&
      other.book == book &&
      other.chapter == chapter &&
      other.position == position;

  @override
  int get hashCode => Object.hash(book, chapter, position);
}

/// Whether Home should show the Continue listening card.
///
/// The card is the way back into the narration when nothing is playing, so it
/// hides when there is nothing to resume. While the mini player is already
/// showing this same chapter it would only duplicate it, so it hides then too
/// — a different chapter in the mini player leaves the card useful.
bool shouldShowContinueListening({
  required bool hasLastPlayed,
  required bool miniPlayerShowing,
  required bool miniPlayerSameItem,
}) {
  if (!hasLastPlayed) return false;
  if (miniPlayerShowing && miniPlayerSameItem) return false;
  return true;
}

/// Remembers the last chapter and position, persisted so a cold start can
/// offer to resume it.
class LastPlayedAudioNotifier extends Notifier<LastPlayedAudio?> {
  static const bookKey = 'audio_last_book';
  static const chapterKey = 'audio_last_chapter';
  static const positionKey = 'audio_last_position_ms';

  @override
  LastPlayedAudio? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final saved = await readSaved();
    if (saved != null) state = saved;
  }

  /// Reads what is on disk without waiting for the notifier to build.
  static Future<LastPlayedAudio?> readSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final book = prefs.getString(bookKey);
      final chapter = prefs.getInt(chapterKey);
      if (book == null || book.trim().isEmpty) return null;
      if (chapter == null || chapter < 1) return null;
      final millis = prefs.getInt(positionKey) ?? 0;
      return LastPlayedAudio(
        book: book,
        chapter: chapter,
        position: Duration(milliseconds: millis < 0 ? 0 : millis),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> record({
    required String book,
    required int chapter,
    required Duration position,
  }) async {
    if (book.trim().isEmpty || chapter < 1) return;
    final clamped = position < Duration.zero ? Duration.zero : position;
    state = LastPlayedAudio(book: book, chapter: chapter, position: clamped);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(bookKey, book);
      await prefs.setInt(chapterKey, chapter);
      await prefs.setInt(positionKey, clamped.inMilliseconds);
    } catch (_) {
      // Losing the resume point is not worth failing playback over.
    }
  }

  Future<void> clear() async {
    state = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(bookKey);
      await prefs.remove(chapterKey);
      await prefs.remove(positionKey);
    } catch (_) {}
  }
}

final lastPlayedAudioProvider =
    NotifierProvider<LastPlayedAudioNotifier, LastPlayedAudio?>(
        LastPlayedAudioNotifier.new);
