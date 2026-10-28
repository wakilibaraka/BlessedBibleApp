import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_blessed_bible/data/bible_books.dart';
import 'package:the_blessed_bible/data/localized_book_names.dart';
import 'package:the_blessed_bible/l10n/l10n.dart';

void main() {
  final languages = ['es', 'fr', 'it', 'pt', 'ro', 'sw', 'tl'];

  test('every shipped language has all 66 book names', () {
    for (final language in languages) {
      final names = kLocalizedBookNames[language];
      expect(names, isNotNull, reason: language);
      expect(names!.length, kBibleBookNames.length, reason: language);
      expect(names.where((n) => n.trim().isEmpty), isEmpty, reason: language);
      expect(names.toSet().length, names.length,
          reason: '$language duplicates');
    }
  });

  test('every language covers exactly the languages the app supports', () {
    final supported = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .where((code) => code != 'en')
        .toSet();
    expect(kLocalizedBookNames.keys.toSet(), supported);
  });

  test('book names are translated per language', () {
    expect(localizedBookName('Genesis', 'fr'), 'Genèse');
    expect(localizedBookName('Psalms', 'fr'), 'Psaumes');
    expect(localizedBookName('Revelation', 'it'), 'Apocalisse');
    expect(localizedBookName('1 John', 'ro'), '1 Ioan');
    expect(localizedBookName('Genesis', 'sw'), 'Mwanzo');
    expect(localizedBookName('Matthew', 'sw'), 'Mathayo');
    expect(localizedBookName('Psalms', 'tl'), 'Mga Awit');
    expect(localizedBookName('Genesis', 'es'), 'Génesis');
    expect(localizedBookName('Revelation', 'pt'), 'Apocalipse');
    expect(localizedReference('1 John 3:16', 'pt'), '1 João 3:16');
  });

  test('unknown languages and non-book names fall back to the input', () {
    expect(localizedBookName('Genesis', 'en'), 'Genesis');
    expect(localizedBookName('Genesis', 'de'), 'Genesis');
    expect(localizedBookName('Bible', 'sw'), 'Bible');
    expect(localizedReference('Bible 1:1', 'sw'), 'Bible 1:1');
  });

  test('references localize only their leading book name', () {
    expect(localizedReference('1 John 3:16', 'fr'), '1 Jean 3:16');
    expect(localizedReference('Genesis 1–2', 'fr'), 'Genèse 1–2');
    expect(localizedReference('Daniel 11:27', 'sw'), 'Danieli 11:27');
    expect(localizedReference('Psalms 23', 'tl'), 'Mga Awit 23');
    expect(localizedReference('Genesis 1 · Psalms 23', 'fr'),
        'Genèse 1 · Psalms 23');
    expect(localizedReference('Psalms', 'fr'), 'Psaumes');
  });

  testWidgets('the helper follows the app locale', (tester) async {
    late String name;
    late String reference;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('sw'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(builder: (context) {
        name = context.bookNameInLocale('Genesis');
        reference = context.referenceInLocale('Genesis 1:1');
        return const SizedBox();
      }),
    ));
    expect(name, 'Mwanzo');
    expect(reference, 'Mwanzo 1:1');
  });
}
