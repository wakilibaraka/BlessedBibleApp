import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingViewMode { full, partial, pinned }


enum VerseActionStyle { classic, detached, horizontal, raindrop }

enum ReadingLayout { single, interleaved, sideBySide, chips }

enum SelectorHeight { quarter, half, full }

enum DictionaryScope { term, termAndTricky, everything }

enum StrongsIndicatorStyle { asterisk, chain, number }

enum PopupStyle { bottomSheet, floating }

class ReadSettingsState {
  final ReadingViewMode readingViewMode;
  final bool isGlowEnabled;
  final VerseActionStyle verseActionStyle;
  final int activeHighlightColorIndex;
  final bool isManualNavHidden;
  final bool isRedLetterEnabled;
  final bool showVerseNumbers;
  final bool keepScreenAwake;
  final int defaultStartTab; // 0=Home, 1=Read, 2=Search, 3=Study
  final ReadingLayout readingLayout;
  final bool fabLongPressToNav;
  final SelectorHeight selectorHeight;
  final bool syncSavedItemsLanguage;
  final bool showChipsOnSavedItems;
  final bool dictionaryUnderlinesEnabled;
  final DictionaryScope dictionaryScope;
  final bool showCrossReferences;
  final bool showStrongsNumbers;
  final StrongsIndicatorStyle strongsIndicatorStyle;
  final PopupStyle popupStyle;

  const ReadSettingsState({
    this.readingViewMode = ReadingViewMode.pinned,
    this.isGlowEnabled = true,
    this.verseActionStyle = VerseActionStyle.horizontal,
    this.activeHighlightColorIndex = 2,
    this.isManualNavHidden = false,
    this.isRedLetterEnabled = true,
    this.showVerseNumbers = true,
    this.keepScreenAwake = false,
    this.defaultStartTab = 0,
    this.readingLayout = ReadingLayout.single,
    this.fabLongPressToNav = true,
    // Note: SelectorHeight.half currently maps to initialChildSize 0.75 (labeled "3/4" in UI)
    // Quarter maps to 0.5 ("Half") and Full maps to 1.0. 
    this.selectorHeight = SelectorHeight.half,
    this.syncSavedItemsLanguage = true,
    this.showChipsOnSavedItems = false,
    this.dictionaryUnderlinesEnabled = true,
    this.dictionaryScope = DictionaryScope.termAndTricky,
    this.showCrossReferences = false,
    this.showStrongsNumbers = false,
    this.strongsIndicatorStyle = StrongsIndicatorStyle.asterisk,
    this.popupStyle = PopupStyle.floating,
  });

  ReadSettingsState copyWith({
    ReadingViewMode? readingViewMode,
    bool? isGlowEnabled,
    VerseActionStyle? verseActionStyle,
    int? activeHighlightColorIndex,
    bool? isManualNavHidden,
    bool? isRedLetterEnabled,
    bool? showVerseNumbers,
    bool? keepScreenAwake,
    int? defaultStartTab,
    ReadingLayout? readingLayout,
    bool? fabLongPressToNav,
    SelectorHeight? selectorHeight,
    bool? syncSavedItemsLanguage,
    bool? showChipsOnSavedItems,
    bool? dictionaryUnderlinesEnabled,
    DictionaryScope? dictionaryScope,
    bool? showCrossReferences,
    bool? showStrongsNumbers,
    StrongsIndicatorStyle? strongsIndicatorStyle,
    PopupStyle? popupStyle,
  }) {
    return ReadSettingsState(
      readingViewMode: readingViewMode ?? this.readingViewMode,
      isGlowEnabled: isGlowEnabled ?? this.isGlowEnabled,
      verseActionStyle: verseActionStyle ?? this.verseActionStyle,
      activeHighlightColorIndex:
          activeHighlightColorIndex ?? this.activeHighlightColorIndex,
      isManualNavHidden: isManualNavHidden ?? this.isManualNavHidden,
      isRedLetterEnabled: isRedLetterEnabled ?? this.isRedLetterEnabled,
      showVerseNumbers: showVerseNumbers ?? this.showVerseNumbers,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      defaultStartTab: defaultStartTab ?? this.defaultStartTab,
      readingLayout: readingLayout ?? this.readingLayout,
      fabLongPressToNav: fabLongPressToNav ?? this.fabLongPressToNav,
      selectorHeight: selectorHeight ?? this.selectorHeight,
      syncSavedItemsLanguage: syncSavedItemsLanguage ?? this.syncSavedItemsLanguage,
      showChipsOnSavedItems: showChipsOnSavedItems ?? this.showChipsOnSavedItems,
      dictionaryUnderlinesEnabled: dictionaryUnderlinesEnabled ?? this.dictionaryUnderlinesEnabled,
      dictionaryScope: dictionaryScope ?? this.dictionaryScope,
      showCrossReferences: showCrossReferences ?? this.showCrossReferences,
      showStrongsNumbers: showStrongsNumbers ?? this.showStrongsNumbers,
      strongsIndicatorStyle: strongsIndicatorStyle ?? this.strongsIndicatorStyle,
      popupStyle: popupStyle ?? this.popupStyle,
    );
  }
}

