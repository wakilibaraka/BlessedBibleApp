import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Single canonical model for every reading plan (Phase B).
///
/// Curated assets, generated plans and (later) imports all become a
/// [PlanSpec]. The original asset strings are preserved verbatim on
/// [PlanRefSpec.label] so `toCuratedJson()` reproduces the source asset
/// exactly (byte-stability gate for in-progress users), while the parsed
/// bounds drive the scheduler without string parsing.
///
/// Design constraints (see plan):
/// - Plan ids, titles and day->passage mappings never change through
///   conversion: in-progress users must not see their plan reshuffle.
/// - Curated assets carry explicit day splits ([days]); the scheduler only
///   runs for generated plans. `tracks` mirrors the generator's input
///   shape (`List<List<PlanRange>>` equivalent) for forward compatibility.

/// Canon bounds for ref parsing: book -> chapter -> sorted verses.
typedef CanonIndex = Map<String, Map<int, List<int>>>;

const Map<String, String> _bookAliases = {
  'jud': 'Jude',
  'joh': 'John',
  '2 joh': '2 John',
  '3 joh': '3 John',
  'psalm': 'Psalms',
  '1 thes': '1 Thessalonians',
  '2 thes': '2 Thessalonians',
  'song of songs': 'Song of Solomon',
};

final RegExp _refPattern = RegExp(
    r'^(.*?)\s+(\d+)(?::(\d+)(?:\s*[-–—]\s*(?:(\d+):)?(\d+))?|\s*[-–—]\s*(\d+)(?::(\d+))?)?$');

/// One structured scripture range with its original display string.
class PlanRefSpec {
  final String book;
  final int startChapter;
  final int startVerse;
  final int endChapter;
  final int endVerse;

  /// The exact asset string this was parsed from (round-trip fidelity).
  final String label;

  const PlanRefSpec({
    required this.book,
    required this.startChapter,
    required this.startVerse,
    required this.endChapter,
    required this.endVerse,
    required this.label,
  });

