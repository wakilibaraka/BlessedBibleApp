import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TestamentLayout { sideBySide, stickySections, filterTabs }
enum NavigationDepth { twoPart, threePart, fourPart }

class BibleNavSettingsState {
  final TestamentLayout layout;
  final NavigationDepth depth;
  final bool autoCloseOnFinalSelection;
  final bool swipeDownToNav;

  const BibleNavSettingsState({
    this.layout = TestamentLayout.sideBySide,
    this.depth = NavigationDepth.twoPart,
    this.autoCloseOnFinalSelection = true,
    this.swipeDownToNav = true,
  });

  BibleNavSettingsState copyWith({
    TestamentLayout? layout,
    NavigationDepth? depth,
    bool? autoCloseOnFinalSelection,
    bool? swipeDownToNav,
  }) {
    return BibleNavSettingsState(
      layout: layout ?? this.layout,
      depth: depth ?? this.depth,
      autoCloseOnFinalSelection: autoCloseOnFinalSelection ?? this.autoCloseOnFinalSelection,
      swipeDownToNav: swipeDownToNav ?? this.swipeDownToNav,
    );
  }
}

class BibleNavSettingsNotifier extends Notifier<BibleNavSettingsState> {
  static const _layoutKey = 'bible_nav_layout';
  static const _depthKey = 'bible_nav_depth';
  static const _autoCloseKey = 'bible_nav_auto_close';
  static const _swipeDownKey = 'bible_nav_swipe_down';

  @override
  BibleNavSettingsState build() {
    _loadSettings();
    return const BibleNavSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final layoutIndex = prefs.getInt(_layoutKey) ?? TestamentLayout.sideBySide.index;
    final depthIndex = prefs.getInt(_depthKey) ?? NavigationDepth.twoPart.index;
    final autoClose = prefs.getBool(_autoCloseKey) ?? true;
    final swipeDown = prefs.getBool(_swipeDownKey) ?? true;

    state = state.copyWith(
      layout: TestamentLayout.values[layoutIndex.clamp(0, TestamentLayout.values.length - 1)],
      depth: NavigationDepth.values[depthIndex.clamp(0, NavigationDepth.values.length - 1)],
      autoCloseOnFinalSelection: autoClose,
      swipeDownToNav: swipeDown,
    );
  }

  Future<void> setLayout(TestamentLayout layout) async {
    state = state.copyWith(layout: layout);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_layoutKey, layout.index);
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
}

final bibleNavSettingsProvider = NotifierProvider<BibleNavSettingsNotifier, BibleNavSettingsState>(BibleNavSettingsNotifier.new);
