import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/study_provider.dart';
import '../../state/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/pinch_to_zoom_font_wrapper.dart';

class CommentarySourceMetadata {
  final String id;
  final String title;
  final String author;
  final bool isAvailable;

  const CommentarySourceMetadata({
    required this.id,
    required this.title,
    required this.author,
    required this.isAvailable,
  });
}

const List<CommentarySourceMetadata> availableCommentarySources = [
  CommentarySourceMetadata(
    id: 'uriah_smith',
    title: 'Thoughts on Daniel and Revelation',
    author: 'Uriah Smith',
    isAvailable: true,
  ),
  CommentarySourceMetadata(
    id: 'waggoner',
    title: 'The Glad Tidings',
    author: 'E.J. Waggoner',
    isAvailable: false,
  ),
  CommentarySourceMetadata(
    id: 'haskell',
    title: 'The Cross and Its Shadow',
    author: 'S.N. Haskell',
    isAvailable: false,
  ),
  CommentarySourceMetadata(
    id: 'andreasen',
    title: 'The Epistle to the Hebrews',
    author: 'M.L. Andreasen',
    isAvailable: false,
  ),
  CommentarySourceMetadata(
    id: 'andrews',
    title: "The Three Angels' Messages",
    author: 'J.N. Andrews',
    isAvailable: false,
  ),
];

class CommentaryHubScreen extends ConsumerStatefulWidget {
  final String reference;

  const CommentaryHubScreen({super.key, required this.reference});

  @override
  ConsumerState<CommentaryHubScreen> createState() => _CommentaryHubScreenState();
}

class _CommentaryHubScreenState extends ConsumerState<CommentaryHubScreen> {
  String _selectedSourceId = 'uriah_smith';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(themeProvider);
    final commentaryAsync = ref.watch(combinedCommentaryProvider);
    
    // Parse reference
    String bookName = '';
    String chapterNum = '';
    String verseNum = '';
    
    final parts = widget.reference.split(' ');
    if (parts.length >= 2) {
      bookName = parts[0];
      final refParts = parts[1].split(':');
      if (refParts.length >= 2) {
        chapterNum = refParts[0];
        verseNum = refParts[1];
      }
    }

    // Retrieve commentary entries for selected source
    List<dynamic> commentaryEntries = [];
    if (commentaryAsync is AsyncData<CombinedCommentaryState>) {
      final data = commentaryAsync.value.data;
      if (data.containsKey(bookName) && data[bookName]!.containsKey(chapterNum)) {
        if (data[bookName]![chapterNum]!.containsKey(verseNum)) {
          // Right now combinedCommentaryProvider only loads Uriah Smith.
          // For future readiness, we'd filter by _selectedSourceId here.
          if (_selectedSourceId == 'uriah_smith') {
            commentaryEntries = data[bookName]![chapterNum]![verseNum]!;
          }
        }
      }
    }
    
    final activeSource = availableCommentarySources.firstWhere((s) => s.id == _selectedSourceId);
    final otherSources = availableCommentarySources.where((s) => s.id != _selectedSourceId).toList();

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
                    widget.reference,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldAccent,
                    ),
                  ),
                ),
              ),
              
              // PRIMARY SOURCE OVERVIEW
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: RepaintBoundary(
                    child: TexturedGlassContainer(
                      isScrollable: true,
                      borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.library_books_rounded, size: 20, color: theme.primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  activeSource.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeSource.author,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.primaryColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Divider(height: 32),
                          if (commentaryAsync.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (commentaryEntries.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
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
                                      'There is no commentary available for this verse from this source.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: commentaryEntries.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final entry = commentaryEntries[index];
                                return Text(
                                  entry.text,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.6,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    ),
                  ),
                ),
              ),

              // OTHER SOURCES
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    'Other Sources',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final source = otherSources[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: _buildOtherSourceCard(theme, source),
                    );
                  },
                  childCount: otherSources.length,
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

  Widget _buildOtherSourceCard(ThemeData theme, CommentarySourceMetadata source) {
    return GestureDetector(
      onTap: source.isAvailable ? () {
        setState(() {
          _selectedSourceId = source.id;
        });
      } : null,
      child: RepaintBoundary(
        child: TexturedGlassContainer(
          isScrollable: true,
          borderRadius: BorderRadius.circular(16),
          padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      source.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: source.isAvailable ? 1.0 : 0.6),
                      ),
                    ),
                  ),
                  if (!source.isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                source.author,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: (source.isAvailable ? theme.primaryColor : theme.colorScheme.onSurface).withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
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
