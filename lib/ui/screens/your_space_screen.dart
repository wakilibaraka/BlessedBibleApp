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
import '../../services/share_service.dart';
import '../../state/translation_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../data/models/bookmark_model.dart';

class YourSpaceScreen extends ConsumerStatefulWidget {
  final int initialTab; // 0=Highlights, 1=Bookmarks, 2=Notes
  const YourSpaceScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<YourSpaceScreen> createState() => _YourSpaceScreenState();
}

class YourSpaceExpandedChipsNotifier extends Notifier<Map<String, String?>> {
  @override
  Map<String, String?> build() => {};

  void setLanguage(String refStr, String translationId) {
    state = {...state, refStr: translationId};
  }

  void clear(String refStr) {
    final newState = Map<String, String?>.from(state);
    newState.remove(refStr);
    state = newState;
  }
}

final yourSpaceExpandedChipsProvider =
    NotifierProvider<YourSpaceExpandedChipsNotifier, Map<String, String?>>(
        YourSpaceExpandedChipsNotifier.new);

class _YourSpaceScreenState extends ConsumerState<YourSpaceScreen> {
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          if (_selectedIndex == 0) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
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
          SafeArea(
            bottom: false,
            child: Column(
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
          ),
        ],
      ),
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
          color: isSelected
              ? AppColors.goldAccent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.goldAccent.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? AppColors.goldAccent
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOKMARKS SEGMENT
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// BOOKMARK FOLDER DIALOGS
// ─────────────────────────────────────────────────────────────────────────────

void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(bookmarkDataProvider.notifier).addFolder(nameController.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}

void _showRenameFolderDialog(BuildContext context, WidgetRef ref, String folderId, String currentName) {
  final nameController = TextEditingController(text: currentName);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(bookmarkDataProvider.notifier).renameFolder(folderId, nameController.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      );
    },
  );
}

