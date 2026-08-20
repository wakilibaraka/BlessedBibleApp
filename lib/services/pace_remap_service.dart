import '../models/reading_plan.dart';
import '../services/word_count_service.dart';
import '../services/plan_generator.dart';
import '../models/pericope_entry.dart';

/// Result of a pace remap operation.
class PaceRemapResult {
  final ReadingPlan newPlan;
  final Set<int> newCompletedReadings;
  final int completedDaysBefore;
  final int completedDaysAfter;

  const PaceRemapResult({
    required this.newPlan,
    required this.newCompletedReadings,
    required this.completedDaysBefore,
    required this.completedDaysAfter,
  });
}

/// Why Adjust Pace might be unavailable for a given plan.
enum PaceAdjustUnavailableReason {
  noTracks,
}

/// A pure, stateless service for remapping reading plan progress when a custom
/// plan's pace (day count) is changed. No Flutter / Riverpod dependencies —
/// fully unit-testable.
///
/// The algorithm:
/// 1. Build a set of "absolute verse indices" that the user has completed from
///    the OLD schedule + OLD completedReadings.
/// 2. Regenerate the plan with [PlanGenerator] using the same tracks + new day
///    count.
/// 3. For each NEW day, mark it complete IFF every verse in its portions is in
///    the completed-verse set.
class PaceRemapService {
  final WordCountService wordCountService;
  final List<PericopeEntry> allPericopes;

  PaceRemapService({
    required this.wordCountService,
    required this.allPericopes,
  });

  /// Returns null if pace adjustment is available, or the reason it is not.
  PaceAdjustUnavailableReason? unavailableReason(ReadingPlan plan) {
    if (plan.tracks == null || plan.tracks!.isEmpty) {
      return PaceAdjustUnavailableReason.noTracks;
    }
    return null;
  }

  /// Remap progress from [oldPlan]/[oldCompleted] to a plan with [newDayCount].
  ///
  /// Returns the new plan and new completed-readings set.
  /// Throws [ArgumentError] if the plan has no tracks.
  PaceRemapResult remap({
    required ReadingPlan oldPlan,
    required Set<int> oldCompleted,
    required int newDayCount,
  }) {
    if (oldPlan.tracks == null || oldPlan.tracks!.isEmpty) {
      throw ArgumentError('Cannot remap: plan has no saved tracks');
    }

    // ── Step 1: compute completed verse set ──────────────────────────────────
    final completedVerseIndices = _buildCompletedVerseSet(
      oldPlan.schedule,
      oldCompleted,
    );

    // ── Step 2: regenerate plan ──────────────────────────────────────────────
    final generator = PlanGenerator(
      wordCountService: wordCountService,
      allPericopes: allPericopes,
    );
    final newPlan = generator.generatePlan(
      id: oldPlan.id,
      title: oldPlan.title,
      tracks: oldPlan.tracks!,
      days: newDayCount,
      cadence: oldPlan.cadence,
    );

    // ── Step 3: remap completed days ─────────────────────────────────────────
    final newCompleted = <int>{};
    for (final day in newPlan.schedule) {
      if (_isDayFullyCompleted(day, completedVerseIndices)) {
        newCompleted.add(day.dayNumber);
      }
    }

    return PaceRemapResult(
      newPlan: newPlan,
      newCompletedReadings: newCompleted,
      completedDaysBefore: oldCompleted.length,
      completedDaysAfter: newCompleted.length,
    );
  }

  /// Build the set of absolute verse indices from completed days in the old plan.
  /// Also exposed as [buildCompletedVerseSetPublic] for unit tests.
  Set<int> _buildCompletedVerseSet(
    List<PlanDay> schedule,
    Set<int> completedDayNumbers,
  ) => buildCompletedVerseSetPublic(schedule, completedDayNumbers);

  /// Public alias for testing.
  Set<int> buildCompletedVerseSetPublic(
    List<PlanDay> schedule,
    Set<int> completedDayNumbers,
  ) {
    final result = <int>{};
    for (final day in schedule) {
      if (!completedDayNumbers.contains(day.dayNumber)) continue;
      for (final portion in day.portions) {
        _addVerseRange(result, portion.book, portion.startChapter,
            portion.startVerse, portion.endChapter, portion.endVerse);
      }
    }
    return result;
  }

  /// Returns true if EVERY verse in [day]'s portions is in [completedVerses].
  /// Also exposed as [isDayFullyCompletedPublic] for unit tests.
  bool _isDayFullyCompleted(PlanDay day, Set<int> completedVerses) =>
      isDayFullyCompletedPublic(day, completedVerses);

  /// Public alias for testing.
  bool isDayFullyCompletedPublic(PlanDay day, Set<int> completedVerses) {
    for (final portion in day.portions) {
      final dayIndices = <int>{};
      _addVerseRange(dayIndices, portion.book, portion.startChapter,
          portion.startVerse, portion.endChapter, portion.endVerse);
      for (final idx in dayIndices) {
        if (!completedVerses.contains(idx)) return false;
      }
    }
    return day.portions.isNotEmpty;
  }

  /// Encode a verse as an absolute index using the word_counts data.
  /// Gen 1:1 = 0, Gen 1:2 = 1, … Rev 22:21 = 31101.
  ///
  /// Uses a lazy-built cumulative offset table keyed by (book, chapter).
  int absoluteVerseIndex(String book, int chapter, int verse) {
    final offset = _chapterOffset(book, chapter);
    return offset + verse - 1; // verse is 1-indexed
  }

  // ── Internal index helpers ─────────────────────────────────────────────────

  /// Ordered list of KJV book names, in canonical order, derived from the
  /// word_counts data. Computed once and cached.
  static const _kjvBookOrder = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
    'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
    '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra',
    'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
    'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations',
    'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
    'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
    'Matthew', 'Mark', 'Luke', 'John', 'Acts',
    'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians',
    'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians',
    '1 Timothy', '2 Timothy', 'Titus', 'Philemon',
    'Hebrews', 'James', '1 Peter', '2 Peter',
    '1 John', '2 John', '3 John', 'Jude', 'Revelation',
  ];

  // Cached offset table: (book, chapter) → first absolute verse index.
  final Map<String, Map<int, int>> _chapterOffsets = {};
  bool _offsetsBuilt = false;

  void _ensureOffsets() {
    if (_offsetsBuilt) return;
    int current = 0;
    for (final book in _kjvBookOrder) {
      _chapterOffsets[book] = {};
      // Chapters are 1-based; iterate until maxVerseInChapter returns 0.
      for (int ch = 1; ; ch++) {
        final maxV = wordCountService.maxVerseInChapter(book, ch);
        if (maxV == 0) break;
        _chapterOffsets[book]![ch] = current;
        current += maxV;
      }
    }
    _offsetsBuilt = true;
  }

  int _chapterOffset(String book, int chapter) {
    _ensureOffsets();
    final bookMap = _chapterOffsets[book];
    if (bookMap == null) return 0;
    return bookMap[chapter] ?? 0;
  }

  void _addVerseRange(
      Set<int> result, String book, int startCh, int startV, int endCh, int endV) {
    for (int ch = startCh; ch <= endCh; ch++) {
      final firstV = (ch == startCh) ? startV : 1;
      final lastV = (ch == endCh)
          ? endV
          : wordCountService.maxVerseInChapter(book, ch);
      final offset = _chapterOffset(book, ch);
      for (int v = firstV; v <= lastV; v++) {
        result.add(offset + v - 1);
      }
    }
  }
}
