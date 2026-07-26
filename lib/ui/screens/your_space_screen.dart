import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/user_data_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/nav_provider.dart';
import '../../theme/app_colors.dart';
import '../../state/user_data_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/notes_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/textured_glass_container.dart';
import 'notes_list_screen.dart';

class _VerseData {
  final String bookAbbrev;
  final String bookName;
  final int chapter;
  final int verseNum;
  final String text;

  _VerseData(
      this.bookAbbrev, this.bookName, this.chapter, this.verseNum, this.text);
}

class YourSpaceScreen extends ConsumerWidget {
  const YourSpaceScreen({super.key});

  _VerseData? _parseVerseRef(String refStr, List<dynamic> flatChapters) {
    try {
      final underscoreIdx = refStr.indexOf('_');
      if (underscoreIdx == -1) return null;
      final bookAbbrev = refStr.substring(0, underscoreIdx);
      final rest = refStr.substring(underscoreIdx + 1);
      final parts = rest.split(':');
      if (parts.length != 2) return null;
      final chapter = int.tryParse(parts[0]);
      final verseNum = int.tryParse(parts[1]);
      if (chapter == null || verseNum == null) return null;

      final fc = flatChapters.firstWhere(
        (c) => c.book.abbreviation == bookAbbrev && c.chapter.number == chapter,
      );
      if (verseNum - 1 >= 0 && verseNum - 1 < fc.chapter.verses.length) {
        final text = fc.chapter.verses[verseNum - 1].text;
        return _VerseData(bookAbbrev, fc.book.name, chapter, verseNum, text);
      }
    } catch (_) {}
    return null;
  }

  Widget _buildVerseCard(BuildContext context, WidgetRef ref, String refStr,
      _VerseData data, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TexturedGlassContainer(
        borderRadius: BorderRadius.circular(16),
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(readLocationProvider.notifier).updateLocation(
                  bookAbbrev: data.bookAbbrev,
                  bookName: data.bookName,
                  chapter: data.chapter,
                  verse: data.verseNum,
                );
            Navigator.of(context).pop();
            ref.read(navProvider.notifier).setIndex(1); // Jump to read
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.bookName} ${data.chapter}:${data.verseNum}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontFamily: 'GentiumBookPlus',
                    fontSize: 16,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      ThemeData theme, IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 64, color: theme.primaryColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final highlights = ref.watch(highlightsProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final bookmarksList = bookmarks.toList();
    final notes = ref.watch(notesProvider);
    final flatChapters = ref.watch(flatChaptersProvider);

    // Group highlights by color
    final groupedHighlights = <int, List<String>>{};
    for (final entry in highlights.entries) {
      groupedHighlights.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Your Space',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.note_add_rounded, color: theme.primaryColor),
            onPressed: () => showAddNoteSheet(context, ref, theme),
            tooltip: 'Add Note',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          CustomScrollView(
            slivers: [
              // ── Highlights Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Highlights',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Verses you've marked in colour — the ones that stood out and spoke to you.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (groupedHighlights.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: _buildEmptyState(theme, Icons.auto_awesome, 'No highlights yet', 'Color-code a verse to see it here.'),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, colorIndex) {
                      final refs = groupedHighlights[colorIndex];
                      if (refs == null || refs.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16, height: 16,
                                    decoration: BoxDecoration(color: highlightPalette[colorIndex], shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Highlighted',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            ...refs.map((refStr) {
                              final data = _parseVerseRef(refStr, flatChapters);
                              if (data == null) return const SizedBox.shrink();
                              return _buildVerseCard(context, ref, refStr, data, theme);
                            }),
                          ],
                        ),
                      );
                    },
                    childCount: highlightPalette.length,
                  ),
                ),

              // ── Bookmarks Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bookmarks',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Verses you've set aside to study more — passages to come back to, wrestle with, or understand deeper.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (bookmarks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: _buildEmptyState(theme, Icons.bookmark_border, 'No saved verses', 'Select a verse and tap the bookmark icon to save it.'),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final refStr = bookmarksList[index];
                      final data = _parseVerseRef(refStr, flatChapters);
                      if (data == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildVerseCard(context, ref, refStr, data, theme),
                      );
                    },
                    childCount: bookmarksList.length,
                  ),
                ),

              // ── Notes Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    'My Notes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldAccent,
                    ),
                  ),
                ),
              ),
              if (notes.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: _buildEmptyState(theme, Icons.edit_note_rounded, 'No notes yet', 'Tap the + icon above to write your first note.'),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = notes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Dismissible(
                          key: ValueKey(note.title + note.date + index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ref.read(notesProvider.notifier).remove(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TexturedGlassContainer(
                              borderRadius: BorderRadius.circular(16),
                              padding: EdgeInsets.zero,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  if (note.reference != null) {
                                    final data = _parseVerseRef(note.reference!, flatChapters);
                                    if (data != null) {
                                      ref.read(readLocationProvider.notifier).updateLocation(
                                        bookAbbrev: data.bookAbbrev,
                                        bookName: data.bookName,
                                        chapter: data.chapter,
                                        verse: data.verseNum,
                                      );
                                      Navigator.of(context).pop();
                                      ref.read(navProvider.notifier).setIndex(1); // Jump to read
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              note.title,
                                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            note.date,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (note.reference != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          note.reference!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        note.content,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: notes.length,
                  ),
                ),
                
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }
}
