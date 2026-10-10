// ignore_for_file: avoid_print
// tool/build_bible_db.dart
// Run once: dart pub global activate sqlite3 && dart run tool/build_bible_db.dart
// Requires: pubspec has sqlite3 dev dep (see tool/pubspec.yaml), and network access.
// Output: assets/bible/bible.db
// NOT bundled in the app; the app never runs this.

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('=== Bible DB Builder ===\n');

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

    final escapedText = text.replaceAll("'", "''");
    buf.writeln("INSERT INTO verses VALUES('kjv','en',$bookNum,$chapter,$verse,'$escapedText');");
    kjvCount++;
    if (bookNum < kjvMinBook) kjvMinBook = bookNum;
    if (bookNum > kjvMaxBook) kjvMaxBook = bookNum;
  }
  print('[KJV] $kjvCount verses, books $kjvMinBook–$kjvMaxBook');

  // Translations to process from helloao
  final apiTranslations = [
    {'id': 'ENGWEBP', 'db_id': 'web', 'lang': 'en', 'langName': 'English', 'name': 'World English Bible', 'abbr': 'WEB', 'license': 'Public Domain'},
    {'id': 'spa_r09', 'db_id': 'spa_r09', 'lang': 'es', 'langName': 'Spanish', 'name': 'Reina Valera 1909', 'abbr': 'RV1909', 'license': 'Public Domain'},
    {'id': 'fra_lsg', 'db_id': 'fra_lsg', 'lang': 'fr', 'langName': 'French', 'name': 'Louis Segond 1910', 'abbr': 'LSG', 'license': 'Public Domain'},
    {'id': 'deu_l12', 'db_id': 'deu_l12', 'lang': 'de', 'langName': 'German', 'name': 'Luther Bible 1912', 'abbr': 'L1912', 'license': 'Public Domain'},
    {'id': 'ita_dio', 'db_id': 'ita_dio', 'lang': 'it', 'langName': 'Italian', 'name': 'Diodati 1885', 'abbr': 'DIO', 'license': 'Public Domain'},
    {'id': 'ron_btf', 'db_id': 'ron_btf', 'lang': 'ro', 'langName': 'Romanian', 'name': 'Romanian BTF Bible', 'abbr': 'BTF', 'license': 'Public Domain'},
    {'id': 'nld_',    'db_id': 'nld_', 'lang': 'nl', 'langName': 'Dutch', 'name': 'Dutch Bible 1917', 'abbr': 'NLD', 'license': 'Public Domain'},
    {'id': 'swh_ulb', 'db_id': 'swh_ulb', 'lang': 'sw', 'langName': 'Swahili', 'name': 'Swahili Unlocked Literal Bible', 'abbr': 'ULB', 'license': 'CC BY-SA 4.0'},
    {'id': 'tgl_ulb', 'db_id': 'tgl_ulb', 'lang': 'tl', 'langName': 'Tagalog', 'name': 'Tagalog Unlocked Literal Bible', 'abbr': 'ULB', 'license': 'CC BY-SA 4.0'},
    {'id': 'por_blj', 'db_id': 'por_blj', 'lang': 'pt', 'langName': 'Portuguese', 'name': 'Bíblia Livre', 'abbr': 'BLIVRE', 'license': 'CC BY 4.0'},
  ];

  final report = <String, Map<String, dynamic>>{};
  
  for (final t in apiTranslations) {
    final apiId = t['id']!;
    final dbId = t['db_id']!;
    final langCode = t['lang']!;
    
    print('\n[$apiId] Fetching complete json ...');
    
    int tCount = 0;
    int tMinBook = 999;
    int tMaxBook = 0;

    try {
      final completeData = await _fetchJson('https://bible.helloao.org/api/$apiId/complete.json');
      final books = completeData['books'] as List<dynamic>;
      print('[$apiId] ${books.length} books found, inserting verses...');

      for (final book in books) {
        final bm = book as Map<String, dynamic>;
        final bookOrder = bm['order'] as int;

        if (bookOrder < tMinBook) tMinBook = bookOrder;
        if (bookOrder > tMaxBook) tMaxBook = bookOrder;

        final chaptersList = bm['chapters'] as List<dynamic>;

        for (final chWrap in chaptersList) {
          final chMap = chWrap as Map<String, dynamic>;
          final chapterData = chMap['chapter'] as Map<String, dynamic>;
          final ch = chapterData['number'] as int;
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
            buf.writeln("INSERT INTO verses VALUES('$dbId','$langCode',$bookOrder,$ch,$verseNum,'$escapedText');");
            tCount++;
          }
        }
      }
      
      report[apiId] = {
        'count': tCount,
        'minBook': tMinBook,
        'maxBook': tMaxBook,
      };

    } catch (e) {
      print('[$apiId] ERROR: $e');
      exit(1);
    }
  }

  // ── translations seed ─────────────────────────────────────────────
  buf.writeln("INSERT OR REPLACE INTO translations VALUES('kjv','en','English','King James Version','KJV','Public Domain',1);");
  for (final t in apiTranslations) {
    final dbId = t['db_id']!;
    final langCode = t['lang']!;
    final langName = t['langName']!;
    final name = t['name']!.replaceAll("'", "''");
    final abbr = t['abbr']!;
    final license = t['license']!.replaceAll("'", "''");
    
    buf.writeln("INSERT OR REPLACE INTO translations VALUES('$dbId','$langCode','$langName','$name','$abbr','$license',1);");
  }

  buf.writeln('COMMIT;');
  buf.writeln('.quit');

  print('\n[DB] Writing SQL to $sqlPath ...');
  File(sqlPath).writeAsStringSync(buf.toString());

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

  final sizeMB = (dbFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
  print('\n╔══════════════════════════════════════════╗');
  print('║           BIBLE DB BUILD REPORT          ║');
  print('╠══════════════════════════════════════════╣');
  print('║  KJV:  $kjvCount verses, books $kjvMinBook-$kjvMaxBook          ║');
  for (final t in apiTranslations) {
    final id = t['id']!;
    final r = report[id]!;
    final padId = id.padRight(8);
    print('║  $padId: ${r['count']} verses, books ${r['minBook']}-${r['maxBook']}    ║');
  }
  print('║  File: $dbPath ($sizeMB MB)           ║');
  print('╚══════════════════════════════════════════╝');
  print('\n✅ Done. Verified canonical normalizations.');

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
