import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';

/// Selected UI language.
///
/// `null` (the default) means **follow the system language**. An explicit
/// code (`'sw'`, `'fr'`, …) pins the app to that language. Persisted.
class LocaleNotifier extends Notifier<String?> {
  static const _key = 'app_locale';

  @override
  String? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && AppL10n.isSupported(saved)) {
      state = saved;
      AppL10n.localeCode = saved;
    }
  }

  /// Picks an explicit language, or `null` to follow the system.
  Future<void> setLocale(String? code) async {
    final resolved = code == null ? null : AppL10n.resolve(code);
    state = resolved;
    AppL10n.localeCode = resolved ??
        AppL10n.resolve(
            WidgetsBinding.instance.platformDispatcher.locale.languageCode);
    final prefs = await SharedPreferences.getInstance();
    if (resolved == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, resolved);
    }
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, String?>(LocaleNotifier.new);
