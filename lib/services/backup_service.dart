import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/local_storage/preferences_service.dart';
import '../services/bible_database_service.dart';
import '../services/translation_pack_store.dart';
import '../state/user_data_provider.dart';
import '../state/notes_provider.dart';
import '../state/reading_plan_provider.dart';
import '../state/search_provider.dart';
import '../state/search_settings_provider.dart';

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

      // Installed downloadable packs (ids only — pack files themselves
      // are re-downloaded after restore, not backed up).
      List<String> packIds = [];
      try {
        final installed = await bibleDbService.getTranslations();
        packIds = [
          for (final t in installed)
            if (!TranslationPackStore.isCoreId(t.translationId))
              t.translationId,
        ];
      } catch (_) {}

      final backup = {
        'version': currentVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'packs': packIds,
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
          sharePositionOrigin:
              box != null ? box.localToGlobal(Offset.zero) & box.size : null,
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

  static Future<void> importData(
      BuildContext context, WidgetRef ref, String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map ||
          !decoded.containsKey('version') ||
          !decoded.containsKey('data')) {
        throw const FormatException('Invalid backup file format');
      }
      final backupVersion = decoded['version'] as int? ?? 0;
      if (backupVersion > currentVersion) {
        throw FormatException(
            'Backup is from a newer app version (v$backupVersion). Update the app first.');
      }

      final data = decoded['data'];
      if (data is! Map) {
        throw const FormatException('Invalid backup data structure');
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Restore'),
          content: const Text(
              'This will overwrite all existing notes, highlights, bookmarks, and settings. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              child:
                  const Text('Restore', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final prefs = ref.read(preferencesProvider).prefs;
      await prefs.clear();

      // Restore per key so one corrupt value can't abort the whole
      // restore; skipped keys are reported, not fatal.
      var skippedKeys = 0;
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;
        try {
          if (value is String) {
            await prefs.setString(key, value);
          } else if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is List) {
            await prefs
                .setStringList(key, [for (final e in value) e.toString()]);
          } else if (value == null) {
            await prefs.remove(key);
          } else {
            skippedKeys++;
          }
        } catch (_) {
          skippedKeys++;
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
      // navSettingsProvider has been removed
      ref.invalidate(bibleNavSettingsProvider);
      ref.invalidate(readSettingsProvider);
      ref.invalidate(studyLayoutProvider);
      ref.invalidate(themeProvider);
      ref.invalidate(typographyProvider);
      ref.invalidate(earthHeavenStyleProvider);
      ref.invalidate(surfaceStyleProvider);

      // Downloaded packs are not in the backup: tell the user which
      // ones to re-download from the translation picker.
      Set<String> installedIds = {};
      try {
        final installed = await bibleDbService.getTranslations();
        installedIds = {for (final t in installed) t.translationId};
      } catch (_) {}
      final backedPacks = [
        for (final e in (decoded['packs'] as List? ?? const [])) e.toString()
      ].where((id) => !installedIds.contains(id)).toList();

      if (context.mounted) {
        final details = [
          if (skippedKeys > 0) '$skippedKeys value(s) skipped',
          if (backedPacks.isNotEmpty)
            're-download ${backedPacks.length} translation(s): ${backedPacks.join(', ')}',
        ].join('. ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(details.isEmpty
                  ? 'Backup restored successfully'
                  : 'Backup restored ($details)')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Restore failed: Invalid or corrupted backup ($e)')),
        );
      }
    }
  }
}
