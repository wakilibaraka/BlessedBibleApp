import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension L10nContext on BuildContext {
  /// The interface strings for the current language.
  ///
  /// Falls back to English where no localizations are installed (widget
  /// tests that build a bare `MaterialApp`), rather than throwing.
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(const Locale('en'));
}
