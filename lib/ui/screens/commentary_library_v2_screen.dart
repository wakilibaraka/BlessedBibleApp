import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/localized_book_names.dart';
import '../../l10n/l10n.dart';
import '../../models/commentary_entry.dart';
import '../../models/commentary_work.dart';
import '../../models/share_content.dart';
import '../../models/study_content_category.dart';
import '../../state/commentary_provider.dart';
import '../../state/theme_provider.dart';
import '../../theme/design_tokens.dart';
import '../widgets/share_sheet.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/state_views.dart';
import '../widgets/study_v2_widgets.dart';

/// Display serif used for editorial headings across the app.
const String _serif = 'EB Garamond';

/// Redesigned commentary library (V2).
///
/// Differences from V1 [CommentaryLibraryScreen]:
/// - Search across books (66-book list is unusable without it).
/// - Books show chapter counts + author badges, sorted with
///   content-bearing books first.
/// - Tapping a book opens a chapter sheet, then the rebuilt hub.
/// - Loading/error states are honest (V1 collapsed both to a false empty).
///
/// The browser is two shelves rather than one flat list: the volumes that
/// make up the library ("Daniel and the Revelation", "The Desire of Ages", …)
/// shown as books, and the scripture index. Either route reaches a chapter in
/// two taps, and the search field spans both.
class CommentaryLibraryV2Screen extends ConsumerStatefulWidget {
  const CommentaryLibraryV2Screen({super.key});

  @override
  ConsumerState<CommentaryLibraryV2Screen> createState() =>
      _CommentaryLibraryV2ScreenState();
}

class _CommentaryLibraryV2ScreenState
    extends ConsumerState<CommentaryLibraryV2Screen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openVolume(CommentaryWork work) {
    Navigator.of(context).push(CupertinoPageRoute<void>(
      builder: (_) => CommentaryVolumeScreen(work: work),
    ));
  }

  void _openBook(String book, Map<int, int> chapterCounts) {
    final chapters = chapterCounts.keys.toList()..sort();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final l10n = ctx.l10n;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(Radii.xxl)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: Space.lg),
                Text(
                  ctx.bookNameInLocale(book),
                  style: const TextStyle(
                    fontFamily: _serif,
                    fontSize: TypeScale.titleLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  l10n.studyChaptersWithContent(chapters.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: Space.md),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: Space.sm,
                      crossAxisSpacing: Space.sm,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: chapters.length,
                    itemBuilder: (context, i) {
                      final ch = chapters[i];
                      return _ChapterTile(
                        book: book,
                        chapter: ch,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(
                            CupertinoPageRoute<void>(
                              builder: (_) => CommentaryHubV2Screen(
                                  book: book, chapter: ch),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appThemeMode = ref.watch(resolvedThemeProvider);
    final asyncEntries = ref.watch(commentaryProvider);

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SharedAppBar(title: Text(context.l10n.studyCommentaryLibrary)),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: asyncEntries.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorState(
                  error: e,
                  message: context.l10n.studyCommentaryLoadError,
                  onRetry: () => ref.invalidate(commentaryProvider),
                ),
                data: (entries) => _browser(context, entries),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _browser(BuildContext context, List<CommentaryEntry> entries) {
    final l10n = context.l10n;
    final works = buildCommentaryWorks(entries);

    // book -> chapter -> entries, plus which volumes cover that book.
    final index = <String, _BookIndex>{};
    for (final e in entries) {
      final book = e.scope.book;
      final chapter = e.scope.chapter;
      if (book == null || chapter == null) continue;
      final slice = index.putIfAbsent(book, _BookIndex.new);
      slice.chapters.update(chapter, (n) => n + 1, ifAbsent: () => 1);
      slice.works.add(commentaryWorkTitle(e.source));
    }

    final query = _query.trim().toLowerCase();
    final shownWorks = query.isEmpty
        ? works
        : works
            .where((w) =>
                w.title.toLowerCase().contains(query) ||
                w.author.toLowerCase().contains(query) ||
                w.books.any((b) =>
                    context.bookNameInLocale(b).toLowerCase().contains(query)))
            .toList();
    // A book stays in the index when its own name matches, when one of the
    // volumes covering it matches (title or author), or when a matching
    // volume covers it at all — so searching an author narrows both shelves.
    final coveredByShown = <String>{
      for (final w in shownWorks) ...w.books,
    };
    final bookNames = index.keys.where((book) {
      if (query.isEmpty) return true;
      if (book.toLowerCase().contains(query)) return true;
      if (context.bookNameInLocale(book).toLowerCase().contains(query)) {
        return true;
      }
      if (coveredByShown.contains(book)) return true;
      return index[book]!.works.any((w) => w.toLowerCase().contains(query));
    }).toList()
      ..sort(compareBibleBookNames);

    if (shownWorks.isEmpty && bookNames.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: entries.isEmpty
            ? l10n.studyNoCommentaryYet
            : l10n.studyCommentaryNoMatch(query),
      );
    }

    // Covers carry text at a fixed type size, so the cell grows with the
    // reader's text scale instead of clipping the title.
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.8);

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: _searchField(context),
          ),
        ),
        if (shownWorks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: V2SectionLabel(
                '${l10n.studyCommentaryShelf} · '
                '${l10n.studyCommentaryVolumes(shownWorks.length)}',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: Space.md,
                crossAxisSpacing: Space.md,
                mainAxisExtent: 168 * textScale,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _VolumeCover(
                  key: ValueKey('volume-cover:${shownWorks[i].title}'),
                  work: shownWorks[i],
                  tint: i,
                  onTap: () => _openVolume(shownWorks[i]),
                ),
                childCount: shownWorks.length,
              ),
            ),
          ),
        ],
        if (bookNames.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: V2SectionLabel(l10n.studyCommentaryByBook),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverList.builder(
              itemCount: bookNames.length,
              itemBuilder: (context, i) {
                final book = bookNames[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BookRow(
                    book: book,
                    index: index[book]!,
                    onTap: () => _openBook(book, index[book]!.chapters),
                  ),
                );
              },
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }

  Widget _searchField(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.lg),
      borderSide: BorderSide(color: theme.dividerColor),
    );
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: context.l10n.studyCommentarySearchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: context.l10n.commonClear,
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: border,
        enabledBorder: border,
      ),
      onChanged: (v) => setState(() => _query = v),
    );
  }
}

