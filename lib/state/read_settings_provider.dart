import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingViewMode { immersive, pinned }

class ReadSettingsState {
  final ReadingViewMode readingViewMode;

  const ReadSettingsState({
    this.readingViewMode = ReadingViewMode.immersive,
  });

  ReadSettingsState copyWith({
    ReadingViewMode? readingViewMode,
  }) {
    return ReadSettingsState(
      readingViewMode: readingViewMode ?? this.readingViewMode,
    );
  }
}

class ReadSettingsNotifier extends Notifier<ReadSettingsState> {
  static const _readingViewModeKey = 'read_settings_view_mode';

  @override
  ReadSettingsState build() {
    _loadSettings();
    return const ReadSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_readingViewModeKey);
    
    if (modeString != null) {
      final mode = ReadingViewMode.values.firstWhere(
        (e) => e.name == modeString,
        orElse: () => ReadingViewMode.immersive,
      );
      state = state.copyWith(readingViewMode: mode);
    }
  }

  Future<void> setReadingViewMode(ReadingViewMode mode) async {
    state = state.copyWith(readingViewMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingViewModeKey, mode.name);
  }
}

final readSettingsProvider = NotifierProvider<ReadSettingsNotifier, ReadSettingsState>(ReadSettingsNotifier.new);
