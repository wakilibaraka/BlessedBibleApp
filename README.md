# 📖 The Blessed Bible

A premium, local-first Bible reading and Historicist Commentary application crafted for iOS and Android with Flutter and Riverpod. 

Designed with an Apple-standard aesthetic, **The Blessed Bible** eliminates clutter and friction from daily devotionals—featuring fluid liquid glass containers, an in-memory isolate search engine, verse-by-verse historicist commentary, and modular study tools.

---

## ✨ Key Features

### 💧 Liquid Glass & Adaptive Typography
- **Frosted Depth & Textures**: Layered backdrop blurring and dynamic surface styling tailored for modern mobile screens.
- **Curated Reading Typography**: 8+ pre-bundled typographic styles (EB Garamond, Bitter, Source Sans 3, Lora, Literata, Gentium Book Plus, Lexend, OpenDyslexic) with proportional font scaling and custom margin controls.
- **Theme Engine**: Seamless transitions across Light, Dark, and high-contrast study palettes.

### 🔍 Isolate-Powered Search Engine
- **Instant In-Memory Indexing**: Low-latency inverted index running on background Dart isolates.
- **Granular Scopes & Precision**: Filter effortlessly between Old Testament, New Testament, and Commentary, with whole-word/exact-phrase precision toggles.
- **Spotlight Memory**: Fast access to recent queries and tapped study locations.

### 📜 Verse-by-Verse Historicist Commentary
- **Contextual Insights**: In-depth historical and prophetic commentary (including Uriah Smith on Daniel & Revelation).
- **Subtle Verse Indicators**: Unobtrusive margin indicators that expand into full commentary drawers on demand.

### 📝 Study Hub, Notes & Bookmarks v2
- **Slash-Command Note Editor**: Rapid inline writing with interactive `/` commands for quick-inserting verse references, timestamps, and headers.
- **Structured Bookmark Folders**: Organize verses into custom or preset folders (*Sermon Prep, Memorize, Comfort, Study*).
- **Streak & Habit Tracking**: Calendar-based day-of-year reading progress with native pull-to-refresh.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart 3)
- **State Management**: [Riverpod 2.x](https://riverpod.dev/) (Notifier/AsyncNotifier architecture)
- **Database**: Local SQLite (`bible.db`) supporting 11 bundled offline translations
- **Search**: In-Memory Inverted Index running via `compute()` background isolates
- **Storage**: Non-destructive, versioned JSON preference serialization
- **Security & Privacy**: 100% local and offline. Zero tracking, zero third-party telemetry.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x or higher)
- Xcode (iOS) / Android Studio (Android SDK 34+)

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/Baraka254/BlessedBibleApp.git
   cd BlessedBibleApp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run on your connected device/simulator:
   ```bash
   flutter run
   ```

---

## 🔒 License
Private Repository. All rights reserved.
