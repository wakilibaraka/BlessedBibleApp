// Unified share sheet: what the preview promises must match what gets
// copied, the WhatsApp/plain choice must change it, and PDF must only be
// offered for long-form content.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/l10n/l10n.dart';
import 'package:the_blessed_bible/models/share_content.dart';
import 'package:the_blessed_bible/ui/widgets/share_document_preview.dart';
import 'package:the_blessed_bible/ui/widgets/share_sheet.dart';

Widget host(ShareContent content, {required PreferencesService prefs}) =>
    ProviderScope(
      overrides: [preferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: TextButton(
                onPressed: () => showShareSheet(context: ctx, content: content),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      ),
    );

String previewText(WidgetTester tester) {
  final preview =
      tester.widget<SelectableText>(find.byType(SelectableText).first);
  return preview.data ?? '';
}

Future<PreferencesService> open(
  WidgetTester tester,
  ShareContent content, {
  Map<String, Object> prefsValues = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(host(content, prefs: PreferencesService(prefs)));
  await tester.tap(find.text('OPEN'));
  await tester.pumpAndSettle();
  return PreferencesService(prefs);
}

void main() {
  final verse = ShareContent.verse(
    reference: 'John 3:16',
    texts: ['For God so loved the world.'],
    translationTag: 'KJV',
  );

  testWidgets('verse sheet defaults to the WhatsApp flavor', (tester) async {
    await open(tester, verse);
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Image'), findsOneWidget);
    // No PDF for a single verse.
    expect(find.text('PDF'), findsNothing);
    expect(previewText(tester), contains('_— John 3:16 (KJV)_'));
  });

  testWidgets('plain flavor drops the markup', (tester) async {
    await open(tester, verse);
    await tester.tap(find.text('Plain text'));
    await tester.pumpAndSettle();
    final preview = previewText(tester);
    expect(preview, contains('— John 3:16 (KJV)'));
    expect(preview, isNot(contains('_— John 3:16 (KJV)_')));
  });

  testWidgets('a saved plain flavor is used on the next share', (tester) async {
    await open(tester, verse, prefsValues: {'share_flavor': 'plain'});
    final preview = previewText(tester);
    expect(preview, contains('— John 3:16 (KJV)'));
    expect(preview, isNot(contains('_—')));
  });

  testWidgets('choosing a flavor remembers it across launches', (tester) async {
    final prefs =
        await open(tester, verse, prefsValues: {'share_flavor': 'plain'});
    await tester.tap(find.text('WhatsApp'));
    await tester.pumpAndSettle();
    expect(prefs.getShareFlavor(), 'whatsapp');
    expect(previewText(tester), contains('_— John 3:16 (KJV)_'));
  });

  testWidgets('reference toggle removes the citation', (tester) async {
    await open(tester, verse);
    await tester.tap(find.text('Include reference'));
    await tester.pumpAndSettle();
    final preview = previewText(tester);
    expect(preview, contains('For God so loved the world.'));
    expect(preview, isNot(contains('John 3:16')));
  });

  testWidgets('commentary sheet offers a PDF', (tester) async {
    await open(
      tester,
      ShareContent.commentary(
        text: 'The earth was without form and void.',
        reference: 'Genesis 1:2',
        source: 'Patriarchs and Prophets',
        author: 'Ellen G. White',
      ),
    );
    expect(find.text('PDF'), findsOneWidget);

    await tester.tap(find.text('PDF'));
    await tester.pumpAndSettle();
    expect(find.text('Print-ready PDF'), findsOneWidget);
    expect(find.text('Share PDF'), findsOneWidget);
    // The sheet previews the exported page itself.
    expect(find.byType(ShareDocumentPreview), findsOneWidget);
  });

  testWidgets('image mode exposes the export shapes', (tester) async {
    await open(tester, verse);
    await tester.tap(find.text('Image'));
    await tester.pumpAndSettle();
    expect(find.text('Portrait'), findsOneWidget);
    expect(find.text('Square'), findsOneWidget);
    expect(find.text('Story'), findsOneWidget);
    expect(find.text('1080 × 1350 px'), findsOneWidget);
    // Both destinations for the image are offered.
    expect(find.text('Save to gallery'), findsOneWidget);
    expect(find.text('Share image'), findsOneWidget);

    await tester.tap(find.text('Square'));
    await tester.pumpAndSettle();
    expect(find.text('1080 × 1080 px'), findsOneWidget);
  });
}
