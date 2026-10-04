import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NavigationDepth { twoPart, threePart, fourPart }

/// Destination of the Home pull-down gesture.
enum HomePullDownTarget { settings, appearance }

class BibleNavSettingsState {
  final NavigationDepth depth;
  final bool autoCloseOnFinalSelection;
  final bool swipeDownToNav;

  /// Home overscroll pull-down → pull target (default Settings).
  final bool homePullDownEnabled;

  /// Where the Home pull-down goes.
  final HomePullDownTarget homePullDownTarget;

  /// Home swipe-left → Read tab.
  final bool homeSwipeLeftEnabled;

  /// Pinch-to-zoom reading font in Read (off by default).
  final bool pinchToZoomFont;

  const BibleNavSettingsState({
    this.depth = NavigationDepth.threePart,
    this.autoCloseOnFinalSelection = true,
    this.swipeDownToNav = true,
    this.homePullDownEnabled = true,
    this.homePullDownTarget = HomePullDownTarget.settings,
    this.homeSwipeLeftEnabled = true,
    this.pinchToZoomFont = false,
  });

  BibleNavSettingsState copyWith({
    NavigationDepth? depth,
    bool? autoCloseOnFinalSelection,
    bool? swipeDownToNav,
    bool? homePullDownEnabled,
    HomePullDownTarget? homePullDownTarget,
    bool? homeSwipeLeftEnabled,
    bool? pinchToZoomFont,
  }) {
    return BibleNavSettingsState(
      depth: depth ?? this.depth,
      autoCloseOnFinalSelection:
          autoCloseOnFinalSelection ?? this.autoCloseOnFinalSelection,
      swipeDownToNav: swipeDownToNav ?? this.swipeDownToNav,
      homePullDownEnabled: homePullDownEnabled ?? this.homePullDownEnabled,
      homePullDownTarget: homePullDownTarget ?? this.homePullDownTarget,
      homeSwipeLeftEnabled:
          homeSwipeLeftEnabled ?? this.homeSwipeLeftEnabled,
      pinchToZoomFont: pinchToZoomFont ?? this.pinchToZoomFont,
    );
  }
}

class BibleNavSettingsNotifier extends Notifier<BibleNavSettingsState> {
  static const _depthKey = 'bible_nav_depth';
  static const _autoCloseKey = 'bible_nav_auto_close';
  static const _swipeDownKey = 'bible_nav_swipe_down';
  static const _homePullDownKey = 'bible_nav_home_pull_down';
  static const _homePullTargetKey = 'bible_nav_home_pull_target';
  static const _homeSwipeLeftKey = 'bible_nav_home_swipe_left';
  static const _pinchZoomKey = 'bible_nav_pinch_zoom_font';

  @override
  BibleNavSettingsState build() {
    _loadSettings();
    return const BibleNavSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final depthIndex =
        prefs.getInt(_depthKey) ?? NavigationDepth.threePart.index;
    final autoClose = prefs.getBool(_autoCloseKey) ?? true;
    final swipeDown = prefs.getBool(_swipeDownKey) ?? true;
    final homePull = prefs.getBool(_homePullDownKey) ?? true;
    final homeSwipe = prefs.getBool(_homeSwipeLeftKey) ?? true;
    final pinchZoom = prefs.getBool(_pinchZoomKey) ?? false;
    final pullTargetIndex = prefs.getInt(_homePullTargetKey) ?? 0;

    state = state.copyWith(
      depth: NavigationDepth
          .values[depthIndex.clamp(0, NavigationDepth.values.length - 1)],
      autoCloseOnFinalSelection: autoClose,
      swipeDownToNav: swipeDown,
      homePullDownEnabled: homePull,
      homePullDownTarget: HomePullDownTarget
          .values[pullTargetIndex.clamp(0, HomePullDownTarget.values.length - 1)],
      homeSwipeLeftEnabled: homeSwipe,
      pinchToZoomFont: pinchZoom,
    );
  }

  Future<void> setDepth(NavigationDepth depth) async {
    state = state.copyWith(depth: depth);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_depthKey, depth.index);
  }

  Future<void> setAutoClose(bool autoClose) async {
    state = state.copyWith(autoCloseOnFinalSelection: autoClose);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCloseKey, autoClose);
  }

  Future<void> setSwipeDown(bool swipeDown) async {
    state = state.copyWith(swipeDownToNav: swipeDown);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_swipeDownKey, swipeDown);
  }

  Future<void> setHomePullDown(bool enabled) async {
    state = state.copyWith(homePullDownEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homePullDownKey, enabled);
  }

  Future<void> setHomePullDownTarget(HomePullDownTarget target) async {
    state = state.copyWith(homePullDownTarget: target);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_homePullTargetKey, target.index);
  }

  Future<void> setHomeSwipeLeft(bool enabled) async {
    state = state.copyWith(homeSwipeLeftEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeSwipeLeftKey, enabled);
  }

  Future<void> setPinchToZoomFont(bool enabled) async {
    state = state.copyWith(pinchToZoomFont: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinchZoomKey, enabled);
  }
}

final bibleNavSettingsProvider =
    NotifierProvider<BibleNavSettingsNotifier, BibleNavSettingsState>(
        BibleNavSettingsNotifier.new);
