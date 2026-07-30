// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures
// tool/generate_reading_plan.dart
//
// Usage: dart run tool/generate_reading_plan.dart
//
// Reads:  assets/reading_plans/source/chronological_guthrie.md
// Writes: assets/reading_plans/chronological_1yr.json
//
// RANGE-IN-LIST CHOICE: chapter ranges inside comma lists are EXPANDED.
//   e.g. "Psa 140-142" inside a comma list → refs: ["Psalms 140","Psalms 141","Psalms 142"]
//   This is consistent with standalone ranges and is most useful for per-chapter navigation.

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Canonical book name map
//
// Keys  = lowercased abbreviations AND full canonical names (as used in source).
// Values = EXACT strings from assets/bible/kjv.json (cross-checked before finalising).
//
// Full canonical names are included first so that source lines that spell the
// book out fully (e.g. "John 1:1-3", "Ruth 1-4", "Joel 1-3") resolve correctly.
// Short abbreviations that would be identical to a full-name key are omitted
// to prevent Dart const-map duplicate-key errors.
//
// Critical ambiguities (burned before — documented explicitly):
//   Psa / Pss → "Psalms" (with 's', NOT "Psalm")
//   Jon       → "Jonah" (NOT John — John is Joh / jo)
//   Phi / Ph  → "Philippians" (NOT Philemon — Philemon is Phm)
//   Jud       → "Judges" (NOT Jude — Jude is the full word "jude")
// ---------------------------------------------------------------------------
const Map<String, String> _bookMap = {
  // ---- Full canonical names (lowercase) — source may spell these out in full ----
  'genesis':          'Genesis',
  'exodus':           'Exodus',
  'leviticus':        'Leviticus',
  'numbers':          'Numbers',
  'deuteronomy':      'Deuteronomy',
  'joshua':           'Joshua',
  'judges':           'Judges',
  'ruth':             'Ruth',
  '1 samuel':         '1 Samuel',
  '2 samuel':         '2 Samuel',
  '1 kings':          '1 Kings',
  '2 kings':          '2 Kings',
  '1 chronicles':     '1 Chronicles',
  '2 chronicles':     '2 Chronicles',
  'ezra':             'Ezra',
  'nehemiah':         'Nehemiah',
  'esther':           'Esther',
  'job':              'Job',
  'psalms':           'Psalms',
  'psalm':            'Psalms',      // defensive alias
  'proverbs':         'Proverbs',
  'ecclesiastes':     'Ecclesiastes',
  'song of solomon':  'Song of Solomon',
  'isaiah':           'Isaiah',
  'jeremiah':         'Jeremiah',
  'lamentations':     'Lamentations',
  'ezekiel':          'Ezekiel',
  'daniel':           'Daniel',
  'hosea':            'Hosea',
  'joel':             'Joel',
  'amos':             'Amos',
  'obadiah':          'Obadiah',
  'jonah':            'Jonah',
  'micah':            'Micah',
  'nahum':            'Nahum',
  'habakkuk':         'Habakkuk',
  'zephaniah':        'Zephaniah',
  'haggai':           'Haggai',
  'zechariah':        'Zechariah',
  'malachi':          'Malachi',
  'matthew':          'Matthew',
  'mark':             'Mark',
  'luke':             'Luke',
  'john':             'John',
  'acts':             'Acts',
  'romans':           'Romans',
  '1 corinthians':    '1 Corinthians',
  '2 corinthians':    '2 Corinthians',
  'galatians':        'Galatians',
  'ephesians':        'Ephesians',
  'philippians':      'Philippians',
  'colossians':       'Colossians',
  '1 thessalonians':  '1 Thessalonians',
  '2 thessalonians':  '2 Thessalonians',
  '1 timothy':        '1 Timothy',
  '2 timothy':        '2 Timothy',
  'titus':            'Titus',
  'philemon':         'Philemon',
  'hebrews':          'Hebrews',
  'james':            'James',
  '1 peter':          '1 Peter',
  '2 peter':          '2 Peter',
  '1 john':           '1 John',
  '2 john':           '2 John',
  '3 john':           '3 John',
  'jude':             'Jude',
  'revelation':       'Revelation',

  // ---- Short abbreviations (those not identical to a full-name key above) ----

  // Pentateuch
  'gen':   'Genesis',
  'exo':   'Exodus',
  'lev':   'Leviticus',
  'num':   'Numbers',
  'deu':   'Deuteronomy',

  // History
  'jos':   'Joshua',
  'jdg':   'Judges',
  'jud':   'Judges',    // abbrev for Judges; "jude" (full word) → Jude above
  'rth':   'Ruth',
  'rut':   'Ruth',
  '1sm':   '1 Samuel',
  '1sam':  '1 Samuel',
  '1 sam': '1 Samuel',
  '2sm':   '2 Samuel',
  '2sam':  '2 Samuel',
  '2 sam': '2 Samuel',
  '1ki':   '1 Kings',
  '1kgs':  '1 Kings',
  '1 ki':  '1 Kings',
  '2ki':   '2 Kings',
  '2kgs':  '2 Kings',
  '2 ki':  '2 Kings',
  '1ch':   '1 Chronicles',
  '1chr':  '1 Chronicles',
  '1 chr': '1 Chronicles',
  '2ch':   '2 Chronicles',
  '2chr':  '2 Chronicles',
  '2 chr': '2 Chronicles',
  'ezr':   'Ezra',
  'ne':    'Nehemiah',
  'neh':   'Nehemiah',
  'est':   'Esther',
  'et':    'Esther',

  // Poetry
  'psa':   'Psalms',   // CRITICAL: "Psalms" with the 's'
  'pss':   'Psalms',
  'pro':   'Proverbs',
  'prv':   'Proverbs',
  'ecc':   'Ecclesiastes',
  'ec':    'Ecclesiastes',
  'song':  'Song of Solomon',
  'so':    'Song of Solomon',
  'sol':   'Song of Solomon',

  // Major Prophets
  'isa':   'Isaiah',
  'is':    'Isaiah',
  'jer':   'Jeremiah',
  'jr':    'Jeremiah',
  'lam':   'Lamentations',
  'lm':    'Lamentations',
  'eze':   'Ezekiel',
  'ez':    'Ezekiel',
  'dan':   'Daniel',
  'dn':    'Daniel',

  // Minor Prophets
  'hos':   'Hosea',
  'ho':    'Hosea',
  'joe':   'Joel',
  'jl':    'Joel',
  'amo':   'Amos',
  'am':    'Amos',
  'oba':   'Obadiah',
  'ob':    'Obadiah',
  'jon':   'Jonah',    // CRITICAL: Jon=Jonah; John is Joh
  'jnh':   'Jonah',
  'mic':   'Micah',
  'mi':    'Micah',
  'nah':   'Nahum',
  'na':    'Nahum',
  'hab':   'Habakkuk',
  'hk':    'Habakkuk',
  'zep':   'Zephaniah',
  'zp':    'Zephaniah',
  'hag':   'Haggai',
  'hg':    'Haggai',
  'zec':   'Zechariah',
  'zc':    'Zechariah',
  'mal':   'Malachi',
  'ml':    'Malachi',

  // Gospels & Acts
  'mat':   'Matthew',
  'mt':    'Matthew',
  'mar':   'Mark',
  'mk':    'Mark',
  'luk':   'Luke',
  'lk':    'Luke',
  'joh':   'John',     // CRITICAL: Joh=John; Jonah is Jon
  'jo':    'John',
  'act':   'Acts',

  // Epistles
  'rom':   'Romans',
  'rm':    'Romans',
  '1co':   '1 Corinthians',
  '1cor':  '1 Corinthians',
  '1 cor': '1 Corinthians',
  '2co':   '2 Corinthians',
  '2cor':  '2 Corinthians',
  '2 cor': '2 Corinthians',
  'gal':   'Galatians',
  'gl':    'Galatians',
  'eph':   'Ephesians',
  'phi':   'Philippians', // CRITICAL: Phi=Philippians; Philemon is Phm
  'ph':    'Philippians',
  'phl':   'Philippians',
  'col':   'Colossians',
  'cl':    'Colossians',
  '1th':   '1 Thessalonians',
  '1 th':  '1 Thessalonians',
  '1ts':   '1 Thessalonians',
  '2th':   '2 Thessalonians',
  '2 th':  '2 Thessalonians',
  '2ts':   '2 Thessalonians',
  '1ti':   '1 Timothy',
  '1tm':   '1 Timothy',
  '1tim':  '1 Timothy',
  '1 tim': '1 Timothy',
  '2ti':   '2 Timothy',
  '2tm':   '2 Timothy',
  '2tim':  '2 Timothy',
  '2 tim': '2 Timothy',
  'tit':   'Titus',
  'tt':    'Titus',
  'phm':   'Philemon',   // CRITICAL: Phm=Philemon; Philippians is Phi
  'heb':   'Hebrews',
  'hb':    'Hebrews',
  'jam':   'James',
  'jm':    'James',
  '1pe':   '1 Peter',
  '1pet':  '1 Peter',
  '1 pe':  '1 Peter',
  '2pe':   '2 Peter',
  '2pet':  '2 Peter',
  '2 pe':  '2 Peter',
  '1jo':   '1 John',
  '1joh':  '1 John',
  '1 joh': '1 John',
  '2jo':   '2 John',
  '2joh':  '2 John',
  '2 joh': '2 John',
  '3jo':   '3 John',
  '3joh':  '3 John',
  '3 joh': '3 John',
  'jde':   'Jude',
  'rev':   'Revelation',
  're':    'Revelation',
};