class _BookIndex {
  final Map<int, int> chapters = {};
  final Set<String> works = {};
}

/// One volume standing on the shelf: spine, author, title, what it covers.
class _VolumeCover extends StatelessWidget {
  final CommentaryWork work;

  /// Position on the shelf, used only to vary the paper tint.
  final int tint;
  final VoidCallback onTap;

  const _VolumeCover({
    super.key,
    required this.work,
    required this.tint,
    required this.onTap,
  });

  static const _tints = [0.05, 0.10, 0.16];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(Radii.lg);
    final fill = Color.alphaBlend(
      theme.primaryColor.withValues(alpha: _tints[tint % _tints.length]),
      theme.colorScheme.surface,
    );
    // Two book names fit on a cover; the remainder becomes a count so a
    // volume covering sixteen books does not read as a wall of capitals.
    final books = work.books;
    final shownBooks = books.take(2).map((b) {
      return context.bookNameInLocale(b).toUpperCase();
    }).join(' · ');
    final bookLine =
        books.length > 2 ? '$shownBooks +${books.length - 2}' : shownBooks;
    final entries = context.l10n.studyCommentaryEntries(work.entryCount);

    return Semantics(
      button: true,
      label: '${work.title}, ${work.author}, $entries',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: fill,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: theme.dividerColor),
          ),
          child: InkWell(
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 7,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.55),
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.surface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(13, 13, 11, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          work.author.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            fontSize: TypeScale.micro,
                            color: theme.primaryColor.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: Space.xs + 2),
                        Container(
                          width: 20,
                          height: 1.5,
                          color: theme.primaryColor.withValues(alpha: 0.5),
                        ),
                        // Classic cover composition: imprint at the head,
                        // title set in the middle, publication line at the
                        // foot. The title floats so a two-line title and a
                        // four-line title both look intentional.
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              work.title,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: _serif,
                                fontSize: TypeScale.title,
                                height: 1.15,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        if (bookLine.isNotEmpty) ...[
                          const SizedBox(height: Space.sm),
                          Text(
                            bookLine,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              fontSize: TypeScale.micro,
                              color: theme.primaryColor.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          entries,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: TypeScale.micro,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One row of the scripture index: book, the volumes that cover it, chapters.
class _BookRow extends StatelessWidget {
  final String book;
  final _BookIndex index;
  final VoidCallback onTap;

  const _BookRow({
    required this.book,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = context.bookNameInLocale(book);
    final works = index.works.toList()..sort();
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return V2Card(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontFamily: _serif,
                fontSize: TypeScale.title,
                fontWeight: FontWeight.w700,
                color: theme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _serif,
                    fontSize: TypeScale.bodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        works.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.sm),
                    Text(
                      context.l10n
                          .studyCommentaryChapters(index.chapters.length),
                      maxLines: 1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

/// One chapter of a covered book, as an index number in a volume.
class _ChapterTile extends StatelessWidget {
  final String book;
  final int chapter;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.book,
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '${context.bookNameInLocale(book)} $chapter',
      excludeSemantics: true,
      // Opaque fill: the tiles sit on the live background, where a tinted
      // wash reads as a hole rather than a button.
      child: Material(
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.35)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              '$chapter',
              style: TextStyle(
                fontFamily: _serif,
                fontSize: TypeScale.bodyLarge,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One volume: a title page, then every chapter it treats, book by book.
///
/// Reaching a chapter from the library is cover → chapter, no detour
/// through a middle screen.
class CommentaryVolumeScreen extends ConsumerWidget {
  final CommentaryWork work;
  const CommentaryVolumeScreen({super.key, required this.work});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(resolvedThemeProvider);

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SharedAppBar(
          title: Text(
            work.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: _titlePage(context),
                    ),
                  ),
                  for (final book in work.books)
                    SliverToBoxAdapter(child: _bookSection(context, book)),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlePage(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final books =
        work.books.map((b) => context.bookNameInLocale(b)).join(' · ');
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return V2Card(
      textured: true,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            work.author.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: Space.md),
          Text(
            work.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _serif,
              fontSize: TypeScale.headline,
              height: 1.18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Space.lg),
          Center(
            child: Container(
              width: 42,
              height: 2,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: Space.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              V2MetaChip(l10n.studyCommentaryEntries(work.entryCount)),
              V2MetaChip(l10n.studyCommentaryChapters(work.chapterCount)),
            ],
          ),
          if (books.isNotEmpty) ...[
            const SizedBox(height: Space.md),
            Text(
              books,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bookSection(BuildContext context, String book) {
    final theme = Theme.of(context);
    final chapters = (work.coverage[book]?.keys.toList() ?? <int>[])..sort();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.bookNameInLocale(book),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _serif,
                    fontSize: TypeScale.title,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: Space.sm),
              Text(
                context.l10n.studyCommentaryChapters(chapters.length),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final chapter in chapters)
                SizedBox(
                  width: 52,
                  height: 52,
                  child: _ChapterTile(
                    book: book,
                    chapter: chapter,
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) =>
                            CommentaryHubV2Screen(book: book, chapter: chapter),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Redesigned commentary hub (V2): verse-anchored, filterable, searchable.
class CommentaryHubV2Screen extends ConsumerStatefulWidget {
  final String book;
  final int chapter;
  final int? verse;
  const CommentaryHubV2Screen({
    super.key,
    required this.book,
    required this.chapter,
    this.verse,
  });

  @override
  ConsumerState<CommentaryHubV2Screen> createState() =>
      _CommentaryHubV2ScreenState();
}

class _CommentaryHubV2ScreenState extends ConsumerState<CommentaryHubV2Screen> {
  StudyContentCategory? _filter;
  bool _verseOnly = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Deep links from a verse land pre-filtered to verse level.
    _verseOnly = widget.verse != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncEntries = ref.watch(commentaryProvider);
    final appThemeMode = ref.watch(resolvedThemeProvider);

    return V2PageShell(
      appThemeMode: appThemeMode,
      page: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SharedAppBar(
            title: Text(
                '${context.bookNameInLocale(widget.book)} ${widget.chapter}')),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: [
                        // Verse anchor — V1 accepted verse props but never showed them.
                        if (widget.verse != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(Radii.lg),
                              border: Border.all(
                                color:
                                    theme.primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              context.referenceInLocale(
                                  '${widget.book} ${widget.chapter}'
                                  ':${widget.verse}'),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        // 10dp gaps minus the chips' 4dp hit padding.
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: context.l10n.studyAllSources,
                                selected: _filter == null,
                                onTap: () => setState(() => _filter = null),
                              ),
                              const SizedBox(width: 8),
                              for (final c in StudyContentCategory.values)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _FilterChip(
                                    label: studyCategoryLabel(context.l10n, c),
                                    selected: _filter == c,
                                    onTap: () => setState(() =>
                                        _filter = _filter == c ? null : c),
                                  ),
                                ),
                              _FilterChip(
                                label: context.l10n.studyVerseLevel,
                                selected: _verseOnly,
                                onTap: () =>
                                    setState(() => _verseOnly = !_verseOnly),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          decoration: InputDecoration(
                            hintText: context.l10n.studySearchWithin(
                                '${context.bookNameInLocale(widget.book)} '
                                '${widget.chapter}'),
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Radii.lg),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Radii.lg),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: asyncEntries.when(
                      loading: () => const LoadingView(),
                      error: (e, _) => ErrorState(
                        error: e,
                        message: context.l10n.studyEntriesLoadFailed,
                        onRetry: () => ref.invalidate(commentaryProvider),
                      ),
                      data: (entries) {
                        var list = entries
                            .where((e) =>
                                e.scope.book == widget.book &&
                                e.scope.chapter == widget.chapter)
                            .toList();
                        if (_filter != null) {
                          list =
                              list.where((e) => e.category == _filter).toList();
                        }
                        if (_verseOnly) {
                          list = list
                              .where((e) =>
                                  e.scope.type == 'verse' &&
                                  (widget.verse == null ||
                                      e.scope.verse == widget.verse))
                              .toList();
                        }
                        if (_query.isNotEmpty) {
                          final q = _query.toLowerCase();
                          list = list
                              .where((e) =>
                                  e.text.toLowerCase().contains(q) ||
                                  e.source.toLowerCase().contains(q) ||
                                  e.author.toLowerCase().contains(q))
                              .toList();
                        }
                        if (list.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                context.l10n.studyNoEntriesMatch,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                          itemCount: list.length,
                          itemBuilder: (context, i) =>
                              _EntryCard(entry: list[i]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // Invisible vertical hit padding: 48dp target.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(
                color:
                    selected ? theme.colorScheme.onSurface : theme.dividerColor,
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? theme.colorScheme.surface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends ConsumerWidget {
  final CommentaryEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final verse = entry.scope.verse;
    final isVerseLevel = entry.scope.type == 'verse';
    final bookmarked = ref.watch(commentaryBookmarksProvider).contains(
        '${entry.scope.book}|${entry.scope.chapter}|${verse ?? "all"}');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: V2Card(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(entry.category.icon, size: 16, color: theme.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    commentaryWorkTitle(entry.source),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                V2Badge(isVerseLevel && verse != null
                    ? context.l10n.studyVerseN(verse)
                    : context.l10n.studyChapter),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              entry.text,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.65),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.author,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.commonShare,
                  icon: Icon(
                    Icons.ios_share_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    final scope = entry.scope;
                    final reference = scope.verse != null
                        ? '${scope.book ?? ''} ${scope.chapter ?? 1}'
                            ':${scope.verse}'
                        : '${scope.book ?? ''} ${scope.chapter ?? 1}';
                    showShareSheet(
                      context: context,
                      content: ShareContent.commentary(
                        text: entry.text,
                        reference: reference.trim(),
                        source: commentaryWorkTitle(entry.source),
                        author: entry.author,
                        eyebrow:
                            context.l10n.studyCommentaryEyebrow.toUpperCase(),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: bookmarked
                      ? context.l10n.studyRemoveBookmark
                      : context.l10n.studyBookmarkCommentary,
                  icon: Icon(
                    bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: bookmarked
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    ref
                        .read(commentaryBookmarksProvider.notifier)
                        .toggleBookmark(entry.scope.book ?? '',
                            entry.scope.chapter ?? 1, verse);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Localized label for a commentary [StudyContentCategory].
String studyCategoryLabel(AppLocalizations l10n, StudyContentCategory c) {
  switch (c) {
    case StudyContentCategory.commentary:
      return l10n.studyCategoryCommentary;
    case StudyContentCategory.devotional:
      return l10n.studyCategoryDevotional;
    case StudyContentCategory.studyNote:
      return l10n.studyCategoryStudyNote;
  }
}
