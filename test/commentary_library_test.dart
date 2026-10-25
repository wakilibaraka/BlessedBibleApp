// Commentary library browser: shelf of volumes, scripture index, and the
// two-tap route from a volume cover to a chapter.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/l10n/l10n.dart';
import 'package:the_blessed_bible/models/commentary_entry.dart';
import 'package:the_blessed_bible/models/study_content_category.dart';
import 'package:the_blessed_bible/state/commentary_provider.dart';
import 'package:the_blessed_bible/theme/app_theme.dart';
import 'package:the_blessed_bible/ui/screens/commentary_library_v2_screen.dart';

class _FakeCommentary extends CommentaryNotifier {
  final List<CommentaryEntry> entries;

  _FakeCommentary(this.entries);

  @override
  Future<List<CommentaryEntry>> build() async => entries;
}

CommentaryEntry _entry({
  required String id,
  required String author,
  required String source,
  String? book,
  int? chapter,
  int? verse,
  String type = 'verse',
  String? topic,
}) =>
    CommentaryEntry(
      id: id,
      author: author,
      source: source,
      scope: CommentaryScope(
        type: type,
        book: book,
        chapter: chapter,
        verse: verse,
        topic: topic,
      ),
      text: 'The text of this entry.',
      category: StudyContentCategory.commentary,
    );

final _entries = [
  _entry(
      id: 'm1',
      author: 'Ellen G. White',
      source: 'The Desire of Ages',
      book: 'Matthew',
      chapter: 1,
      verse: 1),
  _entry(
      id: 'm2',
      author: 'Ellen G. White',
      source: 'The Desire of Ages',
      book: 'Matthew',
      chapter: 1,
      verse: 2),
  _entry(
      id: 'm3',
      author: 'Ellen G. White',
      source: 'The Desire of Ages',
      book: 'Matthew',
      chapter: 2,
      verse: 1),
  _entry(
      id: 'd1',
      author: 'Uriah Smith',
      source: 'Daniel and the Revelation (11:1-2)',
      book: 'Daniel',
      chapter: 11,
      verse: 1),
  _entry(
      id: 'd2',
      author: 'Uriah Smith',
      source: 'Daniel and the Revelation (11:3-4)',
      book: 'Daniel',
      chapter: 11,
      verse: 3),
  _entry(
      id: 'r1',
      author: 'Uriah Smith',
      source: 'Daniel and the Revelation (13:11-17)',
      book: 'Revelation',
      chapter: 13,
      verse: 11),
  // Topical extract: counted in its volume but covers no chapter.
  _entry(
      id: 't1',
      author: 'Ellen G. White',
      source: 'Review and Herald',
      type: 'topic',
      topic: 'Trinity'),
];

/// The page shell animates its background forever, so `pumpAndSettle` never
/// returns. Pump a few frames instead: enough for the async provider and for
/// route transitions to finish.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// The cover of the volume titled [title] on the shelf.
Finder cover(String title) => find.byKey(ValueKey('volume-cover:$title'));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpLibrary(
    WidgetTester tester, {
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(PreferencesService(prefs)),
        commentaryProvider.overrideWith(() => _FakeCommentary(_entries)),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(16),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const CommentaryLibraryV2Screen(),
      ),
    ));
    await _settle(tester);
  }

  testWidgets('the shelf folds range-suffixed sources into one volume',
      (tester) async {
    await pumpLibrary(tester);

    expect(cover('Daniel and the Revelation'), findsOneWidget);
    expect(cover('The Desire of Ages'), findsOneWidget);
    // The one volume is counted once, not once per verse range.
    expect(find.textContaining('2 VOLUMES'), findsOneWidget);
    // Topical-only material has no chapters to open, so it is not a cover.
    expect(cover('Review and Herald'), findsNothing);
    expect(find.text('Review and Herald'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the scripture index lists covered books with their volume',
      (tester) async {
    await pumpLibrary(tester);

    expect(find.text('Matthew'), findsOneWidget);
    expect(find.text('Daniel'), findsOneWidget);
    expect(find.text('Revelation'), findsOneWidget);
    // Matthew is covered in 2 chapters by one volume.
    expect(find.text('The Desire of Ages'), findsNWidgets(2)); // cover + row
    expect(find.text('2 chapters'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search filters the shelf and the index together',
      (tester) async {
    await pumpLibrary(tester);

    await tester.enterText(find.byType(TextField), 'desire');
    await _settle(tester);
    expect(cover('The Desire of Ages'), findsOneWidget);
    expect(cover('Daniel and the Revelation'), findsNothing);
    expect(find.text('Matthew'), findsOneWidget);
    expect(find.text('Daniel'), findsNothing);
    expect(find.textContaining('1 VOLUME'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear'));
    await _settle(tester);
    expect(cover('Daniel and the Revelation'), findsOneWidget);
    expect(find.text('Daniel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search matches an author and a volume title', (tester) async {
    await pumpLibrary(tester);

    await tester.enterText(find.byType(TextField), 'smith');
    await _settle(tester);
    expect(cover('Daniel and the Revelation'), findsOneWidget);
    expect(cover('The Desire of Ages'), findsNothing);
    expect(find.text('Matthew'), findsNothing);
    expect(find.text('Daniel'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await _settle(tester);
    expect(find.textContaining('Nothing matches'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a volume opens its chapters, and a chapter opens the hub',
      (tester) async {
    await pumpLibrary(tester);

    await tester.tap(cover('Daniel and the Revelation'));
    await _settle(tester);

    expect(find.byType(CommentaryVolumeScreen), findsOneWidget);
    // Title page: author, both covered books, chapter tiles per book.
    expect(find.text('Daniel and the Revelation'), findsWidgets);
    expect(find.text('URIAH SMITH'), findsOneWidget);
    expect(find.text('Daniel'), findsOneWidget);
    expect(find.text('Revelation'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);

    await tester.tap(find.text('11'));
    await _settle(tester);
    expect(find.byType(CommentaryHubV2Screen), findsOneWidget);
    expect(find.text('Daniel 11'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a book row opens its chapters, then the hub', (tester) async {
    await pumpLibrary(tester);

    await tester.tap(find.text('Matthew'));
    await _settle(tester);

    expect(find.text('2 chapters with content'), findsOneWidget);
    await tester.tap(find.text('2'));
    await _settle(tester);
    expect(find.byType(CommentaryHubV2Screen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the shelf survives the largest accessibility text size',
      (tester) async {
    await pumpLibrary(tester, textScale: 1.8);

    expect(cover('The Desire of Ages'), findsOneWidget);
    expect(cover('Daniel and the Revelation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
