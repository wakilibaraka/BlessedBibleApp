import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingViewMode { immersive, pinned }
enum BackgroundGlowStyle { top, full }
enum VerseActionStyle { classic, detached, horizontal, raindrop }
enum ReadingLayout { single, interleaved, sideBySide, chips }
enum GestureSensitivity { fluid, firm }

class ReadSettingsState {
  final ReadingViewMode readingViewMode;
  final BackgroundGlowStyle backgroundGlowStyle;
  final bool isGlowEnabled;
  final double glowIntensity;
  final VerseActionStyle verseActionStyle;
  final int activeHighlightColorIndex;
  final int primaryHighlightColorIndex;
  final int secondaryHighlightColorIndex;
  final bool isManualNavHidden;
  final bool isRedLetterEnabled;
  final bool showVerseNumbers;
  final bool keepScreenAwake;
  final int defaultStartTab; // 0=Home, 1=Read, 2=Search, 3=Study
  final ReadingLayout readingLayout;
  final GestureSensitivity gestureSensitivity;

  const ReadSettingsState({
    this.readingViewMode = ReadingViewMode.pinned,
    this.backgroundGlowStyle = BackgroundGlowStyle.top,
    this.isGlowEnabled = true,
    this.glowIntensity = 1.0,
    this.verseActionStyle = VerseActionStyle.horizontal,
    this.activeHighlightColorIndex = 2,
    this.primaryHighlightColorIndex = -1, // Ask every time
    this.secondaryHighlightColorIndex = 1, // Green
    this.isManualNavHidden = false,
    this.isRedLetterEnabled = true,
    this.showVerseNumbers = true,
    this.keepScreenAwake = false,
    this.defaultStartTab = 0,
    this.readingLayout = ReadingLayout.single,
    this.gestureSensitivity = GestureSensitivity.fluid,
  });

  ReadSettingsState copyWith({
    ReadingViewMode? readingViewMode,
    BackgroundGlowStyle? backgroundGlowStyle,
    bool? isGlowEnabled,
    double? glowIntensity,
    VerseActionStyle? verseActionStyle,
    int? activeHighlightColorIndex,
    int? primaryHighlightColorIndex,
    int? secondaryHighlightColorIndex,
    bool? isManualNavHidden,
    bool? isRedLetterEnabled,
    bool? showVerseNumbers,
    bool? keepScreenAwake,
    int? defaultStartTab,
    ReadingLayout? readingLayout,
    GestureSensitivity? gestureSensitivity,
  }) {
    return ReadSettingsState(
      readingViewMode: readingViewMode ?? this.readingViewMode,
      backgroundGlowStyle: backgroundGlowStyle ?? this.backgroundGlowStyle,
      isGlowEnabled: isGlowEnabled ?? this.isGlowEnabled,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      verseActionStyle: verseActionStyle ?? this.verseActionStyle,
      activeHighlightColorIndex: activeHighlightColorIndex ?? this.activeHighlightColorIndex,
      primaryHighlightColorIndex: primaryHighlightColorIndex ?? this.primaryHighlightColorIndex,
      secondaryHighlightColorIndex: secondaryHighlightColorIndex ?? this.secondaryHighlightColorIndex,
      isManualNavHidden: isManualNavHidden ?? this.isManualNavHidden,
      isRedLetterEnabled: isRedLetterEnabled ?? this.isRedLetterEnabled,
      showVerseNumbers: showVerseNumbers ?? this.showVerseNumbers,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      defaultStartTab: defaultStartTab ?? this.defaultStartTab,
      readingLayout: readingLayout ?? this.readingLayout,
      gestureSensitivity: gestureSensitivity ?? this.gestureSensitivity,
    );
  }

}

class ReadSettingsNotifier extends Notifier<ReadSettingsState> {
  static const _readingViewModeKey = 'read_settings_view_mode';
  static const _backgroundGlowStyleKey = 'read_settings_bg_glow_style';
  static const _isGlowEnabledKey = 'read_settings_is_glow_enabled';
  static const _glowIntensityKey = 'read_settings_glow_intensity';
  static const _verseActionStyleKey = 'read_settings_verse_action_style';
  static const _activeHighlightColorIndexKey = 'read_settings_active_highlight_color';
  static const _primaryHighlightColorIndexKey = 'read_settings_primary_highlight_color';
  static const _secondaryHighlightColorIndexKey = 'read_settings_secondary_highlight_color';
  static const _isManualNavHiddenKey = 'read_settings_is_manual_nav_hidden';
  static const _readingLayoutKey = 'read_settings_reading_layout';
  static const _gestureSensitivityKey = 'read_settings_gesture_sensitivity';

  @override
  ReadSettingsState build() {
    _loadSettings();
    return const ReadSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_readingViewModeKey);
    final glowString = prefs.getString(_backgroundGlowStyleKey);
    final isGlowEnabled = prefs.getBool(_isGlowEnabledKey) ?? true;
    final glowIntensity = prefs.getDouble(_glowIntensityKey) ?? 1.0;
    final verseStyleString = prefs.getString(_verseActionStyleKey);
    final activeHighlightIndex = prefs.getInt(_activeHighlightColorIndexKey);
    final primaryHighlightIndex = prefs.getInt(_primaryHighlightColorIndexKey);
    final secondaryHighlightIndex = prefs.getInt(_secondaryHighlightColorIndexKey);
    final isManualNavHidden = prefs.getBool(_isManualNavHiddenKey) ?? false;
    final isRedLetterEnabled = prefs.getBool('red_letter_enabled') ?? true;
    final showVerseNumbers = prefs.getBool('show_verse_numbers') ?? true;
    final keepScreenAwake = prefs.getBool('keep_screen_awake') ?? false;
    final defaultStartTab = prefs.getInt('default_start_tab') ?? 0;
    final layoutString = prefs.getString(_readingLayoutKey);
    final gestureString = prefs.getString(_gestureSensitivityKey);
    
