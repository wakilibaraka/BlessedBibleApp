import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/state/last_played_audio_provider.dart';
import 'package:the_blessed_bible/ui/widgets/continue_listening_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Continue listening visibility', () {
    test('hides when nothing has been played', () {
      expect(
        shouldShowContinueListening(
          hasLastPlayed: false,
          miniPlayerShowing: false,
          miniPlayerSameItem: false,
        ),
        isFalse,
      );
      expect(
        shouldShowContinueListening(
          hasLastPlayed: false,
          miniPlayerShowing: true,
          miniPlayerSameItem: true,
        ),
        isFalse,
      );
    });

    test('shows the last chapter when nothing is playing', () {
      expect(
        shouldShowContinueListening(
          hasLastPlayed: true,
          miniPlayerShowing: false,
          miniPlayerSameItem: false,
        ),
        isTrue,
      );
    });

    test('hides while the mini player shows the same chapter', () {
      expect(
        shouldShowContinueListening(
          hasLastPlayed: true,
          miniPlayerShowing: true,
          miniPlayerSameItem: true,
        ),
        isFalse,
      );
    });

    test('still offers the last chapter while another one plays', () {
      expect(
        shouldShowContinueListening(
          hasLastPlayed: true,
          miniPlayerShowing: true,
          miniPlayerSameItem: false,
        ),
        isTrue,
      );
    });
  });

  group('resume point', () {
    test('records, persists and clears', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(lastPlayedAudioProvider.notifier);

      await notifier.record(
        book: 'John',
        chapter: 3,
        position: const Duration(seconds: 95),
      );

      expect(
        container.read(lastPlayedAudioProvider),
        const LastPlayedAudio(
          book: 'John',
          chapter: 3,
          position: Duration(seconds: 95),
        ),
      );

      final saved = await LastPlayedAudioNotifier.readSaved();
      expect(saved, isNotNull);
      expect(saved!.book, 'John');
      expect(saved.chapter, 3);
      expect(saved.position, const Duration(seconds: 95));

      await notifier.clear();
      expect(container.read(lastPlayedAudioProvider), isNull);
      expect(await LastPlayedAudioNotifier.readSaved(), isNull);
    });

    test('clamps a negative position and ignores an unusable chapter',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(lastPlayedAudioProvider.notifier);

      await notifier.record(
        book: 'Psalms',
        chapter: 23,
        position: const Duration(seconds: -5),
      );
      expect(container.read(lastPlayedAudioProvider)?.position, Duration.zero);

      // An empty book or chapter 0 must not overwrite a usable resume point.
      await notifier.record(
        book: '   ',
        chapter: 2,
        position: const Duration(seconds: 5),
      );
      expect(container.read(lastPlayedAudioProvider)?.book, 'Psalms');

      await notifier.record(
        book: 'Genesis',
        chapter: 0,
        position: Duration.zero,
      );
      expect(container.read(lastPlayedAudioProvider)?.chapter, 23);
    });

    test('reads nothing when only half a record was written', () async {
      SharedPreferences.setMockInitialValues(
          {LastPlayedAudioNotifier.bookKey: 'John'});
      expect(await LastPlayedAudioNotifier.readSaved(), isNull);

      SharedPreferences.setMockInitialValues(
          {LastPlayedAudioNotifier.chapterKey: 3});
      expect(await LastPlayedAudioNotifier.readSaved(), isNull);

      SharedPreferences.setMockInitialValues({
        LastPlayedAudioNotifier.bookKey: 'John',
        LastPlayedAudioNotifier.chapterKey: 3,
      });
      final saved = await LastPlayedAudioNotifier.readSaved();
      expect(saved?.book, 'John');
      expect(saved?.position, Duration.zero,
          reason: 'a missing position resumes from the start');
    });
  });

  group('card formatting', () {
    test('shows minutes and padded seconds', () {
      expect(ContinueListeningCard.clock(Duration.zero), '0:00');
      expect(ContinueListeningCard.clock(const Duration(seconds: 5)), '0:05');
      expect(
        ContinueListeningCard.clock(const Duration(minutes: 2, seconds: 31)),
        '2:31',
      );
      expect(
        ContinueListeningCard.clock(const Duration(minutes: 65, seconds: 9)),
        '65:09',
      );
    });
  });
}
