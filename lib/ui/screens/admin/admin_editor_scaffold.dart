import 'package:flutter/material.dart';

class AdminEditorScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool isSaving;
  final bool isValid;
  final VoidCallback onSave;

  const AdminEditorScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.isSaving,
    required this.isValid,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: isValid ? onSave : null,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Stack(
        children: [
          body,
          if (isSaving)
            Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
