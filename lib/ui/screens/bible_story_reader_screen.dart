import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/devotional_story.dart';
import '../../models/share_content.dart';
import '../../state/devotional_provider.dart';
import '../widgets/share_sheet.dart';
import '../widgets/prose_text.dart';
import '../../state/typography_provider.dart';
import '../../data/localized_book_names.dart';
import '../../utils/prose.dart';
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
  bool _markedRead = false;

  @override
  void initState() {
    super.initState();
    _story = widget.initialStory;
    // Mark as read shortly after opening (matches the web app's behavior of
    // recording a read once the story is viewed).
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        ref.read(devotionalReadProvider.notifier).markRead(_story.id);
        setState(() => _markedRead = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    setState(() {
      _story = neighbor;
      _markedRead = false;
    });
    _scrollController.jumpTo(0);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        ref.read(devotionalReadProvider.notifier).markRead(_story.id);
        setState(() => _markedRead = true);
      }
    });
  }

  /// Share this story as text, an image card or a PDF with the full
  /// retelling, key verse and reference.
  void _shareStory() {
    showShareSheet(
      context: context,
      content: ShareContent.story(
        title: _story.title,
        body:
            _story.retelling.trim().isNotEmpty ? _story.retelling : _story.text,
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
    final positionAsync = ref.watch(_positionProvider(_story.id));
    final position = positionAsync.value;

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
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: isFavorite ? AppColors.goldAccent : null,
                ),
                tooltip: context.l10n.storiesFavorite,
                onPressed: () => ref
                    .read(devotionalFavoritesProvider.notifier)
                    .toggle(_story.id),
              ),
              IconButton(
                icon: Icon(
                  _markedRead
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  color: _markedRead ? AppColors.goldAccent : null,
                ),
                tooltip: context.l10n.storiesMarkAsRead,
                onPressed: () {
                  ref.read(devotionalReadProvider.notifier).markRead(_story.id);
                  setState(() => _markedRead = true);
                },
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_story.book} · ${_story.ref}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _story.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (position != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.storiesPosition(
                        position.index,
                        position.total,
                        context.bookNameInLocale(position.book),
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
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
                            '“${normalizeProse(_story.keyVerse)}”',
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
                  const SizedBox(height: 24),
                  _PassageText(text: _story.text, typography: typography),
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
                  const SizedBox(height: 20),
                  ProseText(
                    text: _story.retelling,
                    typography: typography,
                    accent: theme.primaryColor,
                    paragraphGap: 20,
                    baseStyle: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Source Serif 4',
                      fontSize: typography.fontSize,
                      height: 1.75,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (_story.plateCaption != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.storiesArtworkCaption(_story.plateCaption!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.45),
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
        ],
      ),
      // Prev/next navigation
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
          child: Row(
            children: [
              IconButton(
                onPressed: () => _goNeighbor(next: false),
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: context.l10n.storiesPrevious,
              ),
              Expanded(
                child: Text(
                  '${_story.id} · ${_story.book}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
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
      ),
    );
  }
}

/// KJV passage rendered as flowing prose.
///
/// The content packs arrive hard-wrapped at ~80 characters, so splitting on
/// newlines used to break sentences into separate paragraphs. [proseParagraphs]
/// rejoins the wraps and keeps blank lines as real paragraph breaks.
class _PassageText extends StatelessWidget {
  final String text;
  final TypographyState typography;

  const _PassageText({required this.text, required this.typography});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ProseText(
      text: text,
      typography: typography,
      accent: theme.primaryColor,
      paragraphGap: 12,
      baseStyle: theme.textTheme.bodyLarge?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontSize: TypeScale.titleLarge,
        height: 1.62,
        color: theme.colorScheme.onSurface,
      ),
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
