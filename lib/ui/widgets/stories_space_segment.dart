import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/localized_book_names.dart';
import '../../data/models/devotional_story.dart';
import '../../l10n/l10n.dart';
import '../../state/devotional_provider.dart';
import '../../state/user_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../screens/bible_story_reader_screen.dart';
import 'prose_text.dart';

/// Your Space → Stories: saved Bible stories and the passages marked in
/// them (highlights and underlines). Tapping either opens the story.
class StoriesSpaceSegment extends ConsumerWidget {
  final ThemeData theme;

  const StoriesSpaceSegment({super.key, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(devotionalStoriesProvider).value ?? const [];
    final savedIds = ref.watch(devotionalFavoritesProvider);
    final marks = ref.watch(storyMarksProvider);
    final byId = {for (final s in all) s.id: s};

    final saved = [
      for (final s in all)
        if (savedIds.contains(s.id)) s
    ];
    final marked = <(DevotionalStory, StoryMark)>[
      for (final s in all)
        for (final m in marks[s.id] ?? const <StoryMark>[]) (s, m),
    ];

    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    if (saved.isEmpty && marked.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            context.l10n.spaceNoStories,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    void open(DevotionalStory story) {
      Navigator.of(context).push(CupertinoPageRoute<void>(
        builder: (_) =>
            BibleStoryReaderScreen(initialStory: byId[story.id] ?? story),
      ));
    }

    Widget heading(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            text.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        if (saved.isNotEmpty) ...[
          heading(context.l10n.spaceSavedStories),
          for (final story in saved)
            _StoryTile(
              theme: theme,
              title: story.title,
              subtitle:
                  '${context.bookNameInLocale(story.book)} · ${context.referenceInLocale(story.ref)}',
              leading: story.plateSlug == null
                  ? null
                  : 'assets/devotional/art/${story.plateSlug}.webp',
              onTap: () => open(story),
              onRemove: () => ref
                  .read(devotionalFavoritesProvider.notifier)
                  .toggle(story.id),
              removeLabel: context.l10n.storiesRemoveFromSaved,
            ),
        ],
        if (marked.isNotEmpty) ...[
          heading(context.l10n.spaceStoryMarks),
          for (final (story, mark) in marked)
            _MarkTile(
              theme: theme,
              story: story,
              mark: mark,
              muted: muted,
              onTap: () => open(story),
              onRemove: () => ref
                  .read(storyMarksProvider.notifier)
                  .removeRange(story.id, mark.start, mark.end),
            ),
        ],
      ],
    );
  }
}

class _StoryTile extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String subtitle;
  final String? leading;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final String removeLabel;

  const _StoryTile({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.onTap,
    required this.onRemove,
    required this.removeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Radii.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.md),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: leading == null
                        ? ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest)
                        : Image.asset(
                            leading!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                                color:
                                    theme.colorScheme.surfaceContainerHighest),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.primaryColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: removeLabel,
                  icon: const Icon(Icons.bookmark_rounded,
                      color: AppColors.goldAccent),
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkTile extends StatelessWidget {
  final ThemeData theme;
  final DevotionalStory story;
  final StoryMark mark;
  final Color muted;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _MarkTile({
    required this.theme,
    required this.story,
    required this.mark,
    required this.muted,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final rendered = renderedProse(story.retelling);
    final start = mark.start.clamp(0, rendered.length);
    final end = mark.end.clamp(start, rendered.length);
    final excerpt = rendered.substring(start, end).replaceAll('\n', ' ');
    final highlight = mark.kind == StoryMarkKind.highlight;
    final color = highlight
        ? AppColors.getRenderedHighlightColor(
            highlightPalette[
                mark.colorIndex.clamp(0, highlightPalette.length - 1)],
            theme.brightness,
            theme.scaffoldBackgroundColor,
          )
        : theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Radii.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(Radii.xs),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        excerpt,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          decoration:
                              highlight ? null : TextDecoration.underline,
                          decorationColor: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            theme.textTheme.labelSmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.storiesRemoveMark,
                  icon: Icon(Icons.close_rounded, color: muted, size: 20),
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
