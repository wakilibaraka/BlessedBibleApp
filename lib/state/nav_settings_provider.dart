import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'immersive_mode_provider.dart';
import 'read_selection_provider.dart';
import 'nav_provider.dart';

class NavSettingsState {
  final bool manualMinimizeNav;
  final bool alwaysShowNav;

  const NavSettingsState({
    this.manualMinimizeNav = false,
    this.alwaysShowNav = false,
  });

  NavSettingsState copyWith({
    bool? manualMinimizeNav,
    bool? alwaysShowNav,
  }) {
    return NavSettingsState(
      manualMinimizeNav: manualMinimizeNav ?? this.manualMinimizeNav,
      alwaysShowNav: alwaysShowNav ?? this.alwaysShowNav,
    );
  }
}

class NavSettingsNotifier extends Notifier<NavSettingsState> {
  static const _manualMinimizeKey = 'nav_manual_minimize';
  static const _alwaysShowKey = 'nav_always_show';

  @override
  NavSettingsState build() {
    _loadSettings();
    return const NavSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final manual = prefs.getBool(_manualMinimizeKey) ?? false;
    final alwaysShow = prefs.getBool(_alwaysShowKey) ?? false;

    state = state.copyWith(
      manualMinimizeNav: manual,
      alwaysShowNav: alwaysShow,
    );
  }

  Future<void> toggleManualMinimize() async {
    final newValue = !state.manualMinimizeNav;
    state = state.copyWith(manualMinimizeNav: newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_manualMinimizeKey, newValue);
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

  final settings = ref.watch(navSettingsProvider);

  // If Always Show is ON, it stays visible on Read and Study
  if (settings.alwaysShowNav) return true;

  // 1. Manual Minimize overrides everything else
  if (settings.manualMinimizeNav) return false;

  // 2. Verse Selection hides nav (mutually exclusive)
  final hasSelection = ref.watch(readSelectionProvider).isNotEmpty;
  if (hasSelection) return false;

  // 3. Scroll Auto-Hide (transient)
  final isScrollHidden = ref.watch(immersiveModeProvider);
  return !isScrollHidden;
});
