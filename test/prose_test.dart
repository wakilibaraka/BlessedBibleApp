import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_blessed_bible/l10n/l10n.dart';
import 'package:the_blessed_bible/state/home_provider.dart';
import 'package:the_blessed_bible/state/typography_provider.dart';
import 'package:the_blessed_bible/ui/widgets/commentary_prose.dart';
import 'package:the_blessed_bible/ui/widgets/prose_text.dart';
import 'package:the_blessed_bible/ui/widgets/verse_link_text.dart';
import 'package:the_blessed_bible/utils/passage.dart';
import 'package:the_blessed_bible/utils/prose.dart';

void main() {
  group('normalizeProse', () {
    test('rejoins hard-wrapped lines into one sentence', () {
      const wrapped =
          'In the beginning God created\nthe heaven and the earth.\nAnd the earth was without form,';
      expect(
        normalizeProse(wrapped),
        'In the beginning God created the heaven and the earth. And the earth was without form,',
      );
    });

    test('collapses doubled spaces and stray indentation', () {
      expect(
          normalizeProse('  Grace   be\n\t unto   you  '), 'Grace be unto you');
    });

    test('restores a missing space after sentence punctuation', () {
      expect(normalizeProse('God.It is written:Behold'),
          'God. It is written: Behold');
      // Verse references and decimals are untouched.
      expect(normalizeProse('Dan.11:27 and 1.5'), 'Dan.11:27 and 1.5');
    });

    test('drops zero-width characters', () {
      expect(normalizeProse('be\u200bhold'), 'behold');
    });
  });

  group('proseParagraphs', () {
    test('keeps blank-line paragraphs and joins wrapped lines', () {
      const raw = 'First line\nwrapped here.\n\nSecond paragraph\nstill going.';
      expect(proseParagraphs(raw), [
        'First line wrapped here.',
        'Second paragraph still going.',
      ]);
    });

    test('drops empty paragraphs and keeps text without breaks whole', () {
      expect(proseParagraphs('\n\nOne paragraph only.\n\n'),
          ['One paragraph only.']);
    });
  });

  group('splitMarkupSegments', () {
    test('splits bold and underline, keeping plain runs', () {
      final segments = splitMarkupSegments('A **bold** word and __this__ end');
      expect(segments.map((s) => s.text).toList(),
          ['A ', 'bold', ' word and ', 'this', ' end']);
      expect(segments.map((s) => s.bold).toList(),
          [false, true, false, false, false]);
      expect(segments.map((s) => s.underline).toList(),
          [false, false, false, true, false]);
    });

    test('leaves unmatched markers as literal text', () {
      final segments = splitMarkupSegments('2 * 3 and __open');
      expect(segments.map((s) => s.text).join(), '2 * 3 and __open');
    });
  });

  group('extractVotdSnippet', () {
    test('shows a paragraph, not one clipped sentence', () {
      const entry = 'The time appointed is probably the prophetic time of '
          'verse 24, which has been previously mentioned. It closed, as '
          'already shown, in A.D. 508. From that date the daily sacrifice was '
          'taken away. The sanctuary was then cast down. Every reader of the '
          'prophecy should mark this. The dates are not accidental. History '
          'confirms the sequence. The next step follows plainly.';
      final snippet = extractVotdSnippet(entry);
      expect(snippet.split('. ').length, greaterThan(3),
          reason: 'the old three-sentence cap made the home card too thin');
      expect(snippet.length, lessThanOrEqualTo(420));
      expect(snippet.endsWith('.'), isTrue,
          reason: 'excerpts stop on a sentence boundary');
      expect(snippet.contains('A. D. 508'), isTrue,
          reason: 'abbreviations must not split a sentence into stubs');
      expect(normalizeProse(entry).startsWith(snippet), isTrue,
          reason: 'the excerpt is a prefix of the entry');
    });

    test('keeps short entries whole and tolerates missing punctuation', () {
      expect(extractVotdSnippet('Here is the patience of the saints.'),
          'Here is the patience of the saints.');
      expect(extractVotdSnippet('Short entry.'), 'Short entry.');
      expect(extractVotdSnippet('No final stop here'), 'No final stop here');
    });

    test('never ends mid-word on a long single sentence', () {
      final long = 'Grace ${'and mercy ' * 60}forever.';
      final snippet = extractVotdSnippet(long);
      expect(snippet.endsWith('.'), isTrue);
    });
  });

  group('content packs', () {
    test('story retellings rejoin source wraps without stray breaks', () {
      final raw = File('assets/devotional/stories/1CH.json').readAsStringSync();
      final stories =
          (jsonDecode(raw) as Map<String, dynamic>)['stories'] as List<dynamic>;
      final text =
          (stories.first as Map<String, dynamic>)['retelling'] as String;

      final paragraphs = proseParagraphs(text);
      expect(paragraphs, isNotEmpty);
      for (final paragraph in paragraphs) {
        expect(paragraph.contains('\n'), isFalse, reason: paragraph);
        expect(paragraph.contains('  '), isFalse, reason: paragraph);
      }
      expect(paragraphs.first.split(' ').length, greaterThan(2));
    });

    test('story packs do not duplicate the KJV passage', () {
      // The reader resolves each story's reference against the Bible
      // database, so the packs must not carry the passage text again.
      for (final file in Directory('assets/devotional/stories')
          .listSync()
          .whereType<File>()
          .where((f) => !f.path.endsWith('index.json'))) {
        final pack =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        for (final story in pack['stories'] as List<dynamic>) {
          final s = story as Map<String, dynamic>;
          expect(s.containsKey('text'), isFalse, reason: '${s['id']}');
          expect(PassageRef.parse(s['ref'] as String), isNotNull,
              reason: '${s['id']}: ${s['ref']}');
        }
      }
    });

    test('commentary markers are parsed away from rendered text', () {
      // The shipped pack is cleaned of OCR markup (tool/clean_commentary.py),
      // so exercise the renderer with the marker mix it must still tolerate.
      const text = 'Antony and Caesar were formerly in alliance.\n'
          'See **Daniel 11:27** for the wider setting and __this__ note.';
      final rendered = proseParagraphs(text)
          .map((p) => splitMarkupSegments(p).map((s) => s.text).join())
          .join(' ');
      expect(rendered.contains('**'), isFalse);
      expect(rendered.contains('__'), isFalse);
      expect(rendered.contains('Daniel 11:27'), isTrue);
    });
  });

  testWidgets('CommentaryVerseCard shows the verse and its reference',
      (tester) async {
    const ink = Color(0xFF221E18);
    const accent = Color(0xFF8A6A3B);
    await tester.pumpWidget(MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const Scaffold(
        body: CommentaryVerseCard(
          reference: 'Daniel 11:27',
          verseText: 'And both these kings\' hearts shall be to do mischief.',
          ink: ink,
          accent: accent,
          surface: Color(0xFFFBF7EF),
          border: Color(0xFFE4DACB),
          shadow: Color(0x22000000),
          typography: TypographyState(),
        ),
      ),
    ));
    expect(find.text('Daniel 11:27'), findsOneWidget);
    expect(
      find.textContaining('And both these kings'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProseText renders one block per paragraph', (tester) async {
    const raw = 'Alpha beta\ngamma.\n\nDelta epsilon.';
    await tester.pumpWidget(MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: ProseText(
          text: raw,
          typography: const TypographyState(),
          accent: const Color(0xFF8A6A3B),
        ),
      ),
    ));
    expect(find.byType(VerseLinkText), findsNWidgets(2));
  });
}
