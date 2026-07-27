import re

with open('lib/ui/screens/main_nav_screen.dart', 'r') as f:
    content = f.read()

# 1. Add VerseActionStyle style and isMinimalAction to Builder
builder_pattern = r"(final double rawWidth = MediaQuery\.of\(context\)\.size\.width;)"
builder_replacement = r"""final style = ref.watch(readSettingsProvider.select((s) => s.verseActionStyle));
            final isMinimalAction = currentIndex == 1 && selectedVerses.isNotEmpty && style == VerseActionStyle.horizontal;
            \1"""
content = re.sub(builder_pattern, builder_replacement, content, count=1)

# 2. Update height
height_pattern = r"(final double height =\s*)\(currentIndex == 1 && selectedVerses.isNotEmpty\) \? 420\.0 : 72\.0;"
height_replacement = r"\1(currentIndex == 1 && selectedVerses.isNotEmpty && style != VerseActionStyle.horizontal) ? 420.0 : 72.0;"
content = re.sub(height_pattern, height_replacement, content, count=1)

# 3. Morph the nav tabs
nav_tabs_pattern = r"(child:\s*)Row\(\s*key: const ValueKey\('nav_tabs'\),\s*mainAxisAlignment:\s*MainAxisAlignment\.spaceBetween,\s*children: \["
nav_tabs_replacement = r"""\1isMinimalAction
                                            ? _buildStyle3ActionRow(context, ref, Theme.of(context))
                                            : Row(
                                                key: const ValueKey('nav_tabs'),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: ["""
content = re.sub(nav_tabs_pattern, nav_tabs_replacement, content, count=1)

# 4. Hide classic FAB when isMinimalAction
fab_end_pattern = r"end:\s*\(currentIndex == 1 && selectedVerses.isNotEmpty\)\s*\? 380\.0\s*: 56\.0,"
fab_end_replacement = r"end: (currentIndex == 1 && selectedVerses.isNotEmpty && style != VerseActionStyle.horizontal) ? 380.0 : 56.0,"
content = re.sub(fab_end_pattern, fab_end_replacement, content, count=1)

is_action_pattern = r"final bool isAction =\s*currentIndex == 1 && selectedVerses.isNotEmpty;"
is_action_replacement = r"final bool isAction = currentIndex == 1 && selectedVerses.isNotEmpty && style != VerseActionStyle.horizontal;"
content = re.sub(is_action_pattern, is_action_replacement, content, count=1)

# 5. Add VerseActionLogic calls to the classic menu
# Find the bookmark action in _buildActionMenuIcons
bookmark_action = r"""final bookmarks = ref\.read\(bookmarksProvider\);
\s*final isAllBookmarked = selectedVerses\.every\(\(v\) =>
\s*bookmarks\.contains\(generateVerseKey\(
\s*readLoc\.bookAbbrev, readLoc\.chapter, v\)\)\);
\s*for \(var v in selectedVerses\) \{
\s*final refStr =
\s*generateVerseKey\(readLoc\.bookAbbrev, readLoc\.chapter, v\);
\s*if \(isAllBookmarked\) \{
\s*ref\.read\(bookmarksProvider\.notifier\)\.toggle\(refStr\);
\s*\} else \{
\s*if \(\!bookmarks\.contains\(refStr\)\) \{
\s*ref\.read\(bookmarksProvider\.notifier\)\.toggle\(refStr\);
\s*\}
\s*\}
\s*\}
\s*ScaffoldMessenger\.of\(context\)\.showSnackBar\(
\s*SnackBar\(
\s*content: Text\(isAllBookmarked
\s*\? 'Bookmark\(s\) removed'
\s*: '\$\{selectedVerses\.length\} verse\(s\) bookmarked\!'\),
\s*duration: const Duration\(seconds: 2\),
\s*\),
\s*\);
\s*ref\.read\(readSelectionProvider\.notifier\)\.clear\(\);"""

