import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/user_data_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/nav_provider.dart';
import '../../state/bible_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/textured_glass_container.dart';

class YourSpaceScreen extends ConsumerWidget {
  const YourSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final highlights = ref.watch(highlightsProvider);
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
        title: Text('Your Space', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          groupedHighlights.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 64, color: theme.primaryColor.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No highlights yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Color-code a verse to see it here.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
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
                          String verseText = '...';
                          // Try to find the text
                          try {
                            final parts = refStr.split(':');
                            if (parts.length == 2) {
                              final bookChap = parts[0];
                              final verseNum = int.parse(parts[1]);
                              final lastSpace = bookChap.lastIndexOf(' ');
                              if (lastSpace != -1) {
                                final bookName = bookChap.substring(0, lastSpace);
                                final chapter = int.parse(bookChap.substring(lastSpace + 1));
                                final fc = flatChapters.firstWhere((c) => c.book.name == bookName && c.chapter.number == chapter);
                                if (verseNum - 1 >= 0 && verseNum - 1 < fc.chapter.verses.length) {
                                  verseText = fc.chapter.verses[verseNum - 1].text;
                                }
                              }
                            }
                          } catch (_) {}

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TexturedGlassContainer(
                              borderRadius: BorderRadius.circular(16),
                              padding: EdgeInsets.zero,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  try {
                                    final parts = refStr.split(':');
                                    final bookChap = parts[0];
                                    final verseNum = int.parse(parts[1]);
                                    final lastSpace = bookChap.lastIndexOf(' ');
                                    final bookName = bookChap.substring(0, lastSpace);
                                    final chapter = int.parse(bookChap.substring(lastSpace + 1));
                                    
                                    ref.read(readLocationProvider.notifier).updateLocation(
                                      bookName: bookName,
                                      chapter: chapter,
                                      verse: verseNum,
                                    );
                                    Navigator.of(context).pop();
                                    ref.read(navProvider.notifier).setIndex(1); // Jump to read
                                  } catch (_) {}
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        refStr,
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        verseText,
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
                        }),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }
}