  /// Parses asset ref forms: single verse, whole chapter, verse ranges
  /// (same or cross-chapter), chapter ranges, bare books and known
  /// abbreviations. Throws [FormatException] on anything unresolvable.
  factory PlanRefSpec.parse(String raw, CanonIndex canon) {
    final r = raw.trim();
    for (final name in canon.keys) {
      if (name.toLowerCase() == r.toLowerCase()) {
        final chapters = canon[name]!;
        final first = chapters.keys.reduce((a, b) => a < b ? a : b);
        final last = chapters.keys.reduce((a, b) => a > b ? a : b);
        return PlanRefSpec(
          book: name,
          startChapter: first,
          startVerse: 1,
          endChapter: last,
          endVerse: chapters[last]!.last,
          label: raw,
        );
      }
    }
    final alias = _bookAliases[r.toLowerCase()];
    if (alias != null && canon.containsKey(alias)) {
      final chapters = canon[alias]!;
      final first = chapters.keys.reduce((a, b) => a < b ? a : b);
      final last = chapters.keys.reduce((a, b) => a > b ? a : b);
      return PlanRefSpec(
        book: alias,
        startChapter: first,
        startVerse: 1,
        endChapter: last,
        endVerse: chapters[last]!.last,
        label: raw,
      );
    }
    final m = _refPattern.firstMatch(r);
    if (m == null) throw FormatException('unparseable ref: $raw');
    var book = m.group(1)!;
    if (!canon.containsKey(book)) {
      final a = _bookAliases[book.toLowerCase()];
      if (a == null || !canon.containsKey(a)) {
        throw FormatException('unknown book: $book in $raw');
      }
      book = a;
    }
    final chapters = canon[book]!;
    final c1 = int.parse(m.group(2)!);
    final v1s = m.group(3);
    final c2s = m.group(4);
    final v2s = m.group(5);
    final cendS = m.group(6);

    void checkChapter(int ch) {
      if (!chapters.containsKey(ch)) {
        throw FormatException('bad chapter: $raw');
      }
    }

    void checkVerse(int ch, int v) {
      final vs = chapters[ch]!;
      if (v < vs.first || v > vs.last) {
        throw FormatException('verse out of range: $raw');
      }
    }

    // Single-chapter book with "A-B" form: always verses A..B.
    if (v1s == null && cendS != null && chapters.length == 1) {
      final only = chapters.keys.single;
      final hi = int.parse(cendS);
      checkVerse(only, c1);
      checkVerse(only, hi);
      if (c1 > hi) throw FormatException('reversed range: $raw');
      return PlanRefSpec(
          book: book,
          startChapter: only,
          startVerse: c1,
          endChapter: only,
          endVerse: hi,
          label: raw);
    }
    checkChapter(c1);
    if (v1s == null && cendS == null) {
      final vs = chapters[c1]!;
      return PlanRefSpec(
          book: book,
          startChapter: c1,
          startVerse: vs.first,
          endChapter: c1,
          endVerse: vs.last,
          label: raw);
    }
    if (v1s == null) {
      final vendS = m.group(7);
      final c2 = int.parse(cendS!);
      checkChapter(c2);
      if (c2 < c1) throw FormatException('reversed range: $raw');
      final hi = vendS == null ? chapters[c2]!.last : int.parse(vendS);
      checkVerse(c2, hi);
      return PlanRefSpec(
          book: book,
          startChapter: c1,
          startVerse: 1,
          endChapter: c2,
          endVerse: hi,
          label: raw);
    }
    final v1 = int.parse(v1s);
    final c2 = c2s == null ? c1 : int.parse(c2s);
    final v2 = v2s == null ? v1 : int.parse(v2s);
    checkChapter(c2);
    if (c2 < c1 || (c2 == c1 && v2 < v1)) {
      throw FormatException('reversed range: $raw');
    }
    checkVerse(c1, v1);
    checkVerse(c2, v2);
    // Interior chapters contribute whole chapters.
    for (var ch = c1 + 1; ch <= c2 - 1; ch++) {
      checkChapter(ch);
    }
    return PlanRefSpec(
        book: book,
        startChapter: c1,
        startVerse: v1,
        endChapter: c2,
        endVerse: v2,
        label: raw);
  }

  Map<String, dynamic> toJson() => {
        'book': book,
        'startChapter': startChapter,
        'startVerse': startVerse,
        'endChapter': endChapter,
        'endVerse': endVerse,
        'label': label,
      };

