import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'audio_bible_service.dart';
import 'audio_verse_timing.dart';

/// A listener's correction to a chapter's estimated verse timeline: "this
/// verse is playing right now, at this position".
///
/// Persisted per chapter, so a chapter only has to be corrected once — the
/// correction is still there after the app is restarted.
class AudioSyncAnchor {
  const AudioSyncAnchor({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.position,
    required this.savedAt,
  });

  final String book;
  final int chapter;
  final int verse;
  final Duration position;
  final DateTime savedAt;

  String get chapterId => AudioBibleService.chapterId(book, chapter);

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'position_ms': position.inMilliseconds,
        'saved_at': savedAt.millisecondsSinceEpoch,
      };

  /// Null for anything that could not be a usable anchor, so a corrupt entry
  /// is skipped instead of breaking every chapter's read-along.
  static AudioSyncAnchor? fromJson(Object? value) {
    if (value is! Map) return null;
    final book = value['book'];
    final chapter = value['chapter'];
    final verse = value['verse'];
    if (book is! String || book.trim().isEmpty) return null;
    if (chapter is! int || chapter < 1) return null;
    if (verse is! int || verse < 1) return null;
    final millis = value['position_ms'];
    final saved = value['saved_at'];
    return AudioSyncAnchor(
      book: book,
      chapter: chapter,
      verse: verse,
      position:
          Duration(milliseconds: millis is int && millis > 0 ? millis : 0),
      savedAt: DateTime.fromMillisecondsSinceEpoch(saved is int ? saved : 0),
    );
  }

  VerseAnchor toVerseAnchor() => VerseAnchor(verse: verse, at: position);

  @override
  bool operator ==(Object other) =>
      other is AudioSyncAnchor &&
      other.book == book &&
      other.chapter == chapter &&
      other.verse == verse &&
      other.position == position &&
      other.savedAt == savedAt;

  @override
  int get hashCode => Object.hash(book, chapter, verse, position, savedAt);
}

/// On-disk home for [AudioSyncAnchor]s, one per chapter.
class AudioAnchorStore {
  const AudioAnchorStore({this.maxChapters = 200});

  static const String storageKey = 'audio_sync_anchors';

  /// One correction per chapter is all that is useful, and this keeps a
  /// listener who corrects chapter after chapter from growing the store
  /// without limit. The oldest corrections are dropped first.
  final int maxChapters;

  /// Every stored correction, keyed by chapter id.
  Future<Map<String, AudioSyncAnchor>> readAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final out = <String, AudioSyncAnchor>{};
      decoded.forEach((_, value) {
        final anchor = AudioSyncAnchor.fromJson(value);
        if (anchor != null) out[anchor.chapterId] = anchor;
      });
      return out;
    } catch (_) {
      return {};
    }
  }

  /// The same corrections in the shape the timeline wants.
  Future<Map<String, VerseAnchor>> load() async {
    final all = await readAll();
    return {
      for (final entry in all.entries) entry.key: entry.value.toVerseAnchor(),
    };
  }

  /// Stores [anchor], replacing any earlier correction for its chapter.
  Future<void> save(AudioSyncAnchor anchor) async {
    final all = await readAll();
    all[anchor.chapterId] = anchor;
    while (all.length > maxChapters) {
      final oldest = all.entries.reduce(
        (a, b) => a.value.savedAt.isBefore(b.value.savedAt) ? a : b,
      );
      all.remove(oldest.key);
    }
    await _write(all);
  }

  Future<void> remove(String chapterId) async {
    final all = await readAll();
    if (all.remove(chapterId) == null) return;
    await _write(all);
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (_) {}
  }

  Future<void> _write(Map<String, AudioSyncAnchor> all) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageKey,
      jsonEncode({
        for (final entry in all.entries) entry.key: entry.value.toJson(),
      }),
    );
  }
}
