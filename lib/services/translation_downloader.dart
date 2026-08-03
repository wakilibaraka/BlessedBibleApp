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
  ];

  static Future<void> downloadAndInstall(
      String translationId, void Function(double) onProgress) async {
    final meta = downloadableTranslations
        .firstWhere((t) => (t['db_id'] ?? t['id']) == translationId);

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
          int totalBytes =
              response.contentLength ?? (meta['sizeMB'] * 1024 * 1024).toInt();
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
          await Future.delayed(_retryDelay * (i + 1));
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
    );

    final List<Map<String, dynamic>> dbVerses = [];

    if (versesList.isNotEmpty) {
      // old format
      for (final v in versesList) {
        final m = v as Map<String, dynamic>;
        final bookNum = m['book'] as int;
        final chapter = m['chapter'] as int;
        final verse = m['verse'] as int;
        String text = (m['text'] as String)
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
              final text = verseContent
                  .whereType<String>()
                  .join('')
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
