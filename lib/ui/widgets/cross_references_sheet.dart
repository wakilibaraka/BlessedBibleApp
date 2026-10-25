import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/l10n.dart';
import '../../data/localized_book_names.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/cross_references_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/translation_provider.dart';
import '../../services/bible_database_service.dart';
import 'state_views.dart';

/// A bottom sheet showing all cross-references for a given verse.
class CrossReferencesSheet extends ConsumerWidget {
  final int bookNumber;
  final int chapter;
  final int verse;
  final String bookName;

  const CrossReferencesSheet({
    super.key,
    required this.bookNumber,
    required this.chapter,
    required this.verse,
    required this.bookName,
  });

  String _bookName(BuildContext context, WidgetRef ref, int num) {
    final books = ref.watch(bibleProvider).books;
    if (num >= 1 && num <= books.length) return books[num - 1].name;
    return context.l10n.readBookFallback(num);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final key = (bookNumber: bookNumber, chapter: chapter, verse: verse);
    final crossRefsAsync = ref.watch(crossReferencesProvider(key));
    final activeTranslation = ref.watch(activeTranslationProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Radii.xs),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.readRelatedVerses,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.referenceInLocale('$bookName $chapter:$verse'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Flexible(
            child: crossRefsAsync.when(
              data: (refs) {
                if (refs.isEmpty) {
                  return EmptyState(
                    icon: Icons.link_off_rounded,
                    title: context.l10n.readNoCrossRefs,
                    message: context.l10n.readCrossRefsComingSoon,
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  itemCount: refs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (context, index) {
                    final cr = refs[index];
                    final targetBookName =
                        _bookName(context, ref, cr.toBookNumber);
                    final refLabel =
                        '$targetBookName ${cr.toChapter}:${cr.toVerse}';

                    return _CrossRefTile(
                      refLabel: refLabel,
                      bookNumber: cr.toBookNumber,
                      chapter: cr.toChapter,
                      verse: cr.toVerse,
                      translationId: activeTranslation,
                      votes: cr.votes,
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: LoadingView(),
              ),
              error: (e, _) => ErrorState(
                error: e,
                message: context.l10n.readCrossRefsLoadErrorPlain,
                onRetry: () => ref.invalidate(crossReferencesProvider(key)),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _CrossRefTile extends ConsumerStatefulWidget {
  final String refLabel;
  final int bookNumber;
  final int chapter;
  final int verse;
  final String translationId;
  final int votes;

  const _CrossRefTile({
    required this.refLabel,
    required this.bookNumber,
    required this.chapter,
    required this.verse,
    required this.translationId,
    required this.votes,
  });

  @override
  ConsumerState<_CrossRefTile> createState() => _CrossRefTileState();
}

class _CrossRefTileState extends ConsumerState<_CrossRefTile> {
  String? _verseText;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchVerse();
  }

  Future<void> _fetchVerse() async {
    try {
      final verses = await bibleDbService.getChapter(
        widget.translationId,
        widget.bookNumber,
        widget.chapter,
      );
      final match = verses.where((v) => v.number == widget.verse).firstOrNull;
      if (mounted) {
        setState(() {
          _verseText = match?.text;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        if (_verseText != null) {
          showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(widget.refLabel),
              content: Text(_verseText!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.commonClose),
                ),
              ],
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reference badge (Flexible so a long name at large text
            // wraps instead of overflowing the row).
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Text(
                  widget.refLabel,
                  style: TextStyle(
                    fontSize: TypeScale.caption,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _loading
                  ? Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Radii.xs),
                      ),
                    )
                  : Text(
                      _verseText ?? context.l10n.readVerseUnavailable,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                        color: _verseText == null
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                            : null,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the cross-references sheet as a modal bottom sheet.
void showCrossReferencesSheet(
  BuildContext context, {
  required int bookNumber,
  required int chapter,
  required int verse,
  required String bookName,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CrossReferencesSheet(
      bookNumber: bookNumber,
      chapter: chapter,
      verse: verse,
      bookName: bookName,
    ),
  );
}
