# Changelog

All notable changes to The Blessed Bible. Newest first.

## [Unreleased]

### Repository
- Consolidated `OVERNIGHT_CHANGELOG.md` and `RELEASE_NOTES_prerelease-1.md` into this file; `PROJECT_RULES.md` is now `CONTRIBUTING.md`.
- Merged `tools/` and `scripts/` into `tool/`; moved `evaluate_headings.jq` there.
- Removed unsupported platform folders (linux, macos, windows, web) and the `design-previews/` mockups. Android and iOS are the only targets.
- Added a proprietary `LICENSE`.

### Accounts
- Sign-in now uses the shared `blessed_account` package, so the same Google (or Apple) account works in Blessed Arcade. Signing in creates a small shared profile (display name, optional avatar).
- "Sign in with Apple" is shown only on iPhone and iPad, where it works.
- Failed sign-ins say why (no connection, app not set up for this sign-in method, email already used with another method, account disabled) instead of a generic error; the reason is reported to Crashlytics without personal data.
- Deleting the account also removes its Blessed Arcade cloud data.
- **Sync:** while signed in, bookmarks, folders, highlights and notes sync between devices (per item; the newer change wins; deletions sync too). The account menu shows when it last synced and has **Sync now**. Signing out asks whether to keep the data on the device. Signing in to a different account asks whether to merge this device's data or start fresh.
- Custom reading plans, plan progress, active plans and reading days (streak) sync too; reading days from all devices add up.
- Deleting the account now also clears notes and journal entries from the device.

### Fixed
- Signed-in users can create custom reading plans again (the cloud copy used nested arrays, which Firestore rejects, and failed before the local save). Plans now save locally first and back up in the background.

### Added
- Crash reporting via Firebase Crashlytics, with a **Send crash reports** switch in Settings.
- Firebase App Check.
- **Credits & sources** screen (Settings) with translation, commentary and data credits, a note on the commentary's perspective, and an open-source licenses page including font licenses.
- Rewritten privacy policy, viewable in-app and online; web page for account deletion.

### Changed
- Firestore rules only allow the paths the app uses and validate document shape and size.
- Developer: strict analyzer modes, CI (format, analyze, test, Android build, rules tests), Flutter pinned to 3.44.9 in `.fvmrc`.

## 1.0.2+9

See git history for changes since prerelease-1.

## Overnight UI/UX pass (2026-07-24)

**Date**: July 24, 2026
**Scope**: Autonomous UI/UX optimization and bug fixes

### Diagnostics & Baseline
- Ran `flutter analyze` and `flutter pub get`. The codebase was checked and dependencies were confirmed to be resolving correctly.

### Targeted UX/UI Fixes

#### 1. Navigation Modal Performance (Critical)
- **Files Modified**: `lib/ui/screens/read_screen.dart`
- **Fix**: Removed the expensive `BackdropFilter` (via `TexturedGlassContainer`) from every individual book/chapter/verse grid tile in `_buildGridTile`. Replaced it with a high-performance static frosted `Container` (`theme.colorScheme.surface.withValues(alpha: 0.8)`). This completely eliminates the severe frame drops caused by rendering 66+ blur layers concurrently while scrolling. 

#### 2. Navigation Flow Logic (Friction)
- **Files Modified**: `lib/ui/screens/read_screen.dart`
- **Fix**: Updated Riverpod state logic to reduce unnecessary taps.
  - When a Book is selected (`_onBookSelected`), the selector now automatically advances to the Chapter selection mode.
  - When a Chapter is selected (`_onChapterSelected`), it defaults to Verse 1 and instantly auto-closes the modal, streamlining the UX flow immediately to the text.

#### 3. Header Collision (Read Tab)
- **Files Modified**: `lib/ui/screens/read_screen.dart`
- **Fix**: Re-layered the `Positioned` top navigation controls. Wrapped the Top Navigation Bar layer in a `ClipRRect` and `BackdropFilter` with a solid `theme.scaffoldBackgroundColor` frosted effect. This guarantees that scripture text cleanly vanishes behind the pinned header rather than colliding visually with floating controls during vertical scrolling.

#### 4. Commentary Bottom Sheet Consistency
- **Files Modified**: `lib/ui/screens/read_screen.dart`
- **Fix**: Updated the Commentary Share Menu (`_showShareMenu`). Replaced the square `ListTile` items with pill-shaped `ElevatedButton.icon` widgets utilizing a `RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))`. Enforced the global frosted cream and gold styling for visual consistency across modals.

### Verification
- Ran final `flutter analyze` which confirmed 0 issues found.
- All structural changes respect the existing UI aesthetic parameters (warm cream/gold, glassmorphism, Gentium serif font).

## prerelease-1

The Blessed Bible — an early beta of a KJV Bible study app: 12+ themes, multi-translation reading, commentary (Genesis, Daniel, Hebrews, Revelation), and reading plans.

This is a prerelease beta — expect a few rough edges. Feedback is welcome. Send feedback to me directly, or open an issue on this repo.

[Screenshot: Home — to add]
[Screenshot: Reading a chapter — to add]
[Screenshot: Themes — to add]
[Screenshot: Commentary — to add]

### 📥 Download & Install

Most people: download `BlessedBible-prerelease-1-universal.apk` — it works on any Android phone. Tap to download, then open it to install.
You’ll need to allow “Install from unknown sources” when prompted — that’s normal for beta apps outside the Play Store.

Want a smaller download? If you know your phone’s chip, grab the matching version instead:
- `BlessedBible-prerelease-1-arm64-v8a.apk` — almost all modern phones (Samsung, Pixel, etc. from the last several years)
- `BlessedBible-prerelease-1-armeabi-v7a.apk` — older 32-bit devices
- `BlessedBible-prerelease-1-x86_64.apk` — emulators (rarely needed)

Not sure? Just use the universal one — it always works.