// ---------------------------------------------------------------------------
// Canonical name set — for final validation of every generated ref.
// Exact strings from assets/bible/kjv.json.
// ---------------------------------------------------------------------------
const Set<String> _canonicalNames = {
  'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
  'Joshua', 'Judges', 'Ruth',
  '1 Samuel', '2 Samuel', '1 Kings', '2 Kings',
  '1 Chronicles', '2 Chronicles',
  'Ezra', 'Nehemiah', 'Esther',
  'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon',
  'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel',
  'Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah', 'Micah',
  'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
  'Matthew', 'Mark', 'Luke', 'John', 'Acts',
  'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians',
  'Philippians', 'Colossians',
  '1 Thessalonians', '2 Thessalonians',
  '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews',
  'James', '1 Peter', '2 Peter',
  '1 John', '2 John', '3 John', 'Jude', 'Revelation',
};

// ---------------------------------------------------------------------------
// Resolve an abbreviation to a canonical full book name.
// Returns '!!UNMAPPED:<abbrev>' if not found — caught by validation.
// ---------------------------------------------------------------------------
String resolveBook(String abbrev) {
  final key = abbrev.trim().toLowerCase();
  return _bookMap[key] ?? '!!UNMAPPED:$key';
}

// ---------------------------------------------------------------------------
// Convert a chapter/verse string + canonical book name to a list of refs.
//
//   bookName: canonical full name (already resolved)
//   chapStr:  the portion after the book name, already trimmed, e.g.:
//               "1-2"        → ["Genesis 1","Genesis 2"]
//               "8"          → ["Psalms 8"]
//               "1:1-3"      → ["John 1:1-3"]   (verse-level → 1 ref)
//               "5:11-6:23"  → ["2 Samuel 5:11-6:23"]  (cross-chapter verse → 1 ref)
//               "140-142"    → ["Psalms 140","Psalms 141","Psalms 142"]  (expanded)
// ---------------------------------------------------------------------------
List<String> _chapRangeToRefs(String bookName, String chapStr) {
  chapStr = chapStr.trim();
  if (chapStr.isEmpty) return [bookName];

  // Verse-level reference contains ':' → keep as single ref
  if (chapStr.contains(':')) {
    return ['$bookName $chapStr'];
  }

  // Pure chapter range e.g. "1-2", "140-142"
  if (chapStr.contains('-')) {
    final parts = chapStr.split('-');
    if (parts.length == 2) {
      final start = int.tryParse(parts[0].trim());
      final end   = int.tryParse(parts[1].trim());
      if (start != null && end != null && end >= start) {
        return [for (int c = start; c <= end; c++) '$bookName $c'];
      }
    }
  }

  // Single chapter number
  final ch = int.tryParse(chapStr);
  if (ch != null) return ['$bookName $ch'];

  // Fallback
  return ['$bookName $chapStr'];
}

