# Graph Report - Blessed Bible  (2026-11-05)

## Corpus Check
- 427 files · ~3,950,797 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 138 file(s) not represented in the graph (top: .ttf 48, .xml 32, .db 14)

## Summary
- 16147 nodes · 19389 edges · 191 communities (174 shown, 17 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.95)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1ef3f0c7`
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
- readSettingsProvider
- State
- preferencesProvider
- commentary_library_v2_screen.dart
- app_colors.dart
- app_localizations_es.dart
- search_engine.dart
- reading_plan_detail_v2_screen.dart
- reading_plan_provider.dart
- VoidCallback
- custom_plan_builder_v2_screen.dart
- dynamic_toast.dart
- study_screen_v2.dart
- locale_provider.dart
- read_screen.dart
- theme_picker_sheet.dart
- app_localizations_pt.dart
- search_provider.dart
- plan_flow.dart
- package:flutter_riverpod/flutter_riverpod.dart
- main_nav_screen.dart
- study_reader_screen.dart
- plan_generator.dart
- account_menu.dart
- design_tokens.dart
- read_settings_provider.dart
- your_space_screen.dart
- Contributing: Project Rules & Workflow
- bible_database_service.dart
- [0.0.4] - 2026-10-22
- translation_pack_store.dart
- bible_sync.dart
- StatelessWidget
- resolvedThemeProvider
- home_provider.dart
- Changelog
- plan_spec.dart
- dictionary_provider.dart
- dart:convert
- generate_reading_plan.dart
- _
- notification_service.dart
- devotional_provider.dart
- BlessedBibleWidgets.swift
- home_data.dart
- concordance_screen.dart
- book_chapter_selector_sheet.dart
- account_flows.dart
- ../../l10n/l10n.dart
- fetch_dore_art.py
- search_settings_provider.dart
- typography_provider.dart
- theme_provider.dart
- translation_downloader.dart
- Production Readiness: Status and Plan
- Targeted UX/UI Fixes
- verse_link_text.dart
- reading_plan.dart
- ConsumerWidget
- app_theme.dart
- textured_glass_container.dart
- 📖 Blessed Bible (The Blessed Bible)
- pace_remap_service.dart
- plan_assets_test.dart
- ============================================================
- bible_story_reader_screen.dart
- commentary_entry.dart
- devotional_service.dart
- bible_nav_settings_provider.dart
- pericopes_provider.dart
- commentary_provider.dart
- bibleProvider
- Color
- notesProvider
- build_topical.py
- devotional_story.dart
- share_content.dart
- ✨ Flagship Features
- ai_journal_service.dart
- widget_settings_provider.dart
- build_bible_db.dart
- AppDelegate
- json
- abbreviation
- auth_provider.dart
- isolate_parsers.dart
- journey_map_screen.dart
- story_of_the_day_provider.dart
- notes_provider.dart
- Privacy Policy
- package.json
- share_sheet.dart
- jfb_commentary_data_test.dart
- build_content.py
- story_marks_test.dart
- study_greetings_test.dart
- plan_generator.dart
- study_greetings.dart
- Pericope Dataset — Whole-System Audit Report
- pericope_entry.dart
- wotd_provider.dart
- commentary_prose.dart
- build_jfb_commentary.py
- streak_provider.dart
- read_location_provider.dart
- journal_entry.dart
- curated_plans.dart
- shared_app_bar.dart
- os
- translation_downloader_test.dart
- commentary_hub_screen.dart
- translation_model.dart
- passage.dart
- static const
- tool/
- List
- devotionalFavoritesProvider
- Phase 6 device test checklist
- Content Licenses Register
- sys
- AppLocalizations
- animated_segmented_tile.dart
- settings_screen.dart
- ../../theme/design_tokens.dart
- upload_packs
- Mandatory Self-Checks
- Mandatory Self-Checks
- Mandatory Self-Checks
- language_picker.dart
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
- share_sheet_test.dart
- pull_request_template.md
- [0.0.6] - 2026-10-26
- ReadSettingsNotifier
- commentary_work.dart
- MainActivity.kt
- Applied Fixes
- PHASE_6_PLAN.md
- firestore-tests/README.md
- LaunchImage.imageset/README.md
- crossed_swords_icon.dart
- bible_provider.dart
- share_pdf_service.dart
- main_nav_screen.dart
- Color
- dictionary_search_provider.dart
- content_sync_service.dart
- span_marks.dart
- strongs_provider.dart
- Notifier
- navProvider
- clean_commentary.py
- share_document_preview.dart
- prose.dart
- StreakWidgetProvider.kt
- localized_book_names.dart
- package:flutter/foundation.dart

## God Nodes (most connected - your core abstractions)
1. `preferencesProvider` - 136 edges
2. `_` - 55 edges
3. `resolvedThemeProvider` - 41 edges
4. `readSettingsProvider` - 40 edges
5. `bibleProvider` - 37 edges
6. `_ReadScreenState` - 31 edges
7. `readingPlanProvider` - 30 edges
8. `activeTranslationProvider` - 30 edges
9. `============================================================` - 26 edges
10. `typographyProvider` - 25 edges

## Surprising Connections (you probably didn't know these)
- `4. Work breakdown (one PR each)` --references--> `merge()`  [INFERRED]
  docs/PHASE_5B_SYNC_PLAN.md → tool/build_topical.py
- `_FakeCommentary` --inherits--> `CommentaryNotifier`  [EXTRACTED]
  test/commentary_hub_test.dart → lib/state/commentary_provider.dart
- `_FakeCommentary` --inherits--> `CommentaryNotifier`  [EXTRACTED]
  test/commentary_library_test.dart → lib/state/commentary_provider.dart
- `_FakeCommentary` --inherits--> `CommentaryNotifier`  [EXTRACTED]
  test/votd_pool_test.dart → lib/state/commentary_provider.dart
- `_FixedAutoTheme` --inherits--> `AutoThemeInputsNotifier`  [EXTRACTED]
  test/goldens_test.dart → lib/state/theme_provider.dart

## Import Cycles
- None detected.

## Communities (191 total, 17 thin omitted)

### Community 0 - "app_localizations.dart"
Cohesion: 0.00
Nodes (1206): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1198 more)

### Community 1 - "app_localizations_en.dart"
Cohesion: 0.00
Nodes (1198): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1190 more)

### Community 2 - "app_localizations_fr.dart"
Cohesion: 0.00
Nodes (1198): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1190 more)

### Community 3 - "app_localizations_it.dart"
Cohesion: 0.00
Nodes (1198): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1190 more)

### Community 4 - "app_localizations_ro.dart"
Cohesion: 0.00
Nodes (1198): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1190 more)

### Community 5 - "app_localizations_sw.dart"
Cohesion: 0.00
Nodes (1198): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1190 more)

### Community 6 - "app_localizations_tl.dart"
Cohesion: 0.00
Nodes (1198): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1190 more)

### Community 7 - "preferences_service.dart"
Cohesion: 0.01
Nodes (153): _activePlanIdsKey, _activeTranslationKey, _appUsageDatesKey, _bentoPresetKey, _bookmarksKey, _bookmarksV2Key, _chapterPositionsKey, clearAllUserData (+145 more)

### Community 8 - "readSettingsProvider"
Cohesion: 0.07
Nodes (44): wordCountServiceProvider, translationChapterProvider, crossReferencesProvider, devotionalServiceProvider, storyShowPassageProvider, chapterUnderlineMapProvider, hintsProvider, readSettingsProvider (+36 more)

### Community 9 - "State"
Cohesion: 0.13
Nodes (20): CastingLotsDialog, _CastingLotsDialogState, _StaggeredTabStack, _StaggeredTabStackState, PrivacyPolicyScreen, _PrivacyPolicyScreenState, _ResetDeviceSheet, _ResetDeviceSheetState (+12 more)

### Community 10 - "preferencesProvider"
Cohesion: 0.03
Nodes (78): preferencesProvider, BookmarkData, BackupService, exportData, importData, notificationServiceProvider, build, hasSeen (+70 more)

### Community 11 - "commentary_library_v2_screen.dart"
Cohesion: 0.04
Nodes (47): book, _BookIndex, _BookRow, _browser, chapter, chapters, _ChapterTile, createState (+39 more)

### Community 12 - "app_colors.dart"
Cohesion: 0.03
Nodes (78): AppColors, darkBackground, darkBorder, darkSurface, darkTextPrimary, darkTextSecondary, dawnAccent, dawnBackground (+70 more)

### Community 13 - "app_localizations_es.dart"
Cohesion: 0.00
Nodes (1198): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1190 more)

### Community 14 - "search_engine.dart"
Cohesion: 0.03
Nodes (66): activeTranslation, addNoteTokens, addTokens, args, baseIndexFuture, baseSearchIndexProvider, bibleBooks, bibleState (+58 more)

### Community 15 - "reading_plan_detail_v2_screen.dart"
Cohesion: 0.02
Nodes (83): createState, DictionaryV2Screen, _DictionaryV2ScreenState, onOpen, _openEntry, _query, saved, _savedOnly (+75 more)

### Community 16 - "reading_plan_provider.dart"
Cohesion: 0.03
Nodes (73): addPlan, appWeekday, bookName, build, _canonCache, _canonIndex, chapterNum, completedAtomIds (+65 more)

### Community 17 - "VoidCallback"
Cohesion: 0.03
Nodes (70): CreditItem, CreditSection, creditSections, detail, _fontCopyrights, heading, items, note (+62 more)

### Community 18 - "custom_plan_builder_v2_screen.dart"
Cohesion: 0.04
Nodes (52): _autoName, build, createState, _days, _daysController, dispose, draft, _drafts (+44 more)

### Community 19 - "dynamic_toast.dart"
Cohesion: 0.09
Nodes (22): actionLabel, build, _controller, createState, didChangeDependencies, _dismiss, _dismissing, dispose (+14 more)

### Community 20 - "study_screen_v2.dart"
Cohesion: 0.06
Nodes (25): _ConcordanceCard, count, createState, cta, eyebrow, full, icon, id (+17 more)

### Community 21 - "locale_provider.dart"
Cohesion: 0.07
Nodes (20): GallerySaveResult, GalleryService, savePng, AppLanguage, appLanguageFor, appLanguages, AppLocaleNotifier, bibleId (+12 more)

### Community 22 - "read_screen.dart"
Cohesion: 0.03
Nodes (62): AppTypography, getTheme, _animateToPage, _buildNormalVerse, _buildReadingLayoutVerse, _buildSideButton, _buildThemedPill, clear (+54 more)

### Community 23 - "theme_picker_sheet.dart"
Cohesion: 0.04
Nodes (62): earthHeavenStyleProvider, autoThemeInputsProvider, themeProvider, _ComfortPage, build, color, controller, createState (+54 more)

### Community 24 - "app_localizations_pt.dart"
Cohesion: 0.00
Nodes (1198): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1190 more)

### Community 25 - "search_provider.dart"
Cohesion: 0.06
Nodes (32): searchEngineProvider, addRecentPlace, _addRecentQuery, build, clearRecentQueries, copyWith, _debounce, exactMatch (+24 more)

### Community 26 - "plan_flow.dart"
Cohesion: 0.06
Nodes (29): accent, build, caption, child, compact, current, day, footer (+21 more)

### Community 27 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.01
Nodes (132): PreferencesService, bbeSubstitutionsProvider, build, CreditsScreen, _buildInfoPage, packageInfoProvider, main, prefs (+124 more)

### Community 28 - "main_nav_screen.dart"
Cohesion: 0.03
Nodes (54): WidgetTextMode, addAllowedPointer, createState, didChangeDependencies, dispose, _dragStartY, filled, handleEvent (+46 more)

### Community 29 - "study_reader_screen.dart"
Cohesion: 0.04
Nodes (51): book, bookAbbrev, bookName, chapter, chapterNum, _clearSelection, createState, _current (+43 more)

### Community 30 - "plan_generator.dart"
Cohesion: 0.04
Nodes (39): PaceRemapService, PlanGenerator, allPericopes, generator, genesisTrack, genExodusTrack, main, remapService (+31 more)

### Community 31 - "account_menu.dart"
Cohesion: 0.04
Nodes (49): displayNameProvider, syncControllerProvider, _save, _AccountButtons, build, AccountAvatar, _AccountHeroCard, _AccountHeroCardState (+41 more)

### Community 32 - "design_tokens.dart"
Cohesion: 0.04
Nodes (46): all, body, bodyLarge, caption, card, copyWith, danger, display (+38 more)

### Community 33 - "read_settings_provider.dart"
Cohesion: 0.04
Nodes (46): activeHighlightColorIndex, _activeHighlightColorIndexKey, build, _commentaryStyleKey, copyWith, cycleHighlightColor, defaultStartTab, dictionaryUnderlinesEnabled (+38 more)

### Community 34 - "your_space_screen.dart"
Cohesion: 0.04
Nodes (47): abbrevUpper, bookAbbrev, bookmarkData, _BookmarkViewType, bookName, bookNumber, _buildRealVerseCard, chapter (+39 more)

### Community 35 - "Contributing: Project Rules & Workflow"
Cohesion: 0.20
Nodes (10): 1. Always Verify Build Before Done, 2. Commit After Every Green Build, Backup & Restore Points (Mandatory), Build Verification (Mandatory), Contributing: Project Rules & Workflow, Do Not Block the Task Queue, Layout & Symmetry, Riverpod / State (+2 more)

### Community 36 - "bible_database_service.dart"
Cohesion: 0.04
Nodes (42): BibleDatabaseService, bibleDbService, _clearRepairAttempts, contentBytesUsed, contentVersion, _contentVersionKey, _copyAssetDb, _db (+34 more)

### Community 37 - "[0.0.4] - 2026-10-22"
Cohesion: 0.18
Nodes (11): [0.0.4] - 2026-10-22, Accounts, Accounts & Cloud Sync, Added, Changed, Fixed, Infrastructure & Hygiene, Onboarding & Themes (+3 more)

### Community 38 - "translation_pack_store.dart"
Cohesion: 0.04
Nodes (42): abbreviation, bundledPackIds, _catalogFile, _copyAssetPack, coreIds, deletedPackIds, _deletedPacksKey, deletePack (+34 more)

### Community 39 - "bible_sync.dart"
Cohesion: 0.05
Nodes (42): ActivePlansSync, afterSignIn, _applyingRemote, BookmarksSync, _collections, CustomPlansSync, debounce, deviceId (+34 more)

### Community 40 - "StatelessWidget"
Cohesion: 0.02
Nodes (103): _accent, _amber, _bg, body, child, _ChoiceTile, _ClassicThemeButton, color (+95 more)

### Community 41 - "resolvedThemeProvider"
Cohesion: 0.07
Nodes (47): build, _TheBlessedBibleAppState, widgetUpdateServiceProvider, commentaryBookmarksProvider, commentaryProvider, onboardingCompleteProvider, surfaceStyleProvider, resolvedThemeProvider (+39 more)

### Community 42 - "home_provider.dart"
Cohesion: 0.05
Nodes (40): commentaryForChapterProvider, bibleState, booksByName, buffer, build, byReference, commentaries, commentaryState (+32 more)

### Community 43 - "Changelog"
Cohesion: 0.20
Nodes (10): [0.0.5] - 2026-10-22, 1.0.2+9, Account, Changelog, 📥 Download & Install, Home Screen & Daily Content, Performance, prerelease-1 (+2 more)

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
Nodes (37): _, align, artworkPath, aspectRatio, _Backdrop, body, build, commentary (+29 more)

### Community 49 - "notification_service.dart"
Cohesion: 0.09
Nodes (17): cancelDailyReminder, cancelPrayerReminder, cancelReminder, cancelSabbathReminders, cancelWeeklyReminder, _flutterLocalNotificationsPlugin, initialize, _initialized (+9 more)

### Community 50 - "devotional_provider.dart"
Cohesion: 0.04
Nodes (50): add, all, bookPrefix, build, colorIndex, copyWith, DevotionalFilterNotifier, DevotionalFilterState (+42 more)

### Community 51 - "BlessedBibleWidgets.swift"
Cohesion: 0.09
Nodes (17): BlessedBibleWidgets, .body, Color, Provider, SimpleEntry, StreakWidget, .body, StreakWidgetEntryView (+9 more)

### Community 52 - "home_data.dart"
Cohesion: 0.07
Nodes (26): activeStudy, author, chaptersRemaining, commentarySnippet, content, count, date, fromJson (+18 more)

### Community 53 - "concordance_screen.dart"
Cohesion: 0.02
Nodes (89): ReadingLayout, bookNumber, build, chapter, _clearSearch, _ConcordanceHit, _controller, createState (+81 more)

### Community 54 - "book_chapter_selector_sheet.dart"
Cohesion: 0.07
Nodes (39): bibleNavSettingsProvider, pericopesProvider, _buildNavigationPage, book, BookChapterSelectorSheet, _BookChapterSelectorSheetState, books, build (+31 more)

### Community 55 - "account_flows.dart"
Cohesion: 0.05
Nodes (37): actions, build, c, cause, children, choice, _closeMenu, _CloudDeleteFailed (+29 more)

### Community 56 - "../../l10n/l10n.dart"
Cohesion: 0.02
Nodes (78): currentVersion, clearAllUserData, container, customIds, deleteBibleCloudData, packCleanupTimeout, prefsSvc, remove (+70 more)

### Community 57 - "fetch_dore_art.py"
Cohesion: 0.16
Nodes (15): die(), ensure_dirs(), http_get(), log(), save_json(), supabase_query(), clean_key_verse(), main() (+7 more)

### Community 58 - "search_settings_provider.dart"
Cohesion: 0.06
Nodes (32): _autoOpenKey, autoOpenSingleSearchResult, build, copyWith, _defaultCommKey, _defaultDictKey, _defaultNotesKey, _defaultNtKey (+24 more)

### Community 59 - "typography_provider.dart"
Cohesion: 0.07
Nodes (28): build, copyWith, fontFamily, _fontFamilyKey, fontSize, _fontSizeKey, fontStyle, fontWeight (+20 more)

### Community 60 - "theme_provider.dart"
Cohesion: 0.05
Nodes (34): AppThemeMode, AppThemeModeExtension, AutoTheme, AutoThemeInputs, AutoThemeInputsNotifier, brightness, build, darkCycle (+26 more)

### Community 61 - "translation_downloader.dart"
Cohesion: 0.07
Nodes (20): _clean, downloadableTranslations, downloadAndInstall, _fetchBytes, _helloao, _helloaoApi, info, _maxRetries (+12 more)

### Community 62 - "Production Readiness: Status and Plan"
Cohesion: 0.07
Nodes (29): 10. Bible essentials, 11. Data, sync, privacy, 12. Accessibility and localization, 13. Performance, 14. Licensing, 15. Testing, 16. Release engineering, 17. Store compliance (+21 more)

### Community 63 - "Targeted UX/UI Fixes"
Cohesion: 0.25
Nodes (8): 1. Navigation Modal Performance (Critical), 2. Navigation Flow Logic (Friction), 3. Header Collision (Read Tab), 4. Commentary Bottom Sheet Consistency, Diagnostics & Baseline, Overnight UI/UX pass (2026-07-24), Targeted UX/UI Fixes, Verification

### Community 64 - "verse_link_text.dart"
Cohesion: 0.05
Nodes (34): BoldSegment, boldStyle, build, _buildSpans, createState, defaultStyle, dictionaryWordStyle, didUpdateWidget (+26 more)

### Community 65 - "reading_plan.dart"
Cohesion: 0.07
Nodes (27): book, cadence, clampReason, copyWith, dayNumber, days, endChapter, endVerse (+19 more)

### Community 66 - "ConsumerWidget"
Cohesion: 0.10
Nodes (29): _rescheduleNotifications, activePlanIdsProvider, readingPlanProvider, remindersProvider, storyOfTheDayProvider, CommentaryVolumeScreen, _EntryCard, StoryOfTheDaySection (+21 more)

### Community 67 - "app_theme.dart"
Cohesion: 0.07
Nodes (23): accent, applyFreshPaperlike, applyPaperlike, AppTheme, background, customAccentTheme, darkTheme, dawnTheme (+15 more)

### Community 68 - "textured_glass_container.dart"
Cohesion: 0.06
Nodes (35): _JourneyPathPainter, _CrossedSwordsPainter, _ToastPainter, _GrainPainter, _RingPainter, baseColor, borderOpacity, borderRadius (+27 more)

### Community 69 - "📖 Blessed Bible (The Blessed Bible)"
Cohesion: 0.25
Nodes (8): 📖 Blessed Bible (The Blessed Bible), Clone and Run, Content Build Scripts, 🚀 Developer Setup, ⬇️ Download & Installation, 🔒 License, Prerequisites, 🛠️ Tech Stack & Architecture

### Community 70 - "pace_remap_service.dart"
Cohesion: 0.06
Nodes (27): absoluteVerseIndex, _addVerseRange, allPericopes, _buildCompletedVerseSet, buildCompletedVerseSetPublic, buildVerseSetFromAtomsPublic, _chapterOffset, _chapterOffsets (+19 more)

### Community 71 - "plan_assets_test.dart"
Cohesion: 0.08
Nodes (25): _assets, assetVerses, book, _bookAliases, c1, c2, c2s, canon (+17 more)

### Community 72 - "============================================================"
Cohesion: 0.08
Nodes (25): ============================================================, ============================================================, ============================================================, ============================================================, ============================================================, ============================================================, ============================================================, ============================================================ (+17 more)

### Community 73 - "bible_story_reader_screen.dart"
Cohesion: 0.03
Nodes (60): StoryMark, _bookLabel, createState, DevotionalAttribution, dispose, _FilterPill, _filterToggleButton, label (+52 more)

### Community 74 - "commentary_entry.dart"
Cohesion: 0.08
Nodes (21): author, book, category, chapter, CommentaryEntry, CommentaryScope, custom, dateAdded (+13 more)

### Community 75 - "devotional_service.dart"
Cohesion: 0.05
Nodes (35): _artByPrefix, _artCaptionBySlug, _artLoaded, _artMapAsset, assetPath, _bookAssetPrefix, _booksByPrefix, caption (+27 more)

### Community 76 - "bible_nav_settings_provider.dart"
Cohesion: 0.08
Nodes (24): _autoCloseKey, autoCloseOnFinalSelection, BibleNavSettingsNotifier, BibleNavSettingsState, build, copyWith, depth, _depthKey (+16 more)

### Community 77 - "pericopes_provider.dart"
Cohesion: 0.12
Nodes (12): build, data, getPericopesForChapter, _loadData, loadError, map, _parsePericopes, PericopesNotifier (+4 more)

### Community 78 - "commentary_provider.dart"
Cohesion: 0.07
Nodes (27): book, build, _cachedChapters, _cachedFormattedVerses, _cachedVersesWithCommentary, _cachedVersesWithDevotionals, _cachedVersesWithNotes, chapter (+19 more)

### Community 79 - "bibleProvider"
Cohesion: 0.10
Nodes (29): bibleProvider, bookmarkedWordsProvider, dictionaryDefinitionProvider, dictionarySearchProvider, mostReadProvider, _performSearch, searchStateProvider, searchSettingsProvider (+21 more)

### Community 81 - "notesProvider"
Cohesion: 0.13
Nodes (29): homeProvider, journalProvider, notesProvider, streakProvider, studyLayoutProvider, bookmarkDataProvider, bookmarksProvider, highlightsProvider (+21 more)

### Community 82 - "build_topical.py"
Cohesion: 0.13
Nodes (16): 1. Current state (audit, 2026-10-10), 2. What syncs, 3. Design, 4. Work breakdown (one PR each), 5. Device test script (5B.6), 6. Risks, Phase 5B: Google Sign-In, Sign-Out and Data Sync, build_plan() (+8 more)

### Community 83 - "devotional_story.dart"
Cohesion: 0.09
Nodes (21): book, copyWithEnriched, count, DevotionalBookInfo, DevotionalStory, fromJson, grouping, id (+13 more)

### Community 84 - "share_content.dart"
Cohesion: 0.05
Nodes (41): artworkPath, author, body, cleanShareText, commentary, copyWith, cut, date (+33 more)

### Community 85 - "✨ Flagship Features"
Cohesion: 0.18
Nodes (11): 🔍 Built-In Biblical Concordance, 📚 Commentary Shelf & Historicist Volumes, 📖 Distraction-Free Scripture Reading, 🎨 Dynamic Themes & Custom Typography, ✨ Flagship Features, 🌐 Full Multi-Language Localization, 🏷️ Personal Study Space & Enhanced Sharing, ☁️ Privacy-First & Cloud Sync (+3 more)

### Community 86 - "ai_journal_service.dart"
Cohesion: 0.18
Nodes (9): AiJournalService, analyzeEntry, emotionLabel, emotions, _emotionVerses, JournalReflectionResult, _keywords, prayerPoints (+1 more)

### Community 87 - "widget_settings_provider.dart"
Cohesion: 0.07
Nodes (26): appGroupId, _formatDate, _init, _l10n, _ref, service, streakWidgetName, syncAllWidgets (+18 more)

### Community 88 - "build_bible_db.dart"
Cohesion: 0.10
Nodes (20): apiTranslations, buf, client, dbFile, dbPath, exitCode, _fetchJson, kjvCount (+12 more)

### Community 89 - "AppDelegate"
Cohesion: 0.11
Nodes (6): Flutter, AppDelegate, SceneDelegate, RunnerTests, UIKit, XCTest

### Community 90 - "json"
Cohesion: 0.15
Nodes (12): main(), book_names(), main(), catalog_ids(), find(), get_json(), hashed_downloads(), verify() (+4 more)

### Community 91 - "abbreviation"
Cohesion: 0.51
Nodes (19): meta, meta, meta, meta, abbreviation, is_complete, is_downloaded, language_code (+11 more)

### Community 92 - "auth_provider.dart"
Cohesion: 0.07
Nodes (18): _account, AuthActions, authActionsProvider, deleteAccount, ref, _rememberSignIn, _setSignedOutByUser, signInWithApple (+10 more)

### Community 93 - "isolate_parsers.dart"
Cohesion: 0.07
Nodes (25): abbreviation, BibleBook, BibleChapter, BibleVerse, chapters, fromJson, isBookmarked, isHighlighted (+17 more)

### Community 94 - "journey_map_screen.dart"
Cohesion: 0.06
Nodes (28): ReadingPlanState, build, completedDays, createState, _currentWeek, dispose, _initialized, initState (+20 more)

### Community 95 - "story_of_the_day_provider.dart"
Cohesion: 0.05
Nodes (33): BookmarkFolder, BookmarkNode, createdAt, folderId, folders, fromJson, id, name (+25 more)

### Community 96 - "notes_provider.dart"
Cohesion: 0.10
Nodes (18): dayOfYear, daysInYear, daysRemaining, index, label, remainingLabel, start, verseForDay (+10 more)

### Community 97 - "Privacy Policy"
Cohesion: 0.11
Nodes (17): App integrity checks, Changes to this policy, Children, Contact, Crash reports, Deleting your account, Downloading content, How long we keep data (+9 more)

### Community 98 - "package.json"
Cohesion: 0.12
Nodes (12): description, devDependencies, firebase, @firebase/rules-unit-testing, firebase-tools, name, private, scripts (+4 more)

### Community 99 - "share_sheet.dart"
Cohesion: 0.05
Nodes (33): ShareCardBackdrop, shareCardStyleProvider, _backdrop, _boundaryKey, build, _buildImage, _buildPdf, _buildText (+25 more)

### Community 100 - "jfb_commentary_data_test.dart"
Cohesion: 0.17
Nodes (9): data, entries, label, main, textOf, entries, main, packFile (+1 more)

### Community 101 - "build_content.py"
Cohesion: 0.28
Nodes (11): build_core(), build_pack(), check_only(), count(), main(), manifest_entry(), mb(), quick_check() (+3 more)

### Community 102 - "story_marks_test.dart"
Cohesion: 0.20
Nodes (3): main, _book, main

### Community 103 - "study_greetings_test.dart"
Cohesion: 0.22
Nodes (7): at, _cheer, _en, _evening, _grace, main, _morning

### Community 104 - "plan_generator.dart"
Cohesion: 0.07
Nodes (27): _addPortion, allPericopes, book, _Chunk, _distributeTrack, endCh, endsOnChapter, endsOnPericope (+19 more)

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
Cohesion: 0.10
Nodes (17): allWords, dates, dayIndex, def, defs, headword, index, normalized (+9 more)

### Community 109 - "commentary_prose.dart"
Cohesion: 0.06
Nodes (25): accent, alignStart, border, build, CommentaryVerseCard, ink, onTap, reference (+17 more)

### Community 110 - "build_jfb_commentary.py"
Cohesion: 0.33
Nodes (8): encode_pack(), _entries_for_chapter(), fetch_source(), main(), normalize_paragraphs(), parse_chapter(), parse_entries(), validate_pack()

### Community 111 - "streak_provider.dart"
Cohesion: 0.15
Nodes (11): build, _calculateState, consecutiveDays, count, distinctDaysThisYear, _formatDate, markAppOpenedToday, markReadToday (+3 more)

### Community 112 - "read_location_provider.dart"
Cohesion: 0.08
Nodes (19): currentIndex, hasSelection, isManualHidden, isRead, isScrollHidden, true, bookAbbrev, bookName (+11 more)

### Community 113 - "journal_entry.dart"
Cohesion: 0.18
Nodes (9): content, date, detectedEmotions, fromJson, id, JournalEntry, prayerPoints, recommendedVerses (+1 more)

### Community 114 - "curated_plans.dart"
Cohesion: 0.15
Nodes (12): attribution, availablePlans, badge, category, dailyCommitment, description, durationDays, id (+4 more)

### Community 115 - "shared_app_bar.dart"
Cohesion: 0.15
Nodes (10): actions, automaticallyImplyLeading, backgroundColor, build, elevation, leading, leadingWidth, preferredSize (+2 more)

### Community 116 - "os"
Cohesion: 0.17
Nodes (6): db_text_mb(), main(), mb(), fetch(), main(), main()

### Community 117 - "translation_downloader_test.dart"
Cohesion: 0.17
Nodes (7): main, _fixture, live, liveOsis, main, osisID, type

### Community 118 - "commentary_hub_screen.dart"
Cohesion: 0.05
Nodes (36): ReadingTokens, accent, book, _buildAppBar, _buildClassicEntry, _buildClassicFilters, _buildDropdownChip, _buildRefinedEntry (+28 more)

### Community 119 - "translation_model.dart"
Cohesion: 0.17
Nodes (11): abbreviation, fromMap, isComplete, isDownloaded, languageCode, languageName, license, toMap (+3 more)

### Community 120 - "passage.dart"
Cohesion: 0.12
Nodes (14): book, bookName, chapter, endChapter, endVerse, _exp, lastChapter, out (+6 more)

### Community 121 - "static const"
Cohesion: 0.08
Nodes (21): aiJournalServiceProvider, add, build, JournalNotifier, _key, _load, remove, _save (+13 more)

### Community 122 - "tool/"
Cohesion: 0.20
Nodes (6): Bible text and translation packs, Commentary, Devotional (Bible Stories), Legal and CI, Study data, tool/

### Community 123 - "List"
Cohesion: 0.06
Nodes (27): kBibleBookNames, category, ConcordanceTerm, countKjv, definition, kConcordanceTerms, keyVerse, word (+19 more)

### Community 124 - "devotionalFavoritesProvider"
Cohesion: 0.12
Nodes (25): devotionalBooksProvider, devotionalFavoritesProvider, devotionalFilterProvider, devotionalReadProvider, devotionalStoriesProvider, filteredDevotionalStoriesProvider, storyMarksProvider, BibleStoriesScreen (+17 more)

### Community 125 - "Phase 6 device test checklist"
Cohesion: 0.20
Nodes (9): 0. Get the latest build onto your phone, 1. First launch (onboarding), 2. Languages, 3. Themes, 4. Accessibility, 5. Consistency, 6. Sign-in and sync, Phase 6 device test checklist (+1 more)

### Community 126 - "Content Licenses Register"
Cohesion: 0.20
Nodes (9): Action items (resolve before any store release), App icon and other images, Commentary (`assets/commentary/`), Content Licenses Register, Devotional (Bible Stories), Fonts (`assets/fonts/`), Scripture texts, Software packages (+1 more)

### Community 127 - "sys"
Cohesion: 0.60
Nodes (3): build_html(), build_md(), main()

### Community 128 - "AppLocalizations"
Cohesion: 0.17
Nodes (11): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, AppLocalizationsEs, AppLocalizationsFr, AppLocalizationsIt, of, AppLocalizationsPt (+3 more)

### Community 129 - "animated_segmented_tile.dart"
Cohesion: 0.12
Nodes (14): AnimatedSegmentedTile, build, createState, _isPressed, isSelected, onChanged, option, options (+6 more)

### Community 130 - "settings_screen.dart"
Cohesion: 0.03
Nodes (41): authGateway, createState, _guardStartup, initializeApp, main, prefs, TheBlessedBibleApp, wait (+33 more)

### Community 131 - "../../theme/design_tokens.dart"
Cohesion: 0.02
Nodes (83): PaperlikeTransform, bookAbbrev, chapter, reference, verseNum, build, contentController, createState (+75 more)

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

### Community 136 - "language_picker.dart"
Cohesion: 0.28
Nodes (7): appLocaleProvider, _chooseLanguage, initState, build, LanguageSettingsTile, _LanguageSheet, showLanguagePicker

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

### Community 155 - "share_sheet_test.dart"
Cohesion: 0.06
Nodes (21): ShareCard, host, long, main, short, host, main, main (+13 more)

### Community 156 - "pull_request_template.md"
Cohesion: 0.33
Nodes (5): Checklist, How it was tested, Screenshots, What changed, Why

### Community 157 - "[0.0.6] - 2026-10-26"
Cohesion: 0.50
Nodes (4): [0.0.6] - 2026-10-26, Commentary & Volumes, Localization & Reading Experience, Universal Sharing & Document Export

### Community 159 - "commentary_work.dart"
Cohesion: 0.07
Nodes (27): author, authors, base, books, buildCommentaryWorks, chapterCount, CommentaryWork, commentaryWorkTitle (+19 more)

### Community 175 - "crossed_swords_icon.dart"
Cohesion: 0.12
Nodes (17): build, color, _controller, createState, CrossedSwordsIcon, _CrossedSwordsIconState, didChangeDependencies, dispose (+9 more)

### Community 176 - "bible_provider.dart"
Cohesion: 0.11
Nodes (17): BibleNotifier, BibleState, book, bookNumber, books, build, chapter, ChapterKey (+9 more)

### Community 178 - "share_pdf_service.dart"
Cohesion: 0.07
Nodes (22): _body, _bodyBold, _bodyItalic, _brand, build, _display, _docTitle, _fontsLoaded (+14 more)

### Community 179 - "main_nav_screen.dart"
Cohesion: 0.02
Nodes (83): _buildActionIcon, _buildActionMenuIcons, _buildColorDot, _buildColorDotRow, _buildGlassWrapper, _buildMorphingSlot, _buildNext, _buildRaindropColorRow (+75 more)

### Community 180 - "Color"
Cohesion: 0.22
Nodes (8): copyWith, lerp, readingAccent, readingBorder, readingInk, readingInkMuted, readingPaper, readingSurface

### Community 181 - "dictionary_search_provider.dart"
Cohesion: 0.17
Nodes (11): db, DictionaryHeadword, dictionaryIndexProvider, displayHeadword, grouped, likeTerm, normalizedWord, q (+3 more)

### Community 182 - "content_sync_service.dart"
Cohesion: 0.20
Nodes (8): _asMap, cacheFileName, collectionName, ContentSyncService, _encodeJsonMap, loadLocalCache, _parseJsonMap, syncDeltas

### Community 183 - "span_marks.dart"
Cohesion: 0.10
Nodes (16): CrossRef, CrossRefKey, toBookNumber, toChapter, toVerse, votes, applySpanMarks, cursor (+8 more)

### Community 184 - "strongs_provider.dart"
Cohesion: 0.20
Nodes (9): db, definition, id, lemma, maps, pronunciation, row, StrongsEntry (+1 more)

### Community 185 - "Notifier"
Cohesion: 0.07
Nodes (30): CommentaryBookmarksNotifier, DevotionalFavoritesNotifier, DevotionalReadNotifier, StoryMarksNotifier, StoryShowPassageNotifier, BookmarkedWordsNotifier, VotdOverrideNotifier, build (+22 more)

### Community 186 - "navProvider"
Cohesion: 0.11
Nodes (30): flatChaptersProvider, chromeHiddenProvider, navHiddenProvider, navProvider, bottomNavVisibilityProvider, readLocationProvider, readSelectionProvider, activePlanContextProvider (+22 more)

### Community 187 - "clean_commentary.py"
Cohesion: 0.22
Nodes (7): build_vocabulary(), clean_entry_text(), junk_reason(), main(), merge_fragments(), normalize_text(), sentence_is_readable()

### Community 188 - "share_document_preview.dart"
Cohesion: 0.11
Nodes (17): ShareContent, AppPalette, _StyleMeta, _bodyStyle, _brand, build, content, _eyebrow (+9 more)

### Community 189 - "prose.dart"
Cohesion: 0.12
Nodes (14): _hardWrap, hasVisibleProse, _invisible, _missingClauseSpace, _missingSentenceSpace, normalized, normalizeProse, out (+6 more)

### Community 192 - "localized_book_names.dart"
Cohesion: 0.11
Nodes (13): bookNameInLocale, index, kLocalizedBookNames, LocalizedBookName, localizedReference, names, reference, referenceInLocale (+5 more)

### Community 195 - "package:flutter/foundation.dart"
Cohesion: 0.09
Nodes (17): activateAppCheck, crashlytics, initCrashReporting, reportNonFatal, setCrashlyticsCollectionEnabled, setCrashReportingEnabled, _data, _ensureInitialized (+9 more)

## Knowledge Gaps
- **14011 isolated node(s):** `firebase-tools`, `XCTest`, `WidgetKit`, `SwiftUI`, `.body` (+14006 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 14617 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `StudyContentCategory` connect `commentary_entry.dart` to `commentary_library_v2_screen.dart`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **What connects `firebase-tools`, `XCTest`, `WidgetKit` to the rest of the system?**
  _14011 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.001644736842105263 - nodes in this community are weakly interconnected._
- **Why does `CommentaryEntry` connect `commentary_entry.dart` to `commentary_library_v2_screen.dart`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0016680567139282735 - nodes in this community are weakly interconnected._
- **Why does `_` connect `_` to `verse_link_text.dart`, `share_sheet.dart`, `textured_glass_container.dart`, `../../theme/design_tokens.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `preferencesProvider`, `List`, `dart:convert`, `read_screen.dart`, `../../l10n/l10n.dart`, `static const`, `share_sheet_test.dart`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **Should `app_localizations_fr.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0016680567139282735 - nodes in this community are weakly interconnected._