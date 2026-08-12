import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/chapter_titles_provider.dart';
import '../../state/commentary_provider.dart';
import '../../state/notes_provider.dart';
import '../../data/models/home_data.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/shared_app_bar.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notes = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SharedAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Notes',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded,
                      size: 64,
                      color: theme.primaryColor.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first note.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Dismissible(
                  key: ValueKey(note.title + note.date + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.withValues(alpha: 0.8),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(notesProvider.notifier).remove(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TexturedGlassContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  note.date,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                            if (note.reference != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                note.reference!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddNoteSheet(context, ref, theme),
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

Future<void> showAddNoteSheet(
    BuildContext context, WidgetRef ref, ThemeData theme,
    {String? initialReference}) async {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  if (initialReference != null) {
    // Attempt to extract book, chapter, verse to auto-fill title/commentary
    final lastSpaceIdx = initialReference.lastIndexOf(' ');
    if (lastSpaceIdx != -1) {
      final bookName = initialReference.substring(0, lastSpaceIdx);
      final refParts = initialReference.substring(lastSpaceIdx + 1).split(':');
      if (refParts.isNotEmpty) {
        final chapterNum = int.tryParse(refParts[0]);
        if (chapterNum != null) {
          // 1. Try to set Title from chapter titles
          final chapterTitle = ref.read(chapterTitlesProvider)[bookName]?[chapterNum.toString()];
          if (chapterTitle != null && chapterTitle.isNotEmpty) {
            titleController.text = chapterTitle;
          }

          // 2. Try to set Content from first paragraph of commentary
          final verseNum = refParts.length > 1 ? int.tryParse(refParts[1].split(',')[0]) : null;
          final commentaryList = ref.read(commentaryProvider).value ?? [];
          final matchingCommentaries = commentaryList.where((e) =>
              e.scope.book?.toLowerCase() == bookName.toLowerCase() &&
              e.scope.chapter == chapterNum &&
              (e.scope.verse == verseNum || e.scope.verse == null));
          
          if (matchingCommentaries.isNotEmpty) {
            final contentText = matchingCommentaries.first.text;
            final firstParagraph = contentText.split('\n').firstWhere((line) => line.trim().isNotEmpty, orElse: () => '');
            if (firstParagraph.isNotEmpty) {
              contentController.text = firstParagraph;
            }
          }
        }
      }
    }
  }

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => TexturedGlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            initialReference != null
                ? 'New Note on $initialReference'
                : 'New Note',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Note Title',
              hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.4)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contentController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Start typing...',
              hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.4)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  contentController.text.trim().isEmpty) {
                return;
              }

              final now = DateTime.now();
              const months = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec'
              ];
              final date =
                  '${months[now.month - 1]} ${now.day.toString().padLeft(2, '0')}, ${now.year}';
              final note = PersonalNote(
                titleController.text.trim(),
                contentController.text.trim(),
                date,
                reference: initialReference,
              );

              ref.read(notesProvider.notifier).add(note);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note saved!')),
              );
            },
            child: const Text('Save Note',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}
