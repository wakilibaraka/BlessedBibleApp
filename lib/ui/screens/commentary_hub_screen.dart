import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/theme_provider.dart';
import '../../state/commentary_provider.dart';
import '../../models/commentary_entry.dart';
import '../../theme/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/pinch_to_zoom_font_wrapper.dart';

class CommentaryHubScreen extends ConsumerStatefulWidget {
  final String book;
  final int chapter;
  final int? verse;

  const CommentaryHubScreen({
    super.key,
    required this.book,
    required this.chapter,
    this.verse,
  });

  @override
  ConsumerState<CommentaryHubScreen> createState() => _CommentaryHubScreenState();
}

class _CommentaryHubScreenState extends ConsumerState<CommentaryHubScreen> {
  bool _showChapter = false;
  bool _showBook = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final commentaryAsync = ref.watch(commentaryProvider);
    
    final bookName = widget.book;
    final chapterNum = widget.chapter;
    final verseNum = widget.verse;
    
    final referenceString = verseNum != null 
        ? '$bookName $chapterNum:$verseNum' 
        : '$bookName $chapterNum';

    final commentaryNotifier = ref.read(commentaryProvider.notifier);
    
    List<CommentaryEntry> verseEntries = [];
    List<CommentaryEntry> chapterEntries = [];
    List<CommentaryEntry> bookEntries = [];
    
    if (verseNum != null) {
      verseEntries = commentaryNotifier.commentaryForVerse(bookName, chapterNum, verseNum);
    }
    chapterEntries = commentaryNotifier.commentaryForChapter(bookName, chapterNum);
    bookEntries = commentaryNotifier.commentaryForBook(bookName);

    return Scaffold(
      extendBody: true,
      appBar: SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Commentary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(appThemeMode: appThemeMode),
          ),
          PinchToZoomFontWrapper(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      referenceString,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldAccent,
                      ),
                    ),
                  ),
                ),
                
                if (commentaryAsync.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (verseEntries.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: _buildEmptyState(theme),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: _buildEntryCard(theme, verseEntries[index]),
                        );
                      },
                      childCount: verseEntries.length,
                    ),
                  ),
                  
                if (chapterEntries.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildCollapsibleSection(
                      theme: theme,
                      title: 'On this chapter',
                      isExpanded: _showChapter,
                      entries: chapterEntries,
                      onToggle: () => setState(() => _showChapter = !_showChapter),
                    ),
                  ),
                  
                if (bookEntries.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildCollapsibleSection(
                      theme: theme,
                      title: 'On this book',
                      isExpanded: _showBook,
                      entries: bookEntries,
                      onToggle: () => setState(() => _showBook = !_showBook),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return RepaintBoundary(
      child: TexturedGlassContainer(
        isScrollable: true,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          child: Column(
            children: [
              Icon(Icons.library_books_rounded, size: 48, color: theme.primaryColor.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'No commentary yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There is no commentary available for this specific passage.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required ThemeData theme,
    required String title,
    required bool isExpanded,
    required List<CommentaryEntry> entries,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: RepaintBoundary(
        child: TexturedGlassContainer(
          isScrollable: true,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: theme.primaryColor),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                  child: Column(
                    children: entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: _buildEntryContent(theme, entry),
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(ThemeData theme, CommentaryEntry entry) {
    return RepaintBoundary(
      child: TexturedGlassContainer(
        isScrollable: true,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildEntryContent(theme, entry),
        ),
      ),
    );
  }

  Widget _buildEntryContent(ThemeData theme, CommentaryEntry entry) {
    final paragraphs = entry.text.split('\n\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...paragraphs.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            p.trim(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'Lora', 
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
        )),
        const Divider(height: 24),
        Text(
          entry.author,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        if (entry.source.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            entry.source,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
