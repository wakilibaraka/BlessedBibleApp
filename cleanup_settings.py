import sys
import re

def process_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    for old, new in replacements:
        if old in content:
            content = content.replace(old, new)
        else:
            # We will ignore errors for now and just replace what we can find.
            pass
    with open(filepath, 'w') as f:
        f.write(content)

# 1. Search Settings Provider
search_replacements = [
    ("  final bool useClassicSearch;\n", ""),
    ("    this.useClassicSearch = false,\n", ""),
    ("    bool? useClassicSearch,\n", ""),
    ("      useClassicSearch: useClassicSearch ?? this.useClassicSearch,\n", ""),
    ("  static const _useClassicSearchKey = 'search_use_classic_search';\n", ""),
    ("    final classic = prefs.getBool(_useClassicSearchKey) ?? false;\n", ""),
    ("      useClassicSearch: classic,\n", ""),
    ("  Future<void> setUseClassicSearch(bool value) async {\n    state = state.copyWith(\n      useClassicSearch: value,\n    );\n    final prefs = await SharedPreferences.getInstance();\n    await prefs.setBool(_useClassicSearchKey, value);\n  }\n", "")
]
process_file('lib/state/search_settings_provider.dart', search_replacements)

# 2. Bible Nav Settings Provider
nav_replacements = [
    ("enum TestamentLayout { sideBySide, stickySections, filterTabs }\n\n", ""),
    ("  final TestamentLayout layout;\n", ""),
    ("  final bool fullScreenNavigationVersePicker;\n", ""),
    ("    this.layout = TestamentLayout.sideBySide,\n", ""),
    ("    this.fullScreenNavigationVersePicker = false,\n", ""),
    ("    TestamentLayout? layout,\n", ""),
    ("    bool? fullScreenNavigationVersePicker,\n", ""),
    ("      layout: layout ?? this.layout,\n", ""),
    ("      fullScreenNavigationVersePicker: fullScreenNavigationVersePicker ?? this.fullScreenNavigationVersePicker,\n", ""),
    ("  static const _layoutKey = 'bible_nav_layout';\n", ""),
    ("  static const _fullScreenPickerKey = 'bible_nav_full_screen_picker';\n", ""),
    ("    final layoutIndex = prefs.getInt(_layoutKey) ?? TestamentLayout.sideBySide.index;\n", ""),
    ("    final fullScreenPicker = prefs.getBool(_fullScreenPickerKey) ?? false;\n", ""),
    ("      layout: TestamentLayout.values[layoutIndex.clamp(0, TestamentLayout.values.length - 1)],\n", ""),
    ("      fullScreenNavigationVersePicker: fullScreenPicker,\n", ""),
    ("  Future<void> setLayout(TestamentLayout layout) async {\n    state = state.copyWith(layout: layout);\n    final prefs = await SharedPreferences.getInstance();\n    await prefs.setInt(_layoutKey, layout.index);\n  }\n", ""),
    ("  Future<void> setFullScreenPicker(bool fullScreen) async {\n    state = state.copyWith(fullScreenNavigationVersePicker: fullScreen);\n    final prefs = await SharedPreferences.getInstance();\n    await prefs.setBool(_fullScreenPickerKey, fullScreen);\n  }\n", "")
]
process_file('lib/state/bible_nav_settings_provider.dart', nav_replacements)

print('Providers cleaned up.')