  factory PlanRefSpec.fromJson(Map<String, dynamic> json) => PlanRefSpec(
        book: json['book'] as String,
        startChapter: json['startChapter'] as int,
        startVerse: json['startVerse'] as int,
        endChapter: json['endChapter'] as int,
        endVerse: json['endVerse'] as int,
        label: json['label'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is PlanRefSpec &&
      book == other.book &&
      startChapter == other.startChapter &&
      startVerse == other.startVerse &&
      endChapter == other.endChapter &&
      endVerse == other.endVerse;

  @override
  int get hashCode =>
      Object.hash(book, startChapter, startVerse, endChapter, endVerse);
}

class PlanPassageSpec {
  final String label;
  final List<PlanRefSpec> refs;
  const PlanPassageSpec({required this.label, required this.refs});

  Map<String, dynamic> toJson() => {
        'label': label,
        'refs': [for (final r in refs) r.label],
      };
}

class PlanSpecDay {
  final int day;
  final int week;
  final String title;
  final List<PlanPassageSpec> passages;
  const PlanSpecDay({
    required this.day,
    required this.week,
    required this.title,
    required this.passages,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'week': week,
        'title': title,
        'passages': [
          for (final p in passages) p.toJson(),
        ],
      };
}

enum PlanOrigin { bundled, generated, imported }

enum TrackKind { canonical, chronological, topical, explicitRanges }

class PlanTrack {
  final String id;
  final String label;
  final TrackKind kind;
  final List<PlanRefSpec> ranges;
  const PlanTrack({
    required this.id,
    required this.label,
    required this.kind,
    required this.ranges,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'kind': kind.name,
        'ranges': [for (final r in ranges) r.toJson()],
      };
}

class PlanSpec {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String? badge;
  final int? totalDays;
  final PlanOrigin origin;

  /// Parallel reading tracks (passage-index grouping for curated plans).
  final List<PlanTrack> tracks;

  /// Explicit day splits (curated plans): the scheduler is bypassed.
  final List<PlanSpecDay> days;
  final int cadenceDays;

  /// Rest weekdays (app convention 1=Sun..7=Sat). Empty = no rest.
  final Set<int> restDays;

  final String? attribution;
  final String? license;

  /// sha256 of the source readings array (provenance / drift detection).
  final String? sourceDigest;

  const PlanSpec({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.badge,
    this.totalDays,
    this.origin = PlanOrigin.bundled,
    required this.tracks,
    required this.days,
    required this.cadenceDays,
    this.restDays = const {},
    this.attribution,
    this.license,
    this.sourceDigest,
  });

  /// Converts a curated asset map (title/id/description/readings shape).
  /// Passage order within each day defines track membership
  /// (passage index i -> track i), which reconstructs parallel-track
  /// plans deterministically.
  factory PlanSpec.fromCuratedJson(
    Map<String, dynamic> json, {
    required CanonIndex canon,
  }) {
    final readings = json['readings'] as List;
    final days = <PlanSpecDay>[];
    final trackRanges = <int, List<PlanRefSpec>>{};
    for (var i = 0; i < readings.length; i++) {
      final day = readings[i] as Map<String, dynamic>;
      final passages = <PlanPassageSpec>[];
      final refs = day['passages'] as List;
      for (var j = 0; j < refs.length; j++) {
        final p = refs[j] as Map<String, dynamic>;
        final parsed = [
          for (final r in (p['refs'] as List))
            PlanRefSpec.parse(r as String, canon),
        ];
        passages
            .add(PlanPassageSpec(label: p['label'] as String, refs: parsed));
        trackRanges.putIfAbsent(j, () => []).addAll(parsed);
      }
      days.add(PlanSpecDay(
        day: day['day'] as int,
        week: day['week'] as int,
        title: day['title'] as String,
        passages: passages,
      ));
    }
    final trackIds = trackRanges.keys.toList()..sort();
    return PlanSpec(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      badge: json['badge'] as String?,
      totalDays: json['totalDays'] as int?,
      origin: PlanOrigin.bundled,
      attribution: json['attribution'] as String?,
      license: json['license'] as String?,
      tracks: [
        for (final t in trackIds)
          PlanTrack(
            id: 'track-$t',
            label: 'Track ${t + 1}',
            kind: TrackKind.explicitRanges,
            ranges: trackRanges[t]!,
          ),
      ],
      days: days,
      cadenceDays: days.length,
      sourceDigest:
          sha256.convert(utf8.encode(jsonEncode(readings))).toString(),
    );
  }

  /// Emits the curated asset shape. With [PlanSpec]s produced by
  /// [fromCuratedJson], output deep-equals the source asset.
  Map<String, dynamic> toCuratedJson() {
    final map = <String, dynamic>{
      'title': title,
      'id': id,
    };
    if (description != null) map['description'] = description;
    if (category != null) map['category'] = category;
    if (badge != null) map['badge'] = badge;
    if (totalDays != null) map['totalDays'] = totalDays;
    if (attribution != null) map['attribution'] = attribution;
    if (license != null) map['license'] = license;
    map['readings'] = [for (final d in days) d.toJson()];
    return map;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (badge != null) 'badge': badge,
        if (totalDays != null) 'totalDays': totalDays,
        'origin': origin.name,
        'tracks': [for (final t in tracks) t.toJson()],
        'days': [for (final d in days) d.toJson()],
        'cadenceDays': cadenceDays,
        'restDays': restDays.toList(),
        if (attribution != null) 'attribution': attribution,
        if (license != null) 'license': license,
        if (sourceDigest != null) 'sourceDigest': sourceDigest,
      };
}
