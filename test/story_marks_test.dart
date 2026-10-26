// Story highlights and underlines: span marking keeps text intact, mark
// offsets line up with what the reader renders, and marks persist.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/state/devotional_provider.dart';
import 'package:the_blessed_bible/ui/widgets/prose_text.dart';
import 'package:the_blessed_bible/ui/widgets/verse_link_text.dart';
import 'package:the_blessed_bible/utils/prose.dart';
import 'package:the_blessed_bible/utils/span_marks.dart';
import 'package:the_blessed_bible/utils/verse_linker.dart';

String _plain(List<InlineSpan> spans) =>
    spans.map((s) => s.toPlainText()).join();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('applySpanMarks splits spans without changing text', () {
    final spans = <InlineSpan>[
      const TextSpan(text: 'Hello '),
      const TextSpan(text: 'Judges', children: [TextSpan(text: ' 13:24')]),
      const TextSpan(text: ' world'),
    ];
    const style = TextStyle(backgroundColor: Colors.yellow);
    final marked = applySpanMarks(spans, [(start: 3, end: 10, style: style)]);
    expect(_plain(marked), _plain(spans));

    final styled = <String>[];
    for (final span in marked) {
      span.visitChildren((child) {
        if (child is TextSpan &&
            child.text != null &&
            child.style?.backgroundColor == Colors.yellow) {
          styled.add(child.text!);
        }
        return true;
      });
    }
    expect(styled.join(), 'lo Judg');
  });

  test('mark offsets match the rendered text of every story', () {
    // ProseText counts offsets over renderedParagraph; the spans the
    // reader draws must hold exactly that text or marks would drift.
    for (final file in Directory('assets/devotional/stories')
        .listSync()
        .whereType<File>()
        .where((f) => !f.path.endsWith('index.json'))) {
      final pack = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      for (final story in pack['stories'] as List<dynamic>) {
        final retelling =
            (story as Map<String, dynamic>)['retelling'] as String;
        for (final paragraph in proseParagraphs(retelling)) {
          final drawn = splitMarkupSegments(paragraph)
              .expand((s) => VerseLinker.parse(s.text))
              .toList();
          expect(_plain(drawn), renderedParagraph(paragraph),
              reason: '${story['id']}');
        }
      }
    }
  });

  test('locateSelection ignores line-break differences', () {
    const rendered = 'First paragraph ends here.\nSecond one starts.';
    expect(locateSelection(rendered, 'ends here.\r\nSecond'),
        (start: 16, end: 33));
    expect(locateSelection(rendered, 'not there'), isNull);
    expect(locateSelection(rendered, '   '), isNull);
  });

  test('marks persist, replace overlaps of the same kind, and remove',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    ProviderContainer make() => ProviderContainer(overrides: [
          preferencesProvider.overrideWithValue(PreferencesService(prefs)),
        ]);

    final container = make();
    final marks = container.read(storyMarksProvider.notifier);
    marks.add('JDG-008',
        const StoryMark(start: 0, end: 10, kind: StoryMarkKind.highlight));
    marks.add('JDG-008',
        const StoryMark(start: 5, end: 15, kind: StoryMarkKind.highlight));
    marks.add('JDG-008',
        const StoryMark(start: 20, end: 30, kind: StoryMarkKind.underline));
    expect(container.read(storyMarksProvider)['JDG-008']!.length, 2);
    container.dispose();

    final reloaded = make();
    addTearDown(reloaded.dispose);
    final saved = reloaded.read(storyMarksProvider)['JDG-008']!;
    expect(saved.map((m) => (m.start, m.end, m.kind)), [
      (5, 15, StoryMarkKind.highlight),
      (20, 30, StoryMarkKind.underline),
    ]);

    reloaded.read(storyMarksProvider.notifier).removeRange('JDG-008', 0, 40);
    expect(reloaded.read(storyMarksProvider)['JDG-008'], isNull);
  });

  testWidgets('story text is selectable inside a SelectionArea',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SelectionArea(
          child: VerseLinkText(text: 'And the child grew.'),
        ),
      ),
    ));
    final rich = tester.widget<RichText>(find.byType(RichText).last);
    expect(rich.selectionRegistrar, isNotNull);
  });

  test('renderedProse joins paragraphs with one newline', () {
    expect(
        renderedProse('One **bold**\nline.\n\nTwo.'), 'One bold line.\nTwo.');
  });
}
