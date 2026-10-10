import 'package:the_blessed_bible/models/pericope_entry.dart';
import 'package:the_blessed_bible/models/reading_plan.dart';
import 'package:the_blessed_bible/services/word_count_service.dart';

class _Chunk {
  final String book;
  final int startCh;
  final int startV;
  final int endCh;
  final int endV;
  final int words;

  /// Identifies if this chunk ends on a pericope boundary naturally.
  final bool endsOnPericope;
  final bool endsOnChapter;

  _Chunk(
      this.book, this.startCh, this.startV, this.endCh, this.endV, this.words,
      {this.endsOnPericope = false, this.endsOnChapter = false});
}

const int kSlowReaderWpm = 130;
const int kMinDailyReadingMinutes = 1;
const int minWordsPerDay = kSlowReaderWpm * kMinDailyReadingMinutes;

/// Reading-speed presets (words per minute) for pace estimates.
const int kRelaxedWpm = 100;
const int kStandardWpm = 130;
const int kBriskWpm = 200;

class PlanGenerator {
  final WordCountService wordCountService;
  final List<PericopeEntry> allPericopes;

  /// Words per minute used for time estimates and the minimum-words
  /// floor. Defaults to the historic constant (behavior unchanged
  /// unless a setting is passed).
  final int wpm;

  PlanGenerator({
    required this.wordCountService,
    required this.allPericopes,
    this.wpm = kSlowReaderWpm,
  });

  int get minWordsForDay => wpm * kMinDailyReadingMinutes;

  int _ref(int ch, int v) => ch * 1000 + v;

  ReadingPlan generatePlan({
    required String id,
    required String title,
    required List<List<PlanRange>> tracks,
    required int days,
    int cadence = 7,
    bool atomicRanges = false,
  }) {
    if (days <= 0) {
      throw ArgumentError('Days must be greater than 0');
    }

    int totalPlanWords = 0;
    for (final track in tracks) {
      for (final range in track) {
        totalPlanWords += wordCountService.wordsInRange(
            range.book,
            range.startChapter,
            range.startVerse,
            range.endChapter,
            range.endVerse);
      }
    }

    if (totalPlanWords == 0) {
      return ReadingPlan(
          id: id,
          title: title,
          days: 0,
          cadence: cadence,
          schedule: [],
          tracks: tracks);
    }

    int effectiveReadingDays = (days * cadence / 7).round();
    if (effectiveReadingDays < 1) effectiveReadingDays = 1;

    int maxDays = (totalPlanWords / minWordsForDay).floor();
    if (maxDays < 1) maxDays = 1;

    bool wasClamped = false;
    String? clampReason;
    if (effectiveReadingDays > maxDays) {
      effectiveReadingDays = maxDays;
      wasClamped = true;
      clampReason = 'The gentlest pace for this selection is $maxDays days.';
    }

    // Initialize empty days
    final List<PlanDay> schedule = List.generate(
        effectiveReadingDays,
        (i) => PlanDay(
            dayNumber: i + 1,
            portions: [],
            totalWords: 0,
            estimatedMinutes: 0,
            estimatedTimeDisplay: ''));

    for (final track in tracks) {
      _distributeTrack(track, effectiveReadingDays, schedule,
          atomicRanges: atomicRanges);
    }

    // Remove any trailing empty days (happens if days > available break points)
    schedule.removeWhere((day) => day.portions.isEmpty);

    // Compute estimated reading times for each finalized day
    final finalizedSchedule = schedule.map((day) {
      final int minutes = (day.totalWords / wpm).round();
      final String display = minutes < 1 ? '<1 min' : '$minutes min';
      return PlanDay(
        dayNumber: day.dayNumber,
        portions: day.portions,
        totalWords: day.totalWords,
        estimatedMinutes: minutes,
        estimatedTimeDisplay: display,
      );
    }).toList();

    return ReadingPlan(
      id: id,
      title: title,
      days: finalizedSchedule
          .length, // Clamp the reported days to the actual produced days
      cadence: cadence,
      wasClamped: wasClamped,
      clampReason: clampReason,
      schedule: finalizedSchedule,
      tracks: tracks,
    );
  }

