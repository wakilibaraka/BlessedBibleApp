import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_storage/preferences_service.dart';

class BookmarksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final list = await preferencesService.getBookmarks();
    state = list.toSet();
  }

  void toggle(String reference) {
    if (state.contains(reference)) {
      state = {...state}..remove(reference);
    } else {
      state = {...state, reference};
    }
    preferencesService.saveBookmarks(state.toList());
  }
}

final bookmarksProvider = NotifierProvider<BookmarksNotifier, Set<String>>(BookmarksNotifier.new);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final list = await preferencesService.getFavorites();
    state = list.toSet();
  }

  void toggle(String reference) {
    if (state.contains(reference)) {
      state = {...state}..remove(reference);
    } else {
      state = {...state, reference};
    }
    preferencesService.saveFavorites(state.toList());
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
