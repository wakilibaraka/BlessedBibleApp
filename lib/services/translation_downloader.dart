import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
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

    final url = meta['url'] as String;

    // Prebuilt pack database: exact bytes, hash-verified.
    if (meta['source'] == 'prebuilt') {
      await _downloadPrebuiltPack(meta, url, onProgress);
      return;
    }

    String? jsonString;
    Exception? lastError;

    // Retry logic
    for (int i = 0; i < _maxRetries; i++) {
      try {
        final request = http.Request('GET', Uri.parse(url));
        final response = await request.send();

        if (response.statusCode == 200) {
          final int totalBytes = response.contentLength ??
              ((meta['sizeMB'] as num) * 1024 * 1024).toInt();
          int receivedBytes = 0;
          final List<int> bytes = [];

          await for (final chunk in response.stream) {
            bytes.addAll(chunk);
            receivedBytes += chunk.length;
            onProgress(receivedBytes / totalBytes);
          }

          jsonString = utf8.decode(bytes);
          break; // Success
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      } catch (e) {
        lastError = e as Exception;
        if (i < _maxRetries - 1) {
          await Future<void>.delayed(_retryDelay * (i + 1));
        }
      }
    }

    if (jsonString == null) {
      throw lastError ?? Exception('Download failed');
    }

    onProgress(1.0); // Processing

    // Parse large JSON in isolate to avoid ANR
    final parsedData =
        await Isolate.run(() => _parseTranslationJson(jsonString!, meta));

    // Install to DB
    await bibleDbService.insertTranslationPack(
        parsedData.info, parsedData.verses);
  }

  /// Downloads a prebuilt pack database with retries,
  /// verifies its sha256, and installs it as a standalone pack file.
  static Future<void> _downloadPrebuiltPack(
    Map<String, dynamic> meta,
    String url,
    void Function(double) onProgress,
  ) async {
    final tid = (meta['db_id'] ?? meta['id']) as String;
    List<int>? bytes;
    Exception? lastError;

    for (int i = 0; i < _maxRetries; i++) {
      try {
        final request = http.Request('GET', Uri.parse(url));
        final response = await request.send();
        if (response.statusCode == 200) {
          final int totalBytes = response.contentLength ??
              ((meta['sizeMB'] as num) * 1024 * 1024).toInt();
          int receivedBytes = 0;
          final chunks = <int>[];
          await for (final chunk in response.stream) {
            chunks.addAll(chunk);
            receivedBytes += chunk.length;
            onProgress(receivedBytes / totalBytes);
          }
          bytes = chunks;
          break;
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      } catch (e) {
        lastError = e as Exception;
        if (i < _maxRetries - 1) {
          await Future<void>.delayed(_retryDelay * (i + 1));
        }
      }
    }

    if (bytes == null) {
      throw lastError ?? Exception('Download failed');
    }
    onProgress(1.0); // Verifying + installing
    await bibleDbService.installPrebuiltPack(
      tid,
      bytes,
      expectedSha256: meta['sha256'] as String?,
    );
  }

  // Runs in an isolate
  static _ParsedData _parseTranslationJson(
      String jsonString, Map<String, dynamic> meta) {
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
    final verses = versesFromCompleteJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
      translationId: info.translationId,
      languageCode: info.languageCode,
    );
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
    return pieces
        .join(' ')
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
