# Graph Report - Blessed Bible  (2026-10-27)

## Corpus Check
- 413 files · ~3,175,359 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 133 file(s) not represented in the graph (top: .ttf 48, .xml 32, (none) 12)

## Summary
- 13347 nodes · 16448 edges · 198 communities (182 shown, 16 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.95)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `c221a8bf`
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
- radial_action_menu.dart
- preferencesProvider
- StatelessWidget
- app_colors.dart
- AppPalette
- search_engine.dart
- reading_plan_detail_v2_screen.dart
- reading_plan_provider.dart
- VoidCallback
- custom_plan_builder_v2_screen.dart
- dynamic_toast.dart
- study_screen_v2.dart
- notes_list_screen.dart
- read_screen.dart
- theme_picker_sheet.dart
- goldens_test.dart
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
- onboarding_screen.dart
- ../../l10n/l10n.dart
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
- storage_screen.dart
- book_chapter_selector_sheet.dart
- dictionary_underline_test.dart
- commentary_view.dart
- fetch_dore_art.py
- search_settings_provider.dart
- typography_provider.dart
- package:flutter/services.dart
- translation_downloader.dart
- Production Readiness: Status and Plan
- Targeted UX/UI Fixes
- verse_link_text.dart
- reading_plan.dart
- plans_library_widgets.dart
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
- bible_sync_test.dart
- Color
- commentary_library_test.dart
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
- plan_flow_test.dart
- bible_provider.dart
- journey_map_screen.dart
- story_of_the_day_provider.dart
- bookmark_model.dart
- Privacy Policy
- package.json
- share_sheet.dart
- bible_stories_screen.dart
- build_content.py
- story_marks_test.dart
- study_greetings_test.dart
- plan_generator.dart
- study_greetings.dart
- Pericope Dataset — Whole-System Audit Report
- pericope_entry.dart
- wotd_provider.dart
- commentary_prose.dart
- share_service.dart
- streak_provider.dart
- read_location_provider.dart
- prose_text.dart
- curated_plans.dart
- shared_app_bar.dart
- os
- translation_downloader_test.dart
- commentary_hub_screen.dart
- translation_model.dart
- passage.dart
- surface_style_provider.dart
- tool/
- concordance_screen.dart
- devotionalFavoritesProvider
- Phase 6 device test checklist
- Content Licenses Register
- sys
- AppLocalizations
- glass_container.dart
- package:flutter_riverpod/flutter_riverpod.dart
- verse_action_sheet.dart
- upload_packs
- Mandatory Self-Checks
- Mandatory Self-Checks
- Mandatory Self-Checks
- package:flutter/widgets.dart
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
- most_read_provider.dart
- bible_model.dart
- commentary_work.dart
- MainActivity.kt
- Applied Fixes
- PHASE_6_PLAN.md
- firestore-tests/README.md
- LaunchImage.imageset/README.md
- dart:math
- crossed_swords_icon.dart
- bible_provider.dart
- translation_picker_sheet.dart
- share_pdf_service.dart
- main_nav_screen.dart
- Color
- dictionary_search_provider.dart
- ../../utils/log.dart
- span_marks.dart
- cross_references_sheet.dart
- Notifier
- navProvider
- clean_commentary.py
- share_document_preview.dart
- prose.dart
- static const
- StreakWidgetProvider.kt
- localized_book_names.dart
- nav_settings_provider.dart
- credits_screen.dart
- firebase_setup.dart
- study_provider.dart
- bible_sections.dart

## God Nodes (most connected - your core abstractions)
1. `preferencesProvider` - 136 edges
2. `_` - 55 edges
3. `themeProvider` - 50 edges
4. `readSettingsProvider` - 40 edges
5. `bibleProvider` - 36 edges
6. `_ReadScreenState` - 31 edges
7. `readingPlanProvider` - 30 edges
8. `activeTranslationProvider` - 28 edges
9. `============================================================` - 26 edges
10. `typographyProvider` - 25 edges

## Surprising Connections (you probably didn't know these)
- `4. Work breakdown (one PR each)` --references--> `merge()`  [INFERRED]
  docs/PHASE_5B_SYNC_PLAN.md → tool/build_topical.py
- `_FakeCommentary` --inherits--> `CommentaryNotifier`  [EXTRACTED]
  test/commentary_hub_test.dart → lib/state/commentary_provider.dart
- `_FakeCommentary` --inherits--> `CommentaryNotifier`  [EXTRACTED]
  test/commentary_library_test.dart → lib/state/commentary_provider.dart
- `exportData` --references--> `preferencesProvider`  [EXTRACTED]
  lib/services/backup_service.dart → lib/data/local_storage/preferences_service.dart
