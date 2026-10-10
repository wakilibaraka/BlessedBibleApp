import 'dart:async';

import 'package:blessed_account/blessed_account.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/local_storage/preferences_service.dart';
import '../data/models/bookmark_model.dart';
import '../data/models/home_data.dart';
import '../services/firebase_setup.dart';
import '../state/notes_provider.dart';
import '../state/user_data_provider.dart';

// ---------------------------------------------------------------------------
// Collections: the app's data as id → fields, for blessed_account's
// SyncEngine. Firestore layout and rules: users/{uid}/{name}/{id}.
// ---------------------------------------------------------------------------

class BookmarksSync implements SyncCollection {
  final Ref ref;
  BookmarksSync(this.ref);
  @override
  String get name => 'bookmarks';

  @override
  Map<String, Map<String, Object?>> read() => {
        for (final n in ref.read(bookmarkDataProvider).nodes.values)
          n.reference: {
            'createdAt': n.createdAt.millisecondsSinceEpoch,
            'folderId': n.folderId,
          },
      };

  @override
  Future<void> write(Map<String, Map<String, Object?>> items) async {
    ref.read(bookmarkDataProvider.notifier).applySyncedNodes({
      for (final MapEntry(key: id, value: d) in items.entries)
        id: BookmarkNode(
          reference: id,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
              (d['createdAt'] as num?)?.toInt() ?? 0),
          folderId: d['folderId'] as String?,
        ),
    });
  }
}

class FoldersSync implements SyncCollection {
  final Ref ref;
  FoldersSync(this.ref);
  @override
  String get name => 'folders';

  @override
  Map<String, Map<String, Object?>> read() => {
        for (final f in ref.read(bookmarkDataProvider).folders)
          f.id: {'name': f.name},
      };

  @override
  Future<void> write(Map<String, Map<String, Object?>> items) async {
    ref.read(bookmarkDataProvider.notifier).applySyncedFolders({
      for (final MapEntry(key: id, value: d) in items.entries)
        id: d['name'] as String? ?? '',
    });
  }
}

class HighlightsSync implements SyncCollection {
  final Ref ref;
  HighlightsSync(this.ref);
  @override
  String get name => 'highlights';

  @override
  Map<String, Map<String, Object?>> read() => {
        for (final MapEntry(key: id, value: color)
            in ref.read(highlightsProvider).entries)
          id: {'color': color},
      };

  @override
  Future<void> write(Map<String, Map<String, Object?>> items) async {
    ref.read(highlightsProvider.notifier).applySynced({
      for (final MapEntry(key: id, value: d) in items.entries)
        id: (d['color'] as num?)?.toInt() ?? 0,
    });
  }
}

class NotesSync implements SyncCollection {
  final Ref ref;
  NotesSync(this.ref);
  @override
  String get name => 'notes';

  @override
  Map<String, Map<String, Object?>> read() => {
        for (final n in ref.read(notesProvider))
          n.id: Map<String, Object?>.from(n.toJson())..remove('id'),
      };

  @override
  Future<void> write(Map<String, Map<String, Object?>> items) async {
    ref.read(notesProvider.notifier).applySynced({
      for (final MapEntry(key: id, value: d) in items.entries)
        id: PersonalNote.fromJson({...d, 'id': id}),
    });
  }
}

class PrefsSyncStore implements SyncStore {
  final SharedPreferences prefs;
  PrefsSyncStore(this.prefs);
  @override
  String? read(String key) => prefs.getString(key);
  @override
  Future<void> write(String key, String value) =>
      prefs.setString(key, value).then((_) {});
}

// ---------------------------------------------------------------------------
// Controller: when to sync, and what the account menu shows.
// ---------------------------------------------------------------------------

enum SyncPhase {
  signedOut,
  idle,
  syncing,
  error,

  /// Signed in to a different account than this device's data came from:
  /// waiting for the user to merge or start fresh.
  needsAccountChoice,
}

class SyncStatus {
  final SyncPhase phase;
  final DateTime? lastSyncedAt;
  const SyncStatus(this.phase, {this.lastSyncedAt});
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final prefs = ref.watch(preferencesProvider).prefs;
  var deviceId = prefs.getString(SyncController.deviceIdKey);
  if (deviceId == null) {
    deviceId = const Uuid().v4();
    unawaited(prefs.setString(SyncController.deviceIdKey, deviceId));
  }
  return SyncEngine(
      FirestoreSyncRepository(ref.watch(accountFirestoreProvider)),
      PrefsSyncStore(prefs),
      deviceId: deviceId);
});

final syncControllerProvider =
    NotifierProvider<SyncController, SyncStatus>(SyncController.new);

class SyncController extends Notifier<SyncStatus> {
  static const deviceIdKey = 'sync_device_id';
  static const lastUidKey = 'sync_last_uid';
  static const lastSyncedKey = 'sync_last_synced_at';

  /// Local edits are batched: a sync runs this long after the last one.
  static const debounce = Duration(seconds: 10);
  static const timeout = Duration(seconds: 30);

  late List<SyncCollection> _collections;
  String? _uid;
  Timer? _timer;
  bool _applyingRemote = false;
  Future<void>? _running;
  Completer<void>? _userSeen;

  SharedPreferences get _prefs => ref.read(preferencesProvider).prefs;

