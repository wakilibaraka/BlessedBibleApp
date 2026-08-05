import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/user_data_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/nav_provider.dart';
import '../../theme/app_colors.dart';
import '../../state/bible_provider.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/animated_background.dart';
import '../../state/theme_provider.dart';

class _ParsedVerseData {
  final String bookAbbrev;
  final String bookName;
  final int chapter;
  final int verseNum;
  final String text;

  _ParsedVerseData({
    required this.bookAbbrev,
    required this.bookName,
    required this.chapter,
    required this.verseNum,
    required this.text,
  });
}

_ParsedVerseData? _parseVerseRef(
    String refStr, List<FlatChapter> flatChapters) {
  final underscoreIdx = refStr.indexOf('_');
  if (underscoreIdx == -1) return null;

  final abbrevUpper = refStr.substring(0, underscoreIdx);
  final cvStr = refStr.substring(underscoreIdx + 1);

  final cvParts = cvStr.split(':');
  if (cvParts.length != 2) return null;

  final chapter = int.tryParse(cvParts[0]);
  final verseNum = int.tryParse(cvParts[1]);
  if (chapter == null || verseNum == null) return null;

  final fcIndex = flatChapters.indexWhere(
    (c) =>
        c.book.abbreviation.toUpperCase() == abbrevUpper &&
        c.chapter.number == chapter,
  );
  if (fcIndex == -1) return null;

  final fc = flatChapters[fcIndex];
  final vIndex = fc.chapter.verses.indexWhere((v) => v.number == verseNum);
  if (vIndex == -1) return null;

  return _ParsedVerseData(
    bookAbbrev: fc.book.abbreviation,
    bookName: fc.book.name,
    chapter: chapter,
    verseNum: verseNum,
    text: fc.chapter.verses[vIndex].text,
  );
}

Widget _buildRealVerseCard(BuildContext context, WidgetRef ref, String refStr,
    _ParsedVerseData data, ThemeData theme,
    {int? highlightColorIndex}) {
  final formattedRef = '${data.bookName} ${data.chapter}:${data.verseNum}';
  final highlightColor = (highlightColorIndex != null &&
          highlightColorIndex >= 0 &&
          highlightColorIndex < highlightPalette.length)
      ? AppColors.getRenderedHighlightColor(
          highlightPalette[highlightColorIndex],
          theme.brightness,
          theme.scaffoldBackgroundColor)
      : null;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Container(
      decoration: BoxDecoration(
        color: highlightColor != null
            ? highlightColor.withValues(alpha: 0.18)
            : theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlightColor != null
              ? highlightColor.withValues(alpha: 0.35)
              : theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(readLocationProvider.notifier).updateLocation(
                bookAbbrev: data.bookAbbrev,
                bookName: data.bookName,
                chapter: data.chapter,
                verse: data.verseNum,
              );
          Navigator.of(context).pop(); // dismiss highlights screen
          ref.read(navProvider.notifier).setIndex(1);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formattedRef,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  if (highlightColor != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: highlightColor, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class HighlightsScreen extends ConsumerWidget {
  const HighlightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final highlights = ref.watch(highlightsProvider);
    final flatChapters = ref.watch(flatChaptersProvider);

    final groupedHighlights = <int, List<String>>{};
    for (final entry in highlights.entries) {
      groupedHighlights.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Highlights',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    "Verses you've marked in colour.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),
                Expanded(
                  child: groupedHighlights.isEmpty
                      ? Center(
                          child: Text(
                            "No highlights yet.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: highlightPalette.length,
                          itemBuilder: (context, colorIndex) {
                            final refs = groupedHighlights[colorIndex];
                            if (refs == null || refs.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 4.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                            color: AppColors.getRenderedHighlightColor(
                                                highlightPalette[colorIndex],
                                                theme.brightness,
                                                theme.scaffoldBackgroundColor),
                                            shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Highlighted',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                ...refs.map((refStr) {
                                  final data = _parseVerseRef(refStr, flatChapters);
                                  if (data == null) return const SizedBox.shrink();
                                  return _buildRealVerseCard(
                                      context, ref, refStr, data, theme,
                                      highlightColorIndex: colorIndex);
                                }),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
