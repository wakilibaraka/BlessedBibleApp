# Phase 5B: Google Sign-In, Sign-Out and Data Sync

Goal: on Android, a user can sign in with Google, have their personal data follow them to another device, sign out safely, and delete their account, all without losing data offline. Apple sign-in waits for Phase 5 (Apple developer account).

## 1. Current state (audit, 2026-10-10)

| Area | Finding | Impact |
| --- | --- | --- |
| Google sign-in | `AuthActions.signInWithGoogle` (google_sign_in 7 + Firebase Auth) exists; never verified on a device. `GoogleSignIn.instance.initialize()` gets no `serverClientId`. | May fail with no idToken if the OAuth web client isn't in `google-services.json`. |
| Apple sign-in | Button shows on Android too. | Fails on Android (needs a web service ID). Hide off Apple platforms. |
| Sign-out | Signs out of Firebase and Google; local data stays. | No flush of pending cloud writes; nothing for a shared device. |
| Sync | `CloudSyncService` is **not called anywhere** (its only caller was a dead widget). | Nothing syncs today except the custom-plan backup. |
| Sync design | Union merge per doc: bookmarks by timestamp, highlights with **no timestamps**, streak by max. Notes, folders and plan progress not covered. | Deletions would come back from the cloud; folders and notes would be lost across devices. |
| Custom plans | Backed up to `users/{uid}/plans/{id}`; **never restored**. | Backup is write-only. |
| Account deletion | Deletes `plans`, `sync_data`, root doc, auth user, local data. | Must be extended to any new collections. |

## 2. What syncs

| Data | Local key(s) | Synced |
| --- | --- | --- |
| Bookmarks + folders | `bookmarks_v2` | Yes |
| Highlights | `highlights` | Yes |
| Notes | notes provider key | Yes |
| Custom plans + active plans + plan progress | `custom_plans`, `custom_plan_ids`, `active_plan_ids`, `reading_plan_state` | Yes |
| Reading streak / reading days | `app_usage_dates`, `streak_count`, `last_read_date` | Yes (union of reading days, streak recomputed) |
| Settings, theme, fonts, reminders, search history, reading position | various | No: device-specific, stays local |

## 3. Design

**Cloud layout: one document per item**, so edits on two devices don't overwrite each other.

```
users/{uid}/bookmarks/{id}    { ref, folderId, createdAt, updatedAt, deleted }
users/{uid}/folders/{id}      { name, order, updatedAt, deleted }
users/{uid}/highlights/{id}   { ref, color, updatedAt, deleted }
users/{uid}/notes/{id}        { text, refs, createdAt, updatedAt, deleted }
users/{uid}/plans/{id}        { plan, active, progress, updatedAt, deleted }
users/{uid}/meta/readingDays  { days: [yyyy-mm-dd, ...], updatedAt }
```

- **Conflict rule:** last writer wins per item, by `updatedAt`. A delete is a write with `deleted: true` (a tombstone), so deletions propagate instead of coming back. Tombstones are pruned after 90 days.
- **Local change log:** a small ledger beside the existing storage records `updatedAt` and tombstones for every local add/edit/delete. Existing storage formats stay unchanged, and the notifiers call the ledger on each mutation.
- **Merge engine:** a pure-Dart function `merge(local, remote) -> (toApplyLocally, toUpload)`. It is unit-testable with no Firebase.
- **Incremental pulls:** query `updatedAt > lastPulledAt` per collection, then write in batches of up to 500.
- **Offline:** Firestore offline persistence queues writes. The UI never awaits server acknowledgement (the bug fixed in Phase 4).

**Triggers:** after sign-in; on app start and resume when signed in (debounced); 10 s after a local change; and a manual **Sync now**.

**Sign-in flows**
- First sign-in on a device with local data and an empty account: upload local data.
- Account already has data: merge (union with last-writer-wins). Nothing is deleted.
- A *different* account than last time, with local data from the previous one: ask **Merge into this account** or **Start fresh on this device** (clear local, then pull).

**Sign-out flow:** flush pending writes (`waitForPendingWrites`, 10 s timeout), then ask **Keep data on this device** (default) or **Remove it** → sign out of Firebase and Google.

