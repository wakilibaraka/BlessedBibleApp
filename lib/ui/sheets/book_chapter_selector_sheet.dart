import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bible_model.dart';
import '../../state/pericopes_provider.dart';
import '../../state/translation_provider.dart';

import '../../state/bible_nav_settings_provider.dart';
import '../widgets/textured_glass_container.dart';
import '../../state/read_settings_provider.dart';
import '../../state/chapter_titles_provider.dart';

import '../../utils/bible_sections.dart';

enum SelectionMode { testament, book, chapter, verse }

/// Modal Bottom Sheet for selecting Book, Chapter, and Verse

class _SheetState {
  final BibleBook? book;
  final int chapter;
  final int? verse;
  final SelectionMode mode;
  final bool isOldTestament;

  const _SheetState({
    this.book,
    this.chapter = 1,
    this.verse,
    this.mode = SelectionMode.book,
    this.isOldTestament = true,
  });

  _SheetState copyWith({
    BibleBook? book,
    int? chapter,
    int? verse,
    SelectionMode? mode,
    bool? isOldTestament,
    bool clearVerse = false,
  }) {
    return _SheetState(
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: clearVerse ? null : (verse ?? this.verse),
      mode: mode ?? this.mode,
      isOldTestament: isOldTestament ?? this.isOldTestament,
    );
  }
}

class _SheetNotifier extends Notifier<_SheetState> {
  @override
  _SheetState build() => const _SheetState();

  void init(
      BibleBook book, int chapter, bool isOldTestament, SelectionMode mode) {
    state = _SheetState(
        book: book,
        chapter: chapter,
        isOldTestament: isOldTestament,
        mode: mode);
  }

  void setTestament(bool isOld) {
    state = state.copyWith(isOldTestament: isOld, mode: SelectionMode.book);
  }

  void setBook(BibleBook book) {
    state = state.copyWith(
        book: book, chapter: 1, clearVerse: true, mode: SelectionMode.chapter);
  }

  void setChapter(int chapter, bool advanceToVerse) {
    state = state.copyWith(
        chapter: chapter,
        verse: 1,
        mode: advanceToVerse ? SelectionMode.verse : state.mode);
  }

  void setVerse(int verse) {
    state = state.copyWith(verse: verse);
  }

  void setMode(SelectionMode mode) {
    state = state.copyWith(mode: mode);
  }
}

final _sheetStateProvider =
    NotifierProvider.autoDispose<_SheetNotifier, _SheetState>(
        _SheetNotifier.new);

class BookChapterSelectorSheet extends ConsumerStatefulWidget {
  final List<BibleBook> books;
  final String selectedBookAbbrev;
  final int selectedChapter;
  final void Function(String abbrev, String name, int chapter, int? verse,
      {bool autoClose}) onSelectionChanged;

  const BookChapterSelectorSheet({
    super.key,
    required this.books,
    required this.selectedBookAbbrev,
    required this.selectedChapter,
    required this.onSelectionChanged,
  });

  @override
  ConsumerState<BookChapterSelectorSheet> createState() =>
      _BookChapterSelectorSheetState();
}

