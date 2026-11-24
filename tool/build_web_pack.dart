// ignore_for_file: avoid_print
// tool/build_web_pack.dart
// Builds assets/packs/web.db — the World English Bible as a bundled pack.
//
// The chapter audio in the app is the WEB narration, so WEB ships with the
// app: read-along has text to follow even with no connection, on a fresh
// install. Same schema as TranslationPackStore writes for downloaded packs.
//
// Run from the project root: fvm dart tool/build_web_pack.dart
// Requires network access and the `sqlite3` CLI. The app never runs this.

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  const outPath = 'assets/packs/web.db';
  const apiId = 'ENGWEBP';
  const dbId = 'web';

  print('=== WEB pack builder ===');
  final data = await _fetchJson(
      'https://bible.helloao.org/api/$apiId/complete.json');
  final books = data['books'] as List<dynamic>;
  print('[$apiId] ${books.length} books');

  final buf = StringBuffer();
  buf.writeln('PRAGMA journal_mode=DELETE;');
  buf.writeln('DROP TABLE IF EXISTS verses;');
  buf.writeln('DROP TABLE IF EXISTS translations;');
  buf.writeln('DROP INDEX IF EXISTS idx_verses_pack;');
  buf.writeln('''CREATE TABLE verses (
  translation_id TEXT NOT NULL,
  language_code  TEXT NOT NULL,
  book_number    INTEGER NOT NULL,
  chapter        INTEGER NOT NULL,
  verse          INTEGER NOT NULL,
  text           TEXT NOT NULL
);''');
  buf.writeln('''CREATE TABLE translations (
  translation_id   TEXT PRIMARY KEY,
  language_code    TEXT NOT NULL,
  language_name    TEXT NOT NULL,
  translation_name TEXT NOT NULL,
  abbreviation     TEXT NOT NULL,
  license          TEXT NOT NULL,
  is_complete      INTEGER NOT NULL DEFAULT 0,
  is_downloaded    INTEGER NOT NULL DEFAULT 0
);''');
  buf.writeln('BEGIN TRANSACTION;');

  var count = 0;
  var minBook = 999;
  var maxBook = 0;
  for (final book in books) {
    final bm = book as Map<String, dynamic>;
    final bookOrder = bm['order'] as int;
    if (bookOrder < minBook) minBook = bookOrder;
    if (bookOrder > maxBook) maxBook = bookOrder;
    for (final chWrap in bm['chapters'] as List<dynamic>) {
      final chapterData =
          (chWrap as Map<String, dynamic>)['chapter'] as Map<String, dynamic>;
      final chapter = chapterData['number'] as int;
      for (final item in chapterData['content'] as List<dynamic>) {
        final itemMap = item as Map<String, dynamic>;
        if (itemMap['type'] != 'verse') continue;
        final verse = itemMap['number'] as int;
        final text = _verseText(itemMap['content'] as List<dynamic>);
        buf.writeln(
            "INSERT INTO verses VALUES('$dbId','en',$bookOrder,$chapter,$verse,'${text.replaceAll("'", "''")}');");
        count++;
      }
    }
  }

  buf.writeln(
      "INSERT OR REPLACE INTO translations VALUES('$dbId','en','English','World English Bible','WEB','Public Domain',1,1);");
  buf.writeln(
      'CREATE INDEX idx_verses_pack ON verses(book_number, chapter, verse);');
  buf.writeln('COMMIT;');

  final file = File(outPath);
  await file.parent.create(recursive: true);
  if (await file.exists()) await file.delete();

  final proc = await Process.start('sqlite3', [outPath]);
  proc.stdin.add(utf8.encode(buf.toString()));
  await proc.stdin.close();
  final code = await proc.exitCode;
  if (code != 0) {
    final err = await proc.stderr.transform(utf8.decoder).join();
    stderr.writeln('sqlite3 failed ($code): $err');
    exit(1);
  }

  final mb = (await file.length()) / (1024 * 1024);
  print('[$dbId] $count verses, books $minBook-$maxBook, '
      '${mb.toStringAsFixed(2)} MB -> $outPath');
}

/// A verse's text. helloao splits verses into strings, `{text: ...}` spans
/// (which carry `wordsOfJesus`), notes and line breaks; the text spans are
/// joined and whitespace is normalised so a split mid-sentence does not glue
/// two words together.
String _verseText(List<dynamic> content) {
  final pieces = <String>[];
  for (final part in content) {
    if (part is String) {
      pieces.add(part);
    } else if (part is Map && part['text'] is String) {
      pieces.add(part['text'] as String);
    }
  }
  return pieces
      .join(' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll('\u2019', "'")
      .replaceAll('\u2018', "'")
      .replaceAll('\u201c', '"')
      .replaceAll('\u201d', '"')
      .replaceAll('\u2014', '--')
      .replaceAll('\u2013', '-');
}

Future<Map<String, dynamic>> _fetchJson(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
    }
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}