**Account sheet UI:** signed-in email and avatar, "Last synced 2 min ago", Sync now, and an error line with a retry option.

## 4. Work breakdown (one PR each)

| Step | Work | Done when |
| --- | --- | --- |
| **5B.0 Console setup (you)** | Firebase → Authentication → enable Google. Add SHA-1 and SHA-256 for the debug keystore, the upload keystore and the Play App Signing key. Re-download `google-services.json` / run `flutterfire configure`. Google Cloud OAuth consent screen: app name, support email, privacy policy URL, published to production. | `google-services.json` has an `oauth_client` of type 3 (web). |
| **5B.1 Sign-in hardening** ✅ in code (via `blessed_account`); device check pending 5B.0 | Hide Apple sign-in off iOS/macOS. Pass `serverClientId` if needed. Map sign-in errors to clear messages (no network, cancelled, misconfigured, with the error code). Log non-PII failures to Crashlytics. | Sign-in and sign-out work on a real Android device in debug and release. |
| **5B.2 Ledger + merge engine** | `lib/sync/`: change ledger, item models, `merge()`. Hook ledger writes into the bookmarks, highlights, notes and plan notifiers. | Unit tests: LWW, tombstones, clock skew, idempotent re-merge, empty local/remote, conflicting folder moves. |
| **5B.3 Cloud repository + rules** | `SyncRepository` (Firestore read/write, incremental pull, batching). Rules for the new collections with shape and size checks. Retire `cloud_sync_service.dart` and `sync_data`. | Repository tests with `fake_cloud_firestore`; rules tests on the emulator in CI. |
| **5B.4 Wiring + UI** | `SyncController` provider: triggers, debouncing, status. Account sheet: last synced, Sync now, errors. Sign-in merge prompt, sign-out keep/remove prompt, account-switch prompt. Custom plans restored from the cloud. | Widget tests for the prompts and status line. |
| **5B.5 Deletion + policy** | Account deletion removes all new collections (shared list of subcollections). Privacy policy, Play Data safety and Credits updated: notes, highlights, bookmarks and plans are stored in the account when signed in. | Rules and deletion tests pass; `tool/build_privacy_policy.py --check` passes. |
| **5B.6 Device verification (you + me)** | Run the script below on two Android devices (or a device and an emulator) with one Google account. | Every row passes; results recorded in this file. |

## 5. Device test script (5B.6)

| # | Steps | Expected |
| --- | --- | --- |
| 1 | Fresh install A, add 3 bookmarks (1 in a folder), 2 highlights, 1 note, start a custom plan; sign in with Google | All data still on A; account sheet shows "Last synced just now" |
| 2 | Fresh install B, sign in with the same account | Everything from 1 appears on B, folder included |
| 3 | On B delete a highlight, edit the note; on A pull to sync / reopen | Highlight gone on A, note edited on A |
| 4 | A offline: add a bookmark, delete the note. Go online | Changes reach B within a minute of the next sync |
| 5 | Edit the same note on A and B while both offline, then go online | The later edit wins on both devices; nothing duplicated |
| 6 | Mark plan days complete on A | Same progress on B |
| 7 | Sign out on B, choose Keep | Data stays on B; no further sync |
| 8 | Sign out on A, choose Remove | A is empty; B and the cloud are unaffected |
| 9 | Sign in on A with a *different* Google account | Prompt: Merge / Start fresh; each option behaves as described |
| 10 | Delete account on B | Cloud data gone (verify in console); A shows signed out on next start |
| 11 | Airplane mode for the whole app, signed in | All features work; no errors or spinners stuck |
| 12 | Release build (signed with upload key) | Google sign-in works (catches a missing release SHA-1) |

## 6. Risks

- **Missing SHA fingerprints** are the most common cause of `DEVELOPER_ERROR` / code 10. Play App Signing has its own key; add that SHA too.
- **Clock skew** between devices affects LWW. Use the device clock but never accept `updatedAt` more than 1 day in the future; tie-break by device ID.
- **Firestore cost:** per-item docs mean more writes on first sync (one per item). Fine at this app's data sizes (hundreds to low thousands of items per user).
