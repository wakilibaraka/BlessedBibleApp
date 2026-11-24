/// Maps a chapter's narration onto its verses.
///
/// The public-domain WEB recordings ship one MP3 per chapter and publish no
/// per-verse timestamps, so a real karaoke track is not available. Instead the
/// chapter's duration is distributed across its verses in proportion to how
/// much text each verse has, which keeps the whole chapter correct and the
/// verse order exact, and can be re-anchored to a verse the listener can
/// actually hear (see [anchor]).
///
/// This is an estimate and is labelled as one in the UI. It never claims to
/// know where a verse starts to the second.
library;

/// One verse's span on the chapter timeline.
class VerseSpan {
  const VerseSpan({
    required this.verse,
    required this.start,
    required this.end,
  });

  final int verse;
  final Duration start;
  final Duration end;

  Duration get length => end - start;

  bool contains(Duration position) =>
      position >= start &&
      (position < end || (position == end && length == Duration.zero));

  @override
  bool operator ==(Object other) =>
      other is VerseSpan &&
      other.verse == verse &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(verse, start, end);

  @override
  String toString() => 'VerseSpan($verse, $start..$end)';
}

/// A verse the listener confirmed is playing right now, used to correct the
/// estimate for the rest of the chapter.
class VerseAnchor {
  const VerseAnchor({required this.verse, required this.at});

  final int verse;
  final Duration at;
}

/// The verse timeline for one chapter.
class AudioVerseTimeline {
  const AudioVerseTimeline(this.spans);

  static const AudioVerseTimeline empty = AudioVerseTimeline([]);

  final List<VerseSpan> spans;

  bool get isEmpty => spans.isEmpty;

  /// The verse playing at [position], or null when there is no timeline.
  int? verseAt(Duration position) {
    if (spans.isEmpty) return null;
    if (position <= spans.first.start) return spans.first.verse;
    // Binary search for the last span that starts at or before the position.
    var low = 0;
    var high = spans.length - 1;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      if (spans[mid].start <= position) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    return spans[low].verse;
  }

  /// Where a verse starts, or null when the verse is not in this chapter.
  Duration? startOf(int verse) {
    for (final span in spans) {
      if (span.verse == verse) return span.start;
    }
    return null;
  }

  VerseSpan? spanOf(int verse) {
    for (final span in spans) {
      if (span.verse == verse) return span;
    }
    return null;
  }

  /// The position reached when the last verse ends, which is the chapter's
  /// duration as the timeline understood it.
  Duration get end => spans.isEmpty ? Duration.zero : spans.last.end;

  /// Fraction (0..1) of the chapter that [position] has covered.
  double progressAt(Duration position) {
    final total = end.inMicroseconds;
    if (total <= 0) return 0;
    return (position.inMicroseconds / total).clamp(0.0, 1.0);
  }
}

/// One verse of the chapter, as the timeline needs it: an identity and the
/// text whose length sets its share of the narration.
typedef AudioVerseText = ({int number, String text});

class AudioVerseTiming {
  const AudioVerseTiming._();

  /// Distributes [duration] across [verses] by text length.
  ///
  /// [anchor] re-bases the estimate: verses before it are spread over the
  /// time already played, and verses after it over the time that is left, so
  /// a listener who says "this is verse 12, right here" gets a timeline that
  /// agrees with them from that point on.
  ///
  /// Returns [AudioVerseTimeline.empty] when there is nothing to map.
  static AudioVerseTimeline estimate({
    required List<AudioVerseText> verses,
    required Duration duration,
    VerseAnchor? anchor,
  }) {
    if (verses.isEmpty || duration <= Duration.zero) {
      return AudioVerseTimeline.empty;
    }

    final weights = <int>[
      for (final verse in verses) _weightOf(verse.text),
    ];

    var anchorIndex = -1;
    var anchorAt = Duration.zero;
    if (anchor != null) {
      anchorIndex = verses.indexWhere((v) => v.number == anchor.verse);
      if (anchorIndex < 0) {
        anchorIndex = -1;
      } else {
        anchorAt = _clampDuration(anchor.at, duration);
      }
    }

    // Two independent stretches: before the anchor and from it onwards. With
    // no anchor the whole chapter is one stretch starting at zero.
    final hasAnchor = anchorIndex >= 0;
    final segments = <_Segment>[];
    if (hasAnchor && anchorIndex > 0) {
      segments.add(_Segment(
        startIndex: 0,
        endIndex: anchorIndex,
        from: Duration.zero,
        to: anchorAt,
        weights: weights,
      ));
    }
    segments.add(_Segment(
      startIndex: hasAnchor ? anchorIndex : 0,
      endIndex: verses.length,
      from: hasAnchor ? anchorAt : Duration.zero,
      to: duration,
      weights: weights,
    ));

    final spans = <VerseSpan>[];
    for (final segment in segments) {
      spans.addAll(segment.spans(verses));
    }
    return AudioVerseTimeline(List<VerseSpan>.unmodifiable(spans));
  }

  /// The verse whose span covers [position] for a chapter played to
  /// [duration] — a convenience for callers that have no timeline yet.
  static int? verseAt({
    required List<AudioVerseText> verses,
    required Duration duration,
    required Duration position,
  }) =>
      estimate(verses: verses, duration: duration).verseAt(position);

  /// Character weight of a verse. Whitespace does not cost narration time,
  /// and a verse with no text at all still gets a share so the timeline
  /// stays complete and ordered.
  static int _weightOf(String text) {
    var weight = 0;
    for (final rune in text.trim().runes) {
      if (rune == 0x20 || rune == 0x0A || rune == 0x09) continue;
      weight++;
    }
    return weight == 0 ? 1 : weight;
  }

  static Duration _clampDuration(Duration value, Duration max) {
    if (value < Duration.zero) return Duration.zero;
    if (value > max) return max;
    return value;
  }
}

/// A stretch of verses that shares one start and end time.
class _Segment {
  const _Segment({
    required this.startIndex,
    required this.endIndex,
    required this.from,
    required this.to,
    required this.weights,
  });

  final int startIndex;
  final int endIndex;
  final Duration from;
  final Duration to;
  final List<int> weights;

  List<VerseSpan> spans(List<AudioVerseText> verses) {
    if (endIndex <= startIndex) return const [];
    var total = 0;
    for (var i = startIndex; i < endIndex; i++) {
      total += weights[i];
    }
    if (total <= 0) total = endIndex - startIndex;

    final out = <VerseSpan>[];
    final span = to - from;
    var cumulative = 0;
    for (var i = startIndex; i < endIndex; i++) {
      final start = from +
          Duration(
            microseconds: (span.inMicroseconds * (cumulative / total)).round(),
          );
      cumulative += weights[i];
      final end = i == endIndex - 1
          ? to
          : from +
              Duration(
                microseconds:
                    (span.inMicroseconds * (cumulative / total)).round(),
              );
      // Cumulative boundaries, not a sum of rounded shares: rounding can
      // never leave a gap or an overlap between verses.
      out.add(VerseSpan(verse: verses[i].number, start: start, end: end));
    }
    return out;
  }
}
