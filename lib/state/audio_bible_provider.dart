import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/audio_anchor_store.dart';
import '../services/audio_bible_service.dart';
import '../services/audio_cache_service.dart';
import '../services/audio_verse_timing.dart';
import '../services/bible_database_service.dart';
import '../services/translation_pack_store.dart';
import 'bible_provider.dart';
import 'last_played_audio_provider.dart';

const Object _unset = Object();

/// Why playback stopped, in terms the UI can localize.
enum AudioFailure { unavailable, network }

class AudioBibleState {
  const AudioBibleState({
    this.book,
    this.chapter,
    this.playing = false,
    this.buffering = false,
    this.position = Duration.zero,
    this.duration,
    this.speed = 1.0,
    this.downloadProgress,
    this.downloaded = false,
    this.cacheBytes = 0,
    this.failure,
    this.timeline = AudioVerseTimeline.empty,
    this.currentVerse,
    this.followAudio = true,
    this.advanceMode = AudioAdvanceMode.chapter,
    this.sleepRemaining,
    this.bookDownloadDone,
    this.bookDownloadTotal,
  });

  final String? book;
  final int? chapter;
  final bool playing;
  final bool buffering;
  final Duration position;
  final Duration? duration;
  final double speed;

  /// 0..1 while a chapter is downloading, null when idle.
  final double? downloadProgress;

  /// Whether the current chapter is on disk and can play offline.
  final bool downloaded;
  final int cacheBytes;
  final AudioFailure? failure;

  /// Where each verse sits in this chapter's narration. Empty until the
  /// chapter's text and duration are both known.
  final AudioVerseTimeline timeline;

  /// The verse being narrated right now, from [timeline].
  final int? currentVerse;

  /// Whether the reader scrolls to follow the narration.
  final bool followAudio;

  /// What happens at the end of a chapter.
  final AudioAdvanceMode advanceMode;

  /// Time left on the sleep timer, null when it is off.
  final Duration? sleepRemaining;

  /// Progress of a whole-book download: chapters finished / total.
  final int? bookDownloadDone;
  final int? bookDownloadTotal;

  bool get isCurrentChapter => book != null && chapter != null;

  bool get sleepTimerActive => sleepRemaining != null;

  bool get bookDownloading =>
      bookDownloadDone != null && bookDownloadTotal != null;

  AudioBibleState copyWith({
    Object? book = _unset,
    Object? chapter = _unset,
    bool? playing,
    bool? buffering,
    Duration? position,
    Object? duration = _unset,
    double? speed,
    Object? downloadProgress = _unset,
    bool? downloaded,
    int? cacheBytes,
    Object? failure = _unset,
    AudioVerseTimeline? timeline,
    Object? currentVerse = _unset,
    bool? followAudio,
    AudioAdvanceMode? advanceMode,
    Object? sleepRemaining = _unset,
    Object? bookDownloadDone = _unset,
    Object? bookDownloadTotal = _unset,
  }) {
    return AudioBibleState(
      book: identical(book, _unset) ? this.book : book as String?,
      chapter: identical(chapter, _unset) ? this.chapter : chapter as int?,
      playing: playing ?? this.playing,
      buffering: buffering ?? this.buffering,
      position: position ?? this.position,
      duration:
          identical(duration, _unset) ? this.duration : duration as Duration?,
      speed: speed ?? this.speed,
      downloadProgress: identical(downloadProgress, _unset)
          ? this.downloadProgress
          : downloadProgress as double?,
      downloaded: downloaded ?? this.downloaded,
      cacheBytes: cacheBytes ?? this.cacheBytes,
      failure:
          identical(failure, _unset) ? this.failure : failure as AudioFailure?,
      timeline: timeline ?? this.timeline,
      currentVerse: identical(currentVerse, _unset)
          ? this.currentVerse
          : currentVerse as int?,
      followAudio: followAudio ?? this.followAudio,
      advanceMode: advanceMode ?? this.advanceMode,
      sleepRemaining: identical(sleepRemaining, _unset)
          ? this.sleepRemaining
          : sleepRemaining as Duration?,
      bookDownloadDone: identical(bookDownloadDone, _unset)
          ? this.bookDownloadDone
          : bookDownloadDone as int?,
      bookDownloadTotal: identical(bookDownloadTotal, _unset)
          ? this.bookDownloadTotal
          : bookDownloadTotal as int?,
    );
  }
}

