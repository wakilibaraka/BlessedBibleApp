// Stories filters: testament segments, book dropdown selection,
// favorites/unread narrows, and reset. Plain tests with real async
// (rootBundle works here); binding initialized for services.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/devotional_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> makeContainer() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
      ],
    );
  }

  test('default filter shows all 500 stories', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    final all = await container.read(devotionalStoriesProvider.future);
    expect(all.length, 500);
    final filtered = container.read(filteredDevotionalStoriesProvider);
    expect(filtered.length, 500);
  });

  test('testament segments narrow correctly', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    await container.read(devotionalStoriesProvider.future);
    container
        .read(devotionalFilterProvider.notifier)
        .setTestament(TestamentFilter.ot);
    var filtered = container.read(filteredDevotionalStoriesProvider);
    expect(filtered.isNotEmpty, isTrue);
    expect(filtered.every((s) => s.testament == 'OT'), isTrue);

    container
        .read(devotionalFilterProvider.notifier)
        .setTestament(TestamentFilter.nt);
    filtered = container.read(filteredDevotionalStoriesProvider);
    expect(filtered.isNotEmpty, isTrue);
    expect(filtered.every((s) => s.testament == 'NT'), isTrue);
  });

  test('book dropdown selection filters to one book', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    await container.read(devotionalStoriesProvider.future);
    container.read(devotionalFilterProvider.notifier).setBook('GEN');
    final filtered = container.read(filteredDevotionalStoriesProvider);
    expect(filtered.isNotEmpty, isTrue);
    expect(filtered.every((s) => s.prefix == 'GEN'), isTrue);
    expect(filtered.every((s) => s.book == 'Genesis'), isTrue);
  });

  test('favorites-only with none saved is empty; reset restores', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    await container.read(devotionalStoriesProvider.future);
    container.read(devotionalFilterProvider.notifier).toggleFavoritesOnly();
    expect(container.read(filteredDevotionalStoriesProvider), isEmpty);

    container.read(devotionalFilterProvider.notifier).reset();
    expect(container.read(filteredDevotionalStoriesProvider).length, 500);
  });

  test('favoriting a story surfaces it under favorites-only', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);

    final all = await container.read(devotionalStoriesProvider.future);
    container.read(devotionalFavoritesProvider.notifier).toggle(all.first.id);
    container.read(devotionalFilterProvider.notifier).toggleFavoritesOnly();
    final filtered = container.read(filteredDevotionalStoriesProvider);
    expect(filtered.length, 1);
    expect(filtered.first.id, all.first.id);
  });
}
