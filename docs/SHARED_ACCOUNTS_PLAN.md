# Shared Accounts: The Blessed Bible + Blessed Arcade

Goal: one sign-in works in both apps. A user signs in once with Google (Apple later), sees the same name and avatar in both, and deleting the account from either app removes it everywhere.

## Where things stand (2026-10-10)

| | The Blessed Bible | Blessed Arcade (`wakilibaraka/blessed-arcade`) |
| --- | --- | --- |
| Auth | Firebase Auth + Google (Apple code present), project `blessedbibleapp` | **None.** `lib/ui/auth/login_screen.dart` is a placeholder ("no real auth") |
| Profile | Firebase user (name, email, photo) | Local SQLite `PlayerProfile` (displayName, avatarEmoji, companion, XP, coins, streaks) |
| App ids | `com.baraka.bibleapp` (Android + iOS) | `com.wakilibaraka.blessedarcade.blessed_arcade` (Android), `...blessedArcade` (iOS) |
| Firebase | Configured | Not added |

## Approach

1. **One Firebase project for both apps.** Register the arcade's Android and iOS apps in the existing `blessedbibleapp` Firebase project. Firebase Auth users belong to the project, not the app, so the same Google account gets the **same uid** in both apps. No custom auth server is needed.
2. **A shared Dart package, `blessed_account`,** used by both apps as a git dependency. It contains:
   - `AccountService`: sign in with Google/Apple, sign out, reauthenticate, delete account (moved out of the Bible app's `auth_provider.dart`).
   - `accountStateProvider` (Riverpod): signed-out / signed-in user / error.
   - `SharedProfile` model + repository: `users/{uid}` root doc `{displayName, avatar, createdAt, updatedAt}`.
   - Ready-made widgets: sign-in buttons, account sheet (profile, sign out, delete account), delete confirmation.
   - Each app keeps its own theme by passing colours/text styles in; the package has no visual opinions.
3. **Data layout keeps each app's data separate** under the same user:
   ```
   users/{uid}                          shared profile (name, avatar)
   users/{uid}/bookmarks|highlights|notes|plans|...   Bible app (Phase 5B)
   users/{uid}/arcade/{doc}             arcade progress (XP, coins, streaks, vault)
   ```
4. **Account deletion from either app** deletes the shared profile, both apps' subcollections and the auth user. The package owns the list of subcollections, so neither app can miss the other's data.
5. **Firestore rules** gain the root profile doc (owner-only, validated fields) and `users/{uid}/arcade/**`, with emulator tests in the Bible app's `firestore-tests/`. One rules file serves both apps because it's one project.

## Steps

| # | Work | Where |
| --- | --- | --- |
| 1 | Finish Phase 5B sign-in hardening in the Bible app (Google on a real device). | Bible app |
| 2 | Firebase console: add the arcade's Android app (package + SHA-1/SHA-256) and iOS app; run `flutterfire configure` in the arcade repo. | You |
| 3 | Extract `blessed_account` into its own repo (or a `packages/` folder in one of the apps), with tests. | New package |
| 4 | Bible app switches to the package; behaviour unchanged. | Bible app |
| 5 | Arcade: add Firebase, replace the placeholder login with the package's sign-in (keep "Play as guest"); on first sign-in, offer to upload the local `PlayerProfile`. | Arcade |
| 6 | Rules + deletion for `arcade/**` and the profile doc; privacy policy names both apps (or the arcade gets its own policy page). | Both |
| 7 | Device test: sign in on Bible app → open arcade → already signed in? No: each app has its own sign-in session on the device, but the same account. Verify the same uid/profile, then delete from one app and confirm both lose access. | You + me |

Note on step 7: Android and iOS don't share login sessions between separate apps without extra platform work (Android account manager or a shared iOS keychain group). The standard result is "same account, sign in once per app", which takes one tap with Google. Silent cross-app sign-in can come later if wanted (iOS: shared keychain access group; both apps need the same Apple team).

## Decisions for you

- Package location: separate repo `blessed-account` (cleanest), or `packages/blessed_account` inside one app?
- Should arcade progress (XP, coins, streaks) sync to the cloud, or stay device-only with just the shared profile synced?
- One privacy policy covering both apps, or one each?
