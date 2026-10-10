import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/reading_tokens.dart';
import '../../theme/app_colors.dart';
import '../../state/theme_provider.dart';
import '../../state/surface_style_provider.dart';
import '../../state/commentary_provider.dart';
import '../../models/commentary_entry.dart';
import '../../models/study_content_category.dart';
import '../../state/typography_provider.dart';
import 'dart:ui';

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
  ConsumerState<CommentaryHubScreen> createState() =>
      _CommentaryHubScreenState();
}

class _CommentaryHubScreenState extends ConsumerState<CommentaryHubScreen> {
  String _selectedSource = 'All';
  String _selectedScope = 'All Contexts';

  @override
  Widget build(BuildContext context) {
    final appThemeMode = ref.watch(themeProvider);
    final surfaceStyle = ref.watch(surfaceStyleProvider);
    final theme = Theme.of(context);
    final tokens = Theme.of(context).extension<ReadingTokens>()!;
    final typography = ref.watch(typographyProvider);

    final asyncEntries = ref.watch(commentaryProvider);

    Color getThemeBackgroundColor() {
      if (surfaceStyle == SurfaceStyle.paperlike) {
        return theme.scaffoldBackgroundColor;
      }
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: theme.primaryColor, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              '${widget.book} ${widget.chapter}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: theme.primaryColor,
              ),
            ),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                    color: getThemeBackgroundColor().withValues(alpha: 0.8)),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _buildFilters(theme, tokens),
            ),
          ),
          asyncEntries.when(
            loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Could not load commentary.\n$e',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(commentaryProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )),
            data: (entries) {
              // Filter data based on context and selected chips
              final filtered = entries.where((e) {
                // Must match the book and chapter context
                if (e.scope.book?.toLowerCase() != widget.book.toLowerCase()) {
                  return false;
                }
                if (e.scope.chapter != widget.chapter) return false;

                // Filter by Source / Category
                if (_selectedSource != 'All') {
                  if (_selectedSource == 'Devotionals' &&
                      e.category != StudyContentCategory.devotional) {
                    return false;
                  }
                  if (_selectedSource == 'Commentary' &&
                      e.category != StudyContentCategory.commentary) {
                    return false;
                  }
                }

                // Filter by Scope
                if (_selectedScope == 'Chapter Level' &&
                    e.scope.type != 'chapter') {
                  return false;
                }
                if (_selectedScope == 'Verse Level' && e.scope.type != 'verse') {
                  return false;
                }

                return true;
              }).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text('No content found for these filters.',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: tokens.readingInkMuted)),
                  ),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildEntryCard(
                          theme, tokens, filtered[index], typography);
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme, ReadingTokens tokens) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildDropdownChip(theme, tokens, _selectedSource, [
            'All',
            'Commentary',
            'Devotionals'
          ], (val) {
            setState(() => _selectedSource = val);
          }),
          const SizedBox(width: 8),
          _buildDropdownChip(theme, tokens, _selectedScope,
              ['All Contexts', 'Chapter Level', 'Verse Level'], (val) {
            setState(() => _selectedScope = val);
          }),
        ],
      ),
    );
  }

  Widget _buildDropdownChip(ThemeData theme, ReadingTokens tokens,
      String current, List<String> options, ValueChanged<String> onChanged) {
    return Center(
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.05),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: current,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: theme.primaryColor),
            alignment: Alignment.center,
            dropdownColor: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(value),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(ThemeData theme, ReadingTokens tokens,
      CommentaryEntry entry, TypographyState typography) {
    final isDevotional = entry.category == StudyContentCategory.devotional;
    final isStudyNote = entry.category == StudyContentCategory.studyNote;

    final bgColor = isDevotional
        ? tokens.readingAccent.withValues(alpha: 0.05)
        : isStudyNote
            ? tokens.readingInkMuted.withValues(alpha: 0.05)
            : theme.colorScheme.surface.withValues(alpha: 0.5);

    final border = isDevotional
        ? Border.all(color: tokens.readingAccent.withValues(alpha: 0.2))
        : Border.all(color: tokens.readingBorder.withValues(alpha: 0.3));

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: bgColor,
        border: border,
        borderRadius: BorderRadius.circular(20),
      ),
      child: _buildEntryContent(theme, tokens, entry, typography),
    );
  }

  List<TextSpan> _parseMarkdown(String text, TextStyle? baseStyle) {
    final spans = <TextSpan>[];
    final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final match in exp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  Widget _buildEntryContent(ThemeData theme, ReadingTokens tokens,
      CommentaryEntry entry, TypographyState typography) {
    final paragraphs = entry.text.split('\n\n');
    final isDevotional = entry.category == StudyContentCategory.devotional;
    final isStudyNote = entry.category == StudyContentCategory.studyNote;

    final baseStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: typography.fontSize,
      height: typography.lineHeight,
      fontFamily: typography.fontFamily,
      fontStyle: typography.fontStyle,
      color: tokens.readingInk,
    );

    IconData sourceIcon = Icons.library_books_rounded;
    if (isDevotional) sourceIcon = Icons.favorite_rounded;
    if (isStudyNote) sourceIcon = Icons.edit_note_rounded;

    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sourceIcon, size: 16, color: tokens.readingAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.source.isNotEmpty ? entry.source : 'Commentary',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: tokens.readingAccent,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tokens.readingAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.scope.type == 'verse'
                      ? 'Verse ${entry.scope.verse}'
                      : 'Chapter View',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.readingAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RichText(
                  text: TextSpan(
                    style: baseStyle,
                    children: _parseMarkdown(p.trim(), baseStyle),
                  ),
                ),
              )),
          Divider(height: 24, color: tokens.readingBorder),
          Row(
            children: [
              Text(
                entry.author,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tokens.readingInkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
