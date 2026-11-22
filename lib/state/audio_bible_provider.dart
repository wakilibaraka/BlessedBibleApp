import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../services/audio_bible_service.dart';
import '../services/audio_cache_service.dart';

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

  bool get isCurrentChapter => book != null && chapter != null;

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
    );
  }
}

/// One player for the whole app, so a chapter keeps playing while the reader
/// scrolls or the sheet is dismissed.
class AudioBibleNotifier extends Notifier<AudioBibleState> {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  AudioCacheService? _cache;

  @override
  AudioBibleState build() {
    ref.onDispose(() {
      _playerSub?.cancel();
      _positionSub?.cancel();
      _durationSub?.cancel();
      _player?.dispose();
    });
    return const AudioBibleState();
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
        final next =
            AudioBibleService.next(state.book ?? '', state.chapter ?? 0);
        if (next != null) {
          // Continuous listening: move to the next chapter instead of
          // silently stopping at the end of a chapter.
          unawaited(openChapter(next.bookName, next.chapter));
        } else {
          state = state.copyWith(playing: false);
        }
      }
    });
    _positionSub = player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });
    _durationSub = player.durationStream.listen((duration) {
      if (duration != null) state = state.copyWith(duration: duration);
    });
    return player;
  }

  Future<AudioCacheService> _ensureCache() async {
    final existing = _cache;
    if (existing != null) return existing;
    final support = await getApplicationSupportDirectory();
    final cache = AudioCacheService(
      Directory('${support.path}${Platform.pathSeparator}audio_bible'),
    );
    _cache = cache;
    return cache;
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

  /// Loads a chapter and (by default) starts it. A downloaded chapter plays
  /// from disk, everything else streams — that is what keeps storage small.
  Future<void> openChapter(
    String book,
    int chapter, {
    bool autoplay = true,
  }) async {
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
      );
      return;
    }

    state = state.copyWith(
      book: book,
      chapter: chapter,
      playing: false,
      buffering: true,
      position: Duration.zero,
      duration: null,
      failure: null,
    );

    final cache = await _ensureCache();
    final id = AudioBibleService.chapterId(book, chapter);
    final file = await cache.fileFor(id);
    try {
      final player = _audio;
      if (await file.exists()) {
        await player.setFilePath(file.path);
      } else {
        await player.setUrl(url);
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
  }

  Future<void> toggle() async {
    final player = _audio;
    if (!state.isCurrentChapter) return;
    if (state.playing) {
      await player.pause();
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

  Future<void> setSpeed(double speed) async {
    final clamped = speed.clamp(0.5, 2.0).toDouble();
    await _audio.setSpeed(clamped);
    state = state.copyWith(speed: clamped);
  }

  Future<void> cycleSpeed() =>
      setSpeed(AudioBibleService.nextSpeed(state.speed));

  Future<void> nextChapter() async {
    final next = AudioBibleService.next(state.book ?? '', state.chapter ?? 0);
    if (next != null) await openChapter(next.bookName, next.chapter);
  }

  Future<void> previousChapter() async {
    final previous =
        AudioBibleService.previous(state.book ?? '', state.chapter ?? 0);
    if (previous != null) {
      await openChapter(previous.bookName, previous.chapter);
    }
  }

  /// Downloads the current chapter to the cache, keeping the on-disk total
  /// under the service's cap by dropping the oldest downloads first.
  Future<void> downloadCurrent() async {
    if (!state.isCurrentChapter || state.downloadProgress != null) return;
    final url = AudioBibleService.urlFor(state.book!, state.chapter!);
    if (url == null) {
      state = state.copyWith(failure: AudioFailure.unavailable);
      return;
    }
    final id = AudioBibleService.chapterId(state.book!, state.chapter!);
    final cache = await _ensureCache();
    final target = await cache.fileFor(id);
    final partial = File('${target.path}.part');
    state = state.copyWith(downloadProgress: 0, failure: null);

    final client = http.Client();
    try {
      final response = await client.send(http.Request('GET', Uri.parse(url)));
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
      }
      await cache.trimToCap(
        incomingBytes: response.contentLength ?? 0,
        keep: {id},
      );
      final total = response.contentLength ?? 0;
      final sink = partial.openWrite();
      var received = 0;
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          state = state.copyWith(downloadProgress: received / total);
        }
      }
      await sink.flush();
      await sink.close();
      if (await target.exists()) await target.delete();
      await partial.rename(target.path);
    } catch (_) {
      if (await partial.exists()) {
        try {
          await partial.delete();
        } on FileSystemException {
          // Nothing else to do; the user can retry.
        }
      }
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
    await _audio.stop();
    state = state.copyWith(playing: false, buffering: false);
  }
}

final audioBibleProvider =
    NotifierProvider<AudioBibleNotifier, AudioBibleState>(
        AudioBibleNotifier.new);
