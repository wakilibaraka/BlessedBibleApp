import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/reading_tokens.dart';
import '../../theme/app_colors.dart';
import '../../state/theme_provider.dart';
import '../../state/commentary_provider.dart';
import '../widgets/commentary_view.dart';
import '../widgets/textured_glass_container.dart';

class CommentaryHubScreen extends ConsumerStatefulWidget {
  final String book;
  final int chapter;
  final int? verse;
  final String? verseText;

  const CommentaryHubScreen({
    super.key,
    required this.book,
    required this.chapter,
    this.verse,
    this.verseText,
  });

  @override
  ConsumerState<CommentaryHubScreen> createState() => _CommentaryHubScreenState();
}

class _CommentaryHubScreenState extends ConsumerState<CommentaryHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appThemeMode = ref.watch(themeProvider);
    final tokens = Theme.of(context).extension<ReadingTokens>()!;
    final theme = Theme.of(context);

    Color getThemeBackgroundColor() {
      switch (appThemeMode) {
        case AppThemeMode.dawn:
          return AppColors.dawnBackground;
        case AppThemeMode.lilies:
          return AppColors.liliesBackground;
        case AppThemeMode.roses:
          return AppColors.rosesBackground;
        case AppThemeMode.olives:
          return AppColors.olivesBackground;
        case AppThemeMode.dusk:
          return const Color(0xFF312C51);
        case AppThemeMode.fresh:
          return const Color(0xFF132C33);
        default:
          return tokens.readingPaper;
      }
    }

    return Scaffold(
      backgroundColor: getThemeBackgroundColor(),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: getThemeBackgroundColor().withValues(alpha: 0.8),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            'Commentary',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'EB Garamond',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance back button
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        labelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Library'),
                          Tab(text: 'Reader'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildLibraryView(theme),
          SafeArea(
            top: false,
            bottom: false,
            child: CommentaryView(
              book: widget.book,
              chapter: widget.chapter,
              verse: widget.verse,
              verseText: widget.verseText,
              isCompact: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryView(ThemeData theme) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 80,
        bottom: 120,
        left: 24,
        right: 24,
      ),
      itemCount: kAvailableCommentaries.length,
      itemBuilder: (context, index) {
        final book = kAvailableCommentaries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: _LibraryBookCard(book: book, theme: theme, onRead: () {
            _tabController.animateTo(1);
          }),
        );
      },
    );
  }
}

class _LibraryBookCard extends StatelessWidget {
  final CommentaryBook book;
  final ThemeData theme;
  final VoidCallback onRead;

  const _LibraryBookCard({
    required this.book,
    required this.theme,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    return TexturedGlassContainer(
      isScrollable: false,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  book.isComingSoon 
                      ? theme.colorScheme.surface.withValues(alpha: 0.3)
                      : theme.primaryColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Book Cover
                Container(
                  width: 120,
                  height: double.infinity,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: book.isComingSoon 
                        ? theme.colorScheme.surface.withValues(alpha: 0.5)
                        : theme.primaryColor.withValues(alpha: 0.2),
                    border: Border.all(
                      color: book.isComingSoon 
                          ? theme.dividerColor.withValues(alpha: 0.2)
                          : theme.primaryColor.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      if (!book.isComingSoon)
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(4, 4),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        book.title,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'EB Garamond',
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: book.isComingSoon 
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: book.isComingSoon ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (book.isComingSoon)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              'Coming soon',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: onRead,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    elevation: 0,
                                  ),
                                  child: const Text('Read', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
