import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/bible_provider.dart';
import '../../state/translation_provider.dart';
import '../../services/bible_database_service.dart';
import '../../data/models/bible_model.dart';
import '../../state/typography_provider.dart';

class VersePreviewDialog extends ConsumerWidget {
  final String reference;
  final String bookAbbrev;
  final int chapter;
  final int verseNum;

  const VersePreviewDialog({
    super.key,
    required this.reference,
    required this.bookAbbrev,
    required this.chapter,
    required this.verseNum,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final bibleState = ref.watch(bibleProvider);
    
    int? bookNumber;
    String? fullBookName;
    
    final searchName = bookAbbrev.toLowerCase().replaceAll('.', '').trim();
    for (final book in bibleState.books) {
      final bn = book.name.toLowerCase();
      if (bn == searchName || bn.startsWith(searchName)) {
        bookNumber = bibleState.books.indexOf(book) + 1;
        fullBookName = book.name;
        break;
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 24,
              spreadRadius: 8,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fullBookName != null 
                        ? '$fullBookName $chapter:$verseNum' 
                        : reference,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (bookNumber == null)
              const Text('Could not find the referenced book.')
            else
              FutureBuilder<BibleVerse?>(
                future: bibleDbService.getVerse(
                  ref.watch(activeTranslationProvider),
                  bookNumber,
                  chapter,
                  verseNum,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Text('Error loading verse: ${snapshot.error}');
                  }
                  
                  final verse = snapshot.data;
                  if (verse == null) {
                    return const Text('Verse not found.');
                  }
                  
                  return SingleChildScrollView(
                    child: Text(
                      verse.text.replaceAll(RegExp(r'[<\[][^>\]]*[>\]]'), ''),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: typography.lineHeight,
                        fontSize: typography.fontSize,
                        fontFamily: typography.fontFamily,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
