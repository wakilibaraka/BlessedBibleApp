import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/devotional_story.dart';
import '../data/local_storage/preferences_service.dart';
import '../services/devotional_service.dart';

final devotionalServiceProvider =
    Provider<DevotionalService>((ref) => DevotionalService());

/// All 500 stories in chronological order (loaded once, cached).
final devotionalStoriesProvider =
    FutureProvider<List<DevotionalStory>>((ref) async {
  final service = ref.watch(devotionalServiceProvider);
  return service.loadAllStoryRefs();
});

enum TestamentFilter { all, ot, nt }

class DevotionalFilterState {
  final TestamentFilter testament;
  final String? grouping; // null = all
  final String? bookPrefix; // null = all
  final String query;
  final bool favoritesOnly;
  final bool unreadOnly;

  const DevotionalFilterState({
    this.testament = TestamentFilter.all,
    this.grouping,
    this.bookPrefix,
    this.query = '',
    this.favoritesOnly = false,
    this.unreadOnly = false,
  });

  DevotionalFilterState copyWith({
    TestamentFilter? testament,
    Object? grouping = _sentinel,
    Object? bookPrefix = _sentinel,
    String? query,
    bool? favoritesOnly,
    bool? unreadOnly,
  }) {
    return DevotionalFilterState(
      testament: testament ?? this.testament,
      grouping: grouping == _sentinel ? this.grouping : grouping as String?,
      bookPrefix:
          bookPrefix == _sentinel ? this.bookPrefix : bookPrefix as String?,
      query: query ?? this.query,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      unreadOnly: unreadOnly ?? this.unreadOnly,
    );
  }

  static const Object _sentinel = Object();
}

class DevotionalFilterNotifier extends Notifier<DevotionalFilterState> {
  @override
  DevotionalFilterState build() => const DevotionalFilterState();

  void setTestament(TestamentFilter t) =>
      state = state.copyWith(testament: t, grouping: null, bookPrefix: null);

  void setGrouping(String? g) =>
      state = state.copyWith(grouping: g, bookPrefix: null);

  void setBook(String? prefix) => state = state.copyWith(bookPrefix: prefix);

  void setQuery(String q) => state = state.copyWith(query: q);

  void toggleFavoritesOnly() =>
      state = state.copyWith(favoritesOnly: !state.favoritesOnly);

  void toggleUnreadOnly() =>
      state = state.copyWith(unreadOnly: !state.unreadOnly);

  void reset() => state = const DevotionalFilterState();
}

final devotionalFilterProvider =
    NotifierProvider<DevotionalFilterNotifier, DevotionalFilterState>(
        DevotionalFilterNotifier.new);

/// Story ids the user favorited.
class DevotionalFavoritesNotifier extends Notifier<Set<String>> {
  static const String _key = 'devotional_favorites';

  @override
  Set<String> build() {
    final prefs = ref.watch(preferencesProvider);
    return (prefs.prefs.getStringList(_key) ?? const []).toSet();
  }

  void _save() {
    ref.read(preferencesProvider).prefs.setStringList(_key, state.toList());
  }

  void toggle(String id) {
    final next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
    _save();
  }

  bool isFavorite(String id) => state.contains(id);
}

final devotionalFavoritesProvider =
    NotifierProvider<DevotionalFavoritesNotifier, Set<String>>(
        DevotionalFavoritesNotifier.new);

/// Story ids the user has marked as read.
class DevotionalReadNotifier extends Notifier<Set<String>> {
  static const String _key = 'devotional_read';

  @override
  Set<String> build() {
    final prefs = ref.watch(preferencesProvider);
    return (prefs.prefs.getStringList(_key) ?? const []).toSet();
  }

  void markRead(String id) {
    if (state.contains(id)) return;
    state = {...state, id};
    ref.read(preferencesProvider).prefs.setStringList(_key, state.toList());
  }

  bool isRead(String id) => state.contains(id);
}

final devotionalReadProvider =
    NotifierProvider<DevotionalReadNotifier, Set<String>>(
        DevotionalReadNotifier.new);

/// Applies the current filter to the full story list.
final filteredDevotionalStoriesProvider =
    Provider<List<DevotionalStory>>((ref) {
  final all = ref.watch(devotionalStoriesProvider).value ?? const [];
  final filter = ref.watch(devotionalFilterProvider);
  final favorites = ref.watch(devotionalFavoritesProvider);
  final read = ref.watch(devotionalReadProvider);

  final q = filter.query.trim().toLowerCase();
  Iterable<DevotionalStory> out = all;

  if (filter.testament != TestamentFilter.all) {
    final want = filter.testament == TestamentFilter.ot ? 'OT' : 'NT';
    out = out.where((s) => s.testament == want);
  }
  if (filter.grouping != null) {
    out = out.where((s) => s.grouping == filter.grouping);
  }
  if (filter.bookPrefix != null) {
    out = out.where((s) => s.prefix == filter.bookPrefix);
  }
  if (filter.favoritesOnly) {
    out = out.where((s) => favorites.contains(s.id));
  }
  if (filter.unreadOnly) {
    out = out.where((s) => !read.contains(s.id));
  }
  if (q.isNotEmpty) {
    out = out.where((s) =>
        s.title.toLowerCase().contains(q) ||
        s.ref.toLowerCase().contains(q) ||
        s.book.toLowerCase().contains(q) ||
        s.id.toLowerCase().contains(q));
  }
  return out.toList(growable: false);
});