class ReadSettingsNotifier extends Notifier<ReadSettingsState> {
  static const _readingViewModeKey = 'read_settings_view_mode';
  static const _isGlowEnabledKey = 'read_settings_is_glow_enabled';
  static const _verseActionStyleKey = 'read_settings_verse_action_style';
  static const _activeHighlightColorIndexKey =
      'read_settings_active_highlight_color';
  static const _isManualNavHiddenKey = 'read_settings_is_manual_nav_hidden';
  static const _readingLayoutKey = 'read_settings_reading_layout';
  static const _selectorHeightKey = 'read_settings_selector_height';

  @override
  ReadSettingsState build() {
    _loadSettings();
    return const ReadSettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_readingViewModeKey);
    final isGlowEnabled = prefs.getBool(_isGlowEnabledKey) ?? true;
    final verseStyleString = prefs.getString(_verseActionStyleKey);
    final activeHighlightIndex = prefs.getInt(_activeHighlightColorIndexKey);
    final isManualNavHidden = prefs.getBool(_isManualNavHiddenKey) ?? false;
    final isRedLetterEnabled = prefs.getBool('red_letter_enabled') ?? true;
    final showVerseNumbers = prefs.getBool('show_verse_numbers') ?? true;
    final keepScreenAwake = prefs.getBool('keep_screen_awake') ?? false;
    final defaultStartTab = prefs.getInt('default_start_tab') ?? 0;
    final layoutString = prefs.getString(_readingLayoutKey);
    final fabLongPressToNav = prefs.getBool('fab_long_press_to_nav') ?? true;
    final selectorHeightString = prefs.getString(_selectorHeightKey);
    final syncSavedItemsLanguage = prefs.getBool('sync_saved_items_language') ?? true;
    final showChipsOnSavedItems = prefs.getBool('show_chips_on_saved_items') ?? false;
    final dictionaryUnderlinesEnabled = prefs.getBool('dictionaryUnderlinesEnabled') ?? true;
    final dictScopeString = prefs.getString('dictionaryScope');
    final showCrossReferences = prefs.getBool('show_cross_references') ?? false;
    final showStrongsNumbers = prefs.getBool('show_strongs_numbers') ?? false;
    DictionaryScope dictScope = DictionaryScope.termAndTricky;
    if (dictScopeString != null) {
      dictScope = DictionaryScope.values.firstWhere(
        (e) => e.name == dictScopeString,
        orElse: () => DictionaryScope.termAndTricky,
      );
    }

