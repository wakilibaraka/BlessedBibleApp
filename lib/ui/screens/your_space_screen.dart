import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/user_data_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/bible_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/textured_glass_container.dart';

class _VerseData {
  final String bookAbbrev;
  final String bookName;
  final int chapter;
  final int verseNum;
  final String text;
  
  _VerseData(this.bookAbbrev, this.bookName, this.chapter, this.verseNum, this.text);
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

  Widget _buildVerseCard(BuildContext context, WidgetRef ref, String refStr, _VerseData data, ThemeData theme) {
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

  Widget _buildEmptyState(ThemeData theme, IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.primaryColor.withValues(alpha: 0.5)),
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
    final favorites = ref.watch(favoritesProvider);
    final flatChapters = ref.watch(flatChaptersProvider);

    // Group highlights by color
    final groupedHighlights = <int, List<String>>{};
    for (final entry in highlights.entries) {
      groupedHighlights.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Your Space', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Highlights'),
              Tab(text: 'Bookmarks'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBackground(appThemeMode: appThemeMode),
            ),
            TabBarView(
              children: [
                // Highlights Tab
                groupedHighlights.isEmpty
                    ? _buildEmptyState(
                        theme, 
                        Icons.auto_awesome, 
                        'No highlights yet', 
                        'Color-code a verse to see it here.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
                        itemCount: highlightPalette.length,
                        itemBuilder: (context, colorIndex) {
                          final refs = groupedHighlights[colorIndex];
                          if (refs == null || refs.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16, height: 16,
                                      decoration: BoxDecoration(
                                        color: highlightPalette[colorIndex],
                                        shape: BoxShape.circle,
                                      ),
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
                          );
                        },
                      ),
                
                // Bookmarks Tab
                bookmarks.isEmpty
                    ? _buildEmptyState(
                        theme, 
                        Icons.bookmark_border, 
                        'No bookmarks yet', 
                        'No bookmarks yet — select a verse and tap the bookmark icon',
                      )
                    : ListView(
                        padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
                        children: bookmarks.map((refStr) {
                          final data = _parseVerseRef(refStr, flatChapters);
                          if (data == null) return const SizedBox.shrink();
                          return _buildVerseCard(context, ref, refStr, data, theme);
                        }).toList(),
                      ),

                // Favorites Tab
                favorites.isEmpty
                    ? _buildEmptyState(
                        theme, 
                        Icons.star_border, 
                        'No favorites yet', 
                        'No favorites yet — select a verse and tap the star icon',
                      )
                    : ListView(
                        padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
                        children: favorites.map((refStr) {
                          final data = _parseVerseRef(refStr, flatChapters);
                          if (data == null) return const SizedBox.shrink();
                          return _buildVerseCard(context, ref, refStr, data, theme);
                        }).toList(),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
