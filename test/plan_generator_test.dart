import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/pericope_entry.dart';
import 'package:the_blessed_bible/models/reading_plan.dart';
import 'package:the_blessed_bible/services/plan_generator.dart';
import 'package:the_blessed_bible/services/word_count_service.dart';

void main() {
  late WordCountService wordCountService;
  late List<PericopeEntry> allPericopes;
  late PlanGenerator generator;

  setUpAll(() async {
    // 1. Initialize WordCountService
    final wcFile = File('assets/data/word_counts.json');
    final wcJson = wcFile.readAsStringSync();
    wordCountService = WordCountService();
    // Use synchronous parsing to bypass isolate issues in tests if any, or compute works fine
    await wordCountService.initFromJson(wcJson);

    // 2. Load Pericopes
    final pFile = File('assets/data/pericopes.json');
    final pList = jsonDecode(pFile.readAsStringSync()) as List;
    allPericopes = pList.map((j) => PericopeEntry.fromJson(j)).toList();

    generator = PlanGenerator(
      wordCountService: wordCountService,
      allPericopes: allPericopes,
    );
  });

  test('Generate and verify Genesis 30 days', () {
    final plan = generator.generatePlan(
      id: 'gen30',
      title: 'Genesis in 30 Days',
      tracks: [[
        PlanRange(book: 'Genesis', startChapter: 1, startVerse: 1, endChapter: 50, endVerse: 26) // 50:26 is the last verse
      ]],
      days: 30,
      cadence: 7,
    );

    expect(plan.schedule.length, 30);
    
    int totalWords = 0;
    int minWords = 999999;
    int maxWords = 0;
    
    // Check distribution
    for (final day in plan.schedule) {
      final words = day.totalWords;
      totalWords += words;
      if (words < minWords) minWords = words;
      if (words > maxWords) maxWords = words;
      
      expect(day.portions.length, 1);
    }

    final avgWords = totalWords / 30;
    debugPrint('Genesis 30 Days - Words/Day: Min=$minWords, Max=$maxWords, Avg=${avgWords.toStringAsFixed(1)}');
    
    for (int i = 0; i < 3; i++) {
      debugPrint('Day ${i+1} estimated minutes: ${plan.schedule[i].estimatedTimeDisplay}');
    }

    // Total Genesis words should be ~38,000
    debugPrint('Total Genesis words in plan: $totalWords');
    expect(totalWords, wordCountService.wordsInRange('Genesis', 1, 1, 50, 26));
  });

  test('Generate and verify Hebrews 30 days', () {
    final plan = generator.generatePlan(
      id: 'heb30',
      title: 'Hebrews in 30 Days',
      tracks: [[
        PlanRange(book: 'Hebrews', startChapter: 1, startVerse: 1, endChapter: 13, endVerse: 25)
      ]],
      days: 30,
      cadence: 7,
    );

    expect(plan.schedule.length, 30);
    
    int totalWords = 0;
    for (final day in plan.schedule) {
      totalWords += day.totalWords;
    }
    
    debugPrint('Total Hebrews words in plan: $totalWords');
    // Genesis 30 days covers fewer chapters each day. Hebrews 30 days spreads 13 chapters over 30 days.
    // That means Hebrews will likely have multiple days covering fractions of a chapter, breaking on pericopes.
  });

  test('Verify pericope boundaries in Genesis plan', () {
    final plan = generator.generatePlan(
      id: 'gen30',
      title: 'Genesis',
      tracks: [[
        PlanRange(book: 'Genesis', startChapter: 1, startVerse: 1, endChapter: 50, endVerse: 26)
      ]],
      days: 30,
      cadence: 7,
    );

    int chapterBreaks = 0;
    int verseBreaks = 0;
    
    for (final day in plan.schedule) {
      final portion = day.portions.first;
      
      // Look for a pericope that matches the exact END of this portion
      bool endsOnPericope = allPericopes.any((p) => 
        p.book == portion.book && p.endChapter == portion.endChapter && p.endVerse == portion.endVerse
      );
      
      if (!endsOnPericope) {
        // Did it end on a chapter boundary?
        int maxV = wordCountService.maxVerseInChapter(portion.book, portion.endChapter);
        if (portion.endVerse == maxV) {
          chapterBreaks++;
        } else {
          // If it's the very last portion of the book, it might be the end of the book. 
          // But the end of Genesis is 50:26, which SHOULD be a pericope boundary.
          if (portion.endChapter == 50 && portion.endVerse == 26) {
            // It's the end of the book.
          } else {
            verseBreaks++;
            debugPrint('Verse break on day ${day.dayNumber} ending at ${portion.endChapter}:${portion.endVerse}');
          }
        }
      }
    }
    
    debugPrint('Genesis breaks: Pericope=${30 - chapterBreaks - verseBreaks}, Chapter=$chapterBreaks, Verse=$verseBreaks');
  });

  test('Multi-track: Genesis + Hebrews in 30 days', () {
    final plan = generator.generatePlan(
      id: 'genheb30',
      title: 'Gen + Heb',
      tracks: [
        [PlanRange(book: 'Genesis', startChapter: 1, startVerse: 1, endChapter: 50, endVerse: 26)],
        [PlanRange(book: 'Hebrews', startChapter: 1, startVerse: 1, endChapter: 13, endVerse: 25)],
      ],
      days: 30,
      cadence: 7,
    );

    expect(plan.schedule.length, 30);
    
    for (int i = 0; i < 30; i++) {
      final day = plan.schedule[i];
      // Expect 2 portions (track 1 and track 2)
      expect(day.portions.length, 2);
      expect(day.portions[0].book, 'Genesis');
      expect(day.portions[1].book, 'Hebrews');
    }
    
    debugPrint('Multi-track generated 30 days, 2 portions each successfully.');
  });

  test('Edge case: days > total verses (John in 2000 days)', () {
    final plan = generator.generatePlan(
      id: 'john2000',
      title: 'John in 2000 Days',
      tracks: [[
        PlanRange(book: 'John', startChapter: 1, startVerse: 1, endChapter: 21, endVerse: 25)
      ]],
      days: 2000,
      cadence: 7,
    );
    
    int totalWords = wordCountService.wordsInRange('John', 1, 1, 21, 25);
    int maxDays = (totalWords / 130).floor();
    
    debugPrint('John total words: $totalWords');
    debugPrint('John in 2000 days clamped to actual days: ${plan.days}');
    debugPrint('Computed maxDays constraint: $maxDays');
    
    expect(plan.wasClamped, isTrue);
    expect(plan.clampReason, isNotNull);
    expect(plan.days, maxDays);
    expect(plan.schedule.length, plan.days);
    
    // Confirm no empty days
    for (final day in plan.schedule) {
      expect(day.portions, isNotEmpty);
      expect(day.totalWords, greaterThan(0));
    }
  });

  test('Whole Bible in 365 days', () {
    final allBooks = ['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi', 'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation'];
    
    List<PlanRange> ranges = [];
    for (var book in allBooks) {
      final bookP = allPericopes.where((p) => p.book == book).toList();
      if (bookP.isNotEmpty) {
        int endCh = bookP.last.endChapter;
        int endV = bookP.last.endVerse;
        ranges.add(PlanRange(book: book, startChapter: 1, startVerse: 1, endChapter: endCh, endVerse: endV));
      }
    }

    final plan = generator.generatePlan(
      id: 'bible365',
      title: 'Whole Bible in 365 Days',
      tracks: [ranges],
      days: 365,
      cadence: 7,
    );
    
    expect(plan.days, 365);
    int totalWords = 0;
    int totalMins = 0;
    for (final day in plan.schedule) {
      totalWords += day.totalWords;
      totalMins += day.estimatedMinutes;
    }
    debugPrint('Whole Bible 365 Days - Avg words/day: ${(totalWords / 365).round()}, Avg mins/day: ${(totalMins / 365).round()}');
  });

  test('Edge case: Extremely short plan (Whole Bible in 3 days)', () {
    final allBooks = ['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi', 'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation'];
    
    List<PlanRange> ranges = [];
    for (var book in allBooks) {
      // Find max chapter and max verse
      // We can just use large bounds and clamp, but we have maxVerseInChapter
      // For simplicity in test, let's assume we can query pericopes or just pass 1 to 150.
      // Wait, WordCountService has no simple "max chapter" method, but we can just use 1 to 150 and it'll fail if not clamped.
      // Better: we can extract bounds from allPericopes!
      final bookP = allPericopes.where((p) => p.book == book).toList();
      if (bookP.isNotEmpty) {
        int endCh = bookP.last.endChapter;
        int endV = bookP.last.endVerse;
        ranges.add(PlanRange(book: book, startChapter: 1, startVerse: 1, endChapter: endCh, endVerse: endV));
      }
    }

    final plan = generator.generatePlan(
      id: 'bible3',
      title: 'Whole Bible in 3 Days',
      tracks: [ranges],
      days: 3,
      cadence: 7,
    );
    
    expect(plan.days, 3);
    int totalBibleWords = 0;
    for (final day in plan.schedule) {
      debugPrint('Day ${day.dayNumber} words: ${day.totalWords}');
      totalBibleWords += day.totalWords;
      expect(day.totalWords, greaterThan(200000)); // ~263k
    }
    debugPrint('Whole Bible total words in 3-day plan: $totalBibleWords');
  });

  test('Edge case: days = 1', () {
    final plan = generator.generatePlan(
      id: 'gen1',
      title: 'Genesis in 1 Day',
      tracks: [[
        PlanRange(book: 'Genesis', startChapter: 1, startVerse: 1, endChapter: 50, endVerse: 26)
      ]],
      days: 1,
      cadence: 7,
    );
    
    expect(plan.days, 1);
    expect(plan.schedule.length, 1);
    
    final day = plan.schedule.first;
    expect(day.portions.length, 1);
    expect(day.portions.first.startChapter, 1);
    expect(day.portions.first.endChapter, 50);
    debugPrint('Genesis in 1 Day created 1 day with ${day.totalWords} words.');
  });

  test('Edge case: days <= 0', () {
    expect(() => generator.generatePlan(
      id: 'invalid',
      title: 'Invalid Plan',
      tracks: [[
        PlanRange(book: 'Genesis', startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 1)
      ]],
      days: 0,
      cadence: 7,
    ), throwsArgumentError);
  });
}
