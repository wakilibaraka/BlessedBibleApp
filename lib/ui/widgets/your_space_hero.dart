import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import 'textured_glass_container.dart';
import '../screens/highlights_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/notes_list_screen.dart';
import '../screens/note_editor_screen.dart';
import '../../state/study_layout_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/notes_provider.dart';

class YourSpaceHero extends ConsumerWidget {
  final CardSize size;
  const YourSpaceHero({super.key, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _buildLayout(context, ref, size, theme),
    );
  }

  Widget _buildLayout(BuildContext context, WidgetRef ref, CardSize size, ThemeData theme) {
    final notesTile = _NotesTile(size: size);
    final highlightsTile = _HighlightsTile(size: size);
    final bookmarksTile = _BookmarksTile(size: size);

    switch (size) {
      case CardSize.large:
        return Column(
          key: const ValueKey('classic'),
          children: [
            notesTile,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: highlightsTile),
                const SizedBox(width: 12),
                Expanded(child: bookmarksTile),
              ],
            ),
          ],
        );
      case CardSize.medium:
        return IntrinsicHeight(
          child: Row(
            key: const ValueKey('halfAndHalf'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    highlightsTile,
                    const SizedBox(height: 12),
                    bookmarksTile,
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: notesTile),
            ],
          ),
        );
      case CardSize.small:
        return IntrinsicHeight(
          child: Row(
            key: const ValueKey('compactRow'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: highlightsTile),
              const SizedBox(width: 8),
              Expanded(flex: 3, child: bookmarksTile),
              const SizedBox(width: 8),
              Expanded(flex: 4, child: notesTile),
            ],
          ),
        );
    }
  }
}

class _MinimalTile extends StatelessWidget {
  final String type;
  final IconData icon;

  const _MinimalTile({required this.type, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TexturedGlassContainer(
      isScrollable: false,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: () {
          // Allow long press to bubble up or handle here
        },
        onTap: () {
          if (type == 'Notes') {
            Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const NotesListScreen()));
          } else if (type == 'Highlights') {
            Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const HighlightsScreen()));
          } else if (type == 'Bookmarks') {
            Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const BookmarksScreen()));
          }
        },
        child: Center(
          child: Icon(icon, color: AppColors.goldAccent, size: 24),
        ),
      ),
    );
  }
}

class _NotesTile extends ConsumerWidget {
  final CardSize size;
  const _NotesTile({required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final latestNote = notes.isNotEmpty ? notes.first : null;

    final bool isCompact = size == CardSize.small;
    final bool isHalfAndHalf = size == CardSize.medium;

    return TexturedGlassContainer(
      isScrollable: false,
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.zero,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              if (latestNote != null) {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => NoteEditorScreen(
                    initialNote: latestNote,
                    noteIndex: 0,
                  ),
                ));
              } else {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => const NotesListScreen(),
                ));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (_) => const NotesListScreen(),
                          ));
                        },
                        child: Text(
                          'Notes',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isCompact) const SizedBox(height: 16),
                  if (!isCompact && notes.isNotEmpty) ...[
                    if (isHalfAndHalf) ...[
                      // Show up to 3 recent notes for Half & Half
                      ...notes.take(3).map((note) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title.isNotEmpty ? note.title : 'New Note',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              note.content.isNotEmpty ? note.content.replaceAll('\n', ' ') : 'No additional text',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )),
                    ] else ...[
                      Text(
                        latestNote!.date,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latestNote.title.isNotEmpty ? latestNote.title : 'New Note',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        latestNote.content.isNotEmpty ? latestNote.content.replaceAll('\n', ' ') : 'No additional text',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ] else if (!isCompact) ...[
                    Text(
                      'No notes yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
                      color: theme.primaryColor,
                      onPressed: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => const NoteEditorScreen(),
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HighlightsTile extends ConsumerWidget {
  final CardSize size;
  const _HighlightsTile({required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(highlightsProvider).length;
    final isCompact = size == CardSize.small;

    return TexturedGlassContainer(
      isScrollable: false,
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.zero,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => const HighlightsScreen(),
              ));
            },
            child: Container(
              padding: EdgeInsets.all(isCompact ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(Icons.format_paint_rounded, color: theme.primaryColor),
                  if (!isCompact) const SizedBox(height: 16),
                  if (isCompact) const SizedBox(height: 8),
                  Text(
                    '$count',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 18 : null,
                    ),
                  ),
                  Text(
                    'Highlights',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      fontSize: isCompact ? 10 : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookmarksTile extends ConsumerWidget {
  final CardSize size;
  const _BookmarksTile({required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(bookmarksProvider).length;
    final isCompact = size == CardSize.small;

    return TexturedGlassContainer(
      isScrollable: false,
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.zero,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => const BookmarksScreen(),
              ));
            },
            child: Container(
              padding: EdgeInsets.all(isCompact ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(Icons.bookmark_rounded, color: theme.primaryColor),
                  if (!isCompact) const SizedBox(height: 16),
                  if (isCompact) const SizedBox(height: 8),
                  Text(
                    '$count',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 18 : null,
                    ),
                  ),
                  Text(
                    'Bookmarks',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                      fontSize: isCompact ? 10 : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
