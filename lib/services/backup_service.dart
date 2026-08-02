import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/local_storage/preferences_service.dart';
import '../state/user_data_provider.dart';
import '../state/notes_provider.dart';
import '../state/reading_plan_provider.dart';
import '../state/search_provider.dart';
import '../state/search_settings_provider.dart';
import '../state/nav_settings_provider.dart';
import '../state/bible_nav_settings_provider.dart';
import '../state/read_settings_provider.dart';
import '../state/study_layout_provider.dart';
import '../state/theme_provider.dart';
import '../state/typography_provider.dart';
import '../state/surface_style_provider.dart';

class BackupService {
  static const int currentVersion = 1;

  static Future<void> exportData(BuildContext context, WidgetRef ref) async {
    try {
      final prefs = ref.read(preferencesProvider).prefs;
      final keys = prefs.getKeys();
      final Map<String, dynamic> data = {};

      for (final key in keys) {
        data[key] = prefs.get(key);
      }

      final backup = {
        'version': currentVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      };

      final jsonString = jsonEncode(backup);
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/blessed_bible_backup.json');
      await file.writeAsString(jsonString);

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'The Blessed Bible Backup',
          sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  static Future<void> importData(BuildContext context, WidgetRef ref, String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map || !decoded.containsKey('version') || !decoded.containsKey('data')) {
        throw const FormatException('Invalid backup file format');
      }

      final data = decoded['data'];
      if (data is! Map) {
        throw const FormatException('Invalid backup data structure');
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Restore'),
          content: const Text('This will overwrite all existing notes, highlights, bookmarks, and settings. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Restore', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final prefs = ref.read(preferencesProvider).prefs;
      await prefs.clear();

      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is List) {
          await prefs.setStringList(key, List<String>.from(value));
        }
      }

      // Invalidate providers to force reload from new SharedPreferences data
      ref.invalidate(bookmarksProvider);
      ref.invalidate(highlightsProvider);
      ref.invalidate(notesProvider);
      // Invalidate all active plan family instances, then the ids list
      final activePlanIds = ref.read(activePlanIdsProvider);
      for (final planId in activePlanIds) {
        ref.invalidate(readingPlanProvider(planId));
      }
      ref.invalidate(activePlanIdsProvider);
      ref.invalidate(currentActivePlanIdProvider);
      ref.invalidate(searchStateProvider);
      ref.invalidate(searchSettingsProvider);
      ref.invalidate(navSettingsProvider);
      ref.invalidate(bibleNavSettingsProvider);
      ref.invalidate(readSettingsProvider);
      ref.invalidate(studyLayoutProvider);
      ref.invalidate(themeProvider);
      ref.invalidate(typographyProvider);
      ref.invalidate(surfaceStyleProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: Invalid or corrupted backup ($e)')),
        );
      }
    }
  }
}
