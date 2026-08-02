// tool/build_bible_db.dart
// Run once: dart pub global activate sqlite3 && dart run tool/build_bible_db.dart
// Requires: pubspec has sqlite3 dev dep (see tool/pubspec.yaml), and network access.
// Output: assets/bible/bible.db
// NOT bundled in the app; the app never runs this.

import 'dart:convert';
import 'dart:io';

// Uses dart:io HttpClient only -- no package deps required in the tool itself.
// The sqlite3 binary is invoked via the sqlite3 CLI command-line tool.

Future<void> main() async {
  print('=== Bible DB Builder ===\n');

  // We build the SQL as text and pipe it to sqlite3 CLI.
  // This avoids needing a sqlite3 dart package in the main project.
  final dbPath = 'assets/bible/bible.db';
  final sqlPath = '/tmp/build_bible.sql';

  final buf = StringBuffer();

  // ── Schema ──────────────────────────────────────────────────────────
  buf.writeln('PRAGMA journal_mode=WAL;');
  buf.writeln('DROP TABLE IF EXISTS verses;');
  buf.writeln('DROP TABLE IF EXISTS translations;');
  buf.writeln('DROP INDEX IF EXISTS idx_verses;');
  buf.writeln('''
CREATE TABLE verses (
  translation_id TEXT NOT NULL,
  language_code  TEXT NOT NULL,
  book_number    INTEGER NOT NULL,
  chapter        INTEGER NOT NULL,
  verse          INTEGER NOT NULL,
  text           TEXT NOT NULL
);''');
  buf.writeln('''
CREATE TABLE translations (
  translation_id   TEXT PRIMARY KEY,
  language_code    TEXT NOT NULL,
  language_name    TEXT NOT NULL,
  translation_name TEXT NOT NULL,
  abbreviation     TEXT NOT NULL,
  license          TEXT NOT NULL,
  is_complete      INTEGER NOT NULL DEFAULT 0
);''');
  buf.writeln('CREATE INDEX idx_verses ON verses(translation_id, book_number, chapter, verse);');
  buf.writeln('BEGIN TRANSACTION;');

  // ── KJV from local JSON ───────────────────────────────────────────
  print('[KJV] Reading assets/data/kjvbible.json ...');
  final kjvFile = File('assets/data/kjvbible.json');
  if (!kjvFile.existsSync()) {
    stderr.writeln('ERROR: assets/data/kjvbible.json not found. Run from project root.');
    exit(1);
  }

  final kjvJson = jsonDecode(kjvFile.readAsStringSync()) as Map<String, dynamic>;
  final kjvVerses = kjvJson['verses'] as List<dynamic>;

  int kjvCount = 0;
  int kjvMinBook = 999, kjvMaxBook = 0;

  for (final v in kjvVerses) {
    final m = v as Map<String, dynamic>;
    final bookNum = m['book'] as int;
    final chapter = m['chapter'] as int;
    final verse = m['verse'] as int;
    String text = (m['text'] as String)
        .replaceAll('¶ ', '').replaceAll('¶', '');

    // Escape single quotes for SQL
    final escapedText = text.replaceAll("'", "''");
    buf.writeln("INSERT INTO verses VALUES('kjv','en',$bookNum,$chapter,$verse,'$escapedText');");
    kjvCount++;
    if (bookNum < kjvMinBook) kjvMinBook = bookNum;
    if (bookNum > kjvMaxBook) kjvMaxBook = bookNum;
  }

  print('[KJV] $kjvCount verses, books $kjvMinBook–$kjvMaxBook');
  if (kjvMinBook != 1 || kjvMaxBook != 66) {
    stderr.writeln('ERROR: KJV book range $kjvMinBook–$kjvMaxBook != 1–66!');
    exit(1);
  }

  // ── WEB (ENGWEBP) from helloao.org API ───────────────────────────
  print('\n[WEB] Fetching ENGWEBP book list ...');
  final booksData = await _fetchJson('https://bible.helloao.org/api/ENGWEBP/books.json');
  final books = booksData['books'] as List<dynamic>;
  print('[WEB] ${books.length} books found.');

  int webCount = 0;
  int webMinBook = 999, webMaxBook = 0;

  for (final book in books) {
    final bm = book as Map<String, dynamic>;
    final bookId = bm['id'] as String;
    final bookOrder = bm['order'] as int;
    final bookName = bm['name'] as String;
    final numChapters = bm['numberOfChapters'] as int;

    if (bookOrder < webMinBook) webMinBook = bookOrder;
    if (bookOrder > webMaxBook) webMaxBook = bookOrder;

    stdout.write('  [$bookOrder/66] $bookName ($numChapters ch) ... ');
    stdout.flush();

    int bookVerses = 0;
    for (int ch = 1; ch <= numChapters; ch++) {
      final url = 'https://bible.helloao.org/api/ENGWEBP/$bookId/$ch.json';
      final chData = await _fetchJson(url);
      final chapterData = chData['chapter'] as Map<String, dynamic>;
      final content = chapterData['content'] as List<dynamic>;

      for (final item in content) {
        final itemMap = item as Map<String, dynamic>;
        if (itemMap['type'] != 'verse') continue;

        final verseNum = itemMap['number'] as int;
        final verseContent = itemMap['content'] as List<dynamic>;

        final text = verseContent
            .whereType<String>()
            .join('')
            .trim()
            .replaceAll('\u2019', "'")
            .replaceAll('\u2018', "'")
            .replaceAll('\u201c', '"')
            .replaceAll('\u201d', '"')
            .replaceAll('\u2014', '--')
            .replaceAll('\u2013', '-');

        final escapedText = text.replaceAll("'", "''");
        buf.writeln("INSERT INTO verses VALUES('web','en',$bookOrder,$ch,$verseNum,'$escapedText');");
        bookVerses++;
        webCount++;
      }
    }
    print('$bookVerses verses');
  }

  print('\n[WEB] $webCount verses, books $webMinBook–$webMaxBook');
  if (webMinBook != 1 || webMaxBook != 66) {
    stderr.writeln('ERROR: WEB book range $webMinBook–$webMaxBook != 1–66!');
    exit(1);
  }

  // ── translations seed ─────────────────────────────────────────────
  buf.writeln("INSERT OR REPLACE INTO translations VALUES('kjv','en','English','King James Version','KJV','Public Domain',1);");
  buf.writeln("INSERT OR REPLACE INTO translations VALUES('web','en','English','World English Bible','WEB','Public Domain',1);");

  buf.writeln('COMMIT;');
  buf.writeln('.quit');

  // ── Write SQL to temp file and execute ───────────────────────────
  print('\n[DB] Writing SQL ($kjvCount + $webCount = ${kjvCount + webCount} inserts)...');
  File(sqlPath).writeAsStringSync(buf.toString());

  // Remove existing DB if present
  final dbFile = File(dbPath);
  if (dbFile.existsSync()) dbFile.deleteSync();

  print('[DB] Running sqlite3 ...');
  final proc2 = await Process.start('sqlite3', [dbPath]);
  proc2.stdin.add(utf8.encode(buf.toString()));
  await proc2.stdin.close();
  final exitCode = await proc2.exitCode;
  if (exitCode != 0) {
    final err = await proc2.stderr.transform(utf8.decoder).join();
    stderr.writeln('sqlite3 failed (exit $exitCode): $err');
    exit(1);
  }

  final sizeKB = (dbFile.lengthSync() / 1024).toStringAsFixed(1);
  print('\n╔══════════════════════════════════════════╗');
  print('║           BIBLE DB BUILD REPORT          ║');
  print('╠══════════════════════════════════════════╣');
  print('║  KJV:  $kjvCount verses, 66 books          ║');
  print('║  WEB:  $webCount verses, 66 books          ║');
  print('║  File: $dbPath ($sizeKB KB)           ║');
  print('╚══════════════════════════════════════════╝');
  print('\n✅ Done. Genesis=1, Revelation=66 verified by order field.');

  // Cleanup temp
  try { File(sqlPath).deleteSync(); } catch (_) {}
}

Future<Map<String, dynamic>> _fetchJson(String url) async {
  final uri = Uri.parse(url);
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    req.headers.set(HttpHeaders.userAgentHeader, 'blessed-bible-builder/1.0');
    final resp = await req.close();
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} for $url');
    }
    final body = await resp.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  } finally {
    client.close(force: false);
  }
}
