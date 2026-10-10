import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/bible_provider.dart';
import '../../state/typography_provider.dart';
import '../../state/read_location_provider.dart';
import '../../data/models/bible_model.dart';
import 'textured_glass_container.dart';

class VersePreviewModal extends ConsumerWidget {
  final String reference;
  final String bookName;
  final int chapter;
  final int startVerse;
  final int? endVerse;

  /// Last chapter for cross-chapter ranges (Genesis 1:1-3:24).
  /// Defaults to [chapter] (single-chapter range or single verse).
  final int? endChapter;

  /// Whole-chapter reference ("Genesis 1"): shows every verse.
  final bool wholeChapter;

  const VersePreviewModal({
    super.key,
    required this.reference,
    required this.bookName,
    required this.chapter,
    required this.startVerse,
    this.endVerse,
    this.endChapter,
    this.wholeChapter = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final bibleState = ref.watch(bibleProvider);

    String verseText = context.l10n.readLoading;

    if (!bibleState.isLoading) {
      final book = bibleState.books.cast<BibleBook?>().firstWhere(
            (b) => b?.name == bookName,
            orElse: () => null,
          );

      if (book != null && chapter > 0 && chapter <= book.chapters.length) {
        final lastChapter =
            (endChapter ?? chapter).clamp(chapter, book.chapters.length);
        final texts = <String>[];
        for (var ch = chapter; ch <= lastChapter; ch++) {
          final chapterData = book.chapters[ch - 1];
          final firstV = ch == chapter ? startVerse : 1;
          final lastV = ch == lastChapter
              ? (wholeChapter
                  ? chapterData.verses.length
                  : (endVerse ?? startVerse))
              : chapterData.verses.length;
          for (int i = firstV; i <= lastV; i++) {
            final verse = chapterData.verses.cast<BibleVerse?>().firstWhere(
                  (v) => v?.number == i,
                  orElse: () => null,
                );
            if (verse != null) {
              final label = lastChapter == chapter
                  ? '${verse.number}'
                  : '$ch:${verse.number}';
              texts.add('$label ${verse.text}');
            }
          }
        }

        if (texts.isNotEmpty) {
          verseText = texts.join('\n\n');
        } else {
          verseText = context.l10n.readVerseNotFound;
        }
      } else {
        verseText = context.l10n.readBookOrChapterNotFound;
      }
    }

    return TexturedGlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 12.0, top: 12.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reference,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: typography.fontFamily,
                        fontStyle: typography.fontStyle,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  verseText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: typography.fontFamily,
                    fontStyle: typography.fontStyle,
                    fontSize: typography.fontSize,
                    height: 1.6,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),

            // Open in Read: dismiss the sheet, then jump the reader to
            // the verse (dismissing first keeps the user in context).
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openReaderAtVerse(
                      ref,
                      bookName: bookName,
                      chapter: chapter,
                      verse: startVerse,
                    );
                  },
                  icon: const Icon(Icons.menu_book_rounded),
                  label: Text(context.l10n.readOpenInRead),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
