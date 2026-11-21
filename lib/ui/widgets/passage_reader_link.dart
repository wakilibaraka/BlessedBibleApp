import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../data/bible_books.dart';
import '../../utils/passage.dart';
import '../screens/study_reader_screen.dart';

/// A resolved place to read: canonical English book name (the key every
/// collection uses), chapter, and the verse to emphasise when there is one.
typedef PassageTarget = ({String bookName, int chapter, int? verse});

/// Resolves [bookName] to the canonical book name and validates the numbers.
///
/// Returns null for unknown books and impossible chapters, so a caller can
/// refuse to navigate instead of landing somewhere plausible but wrong.
/// A verse of 0 or less is treated as "no verse" rather than verse 0.
PassageTarget? resolvePassageTarget({
  required String bookName,
  required int chapter,
  int? verse,
}) {
  final wanted = bookName.trim().toLowerCase();
  if (wanted.isEmpty || chapter < 1) return null;
  String? canonical;
  for (final name in kBibleBookNames) {
    if (name.toLowerCase() == wanted) {
      canonical = name;
      break;
    }
  }
  if (canonical == null) return null;
  return (
    bookName: canonical,
    chapter: chapter,
    verse: verse != null && verse > 0 ? verse : null,
  );
}

/// Opens a passage in the chapter reading UI — the same reader a reading-plan
/// day opens — instead of switching the main Read tab.
///
/// Pass a [NavigatorState] when the caller has to dismiss a sheet or route
/// first: the widget's context is gone after that, but the navigator is not.
Future<void> pushPassageInChapterReader(
  NavigatorState navigator, {
  required String bookName,
  required int chapter,
  int? verse,
}) {
  final target =
      resolvePassageTarget(bookName: bookName, chapter: chapter, verse: verse);
  if (target == null) return Future<void>.value();
  HapticFeedback.selectionClick();
  return navigator.push(
    CupertinoPageRoute<void>(
      builder: (_) => StudyReaderScreen(
        payload: StudySessionPayload.passage(
          bookName: target.bookName,
          chapter: target.chapter,
          verse: target.verse,
        ),
      ),
    ),
  );
}

/// Same as [pushPassageInChapterReader] for a widget that stays mounted.
/// The verse is emphasised and scrolled into view; a chapter-only target opens
/// at the top of the chapter. Unparseable or unknown targets do nothing, so a
/// bad reference can never open the wrong chapter or verse.
Future<void> openPassageInChapterReader(
  BuildContext context, {
  required String bookName,
  required int chapter,
  int? verse,
}) =>
    pushPassageInChapterReader(
      Navigator.of(context),
      bookName: bookName,
      chapter: chapter,
      verse: verse,
    );

/// Same as [openPassageInChapterReader], for a reference string such as
/// "Daniel 11:26", "1 John 3:16" or "Psalm 23:1-6" (the first verse is used).
Future<void> openReferenceInChapterReader(
  BuildContext context,
  String reference,
) {
  final passage = PassageRef.parse(reference);
  if (passage == null) return Future<void>.value();
  return openPassageInChapterReader(
    context,
    bookName: passage.bookName,
    chapter: passage.chapter,
    verse: passage.wholeChapter ? null : passage.startVerse,
  );
}