    ReadingViewMode mode = ReadingViewMode.pinned;
    if (modeString != null) {
      mode = ReadingViewMode.values.firstWhere(
        (e) => e.name == modeString,
        orElse: () => ReadingViewMode.pinned,
      );
    }

    BackgroundGlowStyle glowStyle = BackgroundGlowStyle.top;
    if (glowString != null) {
      glowStyle = BackgroundGlowStyle.values.firstWhere(
        (e) => e.name == glowString,
        orElse: () => BackgroundGlowStyle.top,
      );
    }
    
    VerseActionStyle verseStyle = VerseActionStyle.horizontal;
    if (verseStyleString != null) {
      verseStyle = VerseActionStyle.values.firstWhere(
        (e) => e.name == verseStyleString,
        orElse: () => VerseActionStyle.horizontal,
      );
    }

    ReadingLayout layout = ReadingLayout.single;
    if (layoutString != null) {
      layout = ReadingLayout.values.firstWhere(
        (e) => e.name == layoutString,
        orElse: () => ReadingLayout.single,
      );
    }
    
    GestureSensitivity gesture = GestureSensitivity.fluid;
    if (gestureString != null) {
      gesture = GestureSensitivity.values.firstWhere(
        (e) => e.name == gestureString,
        orElse: () => GestureSensitivity.fluid,
      );
    }
    
    state = state.copyWith(
      readingViewMode: mode,
      backgroundGlowStyle: glowStyle,
      isGlowEnabled: isGlowEnabled,
      glowIntensity: glowIntensity,
      verseActionStyle: verseStyle,
      activeHighlightColorIndex: activeHighlightIndex ?? 2,
      primaryHighlightColorIndex: primaryHighlightIndex ?? -1,
      secondaryHighlightColorIndex: secondaryHighlightIndex ?? 1,
      isManualNavHidden: isManualNavHidden,
      isRedLetterEnabled: isRedLetterEnabled,
      showVerseNumbers: showVerseNumbers,
      keepScreenAwake: keepScreenAwake,
      defaultStartTab: defaultStartTab,
      readingLayout: layout,
      gestureSensitivity: gesture,
    );
  }

  Future<void> setReadingLayout(ReadingLayout layout) async {
    state = state.copyWith(readingLayout: layout);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingLayoutKey, layout.name);
  }

  Future<void> setReadingViewMode(ReadingViewMode mode) async {
    state = state.copyWith(readingViewMode: mode, isManualNavHidden: mode == ReadingViewMode.immersive ? false : state.isManualNavHidden);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingViewModeKey, mode.name);
    if (mode == ReadingViewMode.immersive) {
      await prefs.setBool(_isManualNavHiddenKey, false);
    }
  }

  Future<void> setBackgroundGlowStyle(BackgroundGlowStyle style) async {
    state = state.copyWith(backgroundGlowStyle: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundGlowStyleKey, style.name);
  }

  Future<void> setGlowEnabled(bool isEnabled) async {
    state = state.copyWith(isGlowEnabled: isEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGlowEnabledKey, isEnabled);
  }

  Future<void> setGlowIntensity(double intensity) async {
    state = state.copyWith(glowIntensity: intensity);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_glowIntensityKey, intensity);
  }

  Future<void> setVerseActionStyle(VerseActionStyle style) async {
    state = state.copyWith(verseActionStyle: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verseActionStyleKey, style.name);
  }

  Future<void> setActiveHighlightColorIndex(int index) async {
    state = state.copyWith(activeHighlightColorIndex: index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeHighlightColorIndexKey, index);
  }

  Future<void> setPrimaryHighlightColorIndex(int index) async {
    state = state.copyWith(primaryHighlightColorIndex: index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryHighlightColorIndexKey, index);
  }

  Future<void> setSecondaryHighlightColorIndex(int index) async {
    state = state.copyWith(secondaryHighlightColorIndex: index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_secondaryHighlightColorIndexKey, index);
  }

  Future<void> setManualNavHidden(bool isHidden) async {
    state = state.copyWith(isManualNavHidden: isHidden);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isManualNavHiddenKey, isHidden);
  }

  Future<void> setRedLetterEnabled(bool isEnabled) async {
    state = state.copyWith(isRedLetterEnabled: isEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('red_letter_enabled', isEnabled);
  }

  Future<void> setShowVerseNumbers(bool val) async {
    state = state.copyWith(showVerseNumbers: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_verse_numbers', val);
  }

  Future<void> setKeepScreenAwake(bool value) async {
    state = state.copyWith(keepScreenAwake: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_screen_awake', value);
  }

  Future<void> setDefaultStartTab(int index) async {
    state = state.copyWith(defaultStartTab: index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('default_start_tab', index);
  }

  Future<void> setGestureSensitivity(GestureSensitivity mode) async {
    state = state.copyWith(gestureSensitivity: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gestureSensitivityKey, mode.name);
  }
}

final readSettingsProvider = NotifierProvider<ReadSettingsNotifier, ReadSettingsState>(ReadSettingsNotifier.new);
