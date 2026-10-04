import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/devotional_story.dart';
import '../../state/devotional_provider.dart';
import '../../theme/app_colors.dart';
import 'bible_story_reader_screen.dart';

/// Entry point: "Bible Stories" — an illustrated journey through Scripture.
class BibleStoriesScreen extends ConsumerStatefulWidget {
  const BibleStoriesScreen({super.key});

  @override
  ConsumerState<BibleStoriesScreen> createState() => _BibleStoriesScreenState();
}

class _BibleStoriesScreenState extends ConsumerState<BibleStoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stories = ref.watch(filteredDevotionalStoriesProvider);
    final totalAsync = ref.watch(devotionalStoriesProvider);
    final filter = ref.watch(devotionalFilterProvider);
    final books = ref.watch(devotionalBooksProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            collapsedHeight: 72,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Text(
                'Bible Stories',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filters',
                onPressed: () => _openFilters(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '500 illustrated moments from Genesis to Revelation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        ref.read(devotionalFilterProvider.notifier).setQuery(v),
                    decoration: InputDecoration(
                      hintText: 'Search title, book, or reference…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: filter.query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(devotionalFilterProvider.notifier)
                                    .setQuery('');
                              },
                            ),
                      isDense: true,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Testament + books control: All | OT | NT | Books▾.
                  // Books opens a dropdown sheet instead of a chip row.
                  Row(
                    children: [
                      Expanded(
                        child: _FilterPill(
                          label: 'All',
                          selected:
                              filter.testament == TestamentFilter.all &&
                                  filter.bookPrefix == null,
                          onTap: () => ref
                              .read(devotionalFilterProvider.notifier)
                              .setTestament(TestamentFilter.all),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterPill(
                          label: 'OT',
                          selected:
                              filter.testament == TestamentFilter.ot &&
                                  filter.bookPrefix == null,
                          onTap: () => ref
                              .read(devotionalFilterProvider.notifier)
                              .setTestament(TestamentFilter.ot),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterPill(
                          label: 'NT',
                          selected:
                              filter.testament == TestamentFilter.nt &&
                                  filter.bookPrefix == null,
                          onTap: () => ref
                              .read(devotionalFilterProvider.notifier)
                              .setTestament(TestamentFilter.nt),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterPill(
                          label: _bookLabel(books, filter.bookPrefix),
                          selected: filter.bookPrefix != null,
                          trailing: const Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 18,
                          ),
                          onTap: () => _openBookPicker(books),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${stories.length} of ${totalAsync.value?.length ?? 0} stories',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                      const Spacer(),
                      _filterToggleButton(
                        context,
                        icon: Icons.favorite_rounded,
                        label: 'Favorites',
                        active: filter.favoritesOnly,
                        onTap: () => ref
                            .read(devotionalFilterProvider.notifier)
                            .toggleFavoritesOnly(),
                      ),
                      const SizedBox(width: 8),
                      _filterToggleButton(
                        context,
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Unread',
                        active: filter.unreadOnly,
                        onTap: () => ref
                            .read(devotionalFilterProvider.notifier)
                            .toggleUnreadOnly(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          totalAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Could not load stories:\n$e',
                  textAlign: TextAlign.center)),
            ),
            data: (_) => stories.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: _EmptyStories(
                        onClearFilters: () => ref
                            .read(devotionalFilterProvider.notifier)
                            .reset(),
                        onShowRead: () => ref
                            .read(devotionalFilterProvider.notifier)
                            .toggleUnreadOnly(),
                      ),
                    ),
                  )
                : _StoryGrid(stories: stories),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: DevotionalAttribution(),
            ),
          ),
        ],
      ),
    );
  }

  /// App-bar tune icon: jump straight to the book picker.
  void _openFilters(BuildContext context) {
    _openBookPicker(ref.read(devotionalBooksProvider));
  }

  /// Display label for the Books pill: the chosen book, else "Books".
  String _bookLabel(
      List<DevotionalBookInfo> books, String? prefix) {
    if (prefix == null) return 'Books';
    for (final b in books) {
      if (b.prefix == prefix) return b.book;
    }
    return 'Books';
  }

  /// Book dropdown: search + scoped book list + All-books reset.
  void _openBookPicker(List<DevotionalBookInfo> books) {
    final theme = Theme.of(context);
    final query = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              final q = query.text.trim().toLowerCase();
              final visible = q.isEmpty
                  ? books
                  : books
                      .where((b) =>
                          b.book.toLowerCase().contains(q))
                      .toList();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      margin: const EdgeInsets.only(top: 6, bottom: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search books…',
                        prefixIcon:
                            const Icon(Icons.search_rounded),
                        isDense: true,
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: const Icon(
                              Icons.menu_book_outlined),
                          title: const Text('All books'),
                          onTap: () {
                            ref
                                .read(devotionalFilterProvider
                                    .notifier)
                                .setBook(null);
                            Navigator.of(ctx).pop();
                          },
                        ),
                        for (final b in visible)
                          ListTile(
                            title: Text(b.book),
                            trailing: Text(
                              '${b.count}',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(
                                color: theme
                                    .colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            onTap: () {
                              ref
                                  .read(
                                      devotionalFilterProvider
                                          .notifier)
                                  .setBook(b.prefix);
                              Navigator.of(ctx).pop();
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    ).then((_) => query.dispose());
  }

  Widget _filterToggleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? theme.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? theme.primaryColor
                : theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 14,
                color: active ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 4),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

}

/// One segment of the All | OT | NT | Books control.
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Widget? trailing;
  final VoidCallback onTap;
  const _FilterPill({
    required this.label,
    required this.selected,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.primaryColor.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? theme.primaryColor
                : theme.dividerColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected
                      ? theme.primaryColor
                      : theme.colorScheme.onSurface
                          .withValues(alpha: 0.75),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Empty state that says WHY nothing matches: an empty favorites
/// shelf, an exhausted unread queue, or an over-narrow filter combo —
/// each with a one-tap way out (instead of a dead end).
class _EmptyStories extends ConsumerWidget {
  final VoidCallback onClearFilters;
  final VoidCallback onShowRead;
  const _EmptyStories({
    required this.onClearFilters,
    required this.onShowRead,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(devotionalFilterProvider);
    final favorites = ref.watch(devotionalFavoritesProvider);

    String title = 'No stories match these filters.';
    String? actionLabel;
    VoidCallback? action;

    if (filter.favoritesOnly && favorites.isEmpty) {
      title = 'No favorites yet.';
      actionLabel = 'Browse all stories';
      action = onClearFilters;
    } else if (filter.unreadOnly) {
      title = "You're all caught up.";
      actionLabel = 'Show read stories';
      action = onShowRead;
    } else if (filter.query.isNotEmpty ||
        filter.bookPrefix != null ||
        filter.testament != TestamentFilter.all) {
      actionLabel = 'Clear filters';
      action = onClearFilters;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filter.favoritesOnly && favorites.isEmpty
                ? Icons.favorite_outline_rounded
                : Icons.search_off_rounded,
            size: 40,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (filter.favoritesOnly && favorites.isEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Tap ♥ on any story to save it here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                HapticFeedback.selectionClick();
                action!();
              },
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _StoryGrid extends StatelessWidget {
  final List<DevotionalStory> stories;

  const _StoryGrid({required this.stories});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxis = width > 900
        ? 4
        : width > 600
            ? 3
            : 2;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxis,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _StoryCard(story: stories[i]),
          childCount: stories.length,
        ),
      ),
    );
  }
}

class _StoryCard extends ConsumerWidget {
  final DevotionalStory story;

  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref
        .watch(devotionalFavoritesProvider)
        .contains(story.id);
    final isRead = ref.watch(devotionalReadProvider).contains(story.id);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => BibleStoryReaderScreen(initialStory: story),
          ));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isFavorite
                  ? AppColors.goldAccent.withValues(alpha: 0.8)
                  : theme.dividerColor.withValues(alpha: 0.35),
              width: isFavorite ? 2 : 1,
            ),
            boxShadow: isFavorite
                ? [
                    BoxShadow(
                      color: AppColors.goldAccent.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (story.plateSlug != null)
                        Image.asset(
                          'assets/devotional/art/${story.plateSlug}.webp',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _plateFallback(context, story),
                        )
                      else
                        _plateFallback(context, story),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isRead
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 16,
                            color: isRead
                                ? AppColors.goldAccent
                                : Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story.ref.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                          letterSpacing: 0.5,
                        ),
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

  Widget _plateFallback(BuildContext context, DevotionalStory story) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        story.prefix,
        style: theme.textTheme.titleMedium?.copyWith(
          fontFamily: 'IM Fell English',
          color: theme.primaryColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

/// Attribution footer shown across devotional surfaces.
class DevotionalAttribution extends StatelessWidget {
  const DevotionalAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Scripture from the King James Version (public domain). Narrative summaries '
      'adapted from The Graham Bible (grahambible.com), AI-assisted and human reviewed. '
      'Artwork: Gustave Doré (1832–1883), public domain, via Wikimedia Commons.',
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        height: 1.5,
      ),
    );
  }
}
