import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    final groupings = ref.watch(devotionalGroupingsProvider);
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
                  // Testament segmented control
                  SegmentedButton<TestamentFilter>(
                    segments: const [
                      ButtonSegment(value: TestamentFilter.all, label: Text('All')),
                      ButtonSegment(value: TestamentFilter.ot, label: Text('Old Testament')),
                      ButtonSegment(value: TestamentFilter.nt, label: Text('New Testament')),
                    ],
                    selected: {filter.testament},
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      textStyle: WidgetStatePropertyAll(
                        theme.textTheme.labelMedium,
                      ),
                    ),
                    onSelectionChanged: (sel) => ref
                        .read(devotionalFilterProvider.notifier)
                        .setTestament(sel.first),
                  ),
                  const SizedBox(height: 10),
                  // Grouping chips
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _chip(context, 'All groups', null,
                            filter.grouping == null, (g) => ref
                                .read(devotionalFilterProvider.notifier)
                                .setGrouping(g)),
                        for (final g in groupings)
                          _chip(context, g, g, filter.grouping == g, (gg) => ref
                              .read(devotionalFilterProvider.notifier)
                              .setGrouping(gg)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Book chips
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _chip(context, 'All books', null,
                            filter.bookPrefix == null, (b) => ref
                                .read(devotionalFilterProvider.notifier)
                                .setBook(b)),
                        for (final b in books)
                          _chip(context, b.book, b.prefix,
                              filter.bookPrefix == b.prefix, (bp) => ref
                                  .read(devotionalFilterProvider.notifier)
                                  .setBook(bp)),
                      ],
                    ),
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
                ? const SliverFillRemaining(
                    child: Center(child: Text('No stories match these filters.')),
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

  Widget _chip(
    BuildContext context,
    String label,
    String? value,
    bool selected,
    void Function(String?) onTap,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? theme.primaryColor.withValues(alpha: 0.15)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected
                  ? theme.primaryColor
                  : theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected
                  ? theme.primaryColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.75),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
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

  void _openFilters(BuildContext context) {
    // Placeholder for a richer filter sheet; chips above cover the basics.
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