- `_rememberSignIn` --references--> `preferencesProvider`  [EXTRACTED]
  lib/state/auth_provider.dart → lib/data/local_storage/preferences_service.dart

## Import Cycles
- None detected.

## Communities (198 total, 16 thin omitted)

### Community 0 - "app_localizations.dart"
Cohesion: 0.00
Nodes (1175): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1167 more)

### Community 1 - "app_localizations_en.dart"
Cohesion: 0.00
Nodes (1167): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1159 more)

### Community 2 - "app_localizations_fr.dart"
Cohesion: 0.00
Nodes (1167): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1159 more)

### Community 3 - "app_localizations_it.dart"
Cohesion: 0.00
Nodes (1167): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1159 more)

### Community 4 - "app_localizations_ro.dart"
Cohesion: 0.00
Nodes (1167): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1159 more)

### Community 5 - "app_localizations_sw.dart"
Cohesion: 0.00
Nodes (1167): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1159 more)

### Community 6 - "app_localizations_tl.dart"
Cohesion: 0.00
Nodes (1167): a11yHideNav, a11yMakePrimary, a11yNextWeek, a11yNotifications, a11yPreviousWeek, a11yRead, a11yShowNav, a11yTextLarger (+1159 more)

### Community 7 - "preferences_service.dart"
Cohesion: 0.01
Nodes (153): _activePlanIdsKey, _activeTranslationKey, _appUsageDatesKey, _bentoPresetKey, _bookmarksKey, _bookmarksV2Key, _chapterPositionsKey, clearAllUserData (+145 more)

### Community 8 - "themeProvider"
Cohesion: 0.05
Nodes (100): build, _TheBlessedBibleAppState, widgetUpdateServiceProvider, wordCountServiceProvider, bibleNavSettingsProvider, bibleProvider, translationChapterProvider, commentaryBookmarksProvider (+92 more)

### Community 9 - "radial_action_menu.dart"
Cohesion: 0.04
Nodes (54): animateIn, BouncyEntrance, _BouncyEntranceState, build, child, _controller, createState, delay (+46 more)

### Community 10 - "preferencesProvider"
Cohesion: 0.03
Nodes (78): preferencesProvider, notificationServiceProvider, build, hasSeen, markSeen, maybeShowHint, resetHints, build (+70 more)

### Community 11 - "StatelessWidget"
Cohesion: 0.03
Nodes (75): book, _BookIndex, _BookRow, _browser, chapter, chapters, _ChapterTile, createState (+67 more)

### Community 12 - "app_colors.dart"
Cohesion: 0.03
Nodes (78): AppColors, darkBackground, darkBorder, darkSurface, darkTextPrimary, darkTextSecondary, dawnAccent, dawnBackground (+70 more)

### Community 13 - "AppPalette"
Cohesion: 0.33
Nodes (5): ShareContent, AppPalette, _StyleMeta, ShareCardStyle, ShareCardStyleNotifier

### Community 14 - "search_engine.dart"
Cohesion: 0.03
Nodes (66): activeTranslation, addNoteTokens, addTokens, args, baseIndexFuture, baseSearchIndexProvider, bibleBooks, bibleState (+58 more)

### Community 15 - "reading_plan_detail_v2_screen.dart"
Cohesion: 0.04
Nodes (52): dictionarySearchProvider, build, createState, DictionaryV2Screen, _DictionaryV2ScreenState, onOpen, _openEntry, _query (+44 more)

### Community 16 - "reading_plan_provider.dart"
Cohesion: 0.03
Nodes (73): addPlan, appWeekday, bookName, build, _canonCache, _canonIndex, chapterNum, completedAtomIds (+65 more)

### Community 17 - "VoidCallback"
Cohesion: 0.05
Nodes (40): NavMenuTriggerNotifier, ActionIcon, _ActionIconState, build, color, createState, _handleTap, icon (+32 more)

### Community 18 - "custom_plan_builder_v2_screen.dart"
Cohesion: 0.03
Nodes (63): _autoName, build, createState, _days, _daysController, dispose, draft, _drafts (+55 more)

### Community 19 - "dynamic_toast.dart"
Cohesion: 0.09
Nodes (22): actionLabel, build, _controller, createState, didChangeDependencies, _dismiss, _dismissing, dispose (+14 more)

### Community 20 - "study_screen_v2.dart"
Cohesion: 0.02
Nodes (120): BackupService, importData, bookmarkedWordsProvider, dictionaryDefinitionProvider, homeProvider, activePlanIdsProvider, readingPlanProvider, storyOfTheDayProvider (+112 more)

### Community 21 - "notes_list_screen.dart"
Cohesion: 0.03
Nodes (52): AppLanguage, appLanguageFor, appLanguages, AppLocaleNotifier, appLocaleProvider, bibleId, build, code (+44 more)

