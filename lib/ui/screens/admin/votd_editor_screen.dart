import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VotdEditorScreen extends StatefulWidget {
  const VotdEditorScreen({super.key});

  @override
  State<VotdEditorScreen> createState() => _VotdEditorScreenState();
}

class _VotdEditorScreenState extends State<VotdEditorScreen> {
  DateTime _selectedDate = DateTime.now();
  final _refController = TextEditingController();
  final _langController = TextEditingController(text: 'en');
  bool _isLoading = false;

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _loadExisting() async {
    setState(() => _isLoading = true);
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
      // Ignored intentionally for smooth UX
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _save() async {
    setState(() => _isLoading = true);
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
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(_selectedDate);
    return Scaffold(
      appBar: AppBar(title: const Text('VOTD Editor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Target Date (Doc ID)'),
              subtitle: Text(dateStr),
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
            TextField(
              controller: _refController,
              decoration: const InputDecoration(labelText: 'Bible Reference (e.g., John 3:16)'),
            ),
            TextField(
              controller: _langController,
              decoration: const InputDecoration(labelText: 'Language Code'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save to Firestore'),
                  ),
          ],
        ),
      ),
    );
  }
}
