import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_storage/preferences_service.dart';

/// A language the app's interface is translated into.
class AppLanguage {
  const AppLanguage(this.code, this.nativeName, this.bibleId);

  /// Locale language code, as used by the ARB files.
  final String code;

  /// The language's name in that language, shown in pickers so people can
  /// always find their own language whatever the app is currently set to.
  final String nativeName;

  /// The bundled Bible that matches this language.
  final String bibleId;
}

const List<AppLanguage> appLanguages = [
  AppLanguage('en', 'English', 'kjv'),
  AppLanguage('fr', 'Français', 'fra_lsg'),
  AppLanguage('it', 'Italiano', 'ita_dio'),
  AppLanguage('ro', 'Română', 'ron_btf'),
  AppLanguage('sw', 'Kiswahili', 'swh_ulb'),
  AppLanguage('tl', 'Tagalog', 'tgl_ulb'),
];

AppLanguage? appLanguageFor(String code) {
  // Android reports Filipino as `fil`; Tagalog is what we ship.
  final normalized = code == 'fil' ? 'tl' : code;
  for (final l in appLanguages) {
    if (l.code == normalized) return l;
  }
  return null;
}

/// The device language if we support it, otherwise English.
AppLanguage deviceLanguage() {
  for (final locale in PlatformDispatcher.instance.locales) {
    final match = appLanguageFor(locale.languageCode);
    if (match != null) return match;
  }
  return appLanguages.first;
}

/// The interface language. `null` follows the device.
class AppLocaleNotifier extends Notifier<Locale?> {
  static const String key = 'app_locale';

  @override
  Locale? build() {
    final code = ref.watch(preferencesProvider).prefs.getString(key);
    final lang = code == null ? null : appLanguageFor(code);
    return lang == null ? null : Locale(lang.code);
  }

  Future<void> setLanguage(String? code) async {
    final prefs = ref.read(preferencesProvider).prefs;
    if (code == null) {
      await prefs.remove(key);
      state = null;
    } else {
      await prefs.setString(key, code);
      state = Locale(code);
    }
  }
}

final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale?>(AppLocaleNotifier.new);

/// Resolves the device locale list to one we ship, mapping Filipino to
/// Tagalog, so "follow the device" works for every supported language.
Locale resolveAppLocale(List<Locale>? deviceLocales, Iterable<Locale> _) {
  for (final locale in deviceLocales ?? const <Locale>[]) {
    final match = appLanguageFor(locale.languageCode);
    if (match != null) return Locale(match.code);
  }
  return const Locale('en');
}