### Community 22 - "read_screen.dart"
Cohesion: 0.03
Nodes (57): hintsProvider, navHiddenProvider, activePlanContextProvider, _buildFabIcon, _fabTooltip, _animateToPage, _buildEndOfChapterBlock, _buildNormalVerse (+49 more)

### Community 23 - "theme_picker_sheet.dart"
Cohesion: 0.03
Nodes (61): kBibleBookNames, ActivePlanIdsNotifier, color, controller, createState, currentMode, dirX, dirY (+53 more)

### Community 24 - "goldens_test.dart"
Cohesion: 0.08
Nodes (21): main, prefs, _pump, pumpWidget, _screens, _themes, main, _noop (+13 more)

### Community 25 - "search_provider.dart"
Cohesion: 0.06
Nodes (40): mostReadProvider, searchEngineProvider, addRecentPlace, _addRecentQuery, build, clearRecentQueries, copyWith, _debounce (+32 more)

### Community 26 - "plan_flow.dart"
Cohesion: 0.06
Nodes (29): accent, build, caption, child, compact, current, day, footer (+21 more)

### Community 27 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.05
Nodes (32): PreferencesService, main, main, host, main, main, main, pumpAtTab (+24 more)

### Community 28 - "main_nav_screen.dart"
Cohesion: 0.02
Nodes (77): appGroupId, _formatDate, _init, _l10n, _ref, service, streakWidgetName, syncAllWidgets (+69 more)

### Community 29 - "study_reader_screen.dart"
Cohesion: 0.04
Nodes (51): book, bookAbbrev, bookName, chapter, chapterNum, _clearSelection, createState, _current (+43 more)

### Community 30 - "plan_generator.dart"
Cohesion: 0.04
Nodes (42): PaceRemapService, PlanGenerator, _data, _ensureInitialized, init, initFromJson, maxVerseInChapter, _parseWordCountsJson (+34 more)

### Community 31 - "account_menu.dart"
Cohesion: 0.03
Nodes (74): _account, AuthActions, authActionsProvider, deleteAccount, ref, _rememberSignIn, _setSignedOutByUser, signInWithApple (+66 more)

### Community 32 - "design_tokens.dart"
Cohesion: 0.04
Nodes (46): all, body, bodyLarge, caption, card, copyWith, danger, display (+38 more)

### Community 33 - "read_settings_provider.dart"
Cohesion: 0.04
Nodes (48): activeHighlightColorIndex, _activeHighlightColorIndexKey, build, _commentaryStyleKey, copyWith, cycleHighlightColor, defaultStartTab, dictionaryUnderlinesEnabled (+40 more)

### Community 34 - "your_space_screen.dart"
Cohesion: 0.04
Nodes (48): abbrevUpper, bookAbbrev, bookmarkData, _BookmarksSegment, _BookmarksSegmentState, _BookmarkViewType, bookName, bookNumber (+40 more)

### Community 35 - "Contributing: Project Rules & Workflow"
Cohesion: 0.20
Nodes (10): 1. Always Verify Build Before Done, 2. Commit After Every Green Build, Backup & Restore Points (Mandatory), Build Verification (Mandatory), Contributing: Project Rules & Workflow, Do Not Block the Task Queue, Layout & Symmetry, Riverpod / State (+2 more)

### Community 36 - "bible_database_service.dart"
Cohesion: 0.04
Nodes (41): BibleDatabaseService, bibleDbService, _clearRepairAttempts, contentBytesUsed, contentVersion, _contentVersionKey, _copyAssetDb, _db (+33 more)

### Community 37 - "[0.0.4] - 2026-10-22"
Cohesion: 0.18
Nodes (11): [0.0.4] - 2026-10-22, Accounts, Accounts & Cloud Sync, Added, Changed, Fixed, Infrastructure & Hygiene, Onboarding & Themes (+3 more)

### Community 38 - "translation_pack_store.dart"
Cohesion: 0.04
Nodes (42): abbreviation, bundledPackIds, _catalogFile, _copyAssetPack, coreIds, deletedPackIds, _deletedPacksKey, deletePack (+34 more)

### Community 39 - "bible_sync.dart"
Cohesion: 0.04
Nodes (67): devotionalServiceProvider, build, notesProvider, bookmarkDataProvider, bookmarksProvider, build, highlightsProvider, toggle (+59 more)

### Community 40 - "onboarding_screen.dart"
Cohesion: 0.04
Nodes (54): AppThemeMode, AppThemeModeExtension, build, _engineModeKey, _loadTheme, _lockedThemeKey, NoAnimationPageTransitionsBuilder, resolve (+46 more)

### Community 41 - "../../l10n/l10n.dart"
Cohesion: 0.04
Nodes (37): activateAppCheck, authGateway, createState, initCrashReporting, initialize, initializeApp, main, prefs (+29 more)

