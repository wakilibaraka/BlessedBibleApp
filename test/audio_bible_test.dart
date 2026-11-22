import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/services/audio_bible_service.dart';
import 'package:the_blessed_bible/services/audio_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('chapter URLs', () {
    test('cover all 66 books and 1189 chapters', () {
      expect(AudioBibleService.books, hasLength(66));
      expect(
        AudioBibleService.books.fold<int>(0, (sum, b) => sum + b.chapters),
        1189,
      );
      for (final book in AudioBibleService.books) {
        expect(
          AudioBibleService.urlFor(book.bookName, 1),
          isNotNull,
          reason: '${book.bookName} 1 should resolve',
        );
        expect(
          AudioBibleService.urlFor(book.bookName, book.chapters),
          isNotNull,
          reason: '${book.bookName} ${book.chapters} should resolve',
        );
        expect(
          AudioBibleService.urlFor(book.bookName, book.chapters + 1),
          isNull,
          reason: '${book.bookName} should not resolve past its last chapter',
        );
      }
    });

    test('follow the recording\'s real filenames', () {
      expect(
        AudioBibleService.urlFor('Genesis', 1),
        'https://publicdomainaudiobibles.com/content/mp3/WEBD/01_Gen/'
        '01_Genesis_01.mp3',
      );
      expect(
        AudioBibleService.urlFor('1 Corinthians', 13),
        'https://publicdomainaudiobibles.com/content/mp3/WEBD/46_1Cor/'
        '46_1Corinthians_13.mp3',
      );
      // Psalms is the one book with three-digit chapters.
      expect(
        AudioBibleService.urlFor('Psalms', 119),
        'https://publicdomainaudiobibles.com/content/mp3/WEBD/19_Psa/'
        '19_Psalm_119.mp3',
      );
      expect(
        AudioBibleService.urlFor('Revelation', 22),
        'https://publicdomainaudiobibles.com/content/mp3/WEBD/66_Rev/'
        '66_Revelation_22.mp3',
      );
    });

    test('resolve the app\'s book names onto the recording', () {
      expect(
        AudioBibleService.urlFor('Song of Solomon', 1),
        'https://publicdomainaudiobibles.com/content/mp3/WEBD/22_Song/'
        '22_Song_of_Solomon_01.mp3',
      );
      expect(AudioBibleService.chapterCount('song of solomon'), 8);
      expect(AudioBibleService.chapterCount('Judas'), isNull);
      expect(AudioBibleService.urlFor('Genesis', 0), isNull);
      expect(AudioBibleService.urlFor('Genesis', 51), isNull);
    });
  });

  group('navigation', () {
    test('crosses book boundaries in reading order', () {
      expect(AudioBibleService.next('Genesis', 50),
          const AudioChapterRef('Exodus', 1));
      expect(AudioBibleService.next('Psalms', 150),
          const AudioChapterRef('Proverbs', 1));
      expect(AudioBibleService.next('Malachi', 4),
          const AudioChapterRef('Matthew', 1));
      expect(AudioBibleService.next('Revelation', 22), isNull);

      expect(AudioBibleService.previous('Matthew', 1),
          const AudioChapterRef('Malachi', 4));
      expect(AudioBibleService.previous('Psalms', 1),
          const AudioChapterRef('Job', 42));
      expect(AudioBibleService.previous('Genesis', 1), isNull);
    });

    test('speed cycles and never leaves the supported range', () {
      expect(AudioBibleService.nextSpeed(1.0), 1.25);
      expect(AudioBibleService.nextSpeed(2.0), 0.75);
      expect(AudioBibleService.nextSpeed(0.9), 1.25);
      // 1.9 snaps to 2x, then wraps to the slowest option.
      expect(AudioBibleService.nextSpeed(1.9), 0.75);
      expect(AudioBibleService.formatSpeed(1.0), '1x');
      expect(AudioBibleService.formatSpeed(1.5), '1.5x');
      expect(AudioBibleService.formatSpeed(0.75), '0.75x');
    });
  });

  group('audio cache', () {
    late Directory temp;
    late AudioCacheService cache;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('audio_cache_test');
      cache = AudioCacheService(temp, maxBytes: 3 * 1024 * 1024);
    });

    tearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    test('file names are portable', () {
      expect(AudioCacheService.fileNameFor('1 Corinthians:13'),
          '1_corinthians_13.mp3');
      expect(AudioCacheService.fileNameFor('Psalms:119'), 'psalms_119.mp3');
      expect(AudioCacheService.fileNameFor('!!'), 'chapter.mp3');
    });

    test('stores, measures and clears chapters', () async {
      final file = await cache.fileFor('Genesis:1');
      await file.writeAsBytes(List<int>.filled(1000, 0));
      expect(await cache.has('Genesis:1'), isTrue);
      expect(await cache.totalBytes(), 1000);
      await cache.clear();
      expect(await cache.has('Genesis:1'), isFalse);
      expect(await cache.totalBytes(), 0);
    });

    test('drops the oldest downloads to stay under the cap', () async {
      final bytes = 1024 * 1024;
      final oldest = await cache.fileFor('Genesis:1');
      await oldest.writeAsBytes(List<int>.filled(bytes, 0));
      oldest.setLastModifiedSync(DateTime(2020, 1, 1));
      final middle = await cache.fileFor('Genesis:2');
      await middle.writeAsBytes(List<int>.filled(bytes, 0));
      middle.setLastModifiedSync(DateTime(2021, 1, 1));
      final newest = await cache.fileFor('Genesis:3');
      await newest.writeAsBytes(List<int>.filled(bytes, 0));
      newest.setLastModifiedSync(DateTime(2022, 1, 1));

      // Three 1 MB chapters already fill a 3 MB cap; a fourth must evict.
      await cache.trimToCap(incomingBytes: bytes, keep: {'Genesis:4'});
      expect(await oldest.exists(), isFalse);
      expect(await middle.exists(), isTrue);
      expect(await newest.exists(), isTrue);
      expect(await cache.totalBytes(), lessThanOrEqualTo(cache.maxBytes));
    });

    test('never evicts the file being written', () async {
      for (final name in ['Genesis:1', 'Genesis:2', 'Genesis:3']) {
        final file = await cache.fileFor(name);
        await file.writeAsBytes(List<int>.filled(1024 * 1024, 0));
        file.setLastModifiedSync(DateTime(2020, 1, 1));
      }
      await cache.trimToCap(
        incomingBytes: 2 * 1024 * 1024,
        keep: {'Genesis:1'},
      );
      expect(await cache.has('Genesis:1'), isTrue);
    });
  });
}
