// Emulator tests for ../firestore.rules. Run: npm test (from this folder).
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

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

describe('users/{uid}/sync_data (legacy)', () => {
  test('owner can read and delete but no longer write', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'users', ALICE, 'sync_data', 'streak'), { count: 3 }));
    const ref = doc(db(ALICE), 'users', ALICE, 'sync_data', 'streak');
    await assertSucceeds(getDoc(ref));
    await assertFails(setDoc(ref, { count: 4 }));
    await assertSucceeds(deleteDoc(ref));
    await assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'sync_data', 'streak')));
  });
});

describe('per-item sync collections', () => {
  // Shape written by blessed_account's FirestoreSyncRepository.
  const item = (id, data, overrides = {}) => ({
    id, data, updatedAt: 1760000000000, deleted: false, device: 'device-1',
    syncedAt: serverTimestamp(), ...overrides,
  });
  const ref = (uid, col, id) => doc(db(uid), 'users', ALICE, col, id);

  test('owner can write valid items in each collection', async () => {
    await assertSucceeds(setDoc(ref(ALICE, 'bookmarks', 'JHN_3:16'),
      item('JHN_3:16', { createdAt: 1, folderId: null })));
    await assertSucceeds(setDoc(ref(ALICE, 'bookmarks', 'ROM_8:28'),
      item('ROM_8:28', { createdAt: 1, folderId: 'folder_study' })));
    await assertSucceeds(setDoc(ref(ALICE, 'folders', 'folder_study'),
      item('folder_study', { name: 'Study' })));
    await assertSucceeds(setDoc(ref(ALICE, 'highlights', 'PSA_23:1'),
      item('PSA_23:1', { color: 2 })));
    await assertSucceeds(setDoc(ref(ALICE, 'notes', 'n1'),
      item('n1', { title: 'Hope', content: 'Text', date: '2026-10-10', reference: 'ROM_5:5' })));
    await assertSucceeds(getDoc(ref(ALICE, 'notes', 'n1')));
    await assertSucceeds(deleteDoc(ref(ALICE, 'notes', 'n1')));
  });

  test('tombstones have null data', async () => {
    await assertSucceeds(setDoc(ref(ALICE, 'highlights', 'PSA_23:1'),
      item('PSA_23:1', null, { deleted: true })));
    await assertFails(setDoc(ref(ALICE, 'highlights', 'PSA_23:1'),
      item('PSA_23:1', { color: 1 }, { deleted: true })));
    await assertFails(setDoc(ref(ALICE, 'highlights', 'PSA_23:1'),
      item('PSA_23:1', null)));
  });

  test('rejects bad shapes', async () => {
    await assertFails(setDoc(ref(ALICE, 'highlights', 'x'), item('x', { color: 99 })));
    await assertFails(setDoc(ref(ALICE, 'highlights', 'x'), item('x', { color: 1, extra: 1 })));
    await assertFails(setDoc(ref(ALICE, 'folders', 'f'), item('f', { name: 'x'.repeat(201) })));
    await assertFails(setDoc(ref(ALICE, 'notes', 'n'),
      item('n', { title: 't', content: 'x'.repeat(100001), date: 'd' })));
    await assertFails(setDoc(ref(ALICE, 'bookmarks', 'b'), item('b', { createdAt: 'now' })));
    await assertFails(setDoc(ref(ALICE, 'bookmarks', 'b'),
      item('b', { createdAt: 1 }, { syncedAt: 5 })));
    await assertFails(setDoc(ref(ALICE, 'bookmarks', 'b'),
      { ...item('b', { createdAt: 1 }), role: 'admin' }));
  });

  test('plans, progress, active plans and reading days', async () => {
    await assertSucceeds(setDoc(ref(ALICE, 'custom_plans', 'p1'), item('p1', { json: '{"id":"p1"}' })));
    await assertSucceeds(setDoc(ref(ALICE, 'plan_progress', 'p1'), item('p1', { json: '{}' })));
    await assertSucceeds(setDoc(ref(ALICE, 'meta', 'active_plans'), item('active_plans', { ids: ['p1'] })));
    await assertSucceeds(setDoc(ref(ALICE, 'reading_days', '2026-10-10'), item('2026-10-10', {})));
    await assertFails(setDoc(ref(ALICE, 'custom_plans', 'p1'), item('p1', { json: 5 })));
    await assertFails(setDoc(ref(ALICE, 'meta', 'other'), item('other', { ids: [] })));
    await assertFails(setDoc(ref(ALICE, 'meta', 'active_plans'), item('active_plans', { ids: Array(21).fill('x') })));
    await assertFails(setDoc(ref(ALICE, 'reading_days', 'yesterday'), item('yesterday', {})));
    await assertFails(setDoc(ref(ALICE, 'reading_days', '2026-10-10'), item('2026-10-10', { x: 1 })));
  });

  test('other users, signed-out clients and unknown collections are denied', async () => {
    await assertFails(setDoc(ref(BOB, 'notes', 'n'), item('n', { title: 't', content: 'c', date: 'd' })));
    await assertFails(getDoc(ref(BOB, 'notes', 'n')));
    await assertFails(getDoc(ref(null, 'notes', 'n')));
    await assertFails(setDoc(ref(ALICE, 'journal', 'j'), item('j', { text: 'x' })));
  });
});

describe('users/{uid} root and unknown paths', () => {
  // Shape written by blessed_account's SharedProfileRepository.
  const profile = (overrides = {}) => ({
    displayName: 'Ruth', avatar: null, createdAt: 1000, updatedAt: 1000, ...overrides,
  });

  test('owner can create, read, update and delete their profile', async () => {
    const ref = doc(db(ALICE), 'users', ALICE);
    await assertSucceeds(setDoc(ref, profile()));
    await assertSucceeds(getDoc(ref));
    await assertSucceeds(updateDoc(ref, { displayName: 'Naomi', avatar: '🕊️', updatedAt: 2000 }));
    await assertSucceeds(deleteDoc(ref));
  });

  test('profile rejects unknown fields, bad types and createdAt changes', async () => {
    const ref = doc(db(ALICE), 'users', ALICE);
    await assertFails(setDoc(ref, { role: 'admin' }));
    await assertFails(setDoc(ref, profile({ role: 'admin' })));
    await assertFails(setDoc(ref, profile({ displayName: '' })));
    await assertFails(setDoc(ref, profile({ displayName: 'x'.repeat(101) })));
    await assertFails(setDoc(ref, profile({ avatar: 42 })));
    await assertFails(setDoc(ref, profile({ updatedAt: 'now' })));
    await assertSucceeds(setDoc(ref, profile()));
    await assertFails(updateDoc(ref, { createdAt: 5 }));
  });

  test('other users and signed-out clients cannot touch a profile', async () => {
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'users', ALICE), profile()));
    await assertFails(getDoc(doc(db(BOB), 'users', ALICE)));
    await assertFails(setDoc(doc(db(BOB), 'users', ALICE), profile()));
    await assertFails(updateDoc(doc(db(BOB), 'users', ALICE), { displayName: 'Bob' }));
    await assertFails(getDoc(doc(db(null), 'users', ALICE)));
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
