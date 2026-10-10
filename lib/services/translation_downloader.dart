import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import '../data/models/translation_model.dart';
import 'bible_database_service.dart';

class TranslationDownloader {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Downloadable translation definitions
  static final List<Map<String, dynamic>> downloadableTranslations = [
    {
      'id': 'rus_syn',
      'db_id': 'rus_syn',
      'lang': 'ru',
      'langName': 'Russian',
      'name': 'Russian Synodal Bible',
      'abbr': 'SYN',
      'license': 'Public Domain',
      'sizeMB': 5.3
    },
    {
      'id': 'cmn_cuv',
      'db_id': 'cmn_cuv',
      'lang': 'zh',
      'langName': 'Chinese',
      'name': 'Chinese Union Version',
      'abbr': 'CUV',
      'license': 'Public Domain',
      'sizeMB': 2.4
    },
    {
      'id': 'arb_vdv',
      'db_id': 'arb_vdv',
      'lang': 'ar',
      'langName': 'Arabic',
      'name': 'Arabic Van Dyck Bible',
      'abbr': 'VDV',
      'license': 'Public Domain',
      'sizeMB': 7.1
    },
    {
      'id': 'kor_old',
      'db_id': 'kor_old',
      'lang': 'ko',
      'langName': 'Korean',
      'name': 'Korean Bible 1910',
      'abbr': 'KOR',
      'license': 'Public Domain',
      'sizeMB': 4.2
    },
    {
      'id': 'ukr_pan',
      'db_id': 'ukr_pan',
      'lang': 'uk',
      'langName': 'Ukrainian',
      'name': 'Ukrainian Bible by P. Kulish',
      'abbr': 'UKR',
      'license': 'Public Domain',
      'sizeMB': 5.4
    },
    {
      'id': 'HINIRV',
      'db_id': 'hinirv',
      'lang': 'hi',
      'langName': 'Hindi',
      'name': 'Hindi Indian Revised Version',
      'abbr': 'IRV',
      'license': 'CC BY-SA 4.0',
      'sizeMB': 8.0
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
      'id': 'ron_btf',
      'lang': 'ro',
      'langName': 'Romanian',
      'name': 'Romanian BTF Bible',
      'abbr': 'BTF',
      'license': 'Public Domain',
      'sizeMB': 5.4,
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
    // Prebuilt packs hosted in Firebase Storage (see content_packs/ +
    // content_packs/manifest.json for sha256). Upload once with:
    // gsutil cp content_packs/<id>.db gs://blessedbibleapp.firebasestorage.app/packs/
    ..._storagePack(
      id: 'kjv_strongs',
      lang: 'en',
      langName: 'English',
      name: "KJV with Strong's",
      abbr: 'KJVS',
      license: 'Public Domain',
      sizeMB: 7.7,
      sha256:
          '1adece5cf1de520059216e1aaef8cd94ea268966570353e776546d8034425cfa',
    ),
    ..._storagePack(
      id: 'web',
      lang: 'en',
      langName: 'English',
      name: 'World English Bible',
      abbr: 'WEB',
      license: 'Public Domain',
      sizeMB: 5.0,
      sha256:
          'e9e3907aedc0515ffb76a85cf0c18d0bd4f7d208894f09e0539ba70fbcc05415',
    ),
    ..._storagePack(
      id: 'deu_l12',
      lang: 'de',
      langName: 'German',
      name: 'Luther Bible 1912',
      abbr: 'L1912',
      license: 'Public Domain',
      sizeMB: 4.9,
      sha256:
          'f3cc52a2e35060dfea078807fd67b8b2c43b353bc6034edb2f1962ad4d2af250',
    ),
    ..._storagePack(
      id: 'nld_',
      lang: 'nl',
      langName: 'Dutch',
      name: 'Dutch Bible 1917',
      abbr: 'NLD',
      license: 'Public Domain',
      sizeMB: 5.3,
      sha256:
          '3a6d4631581887d7b7cb17d1f094c65cef703ce450c82bc1b79347c9f834ed96',
    ),
    ..._storagePack(
      id: 'por_blj',
      lang: 'pt',
      langName: 'Portuguese',
      name: 'Bíblia Livre',
      abbr: 'BLIVRE',
      license: 'CC BY 4.0',
      sizeMB: 5.0,
      sha256:
          '0a6145db735f7fa95317979cc7d1a963616ec2a6429a6f5adccae065fee03477',
    ),
    ..._storagePack(
      id: 'spa_r09',
      lang: 'es',
      langName: 'Spanish',
      name: 'Reina Valera 1909',
      abbr: 'RV1909',
      license: 'Public Domain',
      sizeMB: 5.0,
      sha256:
          'c1783150ae84f10c76379aa4dc8e8c856b35e3d211134c97628c9e04161dc453',
    ),
  ];

  static const String _storageBucket = 'blessedbibleapp.firebasestorage.app';

  /// Registry entry for one Firebase-Storage-hosted prebuilt pack.
  static List<Map<String, dynamic>> _storagePack({
    required String id,
    required String lang,
    required String langName,
    required String name,
    required String abbr,
    required String license,
    required double sizeMB,
    required String sha256,
  }) {
    return [
      {
        'id': id,
        'lang': lang,
        'langName': langName,
        'name': name,
        'abbr': abbr,
        'license': license,
        'sizeMB': sizeMB,
        'source': 'storage',
        'storageUrl': 'https://firebasestorage.googleapis.com/v0/b/'
            '$_storageBucket/o/packs%2F$id.db?alt=media',
        'sha256': sha256,
      }
    ];
  }

  static Future<void> downloadAndInstall(
      String translationId, void Function(double) onProgress) async {
    final meta = downloadableTranslations
        .firstWhere((t) => (t['db_id'] ?? t['id']) == translationId);

    // Prebuilt pack flow (Firebase Storage): exact bytes, hash-verified.
    final storageUrl = meta['storageUrl'] as String?;
    if (storageUrl != null) {
      await _downloadPrebuiltPack(meta, storageUrl, onProgress);
      return;
    }

    // Primary endpoint (actual helloao structure)
    final primaryUrl =
        "https://bible.helloao.org/api/\${meta['id']}/complete.json";

    String? jsonString;
    Exception? lastError;

    // Retry logic
    for (int i = 0; i < _maxRetries; i++) {
      try {
        final request = http.Request('GET', Uri.parse(primaryUrl));
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
          throw Exception('HTTP \${response.statusCode}');
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

  /// Downloads a prebuilt pack database (Firebase Storage) with retries,
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
    final parsed = jsonDecode(jsonString) as Map<String, dynamic>;
    final versesList = parsed['verses'] as List<dynamic>? ?? [];

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

    final List<Map<String, dynamic>> dbVerses = [];

    if (versesList.isNotEmpty) {
      // old format
      for (final v in versesList) {
        final m = v as Map<String, dynamic>;
        final bookNum = m['book'] as int;
        final chapter = m['chapter'] as int;
        final verse = m['verse'] as int;
        final String text = (m['text'] as String)
            .replaceAll('¶ ', '')
            .replaceAll('¶', '')
            .trim()
            .replaceAll('\u2019', "'")
            .replaceAll('\u2018', "'");
        dbVerses.add({
          'translation_id': info.translationId,
          'language_code': info.languageCode,
          'book_number': bookNum,
          'chapter': chapter,
          'verse': verse,
          'text': text,
        });
      }
    } else if (parsed['books'] != null) {
      // new structure
      final books = parsed['books'] as List<dynamic>;
      for (final bWrap in books) {
        final bMap = bWrap as Map<String, dynamic>;
        final bookData = bMap['book'] as Map<String, dynamic>;
        final bookNum = bookData['number'] as int;
        final chapters = bookData['chapters'] as List<dynamic>;

        for (final chWrap in chapters) {
          final chMap = chWrap as Map<String, dynamic>;
          final chData = chMap['chapter'] as Map<String, dynamic>;
          final chapter = chData['number'] as int;
          final content = chData['content'] as List<dynamic>;

          for (final item in content) {
            final itemMap = item as Map<String, dynamic>;
            if (itemMap['type'] == 'verse') {
              final verseNum = itemMap['number'] as int;
              final verseContent = itemMap['content'] as List<dynamic>;
              final rawText = verseContent
                  .map((e) {
                    if (e is String) return e;
                    if (e is Map) {
                      if (e['text'] != null) return e['text'].toString();
                      if (e['content'] != null && e['content'] is String) {
                        return e['content'].toString();
                      }
                    }
                    return '';
                  })
                  .where((s) => s.isNotEmpty)
                  .join(' ');

              final text = rawText
                  .replaceAll(' ,', ',')
                  .replaceAll(' .', '.')
                  .replaceAll(' ;', ';')
                  .replaceAll(' :', ':')
                  .trim()
                  .replaceAll('\u2019', "'")
                  .replaceAll('\u2018', "'");
              dbVerses.add({
                'translation_id': info.translationId,
                'language_code': info.languageCode,
                'book_number': bookNum,
                'chapter': chapter,
                'verse': verseNum,
                'text': text,
              });
            }
          }
        }
      }
    }

    return _ParsedData(info, dbVerses);
  }
}

class _ParsedData {
  final TranslationInfo info;
  final List<Map<String, dynamic>> verses;
  _ParsedData(this.info, this.verses);
}
