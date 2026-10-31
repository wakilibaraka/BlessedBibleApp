import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../data/localized_book_names.dart';
import '../../l10n/l10n.dart';
import '../../models/commentary_entry.dart';
import '../../models/study_content_category.dart';
import '../../state/bible_provider.dart';
import '../../state/commentary_provider.dart';
import '../../state/read_location_provider.dart';
import '../../state/read_settings_provider.dart';
import '../../state/surface_style_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/typography_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_tokens.dart';
import '../../theme/reading_tokens.dart';
import '../widgets/commentary_prose.dart';
import '../widgets/prose_text.dart';
import '../widgets/commentary_view.dart' show shareCommentaryEntry;
import '../widgets/state_views.dart';

/// Full-page commentary for a chapter, opened from the reader and from the
/// home cards.
///
/// Two layouts share the same filtering logic:
/// - **Refined** (default): a verse pull-quote, pill filters and editorial
///   entry cards.
/// - **Classic**: the previous flat list, selectable in Settings.
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

  static const _sources = ['All', 'Commentary', 'Devotionals'];
  static const _scopes = ['All Contexts', 'Chapter Level', 'Verse Level'];

  String? _lookupVerseText() {
    if (widget.verseText != null && widget.verseText!.isNotEmpty) {
      return widget.verseText;
    }
    final verseNum = widget.verse;
    if (verseNum == null) return null;
    final books = ref.read(bibleProvider).books;
    if (books.isEmpty) return null;
    try {
      final book = books.firstWhere(
        (b) =>
            b.name.toLowerCase() == widget.book.toLowerCase() ||
            b.abbreviation.toLowerCase() == widget.book.toLowerCase(),
      );
      if (widget.chapter <= 0 || widget.chapter > book.chapters.length) {
        return null;
      }
      final chapter = book.chapters[widget.chapter - 1];
      if (verseNum <= 0 || verseNum > chapter.verses.length) return null;
      return chapter.verses[verseNum - 1].text;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appThemeMode = ref.watch(resolvedThemeProvider);
    final surfaceStyle = ref.watch(surfaceStyleProvider);
    final theme = Theme.of(context);
    final tokens = Theme.of(context).extension<ReadingTokens>()!;
    final typography = ref.watch(typographyProvider);
    final style =
        ref.watch(readSettingsProvider.select((s) => s.commentaryStyle));
    final refined = style == CommentaryStyle.refined;

    final asyncEntries = ref.watch(commentaryProvider);

    Color background() {
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
          return AppColors.duskBackground;
        case AppThemeMode.fresh:
          return AppColors.freshBackground;
        default:
          return tokens.readingPaper;
      }
    }

    final verseText = _lookupVerseText();
    final reference = localizedReference(
      widget.verse != null
          ? '${widget.book} ${widget.chapter}:${widget.verse}'
          : '${widget.book} ${widget.chapter}',
      Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      backgroundColor: background(),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme, tokens, reference, refined),
          if (refined) ...[
            if (verseText != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: CommentaryVerseCard(
                    reference: reference,
                    verseText: verseText,
                    refined: true,
                    ink: tokens.readingInk,
                    accent: tokens.readingAccent,
                    surface: tokens.readingSurface,
                    border: tokens.readingBorder,
                    shadow: context.palette.shadow,
                    typography: typography,
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      openReaderAtVerse(
                        ref,
                        bookName: widget.book,
                        chapter: widget.chapter,
                        verse: widget.verse,
                      );
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: _buildRefinedFilters(theme, tokens),
            ),
          ] else
            SliverToBoxAdapter(child: _buildClassicFilters(theme, tokens)),
          asyncEntries.when(
            loading: () => const SliverFillRemaining(child: LoadingView()),
            error: (e, st) => SliverFillRemaining(
              child: ErrorState(
                error: e,
                message: context.l10n.studyCommentaryLoadError,
                onRetry: () => ref.invalidate(commentaryProvider),
              ),
            ),
            data: (entries) {
              final filtered = _filter(entries);
              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      context.l10n.studyNoContentForFilters,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: tokens.readingInkMuted),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(16, refined ? 12 : 16, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => refined
                        ? _buildRefinedEntry(
                            theme, tokens, typography, filtered[index])
                        : _buildClassicEntry(
                            theme, tokens, typography, filtered[index]),
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

  List<CommentaryEntry> _filter(List<CommentaryEntry> entries) {
    final book = widget.book.toLowerCase();
    return entries.where((entry) {
      if (entry.scope.book?.toLowerCase() != book) return false;
      if (entry.scope.chapter != widget.chapter) return false;

      if (_selectedSource == 'Devotionals' &&
          entry.category != StudyContentCategory.devotional) {
        return false;
      }
      if (_selectedSource == 'Commentary' &&
          entry.category != StudyContentCategory.commentary) {
        return false;
      }

      if (_selectedScope == 'Chapter Level' && entry.scope.type != 'chapter') {
        return false;
      }
      if (_selectedScope == 'Verse Level' && entry.scope.type != 'verse') {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  Widget _buildAppBar(
      ThemeData theme, ReadingTokens tokens, String reference, bool refined) {
    final blurBackground = reduceTransparency(context)
        ? Container(color: theme.scaffoldBackgroundColor)
        : ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
              ),
            ),
          );

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      toolbarHeight: refined ? 68 : kToolbarHeight,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: theme.primaryColor, size: 20),
        tooltip: context.l10n.commonBack,
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: refined
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.studyCommentaryEyebrow.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.readingAccent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    fontSize: TypeScale.micro,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: tokens.readingInk,
                  ),
                ),
              ],
            )
          : Text(
              reference,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: theme.primaryColor,
              ),
            ),
      flexibleSpace: blurBackground,
    );
  }

  // ── Filters ───────────────────────────────────────────────────────────────

  /// Refined: one tap for the common choices, no hidden menus.
  Widget _buildRefinedFilters(ThemeData theme, ReadingTokens tokens) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final source in _sources)
            _FilterPill(
              label: _optionLabel(source),
              isSelected: _selectedSource == source,
              accent: tokens.readingAccent,
              onTap: () {
                if (_selectedSource == source) return;
                setState(() => _selectedSource = source);
              },
            ),
          _ScopeMenu(
            current: _selectedScope,
            options: _scopes,
            label: _optionLabel,
            accent: tokens.readingAccent,
            onChanged: (value) => setState(() => _selectedScope = value),
          ),
        ],
      ),
    );
  }

  /// Classic: the two dropdown chips over the list.
  Widget _buildClassicFilters(ThemeData theme, ReadingTokens tokens) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildDropdownChip(theme, tokens, _selectedSource, _sources,
              (val) => setState(() => _selectedSource = val)),
          const SizedBox(width: 8),
          _buildDropdownChip(theme, tokens, _selectedScope, _scopes,
              (val) => setState(() => _selectedScope = val)),
        ],
      ),
    );
  }

  Widget _buildDropdownChip(ThemeData theme, ReadingTokens tokens,
      String current, List<String> options, ValueChanged<String> onChanged) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.05),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: current,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: theme.primaryColor),
            alignment: Alignment.center,
            dropdownColor: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(Radii.lg),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(_optionLabel(value)),
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

  /// Display label for a filter option; the option strings themselves are
  /// identifiers used by the filtering logic.
  String _optionLabel(String value) {
    final l10n = context.l10n;
    switch (value) {
      case 'All':
        return l10n.studyFilterAll;
      case 'Commentary':
        return l10n.studyCategoryCommentary;
      case 'Devotionals':
        return l10n.studyFilterDevotionals;
      case 'All Contexts':
        return l10n.studyFilterAllContexts;
      case 'Chapter Level':
        return l10n.studyFilterChapterLevel;
      case 'Verse Level':
        return l10n.studyFilterVerseLevel;
    }
    return value;
  }

  // ── Entries ───────────────────────────────────────────────────────────────

  Widget _buildRefinedEntry(ThemeData theme, ReadingTokens tokens,
      TypographyState typography, CommentaryEntry entry) {
    final isDevotional = entry.category == StudyContentCategory.devotional;
    final isStudyNote = entry.category == StudyContentCategory.studyNote;
    final icon = isDevotional
        ? Icons.favorite_rounded
        : (isStudyNote ? Icons.edit_note_rounded : Icons.library_books_rounded);
    final source = entry.source.isNotEmpty
        ? entry.source
        : context.l10n.studyCommentaryEyebrow;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDevotional
            ? tokens.readingAccent.withValues(alpha: 0.05)
            : tokens.readingSurface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(
          color: isDevotional
              ? tokens.readingAccent.withValues(alpha: 0.22)
              : tokens.readingBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: tokens.readingAccent),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    source.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tokens.readingAccent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: TypeScale.micro,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.commonShare,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  icon: Icon(Icons.ios_share_rounded,
                      color: tokens.readingAccent.withValues(alpha: 0.8)),
                  onPressed: () => shareCommentaryEntry(context, entry,
                      book: widget.book, chapter: widget.chapter),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ProseText(
                text: entry.text,
                typography: typography,
                accent: tokens.readingAccent,
                baseStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: typography.fontSize,
                  height: typography.lineHeight,
                  fontFamily: typography.fontFamily,
                  fontStyle: typography.fontStyle,
                  color: tokens.readingInk,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  _ScopeTag(
                    label: entry.scope.type == 'verse'
                        ? context.l10n.studyVerseLabel('${entry.scope.verse}')
                        : context.l10n.studyChapterView,
                    accent: tokens.readingAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tokens.readingInkMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassicEntry(ThemeData theme, ReadingTokens tokens,
      TypographyState typography, CommentaryEntry entry) {
    final isDevotional = entry.category == StudyContentCategory.devotional;
    final isStudyNote = entry.category == StudyContentCategory.studyNote;
    final icon = isDevotional
        ? Icons.favorite_rounded
        : (isStudyNote ? Icons.edit_note_rounded : Icons.library_books_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDevotional
            ? tokens.readingAccent.withValues(alpha: 0.05)
            : isStudyNote
                ? tokens.readingInkMuted.withValues(alpha: 0.05)
                : theme.colorScheme.surface.withValues(alpha: 0.5),
        border: isDevotional
            ? Border.all(color: tokens.readingAccent.withValues(alpha: 0.2))
            : Border.all(color: tokens.readingBorder.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(Radii.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tokens.readingAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.source.isNotEmpty
                      ? entry.source
                      : context.l10n.studyCommentaryEyebrow,
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
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Text(
                  entry.scope.type == 'verse'
                      ? context.l10n.studyVerseLabel('${entry.scope.verse}')
                      : context.l10n.studyChapterView,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tokens.readingAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProseText(
            text: entry.text,
            typography: typography,
            accent: tokens.readingAccent,
            refined: false,
            baseStyle: theme.textTheme.bodyLarge?.copyWith(
              fontSize: typography.fontSize,
              height: typography.lineHeight,
              fontFamily: typography.fontFamily,
              fontStyle: typography.fontStyle,
              color: tokens.readingInk,
            ),
          ),
          Divider(height: 24, color: tokens.readingBorder),
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.author,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tokens.readingInkMuted,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.commonShare,
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                icon: Icon(Icons.ios_share_rounded,
                    color: tokens.readingAccent.withValues(alpha: 0.8)),
                onPressed: () => shareCommentaryEntry(context, entry,
                    book: widget.book, chapter: widget.chapter),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small pieces ────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTouchTarget),
          child: AnimatedContainer(
            duration: Motion.of(context, Motion.normal),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? accent : accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(
                color: isSelected ? accent : accent.withValues(alpha: 0.18),
              ),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppPalette.onColor(accent)
                      : accent.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScopeMenu extends StatelessWidget {
  final String current;
  final List<String> options;
  final String Function(String) label;
  final Color accent;
  final ValueChanged<String> onChanged;

  const _ScopeMenu({
    required this.current,
    required this.options,
    required this.label,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: kMinTouchTarget),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isDense: true,
          icon:
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: accent),
          dropdownColor: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(Radii.lg),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: accent,
          ),
          items: options
              .map((value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(label(value)),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _ScopeTag extends StatelessWidget {
  final String label;
  final Color accent;

  const _ScopeTag({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: TypeScale.micro,
            ),
      ),
    );
  }
}
