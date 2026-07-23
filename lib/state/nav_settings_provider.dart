import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'immersive_mode_provider.dart';
import 'read_selection_provider.dart';
import 'nav_provider.dart';

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
  final isReadOrStudy = currentIndex == 1 || currentIndex == 3;

  // On Home, Search, and Settings, the bottom nav is ALWAYS visible
  if (!isReadOrStudy) return true;

  // 1. Verse Selection hides nav (mutually exclusive)
  final hasSelection = ref.watch(readSelectionProvider).isNotEmpty;
  if (hasSelection) return false;

  // 2. Immersive Mode controls the nav visibility directly (both manual toggle and scroll)
  final isScrollHidden = ref.watch(immersiveModeProvider);
  return !isScrollHidden;
});
