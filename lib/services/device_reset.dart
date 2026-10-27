import 'package:blessed_account/blessed_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_storage/preferences_service.dart';
import '../state/journal_provider.dart';
import '../state/notes_provider.dart';
import '../state/reading_plan_provider.dart';
import '../state/streak_provider.dart';
import '../state/translation_provider.dart';
import '../state/user_data_provider.dart'
    show bookmarkDataProvider, highlightsProvider;
import 'bible_database_service.dart';
import 'translation_pack_store.dart';

/// Erases this device's study data (bookmarks, plans, progress, downloaded
/// translations, streaks) while keeping settings, theme, the profile name
/// and bundled content. Never touches the account: call it signed out, or
/// inside `SyncController.whilePaused`.
Future<void> wipeDeviceData(ProviderContainer container) async {
  const packCleanupTimeout = Duration(seconds: 5);
  final prefsSvc = container.read(preferencesProvider);

  // Point the reader at the bundled KJV before removing downloaded packs,
  // so an open chapter never shows a translation that no longer exists.
  await container
      .read(activeTranslationProvider.notifier)
      .setTranslation('kjv');
  await container
      .read(secondaryTranslationProvider.notifier)
      .setTranslation(null);

  await prefsSvc.clearAllUserData();

  final sp = prefsSvc.prefs;
  await sp.remove('active_plan_ids');
  final customIds = sp.getStringList('custom_plan_ids') ?? [];
  for (final id in customIds) {
    await sp.remove('custom_plan_$id');
  }
  await sp.remove('custom_plan_ids');
  for (final key in sp
      .getKeys()
      .where((k) => k.startsWith('reading_plan_state_'))
      .toList()) {
    await sp.remove(key);
  }
  await sp.remove('deleted_packs');
  await sp.remove('study_layout');

  // Downloaded translations (bundled packs self-restore on next launch).
  // Bounded, so a stuck database can't hold the reset dialog open forever.
  try {
    await () async {
      final installed = await bibleDbService.getTranslations();
      for (final t in installed) {
        if (!TranslationPackStore.isCoreId(t.translationId)) {
          try {
            await bibleDbService.deleteTranslationPack(t.translationId);
          } catch (_) {}
        }
      }
    }()
        .timeout(packCleanupTimeout);
  } catch (_) {}

  container
    ..invalidate(bookmarkDataProvider)
    ..invalidate(highlightsProvider)
    ..invalidate(notesProvider)
    ..invalidate(journalProvider)
    ..invalidate(streakProvider)
    ..invalidate(activePlanIdsProvider)
    ..invalidate(availableTranslationsProvider)
    ..invalidate(readingPlanProvider);
}

/// Deletes this app's synced data from the account (`users/{uid}/...`):
/// bookmarks, highlights, notes, plans and progress. Leaves the account,
/// its shared profile and Blessed Arcade's data alone.
Future<void> deleteBibleCloudData(FirebaseFirestore db, String uid,
    {int pageSize = 300}) async {
  final userDoc = db.collection(CloudLayout.users).doc(uid);
  for (final name in CloudLayout.bibleCollections) {
    final collection = userDoc.collection(name);
    while (true) {
      final page = await collection.limit(pageSize).get();
      if (page.docs.isEmpty) break;
      final batch = db.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
