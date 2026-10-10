// Emulator tests for ../firestore.rules. Run: npm test (from this folder).
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc } from 'firebase/firestore';

const ADMIN = 'dx78nhHTHMNnCLlryAWIwGqqAh23';
const ALICE = 'alice';
const BOB = 'bob';

let env;
const db = (uid) =>
  uid ? env.authenticatedContext(uid).firestore() : env.unauthenticatedContext().firestore();

// Shape produced by firestorePlanJson() in lib/services/plan_cloud_backup.dart.
const plan = (id, overrides = {}) => ({
  id,
  title: 'Gospels in 30 days',
  days: 30,
  cadence: 7,
  wasClamped: false,
  clampReason: null,
  schedule: [{ dayNumber: 1, portions: [], totalWords: 0 }],
  tracks: [{ ranges: [{ book: 'Matthew', startChapter: 1, startVerse: 1, endChapter: 28, endVerse: 20 }] }],
  ...overrides,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-blessed-bible',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});
after(async () => env.cleanup());
beforeEach(async () => env.clearFirestore());

describe('users/{uid}/plans', () => {
  test('owner can create, read and delete a valid plan', async () => {
    const ref = doc(db(ALICE), 'users', ALICE, 'plans', 'p1');
    await assertSucceeds(setDoc(ref, plan('p1')));
    await assertSucceeds(getDoc(ref));
    await assertSucceeds(deleteDoc(ref));
  });

  test('other users and signed-out clients are denied', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'users', ALICE, 'plans', 'p1'), plan('p1')));
    await assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'plans', 'p1')));
    await assertFails(setDoc(doc(db(BOB), 'users', ALICE, 'plans', 'p2'), plan('p2')));
    await assertFails(deleteDoc(doc(db(BOB), 'users', ALICE, 'plans', 'p1')));
    await assertFails(getDoc(doc(db(null), 'users', ALICE, 'plans', 'p1')));
  });

  test('id must match the document id', async () => {
    await assertFails(setDoc(doc(db(ALICE), 'users', ALICE, 'plans', 'p1'), plan('other')));
  });

  test('rejects unknown fields, bad types and out-of-range values', async () => {
    const ref = doc(db(ALICE), 'users', ALICE, 'plans', 'p1');
    await assertFails(setDoc(ref, plan('p1', { isAdmin: true })));
    await assertFails(setDoc(ref, plan('p1', { title: 'x'.repeat(201) })));
    await assertFails(setDoc(ref, plan('p1', { days: 0 })));
    await assertFails(setDoc(ref, plan('p1', { days: 731 })));
    await assertFails(setDoc(ref, plan('p1', { days: '30' })));
    await assertFails(setDoc(ref, plan('p1', { schedule: 'nope' })));
  });
});

describe('users/{uid}/sync_data', () => {
  test('owner can write streak with int fields', async () => {
    const ref = doc(db(ALICE), 'users', ALICE, 'sync_data', 'streak');
    await assertSucceeds(setDoc(ref, { count: 3, last_read: 1760000000000 }));
    await assertSucceeds(setDoc(ref, { count: 4 }, { merge: true }));
    await assertSucceeds(getDoc(ref));
  });

  test('streak rejects bad types, negatives and extra fields', async () => {
    const ref = doc(db(ALICE), 'users', ALICE, 'sync_data', 'streak');
    await assertFails(setDoc(ref, { count: -1 }));
    await assertFails(setDoc(ref, { count: '3' }));
    await assertFails(setDoc(ref, { count: 1, extra: true }));
  });

  test('owner can write bookmarks and highlights maps', async () => {
    await assertSucceeds(setDoc(doc(db(ALICE), 'users', ALICE, 'sync_data', 'bookmarks'),
      { 'John 3:16': 1760000000000 }));
    await assertSucceeds(setDoc(doc(db(ALICE), 'users', ALICE, 'sync_data', 'highlights'),
      { 'John 3:16': { colorIndex: 2, ts: 1760000000000 } }));
  });

  test('unknown sync docs and other users are denied', async () => {
    await assertFails(setDoc(doc(db(ALICE), 'users', ALICE, 'sync_data', 'notes'), { a: 1 }));
    await assertFails(setDoc(doc(db(BOB), 'users', ALICE, 'sync_data', 'streak'), { count: 1 }));
    await assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'sync_data', 'bookmarks')));
  });
});

describe('users/{uid} root and unknown paths', () => {
  test('owner can read and delete the root doc but not write it', async () => {
    const ref = doc(db(ALICE), 'users', ALICE);
    await assertSucceeds(getDoc(ref));
    await assertSucceeds(deleteDoc(ref));
    await assertFails(setDoc(ref, { role: 'admin' }));
  });

  test('unknown subcollections are denied even for the owner', async () => {
    await assertFails(setDoc(doc(db(ALICE), 'users', ALICE, 'anything', 'x'), { a: 1 }));
  });
});

describe('CMS collections', () => {
  for (const col of ['VOTD', 'devotionals', 'readingPlans', 'commentary', 'pericopes']) {
    test(`${col}: anyone reads, only the admin writes`, async () => {
      await assertSucceeds(getDoc(doc(db(null), col, 'd1')));
      await assertFails(setDoc(doc(db(ALICE), col, 'd1'), { a: 1 }));
      await assertSucceeds(setDoc(doc(db(ADMIN), col, 'd1'), { a: 1 }));
    });
  }

  test('unknown top-level collections are denied', async () => {
    await assertFails(getDoc(doc(db(ALICE), 'secrets', 'x')));
    await assertFails(setDoc(doc(db(ADMIN), 'secrets', 'x'), { a: 1 }));
  });
});
