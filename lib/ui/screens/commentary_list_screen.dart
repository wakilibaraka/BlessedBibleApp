import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/study_provider.dart';
import '../../state/theme_provider.dart';
import '../../state/typography_provider.dart';
import '../../data/models/commentary_model.dart';

class CommentaryListScreen extends ConsumerWidget {
  const CommentaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typography = ref.watch(typographyProvider);
    final commentaryDataAsync = ref.watch(combinedCommentaryProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Commentary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: commentaryDataAsync.when(
        data: (state) {
          final rev14Data = state.data['Revelation']?['14'];
          if (rev14Data == null || rev14Data.isEmpty) {
            return const Center(child: Text('No commentary available.'));
          }

          final itemList = <MapEntry<String, CommentaryEntry>>[];
          for (final verseStr in rev14Data.keys) {
            for (final entry in rev14Data[verseStr]!) {
              itemList.add(MapEntry(verseStr, entry));
            }
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: itemList.length + (state.isEgwMissing ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == itemList.length) {
                if (state.isEgwMissing) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0, top: 16.0),
                    child: Text(
                      'Local EGW module not found. Place EGW JSON files in your local directory to enable this commentary.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
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
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
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