  @override
  SyncStatus build() {
    _collections = [
      FoldersSync(ref),
      BookmarksSync(ref),
      HighlightsSync(ref),
      NotesSync(ref),
    ];
    final lifecycle = AppLifecycleListener(onResume: () {
      if (state.phase == SyncPhase.idle || state.phase == SyncPhase.error) {
        unawaited(syncNow());
      }
    });
    ref.onDispose(() {
      _timer?.cancel();
      lifecycle.dispose();
    });
    ref.listen(bookmarkDataProvider, (_, __) => _onLocalChange());
    ref.listen(highlightsProvider, (_, __) => _onLocalChange());
    ref.listen(notesProvider, (_, __) => _onLocalChange());
    ref.listen(accountUserProvider, (_, next) {
      if (!next.isLoading) _onUser(next.value);
    });
    // A user already signed in at start: handled once build() has returned
    // (state can't be set during build).
    Future.microtask(() {
      if (!ref.mounted) return;
      final user = ref.read(accountUserProvider);
      if (!user.isLoading) _onUser(user.value);
    });
    final last = _prefs.getInt(lastSyncedKey);
    return SyncStatus(SyncPhase.signedOut,
        lastSyncedAt:
            last == null ? null : DateTime.fromMillisecondsSinceEpoch(last));
  }

  bool get _hasLocalData =>
      _collections.any((c) => c is! FoldersSync && c.read().isNotEmpty);

  void _onUser(AccountUser? user) {
    _timer?.cancel();
    if (user == null) {
      _uid = null;
      state = SyncStatus(SyncPhase.signedOut, lastSyncedAt: state.lastSyncedAt);
      return;
    }
    if (user.uid == _uid) return;
    _uid = user.uid;
    _userSeen?.complete();
    _userSeen = null;
    final lastUid = _prefs.getString(lastUidKey);
    if (lastUid != null && lastUid != user.uid && _hasLocalData) {
      state = SyncStatus(SyncPhase.needsAccountChoice,
          lastSyncedAt: state.lastSyncedAt);
      return;
    }
    unawaited(_prefs.setString(lastUidKey, user.uid));
    unawaited(syncNow());
  }

  /// Waits (briefly) until a just-completed sign-in has reached this
  /// controller, then returns the resulting phase; check for
  /// [SyncPhase.needsAccountChoice].
  Future<SyncPhase> afterSignIn() async {
    if (_uid == null) {
      final seen = _userSeen ??= Completer<void>();
      await seen.future.timeout(const Duration(seconds: 5), onTimeout: () {});
    }
    return state.phase;
  }

  /// After signing in to a different account: merge this device's data
  /// into it, or clear this device first ([startFresh]) and download.
  Future<void> resolveAccountChoice({required bool startFresh}) async {
    final uid = _uid;
    if (uid == null || state.phase != SyncPhase.needsAccountChoice) return;
    if (startFresh) clearLocalData();
    await _prefs.setString(lastUidKey, uid);
    state = SyncStatus(SyncPhase.idle, lastSyncedAt: state.lastSyncedAt);
    await syncNow();
  }

  /// Empties bookmarks, folders, highlights and notes on this device. Call
  /// only while signed out or awaiting the account choice, so the
  /// deletions aren't uploaded.
  void clearLocalData() {
    ref.read(bookmarkDataProvider.notifier).clear();
    ref.read(highlightsProvider.notifier).applySynced({});
    ref.read(notesProvider.notifier).applySynced({});
  }

  /// Called before signing out: uploads pending changes (best effort).
  /// If [forget], the next account to sign in won't be asked to merge.
  Future<void> prepareSignOut({required bool forget}) async {
    _timer?.cancel();
    try {
      await syncNow().timeout(const Duration(seconds: 10));
      await ref
          .read(accountFirestoreProvider)
          .waitForPendingWrites()
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Offline: Firestore keeps the queued writes and sends them later.
    }
    if (forget) await _prefs.remove(lastUidKey);
  }

  void _onLocalChange() {
    final uid = _uid;
    if (uid == null || state.phase == SyncPhase.needsAccountChoice) return;
    // Timestamp the change now (the next sync would otherwise date it),
    // upload a little later (batched). Changes made while a sync is
    // applying remote data are dated by the follow-up sync.
    if (!_applyingRemote) {
      final engine = ref.read(syncEngineProvider);
      for (final c in _collections) {
        unawaited(engine.recordLocalChanges(uid, c));
      }
    }
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(syncNow()));
  }

  /// Syncs now (also the "Sync now" button). Concurrent calls share one run.
  Future<void> syncNow() => _running ??= _sync().whenComplete(() {
        _running = null;
      });

  Future<void> _sync() async {
    final uid = _uid;
    if (uid == null || state.phase == SyncPhase.needsAccountChoice) return;
    _timer?.cancel();
    state = SyncStatus(SyncPhase.syncing, lastSyncedAt: state.lastSyncedAt);
    try {
      _applyingRemote = true;
      await ref
          .read(syncEngineProvider)
          .sync(uid, _collections)
          .timeout(timeout);
      if (_uid != uid) return; // Signed out meanwhile.
      final now = DateTime.now();
      await _prefs.setInt(lastSyncedKey, now.millisecondsSinceEpoch);
      state = SyncStatus(SyncPhase.idle, lastSyncedAt: now);
    } catch (e) {
      reportNonFatal('Sync failed', code: e.runtimeType.toString());
      if (_uid == uid) {
        state = SyncStatus(SyncPhase.error, lastSyncedAt: state.lastSyncedAt);
      }
    } finally {
      _applyingRemote = false;
    }
  }
}
