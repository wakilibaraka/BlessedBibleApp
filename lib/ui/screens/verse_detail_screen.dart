import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/bible_provider.dart';
import '../../state/commentary_provider.dart';
import '../../state/user_data_provider.dart';
import '../../state/notes_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/textured_glass_container.dart';
import 'notes_list_screen.dart'; // for showAddNoteSheet
import '../widgets/shared_app_bar.dart';

class VerseDetailScreen extends ConsumerWidget {
  final String reference;

  const VerseDetailScreen({super.key, required this.reference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);

    // Parse reference safely using Regex (supports "Genesis 1:3" and "GEN_1:3")
    final refRegex = RegExp(r'^(.+?)[_\s]+(\d+):(\d+)$');
    final match = refRegex.firstMatch(reference.trim());

    String bookName = reference;
    int? chapterNum;
    int? verseNum;

    if (match != null) {
      bookName = match.group(1)!.trim();
      chapterNum = int.parse(match.group(2)!);
      verseNum = int.parse(match.group(3)!);
    }

    // Get flat chapters
    final flatChapters = ref.watch(flatChaptersProvider);
    String verseText = 'Loading...';
    String verseKey = '';

    if (chapterNum != null && verseNum != null && flatChapters.isNotEmpty) {
      try {
        final fc = flatChapters.firstWhere((c) =>
            (c.book.name.toLowerCase() == bookName.toLowerCase() ||
                c.book.abbreviation.toLowerCase() == bookName.toLowerCase()) &&
            c.chapter.number == chapterNum);
        if (verseNum - 1 >= 0 && verseNum - 1 < fc.chapter.verses.length) {
          verseText = fc.chapter.verses[verseNum - 1].text;
          verseKey =
              generateVerseKey(fc.book.abbreviation, chapterNum, verseNum);
        } else {
          verseText = 'Verse $verseNum out of bounds.';
        }
      } catch (_) {
        verseText = 'Verse text not found for $bookName $chapterNum:$verseNum';
      }
    } else if (chapterNum == null || verseNum == null) {
      verseText = 'Invalid reference format.';
    }

    // Commentary Data
    final commentaryAsync = ref.watch(commentaryProvider);
    List<dynamic> commentaryEntries = [];
    if (commentaryAsync.value != null) {
      final entries = commentaryAsync.value!;
      commentaryEntries = entries.where((e) => 
        e.scope.book?.toLowerCase() == bookName.toLowerCase() &&
        e.scope.chapter == chapterNum &&
        e.scope.verse == verseNum
      ).toList();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(reference,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TexturedGlassContainer(
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\u201c$verseText\u201d',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFamily: 'GentiumBookPlus',
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            reference,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (verseKey.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _PersonalDataRow(
                        verseKey: verseKey, reference: reference),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    'COMMENTARY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (commentaryAsync.isLoading)
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (commentaryEntries.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books_rounded,
                              size: 48,
                              color: theme.primaryColor.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'No commentary yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Commentary for this verse has not been loaded.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      try {
                        final entry = commentaryEntries[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16.0, left: 16.0, right: 16.0),
                          child: TexturedGlassContainer(
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.text,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      height: 1.6,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.library_books_rounded,
                                          size: 14,
                                          color: theme.primaryColor
                                              .withValues(alpha: 0.7)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          entry.title,
                                          style:
                                              theme.textTheme.labelSmall?.copyWith(
                                            color: theme.primaryColor
                                                .withValues(alpha: 0.8),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16.0, left: 16.0, right: 16.0),
                          child: TexturedGlassContainer(
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'Content unavailable',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.primaryColor.withValues(alpha: 0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    childCount: commentaryEntries.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonalDataRow extends ConsumerWidget {
  final String verseKey;
  final String reference;

  const _PersonalDataRow({required this.verseKey, required this.reference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarks = ref.watch(bookmarksProvider);
    final highlights = ref.watch(highlightsProvider);
    final notes = ref.watch(notesProvider);

    final isBookmarked = bookmarks.contains(verseKey);
    final highlightColorIndex = highlights[verseKey];
    final hasNote = notes.any((n) => n.reference == reference);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            label: isBookmarked ? 'Saved' : 'Save',
            isActive: isBookmarked,
            onTap: () {
              ref.read(bookmarksProvider.notifier).toggle(verseKey);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.border_color_rounded,
            label: highlightColorIndex != null ? 'Highlighted' : 'Highlight',
            isActive: highlightColorIndex != null,
            activeColor: highlightColorIndex != null
                ? AppColors.getRenderedHighlightColor(highlightPalette[highlightColorIndex], Theme.of(context).brightness, Theme.of(context).scaffoldBackgroundColor)
                : null,
            onTap: () {
              int nextColor = 0;
              if (highlightColorIndex != null) {
                nextColor = (highlightColorIndex + 1) % highlightPalette.length;
                if (highlightColorIndex == highlightPalette.length - 1) {
                  ref
                      .read(highlightsProvider.notifier)
                      .toggleHighlight(verseKey, highlightColorIndex);
                  return;
                }
              }
              ref
                  .read(highlightsProvider.notifier)
                  .toggleHighlight(verseKey, nextColor);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: hasNote ? Icons.note_rounded : Icons.note_add_outlined,
            label: hasNote ? 'Notes' : 'Add Note',
            isActive: hasNote,
            onTap: () {
              showAddNoteSheet(context, ref, theme,
                  initialReference: reference);
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.isActive,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = activeColor ??
        (isActive
            ? theme.primaryColor
            : theme.colorScheme.onSurface.withValues(alpha: 0.6));

    return GestureDetector(
      onTap: onTap,
      child: TexturedGlassContainer(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
