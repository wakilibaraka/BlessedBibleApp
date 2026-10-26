import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/devotional_story.dart';
import '../../models/share_content.dart';
import '../../state/bible_provider.dart';
import '../../state/devotional_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../state/user_data_provider.dart';
import '../widgets/share_sheet.dart';
import '../widgets/prose_text.dart';
import '../../state/typography_provider.dart';
import '../../data/localized_book_names.dart';
import '../../utils/passage.dart';
import '../../utils/prose.dart';
import '../../utils/span_marks.dart';
import '../widgets/verse_link_text.dart';
import '../../theme/app_colors.dart';
import 'bible_stories_screen.dart';
import '../../l10n/l10n.dart';
import '../../theme/design_tokens.dart';

/// Two-page devotional reader: engraving on top, scripture + retelling below.
class BibleStoryReaderScreen extends ConsumerStatefulWidget {
  final DevotionalStory initialStory;

  const BibleStoryReaderScreen({super.key, required this.initialStory});

  @override
  ConsumerState<BibleStoryReaderScreen> createState() =>
      _BibleStoryReaderScreenState();
}

class _BibleStoryReaderScreenState
    extends ConsumerState<BibleStoryReaderScreen> {
  late DevotionalStory _story;
  final ScrollController _scrollController = ScrollController();

  /// How far through the page the reader is, 0 to 1 (bottom bar line).
  final ValueNotifier<double> _progress = ValueNotifier(0);

  /// Current text selection in the story, if any (plain text).
  String? _selection;

  @override
  void initState() {
    super.initState();
    _story = widget.initialStory;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _progress.dispose();
    super.dispose();
  }

  /// Tracks reading progress and marks the story read once its end is on
  /// screen, instead of the moment it opens.
  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final max = position.maxScrollExtent;
    _progress.value = max <= 0 ? 1 : (position.pixels / max).clamp(0.0, 1.0);
    if (position.pixels >= max - 160) {
      ref.read(devotionalReadProvider.notifier).markRead(_story.id);
    }
  }

  Future<void> _goNeighbor({required bool next}) async {
    final service = ref.read(devotionalServiceProvider);
    final neighbor = await service.neighborOf(_story, next: next);
    if (!mounted) return;
    if (neighbor == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(next
            ? context.l10n.storiesReachedEnd
            : context.l10n.storiesFirstStory),
        duration: const Duration(seconds: 1),
      ));
      return;
    }
    _openStory(neighbor);
  }

  void _openStory(DevotionalStory story) {
    HapticFeedback.selectionClick();
    setState(() => _story = story);
    _scrollController.jumpTo(0);
    _progress.value = 0;
  }

  void _toggleSaved() {
    HapticFeedback.selectionClick();
    final notifier = ref.read(devotionalFavoritesProvider.notifier);
    notifier.toggle(_story.id);
    final saved = notifier.isFavorite(_story.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(saved
            ? context.l10n.storiesSavedToSpace
            : context.l10n.storiesRemovedFromSaved),
        duration: const Duration(seconds: 2),
      ));
  }

  void _toggleRead() {
    HapticFeedback.selectionClick();
    final read = ref.read(devotionalReadProvider.notifier).toggle(_story.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(read
            ? context.l10n.storiesMarkedRead
            : context.l10n.storiesMarkedUnread),
        duration: const Duration(seconds: 2),
      ));
  }

  /// Lists every story in the current book so the reader can jump.
  Future<void> _showBookStories() async {
    final all = await ref.read(devotionalStoriesProvider.future);
    if (!mounted) return;
    final inBook = [
      for (final s in all)
        if (s.prefix == _story.prefix) s
    ];
    final picked = await showModalBottomSheet<DevotionalStory>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _BookStoriesSheet(
        stories: inBook,
        current: _story,
        book: sheetContext.bookNameInLocale(_story.book),
      ),
    );
    if (picked != null && mounted && picked.id != _story.id) {
      _openStory(picked);
    }
  }

  /// The current selection's range inside the rendered retelling, or null
  /// when nothing is selected or the selection is outside the story.
  ({int start, int end})? _selectionRange() {
    final selection = _selection;
    if (selection == null || selection.trim().isEmpty) return null;
    return locateSelection(renderedProse(_story.retelling), selection);
  }

  void _markSelection(SelectableRegionState region, StoryMarkKind kind) {
    final range = _selectionRange();
    if (range == null) return;
    HapticFeedback.selectionClick();
    ref.read(storyMarksProvider.notifier).add(
          _story.id,
          StoryMark(
            start: range.start,
            end: range.end,
            kind: kind,
            colorIndex:
                ref.read(readSettingsProvider).activeHighlightColorIndex,
          ),
        );
    region.clearSelection();
    region.hideToolbar();
  }

  void _unmarkSelection(SelectableRegionState region) {
    final range = _selectionRange();
    if (range == null) return;
    HapticFeedback.selectionClick();
    ref
        .read(storyMarksProvider.notifier)
        .removeRange(_story.id, range.start, range.end);
    region.clearSelection();
    region.hideToolbar();
  }

  void _shareSelection(SelectableRegionState region) {
    final selection = _selection?.trim();
    if (selection == null || selection.isEmpty) return;
    region.hideToolbar();
    showShareSheet(
      context: context,
      content: ShareContent.story(
        title: _story.title,
        body: selection,
        reference: _story.ref,
        eyebrow: context.l10n.storiesTitle.toUpperCase(),
        source: _story.book,
        imageFilename: 'story-${shareSlug(_story.title)}',
      ),
    );
  }

  /// System Copy / Select all, plus Highlight, Underline, Remove and Share
  /// when the selection sits inside the story.
  Widget _buildSelectionMenu(
      BuildContext context, SelectableRegionState region) {
    final items = [...region.contextMenuButtonItems];
    final range = _selectionRange();
    if (range != null) {
      final marks = ref.read(storyMarksProvider)[_story.id] ?? const [];
      final marked = marks.any((m) => m.overlaps(range.start, range.end));
      items.addAll([
        ContextMenuButtonItem(
          label: context.l10n.storiesHighlight,
          onPressed: () => _markSelection(region, StoryMarkKind.highlight),
        ),
        ContextMenuButtonItem(
          label: context.l10n.storiesUnderline,
          onPressed: () => _markSelection(region, StoryMarkKind.underline),
        ),
        if (marked)
          ContextMenuButtonItem(
            label: context.l10n.storiesRemoveMark,
            onPressed: () => _unmarkSelection(region),
          ),
      ]);
    }
    items.add(ContextMenuButtonItem(
      label: context.l10n.commonShare,
      onPressed: () => _shareSelection(region),
    ));
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: region.contextMenuAnchors,
      buttonItems: items,
    );
  }

  List<SpanMark> _spanMarks(ThemeData theme, List<StoryMark> marks) => [
        for (final m in marks)
          (
            start: m.start,
            end: m.end,
            style: m.kind == StoryMarkKind.highlight
                ? TextStyle(
                    backgroundColor: AppColors.getRenderedHighlightColor(
                      highlightPalette[
                          m.colorIndex.clamp(0, highlightPalette.length - 1)],
                      theme.brightness,
                      theme.scaffoldBackgroundColor,
                    ),
                  )
                : TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: theme.primaryColor,
                    decorationThickness: 2,
                  ),
          ),
      ];

  /// Share this story as text, an image card or a PDF with the full
  /// retelling, key verse and reference.
  void _shareStory() {
    showShareSheet(
      context: context,
      content: ShareContent.story(
        title: _story.title,
        body: _story.retelling.trim().isNotEmpty
            ? _story.retelling
            : _story.keyVerse,
        reference: _story.ref,
        eyebrow: context.l10n.storiesTitle.toUpperCase(),
        keyVerse: _story.keyVerse,
        keyVerseRef: _story.keyVerseRef,
        source: _story.book,
        artworkPath: _story.plateSlug != null
            ? 'assets/devotional/art/${_story.plateSlug}.webp'
            : null,
        imageFilename: 'story-${shareSlug(_story.title)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final favorites = ref.watch(devotionalFavoritesProvider);
    final isFavorite = favorites.contains(_story.id);
    final isRead = ref.watch(devotionalReadProvider).contains(_story.id);
    final positionAsync = ref.watch(_positionProvider(_story.id));
    final position = positionAsync.value;
    final showPassage = ref.watch(storyShowPassageProvider);
    final marks = ref.watch(storyMarksProvider)[_story.id] ?? const [];

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            leading: IconButton(
              tooltip: context.l10n.commonBack,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: isFavorite ? AppColors.goldAccent : null,
                ),
                tooltip: isFavorite
                    ? context.l10n.storiesRemoveFromSaved
                    : context.l10n.storiesFavorite,
                onPressed: _toggleSaved,
              ),
              IconButton(
                icon: Icon(
                  isRead
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isRead ? AppColors.goldAccent : null,
                ),
                tooltip: isRead
                    ? context.l10n.storiesMarkAsUnread
                    : context.l10n.storiesMarkAsRead,
                onPressed: _toggleRead,
              ),
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: context.l10n.commonShare,
                onPressed: _shareStory,
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_story.plateSlug != null)
                    Image.asset(
                      'assets/devotional/art/${_story.plateSlug}.webp',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => Container(
                          color: theme.colorScheme.surfaceContainerHighest),
                    )
                  else
                    Container(color: theme.colorScheme.surfaceContainerHighest),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          // Fixed: darkens the top of the artwork so the back button reads.
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: const Alignment(0, -0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SelectionArea(
              onSelectionChanged: (content) => _selection = content?.plainText,
              contextMenuBuilder: _buildSelectionMenu,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReferenceChip(reference: _story.ref),
                    const SizedBox(height: 12),
                    Text(
                      _story.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (_story.keyVerse.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(Radii.lg),
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.storiesKeyVerse(
                                  _story.keyVerseRef.toUpperCase()),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '“${stripQuotes(normalizeProse(_story.keyVerse))}”',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: 'Cormorant Garamond',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (showPassage) ...[
                      const SizedBox(height: 24),
                      _PassageText(
                          reference: _story.ref, typography: typography),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: theme.dividerColor.withValues(alpha: 0.6),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              context.l10n.storiesTheStory,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: theme.dividerColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    ProseText(
                      text: _story.retelling,
                      typography: typography,
                      accent: theme.primaryColor,
                      paragraphGap: 20,
                      baseStyle: storyTextStyle(theme, typography),
                      marks: _spanMarks(theme, marks),
                    ),
                    if (_story.plateCaption != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        context.l10n
                            .storiesArtworkCaption(_story.plateCaption!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.45),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const DevotionalAttribution(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Prev/next navigation, what comes next, and reading progress.
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(Radii.xl),
            border:
                Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: context.palette.shadow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: _progress,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                    color: theme.primaryColor,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _goNeighbor(next: false),
                        icon: const Icon(Icons.chevron_left_rounded),
                        tooltip: context.l10n.storiesPrevious,
                      ),
                      Expanded(
                        child: _NextUpLabel(
                          story: _story,
                          position: position,
                          onTap: _showBookStories,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _goNeighbor(next: true),
                        icon: const Icon(Icons.chevron_right_rounded),
                        tooltip: context.l10n.storiesNext,
                      ),
                    ],
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

/// Centre of the bottom bar: the next story's title and where this one sits
/// in its book. Tapping opens the list of the book's stories.
class _NextUpLabel extends ConsumerWidget {
  final DevotionalStory story;
  final StoryPosition? position;
  final VoidCallback onTap;

  const _NextUpLabel({
    required this.story,
    required this.position,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final next = ref.watch(_nextStoryProvider(story.id)).value;
    final position = this.position;
    final title = next == null
        ? context.l10n.storiesReachedEnd
        : context.l10n.storiesNextUp(next.title);
    final subtitle = position == null
        ? null
        : context.l10n.storiesPosition(position.index, position.total,
            context.bookNameInLocale(position.book));
    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title, $subtitle',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The stories of one book, with read state; tapping one opens it.
class _BookStoriesSheet extends ConsumerWidget {
  final List<DevotionalStory> stories;
  final DevotionalStory current;
  final String book;

  const _BookStoriesSheet({
    required this.stories,
    required this.current,
    required this.book,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final read = ref.watch(devotionalReadProvider);
    final saved = ref.watch(devotionalFavoritesProvider);
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              context.l10n.storiesInBook(book),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: stories.length,
              itemBuilder: (context, i) {
                final s = stories[i];
                final isCurrent = s.id == current.id;
                return ListTile(
                  selected: isCurrent,
                  leading: Icon(
                    read.contains(s.id)
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: read.contains(s.id) ? AppColors.goldAccent : null,
                    semanticLabel: read.contains(s.id)
                        ? context.l10n.a11yRead
                        : context.l10n.storiesUnread,
                  ),
                  title: Text(s.title),
                  subtitle: Text(context.referenceInLocale(s.ref)),
                  trailing: saved.contains(s.id)
                      ? const Icon(Icons.bookmark_rounded,
                          color: AppColors.goldAccent)
                      : null,
                  onTap: () => Navigator.of(context).pop(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Body style for story text: the reader's chosen Read typography (family,
/// size, line height, weight, italic), so stories read like scripture does.
TextStyle? storyTextStyle(ThemeData theme, TypographyState typography) =>
    theme.textTheme.bodyLarge?.copyWith(
      fontFamily: typography.fontFamily,
      fontSize: typography.fontSize,
      height: typography.lineHeight,
      fontWeight: typography.fontWeight,
      fontStyle: typography.fontStyle,
      color: theme.colorScheme.onSurface,
    );

/// Tappable scripture reference under the artwork. Opens the passage in a
/// sheet with "Open in Read", so the story stays the focus of the page.
class _ReferenceChip extends StatelessWidget {
  final String reference;

  const _ReferenceChip({required this.reference});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = context.referenceInLocale(reference);
    return Semantics(
      button: true,
      label: context.l10n.storiesOpenPassage(label),
      excludeSemantics: true,
      child: Material(
        color: theme.primaryColor.withValues(alpha: 0.10),
        shape: StadiumBorder(
          side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.30)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            showVersePreviewSheet(context, reference, heightFactor: 0.85);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded,
                    size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: theme.primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The story's scripture passage, read from the Bible database (KJV), shown
/// inline when "Show scripture in stories" is on.
class _PassageText extends ConsumerWidget {
  final String reference;
  final TypographyState typography;

  const _PassageText({required this.reference, required this.typography});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bible = ref.watch(bibleProvider);
    final passage = PassageRef.parse(reference);
    if (bible.isLoading || passage == null) return const SizedBox.shrink();
    final verses = resolvePassage(bible.books, passage) ?? const [];
    if (verses.isEmpty) return const SizedBox.shrink();
    // One paragraph per chapter: labels read "13:5" on multi-chapter
    // passages, so a new prefix starts a new paragraph.
    final buffer = StringBuffer();
    String? chapter;
    for (final v in verses) {
      final c = v.label.contains(':') ? v.label.split(':').first : null;
      if (buffer.isNotEmpty) buffer.write(c != chapter ? '\n\n' : ' ');
      chapter = c;
      buffer.write(cleanShareText(v.text));
    }
    return ProseText(
      text: buffer.toString(),
      typography: typography,
      accent: theme.primaryColor,
      baseStyle: storyTextStyle(theme, typography),
    );
  }
}

/// Where a story sits inside its book: index, how many stories that book has
/// and the canonical book name. The reader formats and localizes the line so
/// no English wording is baked into the data layer.
typedef StoryPosition = ({int index, int total, String book});

final _positionProvider =
    FutureProvider.family<StoryPosition?, String>((ref, id) async {
  final service = ref.watch(devotionalServiceProvider);
  final all = await service.loadAllStoryRefs();
  final i = all.indexWhere((s) => s.id == id);
  if (i == -1) return null;
  final story = all[i];
  final bookStories = all.where((s) => s.prefix == story.prefix).length;
  return (
    index: story.indexInBook + 1,
    total: bookStories,
    book: story.book,
  );
});

final _nextStoryProvider =
    FutureProvider.family<DevotionalStory?, String>((ref, id) async {
  final all = await ref.watch(devotionalStoriesProvider.future);
  final i = all.indexWhere((s) => s.id == id);
  if (i == -1 || i + 1 >= all.length) return null;
  return all[i + 1];
});
