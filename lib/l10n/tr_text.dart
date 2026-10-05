import 'package:flutter/widgets.dart';

import 'l10n.dart';

/// A [Text] that translates its string at build time.
///
/// Drop-in replacement for `Text` whose constructor stays `const`, so
/// `const Text('Continue')` becomes `const TrText('Continue')` without
/// breaking any const context. The string is the **English source text**
/// and doubles as the translation key — unknown keys fall back to English.
///
/// The locale is read through [Localizations], so the widget rebuilds
/// automatically when the user switches language.
class TrText extends StatelessWidget {
  const TrText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.args,
  });

  /// English source text, used as the translation key.
  final String data;

  /// Optional positional substitutions for `{0}`, `{1}`, … placeholders.
  final List<Object?>? args;

  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final String? semanticsIdentifier;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final code = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    return Text(
      AppL10n.translate(code, data, args ?? const []),
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
