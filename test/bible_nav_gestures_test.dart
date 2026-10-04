// Home/Read gesture configuration (Phase 4): safe defaults, persisted
// toggles, and the new gestures off unless the user enables them.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/state/bible_nav_settings_provider.dart';

void main() {
  test('gesture defaults: existing on, new ones off', () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(bibleNavSettingsProvider);
    expect(state.homePullDownEnabled, isTrue);
    expect(state.homePullDownTarget, HomePullDownTarget.settings);
    expect(state.homeSwipeLeftEnabled, isTrue);
    expect(state.pinchToZoomFont, isFalse);
  });

  test('gesture toggles persist across rebuilds', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ProviderContainer();
    addTearDown(first.dispose);

    await first
        .read(bibleNavSettingsProvider.notifier)
        .setPinchToZoomFont(true);
    await first
        .read(bibleNavSettingsProvider.notifier)
        .setHomePullDown(false);
    await first
        .read(bibleNavSettingsProvider.notifier)
        .setHomePullDownTarget(HomePullDownTarget.appearance);

    // Fresh container over the same mocked prefs: values reload.
    final second = ProviderContainer();
    addTearDown(second.dispose);
    // First read builds (starting the async load); second read observes it.
    second.read(bibleNavSettingsProvider);
    await Future.delayed(const Duration(milliseconds: 300));
    final state = second.read(bibleNavSettingsProvider);
    expect(state.pinchToZoomFont, isTrue);
    expect(state.homePullDownEnabled, isFalse);
    expect(
        state.homePullDownTarget, HomePullDownTarget.appearance);
  });
}
