import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../data/models/devotional_story.dart';

/// Loads The Bible Stories content from bundled assets.
///
/// - `assets/devotional/stories/index.json` is loaded eagerly (light).
/// - Per-book files (`<PREFIX>.json`) are lazy-loaded on demand and cached.
/// - Artwork: `assets/devotional/art/artwork_map.json` maps book prefix ->
///   Doré plate slug; plates live at `assets/devotional/art/<slug>.webp`.
class DevotionalService {
  static const String _indexAsset = 'assets/devotional/stories/index.json';
  static const String _bookAssetPrefix = 'assets/devotional/stories/';
  static const String _artMapAsset = 'assets/devotional/art/artwork_map.json';

  final Map<String, List<DevotionalStory>> _booksByPrefix = {};
  final Map<String, String> _artByPrefix = {};
  final Map<String, String> _artCaptionBySlug = {};
  bool _artLoaded = false;

  List<DevotionalBookInfo>? _index;

  /// The loaded index, or null before the first [loadIndex] call.
  List<DevotionalBookInfo>? get indexOrNull => _index;

  /// All books in canonical chronological order.
  Future<List<DevotionalBookInfo>> loadIndex() async {
    if (_index != null) return _index!;
    final raw = await rootBundle.loadString(_indexAsset);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final books = (data['books'] as List<dynamic>)
        .map((e) => DevotionalBookInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    _index = books;
    return books;
  }

  Future<void> _ensureArtLoaded() async {
    if (_artLoaded) return;
    try {
      final raw = await rootBundle.loadString(_artMapAsset);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      data.forEach((prefix, entry) {
        final map = entry as Map<String, dynamic>;
        _artByPrefix[prefix] = map['plate'] as String;
        final slug = map['plate'] as String;
        final caption = (map['caption'] as String?) ?? '';
        if (caption.isNotEmpty) _artCaptionBySlug[slug] = caption;
      });
    } catch (_) {
      // Artwork map missing -> stories render text-only.
    }
    _artLoaded = true;
  }

  /// Loads (and caches) all stories of one book, enriched with artwork info.
  Future<List<DevotionalStory>> loadBook(String prefix) async {
    final cached = _booksByPrefix[prefix];
    if (cached != null) return cached;
    await _ensureArtLoaded();

    final raw = await rootBundle.loadString('$_bookAssetPrefix$prefix.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final bookName = data['book'] as String? ?? prefix;
    final testament = data['testament'] as String? ?? '';
    final grouping = data['grouping'] as String? ?? '';
    final order = (data['order'] as num?)?.toInt() ?? 0;

    final plateSlug = _artByPrefix[prefix];
    final plateCaption =
        plateSlug != null ? _artCaptionBySlug[plateSlug] : null;

    final storiesJson = data['stories'] as List<dynamic>? ?? [];
    final stories = <DevotionalStory>[];
    for (var i = 0; i < storiesJson.length; i++) {
      final s = DevotionalStory.fromJson(
        storiesJson[i] as Map<String, dynamic>,
        book: bookName,
        prefix: prefix,
        testament: testament,
        grouping: grouping,
        order: order,
      );
      stories.add(s.copyWithEnriched(
        indexInBook: i,
        plateSlug: plateSlug,
        plateCaption: plateCaption,
      ));
    }
    _booksByPrefix[prefix] = stories;
    return stories;
  }

  /// Flattened, chronologically ordered list across all books.
  /// The heavy text stays lazy: only references are loaded here.
  Future<List<DevotionalStory>> loadAllStoryRefs() async {
    final books = await loadIndex();
    final out = <DevotionalStory>[];
    for (final b in books) {
      // Stories are loaded per book; this is acceptable at 500 items because
      // JSON decoding happens once and results are cached.
      final stories = await loadBook(b.prefix);
      out.addAll(stories);
    }
    return out;
  }

  /// Finds the previous/next story in global chronological order.
  Future<DevotionalStory?> neighborOf(DevotionalStory story, {required bool next}) async {
    final all = await loadAllStoryRefs();
    final i = all.indexWhere((s) => s.id == story.id);
    if (i == -1) return null;
    final j = next ? i + 1 : i - 1;
    if (j < 0 || j >= all.length) return null;
    return all[j];
  }

  /// Total number of stories (from the index).
  Future<int> totalCount() async {
    final books = await loadIndex();
    var sum = 0;
    for (final b in books) {
      sum += b.count;
    }
    return sum;
  }
}
