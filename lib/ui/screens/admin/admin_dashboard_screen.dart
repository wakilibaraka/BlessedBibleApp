import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'votd_editor_screen.dart';
import 'commentary_import_screen.dart';
import 'commentary_editor_screen.dart';
import 'pericope_import_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('VOTD Editor'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const VotdEditorScreen())),
          ),
          ListTile(
            title: const Text('Commentary Importer'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const CommentaryImportScreen())),
          ),
          ListTile(
            title: const Text('Commentary Editor'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const CommentaryEditorListScreen())),
          ),
          ListTile(
            title: const Text('Pericope Importer'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const PericopeImportScreen())),
          ),
        ],
      ),
    );
  }
}
