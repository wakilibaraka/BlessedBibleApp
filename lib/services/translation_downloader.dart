import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../data/models/translation_model.dart';
import 'bible_database_service.dart';

class TranslationDownloader {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// Free Use Bible API (bible.helloao.org): free, no key, texts sourced
  /// from eBible.org. Each translation is one `complete.json` file.
  static const String _helloaoApi = 'https://bible.helloao.org/api';

  /// KJV with Strong's isn't on the Free Use Bible API; it's served from
  /// this repository's Git LFS copy (content_packs/) and hash-verified.
  static const String _repoPacksBase =
      'https://media.githubusercontent.com/media/wakilibaraka/BlessedBibleApp/main/content_packs';

  /// Public-domain OSIS texts from seven1m/open-bibles, pinned to a commit
  /// so the bytes never change under the recorded sha256.
  static const String _openBiblesBase =
      'https://raw.githubusercontent.com/seven1m/open-bibles/f257a3559025c3f873b48a75019f53a9354ed7de';

  // Downloadable translation definitions. `id` is the download id (the
  // API's translation id); `db_id` the on-device id when it differs.
  // CI verifies every helloao id resolves (tool/check_translation_sources.py).
  static final List<Map<String, dynamic>> downloadableTranslations = [
    ..._helloao('rus_syn', 'ru', 'Russian', 'Russian Synodal Bible', 'SYN',
        'Public Domain', 5.3),
    ..._helloao('cmn_cuv', 'zh', 'Chinese', 'Chinese Union Version', 'CUV',
        'Public Domain', 2.4),
    ..._helloao('arb_vdv', 'ar', 'Arabic', 'Arabic Van Dyck Bible', 'VDV',
        'Public Domain', 7.1),
    ..._helloao('kor_old', 'ko', 'Korean', 'Korean Bible 1910', 'KOR',
        'Public Domain', 4.2),
    ..._helloao('ukr_pan', 'uk', 'Ukrainian', 'Ukrainian Bible by P. Kulish',
        'UKR', 'Public Domain', 5.4),
    ..._helloao('HINIRV', 'hi', 'Hindi', 'Hindi Indian Revised Version', 'IRV',
        'CC BY-SA 4.0', 8.0,
        dbId: 'hinirv'),
    ..._helloao('ENGWEBP', 'en', 'English', 'World English Bible', 'WEB',
        'Public Domain', 5.0,
        dbId: 'web'),
    ..._helloao('deu_l12', 'de', 'German', 'Luther Bible 1912', 'L1912',
        'Public Domain', 4.9),
    ..._helloao(
        'nld_', 'nl', 'Dutch', 'Dutch Bible 1917', 'NLD', 'Public Domain', 5.3),
    ..._helloao('por_blj', 'pt', 'Portuguese', 'Bíblia Livre', 'BLIVRE',
        'CC BY 4.0', 5.0),
    ..._helloao('spa_r09', 'es', 'Spanish', 'Reina Valera 1909', 'RV1909',
        'Public Domain', 5.0),
    ..._helloao('pol_ubg', 'pl', 'Polish', 'Updated Gdańsk Bible', 'UBG',
        'CC BY-ND 4.0', 5.0),
    ..._helloao('ces_bkr', 'cs', 'Czech', 'Kralice Bible 1613', 'BKR',
        'Public Domain', 5.0),
    // Not on the Free Use Bible API: public-domain OSIS from
    // github.com/seven1m/open-bibles, pinned to a commit and hash-checked.
    {
      'id': 'hun_kar',
      'lang': 'hu',
      'langName': 'Hungarian',
      'name': 'Károli Bible',
      'abbr': 'KAR',
      'license': 'Public Domain',
      'sizeMB': 5.3,
      'source': 'osis',
      'url': '$_openBiblesBase/hun-karoli.osis.xml',
      'sha256':
          '91f9b0c1447d96400a1cc0e7200eb37f74570b323a71ee16c497d681cd55b863',
      'fixLegacyHungarian': true,
    },
    {
      'id': 'kjv_strongs',
      'lang': 'en',
      'langName': 'English',
      'name': "KJV with Strong's",
      'abbr': 'KJVS',
      'license': 'Public Domain',
      'sizeMB': 7.7,
      'source': 'prebuilt',
      'url': '$_repoPacksBase/kjv_strongs.db',
      'sha256':
          '1adece5cf1de520059216e1aaef8cd94ea268966570353e776546d8034425cfa',
    },
    // Bundled packs the user deleted: restored from the APK (instant,
    // offline) instead of downloaded. Sizes measured from built packs.
    {
      'id': 'swh_ulb',
      'lang': 'sw',
      'langName': 'Swahili',
      'name': 'Swahili Unlocked Literal Bible',
      'abbr': 'ULB',
      'license': 'CC BY-SA 4.0',
      'sizeMB': 5.0,
      'source': 'bundled',
    },
    {
      'id': 'tgl_ulb',
      'lang': 'tl',
      'langName': 'Tagalog',
      'name': 'Tagalog Unlocked Literal Bible',
      'abbr': 'ULB',
      'license': 'CC BY-SA 4.0',
      'sizeMB': 6.0,
      'source': 'bundled',
    },
    {
      'id': 'ita_dio',
      'lang': 'it',
      'langName': 'Italian',
      'name': 'Diodati 1885',
      'abbr': 'DIO',
      'license': 'Public Domain',
      'sizeMB': 4.9,
      'source': 'bundled',
    },
    {
      'id': 'fra_lsg',
      'lang': 'fr',
      'langName': 'French',
      'name': 'Louis Segond 1910',
      'abbr': 'LSG',
      'license': 'Public Domain',
      'sizeMB': 4.1,
      'source': 'bundled',
    },
  ];

