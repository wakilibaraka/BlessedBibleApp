// Commentary verse card: the pull-quote must always be the verse the card is
// labelled with. A caller-supplied `verseText` belongs to the verse the view
// was opened with, so in chapter mode (no verse) it must not be reused for the
// first verse in the chapter.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/data/models/bible_model.dart';
import 'package:the_blessed_bible/l10n/l10n.dart';
import 'package:the_blessed_bible/models/commentary_entry.dart';
import 'package:the_blessed_bible/models/study_content_category.dart';
import 'package:the_blessed_bible/state/bible_provider.dart';
import 'package:the_blessed_bible/state/commentary_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/widgets/commentary_prose.dart';
import 'package:the_blessed_bible/ui/widgets/commentary_view.dart';

const _verse26 = 'And they shall pollute the sanctuary of strength.';
const _verse27 = 'And both these kings hearts shall be to do mischief.';

class _FakeBible extends BibleNotifier {
  @override
  BibleState build() => BibleState(books: [
        BibleBook(name: 'Daniel', abbreviation: 'Dan', chapters: [
          BibleChapter(number: 11, verses: [
            BibleVerse(number: 26, text: _verse26),
            BibleVerse(number: 27, text: _verse27),
          ]),
        ]),
      ]);
}

class _FakeCommentary extends CommentaryNotifier {
  _FakeCommentary(this.entries);
  final List<CommentaryEntry> entries;

  @override
  Future<List<CommentaryEntry>> build() async => entries;
}

CommentaryEntry _entry(int verse, String text) => CommentaryEntry(
      id: 'daniel-11-$verse',
      author: 'A',
      source: 'Commentary',
      scope: CommentaryScope(
          type: 'verse', book: 'Daniel', chapter: 11, verse: verse),
      text: text,
      category: StudyContentCategory.commentary,
    );

void main() {
  testWidgets('chapter mode quotes the verse on the card, not the stale text',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
        bibleProvider.overrideWith(_FakeBible.new),
        commentaryProvider.overrideWith(() => _FakeCommentary([
              _entry(26, 'The first entry in the chapter.'),
              _entry(27, 'The second entry in the chapter.'),
            ])),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(16),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(
          body: CommentaryView(
            book: 'Daniel',
            chapter: 11,
            // Chapter mode: no verse, so the card falls back to the first
            // verse with commentary in the chapter (11:26).
            // The text came from the reader's verse 11:27, which is stale here.
            verseText: _verse27,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final card =
        tester.widget<CommentaryVerseCard>(find.byType(CommentaryVerseCard));
    expect(card.reference, 'Daniel 11:26');
    expect(card.verseText, _verse26);
    expect(find.text(_verse26), findsOneWidget);
    // The caller's text belongs to 11:27, not to the verse being labelled.
    expect(find.text(_verse27), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