// ---------------------------------------------------------------------------
// Parse one passage token (already split from a day string on ';').
//
// Examples of full tokens handled:
//   "Gen 1-2"              → label="Gen 1-2",       refs=["Genesis 1","Genesis 2"]
//   "Psa 8, 104"           → label="Psa 8, 104",    refs=["Psalms 8","Psalms 104"]
//   "John 1:1-3"           → label="John 1:1-3",    refs=["John 1:1-3"]
//   "2 Sam 5:11-6:23"      → label="2 Sam 5:11-6:23", refs=["2 Samuel 5:11-6:23"]
//   "Psa 140-142"          → label="Psa 140-142",   refs=["Psalms 140","Psalms 141","Psalms 142"]
//   "Oba"                  → label="Oba",            refs=["Obadiah"]
//   "Ruth 1-4"             → label="Ruth 1-4",       refs=["Ruth 1","Ruth 2","Ruth 3","Ruth 4"]
//   "1 Chr 10"             → label="1 Chr 10",       refs=["1 Chronicles 10"]
// ---------------------------------------------------------------------------
Map<String, dynamic> parsePassageToken(String token) {
  token = token.trim();
  final label = token; // preserve raw label exactly

  // Regex: optional leading digit+space for numbered books (e.g. "1 ", "2 ", "3 "),
  // then the alpha abbreviation, then optional whitespace + chapter/verse portion.
  //
  // Group 1: optional leading digit(s), e.g. "1"
  // Group 2: the alpha part, e.g. "Sam", "Chr", "Joh", "Gen"
  // Group 3: everything after (chapters/verses, may contain commas)
  final re = RegExp(r'^(\d)\s+([A-Za-z]+)\s*(.*)$');
  final m  = re.firstMatch(token);

  String abbrevKey;
  String rest;

  if (m != null) {
    // Numbered book: e.g. "1 Sam 1-4", "2 Chr 10", "1 Joh 1-5"
    final digit = m.group(1)!;
    final alpha = m.group(2)!;
    rest        = (m.group(3) ?? '').trim();
    abbrevKey   = '$digit ${alpha.toLowerCase()}'; // e.g. "1 sam", "2 chr"
  } else {
    // Non-numbered book: e.g. "Gen 1-2", "Psa 8, 104", "John 1:1-3", "Oba"
    final re2 = RegExp(r'^([A-Za-z]+)\s*(.*)$');
    final m2  = re2.firstMatch(token);
    if (m2 == null) {
      return {'label': label, 'refs': <String>[label]};
    }
    abbrevKey = m2.group(1)!.toLowerCase(); // e.g. "gen", "psa", "john"
    rest      = (m2.group(2) ?? '').trim();
  }

  final bookName = resolveBook(abbrevKey);

  if (rest.isEmpty) {
    // No chapter/verse portion: single-chapter book or bare book name
    return {'label': label, 'refs': <String>[bookName]};
  }

  // Split rest on ',' → multiple chapter refs for the same book
  // e.g. "8, 104" → ["8","104"] → each processed individually
  final segments = rest.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  final List<String> refs = [];
  for (final seg in segments) {
    refs.addAll(_chapRangeToRefs(bookName, seg));
  }

  return {'label': label, 'refs': refs};
}

