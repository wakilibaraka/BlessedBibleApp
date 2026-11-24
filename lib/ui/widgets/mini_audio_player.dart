import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../services/audio_bible_service.dart';
import '../../state/audio_bible_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import 'audio_bible_sheet.dart';
import 'audio_listen_icon.dart';

/// A slim bar above the navigation dock while a chapter is loaded, so the
/// narration stays reachable after the player sheet is dismissed.
class MiniAudioPlayer extends ConsumerWidget {
  const MiniAudioPlayer({super.key});

  static String _clock(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioBibleProvider);
    if (!audio.isCurrentChapter) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final notifier = ref.read(audioBibleProvider.notifier);
    final duration = audio.duration ?? Duration.zero;
    final fraction = duration.inMilliseconds > 0
        ? (audio.position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;
    final verse = audio.currentVerse;
    final subtitle = verse == null
        ? AudioBibleService.translationLabel
        : '${context.l10n.audioNowPlaying(verse)} · '
            '${AudioBibleService.translationLabel}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.lg),
          onTap: () => showAudioBibleSheet(
            context,
            book: audio.book!,
            chapter: audio.chapter!,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.palette.shadow,
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
                    child: Row(
                      children: [
                        AudioListenIcon(
                          playing: audio.playing,
                          color: AppColors.goldAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${audio.book} ${audio.chapter}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                audio.sleepTimerActive
                                    ? '${context.l10n.audioSleepRemaining(
                                        _clock(audio.sleepRemaining!),
                                      )} · $subtitle'
                                    : subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: audio.playing
                              ? context.l10n.audioPause
                              : context.l10n.audioPlay,
                          onPressed: audio.buffering && !audio.playing
                              ? null
                              : notifier.toggle,
                          icon: Icon(
                            audio.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.goldAccent,
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.commonClose,
                          onPressed: notifier.stop,
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: fraction,
                    minHeight: 2,
                    backgroundColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.goldAccent),
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
