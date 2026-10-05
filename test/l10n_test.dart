// Multilanguage support: locale resolution, translation lookup with English
// fallback, positional placeholders, TrText rendering, and the persisted
// Settings override.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/l10n/l10n.dart';
import 'package:the_blessed_bible/l10n/tr_text.dart';
import 'package:the_blessed_bible/l10n/translations.dart';
import 'package:the_blessed_bible/state/locale_provider.dart';

/// Mirrors the app shell: MaterialApp wired to the chosen locale.
Widget harness(String? code) {
  return MaterialApp(
    locale: code == null ? null : Locale(code),
    supportedLocales: kSupportedLocales,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const Scaffold(body: TrText('Continue')),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppL10n.localeCode = 'en';
  });

  test('every bundled language is supported and self-named', () {
    expect(kSupportedLocales.length, 8);
    for (final code in ['en', 'sw', 'tl', 'ro', 'it', 'fr', 'es', 'pt']) {
      expect(AppL10n.isSupported(code), isTrue, reason: code);
      expect(kLanguageNames[code], isNotNull, reason: code);
    }
    expect(kLanguageNames['sw'], 'Kiswahili');
    expect(kLanguageNames['ro'], 'Română');
    expect(kLanguageNames['es'], 'Español');
    expect(kLanguageNames['pt'], 'Português');
  });

  test('unsupported device language resolves to English', () {
    expect(AppL10n.resolve('sw'), 'sw');
    expect(AppL10n.resolve('de'), 'en');
    expect(AppL10n.resolve(null), 'en');
  });

  test('each shipped table translates real UI strings', () {
    for (final code in ['sw', 'tl', 'ro', 'it', 'fr', 'es', 'pt']) {
      final table = kTranslations[code];
      expect(table, isNotNull, reason: code);
      expect(table!.length, greaterThan(700),
          reason: '$code coverage: ${table.length} keys');
      final value = table['Continue'];
      expect(value, isNotNull, reason: code);
      expect(value, isNot('Continue'), reason: '$code must translate Continue');
    }
  });

  test('unknown keys fall back to the English source text', () {
    for (final code in ['en', 'sw', 'fr', 'pt']) {
      expect(AppL10n.translate(code, 'Totally untranslated key'),
          'Totally untranslated key');
      expect(AppL10n.translate(code, ''), '');
    }
  });

  test('positional placeholders are substituted in every language', () {
    expect(AppL10n.translate('en', 'Day {0} of {1}', ['3', '21']),
        'Day 3 of 21');
    expect(AppL10n.translate('es', 'Chapter {0}', ['7']), 'Capítulo 7');
    expect(AppL10n.translate('fr', 'Chapter {0}', ['7']), 'Chapitre 7');
    expect(AppL10n.translate('sw', 'Day {0} of {1}', ['3', '21']),
        'Siku 3 kati ya 21');
  });

  testWidgets('TrText renders the locale the app is showing',
      (tester) async {
    await tester.pumpWidget(harness('es'));
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    // Switching the app locale rebuilds the same tree in the new language.
    await tester.pumpWidget(harness('fr'));
    await tester.pumpAndSettle();
    expect(find.text('Continuer'), findsOneWidget);

    await tester.pumpWidget(harness(null)); // system locale (en in tests)
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('context.tr reads the active locale and formats args',
      (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        supportedLocales: kSupportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        }),
      ),
    );
    expect(captured.tr('Read'), 'Ler');
    expect(captured.tr('Chapter {0}', ['7']), 'Capítulo 7');
  });

  testWidgets('a language picked in Settings is persisted and reused',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Default: follow the system (null).
    expect(container.read(localeProvider), isNull);

    await container.read(localeProvider.notifier).setLocale('sw');
    expect(container.read(localeProvider), 'sw');
    expect(AppL10n.localeCode, 'sw');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'sw');

    // A fresh container (next app launch) restores the saved language.
    final relaunched = ProviderContainer();
    addTearDown(relaunched.dispose);
    for (var i = 0; i < 10 && relaunched.read(localeProvider) == null; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(relaunched.read(localeProvider), 'sw');

    // Back to the system default clears the stored value.
    await relaunched.read(localeProvider.notifier).setLocale(null);
    expect(relaunched.read(localeProvider), isNull);
    expect((await SharedPreferences.getInstance()).getString('app_locale'),
        isNull);
  });
}
