import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_blessed_bible/l10n/l10n.dart';
import 'package:the_blessed_bible/models/commentary_entry.dart';
import 'package:the_blessed_bible/models/study_content_category.dart';
import 'package:the_blessed_bible/state/commentary_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/commentary_hub_screen.dart';
import 'package:the_blessed_bible/ui/widgets/commentary_prose.dart';
import 'package:the_blessed_bible/ui/widgets/verse_link_text.dart';

class _FakeCommentary extends CommentaryNotifier {
  final List<CommentaryEntry> entries;

  _FakeCommentary(this.entries);

  @override
  Future<List<CommentaryEntry>> build() async => entries;
}

void main() {
  final entries = [
    CommentaryEntry(
      id: 'c1',
      author: 'Uriah Smith',
      source: 'Daniel and the Revelation',
      scope: CommentaryScope(
          type: 'verse', book: 'Daniel', chapter: 11, verse: 27),
      text: 'Antony and Caesar were formerly in alliance.\nTheir '
          'protestations of deference were\nthe utterances of hypocrites.\n\n'
          'See **Daniel 11:27** for the wider setting.',
      category: StudyContentCategory.commentary,
    ),
    CommentaryEntry(
      id: 'c2',
      author: 'Ellen G. White',
      source: 'Prophets and Kings',
      scope: CommentaryScope(type: 'chapter', book: 'Daniel', chapter: 11),
      text: 'A chapter-level devotional note.',
      category: StudyContentCategory.devotional,
    ),
  ];

  Future<void> pumpHub(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        commentaryProvider.overrideWith(() => _FakeCommentary(entries)),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(16),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const CommentaryHubScreen(
          book: 'Daniel',
          chapter: 11,
          verse: 27,
          verseText:
              'And both these kings\u2019 hearts shall be to do mischief.',
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('refined hub shows the verse card, filter pills and entries',
      (tester) async {
    await pumpHub(tester);

    expect(find.byType(CommentaryVerseCard), findsOneWidget);
    expect(find.text('Daniel 11:27'), findsWidgets);
    expect(find.textContaining('both these kings'), findsOneWidget);
    // Paragraphs are rendered by VerseLinkText (lazily built list).
    expect(find.byType(VerseLinkText), findsAtLeastNWidgets(2));
    // Refined eyebrow: source uppercased, author in the footer.
    expect(find.text('DANIEL AND THE REVELATION'), findsOneWidget);
    expect(find.text('Uriah Smith'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('classic preset keeps the previous layout', (tester) async {
    await pumpHub(tester,
        prefs: const {'read_settings_commentary_style': 'classic'});

    expect(find.byType(CommentaryVerseCard), findsNothing);
    expect(find.byType(VerseLinkText), findsNWidgets(3));
    // Classic eyebrow: source as written.
    expect(find.text('Daniel and the Revelation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
