import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_blessed_bible/l10n/l10n.dart';

void main() {
  test('no hard-coded English UI strings in lib/ui', () {
    // Text widgets, tooltips and hints should read from context.l10n.
    final pattern = RegExp(
        r"Text\(\s*'[A-Za-z]{3,}|tooltip: '[A-Z]|label: (const )?Text\('[A-Z]|hintText: '[A-Z]");
    final offenders = <String>[];
    for (final file in Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
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
    for (final lang in ['fr', 'it', 'ro', 'sw', 'tl']) {
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