/// One player for the whole app, so a chapter keeps playing while the reader
/// scrolls or the sheet is dismissed.
class AudioBibleNotifier extends Notifier<AudioBibleState> {
  static const _followKey = 'audio_follow_audio';
  static const _advanceKey = 'audio_advance_mode';

  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  AudioCacheService? _cache;
  Timer? _sleepTicker;

  /// Set while a chapter load started by auto-advance or the next/previous
  /// buttons is in flight, so a second trigger is dropped instead of opening
  /// two chapters at once.
  bool _navigating = false;

  /// The chapter id whose completion event has already been acted on. The
  /// player can report `completed` more than once for the same source.
  String? _consumedCompletion;

  /// Verses of the chapter the timeline was last built from, and the timeline
  /// it produced, so a duration that arrives late can be applied without a
  /// second database read.
  String? _timelineChapterId;
  List<AudioVerseText> _timelineVerses = const [];
  Duration? _timelineDuration;
  bool _timelineLoading = false;

  /// Corrections the listener made by tapping the verse they can hear, kept
  /// per chapter so scrubbing back to it keeps the correction.
  final Map<String, VerseAnchor> _anchors = {};

  /// Persists those corrections, so a chapter only has to be corrected once.
  static const AudioAnchorStore _anchorStore = AudioAnchorStore();
  Future<void>? _anchorsLoading;

  bool _bookDownloading = false;

  /// A verse to jump to once the timeline for a freshly opened chapter is
  /// ready (used by "play from this verse").
  int? _pendingStartVerse;

  /// Last position written to the resume point, so the position stream does
  /// not rewrite preferences several times a second.
  Duration _lastRecordedPosition = Duration.zero;