### Community 42 - "home_provider.dart"
Cohesion: 0.06
Nodes (32): dayOfYear, daysInYear, daysRemaining, index, label, remainingLabel, start, verseForDay (+24 more)

### Community 43 - "Changelog"
Cohesion: 0.18
Nodes (11): [0.0.5] - 2026-10-22, [0.0.6] - 2026-10-26, 1.0.2+9, Changelog, Commentary & Volumes, 📥 Download & Install, Home Screen & Daily Content, Localization & Reading Experience (+3 more)

### Community 44 - "plan_spec.dart"
Cohesion: 0.05
Nodes (42): attribution, badge, book, _bookAliases, cadenceDays, category, day, days (+34 more)

### Community 45 - "dictionary_provider.dart"
Cohesion: 0.05
Nodes (35): aliases, bookNumber, build, chapterNumber, ChapterUnderlineArgs, db, definition, dictionaryAliasesProvider (+27 more)

### Community 46 - "dart:convert"
Cohesion: 0.04
Nodes (36): CanonIndex, data, entries, label, main, textOf, _baselinePath, _count (+28 more)

### Community 47 - "generate_reading_plan.dart"
Cohesion: 0.05
Nodes (41): abbrevKey, bad, badRefs, badWeeks, _bookMap, bookName, _canonicalNames, ch (+33 more)

### Community 48 - "_"
Cohesion: 0.05
Nodes (35): _, align, artworkPath, aspectRatio, _Backdrop, body, build, commentary (+27 more)

### Community 49 - "notification_service.dart"
Cohesion: 0.06
Nodes (23): cancelDailyReminder, cancelPrayerReminder, cancelReminder, cancelSabbathReminders, cancelWeeklyReminder, _flutterLocalNotificationsPlugin, initialize, _initialized (+15 more)

### Community 50 - "devotional_provider.dart"
Cohesion: 0.04
Nodes (50): add, all, bookPrefix, build, colorIndex, copyWith, DevotionalFilterNotifier, DevotionalFilterState (+42 more)

### Community 51 - "BlessedBibleWidgets.swift"
Cohesion: 0.09
Nodes (17): BlessedBibleWidgets, .body, Color, Provider, SimpleEntry, StreakWidget, .body, StreakWidgetEntryView (+9 more)

### Community 52 - "home_data.dart"
Cohesion: 0.05
Nodes (34): activeStudy, author, chaptersRemaining, commentarySnippet, content, count, date, fromJson (+26 more)

### Community 53 - "storage_screen.dart"
Cohesion: 0.06
Nodes (35): abbr, build, bundled, _busy, _cacheBytes, _cacheBytesUsed, _clearCache, _confirm (+27 more)

### Community 54 - "book_chapter_selector_sheet.dart"
Cohesion: 0.07
Nodes (34): book, BookChapterSelectorSheet, books, _buildBookSelection, _buildBreadcrumbs, _buildBreadcrumbSegment, _buildChapterSelection, _buildGridTile (+26 more)

### Community 55 - "dictionary_underline_test.dart"
Cohesion: 0.08
Nodes (17): argsFor, container, main, makeContainer, map, markedWords, out, prefs (+9 more)

### Community 56 - "commentary_view.dart"
Cohesion: 0.04
Nodes (37): journalProvider, book, _buildCollapsibleSection, _buildEmptyState, _buildEntryCard, _buildEntryContent, _buildScrollableContent, chapter (+29 more)

### Community 57 - "fetch_dore_art.py"
Cohesion: 0.16
Nodes (15): die(), ensure_dirs(), http_get(), log(), save_json(), supabase_query(), clean_key_verse(), main() (+7 more)

### Community 58 - "search_settings_provider.dart"
Cohesion: 0.06
Nodes (32): _autoOpenKey, autoOpenSingleSearchResult, build, copyWith, _defaultCommKey, _defaultDictKey, _defaultNotesKey, _defaultNtKey (+24 more)

### Community 59 - "typography_provider.dart"
Cohesion: 0.07
Nodes (28): build, copyWith, fontFamily, _fontFamilyKey, fontSize, _fontSizeKey, fontStyle, fontWeight (+20 more)

### Community 60 - "package:flutter/services.dart"
Cohesion: 0.08
Nodes (22): CreditItem, CreditSection, creditSections, detail, _fontCopyrights, heading, items, note (+14 more)

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
Cohesion: 0.06
Nodes (32): BoldSegment, boldStyle, build, _buildSpans, createState, defaultStyle, dictionaryWordStyle, didUpdateWidget (+24 more)

### Community 65 - "reading_plan.dart"
Cohesion: 0.07
Nodes (27): book, cadence, clampReason, copyWith, dayNumber, days, endChapter, endVerse (+19 more)

