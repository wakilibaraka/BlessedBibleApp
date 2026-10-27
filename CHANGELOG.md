# Changelog

All notable changes to The Blessed Bible. Newest first.

## [Unreleased]

### Account
- **Sign out to a guest:** One sheet asks whether to keep your study data and your name on this device (both ticked). You always land as a guest, under your name or "Guest".
- **Reset this device:** Erases study data on this device only. Signed in, choose to sign out or stay signed in and re-download. Deleting this app's cloud data is a separate switch, off by default, confirmed by typing DELETE.
- **Your name:** Guests can name themselves; signed-in name edits update the shared account (Blessed Arcade too).
- **No more blank screens:** Finishing or restarting onboarding no longer replaces the app's root screen, slow account actions show progress, and Delete account, Back up and Restore from the account menu work again.

## [0.0.6] - 2026-10-26

### Commentary & Volumes
- **Commentary Library as a Shelf of Volumes:** Opens on visual book covers with author imprints, serif titles, spines, and scripture coverage (*The Desire of Ages*, *Prophets and Kings*, *Daniel and the Revelation*). Direct chapter navigation in 2 taps; canonical by-book index; search across titles, authors, and scripture.
- **Refined Editorial Layout:** Pull-quote verse header cards, 1-tap filter pills, source eyebrow tags, author attribution, and direct commentary sharing.
- **Classic Preset Toggle:** Option in Settings to switch back to the classic flat commentary list at any time.
- **Prose Reflow & Rich Formatting:** Automatic text reflow from print hard-wraps, collapsed double spaces, real paragraph spacing, and formatting for `**bold**` and `__underline__` with tappable verse previews.
- **Cleaned Historicist Commentary:** Comprehensive OCR artifact sweep eliminating scanner noise, entity artifacts, broken hyphenations, plate credits, and Gutenberg index wrappers (`tool/clean_commentary.py`).

### Universal Sharing & Document Export
- **Unified Share Suite:** Standardized share modal across Verses, Verse of the Day, Word of the Day, Bible stories, highlights, and commentary entries.
- **Typeset PDF Export:** Generate and export publication-ready A4 PDF documents with custom typography, running headers, citations, and localized text.
- **Multi-Format Visual Cards:** High-res image cards in Portrait (4:5), Square (1:1), and Story (9:16) aspect ratios with remembered format preferences.
- **Save to Gallery:** Direct 1-tap saving to device photo libraries (iOS & Android) alongside native sharing.
- **WhatsApp & Plain Text Formats:** Formatted clipboard text with bold headings and italicized citations.

### Localization & Reading Experience
- **Localized Bible Book Names:** Full scripture book translation across all 6 supported languages (English, French, Italian, Romanian, Swahili, Tagalog) across headers, pickers, plans, study cards, and search.
- **Accurate Context Navigation:** Fixed "Read in context" to reliably resolve both book and chapter.
- **Persistent Verse Highlighting:** Jump target verses remain clearly accented until page navigation.
- **Localized End-of-Chapter Markers:** Native language chapter completions in the reader.

## [0.0.5] - 2026-10-22

### Home Screen & Daily Content
- **Story of the Day:** Added daily Bible story section at the bottom of the Home screen, featuring headline title, scripture reference, summary retelling snippet, Gustave Doré engraving plate previews, direct passage reading in `BibleStoryReaderScreen`, and daily calendar rotation across 500 devotional stories.
- **Cleaner Commentary View:** Removed the `COMMENTARY · [Author]` text header and icon from the Home screen commentary card for an uncluttered, modern text-first aesthetic.
- **Enhanced Sharing System:** Added `ShareService.formatStory` for formatted clipboard and WhatsApp sharing, plus custom rendered `ShareCard.story` visual cards supporting multiple backdrop styles and Doré artwork plates.
- **Multi-language Support:** Added localization for Story of the Day in English, French, Italian, Romanian, Swahili, and Tagalog.

## [0.0.4] - 2026-10-22

### Study & Concordance
- **Biblical Concordance:** Complete built-in searchable concordance with 32+ prominent theological terms (Grace, Faith, Love, Peace, Hope, Mercy, Salvation, Righteousness, Holy, Truth, Covenant, Spirit, etc.) with exact verified occurrence counts from the KJV database, curated definitions, category filter chips, Old/New Testament filtering, and in-text keyword highlighting.
- **Study Page Presets:** Simplified card sizing into two explicit presets: **Full** (spans entire width) and **Half** (compact, 2 per row). Added a top preset pill toggle (`[ Full | Half ]`) and an easy customization sheet to switch card layouts individually or in batch.
- **Distinct Daily Cards:** Separated Word of the Day (`wotd`) and Verse of the Day (`votd_archive`) into dedicated half-width cards with interactive entry sheets and archive history.

### Reading Plans Flow
- **Study widget:** No more swipe pages. With an active plan it shows progress and today's reading with a **Read** button that opens the passage directly; with none it suggests curated plans. Multiple active plans each get their own row.
- **Plans page:** Redesigned hero with weekday, date, streak counter, and direct reading button. Removed old calendar rail in favor of clean date-first layout. Unstarted plans show their length and a **Start** button.
- **Plan page:** Merged the separate "Begin plan" screen into one seamless view. Before starting: preview all days, start date picker, and **Start & read day 1**. After: a card that always holds the next reading (today, missed day, or read ahead) with lazy-loaded day rows. Pace and reminder settings moved to the ⋯ menu.
- **Reader:** Accent-based theming, segmented passage progress tracker with tap navigation, "Up next" previews, and inline **Mark day complete** completion card.

### Onboarding & Themes
- **Typography & Theme Shuffle:** Added an interactive comfort setup step during onboarding. Users can select reading typefaces and choose whether themes shuffle automatically on a daily basis or remain fixed.
- **Multi-Translation Selection:** Added dual-translation view selection directly during the initial setup flow.

### Accounts & Cloud Sync
- **Shared Account Integration:** Integrated `blessed_account` supporting Google Sign-In and Apple Sign-In with persistent profile support.
- **Cross-Device Sync:** Automatic sync for bookmarks, folders, highlights, study notes, reading plans, and reading streaks via Firebase Firestore.
- **Welcome-Back Prompt:** Smart one-time prompt offering sign-in restoration after device transfer or fresh install with Android Auto Backup.

### Infrastructure & Hygiene
- **Hardened CI/CD:** Automated GitHub Actions pipeline validating strict analyzer rules (`--fatal-infos`), code formatting, unit tests, golden screenshot tests, Firestore security rules tests, and shrunk signed release bundle builds.
- **Dependency & SDK Pinned:** Locked dependencies matching pinned Flutter 3.44.9 environment for reliable reproducibility.

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
- After a reinstall that restores app settings but not the sign-in (Android Auto Backup), a one-time "Welcome back" prompt offers to sign in and bring back your data. It stays quiet if you signed out yourself, said "Not now", or never had an account.
- CI now builds a signed, shrunk release app bundle on every PR, so release-only (R8/signing) breakage is caught before shipping.

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