  void _distributeTrack(
      List<PlanRange> track, int effectiveReadingDays, List<PlanDay> schedule,
      {bool atomicRanges = false}) {
    int totalWords = 0;
    for (final range in track) {
      totalWords += wordCountService.wordsInRange(
          range.book,
          range.startChapter,
          range.startVerse,
          range.endChapter,
          range.endVerse);
    }

    if (totalWords == 0) return;

    final double targetPerDay = totalWords / effectiveReadingDays;
    final double maxWordsPerChunk = targetPerDay * 1.15;

    final List<_Chunk> splitChunks = [];
    if (atomicRanges) {
      for (final range in track) {
        final w = wordCountService.wordsInRange(range.book, range.startChapter,
            range.startVerse, range.endChapter, range.endVerse);
        splitChunks.add(_Chunk(range.book, range.startChapter, range.startVerse,
            range.endChapter, range.endVerse, w));
      }
    } else {
      for (final range in track) {
        final List<_Chunk> chunks = _getPericopeChunks(range);
        for (final c in chunks) {
          splitChunks.addAll(_splitChunk(c, maxWordsPerChunk));
        }
      }
    }

    int currentDayIndex = 0;
    List<_Chunk> currentDayChunks = [];
    int currentRunningTotal = 0;

    for (int i = 0; i < splitChunks.length; i++) {
      final chunk = splitChunks[i];

      if (currentDayIndex == effectiveReadingDays - 1) {
        currentDayChunks.add(chunk);
        currentRunningTotal += chunk.words;
        continue;
      }

      final int targetForThisDay =
          ((currentDayIndex + 1) * targetPerDay).round();
      final int errorIfAdded =
          (currentRunningTotal + chunk.words - targetForThisDay).abs();
      final int errorIfNotAdded =
          (currentRunningTotal - targetForThisDay).abs();

      if (currentDayChunks.isEmpty || errorIfAdded <= errorIfNotAdded) {
        currentDayChunks.add(chunk);
        currentRunningTotal += chunk.words;
      } else {
        _finalizeDay(schedule[currentDayIndex], currentDayChunks);
        currentDayIndex++;
        currentDayChunks = [chunk];
        currentRunningTotal += chunk.words;
      }
    }

    if (currentDayChunks.isNotEmpty) {
      if (currentDayIndex >= effectiveReadingDays) {
        currentDayIndex = effectiveReadingDays - 1;
      }
      _finalizeDay(schedule[currentDayIndex], currentDayChunks);
    }
  }

  /// Pericope-aware chunks for [range] with EXACT coverage.
  ///
  /// Raw pericope entries overlap each other and leave gaps, so naively
  /// emitting one chunk per intersecting pericope double-counts verses and
  /// drops others (later plan days then falsely read as "fully completed"
  /// during pace remaps). Instead: expand the range to verses, sweep them
  /// into runs that break at pericope boundaries, and emit one chunk per
  /// run. Union of chunks == range exactly once.
  List<_Chunk> _getPericopeChunks(PlanRange range) {
    final bookPericopes = allPericopes
        .where((p) => p.book == range.book && p.isPlanBreak)
        .toList();
    if (bookPericopes.isEmpty) {
      return [
        _Chunk(
            range.book,
            range.startChapter,
            range.startVerse,
            range.endChapter,
            range.endVerse,
            wordCountService.wordsInRange(range.book, range.startChapter,
                range.startVerse, range.endChapter, range.endVerse))
      ];
    }

    // Expand range to verses.
    final chs = <int>[];
    final vs = <int>[];
    for (int ch = range.startChapter; ch <= range.endChapter; ch++) {
      final sV = (ch == range.startChapter) ? range.startVerse : 1;
      final maxV = wordCountService.maxVerseInChapter(range.book, ch);
      if (maxV <= 0) continue;
      final eV = (ch == range.endChapter) ? range.endVerse : maxV;
      for (int v = sV; v <= eV; v++) {
        chs.add(ch);
        vs.add(v);
      }
    }
    if (chs.isEmpty) return [];

    // Cover key per verse: sorted ids of intersecting pericopes ('-' = gap).
    String keyFor(int i) {
      final r = _ref(chs[i], vs[i]);
      final ids = <int>[];
      for (var k = 0; k < bookPericopes.length; k++) {
        final p = bookPericopes[k];
        if (r >= _ref(p.startChapter, p.startVerse) &&
            r <= _ref(p.endChapter, p.endVerse)) {
          ids.add(k);
        }
      }
      return ids.isEmpty ? '-' : ids.join(',');
    }

    bool pericopeEndsAt(int i) {
      final r = _ref(chs[i], vs[i]);
      for (final p in bookPericopes) {
        if (r == _ref(p.endChapter, p.endVerse)) return true;
      }
      return false;
    }

    final chunks = <_Chunk>[];
    var runStart = 0;
    var runKey = keyFor(0);
    void emitRun(int end) {
      final words = wordCountService.wordsInRange(
          range.book, chs[runStart], vs[runStart], chs[end], vs[end]);
      chunks.add(_Chunk(
        range.book,
        chs[runStart],
        vs[runStart],
        chs[end],
        vs[end],
        words,
        endsOnPericope: pericopeEndsAt(end),
        endsOnChapter:
            vs[end] == wordCountService.maxVerseInChapter(range.book, chs[end]),
      ));
    }

    for (var i = 1; i < chs.length; i++) {
      final k = keyFor(i);
      if (k != runKey) {
        emitRun(i - 1);
        runStart = i;
        runKey = k;
      }
    }
    emitRun(chs.length - 1);
    return chunks;
  }