### Community 66 - "plans_library_widgets.dart"
Cohesion: 0.09
Nodes (21): build, count, date, height, initials, LibraryHeroHeader, libraryMonthDay, libraryWeekday (+13 more)

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
Cohesion: 0.08
Nodes (23): absoluteVerseIndex, _addVerseRange, allPericopes, _buildCompletedVerseSet, buildCompletedVerseSetPublic, buildVerseSetFromAtomsPublic, _chapterOffset, _chapterOffsets (+15 more)

### Community 71 - "plan_assets_test.dart"
Cohesion: 0.08
Nodes (25): _assets, assetVerses, book, _bookAliases, c1, c2, c2s, canon (+17 more)

### Community 72 - "============================================================"
Cohesion: 0.08
Nodes (25): ============================================================, ============================================================, ============================================================, ============================================================, ============================================================, ============================================================, ============================================================, ============================================================ (+17 more)

### Community 73 - "bible_story_reader_screen.dart"
Cohesion: 0.04
Nodes (43): StoryMark, all, book, bookStories, createState, current, dispose, _goNeighbor (+35 more)

### Community 74 - "commentary_entry.dart"
Cohesion: 0.08
Nodes (21): author, book, category, chapter, CommentaryEntry, CommentaryScope, custom, dateAdded (+13 more)

### Community 75 - "devotional_service.dart"
Cohesion: 0.08
Nodes (24): _artByPrefix, _artCaptionBySlug, _artLoaded, _artMapAsset, assetPath, _bookAssetPrefix, _booksByPrefix, caption (+16 more)

### Community 76 - "bible_nav_settings_provider.dart"
Cohesion: 0.08
Nodes (24): _autoCloseKey, autoCloseOnFinalSelection, BibleNavSettingsNotifier, BibleNavSettingsState, build, copyWith, depth, _depthKey (+16 more)

### Community 77 - "pericopes_provider.dart"
Cohesion: 0.18
Nodes (9): build, data, getPericopesForChapter, _loadData, loadError, map, _parsePericopes, PericopesNotifier (+1 more)

### Community 78 - "commentary_provider.dart"
Cohesion: 0.08
Nodes (23): book, build, _cachedChapters, _cachedFormattedVerses, _cachedVersesWithCommentary, _cachedVersesWithDevotionals, _cachedVersesWithNotes, chapter (+15 more)

### Community 79 - "bible_sync_test.dart"
Cohesion: 0.10
Nodes (12): main, openMenu, pumpHub, col, db, device, main, settle (+4 more)

### Community 81 - "commentary_library_test.dart"
Cohesion: 0.05
Nodes (28): CommentaryNotifier, build, entries, _FakeCommentary, main, pumpHub, build, cover (+20 more)

### Community 82 - "build_topical.py"
Cohesion: 0.13
Nodes (16): 1. Current state (audit, 2026-10-10), 2. What syncs, 3. Design, 4. Work breakdown (one PR each), 5. Device test script (5B.6), 6. Risks, Phase 5B: Google Sign-In, Sign-Out and Data Sync, build_plan() (+8 more)

### Community 83 - "devotional_story.dart"
Cohesion: 0.09
Nodes (21): book, copyWithEnriched, count, DevotionalBookInfo, DevotionalStory, fromJson, grouping, id (+13 more)

### Community 84 - "share_content.dart"
Cohesion: 0.05
Nodes (40): artworkPath, author, body, cleanShareText, commentary, copyWith, cut, date (+32 more)

### Community 85 - "✨ Flagship Features"
Cohesion: 0.18
Nodes (11): 🔍 Built-In Biblical Concordance, 📚 Commentary Shelf & Historicist Volumes, 📖 Distraction-Free Scripture Reading, 🎨 Dynamic Themes & Custom Typography, ✨ Flagship Features, 🌐 Full Multi-Language Localization, 🏷️ Personal Study Space & Enhanced Sharing, ☁️ Privacy-First & Cloud Sync (+3 more)

### Community 86 - "ai_journal_service.dart"
Cohesion: 0.18
Nodes (9): AiJournalService, analyzeEntry, emotionLabel, emotions, _emotionVerses, JournalReflectionResult, _keywords, prayerPoints (+1 more)

### Community 87 - "widget_settings_provider.dart"
Cohesion: 0.12
Nodes (16): backgroundStyle, _bgStyleKey, build, copyWith, emoji, fromId, id, label (+8 more)

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

### Community 92 - "plan_flow_test.dart"
Cohesion: 0.29
Nodes (4): days, daysAgo, main, plan

### Community 93 - "bible_provider.dart"
Cohesion: 0.14
Nodes (10): book, books, chapter, currentBookNum, currentChapterNum, decoded, entriesList, parseBibleRows (+2 more)

