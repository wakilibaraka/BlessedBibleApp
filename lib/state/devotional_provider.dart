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
