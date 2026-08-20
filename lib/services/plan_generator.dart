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

  _Chunk(this.book, this.startCh, this.startV, this.endCh, this.endV, this.words, {this.endsOnPericope = false, this.endsOnChapter = false});
}

class PlanGenerator {
  final WordCountService wordCountService;
  final List<PericopeEntry> allPericopes;

  PlanGenerator({required this.wordCountService, required this.allPericopes});

  int _ref(int ch, int v) => ch * 1000 + v;

  ReadingPlan generatePlan({
    required String id,
    required String title,
    required List<PlanRange> ranges,
    required int days,
    int cadence = 7,
  }) {
    int effectiveReadingDays = (days * cadence / 7).round();
    if (effectiveReadingDays < 1) effectiveReadingDays = 1;

    // Initialize empty days
    List<PlanDay> schedule = List.generate(
        effectiveReadingDays,
        (i) => PlanDay(dayNumber: i + 1, portions: [], totalWords: 0));

    for (final range in ranges) {
      _distributeRange(range, effectiveReadingDays, schedule);
    }

    return ReadingPlan(
      id: id,
      title: title,
      days: days,
      cadence: cadence,
      schedule: schedule,
    );
  }

  void _distributeRange(
      PlanRange range, int effectiveReadingDays, List<PlanDay> schedule) {
    int totalWords = wordCountService.wordsInRange(
        range.book, range.startChapter, range.startVerse, range.endChapter, range.endVerse);

    if (totalWords == 0) return;

    double targetPerDay = totalWords / effectiveReadingDays;
    double maxWordsPerChunk = targetPerDay * 1.15;

    List<_Chunk> chunks = _getPericopeChunks(range);

    List<_Chunk> splitChunks = [];
    for (final c in chunks) {
      splitChunks.addAll(_splitChunk(c, maxWordsPerChunk));
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

      int targetForThisDay = ((currentDayIndex + 1) * targetPerDay).round();
      int errorIfAdded = (currentRunningTotal + chunk.words - targetForThisDay).abs();
      int errorIfNotAdded = (currentRunningTotal - targetForThisDay).abs();

      if (currentDayChunks.isEmpty || errorIfAdded <= errorIfNotAdded) {
        currentDayChunks.add(chunk);
        currentRunningTotal += chunk.words;
      } else {
        _finalizeDay(schedule[currentDayIndex], currentDayChunks, range.book);
        currentDayIndex++;
        currentDayChunks = [chunk];
        currentRunningTotal += chunk.words;
      }
    }

    if (currentDayChunks.isNotEmpty) {
      // Put everything remaining in the current day (or last day)
      // Usually currentDayIndex will be effectiveReadingDays - 1 here
      if (currentDayIndex >= effectiveReadingDays) {
        currentDayIndex = effectiveReadingDays - 1;
      }
      _finalizeDay(schedule[currentDayIndex], currentDayChunks, range.book);
    }
  }

  List<_Chunk> _getPericopeChunks(PlanRange range) {
    int startRef = _ref(range.startChapter, range.startVerse);
    int endRef = _ref(range.endChapter, range.endVerse);

    final bookPericopes = allPericopes.where((p) => p.book == range.book).toList();
    if (bookPericopes.isEmpty) {
      return [
        _Chunk(range.book, range.startChapter, range.startVerse,
            range.endChapter, range.endVerse,
            wordCountService.wordsInRange(range.book, range.startChapter,
                range.startVerse, range.endChapter, range.endVerse))
      ];
    }

    List<_Chunk> chunks = [];
    for (final p in bookPericopes) {
      int pStartRef = _ref(p.startChapter, p.startVerse);
      int pEndRef = _ref(p.endChapter, p.endVerse);

      if (startRef <= pEndRef && endRef >= pStartRef) {
        // Clamp to range
        bool startsBefore = pStartRef < startRef;
        int cStartCh = startsBefore ? range.startChapter : p.startChapter;
        int cStartV = startsBefore ? range.startVerse : p.startVerse;

        bool endsAfter = pEndRef > endRef;
        int cEndCh = endsAfter ? range.endChapter : p.endChapter;
        int cEndV = endsAfter ? range.endVerse : p.endVerse;

        int words = wordCountService.wordsInRange(
            range.book, cStartCh, cStartV, cEndCh, cEndV);
        
        // It ends on a pericope boundary if we didn't clamp the end
        bool endsOnPericope = !endsAfter;
        bool endsOnChapter = cEndV == wordCountService.maxVerseInChapter(range.book, cEndCh);

        chunks.add(_Chunk(range.book, cStartCh, cStartV, cEndCh, cEndV, words, endsOnPericope: endsOnPericope, endsOnChapter: endsOnChapter));
      }
    }
    return chunks;
  }

  List<_Chunk> _splitChunk(_Chunk c, double maxWords) {
    if (c.words <= maxWords) return [c];

    // Try splitting by chapter
    if (c.startCh < c.endCh) {
      List<_Chunk> chapterChunks = [];
      for (int ch = c.startCh; ch <= c.endCh; ch++) {
        int sV = (ch == c.startCh) ? c.startV : 1;
        int eV = (ch == c.endCh)
            ? c.endV
            : wordCountService.maxVerseInChapter(c.book, ch);
        int words = wordCountService.wordsInRange(c.book, ch, sV, ch, eV);
        
        bool endsOnPericope = (ch == c.endCh) ? c.endsOnPericope : false;
        bool endsOnChapter = eV == wordCountService.maxVerseInChapter(c.book, ch);
        
        chapterChunks.add(_Chunk(c.book, ch, sV, ch, eV, words, endsOnPericope: endsOnPericope, endsOnChapter: endsOnChapter));
      }
      return chapterChunks.expand((cc) => _splitChunk(cc, maxWords)).toList();
    }

    // Try splitting by verse
    if (c.startV < c.endV) {
      List<_Chunk> verseChunks = [];
      for (int v = c.startV; v <= c.endV; v++) {
        int words = wordCountService.wordsInRange(c.book, c.startCh, v, c.startCh, v);
        bool endsOnPericope = (v == c.endV) ? c.endsOnPericope : false;
        bool endsOnChapter = (v == wordCountService.maxVerseInChapter(c.book, c.startCh));
        verseChunks.add(_Chunk(c.book, c.startCh, v, c.startCh, v, words, endsOnPericope: endsOnPericope, endsOnChapter: endsOnChapter));
      }
      return verseChunks;
    }

    return [c];
  }

  void _finalizeDay(PlanDay day, List<_Chunk> chunks, String book) {
    if (chunks.isEmpty) return;

    int startCh = chunks.first.startCh;
    int startV = chunks.first.startV;
    int endCh = chunks.last.endCh;
    int endV = chunks.last.endV;
    int totalWords = chunks.fold(0, (sum, c) => sum + c.words);

    int startRef = _ref(startCh, startV);
    int endRef = _ref(endCh, endV);

    final titles = allPericopes.where((p) {
      if (p.book != book) return false;
      int pStart = _ref(p.startChapter, p.startVerse);
      int pEnd = _ref(p.endChapter, p.endVerse);
      return startRef <= pEnd && endRef >= pStart;
    }).map((p) => p.title).toSet().toList();

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