### Community 94 - "journey_map_screen.dart"
Cohesion: 0.10
Nodes (17): build, completedDays, createState, _currentWeek, dispose, _initialized, initState, JourneyMapScreen (+9 more)

### Community 95 - "story_of_the_day_provider.dart"
Cohesion: 0.09
Nodes (21): build, day, dayIndex, dayKey, _key, _midnight, mode, order (+13 more)

### Community 96 - "bookmark_model.dart"
Cohesion: 0.12
Nodes (14): BookmarkData, BookmarkFolder, BookmarkNode, createdAt, folderId, folders, fromJson, id (+6 more)

### Community 97 - "Privacy Policy"
Cohesion: 0.11
Nodes (17): App integrity checks, Changes to this policy, Children, Contact, Crash reports, Deleting your account, Downloading content, How long we keep data (+9 more)

### Community 98 - "package.json"
Cohesion: 0.12
Nodes (12): description, devDependencies, firebase, @firebase/rules-unit-testing, firebase-tools, name, private, scripts (+4 more)

### Community 99 - "share_sheet.dart"
Cohesion: 0.05
Nodes (34): ShareFlavor, ShareCardBackdrop, shareCardStyleProvider, _backdrop, _boundaryKey, build, _buildImage, _buildPdf (+26 more)

### Community 100 - "bible_stories_screen.dart"
Cohesion: 0.08
Nodes (27): devotionalBooksProvider, devotionalFilterProvider, filteredDevotionalStoriesProvider, BibleStoriesScreen, _BibleStoriesScreenState, _bookLabel, build, createState (+19 more)

### Community 101 - "build_content.py"
Cohesion: 0.28
Nodes (11): build_core(), build_pack(), check_only(), count(), main(), manifest_entry(), mb(), quick_check() (+3 more)

### Community 102 - "story_marks_test.dart"
Cohesion: 0.13
Nodes (5): main, main, _plain, _book, main

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
Cohesion: 0.07
Nodes (23): strongsProvider, accent, alignStart, border, build, CommentaryVerseCard, ink, onTap (+15 more)

### Community 110 - "share_service.dart"
Cohesion: 0.12
Nodes (13): captureBoundaryPng, cleanVerseText, copyText, formatCommentary, formatStory, formatVerse, formatWord, referenceFor (+5 more)

### Community 111 - "streak_provider.dart"
Cohesion: 0.15
Nodes (11): build, _calculateState, consecutiveDays, count, distinctDaysThisYear, _formatDate, markAppOpenedToday, markReadToday (+3 more)

### Community 112 - "read_location_provider.dart"
Cohesion: 0.14
Nodes (13): bookAbbrev, bookName, build, chapter, clearCommentary, clearRequestedVerse, copyWith, openCommentary (+5 more)

### Community 113 - "prose_text.dart"
Cohesion: 0.13
Nodes (11): accent, baseStyle, build, marks, paragraphGap, ProseText, refined, renderedParagraph (+3 more)

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
Cohesion: 0.04
Nodes (44): bookAbbrev, chapter, reference, verseNum, accent, book, _buildAppBar, _buildClassicEntry (+36 more)

### Community 119 - "translation_model.dart"
Cohesion: 0.17
Nodes (11): abbreviation, fromMap, isComplete, isDownloaded, languageCode, languageName, license, toMap (+3 more)

### Community 120 - "passage.dart"
Cohesion: 0.13
Nodes (14): book, bookName, chapter, endChapter, endVerse, _exp, lastChapter, out (+6 more)

### Community 121 - "surface_style_provider.dart"
Cohesion: 0.13
Nodes (13): build, EarthHeavenStyle, EarthHeavenStyleNotifier, eh, _loadState, _migrationKey, resolveEarthSurface, setStyle (+5 more)

### Community 122 - "tool/"
Cohesion: 0.20
Nodes (6): Bible text and translation packs, Commentary, Devotional (Bible Stories), Legal and CI, Study data, tool/

### Community 123 - "concordance_screen.dart"
Cohesion: 0.05
Nodes (38): category, ConcordanceTerm, countKjv, definition, kConcordanceTerms, keyVerse, word, bookNumber (+30 more)

### Community 124 - "devotionalFavoritesProvider"
Cohesion: 0.18
Nodes (14): devotionalFavoritesProvider, devotionalReadProvider, devotionalStoriesProvider, storyMarksProvider, _StoryCard, _BookStoriesSheet, _buildSelectionMenu, _markSelection (+6 more)

### Community 125 - "Phase 6 device test checklist"
Cohesion: 0.20
Nodes (9): 0. Get the latest build onto your phone, 1. First launch (onboarding), 2. Languages, 3. Themes, 4. Accessibility, 5. Consistency, 6. Sign-in and sync, Phase 6 device test checklist (+1 more)

