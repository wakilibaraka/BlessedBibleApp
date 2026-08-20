import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_editor_scaffold.dart';
import '../../../models/commentary_entry.dart';

class CommentaryEditorListScreen extends StatefulWidget {
  const CommentaryEditorListScreen({super.key});

  @override
  State<CommentaryEditorListScreen> createState() => _CommentaryEditorListScreenState();
}

class _CommentaryEditorListScreenState extends State<CommentaryEditorListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Commentary')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by book or text...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('commentary').limit(100).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data!.docs;
                final filtered = docs.where((d) {
                  if (_searchQuery.isEmpty) return true;
                  final data = d.data() as Map<String, dynamic>;
                  final scope = data['scope'] as Map<String, dynamic>? ?? {};
                  final book = (scope['book'] as String? ?? '').toLowerCase();
                  final text = (data['text'] as String? ?? '').toLowerCase();
                  return book.contains(_searchQuery) || text.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching commentary entries found.'));
                }
                
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
                    data['id'] = doc.id;
                    final entry = CommentaryEntry.fromJson(data);
                    
                    final title = '${entry.scope.book ?? "Custom"} ${entry.scope.chapter ?? ""}${entry.scope.verse != null ? ':${entry.scope.verse}' : ''}'.trim();
                    
                    return ListTile(
                      title: Text(title.isNotEmpty ? title : 'Global/Topic Entry', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(entry.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.edit, size: 16),
                      onTap: () => Navigator.push(context, CupertinoPageRoute(
                        builder: (_) => SingleCommentaryEditorScreen(entry: entry),
                      )),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SingleCommentaryEditorScreen extends StatefulWidget {
  final CommentaryEntry entry;
  const SingleCommentaryEditorScreen({super.key, required this.entry});

  @override
  State<SingleCommentaryEditorScreen> createState() => _SingleCommentaryEditorScreenState();
}

class _SingleCommentaryEditorScreenState extends State<SingleCommentaryEditorScreen> {
  late TextEditingController _textCtrl;
  late TextEditingController _typeCtrl;
  late TextEditingController _bookCtrl;
  late TextEditingController _chapterCtrl;
  late TextEditingController _verseCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.entry.text);
    _typeCtrl = TextEditingController(text: widget.entry.scope.type);
    _bookCtrl = TextEditingController(text: widget.entry.scope.book ?? '');
    _chapterCtrl = TextEditingController(text: widget.entry.scope.chapter?.toString() ?? '');
    _verseCtrl = TextEditingController(text: widget.entry.scope.verse?.toString() ?? '');
    
    _textCtrl.addListener(() => setState((){}));
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _typeCtrl.dispose();
    _bookCtrl.dispose();
    _chapterCtrl.dispose();
    _verseCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    setState(() => _isSaving = true);
    try {
      final scopeMap = {
        'type': _typeCtrl.text.trim(),
        if (_bookCtrl.text.trim().isNotEmpty) 'book': _bookCtrl.text.trim(),
        if (_chapterCtrl.text.trim().isNotEmpty) 'chapter': int.tryParse(_chapterCtrl.text.trim()),
        if (_verseCtrl.text.trim().isNotEmpty) 'verse': int.tryParse(_verseCtrl.text.trim()),
      };

      await FirebaseFirestore.instance.collection('commentary').doc(widget.entry.id).update({
        'text': _textCtrl.text.trim(),
        'scope': scopeMap,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved entry in place!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _isSaving = false);
  }
  
  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('Are you sure you want to delete this commentary entry? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    );
    
    if (confirm != true) return;
    
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('commentary').doc(widget.entry.id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _textCtrl.text.trim().isNotEmpty && _typeCtrl.text.trim().isNotEmpty;

    return AdminEditorScaffold(
      title: 'Edit Commentary',
      isSaving: _isSaving,
      isValid: isValid,
      onSave: _save,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                'Document ID: ${widget.entry.id}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Scope Rules', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _typeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Type (e.g. verse, chapter)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _bookCtrl,
                    decoration: InputDecoration(
                      labelText: 'Book (e.g. Genesis)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chapterCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Chapter',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _verseCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Verse',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Commentary Body', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _textCtrl,
              maxLines: 15,
              minLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter commentary text...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _delete,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete this Entry', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
