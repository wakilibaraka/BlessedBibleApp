import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/pericopes_provider.dart';
import '../../state/commentary_provider.dart';
import '../../state/notes_provider.dart';
import '../../state/bible_provider.dart';
import '../../state/translation_provider.dart';
import '../../data/models/bible_model.dart';
import '../../data/models/home_data.dart';
import '../widgets/textured_glass_container.dart';
import '../widgets/shared_app_bar.dart';
import '../sheets/book_chapter_selector_sheet.dart';

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
                  key: ValueKey(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.withValues(alpha: 0.8),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(notesProvider.notifier).remove(note.id);
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
    {String? initialReference, PersonalNote? editingNote, String? editingId}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _NoteEditorForm(
      editingNote: editingNote,
      editingId: editingId,
      initialReference: initialReference,
      theme: theme,
    ),
  );
}

class _NoteEditorForm extends ConsumerStatefulWidget {
  final PersonalNote? editingNote;
  final String? editingId;
  final String? initialReference;
  final ThemeData theme;

  const _NoteEditorForm({
    this.editingNote,
    this.editingId,
    this.initialReference,
    required this.theme,
  });

  @override
  ConsumerState<_NoteEditorForm> createState() => _NoteEditorFormState();
}

class _NoteEditorFormState extends ConsumerState<_NoteEditorForm> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool _showSlashMenu = false;
  int _slashIndex = -1;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.editingNote?.title ?? '');
    contentController = TextEditingController(text: widget.editingNote?.content ?? '');

    if (widget.editingNote == null && widget.initialReference != null) {
      final initialReference = widget.initialReference!;
      final lastSpaceIdx = initialReference.lastIndexOf(' ');
      if (lastSpaceIdx != -1) {
        final bookName = initialReference.substring(0, lastSpaceIdx);
        final refParts = initialReference.substring(lastSpaceIdx + 1).split(':');
        if (refParts.isNotEmpty) {
          final chapterNum = int.tryParse(refParts[0]);
          if (chapterNum != null) {
            final chapterTitle = ref.read(pericopesProvider.notifier).getPericopesForChapter(bookName, chapterNum).where((p) => p.startVerse == 1).firstOrNull?.title;
            if (chapterTitle != null && chapterTitle.isNotEmpty) {
              titleController.text = chapterTitle;
            }
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

    contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    contentController.removeListener(_onContentChanged);
    contentController.dispose();
    titleController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    final text = contentController.text;
    final selection = contentController.selection;
    if (selection.baseOffset == -1) return;

    final cursorPosition = selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPosition);
    final lines = textBeforeCursor.split('\n');
    if (lines.isEmpty) return;
    
    final currentLine = lines.last;

    if (currentLine == '/' || currentLine.endsWith(' /')) {
      if (!_showSlashMenu) {
        setState(() {
          _showSlashMenu = true;
          _slashIndex = cursorPosition - 1;
        });
      }
    } else {
      if (_showSlashMenu) {
        setState(() {
          _showSlashMenu = false;
          _slashIndex = -1;
        });
      }
    }
  }

  void _insertText(String textToInsert) {
    if (_slashIndex != -1) {
      final text = contentController.text;
      final newText = text.replaceRange(_slashIndex, contentController.selection.baseOffset, textToInsert);
      contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: _slashIndex + textToInsert.length),
      );
    }
  }

  void _insertVerse() async {
    setState(() { _showSlashMenu = false; });
    final books = ref.read(bibleProvider).books;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: false,
      builder: (ctx) => BookChapterSelectorSheet(
        books: books,
        selectedBookAbbrev: books.first.abbreviation,
        selectedChapter: 1,
        onSelectionChanged: (abbrev, name, chapter, verse, {bool autoClose = true}) {
          if (autoClose) Navigator.pop(ctx);
          if (verse == null) return;
          
          final bookNum = books.indexWhere((b) => b.abbreviation == abbrev) + 1;
          final activeTrans = ref.read(activeTranslationProvider);
          final versesAsync = ref.read(translationChapterProvider((
            translationId: activeTrans,
            bookNumber: bookNum,
            chapterNumber: chapter,
          )));
          
          String verseText = '';
          if (versesAsync.value != null) {
            final target = versesAsync.value!.firstWhere((v) => v.number == verse, orElse: () => BibleVerse(number: verse, text: ''));
            verseText = target.text;
          }
          if (verseText.isEmpty) {
            final flatList = ref.read(flatChaptersProvider);
            final targetChapter = flatList.firstWhere((fc) => fc.book.abbreviation == abbrev && fc.chapter.number == chapter);
            final target = targetChapter.chapter.verses.firstWhere((v) => v.number == verse);
            verseText = target.text;
          }
          
          final insertedText = '"$verseText" - $name $chapter:$verse ';
          _insertText(insertedText);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Verse inserted'),
              action: SnackBarAction(
                label: 'Add Commentary',
                onPressed: () {
                  final commentaryList = ref.read(commentaryProvider).value ?? [];
                  final matchList = commentaryList.where(
                    (c) => c.scope.book?.toLowerCase() == name.toLowerCase() && c.scope.chapter == chapter && (c.scope.verse == verse || c.scope.verse == null)
                  ).toList();
                  
                  if (matchList.isNotEmpty) {
                    final firstPara = matchList.first.text.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
                    if (firstPara.isNotEmpty) {
                       final text = contentController.text;
                       final cursor = contentController.selection.baseOffset;
                       final newText = text.replaceRange(cursor, cursor, '\n$firstPara\n');
                       contentController.value = TextEditingValue(
                         text: newText,
                         selection: TextSelection.collapsed(offset: cursor + firstPara.length + 2),
                       );
                    }
                  }
                }
              )
            )
          );
        },
      )
    );
  }

  void _insertDate() {
    setState(() { _showSlashMenu = false; });
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    _insertText('${months[now.month - 1]} ${now.day}, ${now.year} ');
  }

  void _insertChapterTitle() {
    setState(() { _showSlashMenu = false; });
    final refStr = widget.editingNote?.reference ?? widget.initialReference;
    if (refStr != null) {
      final lastSpaceIdx = refStr.lastIndexOf(' ');
      if (lastSpaceIdx != -1) {
        final bookName = refStr.substring(0, lastSpaceIdx);
        final refParts = refStr.substring(lastSpaceIdx + 1).split(':');
        if (refParts.isNotEmpty) {
          final chapterNum = int.tryParse(refParts[0]);
          if (chapterNum != null) {
            final chapterTitle = ref.read(pericopesProvider.notifier).getPericopesForChapter(bookName, chapterNum).where((p) => p.startVerse == 1).firstOrNull?.title;
            if (chapterTitle != null && chapterTitle.isNotEmpty) {
              _insertText('$chapterTitle ');
              return;
            }
          }
        }
      }
    }
    _insertText('Chapter Title ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return TexturedGlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.editingNote != null
                  ? 'Edit Note'
                  : (widget.initialReference != null
                      ? 'New Note on ${widget.initialReference}'
                      : 'New Note'),
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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: TextField(
                controller: contentController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Start typing... (type / for commands)',
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
            ),
            if (_showSlashMenu)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Insert verse'),
                      onTap: _insertVerse,
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Insert date'),
                      onTap: _insertDate,
                    ),
                    ListTile(
                      leading: const Icon(Icons.title),
                      title: const Text('Insert chapter title'),
                      onTap: _insertChapterTitle,
                    ),
                  ],
                ),
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
                  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                ];
                final date =
                    '${months[now.month - 1]} ${now.day.toString().padLeft(2, '0')}, ${now.year}';
                final note = PersonalNote(
                  widget.editingNote?.id ?? const Uuid().v4(),
                  titleController.text.trim(),
                  contentController.text.trim(),
                  date,
                  reference: widget.editingNote?.reference ?? widget.initialReference,
                );

                if (widget.editingId != null) {
                  ref.read(notesProvider.notifier).update(widget.editingId!, note);
                } else {
                  ref.read(notesProvider.notifier).add(note);
                }
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note saved!')),
                );
              },
              child: Text(widget.editingNote != null ? 'Save Changes' : 'Save Note',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (widget.editingId != null) ...[
              const SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  ref.read(notesProvider.notifier).remove(widget.editingId!);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted')),
                  );
                },
                child: const Text('Delete Note',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