### Community 126 - "Content Licenses Register"
Cohesion: 0.20
Nodes (9): Action items (resolve before any store release), App icon and other images, Commentary (`assets/commentary/commentary.json`, 4,724 entries), Content Licenses Register, Devotional (Bible Stories), Fonts (`assets/fonts/`), Scripture texts, Software packages (+1 more)

### Community 127 - "sys"
Cohesion: 0.60
Nodes (3): build_html(), build_md(), main()

### Community 128 - "AppLocalizations"
Cohesion: 0.20
Nodes (9): AppLocalizations, _AppLocalizationsDelegate, AppLocalizationsEn, AppLocalizationsFr, AppLocalizationsIt, of, AppLocalizationsRo, AppLocalizationsSw (+1 more)

### Community 129 - "glass_container.dart"
Cohesion: 0.17
Nodes (7): borderRadius, build, child, GlassContainer, isScrollable, margin, padding

### Community 130 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.06
Nodes (19): CommentaryStyle, DictionaryScope, NonKjvDictionaryMode, PopupStyle, SelectorHeight, StrongsIndicatorStyle, VerseActionStyle, build (+11 more)

### Community 131 - "verse_action_sheet.dart"
Cohesion: 0.06
Nodes (29): action, actionCount, actions, active, allBookmarked, bookAbbrev, bookmarks, books (+21 more)

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

### Community 136 - "package:flutter/widgets.dart"
Cohesion: 0.22
Nodes (4): LocalizedBookName, l10n, L10nContext, DesignTokensContext

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
Cohesion: 0.07
Nodes (19): ShareCard, host, long, main, short, host, main, main (+11 more)

### Community 156 - "pull_request_template.md"
Cohesion: 0.33
Nodes (5): Checklist, How it was tested, Screenshots, What changed, Why

### Community 157 - "most_read_provider.dart"
Cohesion: 0.13
Nodes (12): bookAbbrev, bookName, build, chapter, fromKey, incrementVisit, key, MostReadItem (+4 more)

### Community 158 - "bible_model.dart"
Cohesion: 0.15
Nodes (12): abbreviation, BibleBook, BibleChapter, BibleVerse, chapters, fromJson, isBookmarked, isHighlighted (+4 more)

### Community 159 - "commentary_work.dart"
Cohesion: 0.07
Nodes (27): author, authors, base, books, buildCommentaryWorks, chapterCount, CommentaryWork, commentaryWorkTitle (+19 more)

### Community 174 - "dart:math"
Cohesion: 0.25
Nodes (5): AppTypography, getTheme, getNextDayOfWeek, getSunset, SunsetCalculator

### Community 175 - "crossed_swords_icon.dart"
Cohesion: 0.11
Nodes (17): build, color, _controller, createState, CrossedSwordsIcon, _CrossedSwordsIconState, didChangeDependencies, dispose (+9 more)

### Community 176 - "bible_provider.dart"
Cohesion: 0.11
Nodes (16): BibleNotifier, BibleState, book, bookNumber, books, build, chapter, ChapterKey (+8 more)

### Community 177 - "translation_picker_sheet.dart"
Cohesion: 0.05
Nodes (34): ReadingLayout, _activeTab, AppearanceSettingsSheet, _AppearanceSettingsSheetState, AppearanceTab, build, createState, icon (+26 more)

### Community 178 - "share_pdf_service.dart"
Cohesion: 0.07
Nodes (22): _body, _bodyBold, _bodyItalic, _brand, build, _display, _docTitle, _fontsLoaded (+14 more)

### Community 179 - "main_nav_screen.dart"
Cohesion: 0.05
Nodes (28): _buildActionIcon, _buildActionMenuIcons, _buildColorDot, _buildColorDotRow, _buildGlassWrapper, _buildMorphingSlot, _buildRaindropColorRow, CastingLotsDialog (+20 more)

### Community 180 - "Color"
Cohesion: 0.17
Nodes (9): copyWith, lerp, readingAccent, readingBorder, readingInk, readingInkMuted, readingPaper, readingSurface (+1 more)

### Community 181 - "dictionary_search_provider.dart"
Cohesion: 0.17
Nodes (11): db, DictionaryHeadword, dictionaryIndexProvider, displayHeadword, grouped, likeTerm, normalizedWord, q (+3 more)

### Community 182 - "../../utils/log.dart"
Cohesion: 0.09
Nodes (15): _asMap, cacheFileName, collectionName, ContentSyncService, _encodeJsonMap, loadLocalCache, _parseJsonMap, syncDeltas (+7 more)

### Community 183 - "span_marks.dart"
Cohesion: 0.17
Nodes (10): applySpanMarks, cursor, end, _mark, offset, out, pieces, SpanMark (+2 more)