void _showDeleteFolderDialog(BuildContext context, WidgetRef ref, String folderId, String folderName) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text('Are you sure you want to delete "$folderName"?\n\nYour bookmarks inside this folder will NOT be deleted; they will be moved to Unfiled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(bookmarkDataProvider.notifier).deleteFolder(folderId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

void _showMoveToFolderSheet(BuildContext context, WidgetRef ref, String refStr, ThemeData theme) {
  final bookmarkData = ref.read(bookmarkDataProvider);
  final currentFolderId = bookmarkData.nodes[refStr]?.folderId;

  showModalBottomSheet(
    context: context,
    backgroundColor: theme.scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Move to Folder', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Unfiled'),
                trailing: currentFolderId == null ? Icon(Icons.check, color: theme.primaryColor) : null,
                onTap: () {
                  ref.read(bookmarkDataProvider.notifier).moveBookmark(refStr, null);
                  Navigator.pop(context);
                },
              ),
              ...bookmarkData.folders.map((f) => ListTile(
                    title: Text(f.name),
                    trailing: currentFolderId == f.id ? Icon(Icons.check, color: theme.primaryColor) : null,
                    onTap: () {
                      ref.read(bookmarkDataProvider.notifier).moveBookmark(refStr, f.id);
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}

enum _BookmarkViewType { all, unfiled, folder, byDate, byBook }

class _BookmarksSegment extends ConsumerStatefulWidget {
  final ThemeData theme;
  const _BookmarksSegment({required this.theme});

  @override
  ConsumerState<_BookmarksSegment> createState() => _BookmarksSegmentState();
}

class _BookmarksSegmentState extends ConsumerState<_BookmarksSegment> {
  _BookmarkViewType _viewType = _BookmarkViewType.all;
  String? _selectedFolderId;

  @override
  Widget build(BuildContext context) {
    final bookmarkData = ref.watch(bookmarkDataProvider);
    final flatChapters = ref.watch(flatChaptersProvider);

    // Filter bookmarks
    List<BookmarkNode> filteredNodes = [];
    if (_viewType == _BookmarkViewType.all) {
      filteredNodes = bookmarkData.nodes.values.toList();
    } else if (_viewType == _BookmarkViewType.unfiled) {
      filteredNodes = bookmarkData.nodes.values.where((n) => n.folderId == null).toList();
    } else if (_viewType == _BookmarkViewType.folder && _selectedFolderId != null) {
      filteredNodes = bookmarkData.nodes.values.where((n) => n.folderId == _selectedFolderId).toList();
    } else if (_viewType == _BookmarkViewType.byDate || _viewType == _BookmarkViewType.byBook) {
      filteredNodes = bookmarkData.nodes.values.toList();
    }
    
    // Sort descending by created date
    filteredNodes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // For grouping
    Map<String, List<BookmarkNode>> groups = {};
    if (_viewType == _BookmarkViewType.byDate) {
      final now = DateTime.now();
      for (final n in filteredNodes) {
        final diff = now.difference(n.createdAt);
        String group = 'Earlier';
        if (diff.inDays <= 7) {
          group = 'Last 7 Days';
        } else if (diff.inDays <= 30) {
          group = 'Last 30 Days';
        }
        
        groups.putIfAbsent(group, () => []).add(n);
      }
    } else if (_viewType == _BookmarkViewType.byBook) {
      for (final n in filteredNodes) {
        final data = _parseVerseRef(n.reference, flatChapters);
        final group = data?.bookName ?? 'Unknown Book';
        groups.putIfAbsent(group, () => []).add(n);
      }
    }

    Widget content;
    if (_viewType == _BookmarkViewType.byDate || _viewType == _BookmarkViewType.byBook) {
      final groupKeys = groups.keys.toList();
      content = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: groupKeys.length,
        itemBuilder: (context, index) {
          final groupKey = groupKeys[index];
          final nodes = groups[groupKey]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  groupKey,
                  style: widget.theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.primary,
                  ),
                ),
              ),
              ...nodes.map((n) {
                final data = _parseVerseRef(n.reference, flatChapters);
                if (data == null) return const SizedBox.shrink();
                return _buildRealVerseCard(context, ref, n.reference, data, widget.theme, isBookmarked: true);
              }),
            ],
          );
        },
      );
    } else {
      content = filteredNodes.isEmpty
          ? Center(
              child: Text(
                'No bookmarks here.',
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredNodes.length,
              itemBuilder: (context, index) {
                final n = filteredNodes[index];
                final data = _parseVerseRef(n.reference, flatChapters);
                if (data == null) return const SizedBox.shrink();
                return _buildRealVerseCard(context, ref, n.reference, data, widget.theme, isBookmarked: true);
              },
            );
    }

    BookmarkFolder? selectedFolder;
    if (_viewType == _BookmarkViewType.folder && _selectedFolderId != null) {
      selectedFolder = bookmarkData.folders.where((f) => f.id == _selectedFolderId).firstOrNull;
    }

    return Column(
      children: [
        // Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _viewType == _BookmarkViewType.all,
                onSelected: (val) {
                  if (val) setState(() => _viewType = _BookmarkViewType.all);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Unfiled'),
                selected: _viewType == _BookmarkViewType.unfiled,
                onSelected: (val) {
                  if (val) setState(() => _viewType = _BookmarkViewType.unfiled);
                },
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: widget.theme.dividerColor.withValues(alpha: 0.2)),
              const SizedBox(width: 8),
              ...bookmarkData.folders.map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(f.name),
                      selected: _viewType == _BookmarkViewType.folder && _selectedFolderId == f.id,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _viewType = _BookmarkViewType.folder;
                            _selectedFolderId = f.id;
                          });
                        }
                      },
                    ),
                  )),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('New Folder'),
                onPressed: () => _showAddFolderDialog(context, ref),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: widget.theme.dividerColor.withValues(alpha: 0.2)),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('By Date'),
                selected: _viewType == _BookmarkViewType.byDate,
                onSelected: (val) {
                  if (val) setState(() => _viewType = _BookmarkViewType.byDate);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('By Book'),
                selected: _viewType == _BookmarkViewType.byBook,
                onSelected: (val) {
                  if (val) setState(() => _viewType = _BookmarkViewType.byBook);
                },
              ),
            ],
          ),
        ),
        
        // Folder Header (Edit/Delete)
        if (selectedFolder != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedFolder.name,
                  style: widget.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showRenameFolderDialog(context, ref, selectedFolder!.id, selectedFolder.name),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () {
                        setState(() => _viewType = _BookmarkViewType.all);
                        _showDeleteFolderDialog(context, ref, selectedFolder!.id, selectedFolder.name);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
        Expanded(child: content),
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
                    style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            showAddNoteSheet(
                              context,
                              ref,
                              theme,
                              editingNote: note,
                              editingId: note.id,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        note.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      note.date,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
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
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.8),
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
  final int bookNumber;
  final int chapter;
  final int verseNum;
  final String fallbackText;

  _ParsedVerseData({
    required this.bookAbbrev,
    required this.bookName,
    required this.bookNumber,
    required this.chapter,
    required this.verseNum,
    required this.fallbackText,
  });
}

/// Parses a verse reference key in the format produced by generateVerseKey:
/// "ABBREV_chapter:verse" (e.g. "GN_1:1", "MT_5:3").
/// Returns null if the key is malformed or the verse cannot be found in flatChapters.
_ParsedVerseData? _parseVerseRef(
    String refStr, List<FlatChapter> flatChapters) {
  // Format: "ABBREV_chapter:verse"
  final underscoreIdx = refStr.indexOf('_');
  if (underscoreIdx == -1) return null;

  final abbrevUpper = refStr.substring(0, underscoreIdx); // e.g. "GN"
  final cvStr = refStr.substring(underscoreIdx + 1); // e.g. "1:1"

  final cvParts = cvStr.split(':');
  if (cvParts.length != 2) return null;

  final chapter = int.tryParse(cvParts[0]);
  final verseNum = int.tryParse(cvParts[1]);
  if (chapter == null || verseNum == null) return null;

  // Match by abbreviation case-insensitively (JSON stores lowercase, key stores uppercase)
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
    bookNumber: fc.bookNumber,
    chapter: chapter,
    verseNum: verseNum,
    fallbackText: fc.chapter.verses[vIndex].text,
  );
}