// ---------------------------------------------------------------------------
// Parse a full day string into a list of passage objects.
// Splits on ';', processes each token.
// ---------------------------------------------------------------------------
List<Map<String, dynamic>> parseDayString(String dayStr) {
  return dayStr
      .split(';')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map(parsePassageToken)
      .toList();
}

// ---------------------------------------------------------------------------
// Validate that every ref starts with a canonical book name.
// Returns a set of any non-canonical prefixes found.
// ---------------------------------------------------------------------------
Set<String> validateRefs(List<Map<String, dynamic>> readings) {
  final bad = <String>{};
  for (final r in readings) {
    for (final p in (r['passages'] as List<Map<String, dynamic>>)) {
      for (final ref in (p['refs'] as List<String>)) {
        bool found = false;
        for (final canonical in _canonicalNames) {
          if (ref == canonical || ref.startsWith('$canonical ')) {
            found = true;
            break;
          }
        }
        if (!found) bad.add(ref);
      }
    }
  }
  return bad;
}

// ---------------------------------------------------------------------------
// Main generator
// ---------------------------------------------------------------------------
void main() async {
  const sourcePath = 'assets/reading_plans/source/chronological_guthrie.md';
  const outputPath = 'assets/reading_plans/chronological_1yr.json';

  final sourceFile = File(sourcePath);
  if (!sourceFile.existsSync()) {
    stderr.writeln('ERROR: Source file not found: $sourcePath');
    exit(1);
  }

  final lines = sourceFile.readAsLinesSync();

  // -------------------------------------------------------------------------
  // Parse the source file into week blocks
  // -------------------------------------------------------------------------
  int? currentWeek;
  String? currentTheme;
  final Map<int, String> currentDays = {}; // 1–6 → raw day string

  final List<Map<String, dynamic>> readings = [];
  int globalDay = 0; // sequential 1–312 across all weeks

  void flushWeek() {
    if (currentWeek == null || currentTheme == null) return;
    for (int d = 1; d <= 6; d++) {
      if (!currentDays.containsKey(d)) {
        stderr.writeln('WARNING: Week $currentWeek missing D$d');
        continue;
      }
      globalDay++;
      final passages = parseDayString(currentDays[d]!);
      readings.add({
        'day':      globalDay,
        'week':     currentWeek,
        'title':    currentTheme,
        'passages': passages,
      });
    }
    currentDays.clear();
  }

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    if (line.startsWith('Week:')) {
      flushWeek();
      currentWeek = int.parse(line.substring(5).trim());
      currentTheme = null;
    } else if (line.startsWith('Theme:')) {
      currentTheme = line.substring(6).trim();
    } else {
      final m = RegExp(r'^D([1-6]):\s*(.+)$').firstMatch(line);
      if (m != null) {
        currentDays[int.parse(m.group(1)!)] = m.group(2)!.trim();
      }
    }
  }
  flushWeek();

  // -------------------------------------------------------------------------
  // Build output JSON
  // -------------------------------------------------------------------------
  final output = {
    'id':            'chronological_1yr',
    'title':         'Chronological Bible in a Year',
    'description':   'Read the Bible in the order events occurred.',
    'framework':     'Guthrie – Read the Bible for Life',
    'totalReadings': readings.length,
    'daysPerWeek':   6,
    'readings':      readings,
  };

  // -------------------------------------------------------------------------
  // Validation
  // -------------------------------------------------------------------------
  print('');
  print('=== VALIDATION REPORT ===');
  print('');
  print('totalReadings : ${readings.length}  (expected 312)');
  final weeksFound = readings.map((r) => r['week'] as int).toSet().length;
  print('weeks found   : $weeksFound  (expected 52)');

  // Contiguous days
  final days = readings.map((r) => r['day'] as int).toList()..sort();
  var contiguous = true;
  for (int i = 0; i < days.length; i++) {
    if (days[i] != i + 1) { contiguous = false; break; }
  }
  print('days contiguous 1..${readings.length}: $contiguous');

  // 52 weeks × 6 days
  final weekCounts = <int, int>{};
  for (final r in readings) {
    final w = r['week'] as int;
    weekCounts[w] = (weekCounts[w] ?? 0) + 1;
  }
  final badWeeks = weekCounts.entries.where((e) => e.value != 6).toList();
  if (badWeeks.isEmpty) {
    print('52 weeks × 6 days each: ✓');
  } else {
    print('BAD WEEK COUNTS: $badWeeks');
  }

  // Unmapped / non-canonical refs
  final badRefs = validateRefs(readings);
  if (badRefs.isEmpty) {
    print('');
    print('Unmapped / non-canonical refs: none ✓');
  } else {
    print('');
    print('NON-CANONICAL REFS (must fix):');
    for (final r in badRefs.toList()..sort()) print('  $r');
  }

  // -------------------------------------------------------------------------
  // Spot checks
  // -------------------------------------------------------------------------
  print('');
  print('=== SPOT CHECKS ===');
  _printDay(readings, 1,   'Day 1');
  _printDay(readings, 8,   'Day 8');
  _printDay(readings, 44,  'Day 44');
  _printWeekDay(readings, 15, 3, 'Week 15 D3  (Psa 7,27,31,34,52)');
  _printWeekDay(readings, 45, 2, 'Week 45 D2  (multi-Gospel harmony)');
  _printDay(readings, 312, 'Day 312');

  // -------------------------------------------------------------------------
  // Write output JSON
  // -------------------------------------------------------------------------
  File(outputPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(output));
  print('');
  print('Output written → $outputPath');
  print('');
}

void _printDay(List<Map<String, dynamic>> readings, int day, String label) {
  final r = readings.firstWhere((r) => r['day'] == day, orElse: () => {});
  if (r.isEmpty) { print('$label: NOT FOUND'); return; }
  print('$label — Week ${r['week']}, "${r['title']}"');
  for (final p in (r['passages'] as List)) {
    print('  label="${p['label']}", refs=${(p['refs'] as List).join(' | ')}');
  }
}

void _printWeekDay(List<Map<String, dynamic>> readings, int week, int dayInWeek, String label) {
  final weekR = readings.where((r) => r['week'] == week).toList()
    ..sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
  if (dayInWeek < 1 || dayInWeek > weekR.length) {
    print('$label: NOT FOUND'); return;
  }
  final r = weekR[dayInWeek - 1];
  print('$label (global Day ${r['day']}) — Week ${r['week']}, "${r['title']}"');
  for (final p in (r['passages'] as List)) {
    print('  label="${p['label']}", refs=${(p['refs'] as List).join(' | ')}');
  }
}
