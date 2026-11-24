import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/services/audio_anchor_store.dart';
import 'package:the_blessed_bible/services/audio_bible_service.dart';
import 'package:the_blessed_bible/services/audio_verse_timing.dart';

AudioSyncAnchor _anchor(
  String book,
  int chapter,
  int verse,
  int seconds, {
  DateTime? savedAt,
}) =>
    AudioSyncAnchor(
      book: book,
      chapter: chapter,
      verse: verse,
      position: Duration(seconds: seconds),
      savedAt: savedAt ?? DateTime(2026, 11, 24),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('audio anchor store', () {
    test('round-trips a correction per chapter', () async {
      SharedPreferences.setMockInitialValues({});
      const store = AudioAnchorStore();

      await store.save(_anchor('John', 3, 16, 62));

      final all = await store.readAll();
      expect(all.keys, [AudioBibleService.chapterId('John', 3)]);
      final saved = all.values.single;
      expect(saved.book, 'John');
      expect(saved.chapter, 3);
      expect(saved.verse, 16);
      expect(saved.position, const Duration(seconds: 62));
      expect(saved.savedAt, DateTime(2026, 11, 24));
    });

    test('keeps chapters separate and replaces a re-correction', () async {
      SharedPreferences.setMockInitialValues({});
      const store = AudioAnchorStore();

      await store.save(_anchor('John', 3, 16, 62));
      await store.save(_anchor('Psalms', 23, 1, 5));
      await store.save(_anchor('John', 3, 14, 40));

      final all = await store.readAll();
      expect(all, hasLength(2));
      final john = all[AudioBibleService.chapterId('John', 3)]!;
      expect(john.verse, 14, reason: 'the newest correction wins');
      expect(john.position, const Duration(seconds: 40));
      expect(all[AudioBibleService.chapterId('Psalms', 23)]!.verse, 1);
    });

    test('drops the oldest corrections past the cap', () async {
      SharedPreferences.setMockInitialValues({});
      const store = AudioAnchorStore(maxChapters: 2);

      await store
          .save(_anchor('Genesis', 1, 3, 10, savedAt: DateTime(2026, 1, 1)));
      await store
          .save(_anchor('Genesis', 2, 4, 20, savedAt: DateTime(2026, 1, 2)));
      await store
          .save(_anchor('Genesis', 3, 5, 30, savedAt: DateTime(2026, 1, 3)));

      final all = await store.readAll();
      expect(all, hasLength(2));
      expect(
          all.containsKey(AudioBibleService.chapterId('Genesis', 1)), isFalse,
          reason: 'the oldest correction is evicted');
      expect(
          all.containsKey(AudioBibleService.chapterId('Genesis', 3)), isTrue);
    });

    test('survives a corrupt store and skips unusable entries', () async {
      SharedPreferences.setMockInitialValues(
          {AudioAnchorStore.storageKey: 'not json at all'});
      const store = AudioAnchorStore();
      expect(await store.readAll(), isEmpty);

      SharedPreferences.setMockInitialValues({
        AudioAnchorStore.storageKey:
            '{"broken":{"book":5},"john:3":{"book":"John","chapter":3,'
                '"verse":7,"position_ms":1000,"saved_at":0}}',
      });
      final all = await store.readAll();
      expect(all, hasLength(1));
      expect(all[AudioBibleService.chapterId('John', 3)]!.verse, 7);
    });

    test('removes and clears', () async {
      SharedPreferences.setMockInitialValues({});
      const store = AudioAnchorStore();

      await store.save(_anchor('John', 3, 16, 62));
      await store.remove(AudioBibleService.chapterId('John', 3));
      expect(await store.readAll(), isEmpty);

      await store.save(_anchor('John', 3, 16, 62));
      await store.clear();
      expect(await store.readAll(), isEmpty);
    });

    test('a restored correction re-bases the chapter timeline', () async {
      SharedPreferences.setMockInitialValues({});
      const store = AudioAnchorStore();
      await store.save(_anchor('John', 3, 3, 20));

      final loaded = await store.load();
      final timeline = AudioVerseTiming.estimate(
        verses: const [
          (number: 1, text: 'aaaa'),
          (number: 2, text: 'bbbb'),
          (number: 3, text: 'cccc'),
          (number: 4, text: 'dddd'),
        ],
        duration: const Duration(seconds: 40),
        anchor: loaded[AudioBibleService.chapterId('John', 3)],
      );

      expect(timeline.startOf(3), const Duration(seconds: 20),
          reason: 'the saved correction is applied on reopen');
      expect(timeline.startOf(1), Duration.zero);
      expect(timeline.end, const Duration(seconds: 40));
    });
  });
}
