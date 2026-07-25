import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingViewMode { immersive, pinned }
enum BackgroundGlowStyle { top, full }

class ReadSettingsState {
  final ReadingViewMode readingViewMode;
  final BackgroundGlowStyle backgroundGlowStyle;

  const ReadSettingsState({
    this.readingViewMode = ReadingViewMode.immersive,
    this.backgroundGlowStyle = BackgroundGlowStyle.top,
  });

  ReadSettingsState copyWith({
    ReadingViewMode? readingViewMode,
    BackgroundGlowStyle? backgroundGlowStyle,
  }) {
    return ReadSettingsState(
      readingViewMode: readingViewMode ?? this.readingViewMode,
      backgroundGlowStyle: backgroundGlowStyle ?? this.backgroundGlowStyle,
    );
  }
}

class ReadSettingsNotifier extends Notifier<ReadSettingsState> {
  static const _readingViewModeKey = 'read_settings_view_mode';
  static const _backgroundGlowStyleKey = 'read_settings_bg_glow_style';

  @override
  ReadSettingsState build() {
    _loadSettings();
    return const ReadSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_readingViewModeKey);
    final glowString = prefs.getString(_backgroundGlowStyleKey);
    
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
    
    state = state.copyWith(readingViewMode: mode, backgroundGlowStyle: glowStyle);
  }

  Future<void> setReadingViewMode(ReadingViewMode mode) async {
    state = state.copyWith(readingViewMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingViewModeKey, mode.name);
  }

  Future<void> setBackgroundGlowStyle(BackgroundGlowStyle style) async {
    state = state.copyWith(backgroundGlowStyle: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundGlowStyleKey, style.name);
  }
}

final readSettingsProvider = NotifierProvider<ReadSettingsNotifier, ReadSettingsState>(ReadSettingsNotifier.new);