class _BookChapterSelectorSheetState
    extends ConsumerState<BookChapterSelectorSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.books.isEmpty) return;
      int bookIndex = widget.books
          .indexWhere((b) => b.abbreviation == widget.selectedBookAbbrev);
      if (bookIndex == -1) bookIndex = 0;
      final initialBook = widget.books[bookIndex];
      final isOldTestament = bookIndex < 39;
      final settings = ref.read(bibleNavSettingsProvider);
      final mode = settings.depth == NavigationDepth.fourPart
          ? SelectionMode.testament
          : SelectionMode.book;

      ref
          .read(_sheetStateProvider.notifier)
          .init(initialBook, widget.selectedChapter, isOldTestament, mode);
    });
  }

  void _onTestamentSelected(bool isOld) {
    ref.read(_sheetStateProvider.notifier).setTestament(isOld);
  }

  void _onBookSelected(BibleBook book, BibleNavSettingsState settings) {
    ref.read(_sheetStateProvider.notifier).setBook(book);
    ref.read(_sheetStateProvider.notifier).setMode(SelectionMode.chapter);
  }

  void _onChapterSelected(int chapter, BibleNavSettingsState settings) {
    if (settings.depth == NavigationDepth.twoPart) {
      ref.read(_sheetStateProvider.notifier).setChapter(chapter, false);
      final book = ref.read(_sheetStateProvider).book;
      if (book != null) {
        widget.onSelectionChanged(
          book.abbreviation,
          book.name,
          chapter,
          1,
          autoClose: true,
        );
      }
    } else {
      ref.read(_sheetStateProvider.notifier).setChapter(chapter, true);
    }
  }

  void _onVerseSelected(int verse, BibleNavSettingsState settings) {
    ref.read(_sheetStateProvider.notifier).setVerse(verse);
    final sheetState = ref.read(_sheetStateProvider);
    final book = sheetState.book;
    if (book != null) {
      widget.onSelectionChanged(
        book.abbreviation,
        book.name,
        sheetState.chapter,
        verse,
        autoClose: settings.autoCloseOnFinalSelection,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(bibleNavSettingsProvider);
    final selectorHeightSetting = ref.watch(readSettingsProvider.select((s) => s.selectorHeight));
    
    final heightFactor = switch (selectorHeightSetting) {
      SelectorHeight.quarter => 0.25,
      SelectorHeight.half => 0.50,
      SelectorHeight.full => 0.95,
    };
    final isInitialized =
        ref.watch(_sheetStateProvider.select((s) => s.book != null));

    if (!isInitialized) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: TexturedGlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBreadcrumbs(theme, settings),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildSelectionView(theme, settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs(ThemeData theme, BibleNavSettingsState settings) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          if (settings.depth == NavigationDepth.fourPart)
            Consumer(builder: (context, ref, _) {
              final isOld = ref
                  .watch(_sheetStateProvider.select((s) => s.isOldTestament));
              final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
              return _buildBreadcrumbSegment('Testament', isOld ? 'OT' : 'NT',
                  SelectionMode.testament, mode, theme);
            }),
          Consumer(builder: (context, ref, _) {
            final bookName =
                ref.watch(_sheetStateProvider.select((s) => s.book?.name ?? ''));
            final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
            return _buildBreadcrumbSegment(
                'Book', bookName.isEmpty ? 'Select Book' : bookName, SelectionMode.book, mode, theme);
          }),
          Consumer(builder: (context, ref, _) {
            final chapter =
                ref.watch(_sheetStateProvider.select((s) => s.chapter));
            final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
            return _buildBreadcrumbSegment(
                'Chapter', '$chapter', SelectionMode.chapter, mode, theme);
          }),
          if (settings.depth != NavigationDepth.twoPart)
            Consumer(builder: (context, ref, _) {
              final verse =
                  ref.watch(_sheetStateProvider.select((s) => s.verse));
              final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
              return _buildBreadcrumbSegment(
                  'Verse',
                  verse != null ? '$verse' : '1',
                  SelectionMode.verse,
                  mode,
                  theme);
            }),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbSegment(String label, String value,
      SelectionMode targetMode, SelectionMode currentMode, ThemeData theme) {
    final isSelected = currentMode == targetMode;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(_sheetStateProvider.notifier).setMode(targetMode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
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

  Widget _buildSelectionView(ThemeData theme, BibleNavSettingsState settings) {
    final mode = ref.watch(_sheetStateProvider.select((s) => s.mode));
    switch (mode) {
      case SelectionMode.testament:
        return _buildTestamentSelection(theme);
      case SelectionMode.book:
        return _buildBookSelection(theme, settings);
      case SelectionMode.chapter:
        return _buildChapterSelection(theme, settings);
      case SelectionMode.verse:
        return _buildVerseSelection(theme, settings);
    }
  }

  Widget _buildTestamentSelection(ThemeData theme) {
    final isOldTestament =
        ref.watch(_sheetStateProvider.select((s) => s.isOldTestament));
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildGridTile(
              text: 'Old\nTestament',
              isSelected: isOldTestament,
              onTap: () => _onTestamentSelected(true),
              theme: theme,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildGridTile(
              text: 'New\nTestament',
              isSelected: !isOldTestament,
              onTap: () => _onTestamentSelected(false),
              theme: theme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookSelection(ThemeData theme, BibleNavSettingsState settings) {
    final oldTestamentBooks = widget.books.take(39).toList();
    final newTestamentBooks = widget.books.skip(39).toList();

    if (settings.depth == NavigationDepth.fourPart) {
      final isOldTestament =
          ref.watch(_sheetStateProvider.select((s) => s.isOldTestament));
      final displayedBooks =
          isOldTestament ? oldTestamentBooks : newTestamentBooks;
      return Consumer(builder: (context, ref, _) {
        final selectedBookAbbrev =
            ref.watch(_sheetStateProvider.select((s) => s.book?.abbreviation));
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 4),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 48,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: displayedBooks.length,
          itemBuilder: (context, index) {
            final book = displayedBooks[index];
            final isSel = book.abbreviation == selectedBookAbbrev;
            return _buildGridTile(
              text: book.name,
              isSelected: isSel,
              onTap: () => _onBookSelected(book, settings),
              theme: theme,
              backgroundColor: getSectionColor(
                  book.name, theme.brightness == Brightness.dark),
            );
          },
        );
      });
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text('Old Testament',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer(builder: (context, ref, _) {
                  final selectedBookAbbrev = ref.watch(
                      _sheetStateProvider.select((s) => s.book?.abbreviation));
                  return ListView.builder(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 4),
                    itemCount: oldTestamentBooks.length,
                    itemExtent: 50,
                    itemBuilder: (context, index) {
                      final book = oldTestamentBooks[index];
                      final isSel = book.abbreviation == selectedBookAbbrev;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0, right: 4.0),
                        child: _buildGridTile(
                            text: book.name,
                            isSelected: isSel,
                            onTap: () => _onBookSelected(book, settings),
                            theme: theme,
                            backgroundColor: getSectionColor(book.name,
                                theme.brightness == Brightness.dark)),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        Container(
            width: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            margin: const EdgeInsets.symmetric(horizontal: 8)),
        Expanded(
          child: Column(
            children: [
              Text('New Testament',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer(builder: (context, ref, _) {
                  final selectedBookAbbrev = ref.watch(
                      _sheetStateProvider.select((s) => s.book?.abbreviation));
                  return ListView.builder(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 4),
                    itemCount: newTestamentBooks.length,
                    itemExtent: 50,
                    itemBuilder: (context, index) {
                      final book = newTestamentBooks[index];
                      final isSel = book.abbreviation == selectedBookAbbrev;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                        child: _buildGridTile(
                            text: book.name,
                            isSelected: isSel,
                            onTap: () => _onBookSelected(book, settings),
                            theme: theme,
                            backgroundColor: getSectionColor(book.name,
                                theme.brightness == Brightness.dark)),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapterSelection(
      ThemeData theme, BibleNavSettingsState settings) {
    final book = ref.read(_sheetStateProvider).book;
    if (book == null) return const SizedBox.shrink();
    final chapters = book.chapters.length;

    return Consumer(builder: (context, ref, _) {
      final selectedChapter =
          ref.watch(_sheetStateProvider.select((s) => s.chapter));
      final allChapterTitles = ref.watch(chapterTitlesProvider);
      final bookTitles = allChapterTitles[book.name] ?? {};

      return GridView.builder(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80, // Made wider to fit titles
          mainAxisExtent: 64,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: chapters,
        itemBuilder: (context, index) {
          final chapter = index + 1;
          final isSel = chapter == selectedChapter;
          final subtitle = bookTitles[chapter.toString()];

          return _buildGridTile(
            text: '$chapter',
            subtitle: subtitle,
            isSelected: isSel,
            onTap: () => _onChapterSelected(chapter, settings),
            theme: theme,
          );
        },
      );
    });
  }

  Widget _buildVerseSelection(ThemeData theme, BibleNavSettingsState settings) {
    final book = ref.read(_sheetStateProvider).book;
    final selectedChapter = ref.read(_sheetStateProvider).chapter;

    if (book == null || book.chapters.isEmpty) return const SizedBox.shrink();
    int chapIdx = book.chapters.indexWhere((c) => c.number == selectedChapter);
    if (chapIdx == -1) chapIdx = 0;
    final chapterData = book.chapters[chapIdx];
    final verses = chapterData.verses.length;

    return Consumer(builder: (context, ref, _) {
      final selectedVerse =
          ref.watch(_sheetStateProvider.select((s) => s.verse));
          
      final activeTrans = ref.watch(activeTranslationProvider);
      final chapterPericopes = ref.watch(pericopesProvider).values.expand((e) => e)
          .where((p) => p.book == book.name && p.startChapter == selectedChapter && (p.translationId == activeTrans || p.translationId == null))
          .toList();

      return CustomScrollView(
        slivers: [
          if (chapterPericopes.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                child: Text(
                  'Stories & Sections',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = chapterPericopes[index];
                    final isSel = p.startVerse == selectedVerse;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _onVerseSelected(p.startVerse, settings),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSel ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isSel ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'v. ${p.startVerse}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isSel ? theme.colorScheme.onPrimary.withValues(alpha: 0.7) : theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: chapterPericopes.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                child: Text(
                  'All Verses',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          SliverPadding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 64,
                mainAxisExtent: 64,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final verse = index + 1;
                  final isSel = verse == selectedVerse;
                  return _buildGridTile(
                    text: '$verse',
                    isSelected: isSel,
                    onTap: () => _onVerseSelected(verse, settings),
                    theme: theme,
                  );
                },
                childCount: verses,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGridTile(
      {required String text,
      String? subtitle,
      required bool isSelected,
      required VoidCallback onTap,
      required ThemeData theme,
      Color? backgroundColor}) {
    // Determine if it's a book name (contains letters) to apply serif font consistency
    final isBook = text.contains(RegExp(r'[a-zA-Z]')) && subtitle == null;

    final textStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
      fontFamily: isBook
          ? theme.textTheme.bodyMedium?.fontFamily
          : null, // Font consistency for books
      color: isSelected
          ? Colors.white
          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
    );

    Widget content = Text(
      text,
      style: textStyle,
      maxLines: 1,
      textAlign: TextAlign.center,
    );

    if (subtitle != null && subtitle.isNotEmpty) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          content,
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: isSelected ? Colors.white.withValues(alpha: 0.9) : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.1,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    final textWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: subtitle != null ? content : FittedBox(
        fit: BoxFit.scaleDown,
        child: content,
      ),
    );

    if (!isSelected) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ??
                theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: textWidget,
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: textWidget,
      ),
    );
  }
}

