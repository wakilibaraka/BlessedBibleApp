import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reading_plan.dart';
import '../utils/log.dart';

/// Best-effort cloud copy of a custom plan under `users/{uid}/plans/{id}`.
///
/// The local copy in preferences is the source of truth, so callers save
/// locally first and never await this: Firestore write futures only complete
/// once the server acknowledges, which would hang while offline.
Future<void> backupCustomPlan(String uid, ReadingPlan plan) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('plans')
        .doc(plan.id)
        .set(firestorePlanJson(plan));
  } catch (e) {
    logDebug('Custom plan cloud backup failed: $e');
  }
}

/// [ReadingPlan.toJson] with `tracks` reshaped for Firestore, which rejects
/// arrays nested directly inside arrays: `[[range, ...], ...]` becomes
/// `[{'ranges': [range, ...]}, ...]`.
Map<String, dynamic> firestorePlanJson(ReadingPlan plan) {
  final json = plan.toJson();
  final tracks = json['tracks'];
  if (tracks is List) {
    json['tracks'] = [
      for (final track in tracks) {'ranges': track},
    ];
  }
  return json;
}
