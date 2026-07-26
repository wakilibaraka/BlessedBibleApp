import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'read_selection_provider.dart';
import 'nav_provider.dart';
import 'immersive_mode_provider.dart';
import 'read_settings_provider.dart';

class NavSettingsState {
  final bool alwaysShowNav;

  const NavSettingsState({
    this.alwaysShowNav = false,
  });

  NavSettingsState copyWith({
    bool? alwaysShowNav,
  }) {
    return NavSettingsState(
      alwaysShowNav: alwaysShowNav ?? this.alwaysShowNav,
    );
  }
}

class NavSettingsNotifier extends Notifier<NavSettingsState> {
  static const _alwaysShowKey = 'nav_always_show';

  @override
  NavSettingsState build() {
    _loadSettings();
    return const NavSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final alwaysShow = prefs.getBool(_alwaysShowKey) ?? false;

    state = state.copyWith(
      alwaysShowNav: alwaysShow,
    );
  }

  Future<void> setAlwaysShowNav(bool value) async {
    state = state.copyWith(alwaysShowNav: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alwaysShowKey, value);
  }
}

final navSettingsProvider = NotifierProvider<NavSettingsNotifier, NavSettingsState>(NavSettingsNotifier.new);

final bottomNavVisibilityProvider = Provider<bool>((ref) {
  final currentIndex = ref.watch(navProvider);
  final isRead = currentIndex == 1;

  // On Home, Search, and Settings, the bottom nav is ALWAYS visible
  if (!isRead) return true;

  // 1. Verse Selection hides nav (mutually exclusive)
  final hasSelection = ref.watch(readSelectionProvider).isNotEmpty;
  if (hasSelection) return false;

  // 2. Immersive mode hides nav on Read
  final isImmersive = ref.watch(immersiveModeProvider);
  final readSettings = ref.watch(readSettingsProvider);
  if (isImmersive && readSettings.readingViewMode == ReadingViewMode.immersive) return false;

  return true;
});
