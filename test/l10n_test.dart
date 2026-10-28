import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_blessed_bible/l10n/l10n.dart';

void main() {
  test('no hard-coded English UI strings in lib/ui', () {
    // Text widgets, tooltips and hints should read from context.l10n.
    // Matches across line breaks and either quote style.
    final pattern = RegExp(
        r"""Text\(\s*['"][A-Za-z][a-z]{2,}|tooltip: ['"][A-Z]|label: (const )?Text\(['"][A-Z]|hintText: ['"][A-Z]""");
    final offenders = <String>[];
    for (final file in Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final src = file.readAsStringSync();
      for (final m in pattern.allMatches(src)) {
        final line = '\n'.allMatches(src.substring(0, m.start)).length + 1;
        offenders.add('${file.path}:$line: ${m.group(0)}');
      }
    }
    expect(offenders, isEmpty,
        reason: 'Move these strings to tool/l10n/parts/*.json');
  });

  test('every language has every string with the same placeholders', () {
    Map<String, dynamic> load(String lang) =>
        jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
            as Map<String, dynamic>;
    final en = load('en');
    final keys = en.keys.where((k) => !k.startsWith('@')).toSet();
    final placeholder = RegExp(r'\{(\w+)[,}]');
    for (final lang in ['es', 'fr', 'it', 'pt', 'ro', 'sw', 'tl']) {
      final other = load(lang);
      expect(other.keys.where((k) => !k.startsWith('@')).toSet(), keys,
          reason: lang);
      for (final key in keys) {
        Set<String> names(Object? s) =>
            placeholder.allMatches(s as String).map((m) => m[1]!).toSet()
              ..removeAll(['plural', 'select', 'other', 'one', 'few', 'many']);
        expect(names(other[key]), names(en[key]), reason: '$lang $key');
      }
    }
  });

  test('story position line is translated in every language', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.storiesPosition(3, 12, 'Daniel'), '3 of 12 in Daniel');
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == 'en') continue;
      final label =
          lookupAppLocalizations(locale).storiesPosition(3, 12, 'Daniel');
      expect(label, contains('3'), reason: locale.languageCode);
      expect(label, contains('12'), reason: locale.languageCode);
      expect(label, contains('Daniel'), reason: locale.languageCode);
      expect(label, isNot(en.storiesPosition(3, 12, 'Daniel')),
          reason: locale.languageCode);
    }
  });

  test('reader end-of-chapter label is translated in every language', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.readEndOfChapter('Genesis 1'), '· End of Genesis 1 ·');
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == 'en') continue;
      final label =
          lookupAppLocalizations(locale).readEndOfChapter('Genesis 1');
      expect(label, contains('Genesis 1'), reason: locale.languageCode);
      expect(label, isNot(en.readEndOfChapter('Genesis 1')),
          reason: locale.languageCode);
    }
  });

  testWidgets('every supported language loads', (tester) async {
    for (final locale in AppLocalizations.supportedLocales) {
      late AppLocalizations l10n;
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(builder: (context) {
          l10n = context.l10n;
          return const SizedBox();
        }),
      ));
      expect(l10n.localeName, locale.languageCode);
      expect(l10n.commonCancel, isNotEmpty);
    }
  });
}
