import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/journal_provider.dart';
import '../../l10n/tr_text.dart';
import '../../l10n/l10n.dart';

class JournalSegment extends ConsumerWidget {
  final ThemeData theme;
  const JournalSegment({super.key, required this.theme});

  void _showAddJournalDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const TrText('New Journal Entry'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.tr('How are you feeling today? Pour your heart out...'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const TrText('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(journalProvider.notifier).add(controller.text);
              }
              Navigator.pop(c);
            },
            child: const TrText('Save & Analyze'),
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
            TrText('No journal entries yet.', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _showAddJournalDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const TrText('Write Entry'),
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
              color: theme.primaryColor.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.date.split('T').first,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(entry.content, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    if (entry.detectedEmotions.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          TrText('AI Reflection', style: theme.textTheme.labelMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TrText('Detected Emotion: {0}', args: [entry.detectedEmotions.first], style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      TrText('Verses: {0}', args: [entry.recommendedVerses.join(', ')], style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      ...entry.prayerPoints.map((p) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(p, style: theme.textTheme.bodySmall)),
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