Widget _buildRealVerseCard(BuildContext context, WidgetRef ref, String refStr,
    _ParsedVerseData data, ThemeData theme,
    {int? highlightColorIndex, bool isBookmarked = false}) {
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
                  if (highlightColor != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6, right: 6),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: highlightColor, shape: BoxShape.circle),
                      ),
                    ),
                  PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    onSelected: (value) {
                      switch (value) {
                        case 0:
                          ref.read(readLocationProvider.notifier).updateLocation(
                                bookAbbrev: data.bookAbbrev,
                                bookName: data.bookName,
                                chapter: data.chapter,
                                verse: data.verseNum,
                              );
                          Navigator.of(context).pop();
                          ref.read(navProvider.notifier).setIndex(1);
                          break;
                        case 1:
                          showAddNoteSheet(context, ref, theme, initialReference: formattedRef);
                          break;
                        case 2:
                          // We use fallbackText for sharing from Your Space for simplicity, unless we await the translation.
                          // To keep it sync, we'll just share the fallback text.
                          ShareService.shareText(body: '"${data.fallbackText}" — $formattedRef');
                          break;
                        case 3:
                          if (isBookmarked) {
                            ref.read(bookmarksProvider.notifier).toggle(refStr);
                          } else if (highlightColorIndex != null) {
                            ref.read(highlightsProvider.notifier).toggleHighlight(refStr, highlightColorIndex);
                          }
                          break;
                        case 4:
                          _showMoveToFolderSheet(context, ref, refStr, theme);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 0, child: Text('Open in Read')),
                      const PopupMenuItem(value: 1, child: Text('Add Note')),
                      const PopupMenuItem(value: 2, child: Text('Share')),
                      if (isBookmarked)
                        const PopupMenuItem(value: 4, child: Text('Move to folder')),
                      PopupMenuItem(
                          value: 3,
                          child: Text(isBookmarked ? 'Remove Bookmark' : 'Remove Highlight',
                              style: const TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Consumer(
                builder: (context, ref, _) {
                  final settings = ref.watch(readSettingsProvider);
                  final activeTransId = ref.watch(activeTranslationProvider);
                  final showChips = settings.showChipsOnSavedItems;
                  
                  final installedTranslations = ref.watch(availableTranslationsProvider).value ?? [];
                  final targetLanguages = <String, String>{};
                  for (final t in installedTranslations) {
                    if (!targetLanguages.containsKey(t.languageName)) {
                      targetLanguages[t.languageName] = t.languageName.length > 3 
                          ? t.languageName.substring(0, 3).toUpperCase() 
                          : t.languageName.toUpperCase();
                    }
                  }

                  final availableChips = <String, String>{};
                  String? activeLanguageLabel;
                  for (final t in installedTranslations) {
                    final label = targetLanguages[t.languageName]!;
                    if (!availableChips.containsKey(label)) {
                      availableChips[label] = t.translationId;
                    }
                    if (t.translationId == activeTransId) {
                      activeLanguageLabel = label;
                    }
                  }

                  final chipsToRender = targetLanguages.entries
                      .where((e) => e.value != activeLanguageLabel)
                      .toList();

                  final expandedChipsMap = ref.watch(yourSpaceExpandedChipsProvider);
                  final activeChipId = expandedChipsMap[refStr];

                  Widget verseWidget;
                  if (!settings.syncSavedItemsLanguage || activeTransId == 'kjv') {
                    verseWidget = Text(
                      data.fallbackText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        decoration: isBookmarked ? TextDecoration.underline : null,
                        decorationColor: isBookmarked ? theme.primaryColor : null,
                      ),
                    );
                  } else {
                    final request = (
                      translationId: activeTransId,
                      bookNumber: data.bookNumber,
                      chapter: data.chapter,
                      verse: data.verseNum
                    );
                    final verseAsync = ref.watch(verseTranslationProvider(request));

                    verseWidget = verseAsync.when(
                      data: (verseData) {
                        final displayText = verseData?.text ?? data.fallbackText;
                        return Text(
                          displayText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.4,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            decoration: isBookmarked ? TextDecoration.underline : null,
                            decorationColor: isBookmarked ? theme.primaryColor : null,
                          ),
                        );
                      },
                      loading: () => Text(
                        data.fallbackText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.4,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      error: (_, __) => Text(
                        data.fallbackText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.4,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  }

                  Widget? expandedTranslationWidget;
                  if (activeChipId != null) {
                    final request = (
                      translationId: activeChipId,
                      bookNumber: data.bookNumber,
                      chapter: data.chapter,
                      verse: data.verseNum
                    );
                    final expandedAsync = ref.watch(verseTranslationProvider(request));
                    expandedTranslationWidget = expandedAsync.when(
                      data: (verseData) {
                        if (verseData == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            verseData.text,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.4,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      verseWidget,
                      if (expandedTranslationWidget != null) expandedTranslationWidget,
                      if (showChips && chipsToRender.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (int i = 0; i < chipsToRender.length; i++)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: i == chipsToRender.length - 1 ? 0.0 : 6.0),
                                  child: Builder(builder: (context) {
                                    final langEntry = chipsToRender[i];
                                    final isInstalled = availableChips.containsKey(langEntry.value);
                                    final translationId = availableChips[langEntry.value];
                                    final isSelected = activeChipId == translationId;

                                    return Material(
                                      color: isSelected
                                          ? theme.primaryColor.withValues(alpha: 0.15)
                                          : theme.colorScheme.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: isSelected
                                              ? theme.primaryColor.withValues(alpha: 0.5)
                                              : theme.colorScheme.onSurface.withValues(
                                                  alpha: isInstalled ? 0.15 : 0.05),
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: () {
                                          if (isInstalled && translationId != null) {
                                            if (isSelected) {
                                              ref.read(yourSpaceExpandedChipsProvider.notifier).clear(refStr);
                                            } else {
                                              ref.read(yourSpaceExpandedChipsProvider.notifier).setLanguage(refStr, translationId);
                                            }
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Center(
                                            child: Text(
                                              langEntry.value,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                color: isSelected
                                                    ? theme.primaryColor
                                                    : (isInstalled
                                                        ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                                                        : theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
