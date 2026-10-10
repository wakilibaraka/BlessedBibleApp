import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/user_data_provider.dart';
import '../state/streak_provider.dart';
import '../data/models/bookmark_model.dart';
import '../utils/log.dart';

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(ref);
});

class CloudSyncService {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CloudSyncService(this.ref);

  String? get uid => _auth.currentUser?.uid;

  /// Syncs local data to Firestore and pulls remote data back (Last Write Wins).
  Future<void> syncData() async {
    final currentUid = uid;
    if (currentUid == null) return;

    try {
      await Future.wait([
        _syncBookmarks(currentUid),
        _syncHighlights(currentUid),
        _syncStreaks(currentUid),
      ]);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'last_cloud_sync_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      logDebug('Cloud sync failed: $e');
      rethrow;
    }
  }

  Future<void> _syncBookmarks(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final localJson = prefs.getString('bookmarks_v2');
    final Map<String, dynamic> localData = {};
    BookmarkData? currentLocalBookmarkData;

    if (localJson != null && localJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(localJson);
        currentLocalBookmarkData =
            BookmarkData.fromJson(decoded as Map<String, dynamic>);
        for (final entry in currentLocalBookmarkData.nodes.entries) {
          final bm = entry.value;
          localData[entry.key] = bm.createdAt.millisecondsSinceEpoch;
        }
      } catch (_) {}
    }

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('sync_data')
        .doc('bookmarks');
    final docSnap = await docRef.get();

    Map<String, dynamic> remoteData = {};
    if (docSnap.exists) {
      remoteData = docSnap.data() as Map<String, dynamic>;
    }

    bool hasRemoteNewer = false;
    final Map<String, dynamic> merged = {...remoteData};

    for (final entry in localData.entries) {
      final key = entry.key;
      final localTs = entry.value as int;
      if (!merged.containsKey(key) || (merged[key] as int) < localTs) {
        merged[key] = localTs;
      }
    }

    for (final entry in remoteData.entries) {
      final key = entry.key;
      final remoteTs = entry.value as int;
      if (!localData.containsKey(key) || (localData[key] as int) < remoteTs) {
        hasRemoteNewer = true;
      }
    }

    await docRef.set(merged, SetOptions(merge: true));

    if (hasRemoteNewer) {
      final Map<String, BookmarkNode> newNodes = {};
      for (final e in merged.entries) {
        newNodes[e.key] = BookmarkNode(
          reference: e.key,
          createdAt: DateTime.fromMillisecondsSinceEpoch(e.value as int),
          folderId: currentLocalBookmarkData
              ?.nodes[e.key]?.folderId, // preserve local folder if exists
        );
      }

      final newData = BookmarkData(
        folders: currentLocalBookmarkData?.folders ?? [],
        nodes: newNodes,
      );
      await prefs.setString('bookmarks_v2', jsonEncode(newData.toJson()));
      ref.invalidate(bookmarkDataProvider);
    }
  }

  Future<void> _syncHighlights(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    // highlights are stored as a map of reference -> colorIndex directly in SharedPreferences
    final localJson = prefs.getString('highlights'); // The key is 'highlights'
    Map<String, int> localData = {};
    if (localJson != null && localJson.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap =
            jsonDecode(localJson) as Map<String, dynamic>;
        localData = jsonMap.map((key, value) => MapEntry(key, value as int));
      } catch (_) {}
    }

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('sync_data')
        .doc('highlights');
    final docSnap = await docRef.get();

    // Remote data schema: reference -> { "colorIndex": X, "timestamp": Y }
    Map<String, dynamic> remoteData = {};
    if (docSnap.exists) {
      remoteData = docSnap.data() as Map<String, dynamic>;
    }

    bool hasRemoteNewer = false;
    final Map<String, dynamic> merged = {...remoteData};

    final now = DateTime.now().millisecondsSinceEpoch;

    for (final entry in localData.entries) {
      final key = entry.key;
      final localColor = entry.value;

      if (!merged.containsKey(key)) {
        // We don't have a local timestamp, so if it's not in remote, we assign now.
        merged[key] = {
          'colorIndex': localColor,
          'timestamp': now,
        };
      } else {
        // If it exists in remote, check if the color matches.
        final remoteVal = merged[key] as Map<String, dynamic>;
        if (remoteVal['colorIndex'] != localColor) {
          // Local color differs from remote. Since we have no local timestamp, we assume local was modified more recently if it differs.
          merged[key] = {
            'colorIndex': localColor,
            'timestamp': now,
          };
        }
      }
    }

    // Now check if remote has anything missing locally, or if remote was updated
    for (final entry in remoteData.entries) {
      final key = entry.key;
      final remoteVal = entry.value as Map<String, dynamic>;
      final remoteColor = remoteVal['colorIndex'] as int;

      if (!localData.containsKey(key) || localData[key] != remoteColor) {
        // Remote has something we don't have, OR remote color is different and we just merged.
        // Wait, if local color differs, we just overwrote it in `merged`.
        // So we only care if remote HAS it but local DOES NOT HAVE it,
        // OR local HAS it but we are yielding to remote (which we aren't, because no local ts).
        // Actually, if we didn't have it locally, we should pull it.
        if (!localData.containsKey(key)) {
          hasRemoteNewer = true;
        }
      }
    }

    await docRef.set(merged, SetOptions(merge: true));

    if (hasRemoteNewer || localData.length != merged.length) {
      final Map<String, int> newHighlights = {};
      for (final e in merged.entries) {
        final val = e.value as Map<String, dynamic>;
        newHighlights[e.key] = val['colorIndex'] as int;
      }
      await prefs.setString('highlights', jsonEncode(newHighlights));
      ref.invalidate(highlightsProvider);
    }
  }

  Future<void> _syncStreaks(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final localCount = prefs.getInt('streak_count') ?? 0;
    final localLastRead = prefs.getInt('streak_last_read') ?? 0;

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('sync_data')
        .doc('streak');
    final docSnap = await docRef.get();

    int remoteCount = 0;
    int remoteLastRead = 0;
    if (docSnap.exists) {
      final data = docSnap.data() as Map<String, dynamic>;
      remoteCount = (data['count'] as int?) ?? 0;
      remoteLastRead = (data['last_read'] as int?) ?? 0;
    }

    if (localLastRead > remoteLastRead) {
      await docRef.set({
        'count': localCount,
        'last_read': localLastRead,
      }, SetOptions(merge: true));
    } else if (remoteLastRead > localLastRead) {
      await prefs.setInt('streak_count', remoteCount);
      await prefs.setInt('streak_last_read', remoteLastRead);
      ref.invalidate(streakProvider);
    } else {
      if (remoteCount > localCount) {
        await prefs.setInt('streak_count', remoteCount);
        ref.invalidate(streakProvider);
      } else if (localCount > remoteCount) {
        await docRef.set({'count': localCount}, SetOptions(merge: true));
      }
    }
  }

  Future<void> resetLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookmarks_v2');
    await prefs.remove('highlights');
    await prefs.remove('streak_count');
    await prefs.remove('streak_last_read');
    await prefs.remove('last_cloud_sync_timestamp');

    ref.invalidate(bookmarkDataProvider);
    ref.invalidate(highlightsProvider);
    ref.invalidate(streakProvider);
  }
}
