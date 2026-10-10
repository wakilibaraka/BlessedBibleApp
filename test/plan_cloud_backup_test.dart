import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/models/reading_plan.dart';
import 'package:the_blessed_bible/services/plan_cloud_backup.dart';

/// Firestore rejects a list that directly contains a list.
bool _hasNestedList(Object? value) {
  if (value is Map) return value.values.any(_hasNestedList);
  if (value is List) {
    return value.any((e) => e is List || _hasNestedList(e));
  }
  return false;
}

void main() {
  final range = PlanRange(
      book: 'Matthew',
      startChapter: 1,
      startVerse: 1,
      endChapter: 28,
      endVerse: 20);

  ReadingPlan plan({List<List<PlanRange>>? tracks}) => ReadingPlan(
        id: 'p1',
        title: 'Gospels',
        days: 30,
        cadence: 7,
        schedule: const [],
        tracks: tracks,
      );

  test('toJson nests track arrays, which Firestore cannot store', () {
    expect(
        _hasNestedList(plan(tracks: [
          [range]
        ]).toJson()),
        isTrue);
  });

  test('firestorePlanJson wraps each track in a map', () {
    final json = firestorePlanJson(plan(tracks: [
      [range],
      [range, range],
    ]));
    expect(_hasNestedList(json), isFalse);
    final tracks = json['tracks'] as List;
    expect(tracks, hasLength(2));
    expect((tracks[1] as Map)['ranges'], hasLength(2));
    expect(json['id'], 'p1');
  });

  test('firestorePlanJson leaves plans without tracks unchanged', () {
    final json = firestorePlanJson(plan());
    expect(json.containsKey('tracks'), isFalse);
    expect(json, plan().toJson());
  });
}
