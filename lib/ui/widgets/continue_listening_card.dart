import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../state/audio_bible_provider.dart';
import '../../state/last_played_audio_provider.dart';
import '../../state/read_location_provider.dart';
import '../../theme/design_tokens.dart';
import 'glass_container.dart';

/// Home's way back into the narration after a restart.
///
/// It stays out of the way while the mini player is already showing the same
/// chapter, and hides itself when nothing has been listened to yet.
class ContinueListeningCard extends ConsumerWidget {
  const ContinueListeningCard({super.key});

  static String clock(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(lastPlayedAudioProvider);
    final audio = ref.watch(audioBibleProvider.select((s) => (
          isCurrentChapter: s.isCurrentChapter,
          book: s.book,
          chapter: s.chapter,
        )));

    final visible = shouldShowContinueListening(
      hasLastPlayed: resume != null,
      miniPlayerShowing: audio.isCurrentChapter,
      miniPlayerSameItem: resume != null &&
          audio.book == resume.book &&
          audio.chapter == resume.chapter,
    );
    if (!visible || resume == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(Radii.xxl),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Icon(
                Icons.headphones_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.audioContinueListening,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${resume.book} ${resume.chapter}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.audioPausedAt(clock(resume.position)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () {
                openReaderAtVerse(
                  ref,
                  bookName: resume.book,
                  chapter: resume.chapter,
                );
                ref.read(audioBibleProvider.notifier).openChapter(
                      resume.book,
                      resume.chapter,
                      startAt: resume.position,
                    );
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
              ),
              child: Text(
                l10n.plansResume,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