  @override
  AudioBibleState build() {
    _loadPreferences();
    unawaited(_ensureAnchorsLoaded());
    ref.onDispose(() {
      _playerSub?.cancel();
      _positionSub?.cancel();
      _durationSub?.cancel();
      _sleepTicker?.cancel();
      _player?.dispose();
    });
    return const AudioBibleState();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final follow = prefs.getBool(_followKey);
      final modeName = prefs.getString(_advanceKey);
      final mode = modeName == null
          ? AudioAdvanceMode.chapter
          : AudioAdvanceMode.values.firstWhere(
              (m) => m.name == modeName,
              orElse: () => AudioAdvanceMode.chapter,
            );
      state = state.copyWith(
        followAudio: follow ?? state.followAudio,
        advanceMode: mode,
      );
    } catch (_) {
      // Preferences are a convenience; the defaults are usable.
    }
  }

  AudioPlayer get _audio => _player ??= _createPlayer();

  AudioPlayer _createPlayer() {
    final player = AudioPlayer();
    _playerSub = player.playerStateStream.listen((playerState) {
      final processing = playerState.processingState;
      state = state.copyWith(
        playing: playerState.playing && processing != ProcessingState.completed,
        buffering: processing == ProcessingState.loading ||
            processing == ProcessingState.buffering,
      );
      if (processing == ProcessingState.completed) {
        final completedBook = state.book;
        final completedChapter = state.chapter;
        final target = AudioBibleService.advanceAfterCompletion(
          book: completedBook,
          chapter: completedChapter,
          consumedFor: _consumedCompletion,
          navigating: _navigating,
          mode: state.advanceMode,
        );
        if (target != null) {
          _consumedCompletion =
              AudioBibleService.chapterId(completedBook!, completedChapter!);
          // Continuous listening: move to the next chapter instead of
          // silently stopping at the end of a chapter.
          unawaited(_navigate(target));
        } else if (!_navigating) {
          state = state.copyWith(playing: false);
          _clearSleepTimer();
        }
      }
    });
    _positionSub = player.positionStream.listen((position) {
      final verse = state.timeline.verseAt(position);
      state = state.copyWith(
        position: position,
        currentVerse: verse ?? state.currentVerse,
      );
      // Keep a resumable point current without writing preferences on every
      // tick; ten seconds is finer than anyone resumes to.
      if (state.isCurrentChapter &&
          (position - _lastRecordedPosition).abs() >=
              const Duration(seconds: 10)) {
        _lastRecordedPosition = position;
        _recordLastPlayed(state.book!, state.chapter!, position);
      }
    });
    _durationSub = player.durationStream.listen((duration) {
      if (duration == null) return;
      state = state.copyWith(duration: duration);
      // The first duration is what makes a timeline possible; a later change
      // means the old one was an estimate and has to be redrawn.
      if (_timelineDuration != duration) {
        _applyTimeline();
      }
    });
    return player;
  }

  Future<AudioCacheService> _ensureCache() async {
    final existing = _cache;
    if (existing != null) return existing;
    // One definition of where chapters live, shared with Settings → Storage.
    final cache = await AudioCacheService.openDefault();
    _cache = cache;
    return cache;
  }

  /// Remembers the chapter and position for Home's Continue listening card.
  void _recordLastPlayed(String book, int chapter, Duration position) {
    unawaited(ref.read(lastPlayedAudioProvider.notifier).record(
          book: book,
          chapter: chapter,
          position: position,
        ));
  }

  Future<void> _refreshCacheInfo() async {
    final cache = await _ensureCache();
    final id = state.isCurrentChapter
        ? AudioBibleService.chapterId(state.book!, state.chapter!)
        : null;
    final bytes = await cache.totalBytes();
    final downloaded = id == null ? false : await cache.has(id);
    state = state.copyWith(
      cacheBytes: bytes,
      downloaded: downloaded,
      downloadProgress: null,
    );
  }

  /// The chapter's verses in the translation that is actually narrated, so
  /// verse weights match the audio. Falls back to the backbone when the WEB
  /// pack cannot be opened for any reason.
  Future<List<AudioVerseText>> _versesForTiming(
      String book, int chapter) async {
    final books = ref.read(bibleProvider).books;
    final index = books.indexWhere((b) =>
        b.name.toLowerCase() == book.trim().toLowerCase() ||
        b.abbreviation.toLowerCase() == book.trim().toLowerCase());
    if (index < 0) return const [];
    final bookNumber = index + 1;

    for (final id in const [
      TranslationPackStore.audioTranslationId,
      'kjv',
    ]) {
      try {
        if (id != 'kjv') await bibleDbService.ensureTranslationReady(id);
        final verses = await bibleDbService.getChapter(id, bookNumber, chapter);
        if (verses.isNotEmpty) {
          return [
            for (final verse in verses)
              (number: verse.number, text: verse.text),
          ];
        }
      } catch (_) {
        // Try the next source; read-along is a bonus, not a precondition.
      }
    }
    return const [];
  }

  /// Loads saved corrections once; every chapter opened afterwards gets its
  /// correction applied by [_applyTimeline] without another disk read.
  Future<void> _ensureAnchorsLoaded() {
    return _anchorsLoading ??= _loadAnchors();
  }

  Future<void> _loadAnchors() async {
    try {
      final saved = await _anchorStore.load();
      _anchors.addAll(saved);
    } catch (_) {
      // Read-along still works without corrections; it is just an estimate.
    }
  }

  Future<void> _persistAnchor(AudioSyncAnchor anchor) async {
    try {
      await _anchorStore.save(anchor);
    } catch (_) {
      // A correction that cannot be written still applies to this session.
    }
  }

  Future<void> _loadTimeline(String book, int chapter) async {
    if (_timelineLoading) return;
    _timelineLoading = true;
    try {
      final id = AudioBibleService.chapterId(book, chapter);
      final verses = await _versesForTiming(book, chapter);
      if (verses.isEmpty) return;
      if (state.book != book || state.chapter != chapter) return;
      // A saved correction has to be in place before the first timeline is
      // built, otherwise the chapter opens uncorrected and then jumps.
      await _ensureAnchorsLoaded();
      if (state.book != book || state.chapter != chapter) return;
      _timelineChapterId = id;
      _timelineVerses = verses;
      _applyTimeline();
    } finally {
      _timelineLoading = false;
    }
  }

  /// Builds (or rebuilds) the verse timeline from the cached verses and the
  /// duration the player reported, applying the listener's anchor for this
  /// chapter if there is one.
  void _applyTimeline() {
    final duration = state.duration;
    final id = _timelineChapterId;
    if (id == null || _timelineVerses.isEmpty) return;
    if (duration == null || duration <= Duration.zero) return;
    if (_timelineDuration == duration && !state.timeline.isEmpty) return;

    final timeline = AudioVerseTiming.estimate(
      verses: _timelineVerses,
      duration: duration,
      anchor: _anchors[id],
    );
    _timelineDuration = duration;
    state = state.copyWith(
      timeline: timeline,
      currentVerse: timeline.verseAt(state.position),
    );

    // A chapter opened with "play from this verse" waits for the timeline
    // before it can seek, because verse starts are derived from the duration.
    final pending = _pendingStartVerse;
    if (pending != null) {
      _pendingStartVerse = null;
      final span = timeline.spanOf(pending);
      if (span != null) unawaited(seek(span.start));
    }
  }

  /// Plays a chapter from a specific verse, loading it first when needed.
  Future<void> playFromVerse(String book, int chapter, int verse) async {
    if (state.book == book && state.chapter == chapter) {
      if (!state.timeline.isEmpty) {
        await seekToVerse(verse);
        if (!state.playing) await toggle();
        return;
      }
      _pendingStartVerse = verse;
      _applyTimeline();
      if (!state.playing) await toggle();
      return;
    }
    await openChapter(book, chapter, startAtVerse: verse);
  }

  /// Loads a chapter and (by default) starts it. A downloaded chapter plays
  /// from disk, everything else streams — that is what keeps storage small.
  Future<void> openChapter(
    String book,
    int chapter, {
    bool autoplay = true,
    int? startAtVerse,
    Duration? startAt,
  }) async {
    _pendingStartVerse = startAtVerse;
    final url = AudioBibleService.urlFor(book, chapter);
    if (url == null) {
      state = state.copyWith(
        book: book,
        chapter: chapter,
        playing: false,
        buffering: false,
        position: Duration.zero,
        duration: null,
        failure: AudioFailure.unavailable,
        timeline: AudioVerseTimeline.empty,
        currentVerse: null,
      );
      return;
    }

    // A new load is a new completion budget: replaying this chapter later
    // must be allowed to advance again.
    _consumedCompletion = null;
    _timelineChapterId = null;
    _timelineVerses = const [];
    _timelineDuration = null;
    state = state.copyWith(
      book: book,
      chapter: chapter,
      playing: false,
      buffering: true,
      position: Duration.zero,
      duration: null,
      failure: null,
      timeline: AudioVerseTimeline.empty,
      currentVerse: null,
    );

    final cache = await _ensureCache();
    final id = AudioBibleService.chapterId(book, chapter);
    final file = await cache.fileFor(id);
    try {
      final player = _audio;
      // The media item is what the lock screen and notification show.
      final mediaItem = MediaItem(
        id: id,
        title: '$book $chapter',
        album: 'World English Bible',
        artist: 'Read by David Williams',
      );
      if (await file.exists()) {
        await player.setAudioSource(
          AudioSource.file(file.path, tag: mediaItem),
        );
      } else {
        await player.setAudioSource(
          AudioSource.uri(Uri.parse(url), tag: mediaItem),
        );
      }
      // Resuming from Home lands where the listener left off.
      if (startAt != null && startAt > Duration.zero) {
        await player.seek(startAt);
        _lastRecordedPosition = startAt;
      }
      if (autoplay) await player.play();
      state = state.copyWith(downloaded: await file.exists());
    } catch (_) {
      state = state.copyWith(
        buffering: false,
        playing: false,
        failure: AudioFailure.network,
      );
    }
    await _refreshCacheInfo();
    _recordLastPlayed(book, chapter, startAt ?? Duration.zero);
    // Read-along needs the text; it is fetched alongside playback so a slow
    // database never delays the sound.
    unawaited(_loadTimeline(book, chapter));
  }

  Future<void> toggle() async {
    final player = _audio;
    if (!state.isCurrentChapter) return;
    if (state.playing) {
      await player.pause();
      // Pausing is a natural resume point; write it immediately.
      if (state.isCurrentChapter) {
        _recordLastPlayed(state.book!, state.chapter!, state.position);
      }
    } else {
      await player.play();
    }
  }

  Future<void> seek(Duration position) async {
    if (!state.isCurrentChapter) return;
    await _audio.seek(position);
  }

  Future<void> skip(Duration offset) async {
    if (!state.isCurrentChapter) return;
    final target = state.position + offset;
    final duration = state.duration;
    var clamped = target < Duration.zero ? Duration.zero : target;
    if (duration != null && clamped > duration) clamped = duration;
    await _audio.seek(clamped);
  }

  /// Jumps to where a verse starts, using the estimated timeline.
  Future<void> seekToVerse(int verse) async {
    final span = state.timeline.spanOf(verse);
    if (span == null) return;
    await seek(span.start);
  }

  /// Records that [verse] is what the listener hears at the current position
  /// and re-draws the rest of the chapter from there. This is how the
  /// estimated timeline is corrected when it drifts.
  Future<void> anchorHere(int verse) async {
    final book = state.book;
    final chapter = state.chapter;
    if (book == null || chapter == null) return;
    final id = AudioBibleService.chapterId(book, chapter);
    final anchor = VerseAnchor(verse: verse, at: state.position);
    _anchors[id] = anchor;
    unawaited(_persistAnchor(AudioSyncAnchor(
      book: book,
      chapter: chapter,
      verse: verse,
      position: anchor.at,
      savedAt: DateTime.now(),
    )));
    _timelineDuration = null;
    _applyTimeline();
  }

  Future<void> setSpeed(double speed) async {
    final clamped = speed.clamp(0.5, 2.0).toDouble();
    await _audio.setSpeed(clamped);
    state = state.copyWith(speed: clamped);
  }

  Future<void> cycleSpeed() =>
      setSpeed(AudioBibleService.nextSpeed(state.speed));

  /// Whether the reader scrolls with the narration.
  Future<void> setFollowAudio(bool value) async {
    state = state.copyWith(followAudio: value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_followKey, value);
    } catch (_) {}
  }

  Future<void> toggleFollowAudio() => setFollowAudio(!state.followAudio);

  Future<void> setAdvanceMode(AudioAdvanceMode mode) async {
    state = state.copyWith(advanceMode: mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_advanceKey, mode.name);
    } catch (_) {}
  }

  /// Single entry point for every advance, so auto-advance and the buttons
  /// cannot both start a load for the same tap.
  Future<void> _navigate(AudioChapterRef target) async {
    if (_navigating) return;
    _navigating = true;
    try {
      await openChapter(target.bookName, target.chapter);
    } finally {
      _navigating = false;
    }
  }

  Future<void> nextChapter() async {
    final next = AudioBibleService.next(state.book ?? '', state.chapter ?? 0);
    if (next != null) await _navigate(next);
  }

  Future<void> previousChapter() async {
    final previous =
        AudioBibleService.previous(state.book ?? '', state.chapter ?? 0);
    if (previous != null) await _navigate(previous);
  }

  // ── Sleep timer ──────────────────────────────────────────────────

  static const List<Duration?> sleepOptions = [
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(minutes: 60),
    null,
  ];

  /// Steps through 15 / 30 / 45 / 60 minutes and then off.
  Future<void> cycleSleepTimer() async {
    final current = state.sleepRemaining;
    var next = sleepOptions.first;
    if (current != null) {
      // Snap to the closest option so a ticking timer still cycles cleanly.
      var best = sleepOptions.first;
      for (final option in sleepOptions) {
        if (option == null) continue;
        final bestDiff = (best! - current).abs();
        final optionDiff = (option - current).abs();
        if (optionDiff < bestDiff) best = option;
      }
      final index = sleepOptions.indexOf(best);
      next = sleepOptions[(index + 1) % sleepOptions.length];
    }
    await setSleepTimer(next);
  }

  Future<void> setSleepTimer(Duration? remaining) async {
    _sleepTicker?.cancel();
    _sleepTicker = null;
    if (remaining == null) {
      state = state.copyWith(sleepRemaining: null);
      return;
    }
    state = state.copyWith(sleepRemaining: remaining);
    _sleepTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = state.sleepRemaining;
      if (left == null) {
        timer.cancel();
        return;
      }
      final next = left - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        _sleepTicker = null;
        state = state.copyWith(sleepRemaining: null);
        unawaited(_audio.pause());
      } else {
        state = state.copyWith(sleepRemaining: next);
      }
    });
  }

  void _clearSleepTimer() {
    _sleepTicker?.cancel();
    _sleepTicker = null;
    if (state.sleepRemaining != null) {
      state = state.copyWith(sleepRemaining: null);
    }
  }

  // ── Downloads ────────────────────────────────────────────────────

  /// Downloads the current chapter to the cache, keeping the on-disk total
  /// under the service's cap by dropping the oldest downloads first.
  Future<void> downloadCurrent() async {
    if (!state.isCurrentChapter || state.downloadProgress != null) return;
    final book = state.book!;
    final chapter = state.chapter!;
    final url = AudioBibleService.urlFor(book, chapter);
    if (url == null) {
      state = state.copyWith(failure: AudioFailure.unavailable);
      return;
    }
    final id = AudioBibleService.chapterId(book, chapter);
    final cache = await _ensureCache();
    state = state.copyWith(downloadProgress: 0, failure: null);

    final client = http.Client();
    try {
      final response = await client.send(http.Request('GET', Uri.parse(url)));
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
      }
      // The cache enforces the cap itself, including when the server sends
      // no Content-Length.
      await cache.storeStream(
        id,
        response.stream,
        totalBytes: response.contentLength,
        onProgress: (received, total) {
          if (total != null && total > 0) {
            state = state.copyWith(downloadProgress: received / total);
          }
        },
      );
    } catch (_) {
      state = state.copyWith(
        downloadProgress: null,
        failure: AudioFailure.network,
      );
      return;
    } finally {
      client.close();
    }
    await _refreshCacheInfo();
  }

  /// Downloads every chapter of the current book for offline listening.
  ///
  /// Chapters already on disk are skipped, a failed chapter does not abort
  /// the rest, and the cache cap still applies (so a long book may evict its
  /// own earliest chapters — the count shown is what was attempted).
  Future<void> downloadBook() async {
    if (_bookDownloading || !state.isCurrentChapter) return;
    final book = state.book!;
    final total = AudioBibleService.chapterCount(book);
    if (total == null) return;
    _bookDownloading = true;
    final cache = await _ensureCache();
    state = state.copyWith(
      bookDownloadDone: 0,
      bookDownloadTotal: total,
      failure: null,
    );
    final client = http.Client();
    try {
      for (var chapter = 1; chapter <= total; chapter++) {
        if (!state.isCurrentChapter || state.book != book) break;
        final id = AudioBibleService.chapterId(book, chapter);
        if (!await cache.has(id)) {
          final url = AudioBibleService.urlFor(book, chapter);
          if (url != null) {
            try {
              final response =
                  await client.send(http.Request('GET', Uri.parse(url)));
              if (response.statusCode == HttpStatus.ok) {
                await cache.storeStream(
                  id,
                  response.stream,
                  totalBytes: response.contentLength,
                );
              }
            } catch (_) {
              // Keep going: one unreachable chapter should not cost the book.
            }
          }
        }
        state = state.copyWith(bookDownloadDone: chapter);
      }
    } finally {
      client.close();
      _bookDownloading = false;
      state = state.copyWith(
        bookDownloadDone: null,
        bookDownloadTotal: null,
      );
      await _refreshCacheInfo();
    }
  }

  Future<void> removeDownload() async {
    if (!state.isCurrentChapter) return;
    final cache = await _ensureCache();
    final file = await cache
        .fileFor(AudioBibleService.chapterId(state.book!, state.chapter!));
    if (await file.exists()) await file.delete();
    await _refreshCacheInfo();
  }

  Future<void> clearCache() async {
    final cache = await _ensureCache();
    await cache.clear();
    await _refreshCacheInfo();
  }

  Future<void> stop() async {
    _clearSleepTimer();
    await _audio.stop();
    state = state.copyWith(playing: false, buffering: false);
  }
}

final audioBibleProvider =
    NotifierProvider<AudioBibleNotifier, AudioBibleState>(
        AudioBibleNotifier.new);
