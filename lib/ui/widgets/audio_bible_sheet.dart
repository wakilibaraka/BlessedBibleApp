import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../services/audio_bible_service.dart';
import '../../services/translation_pack_store.dart';
import '../../state/audio_bible_provider.dart';
import '../../state/translation_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import 'audio_listen_icon.dart';
import 'audio_verse_progress_bar.dart';

/// Opens the chapter audio player. Playback lives in [audioBibleProvider], so
/// dismissing this sheet keeps the chapter playing.
Future<void> showAudioBibleSheet(
  BuildContext context, {
  required String book,
  required int chapter,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AudioBibleSheet(book: book, chapter: chapter),
  );
}

class AudioBibleSheet extends ConsumerStatefulWidget {
  const AudioBibleSheet({super.key, required this.book, required this.chapter});

  final String book;
  final int chapter;

  @override
  ConsumerState<AudioBibleSheet> createState() => _AudioBibleSheetState();
}

class _AudioBibleSheetState extends ConsumerState<AudioBibleSheet> {
  @override
  void initState() {
    super.initState();
    // Opening the sheet for a chapter that is not loaded starts it; reopening
    // the same chapter only reveals the controls.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(audioBibleProvider);
      if (current.book != widget.book || current.chapter != widget.chapter) {
        ref
            .read(audioBibleProvider.notifier)
            .openChapter(widget.book, widget.chapter);
      }
    });
  }

  static String _clock(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static String _size(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).round()} KB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final audio = ref.watch(audioBibleProvider);
    final notifier = ref.read(audioBibleProvider.notifier);
    final activeTranslation = ref.watch(activeTranslationProvider);

    final book = audio.book ?? widget.book;
    final chapter = audio.chapter ?? widget.chapter;
    final duration = audio.duration ?? Duration.zero;

    final details = switch (audio.failure) {
      AudioFailure.unavailable => l10n.audioUnavailable,
      AudioFailure.network => l10n.audioNetworkError,
      null => null,
    };

    final verse = audio.currentVerse;
    final sleep = audio.sleepRemaining;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(Radii.xs),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      AudioListenIcon(
                        playing: audio.playing,
                        color: AppColors.goldAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$book $chapter · '
                              '${AudioBibleService.translationLabel}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (verse != null)
                              Text(
                                l10n.audioNowPlaying(verse),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.goldAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (audio.downloadProgress != null)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            // A server that sends no Content-Length gives no
                            // fraction to show, so spin instead of sitting at 0.
                            value: (audio.downloadProgress ?? 0) > 0
                                ? audio.downloadProgress
                                : null,
                          ),
                        ),
                      IconButton(
                        tooltip: l10n.commonClose,
                        // Dismissing only hides the controls: the chapter keeps
                        // playing, and the headphones button brings them back.
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(Icons.close_rounded,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: .6)),
                      ),
                    ],
                  ),
                  if (details != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 10),
                  AudioVerseProgressBar(
                    position: audio.position,
                    duration: duration,
                    timeline: audio.timeline,
                    activeColor: AppColors.goldAccent,
                    trackColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.15),
                    onSeek: notifier.seek,
                    onSeekToVerse: notifier.seekToVerse,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_clock(audio.position),
                            style: theme.textTheme.labelSmall),
                        Text(_clock(duration),
                            style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                  if (verse != null && audio.timeline.end > Duration.zero)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        l10n.audioSyncApprox,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: .5),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: l10n.readPreviousChapter,
                        onPressed: notifier.previousChapter,
                        icon: const Icon(Icons.skip_previous_rounded, size: 30),
                      ),
                      IconButton(
                        onPressed: () =>
                            notifier.skip(const Duration(seconds: -10)),
                        icon: const Icon(Icons.replay_10_rounded, size: 26),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.goldAccent,
                            foregroundColor: AppColors.lightTextPrimary,
                          ),
                          onPressed: audio.buffering && !audio.playing
                              ? null
                              : notifier.toggle,
                          child: Icon(
                            audio.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () =>
                            notifier.skip(const Duration(seconds: 10)),
                        icon: const Icon(Icons.forward_10_rounded, size: 26),
                      ),
                      IconButton(
                        tooltip: l10n.readNextChapter,
                        onPressed: notifier.nextChapter,
                        icon: const Icon(Icons.skip_next_rounded, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        tooltip: l10n.audioSpeed,
                        avatar: const Icon(Icons.speed_rounded, size: 16),
                        label: Text(AudioBibleService.formatSpeed(audio.speed)),
                        onPressed: notifier.cycleSpeed,
                      ),
                      ActionChip(
                        tooltip: l10n.audioSleepTimer,
                        avatar: const Icon(Icons.bedtime_outlined, size: 16),
                        label: Text(
                          sleep == null ? l10n.audioSleepTimer : _clock(sleep),
                        ),
                        onPressed: notifier.cycleSleepTimer,
                      ),
                      ActionChip(
                        tooltip: l10n.audioFollow,
                        avatar: Icon(
                          audio.followAudio
                              ? Icons.vertical_align_center_rounded
                              : Icons.vertical_align_top_rounded,
                          size: 16,
                        ),
                        label: Text(l10n.audioFollow),
                        onPressed: notifier.toggleFollowAudio,
                      ),
                      if (verse != null)
                        ActionChip(
                          tooltip: l10n.audioAnchorFromHere,
                          avatar: const Icon(Icons.sync_rounded, size: 16),
                          label: Text(l10n.audioAnchorFromHere),
                          onPressed: () => notifier.anchorHere(verse),
                        ),
                      if (audio.downloaded)
                        ActionChip(
                          avatar:
                              const Icon(Icons.offline_pin_rounded, size: 16),
                          label: Text(l10n.audioOffline),
                          onPressed: notifier.removeDownload,
                        )
                      else if (audio.downloadProgress == null)
                        ActionChip(
                          avatar: const Icon(Icons.download_rounded, size: 16),
                          label: Text(l10n.audioDownload),
                          onPressed: notifier.downloadCurrent,
                        ),
                      if (audio.bookDownloadTotal != null)
                        ActionChip(
                          avatar: const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          label: Text(l10n.audioBookDownloading(
                            audio.bookDownloadDone ?? 0,
                            audio.bookDownloadTotal ?? 0,
                          )),
                          onPressed: null,
                        )
                      else
                        ActionChip(
                          avatar: const Icon(
                              Icons.download_for_offline_outlined,
                              size: 16),
                          label: Text(l10n.audioDownloadBook),
                          onPressed: notifier.downloadBook,
                        ),
                      if (audio.cacheBytes > 0)
                        ActionChip(
                          avatar: const Icon(Icons.delete_outline_rounded,
                              size: 16),
                          label: Text(
                              '${l10n.audioClearDownloads} · ${_size(audio.cacheBytes)}'),
                          onPressed: notifier.clearCache,
                        ),
                      if (activeTranslation !=
                          TranslationPackStore.audioTranslationId)
                        ActionChip(
                          avatar: const Icon(Icons.menu_book_rounded, size: 16),
                          label: Text(l10n.audioListenInWeb),
                          onPressed: () => ref
                              .read(activeTranslationProvider.notifier)
                              .setTranslation(
                                  TranslationPackStore.audioTranslationId),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.audioAdvanceTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: .6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final mode in AudioAdvanceMode.values)
                        ChoiceChip(
                          label: Text(switch (mode) {
                            AudioAdvanceMode.chapter =>
                              l10n.audioAdvanceChapter,
                            AudioAdvanceMode.book => l10n.audioAdvanceBook,
                            AudioAdvanceMode.off => l10n.audioAdvanceOff,
                          }),
                          selected: audio.advanceMode == mode,
                          onSelected: (_) => notifier.setAdvanceMode(mode),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.audioStreamNote,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: .6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AudioBibleService.attribution,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: .45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
