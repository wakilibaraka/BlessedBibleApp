import 'package:flutter/widgets.dart';

import 'translations.dart';

/// UI languages enabled in the app by default.
///
/// English is the source language: every translation key IS the English
/// string, so anything not yet translated falls back to English
/// automatically (never a missing/blank string).
const List<Locale> kSupportedLocales = <Locale>[
  Locale('en'),
  Locale('sw'),
  Locale('tl'),
  Locale('ro'),
  Locale('it'),
  Locale('fr'),
  Locale('es'),
  Locale('pt'),
];

/// Language names shown in the picker, in each language's own spelling.
const Map<String, String> kLanguageNames = <String, String>{
  'en': 'English',
  'sw': 'Kiswahili',
  'tl': 'Tagalog',
  'ro': 'Română',
  'it': 'Italiano',
  'fr': 'Français',
  'es': 'Español',
  'pt': 'Português',
};

/// Core lookup. Works with or without a [BuildContext] (notifications,
/// services and other non-widget code use the global [AppL10n.localeCode]).
class AppL10n {
  AppL10n._();

  /// Language code used by code that has no BuildContext.
  /// Kept in sync with the locale the widget tree resolves to.
  static String localeCode = 'en';

  static bool isSupported(String code) =>
      kSupportedLocales.any((l) => l.languageCode == code);

  /// Resolves the best supported locale for [deviceLanguageCode],
  /// falling back to English when the device language isn't supported.
  static String resolve(String? deviceLanguageCode) {
    if (deviceLanguageCode == null) return 'en';
    return isSupported(deviceLanguageCode) ? deviceLanguageCode : 'en';
  }

  /// Translates [key] into [code].
  ///
  /// `{0}`, `{1}`, … placeholders are replaced from [args] (positional).
  /// Unknown keys return [key] itself — the English source text.
  static String translate(String code, String key, [List<Object?> args = const []]) {
    if (key.isEmpty) return key;
    var out = kTranslations[code]?[key] ?? key;
    if (args.isNotEmpty) out = _format(out, args);
    return out;
  }

  static String _format(String template, List<Object?> args) {
    var out = template;
    for (var i = 0; i < args.length; i++) {
      out = out.replaceAll('{$i}', '${args[i]}');
    }
    return out;
  }
}

/// Global lookup for code without a BuildContext (notifications, services).
String tr(String key, [List<Object?> args = const []]) =>
    AppL10n.translate(AppL10n.localeCode, key, args);

extension L10nContext on BuildContext {
  /// Translates [key] for the locale the widget tree is currently showing.
  ///
  /// Reads the locale through [Localizations] so widgets that call this in
  /// [Widget.build] rebuild automatically when the language changes.
  String tr(String key, [List<Object?> args = const []]) {
    final code = Localizations.maybeLocaleOf(this)?.languageCode ?? 'en';
    return AppL10n.translate(code, key, args);
  }
}