  /// Registry entry for one Free Use Bible API translation.
  static List<Map<String, dynamic>> _helloao(
    String id,
    String lang,
    String langName,
    String name,
    String abbr,
    String license,
    double sizeMB, {
    String? dbId,
  }) {
    return [
      {
        'id': id,
        if (dbId != null) 'db_id': dbId,
        'lang': lang,
        'langName': langName,
        'name': name,
        'abbr': abbr,
        'license': license,
        'sizeMB': sizeMB,
        'source': 'helloao',
        'url': '$_helloaoApi/$id/complete.json',
      }
    ];
  }

  static Future<void> downloadAndInstall(
      String translationId, void Function(double) onProgress) async {
    final meta = downloadableTranslations
        .firstWhere((t) => (t['db_id'] ?? t['id']) == translationId);
    final tid = (meta['db_id'] ?? meta['id']) as String;
    final expectedSha256 = meta['sha256'] as String?;

    final bytes = await _fetchBytes(meta['url'] as String,
        ((meta['sizeMB'] as num) * 1024 * 1024).toInt(), onProgress);
    onProgress(1.0); // Verifying + installing

    // Prebuilt pack database: exact bytes, hash-verified by the pack store.
    if (meta['source'] == 'prebuilt') {
      await bibleDbService.installPrebuiltPack(tid, bytes,
          expectedSha256: expectedSha256);
      return;
    }

    if (expectedSha256 != null &&
        sha256.convert(bytes).toString() != expectedSha256) {
      throw StateError('Download of $tid failed integrity check.');
    }

    // Parse in an isolate to keep the UI responsive.
    final text = utf8.decode(bytes);
    final parsed = await Isolate.run(() => _parse(text, meta));
    await bibleDbService.insertTranslationPack(parsed.info, parsed.verses);
  }

