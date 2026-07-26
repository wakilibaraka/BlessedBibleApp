import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/study_provider.dart';
import '../../data/models/commentary_model.dart';

class CommentaryListScreen extends ConsumerWidget {
  final String bookName;
  final String chapterNumber;

  const CommentaryListScreen({
    super.key,
    required this.bookName,
    required this.chapterNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final commentaryDataAsync = ref.watch(combinedCommentaryProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('$bookName $chapterNumber Commentary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: commentaryDataAsync.when(
        data: (state) {
          final chapterData = state.data[bookName]?[chapterNumber];
          
          final itemList = <MapEntry<String, CommentaryEntry>>[];
          if (chapterData != null) {
            for (final verseStr in chapterData.keys) {
              for (final entry in chapterData[verseStr]!) {
                itemList.add(MapEntry(verseStr, entry));
              }
            }
          }

          if (itemList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'No commentary available for this verse yet.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: itemList.length,
            itemBuilder: (context, index) {
              final verseStr = itemList[index].key;
              final entry = itemList[index].value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revelation 14:$verseStr',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.title.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('Error loading commentary')),
      ),
    );
  }
}
