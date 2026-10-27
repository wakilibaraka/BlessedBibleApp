import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/services/device_reset.dart';

void main() {
  test('deleting cloud data removes only this app\'s collections', () async {
    final db = FakeFirebaseFirestore();
    final user = db.collection('users').doc('u1');
    await user.set({'displayName': 'Ruth'});
    for (final c in ['bookmarks', 'highlights', 'notes', 'plans']) {
      await user.collection(c).doc('a').set({'x': 1});
      await user.collection(c).doc('b').set({'x': 2});
    }
    await user.collection('arcade').doc('progress').set({'level': 3});
    await db.collection('users').doc('u2').collection('notes').doc('n').set({});

    await deleteBibleCloudData(db, 'u1', pageSize: 1);

    for (final c in ['bookmarks', 'highlights', 'notes', 'plans']) {
      expect((await user.collection(c).get()).docs, isEmpty, reason: c);
    }
    // The shared profile, Blessed Arcade and other users stay.
    expect((await user.get()).exists, isTrue);
    expect((await user.collection('arcade').get()).docs, hasLength(1));
    expect(
        (await db.collection('users').doc('u2').collection('notes').get()).docs,
        hasLength(1));
  });
}