  /// GETs [url] with retries, reporting progress against the
  /// Content-Length (or [expectedBytes] when the server omits it).
  static Future<List<int>> _fetchBytes(
      String url, int expectedBytes, void Function(double) onProgress) async {
    Exception? lastError;
    for (int i = 0; i < _maxRetries; i++) {
      try {
        final response = await http.Request('GET', Uri.parse(url)).send();
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        final total = response.contentLength ?? expectedBytes;
        final bytes = <int>[];
        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          onProgress((bytes.length / total).clamp(0.0, 1.0));
        }
        return bytes;
      } on Exception catch (e) {
        lastError = e;
        if (i < _maxRetries - 1) {
          await Future<void>.delayed(_retryDelay * (i + 1));
        }
      }
    }
    throw lastError ?? Exception('Download failed');
  }

  // Runs in an isolate
  static _ParsedData _parse(String text, Map<String, dynamic> meta) {
    final info = TranslationInfo(
      translationId: (meta['db_id'] ?? meta['id']) as String,
      languageCode: meta['lang'] as String,
      languageName: meta['langName'] as String,
      translationName: meta['name'] as String,
      abbreviation: meta['abbr'] as String,
      license: meta['license'] as String,
      isComplete: true,
      isDownloaded: true,
    );
    final verses = meta['source'] == 'osis'
        ? versesFromOsis(
            text,
            translationId: info.translationId,
            languageCode: info.languageCode,
            fixLegacyHungarian: meta['fixLegacyHungarian'] == true,
          )
        : versesFromCompleteJson(
            jsonDecode(text) as Map<String, dynamic>,
            translationId: info.translationId,
            languageCode: info.languageCode,
          );
    if (verses.length < 30000) {
      throw StateError('${info.translationId}: incomplete download '
          '(${verses.length} verses)');
    }
    return _ParsedData(info, verses);
  }

  /// Protestant canon in order, by USFM book id (book_number = index + 1).
  static const List<String> _usfmBooks = [
    'GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT', '1SA', '2SA', //
    '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH', 'EST', 'JOB', 'PSA', 'PRO',
    'ECC', 'SNG', 'ISA', 'JER', 'LAM', 'EZK', 'DAN', 'HOS', 'JOL', 'AMO',
    'OBA', 'JON', 'MIC', 'NAM', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL', 'MAT',
    'MRK', 'LUK', 'JHN', 'ACT', 'ROM', '1CO', '2CO', 'GAL', 'EPH', 'PHP',
    'COL', '1TH', '2TH', '1TI', '2TI', 'TIT', 'PHM', 'HEB', 'JAS', '1PE',
    '2PE', '1JN', '2JN', '3JN', 'JUD', 'REV',
  ];

  /// Converts a Free Use Bible API `complete.json` document
  /// (`{translation, books: [{id, chapters: [{chapter: {number, content}}]}]}`)
  /// into verse rows. Books outside the 66-book canon (apocrypha) are skipped;
  /// headings, line breaks and footnote markers are dropped from verse text.
  static List<Map<String, dynamic>> versesFromCompleteJson(
    Map<String, dynamic> json, {
    required String translationId,
    required String languageCode,
  }) {
    final rows = <Map<String, dynamic>>[];
    for (final book in (json['books'] as List).cast<Map<String, dynamic>>()) {
      final bookNumber = _usfmBooks.indexOf(book['id'] as String) + 1;
      if (bookNumber == 0) continue;
      for (final ch
          in (book['chapters'] as List).cast<Map<String, dynamic>>()) {
        final chapter = ch['chapter'] as Map<String, dynamic>;
        final chapterNumber = chapter['number'] as int;
        for (final item
            in (chapter['content'] as List).cast<Map<String, dynamic>>()) {
          if (item['type'] != 'verse') continue;
          final text = _verseText(item['content'] as List);
          if (text.isEmpty) continue;
          rows.add({
            'translation_id': translationId,
            'language_code': languageCode,
            'book_number': bookNumber,
            'chapter': chapterNumber,
            'verse': item['number'] as int,
            'text': text,
          });
        }
      }
    }
    return rows;
  }

  /// OSIS book ids in canon order (book_number = index + 1).
  static const List<String> _osisBooks = [
    'Gen', 'Exod', 'Lev', 'Num', 'Deut', 'Josh', 'Judg', 'Ruth', '1Sam', //
    '2Sam', '1Kgs', '2Kgs', '1Chr', '2Chr', 'Ezra', 'Neh', 'Esth', 'Job',
    'Ps', 'Prov', 'Eccl', 'Song', 'Isa', 'Jer', 'Lam', 'Ezek', 'Dan', 'Hos',
    'Joel', 'Amos', 'Obad', 'Jonah', 'Mic', 'Nah', 'Hab', 'Zeph', 'Hag',
    'Zech', 'Mal', 'Matt', 'Mark', 'Luke', 'John', 'Acts', 'Rom', '1Cor',
    '2Cor', 'Gal', 'Eph', 'Phil', 'Col', '1Thess', '2Thess', '1Tim', '2Tim',
    'Titus', 'Phlm', 'Heb', 'Jas', '1Pet', '2Pet', '1John', '2John',
    '3John', 'Jude', 'Rev',
  ];

  /// Converts an OSIS XML Bible with container `<verse osisID="Gen.1.1">`
  /// elements into verse rows. `<note>` content is dropped and books outside
  /// the 66-book canon are skipped. [fixLegacyHungarian] repairs the
  /// Latin-1 stand-ins (õ/û) older Hungarian files use for ő/ű.
  static List<Map<String, dynamic>> versesFromOsis(
    String xml, {
    required String translationId,
    required String languageCode,
    bool fixLegacyHungarian = false,
  }) {
    final rows = <Map<String, dynamic>>[];
    for (final verse in XmlDocument.parse(xml).findAllElements('verse')) {
      final ref = verse.getAttribute('osisID')?.split(' ').first.split('.');
      if (ref == null || ref.length != 3) continue;
      final bookNumber = _osisBooks.indexOf(ref[0]) + 1;
      if (bookNumber == 0) continue;
      final parts = verse.descendants
          .whereType<XmlText>()
          .where((t) => !t.ancestors
              .whereType<XmlElement>()
              .any((e) => e.name.local == 'note'))
          .map((t) => t.value);
      var text = _clean(parts.join(' '));
      if (fixLegacyHungarian) {
        text = text
            .replaceAll('õ', 'ő')
            .replaceAll('Õ', 'Ő')
            .replaceAll('û', 'ű')
            .replaceAll('Û', 'Ű');
      }
      if (text.isEmpty) continue;
      rows.add({
        'translation_id': translationId,
        'language_code': languageCode,
        'book_number': bookNumber,
        'chapter': int.parse(ref[1]),
        'verse': int.parse(ref[2]),
        'text': text,
      });
    }
    return rows;
  }

  /// Joins a verse's content parts: plain strings and `{text}` runs are
  /// kept; `{heading}`, `{lineBreak}` and `{noteId}` parts are dropped.
  static String _verseText(List<dynamic> parts) {
    final pieces = <String>[];
    for (final part in parts) {
      if (part is String) {
        pieces.add(part);
      } else if (part is Map && part['text'] is String) {
        pieces.add(part['text'] as String);
      }
    }
    return _clean(pieces.join(' '));
  }

  /// Collapses whitespace, removes space before punctuation, and normalises
  /// curly apostrophes.
  static String _clean(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAllMapped(RegExp(r' ([,.;:!?])'), (m) => m.group(1)!)
        .replaceAll('\u2019', "'")
        .replaceAll('\u2018', "'")
        .trim();
  }
}

class _ParsedData {
  final TranslationInfo info;
  final List<Map<String, dynamic>> verses;
  _ParsedData(this.info, this.verses);
}
