import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingViewMode { immersive, pinned }
enum BackgroundGlowStyle { top, full }
enum VerseActionStyle { classic, detached, horizontal, raindrop }

class ReadSettingsState {
  final ReadingViewMode readingViewMode;
  final BackgroundGlowStyle backgroundGlowStyle;
  final VerseActionStyle verseActionStyle;
  final int activeHighlightColorIndex;
  final bool isManualNavHidden;

  const ReadSettingsState({
    this.readingViewMode = ReadingViewMode.immersive,
    this.backgroundGlowStyle = BackgroundGlowStyle.top,
    this.verseActionStyle = VerseActionStyle.classic,
    this.activeHighlightColorIndex = 2,
    this.isManualNavHidden = false,
  });

  ReadSettingsState copyWith({
    ReadingViewMode? readingViewMode,
    BackgroundGlowStyle? backgroundGlowStyle,
    VerseActionStyle? verseActionStyle,
    int? activeHighlightColorIndex,
    bool? isManualNavHidden,
  }) {
    return ReadSettingsState(
      readingViewMode: readingViewMode ?? this.readingViewMode,
      backgroundGlowStyle: backgroundGlowStyle ?? this.backgroundGlowStyle,
      verseActionStyle: verseActionStyle ?? this.verseActionStyle,
      activeHighlightColorIndex: activeHighlightColorIndex ?? this.activeHighlightColorIndex,
      isManualNavHidden: isManualNavHidden ?? this.isManualNavHidden,
    );
  }
}

class ReadSettingsNotifier extends Notifier<ReadSettingsState> {
  static const _readingViewModeKey = 'read_settings_view_mode';
  static const _backgroundGlowStyleKey = 'read_settings_bg_glow_style';
  static const _verseActionStyleKey = 'read_settings_verse_action_style';
  static const _activeHighlightColorIndexKey = 'read_settings_active_highlight_color';
  static const _isManualNavHiddenKey = 'read_settings_is_manual_nav_hidden';

  @override
  ReadSettingsState build() {
    _loadSettings();
    return const ReadSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_readingViewModeKey);
    final glowString = prefs.getString(_backgroundGlowStyleKey);
    final verseStyleString = prefs.getString(_verseActionStyleKey);
    final activeHighlightIndex = prefs.getInt(_activeHighlightColorIndexKey);
    final isManualNavHidden = prefs.getBool(_isManualNavHiddenKey) ?? false;
    
    ReadingViewMode mode = ReadingViewMode.immersive;
    if (modeString != null) {
      mode = ReadingViewMode.values.firstWhere(
        (e) => e.name == modeString,
        orElse: () => ReadingViewMode.immersive,
      );
    }

    BackgroundGlowStyle glowStyle = BackgroundGlowStyle.top;
    if (glowString != null) {
      glowStyle = BackgroundGlowStyle.values.firstWhere(
        (e) => e.name == glowString,
        orElse: () => BackgroundGlowStyle.top,
      );
    }
    
    VerseActionStyle verseStyle = VerseActionStyle.classic;
    if (verseStyleString != null) {
      verseStyle = VerseActionStyle.values.firstWhere(
        (e) => e.name == verseStyleString,
        orElse: () => VerseActionStyle.classic,
      );
    }
    
    int activeColor = activeHighlightIndex ?? 3;

    state = state.copyWith(
      readingViewMode: mode,
      backgroundGlowStyle: glowStyle,
      verseActionStyle: verseStyle,
      activeHighlightColorIndex: activeColor,
      isManualNavHidden: isManualNavHidden,
    );
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

  Future<void> setManualNavHidden(bool isHidden) async {
    state = state.copyWith(isManualNavHidden: isHidden);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isManualNavHiddenKey, isHidden);
  }
}

final readSettingsProvider = NotifierProvider<ReadSettingsNotifier, ReadSettingsState>(ReadSettingsNotifier.new);
