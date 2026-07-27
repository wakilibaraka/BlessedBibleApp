import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/user_data_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/nav_provider.dart';
import '../../theme/app_colors.dart';
import '../../state/bible_provider.dart';
import '../../state/notes_provider.dart';
import '../../state/theme_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/shared_app_bar.dart';
import 'notes_list_screen.dart'; // for showAddNoteSheet

class YourSpaceScreen extends ConsumerStatefulWidget {
  const YourSpaceScreen({super.key});

  @override
  ConsumerState<YourSpaceScreen> createState() => _YourSpaceScreenState();
}

class _YourSpaceScreenState extends ConsumerState<YourSpaceScreen> {
  int _selectedIndex = 0; // 0=Highlights, 1=Bookmarks, 2=Notes
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);

    return Scaffold(
      extendBody: true,
      appBar: SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Your Space',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Segmented Control Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentTab(
                        label: 'Highlights',
                        isSelected: _selectedIndex == 0,
                        onTap: () => _onTabTapped(0),
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _SegmentTab(
                        label: 'Bookmarks',
                        isSelected: _selectedIndex == 1,
                        onTap: () => _onTabTapped(1),
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _SegmentTab(
                        label: 'Notes',
                        isSelected: _selectedIndex == 2,
                        onTap: () => _onTabTapped(2),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
              
              // ── Segment Content ──
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  children: [
                    _HighlightsSegment(theme: theme),
                    _BookmarksSegment(theme: theme),
                    _NotesSegment(theme: theme),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldAccent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.goldAccent.withValues(alpha: 0.5) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? AppColors.goldAccent : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HIGHLIGHTS SEGMENT
// ─────────────────────────────────────────────────────────────────────────────
class _HighlightsSegment extends ConsumerWidget {
  final ThemeData theme;
  const _HighlightsSegment({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlights = ref.watch(highlightsProvider);
    final flatChapters = ref.watch(flatChaptersProvider);

    final groupedHighlights = <int, List<String>>{};
    for (final entry in highlights.entries) {
      groupedHighlights.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
              ? const SizedBox.shrink()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: highlightPalette.length,
                  itemBuilder: (context, colorIndex) {
                    final refs = groupedHighlights[colorIndex];
                    if (refs == null || refs.isEmpty) return const SizedBox.shrink();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(color: AppColors.getRenderedHighlightColor(highlightPalette[colorIndex], theme.brightness, theme.scaffoldBackgroundColor), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Highlighted',
                                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        ...refs.map((refStr) {
                          final data = _parseVerseRef(refStr, flatChapters);
                          if (data == null) return const SizedBox.shrink();
                          return _buildRealVerseCard(context, ref, refStr, data, theme, highlightColorIndex: colorIndex);
                        }),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOKMARKS SEGMENT
// ─────────────────────────────────────────────────────────────────────────────
class _BookmarksSegment extends ConsumerWidget {
  final ThemeData theme;
  const _BookmarksSegment({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider).toList();
    final flatChapters = ref.watch(flatChaptersProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            "Verses you're going to reflect on and study more.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
        Expanded(
          child: bookmarks.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final refStr = bookmarks[index];
                    final data = _parseVerseRef(refStr, flatChapters);
                    if (data == null) return const SizedBox.shrink();
                    return _buildRealVerseCard(context, ref, refStr, data, theme, isBookmarked: true);
                  },
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTES SEGMENT
// ─────────────────────────────────────────────────────────────────────────────
class _NotesSegment extends ConsumerWidget {
  final ThemeData theme;
  const _NotesSegment({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final flatChapters = ref.watch(flatChaptersProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your notes.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: theme.primaryColor),
                onPressed: () => showAddNoteSheet(context, ref, theme),
              ),
            ],
          ),
        ),
        Expanded(
          child: notes.isEmpty
              ? Center(
                  child: Text(
                    'No notes yet.\nTap + to create one.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
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
                                Navigator.of(context).pop(); // dismiss your space screen
                                ref.read(navProvider.notifier).setIndex(1);
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
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      note.date,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                if (note.reference != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    note.reference!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  note.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
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
                  },
                ),
        ),
      ],
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────


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

/// Parses a verse reference key in the format produced by generateVerseKey:
/// "ABBREV_chapter:verse" (e.g. "GN_1:1", "MT_5:3").
/// Returns null if the key is malformed or the verse cannot be found in flatChapters.
_ParsedVerseData? _parseVerseRef(String refStr, List<FlatChapter> flatChapters) {
  // Format: "ABBREV_chapter:verse"
  final underscoreIdx = refStr.indexOf('_');
  if (underscoreIdx == -1) return null;

  final abbrevUpper = refStr.substring(0, underscoreIdx); // e.g. "GN"
  final cvStr = refStr.substring(underscoreIdx + 1);       // e.g. "1:1"

  final cvParts = cvStr.split(':');
  if (cvParts.length != 2) return null;

  final chapter = int.tryParse(cvParts[0]);
  final verseNum = int.tryParse(cvParts[1]);
  if (chapter == null || verseNum == null) return null;

  // Match by abbreviation case-insensitively (JSON stores lowercase, key stores uppercase)
  final fcIndex = flatChapters.indexWhere(
    (c) => c.book.abbreviation.toUpperCase() == abbrevUpper && c.chapter.number == chapter,
  );
  if (fcIndex == -1) return null;

  final fc = flatChapters[fcIndex];
  final vIndex = fc.chapter.verses.indexWhere((v) => v.number == verseNum);
  if (vIndex == -1) return null;

  return _ParsedVerseData(
    bookAbbrev: fc.book.abbreviation, // canonical lowercase from JSON
    bookName: fc.book.name,
    chapter: chapter,
    verseNum: verseNum,
    text: fc.chapter.verses[vIndex].text,
  );
}

Widget _buildRealVerseCard(
    BuildContext context, WidgetRef ref, String refStr, _ParsedVerseData data, ThemeData theme,
    {int? highlightColorIndex, bool isBookmarked = false}) {
  final formattedRef = '${data.bookName} ${data.chapter}:${data.verseNum}';
  final highlightColor = (highlightColorIndex != null && highlightColorIndex >= 0 && highlightColorIndex < highlightPalette.length)
      ? AppColors.getRenderedHighlightColor(highlightPalette[highlightColorIndex], theme.brightness, theme.scaffoldBackgroundColor)
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
          Navigator.of(context).pop(); // dismiss your space screen
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
                  if (isBookmarked)
                    Icon(Icons.bookmark_rounded, size: 16, color: theme.primaryColor.withValues(alpha: 0.7)),
                  if (highlightColor != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: highlightColor, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                data.text,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  decoration: isBookmarked ? TextDecoration.underline : null,
                  decorationColor: isBookmarked ? theme.primaryColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

