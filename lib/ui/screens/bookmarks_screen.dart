import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/user_data_provider.dart';
import '../../state/bible_provider.dart';
import '../../data/models/home_data.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/animated_background.dart';
import '../../state/theme_provider.dart';
import 'note_editor_screen.dart';

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

Widget _buildBookmarkCard(BuildContext context, WidgetRef ref, String refStr,
    _ParsedVerseData data, ThemeData theme) {
  final formattedRef = '${data.bookName} ${data.chapter}:${data.verseNum}';

  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Open editor for this bookmark!
          final initialNote = PersonalNote('', '', '', reference: refStr);
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => NoteEditorScreen(
              initialNote: initialNote,
            ),
          ));
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
                  Icon(Icons.edit_note_rounded,
                      size: 20,
                      color: theme.primaryColor.withValues(alpha: 0.7)),
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

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final bookmarks = ref.watch(bookmarksProvider).toList();
    final flatChapters = ref.watch(flatChaptersProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Bookmarks',
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
                    "Verses you're reflecting on. Tap any bookmark to add a note.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),
                Expanded(
                  child: bookmarks.isEmpty
                      ? Center(
                          child: Text(
                            "No bookmarks yet.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: bookmarks.length,
                          itemBuilder: (context, index) {
                            final refStr = bookmarks[index];
                            final data = _parseVerseRef(refStr, flatChapters);
                            if (data == null) return const SizedBox.shrink();
                            return _buildBookmarkCard(
                                context, ref, refStr, data, theme);
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
