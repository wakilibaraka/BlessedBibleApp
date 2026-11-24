# 📖 Blessed Bible (The Blessed Bible)

[![Release](https://img.shields.io/github/v/release/wakilibaraka/BlessedBibleApp?include_prereleases&style=flat-square&color=blue)](https://github.com/wakilibaraka/BlessedBibleApp/releases)
[![CI Status](https://img.shields.io/github/actions/workflow/status/wakilibaraka/BlessedBibleApp/ci.yml?branch=main&style=flat-square&label=CI)](https://github.com/wakilibaraka/BlessedBibleApp/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.6%2B-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20(in%20progress)-green?style=flat-square)](https://github.com/wakilibaraka/BlessedBibleApp)

A fast, offline-first, distraction-free Bible study app crafted with Flutter. Built for deep scripture immersion, multi-language study, verse-by-verse historicist commentary, and interactive reading plans. Listed on devices as **Bible**.

---

## ⬇️ Download & Installation

Get the latest release APKs directly from [GitHub Releases](https://github.com/wakilibaraka/BlessedBibleApp/releases/latest).

| Package | Recommended For | Description |
| :--- | :--- | :--- |
| **`BlessedBible-*-arm64-v8a.apk`** | **Most Modern Phones & Tablets** *(Recommended)* | Optimized 64-bit ARM build with the smallest download size (~127 MB) and fastest startup. |
| **`BlessedBible-*-universal.apk`** | **Any Android Device** | Complete bundle containing all CPU architectures (~172 MB). Choose this if you're unsure of your processor type. |
| **`BlessedBible-*-armeabi-v7a.apk`** | **Older 32-bit Phones** | Optimized build for older 32-bit ARM Android devices (~125 MB). |
| **`BlessedBible-*-x86_64.apk`** | **Emulators & Chromebooks** | Optimized for Intel/AMD-based Android emulators and Chromebook devices (~128 MB). |

> **How to install:** Download the APK matching your device, tap the downloaded file on your Android device, and allow installation from your browser or file manager when prompted.

---

## ✨ Flagship Features

### 📖 Distraction-Free Scripture Reading
- **King James Version (KJV)** with smooth, native scrolling, gesture navigation, and rapid chapter/verse selection.
- **Multi-Language Support**: Complete interface and scripture localization across 6 languages: English, French (`Français`), Italian (`Italiano`), Romanian (`Română`), Swahili (`Kiswahili`), and Tagalog. Read comparative secondary translations side-by-side or per-verse.
- **Audio & Offline Bible**: High-performance local SQLite database — read anywhere without an internet connection or cellular data.

### 📜 Story of the Day & Gustave Doré Artwork
- **Daily Narrative Journey**: Featured Bible story presented daily on the Home screen, rotating predictably across a 500-story curated devotional collection.
- **Direct Reading**: 1-tap `[Read story]` action opens the narrative in `BibleStoryReaderScreen` with immediate scripture navigation.
- **Classical Doré Plates**: Embedded engraving plate previews by renowned artist Gustave Doré accompanying key historical accounts.

### 🔍 Built-In Biblical Concordance
- **Curated Theological Index**: Explore 32+ foundational biblical keywords (Grace, Faith, Love, Peace, Hope, Mercy, Salvation, Righteousness, Covenant, Spirit, etc.) with exact verified KJV occurrence counts and concise theological definitions.
- **Smart Filtering & Highlighting**: Filter results by Old Testament, New Testament, or thematic categories (*Salvation*, *Spiritual Life*, *Christian Walk*, *God & Spirit*). Matches are highlighted directly in the scripture text.

### 📚 Commentary Shelf & Historicist Volumes
- **Visual Library as a Shelf of Books**: Replaces flat lists with gorgeous volume covers featuring author imprints, spines, and scripture scope (*The Desire of Ages*, *Prophets and Kings*, *Patriarchs and Prophets*, *Daniel and the Revelation*).
- **2-Tap Chapter Navigation**: Tap any volume to view its title page, chapter index, and scope, with a canonical by-book index and fast search across authors and titles.
- **Refined Editorial Layout**: Verse pull-quote hero cards, 1-tap filter pills, and source tags. Settings allows switching to the classic layout at any time.
- **Prose Reflow & OCR Cleanup**: Reflows print hard-wraps, rejoins words broken across a line, repairs OCR-glued sentences, and drops zero-width and soft-hyphen noise. Verse pull-quote cards and the Story of the Day key verse render bold, underline, and tappable inline scripture links like the body text.

### 📤 Unified Share Suite, PDF Export & Gallery Save
- **Standardized Multi-Mode Sharing**: A single, elegant share modal across verses, daily inspiration, Bible stories, and commentary entries.
- **Typeset A4 PDF Export**: Export commentary and devotional stories as beautifully formatted, print-ready PDF documents with running heads, citations, and full multi-language font support.
- **Multi-Ratio Graphic Cards**: Create high-resolution share cards in **Portrait (4:5)**, **Square (1:1)**, and **Story (9:16)** formats with custom backdrops.
- **1-Tap Save to Gallery**: Save generated cards directly to the device's photo library on Android and iOS.
- **Formatted WhatsApp & Text Sharing**: Cleanly formatted clipboard exports with bold headers, italic citations, and stripped OCR/Strong's markers.

### 🌐 Full Multi-Language Localization
- **6 Supported Languages**: English, French (`Français`), Italian (`Italiano`), Romanian (`Română`), Swahili (`Kiswahili`), and Tagalog.
- **Complete Book Name Translation**: Bible book names follow the selected interface language everywhere — headers, book selectors, study tools, search, reading plans, and the plan reader's completion card.
- **Read in Context, Properly**: "Read in context" on the Verse of the Day, a commentary pull-quote, or a verse preview opens the plan-style chapter reader on the named chapter, with that verse accented and scrolled into view.

### 📅 Redesigned Reading Plans & Plan Reader
- **Streamlined Dashboard**: Date and reading streak hero at the top of your plans, keeping your daily goal front and center.
- **1-Tap Direct Reading**: Open today's assigned chapters with a single tap from the Study Page or Plans Library.
- **Segmented Reader**: Visual segmented progress bar for multi-passage days, "Up next" previews, and inline completion cards that mark your day done right in the reader.
- **Custom Plan Builder**: Create your own custom reading journeys tailored to your personal pace and schedule, and change the day count later without losing progress.
- **Completion Dates & Plan Streak**: Every finished day records the date it was read, so the plan page knows whether you read today and shows a consecutive-day streak. Catch-up dates the days it sweeps rather than claiming the whole plan was read today.
- **Honest Progress**: Day completion survives re-partitioning (style changes, pace changes, imports) because progress is keyed by passage content, not by day number.

### 🎧 Listen to Any Chapter
- **Tap the headphones in the reader**: streams the public-domain World English Bible narration for the chapter you are on (about 0.2–1 MB each), with a media notification and lock-screen controls. No narration files ship in the app, so the download stays small.
- **WEB on device from install**: the World English Bible text ships with the app (about 5 MB), so read-along works offline on a fresh install without downloading a translation.
- **Read along**: the text follows the narrated verse, steps aside the moment you scroll, and offers "Back to the playing verse". Verse timing is estimated from the text — tap the verse you hear to correct a chapter, and the correction is saved so you only fix a chapter once.
- **Verse-aware scrubber**: one tick per verse; tap to jump to a verse or drag to scrub, with the current verse named above the bar.
- **Built for listening**: continuous play (next chapter, or stop at the end of the book), a 15/30/45/60-minute sleep timer, 10-second skips, and 0.75×–2× speed.
- **Offline and resumable**: download a single chapter or a whole book (capped at 200 MB, oldest dropped first), clear downloads from the player or from **Settings → Storage**, and resume the last chapter from the **Continue listening** card on Home.

### 🎨 Dynamic Themes & Custom Typography
- **14 Hand-Crafted Visual Themes**: Light, Dark, Sepia, OLED black, Earth, Paperlike, and Claymorphic styles with live recoloring.
- **Daily Theme Shuffle**: Enjoy fresh aesthetics every day automatically, or lock in your favorite theme permanently.
- **Refined Reading Typography**: Premium typefaces designed for sustained reading comfort, including *Lora*, *Literata*, *EB Garamond*, *Bitter*, *Lexend*, and *Source Sans 3*, with adjustable sizing and line spacing.

### 🏷️ Personal Study Space & Enhanced Sharing
- **Study Page Layout Presets**: Instant toggle between **Full** (spacious cards) and **Half** (compact, 2 per row) study card layouts.
- **Dedicated Daily Cards**: Separate cards for **Word of the Day** (with instant dictionary lookup) and **Verse of the Day** (with archive browsing).
- **Visual Share Suite**: Generate beautiful high-resolution share cards (`ShareCard.story`, `ShareCard.verse`) with customizable backgrounds (dawn, dusk, artwork plates, gradients) or format text cleanly for WhatsApp and clipboard sharing.
- **Organized Bookmarks & Notes**: Group saved verses into customized folders or automatic smart collections by book and date.

### ☁️ Privacy-First & Cloud Sync
- **No Account Required**: The entire app functions completely offline without collecting personal data.
- **Optional Cloud Sync**: Sign in securely with Google or Apple via `blessed_account` to seamlessly sync your bookmarks, notes, reading plans, and streaks across multiple devices.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management**: [Riverpod](https://riverpod.dev) with Notifier architecture
- **Local Storage**: Bundled SQLite database (`sqflite`), Git LFS data packs, and `shared_preferences`
- **Cloud & Sync**: Firebase Auth, Cloud Firestore (with strict security rules), Firebase App Check, and Crashlytics
- **Design Tokens**: Centralized token architecture (`AppPalette`, `TypeScale`, `Radii`, `Elevation`) ensuring consistent styling without raw magic values
- **CI/CD Pipeline**: GitHub Actions running automated formatting, static analysis (`--fatal-infos`), 440+ unit/widget tests, golden snapshots, Firestore rules tests, and Android debug plus R8/keystore release builds

---

## 🚀 Developer Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (pinned to **3.47.6** via `.fvmrc`)
- Android Studio / Android SDK (Platform 34+)
- Xcode 15+ (for iOS development)
- Git LFS (`git lfs install`)

### Clone and Run
```bash
# Clone repository with Git LFS
git clone https://github.com/wakilibaraka/BlessedBibleApp.git
cd BlessedBibleApp
git lfs pull

# Install dependencies with locked versions
flutter pub get --enforce-lockfile

# Run local code analysis and test suite
flutter analyze --fatal-infos
flutter test

# Run app on connected device or emulator
flutter run

# Build a release APK for modern 64-bit phones (arm64 only, ~5 MB of packs)
flutter build apk --release --target-platform android-arm64
```

### Content Build Scripts
Database conversion and data processing tools reside in [`tool/`](tool/README.md).
See [`CONTRIBUTING.md`](CONTRIBUTING.md) for architectural guidelines and code standards, and [`CHANGELOG.md`](CHANGELOG.md) for version history.

---

## 🔒 License

Proprietary. The source code is made public for reference and personal study only; all rights reserved. See [`LICENSE`](LICENSE) for details.
