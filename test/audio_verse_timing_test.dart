import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/services/audio_bible_service.dart';
import 'package:the_blessed_bible/services/audio_verse_timing.dart';

void main() {
  const verses = <AudioVerseText>[
    (number: 1, text: 'In the beginning'),
    (number: 2, text: 'And the earth was without form'),
    (number: 3, text: 'And God said'),
    (number: 4, text: 'And God saw the light'),
  ];

  /// Four verses of identical length, so each one owns exactly a quarter of
  /// the chapter and the expected boundaries are exact.
  const evenVerses = <AudioVerseText>[
    (number: 1, text: 'aaaa'),
    (number: 2, text: 'bbbb'),
    (number: 3, text: 'cccc'),
    (number: 4, text: 'dddd'),
  ];

  group('verse timeline', () {
    test('covers the whole chapter in verse order', () {
      final timeline = AudioVerseTiming.estimate(
        verses: verses,
        duration: const Duration(minutes: 4),
      );

      expect(timeline.spans, hasLength(4));
      expect(timeline.spans.first.start, Duration.zero);
      expect(timeline.spans.last.end, const Duration(minutes: 4));
      expect(timeline.end, const Duration(minutes: 4));
      expect([for (final s in timeline.spans) s.verse], [1, 2, 3, 4]);

      for (var i = 1; i < timeline.spans.length; i++) {
        // No gaps, no overlaps, never going backwards.
        expect(timeline.spans[i].start, timeline.spans[i - 1].end);
        expect(timeline.spans[i].end, greaterThan(timeline.spans[i].start));
      }
    });

    test('gives a longer verse a longer span', () {
      final timeline = AudioVerseTiming.estimate(
        verses: const [
          (number: 1, text: 'short'),
          (number: 2, text: 'a much much much longer verse than the first'),
        ],
        duration: const Duration(seconds: 30),
      );

      expect(timeline.spans[1].length, greaterThan(timeline.spans[0].length));
      expect(timeline.spans[1].start, timeline.spans[0].end);
    });

    test('reports the verse playing at a position', () {
      final timeline = AudioVerseTiming.estimate(
        verses: evenVerses,
        duration: const Duration(seconds: 40),
      );

      // Each of the four verses gets 10 seconds.
      expect(timeline.verseAt(Duration.zero), 1);
      expect(timeline.verseAt(const Duration(seconds: 9)), 1);
      expect(timeline.verseAt(const Duration(seconds: 10)), 2);
      expect(timeline.verseAt(const Duration(seconds: 21)), 3);
      expect(timeline.verseAt(const Duration(seconds: 39)), 4);
      expect(timeline.verseAt(const Duration(seconds: 40)), 4);
      // Past the end (a stale position) still reports the last verse.
      expect(timeline.verseAt(const Duration(hours: 1)), 4);
    });

    test('an anchor re-bases the rest of the chapter', () {
      final timeline = AudioVerseTiming.estimate(
        verses: evenVerses,
        duration: const Duration(seconds: 40),
        anchor: const VerseAnchor(verse: 3, at: Duration(seconds: 20)),
      );

      expect(timeline.startOf(1), Duration.zero);
      // Two verses share the 20 seconds already played.
      expect(timeline.startOf(2), const Duration(seconds: 10));
      expect(timeline.startOf(3), const Duration(seconds: 20));
      // Two verses share the 20 seconds that are left.
      expect(timeline.startOf(4), const Duration(seconds: 30));
      expect(timeline.end, const Duration(seconds: 40));
      expect(timeline.verseAt(const Duration(seconds: 20)), 3);
    });

    test('an anchor on the first verse leaves the intro behind it', () {
      final timeline = AudioVerseTiming.estimate(
        verses: evenVerses,
        duration: const Duration(seconds: 40),
        anchor: const VerseAnchor(verse: 1, at: Duration(seconds: 4)),
      );

      expect(timeline.startOf(1), const Duration(seconds: 4));
      expect(timeline.end, const Duration(seconds: 40));
    });

    test('an anchor outside the chapter is ignored', () {
      final timeline = AudioVerseTiming.estimate(
        verses: evenVerses,
        duration: const Duration(seconds: 40),
        anchor: const VerseAnchor(verse: 99, at: Duration(seconds: 20)),
      );

      expect(timeline.spans.first.start, Duration.zero);
      expect(timeline.spans.last.end, const Duration(seconds: 40));
      expect(timeline.spans, hasLength(4));
    });

    test('reports progress through the chapter', () {
      final timeline = AudioVerseTiming.estimate(
        verses: verses,
        duration: const Duration(seconds: 40),
      );

      expect(timeline.progressAt(Duration.zero), 0);
      expect(timeline.progressAt(const Duration(seconds: 20)), 0.5);
      expect(timeline.progressAt(const Duration(minutes: 5)), 1);
    });

    test('has nothing to say without verses or a duration', () {
      expect(
        AudioVerseTiming.estimate(
          verses: const [],
          duration: const Duration(minutes: 3),
        ).isEmpty,
        isTrue,
      );
      expect(
        AudioVerseTiming.estimate(verses: verses, duration: Duration.zero)
            .isEmpty,
        isTrue,
      );
      expect(const AudioVerseTimeline([]).verseAt(Duration.zero), isNull);
      expect(
          AudioVerseTiming.verseAt(
            verses: const [],
            duration: Duration.zero,
            position: Duration.zero,
          ),
          isNull);
    });

    test('a verse with no text still gets a share', () {
      final timeline = AudioVerseTiming.estimate(
        verses: const [
          (number: 1, text: 'text'),
          (number: 2, text: '   '),
          (number: 3, text: 'more text'),
        ],
        duration: const Duration(seconds: 30),
      );

      expect(timeline.spans, hasLength(3));
      expect(timeline.spans.last.end, const Duration(seconds: 30));
      expect(timeline.spanOf(2), isNotNull);
    });
  });

  group('advance mode', () {
    AudioChapterRef? advance(
      String book,
      int chapter,
      AudioAdvanceMode mode, {
      String? consumedFor,
      bool navigating = false,
    }) =>
        AudioBibleService.advanceAfterCompletion(
          book: book,
          chapter: chapter,
          consumedFor: consumedFor,
          navigating: navigating,
          mode: mode,
        );

    test('keep playing crosses into the next book', () {
      expect(
        advance('Genesis', 50, AudioAdvanceMode.chapter),
        const AudioChapterRef('Exodus', 1),
      );
    });

    test('stop at the end of the book', () {
      expect(
        advance('Genesis', 49, AudioAdvanceMode.book),
        const AudioChapterRef('Genesis', 50),
      );
      expect(advance('Genesis', 50, AudioAdvanceMode.book), isNull);
      // Within the book the mode does not matter.
      expect(
        advance('Psalms', 1, AudioAdvanceMode.book),
        const AudioChapterRef('Psalms', 2),
      );
    });

    test('off never advances', () {
      expect(advance('Genesis', 1, AudioAdvanceMode.off), isNull);
      expect(advance('Revelation', 22, AudioAdvanceMode.off), isNull);
    });

    test('the guards still hold in every mode', () {
      for (final mode in AudioAdvanceMode.values) {
        expect(
          advance('Genesis', 1, mode, navigating: true),
          isNull,
          reason: 'a load already in flight must not be raced',
        );
        expect(
          advance(
            'Genesis',
            1,
            mode,
            consumedFor: AudioBibleService.chapterId('Genesis', 1),
          ),
          isNull,
          reason: 'a completion is acted on once',
        );
      }
      expect(advance('Revelation', 22, AudioAdvanceMode.chapter), isNull);
    });
  });
}
