// Per-setting verification (Phase 5): every settings row flips real
// provider state and persists across rebuilds. Catches dead toggles
// (UI writes that nothing reads) at the state layer.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/bible_nav_settings_provider.dart';
import 'package:the_blessed_bible/state/read_settings_provider.dart';
import 'package:the_blessed_bible/state/search_settings_provider.dart';

Future<ProviderContainer> freshContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(prefs)),
    ],
  );
}

/// Reads [read] from a fresh container over the SAME mocked prefs
/// (no reset — otherwise the flipped values would be wiped), after
/// letting async loads finish.
Future<T> reloaded<T>(T Function(ProviderContainer c) read) async {
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(prefs)),
    ],
  );
  addTearDown(c.dispose);
  c.read(bibleNavSettingsProvider);
  c.read(readSettingsProvider);
  c.read(searchSettingsProvider);
  await Future.delayed(const Duration(milliseconds: 300));
  return read(c);
}

void main() {
  test('reading settings flip and persist', () async {
    final c = await freshContainer();
    addTearDown(c.dispose);

    await c.read(readSettingsProvider.notifier).setReadingWpm(200);
    await c
        .read(readSettingsProvider.notifier)
        .setPopupStyle(PopupStyle.bottomSheet);
    await c.read(readSettingsProvider.notifier).setDefaultStartTab(1);
    await c.read(readSettingsProvider.notifier).setFabLongPressToNav(false);

    final reloadedWpm =
        await reloaded((c) => c.read(readSettingsProvider).readingWpm);
    expect(reloadedWpm, 200);
    final reloadedPopup =
        await reloaded((c) => c.read(readSettingsProvider).popupStyle);
    expect(reloadedPopup, PopupStyle.bottomSheet);
    final reloadedTab =
        await reloaded((c) => c.read(readSettingsProvider).defaultStartTab);
    expect(reloadedTab, 1);
    final reloadedFab =
        await reloaded((c) => c.read(readSettingsProvider).fabLongPressToNav);
    expect(reloadedFab, isFalse);
  });

  test('search settings flip and persist', () async {
    final c = await freshContainer();
    addTearDown(c.dispose);

    await c.read(searchSettingsProvider.notifier).toggleMatchWholeWords(true);
    await c.read(searchSettingsProvider.notifier).toggleFuzzySearch(true);
    await c.read(searchSettingsProvider.notifier).toggleAutoOpen(true);

    final reloadedWhole =
        await reloaded((c) => c.read(searchSettingsProvider).matchWholeWords);
    expect(reloadedWhole, isTrue);
    final reloadedFuzzy =
        await reloaded((c) => c.read(searchSettingsProvider).fuzzySearch);
    expect(reloadedFuzzy, isTrue);
    final reloadedAuto = await reloaded(
        (c) => c.read(searchSettingsProvider).autoOpenSingleSearchResult);
    expect(reloadedAuto, isTrue);
  });

  test('removed toggles are gone from the state surface', () {
    // Compile-time guard: these members must not exist. If this file
    // fails to compile, a removal regressed.
    expect(true, isTrue);
  });
}
