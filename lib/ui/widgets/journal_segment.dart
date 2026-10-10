import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/journal_provider.dart';

class JournalSegment extends ConsumerWidget {
  final ThemeData theme;
  const JournalSegment({super.key, required this.theme});

  void _showAddJournalDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(context.l10n.notesNewJournalEntry),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.l10n.notesJournalHint,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(context.l10n.commonCancel)),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(journalProvider.notifier).add(controller.text);
              }
              Navigator.pop(c);
            },
            child: Text(context.l10n.notesSaveAndAnalyze),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(context.l10n.notesNoJournalEntries,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _showAddJournalDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.notesWriteEntry),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              color: theme.primaryColor.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.date.split('T').first,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(entry.content, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    if (entry.detectedEmotions.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 16, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          Text(context.l10n.notesAiReflection,
                              style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          context.l10n.notesDetectedEmotion(
                              entry.detectedEmotions.first),
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text(
                          context.l10n.notesVersesList(
                              entry.recommendedVerses.join(', ')),
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      ...entry.prayerPoints.map((p) => Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(
                                    child: Text(p,
                                        style: theme.textTheme.bodySmall)),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            heroTag: 'journal_fab',
            onPressed: () => _showAddJournalDialog(context, ref),
            child: const Icon(Icons.edit),
          ),
        ),
      ],
    );
  }
}
