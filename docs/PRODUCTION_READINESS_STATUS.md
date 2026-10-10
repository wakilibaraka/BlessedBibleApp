# Production Readiness: Status and Plan

Audit of `main` @ `9ad360f` against *Blessed Bible App: Production Readiness Checklist and Clean Sweep* (Oct 9, 2026). Audited 2026-10-10.

Legend: ✅ done · 🟡 partial · ❌ not done · 🔍 needs manual or device verification (can't be judged from code)

**How this was checked:** static reading of the repo only. The Flutter SDK was not available, so `flutter analyze` and the 171 tests in `test/` were **not run**. The clone is shallow (last 50 commits), so the secrets-in-history check covers those commits only.

---

## Summary

| Section | Status | Key gaps |
| --- | --- | --- |
| 1. Known blockers | 🟡 3 of 8 | iOS not configured, licensing unverified, privacy policy not hosted, root not clean |
| 2. Code clean sweep | 🟡 | ~22 orphan files, 2 unused fonts, 1 unused dependency, no strict analyzer, no crash reporting, no FVM pin |
| 3. Repo hygiene | ❌ mostly | stray root files, `tool/` + `tools/`, 3 loose markdown docs, desktop/web folders, wrong README clone URL, no LICENSE, no CI |
| 4. Feature inventory | 🔍 | needs a device test pass. Notes are not cloud-synced. |
| 5. Onboarding | 🟡 | single screen, not the multi-step flow the checklist describes |
| 6–9. Gestures, settings, themes, consistency | 🔍 | manual matrices. Code signals: 212 `Color(0x`, 636 `Colors.`, 121 literal `fontSize:` |
| 10. Bible essentials | 🟡 | most features present. Credits/sources screen and doctrinal-perspective statement missing. |
| 11. Data, sync, privacy | 🟡 | owner-only rules ✅, deletion ✅. No App Check, no rules tests, sync design not documented. |
| 12. Accessibility and l10n | ❌ | no ARB/intl setup, only 31 semantics/tooltip sites |
| 13. Performance | 🔍 | needs profiling. 14 MB fonts + 22 MB devotional assets. |
| 14. Licensing | ❌ | no licenses register. `ron_btf` "Public Domain" claim is doubtful. No OSS licenses screen. |
| 15. Testing | 🟡 | 24 test files / 171 cases. No goldens, integration, rules, or migration tests. No CI. |
| 16. Release engineering | 🟡 | Android release signing ✅. No flavors, CI/CD, obfuscation, crash reporter, or iOS setup. |
| 17. Store compliance | ❌ | blocked by sections 1, 11, 14 |

---

## 1. Known blockers

| Item | Status | Evidence / what's left |
| --- | --- | --- |
| P0 iOS build signs and passes TestFlight | ❌ | `ios/` exists (bundle `com.baraka.bibleapp`, iOS 15.0, WidgetExtension), but there is no `Runner.entitlements` (Sign in with Apple capability), no `PrivacyInfo.xcprivacy`, and no `GoogleService-Info.plist` workflow. README still says "iOS planned". |
| P0 Sign in with Apple | 🟡 | Code done: `lib/state/auth_provider.dart:56` plus buttons in `account_menu.dart` and `account_sync_card.dart`. **Missing:** the iOS entitlement and Apple/Firebase console configuration, and an on-device test. |
| P0 In-app account deletion removes cloud data | ✅ | `auth_provider.dart:127–183`: reauthenticates, deletes `users/{uid}/plans/*`, `users/{uid}/sync_data/*`, `users/{uid}`, the auth user, and local data. Covers every path the app writes (`cloud_sync_service.dart`, `custom_plan_builder_v2_screen.dart:408`). Still needs a device test. |
| P0 Content licensing verified | ❌ | See section 14. |
| P0 Firestore rules owner-only | ✅ | `firestore.rules`: `users/{userId}/**` requires `auth.uid == userId`. CMS collections are world-readable and admin-write by a hardcoded UID. Missing: field validation and size limits, emulator tests. |
| P0 No secrets in git | 🟡 | No keystores, `key.properties`, `google-services.json`, `firebase_options.dart`, or `AIza…` keys in the visible history, and `.gitignore` covers them. **Re-run on a full clone** (`git log --all` with gitleaks or trufflehog) because this clone was shallow. |
| P0 Privacy policy at a public URL | 🟡 | In-app `privacy_policy_screen.dart` and `docs/privacy_policy.{md,html}` exist, but there's no public URL in the code. Policy says Crashlytics is used, but Crashlytics is **not** a dependency. Fix the text or add Crashlytics. |
| P1 Clean repo root | ❌ | See section 3. |

## 2. Code stability and clean sweep

### 2.1 Static analysis
- ❌ `analysis_options.yaml` is the default `flutter_lints` with no extra rules and no `strict-casts`, `strict-inference`, or `strict-raw-types`.
- 🔍 `flutter analyze`, `dart fix`, and `dart format` weren't run here. CI doesn't enforce them because there's no CI.
- ✅ No `TODO`/`FIXME`/`HACK`/`XXX` and no bare `print(` in `lib/`.
- 🟡 21 `debugPrint(` calls: route them through a logger that's silent in release. 5 `// ignore` comments: justify or remove each.

### 2.2 Dead code
- ❌ **Files never imported from `lib/` or `test/`** (delete or wire up):
  - `ui/sheets/`: `custom_plan_action_sheet`, `curated_plan_action_sheet`, `quick_note_sheet`
  - `ui/screens/`: `bookmarks_screen`, `dictionary_screen`, `commentary_library_screen`, `highlights_screen`
  - `ui/widgets/`: `search_field`, `note_card`, `jiggle_animator`, `your_space_hero`, `pinch_to_zoom_font_wrapper`, `study_progress_card`, `bible_stories_banner`, `ghost_button`, `account_sync_card`, `account_button`, `primary_button`, `verse_card`
  - `data/curated/rest_day_reflections`, `state/rest_day_provider`, `state/dynamic_reading_plan_provider`
  - Note: `account_sync_card` and `account_button` are dead duplicates of `account_menu` (they also contain the delete flow).
- ❌ Unused fonts: **Bonheur Royale** and **Shadows Into Light** are declared in `pubspec.yaml` but never referenced in `lib/`.
- ❌ Unused dependency: **`flutter_timezone`** (no imports).
- 🔍 Still to run: DCM `check-unused-code`, unused providers, unused assets per file, unreachable routes.
- ❌ `design-previews/study-redesign-v1`: decide to keep, branch, or delete. Legacy Study was retired in `27125fb`.

### 2.3 Duplicates
- 🟡 Account UI exists three times (`account_menu`, `account_sync_card`, `account_button`), so keep only `account_menu`. `primary_button`/`ghost_button` are unused parallel button styles.
- 🔍 Run DB integrity queries (`GROUP BY … HAVING COUNT(*) > 1`) on `bible.db`, the packs, and commentary.
- 🔍 Double-tap guards on bookmark, highlight, and note creation.

### 2.4 Architecture and stability
- 🟡 Layering: direct Firestore/SQL access in widgets in `concordance_screen.dart`, `custom_plan_builder_v2_screen.dart`, and `account_menu.dart`. Move it into services or providers.
- 🟡 Global handlers are installed (`main.dart:27–60`) with a branded `ErrorWidget`, but they write `crash_log.txt` to a **relative path**, which fails silently on mobile. There's no crash reporter.
- ❌ Empty `if (kStartupTrace) {}` blocks in `main.dart` (dead leftovers).
- 🟡 Bundled Bible DB opened `readOnly` in some paths (`bible_database_service.dart:332,398`) but `readOnly: false` at `:617`. Confirm user data lives outside the content DB. No visible versioned `onUpgrade` migrations.
- ❌ No Flutter version pin (`.fvmrc`). `.metadata` shows stable `84fc5cb`.
- ✅ `pubspec.lock` committed. 🔍 `flutter pub outdated` review.
- 🔍 Also review: ~118 `setState` calls against ~130 `mounted` checks, ~27 `!` operators, `BuildContext` used across async gaps. Analyzer lints will catch most of these once they're tightened.

### 2.5 Stability testing
- 🔍 All manual (cold/warm start, kill mid-write, airplane mode, rotation, soak, release mode).

## 3. Repository hygiene

| Item | Status |
| --- | --- |
| Root `test_db.dart` (empty), `test_script.dart` (empty), `test_devotional.dart` (scratch) | ❌ delete |
| `tool/` and `tools/` merge | ❌ both exist (`tools/` has Hebrews JSON, Doré fetchers, commentary studio) |
| `evaluate_headings.jq` into `tool/` | ❌ |
| `OVERNIGHT_CHANGELOG.md`, `RELEASE_NOTES_prerelease-1.md`, `PROJECT_RULES.md` into `CHANGELOG.md` + `CONTRIBUTING.md` | ❌ |
| `linux/`, `macos/`, `windows/`, `web/` removed or documented | ❌ |
| `.gitignore` covers secrets and build output | ✅ (also has a long list of agent scratch filenames that can be trimmed) |
| Large binaries in LFS | ✅ `.gitattributes` covers `bible.db`, `assets/packs/*.db`, `content_packs/*.db` |
| README clone URL | ❌ points at `Baraka254/BlessedBibleApp`. Repo is `wakilibaraka/BlessedBibleApp`. |
| README feature list accurate | 🔍 after the sweep. Platform line still says "iOS planned". |
| LICENSE file | ❌ none. README says "All rights reserved". Add a `LICENSE` stating proprietary. |
| Branch protection, CI checks, PR template | ❌ no `.github/` directory |
| Tagged releases | 🔍 README links Releases. Version is `1.0.2+9`. |

## 4. Feature inventory
Needs a device pass on both platforms. Notes from the code:
- Cloud sync covers **bookmarks, highlights, streak, and custom plans only**. **Notes are not synced**, but the README implies backup of all personal data. Either add notes to sync or narrow the claim.
- Backup is also available as a JSON share export (`backup_service.dart`).
- Present beyond the README: dictionary, concordance, Strong's (`kjv_strongs`), cross-references, share-as-image, home widget, notifications, Bible Stories devotional. Record ship/defer/cut decisions for the store listing.

## 5. Onboarding
- 🟡 `onboarding_screen.dart` is a single `ConsumerWidget` with feature rows, not a paged flow. Missing: language/translation, theme/font, reminders, and sign-in steps; progress indicator; skip per page; "Replay tour" in Settings.
- 🔍 Decide on one app name: "Bible" on device vs "The Blessed Bible" in the README and privacy policy.

## 6–9. Gestures, settings, themes, inconsistency
Manual matrices. Code-level starters:
- Gesture set was intentionally reduced in `cd2e6fa` (pinch-to-zoom and long-press word lookup removed). The leftover `pinch_to_zoom_font_wrapper.dart` is dead.
- **Hard-coded styling:** 212 `Color(0x…)`, 636 `Colors.*`, 121 literal `fontSize:` in `lib/`. This is the bulk of the section 8.3 and 9 work.
- Settings has an About section with `PackageInfo` ✅. No credits, licenses, or terms entries.

## 10. Bible essentials
- ✅ KJV, pericope headings, commentary, plans, bookmarks/highlights/notes, share text and image, cross-references.
- ❌ Credits and sources screen. Only the devotional has a `DevotionalAttribution` footer.
- ❌ Doctrinal-perspective statement for the historicist commentary.

## 11. Data, sync, privacy
- ✅ Local-first: SQLite and SharedPreferences, account optional.
- ✅ Owner-only rules. ✅ Account deletion.
- ❌ Firebase App Check. ❌ Rules emulator tests. ❌ Written sync and conflict design.
- 🟡 Tokens: Firebase Auth manages its own persistence. Nothing custom is in SharedPreferences (confirm).
- ❌ Privacy policy doesn't match the code (Crashlytics). ❌ Data-type inventory for Play Data Safety and Apple privacy labels.

## 12. Accessibility and localization
- ❌ No `flutter_localizations`, `intl`, ARB files, or `l10n.yaml`. All UI strings are literals.
- ❌ Only 31 `Semantics`/`semanticLabel`/`tooltip` sites across 168 files.
- 🔍 Text scaling, contrast, screen readers, reduced motion and transparency.

## 13. Performance
- 🔍 All require profiling. Size watch: `assets/fonts` 14 MB (including two unused families), `assets/devotional` 22 MB, `assets/commentary` 9.6 MB, `bible.db` 50.5 MB. Consider downloadable packs for the devotional art.

## 14. Licensing
- ❌ No licenses register (text, edition, source URL, license, date verified).
- Pack manifest claims: Swahili and Tagalog ULB (CC BY-SA 4.0: needs attribution and share-alike notice), Diodati 1885, LSG 1910 (PD). **`ron_btf` is marked "Public Domain"; the Romanian *Biblia Traducerea Fidelă* is a modern translation, so verify.**
- `content_packs/` also contains `deu_l12`, `nld_`, `por_blj`, `spa_r09`, `web`, and `kjv_strongs`. Their licenses aren't in the `packs` manifest entries. Verify each one, especially `por_blj`.
- ❌ EGW and Uriah Smith edition provenance not documented.
- ❌ Font license notices. `tools/fetch_devotional_fonts.py` notes OFL, but nothing is shown in the app.
- ❌ No `LicensePage` / open-source licenses screen.
- ❌ Doré plates: public domain, but record the source.

## 15. Testing
- 🟡 24 widget and unit test files, 171 cases (search, plans, notes, gestures, settings toggles, share card).
- ❌ Golden, integration, Firestore rules, migration, and streak/time-zone tests. ❌ Coverage reporting. ❌ CI.

## 16. Release engineering
- ✅ Android release signing from `key.properties` (`android/app/build.gradle.kts`). `targetSdk = 35`: confirm against the current Play requirement.
- ❌ Dev/prod flavors. ❌ `--obfuscate --split-debug-info` + symbol upload. ❌ Crash reporting. ❌ CI/CD. ❌ iOS signing, capabilities, privacy manifest. 🔍 R8/shrinking verification, deep links.

## 17. Store compliance
Blocked on sections 1, 11, and 14. Nothing store-side is verifiable from the repo.

---

## Plan

Ordered so each phase unblocks the next. Each phase is roughly one PR.

### Phase 1: Repo clean sweep (low risk, 1 PR)
1. Delete `test_db.dart`, `test_script.dart`, `test_devotional.dart`.
2. Merge `tools/` into `tool/`. Move `evaluate_headings.jq` there and add `tool/README.md`.
3. Fold `OVERNIGHT_CHANGELOG.md` and `RELEASE_NOTES_prerelease-1.md` into `CHANGELOG.md`. Rename `PROJECT_RULES.md` to `CONTRIBUTING.md`.
4. Fix the README clone URL. Add a proprietary `LICENSE`.
5. Decide on `linux/`, `macos/`, `windows/`, `web/`, and `design-previews/` (delete or document as unsupported).
6. Trim the `.gitignore` scratch-file list.

### Phase 2: Dead code and dependencies (1 PR)
1. Delete the ~22 orphan files listed in 2.2, after a final check with DCM or `flutter analyze`.
2. Remove the Bonheur Royale and Shadows Into Light fonts and the `flutter_timezone` dependency.
3. Remove the empty `kStartupTrace` blocks. Replace `debugPrint` with a release-silent logger.
4. Run `dart fix --apply` and `dart format .`.

### Phase 3: Quality gates (1 PR)
1. Tighten `analysis_options.yaml` (strict modes plus extra lints) and fix the findings.
2. Add `.fvmrc`.
3. Add `.github/workflows/ci.yml` (analyze, format check, test, Android build) and a PR template. Turn on branch protection for `main`.

### Phase 4: P0 compliance (2–3 PRs plus console work)
1. **Crash reporting:** add Crashlytics (or remove it from the policy). Replace the `crash_log.txt` writes. Add obfuscation and symbol upload.
2. **Privacy:** host `docs/privacy_policy.html` (GitHub Pages) and link the URL in Settings and both stores. Reconcile its claims with the code (Crashlytics, notes sync).
3. **Licensing:** create `docs/LICENSES_REGISTER.md` for every text, font, and image. Resolve `ron_btf` and `por_blj`. Add a Credits & Sources screen, `showLicensePage`, and a doctrinal-perspective note.
4. **Firebase:** add App Check, add field and size validation to the rules, and add emulator tests for the rules.
5. **Secrets:** run gitleaks on a full clone.

### Phase 5: iOS (needs a Mac and an Apple Developer account)
1. Add the Sign in with Apple capability (`Runner.entitlements`), `PrivacyInfo.xcprivacy`, and `GoogleService-Info.plist` via the Firebase CLI.
2. Configure the Apple provider in Firebase. Test sign-in and deletion on device.
3. Archive, then TestFlight. Update the README platform line.

### Phase 6: UX sweep (multiple PRs)
1. Onboarding: build the paged flow (language/translation, theme/font, reminders, optional sign-in), with skip and back on every page and a "Replay tour" entry.
2. Theme tokens: replace hard-coded `Color(0x…)`/`Colors.*`/`fontSize:` with theme tokens, screen by screen. Start with the reader, then settings.
3. Accessibility: semantic labels on icon buttons and custom gestures, then a largest-text-size pass.
4. Notes cloud sync, or narrow the backup claim.
5. Localization scaffolding (`flutter_localizations` + ARB) if any non-English UI is planned.

### Phase 7: Verification and release
Run the manual matrices in sections 4–9 on the device set, add golden and integration tests, set up flavors and CD to the Play internal track and TestFlight, and complete store listings. Then use the section 18 launch gate.