bookmark_replacement = r"""VerseActionLogic.handleBookmark(ref, readLoc.bookAbbrev, readLoc.chapter, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();"""
content = re.sub(bookmark_action, bookmark_replacement, content, count=1)


copy_action = r"""final flatChapters = ref\.read\(flatChaptersProvider\);
\s*if \(flatChapters\.isNotEmpty\) \{
\s*try \{
\s*final chapter = flatChapters
\s*\.firstWhere\(
\s*\(c\) =>
\s*c\.book\.name == readLoc\.bookName &&
\s*c\.chapter\.number == readLoc\.chapter,
\s*\)
\s*\.chapter;
\s*final formattedText = ShareService\.formatVerses\(
\s*bookName: readLoc\.bookName,
\s*chapterNumber: readLoc\.chapter,
\s*verseNumbers: selectedVerses\.toList\(\),
\s*chapterData: chapter,
\s*\);
\s*ShareService\.copyText\(context, formattedText\);
\s*\} catch \(\_\) \{\}
\s*\}
\s*ref\.read\(readSelectionProvider\.notifier\)\.clear\(\);"""

copy_replacement = r"""dynamic chapterData;
                final flatChapters = ref.read(flatChaptersProvider);
                if (flatChapters.isNotEmpty) {
                  try {
                    chapterData = flatChapters.firstWhere((c) => c.book.name == readLoc.bookName && c.chapter.number == readLoc.chapter).chapter;
                  } catch (_) {}
                }
                VerseActionLogic.handleCopy(context, readLoc.bookName, readLoc.chapter, selectedVerses.toList(), chapterData);
                ref.read(readSelectionProvider.notifier).clear();"""
content = re.sub(copy_action, copy_replacement, content, count=1)


note_action = r"""final sorted = selectedVerses\.toList\(\)\.\.sort\(\);
\s*final refStr =
\s*'\$\{readLoc\.bookName\} \$\{readLoc\.chapter\}:\$\{sorted\.join\(', '\)\}';
\s*showAddNoteSheet\(context, ref, theme, initialReference: refStr\);
\s*ref\.read\(readSelectionProvider\.notifier\)\.clear\(\);"""

note_replacement = r"""VerseActionLogic.handleNote(context, ref, theme, readLoc.bookName, readLoc.chapter, selectedVerses.toList());
                ref.read(readSelectionProvider.notifier).clear();"""
content = re.sub(note_action, note_replacement, content, count=1)

# Replace Commentary which is hidden behind the auto_awesome icon? Wait, let's see.
awesome_action = r"""IconButton\(
\s*icon: const Icon\(Icons\.auto_awesome\),
\s*color: Colors\.redAccent,
\s*tooltip: 'Deep Study',
\s*padding: EdgeInsets\.zero,
\s*constraints: const BoxConstraints\(\),
\s*visualDensity: VisualDensity\.compact,
\s*onPressed: \(\) \{
\s*ref\.read\(navProvider\.notifier\)\.setIndex\(3\);
\s*ref\.read\(readSelectionProvider\.notifier\)\.clear\(\);
\s*\}\),"""

# Wait, the user wants "Bookmark, Copy, Note, Commentary (bulb)" for Classic!
# In the pristine file, it has auto_awesome (Deep Study).
# I need to change auto_awesome to lightbulb_outline_rounded (Commentary).
commentary_replacement = r"""_buildActionIcon(
              Icons.lightbulb_outline_rounded,
              'Commentary',
              theme.colorScheme.onSurface,
              () {
                dynamic chapterData;
                final flatChapters = ref.read(flatChaptersProvider);
                if (flatChapters.isNotEmpty) {
                  try {
                    chapterData = flatChapters.firstWhere((c) => c.book.name == readLoc.bookName && c.chapter.number == readLoc.chapter).chapter;
                  } catch (_) {}
                }
                final targetVerses = selectedVerses.toList();
                VerseActionLogic.handleCommentary(context, readLoc.bookName, readLoc.chapter, targetVerses.isNotEmpty ? targetVerses.first : 1, targetVerses, chapterData);
                ref.read(readSelectionProvider.notifier).clear();
              },
            ),"""
