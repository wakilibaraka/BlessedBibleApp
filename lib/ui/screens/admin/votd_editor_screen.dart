import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_editor_scaffold.dart';
import '../../../state/bible_provider.dart';

class _ParsedRef {
  final String book;
  final int chapter;
  final int? verse;
  _ParsedRef(this.book, this.chapter, this.verse);
}

_ParsedRef _parseReference(String refStr) {
  final lastSpaceIdx = refStr.lastIndexOf(' ');
  if (lastSpaceIdx != -1) {
    final bookName = refStr.substring(0, lastSpaceIdx);
    final refParts = refStr.substring(lastSpaceIdx + 1).split(':');
    final chapterNum =
        int.tryParse(refParts.isNotEmpty ? refParts[0] : '') ?? 1;
    final verseNum = refParts.length > 1 ? int.tryParse(refParts[1]) : null;
    return _ParsedRef(bookName, chapterNum, verseNum);
  }
  return _ParsedRef(refStr, 1, null);
}

class VotdEditorScreen extends ConsumerStatefulWidget {
  const VotdEditorScreen({super.key});

  @override
  ConsumerState<VotdEditorScreen> createState() => _VotdEditorScreenState();
}

class _VotdEditorScreenState extends ConsumerState<VotdEditorScreen> {
  DateTime _selectedDate = DateTime.now();
  final _refController = TextEditingController();
  final _langController = TextEditingController(text: 'en');
  bool _isSaving = false;

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _loadExisting() async {
    final docId = _formatDate(_selectedDate);
    try {
      final doc = await FirebaseFirestore.instance.collection('VOTD').doc(docId).get();
      if (doc.exists) {
        _refController.text = doc.data()?['reference'] ?? '';
        _langController.text = doc.data()?['language_code'] ?? 'en';
      } else {
        _refController.text = '';
      }
    } catch (e) {
      // Ignored for smooth UX
    }
    setState(() {}); // trigger preview update
  }

  void _save() async {
    setState(() => _isSaving = true);
    final docId = _formatDate(_selectedDate);
    try {
      await FirebaseFirestore.instance.collection('VOTD').doc(docId).set({
        'reference': _refController.text.trim(),
        'language_code': _langController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Firestore!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _isSaving = false);
  }

  String _getPreviewText() {
    final refStr = _refController.text.trim();
    if (refStr.isEmpty) return 'Enter a reference to see preview...';
    
    final parts = _parseReference(refStr);
    final bibleState = ref.watch(bibleProvider);
    if (bibleState.isLoading) return 'Loading Bible database...';
    
    try {
      final book = bibleState.books.firstWhere((b) => b.name.toLowerCase() == parts.book.toLowerCase());
      final chapter = book.chapters[parts.chapter - 1];
      if (parts.verse != null) {
         final verse = chapter.verses.firstWhere((v) => v.number == parts.verse);
         return verse.text;
      } else {
         return '${chapter.verses.first.text} ...';
      }
    } catch (e) {
      return 'Reference not found in local Bible.';
    }
  }

  @override
  void initState() {
    super.initState();
    _refController.addListener(() => setState(() {}));
    _loadExisting();
  }

  @override
  void dispose() {
    _refController.dispose();
    _langController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(_selectedDate);
    final isValid = _refController.text.trim().isNotEmpty && _langController.text.trim().isNotEmpty;
    
    return AdminEditorScaffold(
      title: 'VOTD Editor',
      isSaving: _isSaving,
      isValid: isValid,
      onSave: _save,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text('Target Date (Document ID)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(dateStr, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                    _loadExisting();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _refController,
              decoration: InputDecoration(
                labelText: 'Bible Reference',
                hintText: 'e.g., John 3:16',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _langController,
              decoration: InputDecoration(
                labelText: 'Language Code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Verse Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                _getPreviewText(),
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