### Community 184 - "cross_references_sheet.dart"
Cohesion: 0.05
Nodes (34): CrossRef, crossReferencesProvider, CrossRefKey, toBookNumber, toChapter, toVerse, votes, db (+26 more)

### Community 185 - "Notifier"
Cohesion: 0.09
Nodes (24): CommentaryBookmarksNotifier, DevotionalFavoritesNotifier, DevotionalReadNotifier, StoryMarksNotifier, StoryShowPassageNotifier, BookmarkedWordsNotifier, HintsNotifier, VotdOverrideNotifier (+16 more)

### Community 186 - "navProvider"
Cohesion: 0.08
Nodes (37): flatChaptersProvider, chromeHiddenProvider, navProvider, bottomNavVisibilityProvider, readLocationProvider, readSelectionProvider, _bookSection, _openBook (+29 more)

### Community 187 - "clean_commentary.py"
Cohesion: 0.21
Nodes (7): build_vocabulary(), clean_entry_text(), junk_reason(), main(), merge_fragments(), normalize_text(), sentence_is_readable()

### Community 188 - "share_document_preview.dart"
Cohesion: 0.13
Nodes (14): _bodyStyle, _brand, build, content, _eyebrow, _ink, _metaLine, _muted (+6 more)

### Community 189 - "prose.dart"
Cohesion: 0.13
Nodes (13): _hardWrap, _invisible, _missingClauseSpace, _missingSentenceSpace, normalized, normalizeProse, out, _paragraphBreak (+5 more)

### Community 190 - "static const"
Cohesion: 0.18
Nodes (8): aiJournalServiceProvider, add, build, JournalNotifier, _key, _load, remove, _save

### Community 192 - "localized_book_names.dart"
Cohesion: 0.18
Nodes (9): bookNameInLocale, index, kLocalizedBookNames, localizedReference, names, reference, referenceInLocale, rest (+1 more)

### Community 193 - "nav_settings_provider.dart"
Cohesion: 0.20
Nodes (6): currentIndex, hasSelection, isManualHidden, isRead, isScrollHidden, true

### Community 194 - "credits_screen.dart"
Cohesion: 0.25
Nodes (5): bbeSubstitutionsProvider, build, CreditsScreen, _buildInfoPage, packageInfoProvider

### Community 195 - "firebase_setup.dart"
Cohesion: 0.22
Nodes (6): activateAppCheck, crashlytics, initCrashReporting, reportNonFatal, setCrashlyticsCollectionEnabled, setCrashReportingEnabled

### Community 196 - "study_provider.dart"
Cohesion: 0.40
Nodes (4): ActiveStudyVerseNotifier, activeStudyVerseProvider, build, setVerse

### Community 197 - "bible_sections.dart"
Cohesion: 0.40
Nodes (4): BibleSection, _bookSections, getSectionColor, section

## Knowledge Gaps
- **11293 isolated node(s):** `firebase-tools`, `XCTest`, `WidgetKit`, `SwiftUI`, `.body` (+11288 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 11882 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_` connect `_` to `verse_link_text.dart`, `share_sheet.dart`, `textured_glass_container.dart`, `package:flutter_riverpod/flutter_riverpod.dart`, `preferencesProvider`, `AppPalette`, `dart:math`, `dart:convert`, `commentary_hub_screen.dart`, `theme_picker_sheet.dart`, `commentary_view.dart`, `share_sheet_test.dart`, `static const`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `firebase-tools`, `XCTest`, `WidgetKit` to the rest of the system?**
  _11293 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `app_localizations.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0016906170752324597 - nodes in this community are weakly interconnected._
- **Why does `preferencesProvider` connect `preferencesProvider` to `preferences_service.dart`, `themeProvider`, `AppPalette`, `reading_plan_provider.dart`, `study_screen_v2.dart`, `notes_list_screen.dart`, `read_screen.dart`, `theme_picker_sheet.dart`, `search_provider.dart`, `plan_flow.dart`, `most_read_provider.dart`, `account_menu.dart`, `bible_sync.dart`, `onboarding_screen.dart`, `../../l10n/l10n.dart`, `_`, `devotional_provider.dart`, `Notifier`, `static const`, `credits_screen.dart`, `commentary_provider.dart`, `widget_settings_provider.dart`, `story_of_the_day_provider.dart`, `bookmark_model.dart`, `share_sheet.dart`, `streak_provider.dart`, `read_location_provider.dart`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **Should `app_localizations_en.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0017123287671232876 - nodes in this community are weakly interconnected._
- **Should `app_localizations_fr.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0017123287671232876 - nodes in this community are weakly interconnected._
- **Should `app_localizations_it.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.001710863986313088 - nodes in this community are weakly interconnected._