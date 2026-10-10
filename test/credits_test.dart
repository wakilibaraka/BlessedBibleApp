import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/data/credits.dart';
import 'package:the_blessed_bible/ui/screens/credits_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('credits screen lists sources and links to licenses',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: CreditsScreen()),
    ));
    await tester.pump();

    expect(find.text('Scripture'), findsOneWidget);
    await tester.scrollUntilVisible(find.text(kCommentaryPerspective), 200);
    await tester.scrollUntilVisible(find.textContaining('OpenBible.info'), 200);
    await tester.scrollUntilVisible(find.text('Open-source licenses'), 200);
    expect(find.text('Open-source licenses'), findsOneWidget);
  });

  test('every bundled font family has an OFL notice', () async {
    registerFontLicenses();
    final entries = await LicenseRegistry.licenses.toList();
    final fontPackages = {
      for (final e in entries)
        for (final p in e.packages)
          if (p.endsWith(' (font)')) p.replaceAll(' (font)', ''),
    };

    final pubspec = File('pubspec.yaml').readAsStringSync();
    final declared = RegExp(r'^\s+- family: (.+)$', multiLine: true)
        .allMatches(pubspec)
        .map((m) => m.group(1)!.trim())
        .toSet();
    // pubspec family names that differ from the font's own name.
    final normalized = declared
        .map((f) => f == 'IM Fell English' ? 'IM FELL English' : f)
        .toSet();

    expect(fontPackages, containsAll(normalized));
    final text = entries
        .firstWhere((e) => e.packages.contains('Lora (font)'))
        .paragraphs
        .map((p) => p.text)
        .join('\n');
    expect(text, contains('SIL OPEN FONT LICENSE Version 1.1'));
  });
}