  List<_Chunk> _splitChunk(_Chunk c, double maxWords) {
    if (c.words <= maxWords) return [c];

    // Try splitting by chapter
    if (c.startCh < c.endCh) {
      final List<_Chunk> chapterChunks = [];
      for (int ch = c.startCh; ch <= c.endCh; ch++) {
        final int sV = (ch == c.startCh) ? c.startV : 1;
        final int eV = (ch == c.endCh)
            ? c.endV
            : wordCountService.maxVerseInChapter(c.book, ch);
        final int words = wordCountService.wordsInRange(c.book, ch, sV, ch, eV);

        final bool endsOnPericope = (ch == c.endCh) ? c.endsOnPericope : false;
        final bool endsOnChapter =
            eV == wordCountService.maxVerseInChapter(c.book, ch);

        chapterChunks.add(_Chunk(c.book, ch, sV, ch, eV, words,
            endsOnPericope: endsOnPericope, endsOnChapter: endsOnChapter));
      }
      return chapterChunks.expand((cc) => _splitChunk(cc, maxWords)).toList();
    }

    // Try splitting by verse
    if (c.startV < c.endV) {
      final List<_Chunk> verseChunks = [];
      for (int v = c.startV; v <= c.endV; v++) {
        final int words =
            wordCountService.wordsInRange(c.book, c.startCh, v, c.startCh, v);
        final bool endsOnPericope = (v == c.endV) ? c.endsOnPericope : false;
        final bool endsOnChapter =
            (v == wordCountService.maxVerseInChapter(c.book, c.startCh));
        verseChunks.add(_Chunk(c.book, c.startCh, v, c.startCh, v, words,
            endsOnPericope: endsOnPericope, endsOnChapter: endsOnChapter));
      }
      return verseChunks;
    }

    return [c];
  }

  /// True when (ch2:v2) is exactly the verse after (ch1:v1).
  bool _isNextVerse(String book, int ch1, int v1, int ch2, int v2) {
    if (ch2 == ch1) return v2 == v1 + 1;
    if (ch2 == ch1 + 1 && v2 == 1) {
      return v1 == wordCountService.maxVerseInChapter(book, ch1);
    }
    return false;
  }

  void _finalizeDay(PlanDay day, List<_Chunk> chunks) {
    if (chunks.isEmpty) return;

    final Map<String, List<_Chunk>> chunksByBook = {};
    for (final c in chunks) {
      chunksByBook.putIfAbsent(c.book, () => []).add(c);
    }

    for (final entry in chunksByBook.entries) {
      final book = entry.key;
      final bookChunks = entry.value;

      // Merge contiguous runs only. Merging first→last across a gap would
      // silently double-count the gap (the root cause of remap tests
      // seeing "fully completed" days that were never read).
      var runStart = 0;
      void emitRun(int runEnd) {
        final first = bookChunks[runStart];
        final last = bookChunks[runEnd];
        int totalWords = 0;
        for (var i = runStart; i <= runEnd; i++) {
          totalWords += bookChunks[i].words;
        }
        _addPortion(day, book, first.startCh, first.startV, last.endCh,
            last.endV, totalWords);
      }

      for (var i = 1; i < bookChunks.length; i++) {
        final prev = bookChunks[i - 1];
        final cur = bookChunks[i];
        final contiguous = _isNextVerse(
                book, prev.endCh, prev.endV, cur.startCh, cur.startV) ||
            _ref(cur.startCh, cur.startV) <= _ref(prev.endCh, prev.endV);
        if (!contiguous) {
          emitRun(i - 1);
          runStart = i;
        }
      }
      emitRun(bookChunks.length - 1);
    }
  }

  void _addPortion(PlanDay day, String book, int startCh, int startV, int endCh,
      int endV, int totalWords) {
    final int startRef = _ref(startCh, startV);
    final int endRef = _ref(endCh, endV);

    final titles = allPericopes
        .where((p) {
          if (p.book != book || !p.isPlanBreak) return false;
          final int pStart = _ref(p.startChapter, p.startVerse);
          final int pEnd = _ref(p.endChapter, p.endVerse);
          return startRef <= pEnd && endRef >= pStart;
        })
        .map((p) => p.title)
        .toSet()
        .toList();

    day.portions.add(PlanPortion(
      book: book,
      startChapter: startCh,
      startVerse: startV,
      endChapter: endCh,
      endVerse: endV,
      wordCount: totalWords,
      pericopeTitles: titles,
    ));

    day.totalWords += totalWords;
  }
}
