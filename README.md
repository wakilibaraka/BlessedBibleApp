# 📖 Blessed Bible (The Blessed Bible)

[![Release](https://img.shields.io/github/v/release/wakilibaraka/BlessedBibleApp?include_prereleases&style=flat-square&color=blue)](https://github.com/wakilibaraka/BlessedBibleApp/releases)
[![CI Status](https://img.shields.io/github/actions/workflow/status/wakilibaraka/BlessedBibleApp/ci.yml?branch=main&style=flat-square&label=CI)](https://github.com/wakilibaraka/BlessedBibleApp/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.44.9%2B-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
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

### 📜 Historicist Commentary & Clean Home Cards
- **Streamlined Home Commentary Card**: Elevated distraction-free commentary view without repetitive labels, highlighting rich historicist thoughts directly on the dashboard.
- **Classic Theological Insights**: Verse-by-verse and chapter-level commentary for Genesis, Daniel, Hebrews, and Revelation, drawn from classic historicist authors (Uriah Smith, Ellen G. White).
- **Inline Cross-References**: Tap directly into commentaries without losing your place in scripture.

### 📅 Redesigned Reading Plans & Plan Reader
- **Streamlined Dashboard**: Date and reading streak hero at the top of your plans, keeping your daily goal front and center.
- **1-Tap Direct Reading**: Open today's assigned chapters with a single tap from the Study Page or Plans Library.
- **Segmented Reader**: Visual segmented progress bar for multi-passage days, "Up next" previews, and inline completion cards that mark your day done right in the reader.
- **Custom Plan Builder**: Create your own custom reading journeys tailored to your personal pace and schedule.

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
- **CI/CD Pipeline**: GitHub Actions running automated formatting, static analysis (`--fatal-infos`), 240+ unit/widget tests, golden snapshots, and R8/keystore release validation

---

## 🚀 Developer Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (pinned to **3.44.9** via `.fvmrc`)
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
```

### Content Build Scripts
Database conversion and data processing tools reside in [`tool/`](tool/README.md).
See [`CONTRIBUTING.md`](CONTRIBUTING.md) for architectural guidelines and code standards, and [`CHANGELOG.md`](CHANGELOG.md) for version history.

---

## 🔒 License

Proprietary. The source code is made public for reference and personal study only; all rights reserved. See [`LICENSE`](LICENSE) for details.
