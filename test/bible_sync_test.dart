import 'package:blessed_account/blessed_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blessed_account/testing.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_blessed_bible/data/local_storage/preferences_service.dart';
import 'package:the_blessed_bible/data/models/home_data.dart';
import 'package:the_blessed_bible/state/notes_provider.dart';
import 'package:the_blessed_bible/state/user_data_provider.dart';
import 'package:the_blessed_bible/sync/bible_sync.dart';
import 'package:the_blessed_bible/ui/widgets/account_menu.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore db;

  /// One "device": its own preferences, sharing [db].
  Future<ProviderContainer> device({
    AccountUser? user = const AccountUser(uid: 'u1'),
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sp = await SharedPreferences.getInstance();
    final c = ProviderContainer(overrides: [
      preferencesProvider.overrideWithValue(PreferencesService(sp)),
      authGatewayProvider.overrideWithValue(FakeAuthGateway(user: user)),
      accountFirestoreProvider.overrideWithValue(db),
    ]);
    addTearDown(c.dispose);
    c.listen(syncControllerProvider, (_, __) {});
    await pumpEventQueue();
    return c;
  }

  Future<void> settle(ProviderContainer c) async {
    await c.read(syncControllerProvider.notifier).syncNow();
    await pumpEventQueue();
  }

  CollectionReference<Map<String, dynamic>> col(String name) =>
      db.collection('users').doc('u1').collection(name);

  setUp(() => db = FakeFirebaseFirestore());

  test('signing in uploads local data, and a second device gets it', () async {
    final a = await device();
    a.read(bookmarkDataProvider.notifier).toggle('JHN_3:16');
    a.read(highlightsProvider.notifier).toggleHighlight('PSA_23:1', 2);
    a.read(notesProvider.notifier).add(PersonalNote(
        'n1', 'Hope', 'Romans 5', '2026-10-10',
        reference: 'ROM_5:5'));
    await settle(a);

    expect((await col('bookmarks').get()).docs.single.data()['id'], 'JHN_3:16');
    expect((await col('folders').get()).docs, hasLength(4));
    expect(a.read(syncControllerProvider).phase, SyncPhase.idle);
    expect(a.read(syncControllerProvider).lastSyncedAt, isNotNull);

    final b = await device();
    await settle(b);
    expect(b.read(bookmarksProvider), {'JHN_3:16'});
    expect(b.read(highlightsProvider), {'PSA_23:1': 2});
    expect(b.read(notesProvider).single.title, 'Hope');
    expect(b.read(notesProvider).single.reference, 'ROM_5:5');
  });

  test('a deletion on one device reaches the other', () async {
    final a = await device();
    a.read(highlightsProvider.notifier).toggleHighlight('PSA_23:1', 2);
    await settle(a);
    final b = await device();
    await settle(b);
    expect(b.read(highlightsProvider), {'PSA_23:1': 2});

    b.read(highlightsProvider.notifier).removeHighlight('PSA_23:1');
    await pumpEventQueue();
    await settle(b);
    await settle(a);
    expect(a.read(highlightsProvider), isEmpty);
  });

  test('a different account asks first; start fresh clears the device',
      () async {
    final c = await device(
      user: const AccountUser(uid: 'u1'),
      prefs: {
        SyncController.lastUidKey: 'someone-else',
        'highlights': '{"PSA_23:1":2}',
      },
    );
    expect(c.read(syncControllerProvider).phase, SyncPhase.needsAccountChoice);
    expect((await col('highlights').get()).docs, isEmpty,
        reason: 'nothing is uploaded before the user chooses');

    await c
        .read(syncControllerProvider.notifier)
        .resolveAccountChoice(startFresh: true);
    await pumpEventQueue();
    expect(c.read(highlightsProvider), isEmpty);
    expect((await col('highlights').get()).docs, isEmpty);
    expect(c.read(syncControllerProvider).phase, SyncPhase.idle);
  });

  test('merge keeps the device data and uploads it', () async {
    final c = await device(prefs: {
      SyncController.lastUidKey: 'someone-else',
      'highlights': '{"PSA_23:1":2}',
    });
    await c
        .read(syncControllerProvider.notifier)
        .resolveAccountChoice(startFresh: false);
    await pumpEventQueue();
    expect(c.read(highlightsProvider), {'PSA_23:1': 2});
    expect((await col('highlights').get()).docs, hasLength(1));
  });

  test('signed out: nothing syncs', () async {
    final c = await device(user: null);
    c.read(highlightsProvider.notifier).toggleHighlight('PSA_23:1', 2);
    await settle(c);
    expect(c.read(syncControllerProvider).phase, SyncPhase.signedOut);
    expect((await col('highlights').get()).docs, isEmpty);
  });

  test('plans, progress, active plans and reading days reach a new device',
      () async {
    final a = await device(prefs: {
      'custom_plan_ids': ['c1'],
      'custom_plan_c1': '{"id":"c1","title":"Romans"}',
      'reading_plan_state_c1': '{"completedReadings":[1,2]}',
      'active_plan_ids': ['c1'],
      'app_usage_dates': ['2026-10-09', '2026-10-10'],
    });
    await settle(a);

    final b = await device(prefs: {
      'app_usage_dates': ['2026-10-08'],
    });
    await settle(b);
    final p = b.read(preferencesProvider);
    expect(p.getCustomPlanIds(), ['c1']);
    expect(p.getCustomPlan('c1')?['title'], 'Romans');
    expect(p.getReadingPlanState('c1')?['completedReadings'], [1, 2]);
    expect(p.getActivePlanIds(), ['c1']);
    expect(p.getAppUsageDates(), ['2026-10-08', '2026-10-09', '2026-10-10'],
        reason: 'reading days from both devices add up');
  });

  test('start fresh also clears plans and reading days', () async {
    final c = await device(prefs: {
      SyncController.lastUidKey: 'someone-else',
      'custom_plan_ids': ['c1'],
      'custom_plan_c1': '{"id":"c1"}',
      'active_plan_ids': ['c1'],
      'app_usage_dates': ['2026-10-10'],
    });
    await c
        .read(syncControllerProvider.notifier)
        .resolveAccountChoice(startFresh: true);
    await pumpEventQueue();
    final p = c.read(preferencesProvider);
    expect(p.getCustomPlanIds(), isEmpty);
    expect(p.getActivePlanIds(), isEmpty);
    expect(p.getAppUsageDates(), isEmpty);
  });

  test('synced label', () {
    final now = DateTime(2026, 10, 10, 12);
    expect(syncedLabel(null, now), 'Not synced yet');
    expect(syncedLabel(now, now), 'Synced just now');
    expect(syncedLabel(now.subtract(const Duration(minutes: 5)), now),
        'Synced 5 min ago');
    expect(syncedLabel(now.subtract(const Duration(hours: 3)), now),
        'Synced 3 h ago');
    expect(syncedLabel(DateTime(2026, 10, 1), now), 'Synced 1/10/2026');
  });
}
