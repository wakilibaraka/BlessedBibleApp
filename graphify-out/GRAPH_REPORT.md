# Graph Report - Blessed Bible  (2026-10-22)

## Corpus Check
- 382 files · ~4,196,162 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 133 file(s) not represented in the graph (top: .ttf 48, .xml 32, (none) 12)

## Summary
- 12163 nodes · 14932 edges · 179 communities (162 shown, 17 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.95)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5c292cab`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- app_localizations.dart
- app_localizations_en.dart
- app_localizations_fr.dart
- app_localizations_it.dart
- app_localizations_ro.dart
- app_localizations_sw.dart
- app_localizations_tl.dart
- preferences_service.dart
- themeProvider
- ../../l10n/l10n.dart
- preferencesProvider
- StatelessWidget
- app_colors.dart
- search_screen.dart
- search_engine.dart
- reading_plan_detail_v2_screen.dart
- reading_plan_provider.dart
- commentary_library_v2_screen.dart
- custom_plan_builder_v2_screen.dart
- package:flutter_riverpod/flutter_riverpod.dart
- study_screen_v2.dart
- onboarding_screen.dart
- read_screen.dart
- theme_picker_sheet.dart
- plans_library_widgets.dart
- search_provider.dart
- bible_sync_test.dart
- package:flutter_test/flutter_test.dart
- main_nav_screen.dart
- study_reader_screen.dart
- plan_scheduler_test.dart
- account_menu.dart
- design_tokens.dart
- read_settings_provider.dart
- your_space_screen.dart
- Contributing: Project Rules & Workflow
- bible_database_service.dart
- reminders_provider.dart
- translation_pack_store.dart
- bible_sync.dart
- commentary_view.dart
- ReadingTokens
- home_provider.dart
- item_context_sheet.dart
- plan_spec.dart
- dictionary_provider.dart
- dart:convert
- generate_reading_plan.dart
- _
- notification_service.dart
- devotional_provider.dart
- BlessedBibleWidgets.swift
- home_data.dart
- storage_screen.dart
- book_chapter_selector_sheet.dart
- dictionary_underline_test.dart
- library_calendar_rail.dart
- fetch_dore_art.py
- search_settings_provider.dart
- typography_provider.dart
- verse_action_sheet.dart
- translation_downloader.dart
- Production Readiness: Status and Plan
- package:flutter/material.dart
- verse_link_text.dart
- reading_plan.dart
- plan_generator.dart
- app_theme.dart
- textured_glass_container.dart
- isolate_parsers.dart
- pace_remap_service.dart
- plan_assets_test.dart
- ============================================================
- bible_story_reader_screen.dart
- commentary_entry.dart
- devotional_service.dart
- bible_nav_settings_provider.dart
- return
- commentary_provider.dart
- concordance_screen.dart
- dynamic_toast.dart
- radial_action_menu.dart
- build_topical.py
- devotional_story.dart
- Notifier
- translation_picker_sheet.dart
- List
- bouncy_entrance.dart
- build_bible_db.dart
- AppDelegate
- json
- abbreviation
- crossed_swords_icon.dart
- bible_provider.dart
- notes_list_screen.dart
- goldens_test.dart
- bookmark_model.dart
- Privacy Policy
- package.json
- study_layout_provider.dart
- bible_stories_screen.dart
- build_content.py
- auth_provider.dart
- study_greetings_test.dart
- day_complete_celebration.dart
- study_greetings.dart
- Pericope Dataset — Whole-System Audit Report
- pericope_entry.dart
- wotd_provider.dart
- state_views.dart
- animated_segmented_tile.dart
- streak_provider.dart
- read_location_provider.dart
- State
- curated_plans.dart
- shared_app_bar.dart
- os
- translation_downloader_test.dart
- VotdWidgetProvider.kt
- translation_model.dart
- let_read_test.dart
- surface_style_provider.dart
- StreakWidgetProvider.kt
- Color
- most_read_provider.dart
- Phase 6 device test checklist
- Content Licenses Register
- sys
- AppLocalizations
- build
- action_icon.dart
- locale_reschedule_test.dart
- upload_packs
- Mandatory Self-Checks
- Mandatory Self-Checks
- Mandatory Self-Checks
- cross_references_provider.dart
- verse_linker.dart
- deu_l12
- fra_lsg
- ita_dio
- kjv_strongs
- nld_
- ron_btf
- swh_ulb
- tgl_ulb
- por_blj
- spa_r09
- web
- Android: Google sign-in setup and release checks
- Heading Merge Proposal: Chapter Titles & Pericopes
- Mandatory Self-Checks
- Mandatory Self-Checks
- Mandatory Self-Checks
- Shared Accounts: The Blessed Bible + Blessed Arcade
- share_card_test.dart
- pull_request_template.md
- let_read.dart
- credits.dart
- firebase_options_stub.dart
- MainActivity.kt
- Applied Fixes
- PHASE_6_PLAN.md
- firestore-tests/README.md
- LaunchImage.imageset/README.md
- journal_entry.dart
- notificationServiceProvider
- search_engine_test.dart
- content_sync_service.dart
- concordance_terms.dart

## God Nodes (most connected - your core abstractions)
1. `preferencesProvider` - 123 edges
2. `_` - 62 edges
3. `themeProvider` - 47 edges
4. `readSettingsProvider` - 34 edges
5. `bibleProvider` - 31 edges
6. `_ReadScreenState` - 31 edges
7. `activeTranslationProvider` - 28 edges
8. `============================================================` - 26 edges
9. `readingPlanProvider` - 23 edges
10. `typographyProvider` - 23 edges

## Surprising Connections (you probably didn't know these)
- `4. Work breakdown (one PR each)` --references--> `merge()`  [INFERRED]
  docs/PHASE_5B_SYNC_PLAN.md → tool/build_topical.py
- `exportData` --references--> `preferencesProvider`  [EXTRACTED]
  lib/services/backup_service.dart → lib/data/local_storage/preferences_service.dart
- `_rememberSignIn` --references--> `preferencesProvider`  [EXTRACTED]
  lib/state/auth_provider.dart → lib/data/local_storage/preferences_service.dart
- `build` --references--> `preferencesProvider`  [EXTRACTED]
  lib/state/commentary_provider.dart → lib/data/local_storage/preferences_service.dart
- `toggleBookmark` --references--> `preferencesProvider`  [EXTRACTED]
  lib/state/commentary_provider.dart → lib/data/local_storage/preferences_service.dart

## Import Cycles
- None detected.

## Communities (179 total, 17 thin omitted)

### Community 0 - "app_localizations.dart"
Cohesion: 0.00
Nodes (1083): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1075 more)

### Community 1 - "app_localizations_en.dart"
Cohesion: 0.00
Nodes (1075): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1067 more)

### Community 2 - "app_localizations_fr.dart"
Cohesion: 0.00
Nodes (1075): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1067 more)

### Community 3 - "app_localizations_it.dart"
Cohesion: 0.00
Nodes (1075): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1067 more)

### Community 4 - "app_localizations_ro.dart"
Cohesion: 0.00
Nodes (1075): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1067 more)

### Community 5 - "app_localizations_sw.dart"
Cohesion: 0.00
Nodes (1075): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1067 more)

### Community 6 - "app_localizations_tl.dart"
Cohesion: 0.00
Nodes (1075): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1067 more)

### Community 7 - "preferences_service.dart"
Cohesion: 0.01
Nodes (148): _activePlanIdsKey, _activeTranslationKey, _appUsageDatesKey, _bentoPresetKey, _bookmarksKey, _bookmarksV2Key, _chapterPositionsKey, clearAllUserData (+140 more)

### Community 8 - "themeProvider"
Cohesion: 0.04
Nodes (122): build, _TheBlessedBibleAppState, widgetUpdateServiceProvider, wordCountServiceProvider, bibleNavSettingsProvider, bibleProvider, flatChaptersProvider, translationChapterProvider (+114 more)

### Community 9 - "../../l10n/l10n.dart"
Cohesion: 0.02
Nodes (90): cleanVerseText, copyText, formatVerse, formatWord, referenceFor, shareImageFromBoundary, ShareService, shareText (+82 more)

### Community 10 - "preferencesProvider"
Cohesion: 0.03
Nodes (74): preferencesProvider, build, hasSeen, HintsNotifier, hintsProvider, markSeen, maybeShowHint, resetHints (+66 more)

### Community 11 - "StatelessWidget"
Cohesion: 0.04
Nodes (53): _RefBox, _RestChip, _TrackCard, _ChoiceTile, _ClassicThemeButton, _FeatureRow, _FontChip, _LanguagePage (+45 more)

### Community 12 - "app_colors.dart"
Cohesion: 0.03
Nodes (78): AppColors, darkBackground, darkBorder, darkSurface, darkTextPrimary, darkTextSecondary, dawnAccent, dawnBackground (+70 more)

### Community 13 - "search_screen.dart"
Cohesion: 0.07
Nodes (27): mostReadProvider, searchEngineProvider, build, _performSearch, SearchNotifier, searchStateProvider, searchSettingsProvider, _animationController (+19 more)

### Community 14 - "search_engine.dart"
Cohesion: 0.03
Nodes (66): activeTranslation, addNoteTokens, addTokens, args, baseIndexFuture, baseSearchIndexProvider, bibleBooks, bibleState (+58 more)

### Community 15 - "reading_plan_detail_v2_screen.dart"
Cohesion: 0.05
Nodes (36): _checked, color, createState, date, dateLabel, _dateMap, day, _DayDetailCard (+28 more)

### Community 16 - "reading_plan_provider.dart"
Cohesion: 0.03
Nodes (73): addPlan, appWeekday, bookName, build, _canonCache, _canonIndex, chapterNum, completedAtomIds (+65 more)

### Community 17 - "commentary_library_v2_screen.dart"
Cohesion: 0.06
Nodes (35): bookmarkedWordsProvider, dictionaryDefinitionProvider, dictionarySearchProvider, book, chapter, CommentaryHubV2Screen, CommentaryLibraryV2Screen, createState (+27 more)

### Community 18 - "custom_plan_builder_v2_screen.dart"
Cohesion: 0.04
Nodes (49): _autoName, build, createState, _days, _daysController, dispose, draft, _drafts (+41 more)

### Community 19 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.04
Nodes (34): bbeSubstitutionsProvider, DictionaryScope, NonKjvDictionaryMode, PopupStyle, SelectorHeight, StrongsIndicatorStyle, VerseActionStyle, build (+26 more)

### Community 20 - "study_screen_v2.dart"
Cohesion: 0.02
Nodes (126): BackupService, importData, commentaryForChapterProvider, build, votdPoolProvider, notesProvider, activePlanContextProvider, activePlanIdsProvider (+118 more)

### Community 21 - "onboarding_screen.dart"
Cohesion: 0.02
Nodes (85): activateAppCheck, authGateway, createState, initCrashReporting, initialize, initializeApp, main, prefs (+77 more)

### Community 22 - "read_screen.dart"
Cohesion: 0.03
Nodes (58): navHiddenProvider, _buildFabIcon, _fabTooltip, _animateToPage, _buildNormalVerse, _buildReadingLayoutVerse, _buildSideButton, _buildThemedPill (+50 more)

### Community 23 - "theme_picker_sheet.dart"
Cohesion: 0.05
Nodes (41): color, controller, createState, currentMode, dirX, dirY, dispose, fillColor (+33 more)

### Community 24 - "plans_library_widgets.dart"
Cohesion: 0.09
Nodes (22): build, _dailyPlateProvider, day, height, initials, libraryDateHeader, LibraryGreetingHeader, LibraryPlateBand (+14 more)

### Community 25 - "search_provider.dart"
Cohesion: 0.06
Nodes (29): addRecentPlace, _addRecentQuery, clearRecentQueries, copyWith, _debounce, exactMatch, filterBook, filterCommentary (+21 more)

### Community 26 - "bible_sync_test.dart"
Cohesion: 0.08
Nodes (14): main, openMenu, pumpHub, col, db, device, main, settle (+6 more)

### Community 27 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.05
Nodes (23): main, host, main, host, main, planStartedOn, settlePaging, main (+15 more)

### Community 28 - "main_nav_screen.dart"
Cohesion: 0.02
Nodes (61): addAllowedPointer, createState, didChangeDependencies, dispose, _dragStartY, filled, handleEvent, _hasFiredArmedHaptic (+53 more)

### Community 29 - "study_reader_screen.dart"
Cohesion: 0.04
Nodes (52): book, bookAbbrev, bookName, chapter, chapterNum, _clearSelection, createState, _current (+44 more)

### Community 30 - "plan_scheduler_test.dart"
Cohesion: 0.05
Nodes (41): PaceRemapService, PlanGenerator, _data, _ensureInitialized, init, initFromJson, maxVerseInChapter, _parseWordCountsJson (+33 more)

### Community 31 - "account_menu.dart"
Cohesion: 0.04
Nodes (58): authActionsProvider, syncControllerProvider, _save, build, _FeaturesAndAccountPage, build, AccountAvatar, _AccountMenuBody (+50 more)

### Community 32 - "design_tokens.dart"
Cohesion: 0.04
Nodes (45): all, body, bodyLarge, caption, card, copyWith, danger, display (+37 more)

### Community 33 - "read_settings_provider.dart"
Cohesion: 0.04
Nodes (46): activeHighlightColorIndex, _activeHighlightColorIndexKey, build, copyWith, cycleHighlightColor, defaultStartTab, dictionaryUnderlinesEnabled, difficultAndNames (+38 more)

### Community 34 - "your_space_screen.dart"
Cohesion: 0.04
Nodes (44): abbrevUpper, bookAbbrev, bookmarkData, _BookmarkViewType, bookName, bookNumber, _buildRealVerseCard, chapter (+36 more)

### Community 35 - "Contributing: Project Rules & Workflow"
Cohesion: 0.04
Nodes (43): 1.0.2+9, 1. Navigation Modal Performance (Critical), 2. Navigation Flow Logic (Friction), 3. Header Collision (Read Tab), 4. Commentary Bottom Sheet Consistency, Accounts, Added, Changed (+35 more)

### Community 36 - "bible_database_service.dart"
Cohesion: 0.04
Nodes (41): BibleDatabaseService, bibleDbService, _clearRepairAttempts, contentBytesUsed, contentVersion, _contentVersionKey, _copyAssetDb, _db (+33 more)

### Community 37 - "reminders_provider.dart"
Cohesion: 0.08
Nodes (23): copyWith, customWeeklyDay, customWeeklyEnabled, customWeeklyHour, customWeeklyMinute, dailyEnabled, dailyHour, dailyMinute (+15 more)

### Community 38 - "translation_pack_store.dart"
Cohesion: 0.04
Nodes (42): abbreviation, bundledPackIds, _catalogFile, _copyAssetPack, coreIds, deletedPackIds, _deletedPacksKey, deletePack (+34 more)

### Community 39 - "bible_sync.dart"
Cohesion: 0.05
Nodes (41): ActivePlansSync, afterSignIn, _applyingRemote, BookmarksSync, _collections, CustomPlansSync, debounce, deviceId (+33 more)

### Community 40 - "commentary_view.dart"
Cohesion: 0.03
Nodes (48): currentVersion, exportData, bookName, bookNumber, chapterNum, color, createState, _getBookAbbrev (+40 more)

### Community 41 - "ReadingTokens"
Cohesion: 0.40
Nodes (3): AppPalette, ReadingTokens, _StyleMeta

### Community 42 - "home_provider.dart"
Cohesion: 0.06
Nodes (29): bibleState, books, commentaries, commentaryState, defaultFallback, _extractSnippet, _fetchData, HomeNotifier (+21 more)

### Community 43 - "item_context_sheet.dart"
Cohesion: 0.12
Nodes (14): actions, build, confirmDestructive, destructive, false, icon, ItemAction, ItemContextSheet (+6 more)

### Community 44 - "plan_spec.dart"
Cohesion: 0.05
Nodes (42): attribution, badge, book, _bookAliases, cadenceDays, category, day, days (+34 more)

### Community 45 - "dictionary_provider.dart"
Cohesion: 0.05
Nodes (35): aliases, bookNumber, build, chapterNumber, ChapterUnderlineArgs, db, definition, dictionaryAliasesProvider (+27 more)

### Community 46 - "dart:convert"
Cohesion: 0.06
Nodes (29): CanonIndex, _baselinePath, _count, files, main, _patterns, result, main (+21 more)

### Community 47 - "generate_reading_plan.dart"
Cohesion: 0.05
Nodes (41): abbrevKey, bad, badRefs, badWeeks, _bookMap, bookName, _canonicalNames, ch (+33 more)

### Community 48 - "_"
Cohesion: 0.05
Nodes (43): _, align, artworkPath, body, _boundaryKey, build, caption, context (+35 more)

### Community 49 - "notification_service.dart"
Cohesion: 0.09
Nodes (17): cancelDailyReminder, cancelPrayerReminder, cancelReminder, cancelSabbathReminders, cancelWeeklyReminder, _flutterLocalNotificationsPlugin, initialize, _initialized (+9 more)

### Community 50 - "devotional_provider.dart"
Cohesion: 0.05
Nodes (36): all, bookPrefix, build, copyWith, DevotionalFilterNotifier, DevotionalFilterState, favorites, favoritesOnly (+28 more)

### Community 51 - "BlessedBibleWidgets.swift"
Cohesion: 0.09
Nodes (17): BlessedBibleWidgets, .body, Color, Provider, SimpleEntry, StreakWidget, .body, StreakWidgetEntryView (+9 more)

### Community 52 - "home_data.dart"
Cohesion: 0.08
Nodes (25): activeStudy, author, chaptersRemaining, commentarySnippet, content, count, date, fromJson (+17 more)

### Community 53 - "storage_screen.dart"
Cohesion: 0.06
Nodes (35): abbr, build, bundled, _busy, _cacheBytes, _cacheBytesUsed, _clearCache, _confirm (+27 more)

### Community 54 - "book_chapter_selector_sheet.dart"
Cohesion: 0.07
Nodes (34): book, BookChapterSelectorSheet, books, _buildBookSelection, _buildBreadcrumbs, _buildBreadcrumbSegment, _buildChapterSelection, _buildGridTile (+26 more)

### Community 55 - "dictionary_underline_test.dart"
Cohesion: 0.09
Nodes (17): argsFor, container, main, makeContainer, map, markedWords, out, prefs (+9 more)

### Community 56 - "library_calendar_rail.dart"
Cohesion: 0.06
Nodes (31): _anchor, build, complete, _controller, createState, day, _DayCell, _dayLabel (+23 more)

### Community 57 - "fetch_dore_art.py"
Cohesion: 0.15
Nodes (16): die(), ensure_dirs(), http_get(), log(), save_json(), supabase_query(), clean_key_verse(), main() (+8 more)

### Community 58 - "search_settings_provider.dart"
Cohesion: 0.06
Nodes (32): _autoOpenKey, autoOpenSingleSearchResult, build, copyWith, _defaultCommKey, _defaultDictKey, _defaultNotesKey, _defaultNtKey (+24 more)

### Community 59 - "typography_provider.dart"
Cohesion: 0.07
Nodes (28): build, copyWith, fontFamily, _fontFamilyKey, fontSize, _fontSizeKey, fontStyle, fontWeight (+20 more)

### Community 60 - "verse_action_sheet.dart"
Cohesion: 0.06
Nodes (29): action, actionCount, actions, active, allBookmarked, bookAbbrev, bookmarks, books (+21 more)

### Community 61 - "translation_downloader.dart"
Cohesion: 0.07
Nodes (20): _clean, downloadableTranslations, downloadAndInstall, _fetchBytes, _helloao, _helloaoApi, info, _maxRetries (+12 more)

### Community 62 - "Production Readiness: Status and Plan"
Cohesion: 0.07
Nodes (29): 10. Bible essentials, 11. Data, sync, privacy, 12. Accessibility and localization, 13. Performance, 14. Licensing, 15. Testing, 16. Release engineering, 17. Store compliance (+21 more)

### Community 63 - "package:flutter/material.dart"
Cohesion: 0.13
Nodes (13): AppThemeMode, AppThemeModeExtension, build, _engineModeKey, _loadTheme, _lockedThemeKey, NoAnimationPageTransitionsBuilder, resolve (+5 more)

### Community 64 - "verse_link_text.dart"
Cohesion: 0.07
Nodes (26): BoldSegment, boldStyle, build, _buildSpans, createState, defaultStyle, dictionaryWordStyle, didUpdateWidget (+18 more)

### Community 65 - "reading_plan.dart"
Cohesion: 0.07
Nodes (27): book, cadence, clampReason, copyWith, dayNumber, days, endChapter, endVerse (+19 more)

### Community 66 - "plan_generator.dart"
Cohesion: 0.07
Nodes (27): _addPortion, allPericopes, book, _Chunk, _distributeTrack, endCh, endsOnChapter, endsOnPericope (+19 more)

### Community 67 - "app_theme.dart"
Cohesion: 0.07
Nodes (23): accent, applyFreshPaperlike, applyPaperlike, AppTheme, background, customAccentTheme, darkTheme, dawnTheme (+15 more)

### Community 68 - "textured_glass_container.dart"
Cohesion: 0.05
Nodes (42): _JourneyPathPainter, _CrossedSwordsPainter, borderRadius, build, child, GlassContainer, isScrollable, margin (+34 more)

### Community 69 - "isolate_parsers.dart"
Cohesion: 0.08
Nodes (22): abbreviation, BibleBook, BibleChapter, BibleVerse, chapters, fromJson, isBookmarked, isHighlighted (+14 more)

### Community 70 - "pace_remap_service.dart"
Cohesion: 0.08
Nodes (23): absoluteVerseIndex, _addVerseRange, allPericopes, _buildCompletedVerseSet, buildCompletedVerseSetPublic, buildVerseSetFromAtomsPublic, _chapterOffset, _chapterOffsets (+15 more)

### Community 71 - "plan_assets_test.dart"
Cohesion: 0.08
Nodes (25): _assets, assetVerses, book, _bookAliases, c1, c2, c2s, canon (+17 more)

### Community 72 - "============================================================"
Cohesion: 0.08
Nodes (25): ============================================================, ============================================================, ============================================================, ============================================================, ============================================================, ============================================================, ============================================================, ============================================================ (+17 more)

### Community 73 - "bible_story_reader_screen.dart"
Cohesion: 0.10
Nodes (21): devotionalFavoritesProvider, devotionalReadProvider, _StoryCard, all, BibleStoryReaderScreen, _BibleStoryReaderScreenState, bookStories, build (+13 more)

### Community 74 - "commentary_entry.dart"
Cohesion: 0.08
Nodes (21): author, book, category, chapter, CommentaryEntry, CommentaryScope, custom, dateAdded (+13 more)

### Community 75 - "devotional_service.dart"
Cohesion: 0.08
Nodes (24): _artByPrefix, _artCaptionBySlug, _artLoaded, _artMapAsset, assetPath, _bookAssetPrefix, _booksByPrefix, caption (+16 more)

### Community 76 - "bible_nav_settings_provider.dart"
Cohesion: 0.08
Nodes (24): _autoCloseKey, autoCloseOnFinalSelection, BibleNavSettingsNotifier, BibleNavSettingsState, build, copyWith, depth, _depthKey (+16 more)

### Community 77 - "return"
Cohesion: 0.07
Nodes (19): activateAppCheck, crashlytics, initCrashReporting, reportNonFatal, setCrashlyticsCollectionEnabled, setCrashReportingEnabled, backupCustomPlan, firestorePlanJson (+11 more)

### Community 78 - "commentary_provider.dart"
Cohesion: 0.08
Nodes (23): book, build, _cachedChapters, _cachedFormattedVerses, _cachedVersesWithCommentary, _cachedVersesWithDevotionals, _cachedVersesWithNotes, chapter (+15 more)

### Community 79 - "concordance_screen.dart"
Cohesion: 0.06
Nodes (31): bookNumber, build, chapter, _clearSearch, _ConcordanceHit, ConcordanceScreen, _ConcordanceScreenState, _controller (+23 more)

### Community 80 - "dynamic_toast.dart"
Cohesion: 0.10
Nodes (20): actionLabel, build, _controller, createState, didChangeDependencies, _dismiss, _dismissing, dispose (+12 more)

### Community 81 - "radial_action_menu.dart"
Cohesion: 0.10
Nodes (20): action, actions, anchor, around, build, centres, _close, color (+12 more)

### Community 82 - "build_topical.py"
Cohesion: 0.13
Nodes (16): 1. Current state (audit, 2026-10-10), 2. What syncs, 3. Design, 4. Work breakdown (one PR each), 5. Device test script (5B.6), 6. Risks, Phase 5B: Google Sign-In, Sign-Out and Data Sync, build_plan() (+8 more)

### Community 83 - "devotional_story.dart"
Cohesion: 0.09
Nodes (22): book, copyWithEnriched, count, DevotionalBookInfo, DevotionalStory, fromJson, grouping, id (+14 more)

### Community 84 - "Notifier"
Cohesion: 0.05
Nodes (39): CommentaryBookmarksNotifier, CommentaryNotifier, DevotionalFavoritesNotifier, DevotionalReadNotifier, BookmarkedWordsNotifier, db, DictionaryHeadword, dictionaryIndexProvider (+31 more)

### Community 85 - "translation_picker_sheet.dart"
Cohesion: 0.05
Nodes (34): ReadingLayout, _activeTab, AppearanceSettingsSheet, _AppearanceSettingsSheetState, AppearanceTab, build, createState, icon (+26 more)

### Community 86 - "List"
Cohesion: 0.06
Nodes (29): kBibleBookNames, AiJournalService, aiJournalServiceProvider, analyzeEntry, emotionLabel, emotions, _emotionVerses, JournalReflectionResult (+21 more)

### Community 87 - "bouncy_entrance.dart"
Cohesion: 0.10
Nodes (18): animateIn, BouncyEntrance, _BouncyEntranceState, build, child, _controller, createState, delay (+10 more)

### Community 88 - "build_bible_db.dart"
Cohesion: 0.10
Nodes (20): apiTranslations, buf, client, dbFile, dbPath, exitCode, _fetchJson, kjvCount (+12 more)

### Community 89 - "AppDelegate"
Cohesion: 0.11
Nodes (6): Flutter, AppDelegate, SceneDelegate, RunnerTests, UIKit, XCTest

### Community 90 - "json"
Cohesion: 0.19
Nodes (8): main(), book_names(), main(), catalog_ids(), find(), get_json(), hashed_downloads(), verify()

### Community 91 - "abbreviation"
Cohesion: 0.51
Nodes (19): meta, meta, meta, meta, abbreviation, is_complete, is_downloaded, language_code (+11 more)

### Community 92 - "crossed_swords_icon.dart"
Cohesion: 0.11
Nodes (17): build, color, _controller, createState, CrossedSwordsIcon, _CrossedSwordsIconState, didChangeDependencies, dispose (+9 more)

### Community 93 - "bible_provider.dart"
Cohesion: 0.11
Nodes (16): BibleNotifier, BibleState, book, bookNumber, books, build, chapter, ChapterKey (+8 more)

### Community 94 - "notes_list_screen.dart"
Cohesion: 0.06
Nodes (29): AppLocaleNotifier, _rescheduleNotifications, remindersProvider, PaperlikeTransform, contentController, createState, dispose, editingId (+21 more)

### Community 95 - "goldens_test.dart"
Cohesion: 0.08
Nodes (21): main, prefs, _pump, pumpWidget, _screens, _themes, main, _noop (+13 more)

### Community 96 - "bookmark_model.dart"
Cohesion: 0.13
Nodes (13): BookmarkData, BookmarkFolder, BookmarkNode, createdAt, folderId, folders, fromJson, id (+5 more)

### Community 97 - "Privacy Policy"
Cohesion: 0.11
Nodes (17): App integrity checks, Changes to this policy, Children, Contact, Crash reports, Deleting your account, Downloading content, How long we keep data (+9 more)

### Community 98 - "package.json"
Cohesion: 0.12
Nodes (12): description, devDependencies, firebase, @firebase/rules-unit-testing, firebase-tools, name, private, scripts (+4 more)

### Community 99 - "study_layout_provider.dart"
Cohesion: 0.11
Nodes (18): applyPreset, build, CardSize, CardSpan, defaultLayoutV2, expanded, fromJson, id (+10 more)

### Community 100 - "bible_stories_screen.dart"
Cohesion: 0.09
Nodes (19): _bookLabel, createState, DevotionalAttribution, dispose, _FilterPill, _filterToggleButton, label, onClearFilters (+11 more)

### Community 101 - "build_content.py"
Cohesion: 0.28
Nodes (11): build_core(), build_pack(), check_only(), count(), main(), manifest_entry(), mb(), quick_check() (+3 more)

### Community 102 - "auth_provider.dart"
Cohesion: 0.12
Nodes (9): _account, AuthActions, deleteAccount, ref, _rememberSignIn, _setSignedOutByUser, signInWithApple, signInWithGoogle (+1 more)

### Community 103 - "study_greetings_test.dart"
Cohesion: 0.12
Nodes (10): l10n, L10nContext, DesignTokensContext, at, _cheer, _en, _evening, _grace (+2 more)

### Community 104 - "day_complete_celebration.dart"
Cohesion: 0.12
Nodes (12): build, _confettiController, _controller, createState, day, DayCompleteCelebration, _DayCompleteCelebrationState, dispose (+4 more)

### Community 105 - "study_greetings.dart"
Cohesion: 0.12
Nodes (16): _dailyGreetings, day, dayIndex, _encouragementGreetings, _eveningGreetings, _graceGreetings, greetingEyebrow, greetingEyebrowNight (+8 more)

### Community 106 - "Pericope Dataset — Whole-System Audit Report"
Cohesion: 0.12
Nodes (15): 1. All 66 Books Present, 2. Global Coverage Against Source Data, 3. Book-Name Spelling Consistency, 4. Global Totals, 5. No Cross-File / Book-Boundary Overlaps, 6. Chapter-Title vs. Pericope Conflict Analysis, Audit Summary, `bible.db` vs `kjvbible.json` Discrepancy Check (+7 more)

### Community 107 - "pericope_entry.dart"
Cohesion: 0.12
Nodes (15): book, buildId, confidence, endChapter, endVerse, fromJson, id, isPlanBreak (+7 more)

### Community 108 - "wotd_provider.dart"
Cohesion: 0.08
Nodes (18): allWords, dayIndex, def, defs, headword, index, normalized, now (+10 more)

### Community 109 - "state_views.dart"
Cohesion: 0.12
Nodes (14): actionLabel, build, createState, EmptyState, error, ErrorState, _ErrorStateState, icon (+6 more)

### Community 110 - "animated_segmented_tile.dart"
Cohesion: 0.13
Nodes (13): AnimatedSegmentedTile, build, createState, _isPressed, isSelected, onChanged, option, options (+5 more)

### Community 111 - "streak_provider.dart"
Cohesion: 0.15
Nodes (11): build, _calculateState, consecutiveDays, count, distinctDaysThisYear, _formatDate, markAppOpenedToday, markReadToday (+3 more)

### Community 112 - "read_location_provider.dart"
Cohesion: 0.09
Nodes (19): currentIndex, hasSelection, isManualHidden, isRead, isScrollHidden, true, bookAbbrev, bookName (+11 more)

### Community 113 - "State"
Cohesion: 0.23
Nodes (10): CastingLotsDialog, _CastingLotsDialogState, PrivacyPolicyScreen, _PrivacyPolicyScreenState, _ToastOverlay, _ToastOverlayState, LibraryCalendarRail, LibraryCalendarRailState (+2 more)

### Community 114 - "curated_plans.dart"
Cohesion: 0.15
Nodes (12): attribution, availablePlans, badge, category, dailyCommitment, description, durationDays, id (+4 more)

### Community 115 - "shared_app_bar.dart"
Cohesion: 0.15
Nodes (10): actions, automaticallyImplyLeading, backgroundColor, build, elevation, leading, leadingWidth, preferredSize (+2 more)

### Community 116 - "os"
Cohesion: 0.23
Nodes (6): db_text_mb(), main(), mb(), fetch(), main(), main()

### Community 117 - "translation_downloader_test.dart"
Cohesion: 0.17
Nodes (7): main, _fixture, live, liveOsis, main, osisID, type

### Community 119 - "translation_model.dart"
Cohesion: 0.17
Nodes (11): abbreviation, fromMap, isComplete, isDownloaded, languageCode, languageName, license, toMap (+3 more)

### Community 120 - "let_read_test.dart"
Cohesion: 0.17
Nodes (6): main, build, _en, main, s, VerseOfDayStub

### Community 121 - "surface_style_provider.dart"
Cohesion: 0.13
Nodes (13): build, EarthHeavenStyle, EarthHeavenStyleNotifier, eh, _loadState, _migrationKey, resolveEarthSurface, setStyle (+5 more)

### Community 123 - "Color"
Cohesion: 0.20
Nodes (8): copyWith, lerp, readingAccent, readingBorder, readingInk, readingInkMuted, readingPaper, readingSurface

### Community 124 - "most_read_provider.dart"
Cohesion: 0.13
Nodes (12): bookAbbrev, bookName, build, chapter, fromKey, incrementVisit, key, MostReadItem (+4 more)

### Community 125 - "Phase 6 device test checklist"
Cohesion: 0.20
Nodes (9): 0. Get the latest build onto your phone, 1. First launch (onboarding), 2. Languages, 3. Themes, 4. Accessibility, 5. Consistency, 6. Sign-in and sync, Phase 6 device test checklist (+1 more)

### Community 126 - "Content Licenses Register"
Cohesion: 0.20
Nodes (9): Action items (resolve before any store release), App icon and other images, Commentary (`assets/commentary/commentary.json`, 4,724 entries), Content Licenses Register, Devotional (Bible Stories), Fonts (`assets/fonts/`), Scripture texts, Software packages (+1 more)

### Community 127 - "sys"
Cohesion: 0.27
Nodes (3): build_html(), build_md(), main()

### Community 128 - "AppLocalizations"
Cohesion: 0.20
Nodes (9): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, AppLocalizationsFr, AppLocalizationsIt, of, AppLocalizationsRo, AppLocalizationsSw (+1 more)

### Community 129 - "build"
Cohesion: 0.31
Nodes (9): devotionalBooksProvider, devotionalFilterProvider, devotionalStoriesProvider, filteredDevotionalStoriesProvider, BibleStoriesScreen, _BibleStoriesScreenState, build, _EmptyStories (+1 more)

### Community 130 - "action_icon.dart"
Cohesion: 0.15
Nodes (12): ActionIcon, _ActionIconState, build, color, createState, _handleTap, icon, onLongPress (+4 more)

### Community 131 - "locale_reschedule_test.dart"
Cohesion: 0.20
Nodes (6): calls, initialize, main, scheduleDailyReminder, schedulePrayerReminder, syncReadingPlanReminder

### Community 132 - "upload_packs"
Cohesion: 0.22
Nodes (8): core, bytes, file, sha256, sizeMB, translations, packs, upload_packs

### Community 133 - "Mandatory Self-Checks"
Cohesion: 0.25
Nodes (7): 1. Coverage, 2. Anchor Check, 3. Book Completeness, 4. Confidence Summary, Dataset, Mandatory Self-Checks, The Epistles & Revelation Pericope Draft (Chunk 6/6)

### Community 134 - "Mandatory Self-Checks"
Cohesion: 0.25
Nodes (7): 1. Coverage, 2. Anchor Check, 3. Passion Granularity Confirmation, 4. Confidence Summary, Dataset, Gospels & Acts Pericope Draft (Chunk 5/6), Mandatory Self-Checks

### Community 135 - "Mandatory Self-Checks"
Cohesion: 0.25
Nodes (7): 1. Coverage, 2. Anchor Check, 3. Density Confirmation, 4. Confidence Summary, Dataset, Mandatory Self-Checks, The Prophets Pericope Draft (Chunk 4/6)

### Community 136 - "cross_references_provider.dart"
Cohesion: 0.25
Nodes (6): CrossRef, CrossRefKey, toBookNumber, toChapter, toVerse, votes

### Community 137 - "verse_linker.dart"
Cohesion: 0.25
Nodes (4): _books, parse, _regex, VerseLinker

### Community 138 - "deu_l12"
Cohesion: 0.29
Nodes (7): bytes, file, id, sha256, sizeMB, verses, deu_l12

### Community 139 - "fra_lsg"
Cohesion: 0.29
Nodes (7): bytes, file, id, sha256, sizeMB, verses, fra_lsg

### Community 140 - "ita_dio"
Cohesion: 0.29
Nodes (7): bytes, file, id, sha256, sizeMB, verses, ita_dio

### Community 141 - "kjv_strongs"
Cohesion: 0.29
Nodes (7): bytes, file, id, sha256, sizeMB, verses, kjv_strongs

### Community 142 - "nld_"
Cohesion: 0.29
Nodes (7): bytes, file, id, sha256, sizeMB, verses, nld_

### Community 143 - "ron_btf"
Cohesion: 0.29
Nodes (7): ron_btf, bytes, file, id, sha256, sizeMB, verses

### Community 144 - "swh_ulb"
Cohesion: 0.29
Nodes (7): swh_ulb, bytes, file, id, sha256, sizeMB, verses

### Community 145 - "tgl_ulb"
Cohesion: 0.29
Nodes (7): tgl_ulb, bytes, file, id, sha256, sizeMB, verses

### Community 146 - "por_blj"
Cohesion: 0.29
Nodes (7): bytes, file, id, sha256, sizeMB, verses, por_blj

### Community 147 - "spa_r09"
Cohesion: 0.29
Nodes (7): bytes, file, id, sha256, sizeMB, verses, spa_r09

### Community 148 - "web"
Cohesion: 0.29
Nodes (7): web, bytes, file, id, sha256, sizeMB, verses

### Community 149 - "Android: Google sign-in setup and release checks"
Cohesion: 0.29
Nodes (6): 1. Collect the fingerprints, 2. Firebase console, 3. Build and ship to the internal track, 4. Run the checks, 5. App Check, before enforcing it, Android: Google sign-in setup and release checks

### Community 150 - "Heading Merge Proposal: Chapter Titles & Pericopes"
Cohesion: 0.29
Nodes (6): 1. Collision Analysis (Representative Sample), 2. Non-Collision Chapters, 3. The Unified Rendering Rule (Reader & Study Page), 4. Chapter Titles → TOC/Navigation Preservation, 5. Summary Counts (Extrapolated across 969 collisions), Heading Merge Proposal: Chapter Titles & Pericopes

### Community 151 - "Mandatory Self-Checks"
Cohesion: 0.29
Nodes (6): 1. Coverage, 2. Anchor Check, 3. Confidence Summary, Dataset, Historical Books Pericope Draft (Chunk 2/6), Mandatory Self-Checks

### Community 152 - "Mandatory Self-Checks"
Cohesion: 0.29
Nodes (6): 1. Coverage, 2. Anchor Check, 3. Confidence Summary, Dataset, Mandatory Self-Checks, Pentateuch Pericope Draft (Chunk 1/6)

### Community 153 - "Mandatory Self-Checks"
Cohesion: 0.29
Nodes (6): 1. Coverage, 2. Anchor Check, 3. Confidence Summary, Dataset, Mandatory Self-Checks, Poetry & Wisdom Pericope Draft (Chunk 3/6)

### Community 154 - "Shared Accounts: The Blessed Bible + Blessed Arcade"
Cohesion: 0.29
Nodes (6): Approach, Decisions (2026-10-10), Revised order, Shared Accounts: The Blessed Bible + Blessed Arcade, Steps, Where things stand (2026-10-10)

### Community 155 - "share_card_test.dart"
Cohesion: 0.29
Nodes (4): host, long, main, short

### Community 156 - "pull_request_template.md"
Cohesion: 0.33
Nodes (5): Checklist, How it was tested, Screenshots, What changed, Why

### Community 157 - "let_read.dart"
Cohesion: 0.18
Nodes (9): dayOfYear, daysInYear, daysRemaining, index, label, remainingLabel, start, verseForDay (+1 more)

### Community 158 - "credits.dart"
Cohesion: 0.18
Nodes (10): CreditItem, CreditSection, creditSections, detail, _fontCopyrights, heading, items, note (+2 more)

### Community 174 - "journal_entry.dart"
Cohesion: 0.18
Nodes (9): content, date, detectedEmotions, fromJson, id, JournalEntry, prayerPoints, recommendedVerses (+1 more)

### Community 175 - "notificationServiceProvider"
Cohesion: 0.18
Nodes (11): notificationServiceProvider, resyncPlanReminders, _syncReminder, build, RemindersNotifier, RemindersState, rescheduleAll, _syncDailySchedule (+3 more)

### Community 176 - "search_engine_test.dart"
Cohesion: 0.18
Nodes (5): main, corpus, index, main, testEngine

### Community 177 - "content_sync_service.dart"
Cohesion: 0.20
Nodes (8): _asMap, cacheFileName, collectionName, ContentSyncService, _encodeJsonMap, loadLocalCache, _parseJsonMap, syncDeltas

### Community 178 - "concordance_terms.dart"
Cohesion: 0.25
Nodes (7): category, ConcordanceTerm, countKjv, definition, kConcordanceTerms, keyVerse, word

## Knowledge Gaps
- **10294 isolated node(s):** `firebase-tools`, `XCTest`, `WidgetKit`, `SwiftUI`, `.body` (+10289 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 10836 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_` connect `_` to `verse_link_text.dart`, `textured_glass_container.dart`, `../../l10n/l10n.dart`, `preferencesProvider`, `StatelessWidget`, `wotd_provider.dart`, `dart:convert`, `package:flutter_riverpod/flutter_riverpod.dart`, `onboarding_screen.dart`, `List`, `dictionary_underline_test.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **What connects `firebase-tools`, `XCTest`, `WidgetKit` to the rest of the system?**
  _10294 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0018331805682859762 - nodes in this community are weakly interconnected._
- **Why does `preferencesProvider` connect `preferencesProvider` to `preferences_service.dart`, `themeProvider`, `search_screen.dart`, `reading_plan_detail_v2_screen.dart`, `reading_plan_provider.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `study_screen_v2.dart`, `onboarding_screen.dart`, `search_provider.dart`, `account_menu.dart`, `reminders_provider.dart`, `bible_sync.dart`, `commentary_view.dart`, `notificationServiceProvider`, `_`, `devotional_provider.dart`, `commentary_provider.dart`, `Notifier`, `List`, `notes_list_screen.dart`, `bookmark_model.dart`, `study_layout_provider.dart`, `auth_provider.dart`, `streak_provider.dart`, `read_location_provider.dart`, `most_read_provider.dart`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0018570102135561746 - nodes in this community are weakly interconnected._
- **Why does `readingPlanProvider` connect `study_screen_v2.dart` to `themeProvider`, `reading_plan_detail_v2_screen.dart`, `reading_plan_provider.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `account_menu.dart`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **Should `app_localizations_fr.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0018587360594795538 - nodes in this community are weakly interconnected._