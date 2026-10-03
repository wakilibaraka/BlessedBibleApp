import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/cross_references_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/translation_provider.dart';
import '../../services/bible_database_service.dart';


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

  String _bookName(WidgetRef ref, int num) {
    final books = ref.watch(bibleProvider).books;
    if (num >= 1 && num <= books.length) return books[num - 1].name;
    return 'Book $num';
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Related Verses',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$bookName $chapter:$verse',
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
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.link_off_rounded,
                            size: 40,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No cross-references found for this verse.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cross-references will be available\nafter the next app update.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  itemCount: refs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                  itemBuilder: (context, index) {
                    final cr = refs[index];
                    final targetBookName = _bookName(ref, cr.toBookNumber);
                    final refLabel = '$targetBookName ${cr.toChapter}:${cr.toVerse}';

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
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: $e'),
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
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(widget.refLabel),
              content: Text(_verseText!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reference badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.refLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _loading
                  ? Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : Text(
                      _verseText ?? 'Verse not available',
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
  showModalBottomSheet(
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
