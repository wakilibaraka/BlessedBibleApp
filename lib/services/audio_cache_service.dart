import 'dart:io';

/// On-disk storage for chapters the listener chose to keep.
///
/// The default is streaming, so this directory can legitimately stay empty.
/// A hard cap keeps a listener who downloads carelessly from filling the
/// device: the oldest chapters are dropped until the newest fit.
class AudioCacheService {
  AudioCacheService(this.root, {this.maxBytes = defaultMaxBytes});

  /// 200 MB is roughly a month of daily chapters, or a whole short book.
  static const int defaultMaxBytes = 200 * 1024 * 1024;

  final Directory root;
  final int maxBytes;

  Future<Directory> ensureRoot() async {
    if (!await root.exists()) await root.create(recursive: true);
    return root;
  }

  /// Chapter ids contain a colon and spaces ("1 corinthians:13"); flatten them
  /// so the file name is portable and stable across platforms.
  static String fileNameFor(String chapterId) {
    final safe = chapterId
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return '${safe.isEmpty ? 'chapter' : safe}.mp3';
  }

  Future<File> fileFor(String chapterId) async {
    final dir = await ensureRoot();
    return File('${dir.path}/${fileNameFor(chapterId)}');
  }

  Future<bool> has(String chapterId) async =>
      (await fileFor(chapterId)).exists();

  Future<int> totalBytes() async {
    if (!await root.exists()) return 0;
    var total = 0;
    await for (final entity in root.list()) {
      if (entity is File && entity.path.endsWith('.mp3')) {
        total += await entity.length();
      }
    }
    return total;
  }

  /// Drops the oldest downloads (by modified time) until [incomingBytes] more
  /// would fit under [maxBytes]. [keep] is never deleted — it is the file the
  /// caller is writing right now.
  Future<void> trimToCap({
    int incomingBytes = 0,
    Set<String> keep = const {},
  }) async {
    if (!await root.exists()) return;
    final files = <File>[];
    await for (final entity in root.list()) {
      if (entity is File && entity.path.endsWith('.mp3')) files.add(entity);
    }
    if (files.isEmpty) return;
    var total = 0;
    final stats = <File, int>{};
    for (final file in files) {
      final length = await file.length();
      stats[file] = length;
      total += length;
    }
    if (total + incomingBytes <= maxBytes) return;
    final keepNames = keep.map(fileNameFor).toSet();
    files
        .sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
    for (final file in files) {
      if (total + incomingBytes <= maxBytes) break;
      if (keepNames.contains(file.uri.pathSegments.last)) continue;
      try {
        await file.delete();
        total -= stats[file] ?? 0;
      } on FileSystemException {
        // A file the OS already removed is not an error here.
      }
    }
  }

  /// How often the cap is re-checked while a download of unknown length is
  /// still streaming in. Small enough that a 200 MB cap cannot be blown by
  /// more than this before the next eviction.
  static const int capCheckInterval = 512 * 1024;

  /// Writes [chunks] to this chapter's file, enforcing the cap as it goes.
  ///
  /// With a Content-Length the space is reserved up front; without one (a
  /// chunked response) the partial size is counted against the cap every
  /// [capCheckInterval] bytes, so the 200 MB limit holds either way. The
  /// chapter being written is never evicted.
  Future<void> storeStream(
    String chapterId,
    Stream<List<int>> chunks, {
    int? totalBytes,
    void Function(int received, int? total)? onProgress,
  }) async {
    final target = await fileFor(chapterId);
    final partial = File('${target.path}.part');
    final sink = partial.openWrite();
    var received = 0;
    var lastCapCheck = 0;
    try {
      if (totalBytes != null) {
        await trimToCap(incomingBytes: totalBytes, keep: {chapterId});
      }
      await for (final chunk in chunks) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, totalBytes);
        if (totalBytes == null && received - lastCapCheck >= capCheckInterval) {
          lastCapCheck = received;
          await trimToCap(incomingBytes: received, keep: {chapterId});
        }
      }
      await sink.flush();
      await sink.close();
      if (await target.exists()) await target.delete();
      await partial.rename(target.path);
      // Final pass: now that the file is on disk it is counted directly, so
      // anything that slipped in during the transfer is trimmed here.
      await trimToCap(keep: {chapterId});
    } catch (_) {
      try {
        await sink.close();
      } on StateError {
        // The sink may already be closed by the failure path.
      }
      if (await partial.exists()) {
        try {
          await partial.delete();
        } on FileSystemException {
          // Nothing else to do; the user can retry.
        }
      }
      rethrow;
    }
  }

  Future<void> clear() async {
    if (!await root.exists()) return;
    await for (final entity in root.list()) {
      if (entity is File) {
        try {
          await entity.delete();
        } on FileSystemException {
          // Ignore files that vanished mid-listing.
        }
      }
    }
  }
}