    ReadingViewMode mode = ReadingViewMode.pinned;
    if (modeString != null) {
      mode = ReadingViewMode.values.firstWhere(
        (e) => e.name == modeString,
        orElse: () => ReadingViewMode.pinned,
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

    // Default to 'half', which maps to 0.75 (3/4) height in the UI
    SelectorHeight selectorHeight = SelectorHeight.half;
    if (selectorHeightString != null) {
      selectorHeight = SelectorHeight.values.firstWhere(
        (e) => e.name == selectorHeightString,
        orElse: () => SelectorHeight.half,
      );
    }

    final strongsStyleString = prefs.getString('strongs_indicator_style');
    StrongsIndicatorStyle strongsStyle = StrongsIndicatorStyle.asterisk;
    if (strongsStyleString != null) {
      strongsStyle = StrongsIndicatorStyle.values.firstWhere(
        (e) => e.name == strongsStyleString,
        orElse: () => StrongsIndicatorStyle.asterisk,
      );
    }

    final popupStyleString = prefs.getString('popup_style');
    PopupStyle popupStyle = PopupStyle.floating;
    if (popupStyleString != null) {
      popupStyle = PopupStyle.values.firstWhere(
        (e) => e.name == popupStyleString,
        orElse: () => PopupStyle.floating,
      );
    }

    state = state.copyWith(
      readingViewMode: mode,
      isGlowEnabled: isGlowEnabled,
      verseActionStyle: verseStyle,
      activeHighlightColorIndex: activeHighlightIndex ?? 2,
      isManualNavHidden: isManualNavHidden,
      isRedLetterEnabled: isRedLetterEnabled,
      showVerseNumbers: showVerseNumbers,
      keepScreenAwake: keepScreenAwake,
      defaultStartTab: defaultStartTab,
      readingLayout: layout,
      fabLongPressToNav: fabLongPressToNav,
      selectorHeight: selectorHeight,
      syncSavedItemsLanguage: syncSavedItemsLanguage,
      showChipsOnSavedItems: showChipsOnSavedItems,
      dictionaryUnderlinesEnabled: dictionaryUnderlinesEnabled,
      dictionaryScope: dictScope,
      showCrossReferences: showCrossReferences,
      showStrongsNumbers: showStrongsNumbers,
      strongsIndicatorStyle: strongsStyle,
      popupStyle: popupStyle,
    );
  }

  Future<void> setPopupStyle(PopupStyle style) async {
    state = state.copyWith(popupStyle: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('popup_style', style.name);
  }

  Future<void> setFabLongPressToNav(bool value) async {
    state = state.copyWith(fabLongPressToNav: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fab_long_press_to_nav', value);
  }

  Future<void> setReadingLayout(ReadingLayout layout) async {
    state = state.copyWith(readingLayout: layout);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingLayoutKey, layout.name);
  }

  Future<void> setReadingViewMode(ReadingViewMode mode) async {
    state = state.copyWith(
        readingViewMode: mode,
        isManualNavHidden: mode == ReadingViewMode.full || mode == ReadingViewMode.partial
            ? false
            : state.isManualNavHidden);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readingViewModeKey, mode.name);
    if (mode == ReadingViewMode.full || mode == ReadingViewMode.partial) {
      await prefs.setBool(_isManualNavHiddenKey, false);
    }
  }


  Future<void> setGlowEnabled(bool isEnabled) async {
    state = state.copyWith(isGlowEnabled: isEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGlowEnabledKey, isEnabled);
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

  Future<void> setSelectorHeight(SelectorHeight height) async {
    state = state.copyWith(selectorHeight: height);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectorHeightKey, height.name);
  }

  Future<void> setSyncSavedItemsLanguage(bool value) async {
    state = state.copyWith(syncSavedItemsLanguage: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sync_saved_items_language', value);
  }


  Future<void> setDictionaryUnderlinesEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dictionaryUnderlinesEnabled', value);
    state = state.copyWith(dictionaryUnderlinesEnabled: value);
  }

  Future<void> setDictionaryScope(DictionaryScope scope) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dictionaryScope', scope.name);
    state = state.copyWith(dictionaryScope: scope);
  }

  Future<void> setShowChipsOnSavedItems(bool value) async {
    state = state.copyWith(showChipsOnSavedItems: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_chips_on_saved_items', value);
  }

  Future<void> setShowCrossReferences(bool value) async {
    state = state.copyWith(showCrossReferences: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_cross_references', value);
  }

  Future<void> setStrongsIndicatorStyle(StrongsIndicatorStyle style) async {
    state = state.copyWith(strongsIndicatorStyle: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('strongs_indicator_style', style.name);
  }

  Future<void> setShowStrongsNumbers(bool value) async {
    state = state.copyWith(showStrongsNumbers: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_strongs_numbers', value);
  }
}

final readSettingsProvider =
    NotifierProvider<ReadSettingsNotifier, ReadSettingsState>(
        ReadSettingsNotifier.new);
