// Home/Read gesture configuration (Phase 4): safe defaults, persisted
// toggles. Pinch-to-zoom was removed — the reader keeps only chapter
// drag, verse tap, verse long-press and the FAB.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/state/bible_nav_settings_provider.dart';

void main() {
  test('gesture defaults: existing on, pull-down opens Appearance', () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(bibleNavSettingsProvider);
    expect(state.homePullDownEnabled, isTrue);
    expect(state.homePullDownTarget, HomePullDownTarget.appearance);
    expect(state.homeSwipeLeftEnabled, isTrue);
    // Appearance is index 0 so both the default and the stored-index
    // path agree on the same destination.
    expect(HomePullDownTarget.appearance.index, 0);
  });

  test('gesture toggles persist across rebuilds', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ProviderContainer();
    addTearDown(first.dispose);

    await first.read(bibleNavSettingsProvider.notifier).setHomePullDown(false);
    await first
        .read(bibleNavSettingsProvider.notifier)
        .setHomePullDownTarget(HomePullDownTarget.settings);

    // Fresh container over the same mocked prefs: values reload.
    final second = ProviderContainer();
    addTearDown(second.dispose);
    // First read builds (starting the async load); second read observes it.
    second.read(bibleNavSettingsProvider);
    await Future.delayed(const Duration(milliseconds: 300));
    final state = second.read(bibleNavSettingsProvider);
    expect(state.homePullDownEnabled, isFalse);
    expect(state.homePullDownTarget, HomePullDownTarget.settings);
  });

  test('a stored Settings choice survives the Appearance default', () async {
    // Regression guard: flipping the default must not rewrite an
    // explicit user choice.
    SharedPreferences.setMockInitialValues({
      'bible_nav_home_pull_target': HomePullDownTarget.settings.index,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(bibleNavSettingsProvider);
    await Future.delayed(const Duration(milliseconds: 300));
    expect(container.read(bibleNavSettingsProvider).homePullDownTarget,
        HomePullDownTarget.settings);
  });
}
