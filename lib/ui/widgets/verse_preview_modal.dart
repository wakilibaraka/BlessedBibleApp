import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/bible_provider.dart';
import '../../state/typography_provider.dart';
import '../../data/models/bible_model.dart';
import 'textured_glass_container.dart';

class VersePreviewModal extends ConsumerWidget {
  final String reference;
  final String bookName;
  final int chapter;
  final int startVerse;
  final int? endVerse;

  const VersePreviewModal({
    super.key,
    required this.reference,
    required this.bookName,
    required this.chapter,
    required this.startVerse,
    this.endVerse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final bibleState = ref.watch(bibleProvider);
    
    String verseText = 'Loading...';
    
    if (!bibleState.isLoading) {
      final book = bibleState.books.cast<BibleBook?>().firstWhere(
        (b) => b?.name == bookName,
        orElse: () => null,
      );
      
      if (book != null && chapter > 0 && chapter <= book.chapters.length) {
        final chapterData = book.chapters[chapter - 1];
        
        final texts = <String>[];
        final end = endVerse ?? startVerse;
        
        for (int i = startVerse; i <= end; i++) {
          final verse = chapterData.verses.cast<BibleVerse?>().firstWhere(
            (v) => v?.number == i,
            orElse: () => null,
          );
          if (verse != null) {
            texts.add('${verse.number} ${verse.text}');
          }
        }
        
        if (texts.isNotEmpty) {
          verseText = texts.join('\n\n');
        } else {
          verseText = 'Verse not found.';
        }
      } else {
        verseText = 'Book or chapter not found.';
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
              padding: const EdgeInsets.only(left: 24.0, right: 12.0, top: 12.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reference,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: typography.fontFamily == 'System' ? null : typography.fontFamily,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  verseText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: typography.fontFamily == 'System' ? null : typography.fontFamily,
                    fontSize: typography.fontSize,
                    height: 1.6,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