content = re.sub(awesome_action, commentary_replacement, content, count=1)

# Add _buildStyle3ActionRow at the bottom before the last brace
style3_row = r"""
  Widget _buildStyle3ActionRow(BuildContext context, WidgetRef ref, ThemeData theme) {
    final readLoc = ref.watch(readLocationProvider);
    final selectedVerses = ref.watch(readSelectionProvider);
    final targetVerses = selectedVerses.toList();
    final bookmarks = ref.watch(bookmarksProvider);
    final bookAbbrev = readLoc.bookAbbrev;
    final chapterNum = readLoc.chapter;
    final bookName = readLoc.bookName;
    
    dynamic chapterData;
    final flatChapters = ref.read(flatChaptersProvider);
    if (flatChapters.isNotEmpty) {
      try {
        chapterData = flatChapters.firstWhere(
          (c) => c.book.name == bookName && c.chapter.number == chapterNum,
          orElse: () => flatChapters.first,
        ).chapter;
      } catch (_) {}
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        key: const ValueKey('nav_tabs_style3'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionIcon(
            targetVerses.every((v) => bookmarks.contains(generateVerseKey(bookAbbrev, chapterNum, v)))
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            'Bookmark',
            targetVerses.every((v) => bookmarks.contains(generateVerseKey(bookAbbrev, chapterNum, v)))
                ? theme.primaryColor
                : theme.colorScheme.onSurface,
            () {
              VerseActionLogic.handleBookmark(ref, bookAbbrev, chapterNum, targetVerses);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          _buildActionIcon(
            Icons.copy_rounded,
            'Copy',
            theme.colorScheme.onSurface,
            () {
              VerseActionLogic.handleCopy(context, bookName, chapterNum, targetVerses, chapterData);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          _buildActionIcon(
            Icons.edit_document,
            'Note',
            theme.colorScheme.onSurface,
            () {
              VerseActionLogic.handleNote(context, ref, theme, bookName, chapterNum, targetVerses);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          _buildActionIcon(
            Icons.lightbulb_outline_rounded,
            'Commentary',
            theme.colorScheme.onSurface,
            () {
              VerseActionLogic.handleCommentary(context, bookName, chapterNum, targetVerses.isNotEmpty ? targetVerses.first : 1, targetVerses, chapterData);
              ref.read(readSelectionProvider.notifier).clear();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(width: 1, height: 28, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          ),
          _buildColorDotRow(context, ref),
          _buildActionIcon(
            Icons.close_rounded,
            'Close',
            theme.colorScheme.onSurface.withValues(alpha: 0.5),
            () => ref.read(readSelectionProvider.notifier).clear(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDotRow(BuildContext context, WidgetRef ref) {
    final readSettings = ref.watch(readSettingsProvider);
    final activeIndex = readSettings.activeHighlightColorIndex;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(highlightPalette.length, (i) {
        return _buildColorDot(
          highlightPalette[i],
          isSelected: i == activeIndex,
          onTap: () {
            ref.read(readSettingsProvider.notifier).setActiveHighlightColorIndex(i);
            
            final readLoc = ref.read(readLocationProvider);
            final targetVerses = ref.read(readSelectionProvider).toList();
            VerseActionLogic.handleHighlight(ref, readLoc.bookAbbrev, readLoc.chapter, targetVerses, i);
            ref.read(readSelectionProvider.notifier).clear();
          },
        );
      }),
    );
  }
}
"""
content = re.sub(r"\}\n*$", style3_row, content)

with open('lib/ui/screens/main_nav_screen.dart', 'w') as f:
    f.write(content)

print("Done")