/// Books available for the active testament/grouping filter.
final devotionalBooksProvider = Provider<List<DevotionalBookInfo>>((ref) {
  final filter = ref.watch(devotionalFilterProvider);
  final index = ref.watch(devotionalServiceProvider).indexOrNull ?? const [];
  return index.where((b) {
    if (filter.testament == TestamentFilter.ot && b.testament != 'OT') {
      return false;
    }
    if (filter.testament == TestamentFilter.nt && b.testament != 'NT') {
      return false;
    }
    if (filter.grouping != null && b.grouping != filter.grouping) return false;
    return true;
  }).toList(growable: false);
});

/// Whether the story reader prints the full scripture passage above the
/// retelling. Off by default: the story comes first and the passage opens
/// from the reference chip. On restores the previous layout.
class StoryShowPassageNotifier extends Notifier<bool> {
  static const String _key = 'story_show_passage';

  @override
  bool build() {
    final prefs = ref.watch(preferencesProvider);
    return prefs.prefs.getBool(_key) ?? false;
  }

  void set(bool value) {
    state = value;
    ref.read(preferencesProvider).prefs.setBool(_key, value);
  }
}

final storyShowPassageProvider =
    NotifierProvider<StoryShowPassageNotifier, bool>(
        StoryShowPassageNotifier.new);

/// How a story mark is drawn.
enum StoryMarkKind { highlight, underline }

/// A highlight or underline on a story's retelling. [start]/[end] count
/// characters of the rendered retelling (see `renderedProse`), so marks
/// survive layout and font changes. [colorIndex] indexes `highlightPalette`.
class StoryMark {
  final int start;
  final int end;
  final StoryMarkKind kind;
  final int colorIndex;

  const StoryMark({
    required this.start,
    required this.end,
    required this.kind,
    this.colorIndex = 0,
  });

  bool overlaps(int s, int e) => start < e && end > s;

  Map<String, dynamic> toJson() => {
        's': start,
        'e': end,
        'k': kind.name,
        'c': colorIndex,
      };

  static StoryMark? fromJson(Object? json) {
    if (json is! Map) return null;
    final s = json['s'], e = json['e'];
    if (s is! int || e is! int || e <= s) return null;
    return StoryMark(
      start: s,
      end: e,
      kind: json['k'] == StoryMarkKind.underline.name
          ? StoryMarkKind.underline
          : StoryMarkKind.highlight,
      colorIndex: json['c'] is int ? json['c'] as int : 0,
    );
  }
}

/// Highlights and underlines per story id, saved on the device.
class StoryMarksNotifier extends Notifier<Map<String, List<StoryMark>>> {
  static const String _key = 'story_marks';

  @override
  Map<String, List<StoryMark>> build() {
    final raw = ref.watch(preferencesProvider).prefs.getString(_key);
    if (raw == null) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          entry.key: [
            for (final m in entry.value as List<dynamic>)
              if (StoryMark.fromJson(m) case final mark?) mark,
          ],
      }..removeWhere((_, marks) => marks.isEmpty);
    } catch (_) {
      return const {};
    }
  }

  void _save() {
    ref.read(preferencesProvider).prefs.setString(
          _key,
          jsonEncode({
            for (final e in state.entries)
              e.key: [for (final m in e.value) m.toJson()],
          }),
        );
  }

  /// Adds [mark], replacing marks of the same kind it overlaps.
  void add(String storyId, StoryMark mark) {
    final current = state[storyId] ?? const <StoryMark>[];
    final kept = [
      for (final m in current)
        if (m.kind != mark.kind || !m.overlaps(mark.start, mark.end)) m,
    ];
    state = {
      ...state,
      storyId: [...kept, mark]..sort((a, b) => a.start.compareTo(b.start)),
    };
    _save();
  }

  /// Removes every mark overlapping [start, end).
  void removeRange(String storyId, int start, int end) {
    final current = state[storyId];
    if (current == null) return;
    final kept = [
      for (final m in current)
        if (!m.overlaps(start, end)) m
    ];
    state = {...state, storyId: kept}..removeWhere((_, v) => v.isEmpty);
    _save();
  }
}

final storyMarksProvider =
    NotifierProvider<StoryMarksNotifier, Map<String, List<StoryMark>>>(
        StoryMarksNotifier.new);

/// Finds [selection] in [rendered], ignoring differences in whitespace
/// (a selection across paragraphs may join them with any line break).
/// Returns the first match's range, or null.
({int start, int end})? locateSelection(String rendered, String selection) {
  final words = selection.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) return null;
  final pattern = RegExp(words.map(RegExp.escape).join(r'\s+'));
  final match = pattern.firstMatch(rendered);
  if (match == null) return null;
  return (start: match.start, end: match.end);
}
