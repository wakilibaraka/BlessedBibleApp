// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'The Blessed Bible';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonShare => 'Share';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSearch => 'Search';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Same as device';

  @override
  String get languageSubtitle =>
      'The language of menus and buttons. Your Bible translation is chosen separately.';

  @override
  String get onboardingTagline => 'Scripture, without distraction.';

  @override
  String get onboardingPickLanguage => 'Choose your language';

  @override
  String get onboardingLanguageHint =>
      'You can change this any time in Settings.';

  @override
  String get onboardingBibleTitle => 'Your Bible';

  @override
  String get onboardingBibleBody =>
      'Pick the translation you read most. You can show a second one side by side.';

  @override
  String onboardingParallel(String name) {
    return 'Also show $name alongside';
  }

  @override
  String get onboardingLookTitle => 'Make it comfortable';

  @override
  String get onboardingLookBody =>
      'Choose a page colour and text size. Everything can be fine-tuned later.';

  @override
  String get onboardingThemeLight => 'Light';

  @override
  String get onboardingThemeSepia => 'Sepia';

  @override
  String get onboardingThemeDark => 'Dark';

  @override
  String get onboardingTextSize => 'Text size';

  @override
  String get onboardingPreviewVerse =>
      'In the beginning was the Word, and the Word was with God, and the Word was God.';

  @override
  String get onboardingPreviewRef => 'John 1:1';

  @override
  String get onboardingFeaturesTitle => 'Everything for your daily walk';

  @override
  String get onboardingFeatureWordTitle => 'The Pure Word';

  @override
  String get onboardingFeatureWordBody =>
      'Read without distraction, with highlights, notes and bookmarks.';

  @override
  String get onboardingFeaturePlansTitle => 'Reading Plans';

  @override
  String get onboardingFeaturePlansBody =>
      'Chronological, thematic or your own — with gentle reminders.';

  @override
  String get onboardingFeatureStudyTitle => 'Deep Study';

  @override
  String get onboardingFeatureStudyBody =>
      'Commentary, dictionary, Strong\'s and maps, right beside the text.';

  @override
  String get onboardingFeatureSyncTitle => 'Kept safe';

  @override
  String get onboardingFeatureSyncBody =>
      'Sign in any time to sync across your devices. No account needed to read.';

  @override
  String get onboardingBegin => 'Begin reading';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get plansContinueReading => 'Continue Reading';

  @override
  String get plansResume => 'Resume';

  @override
  String plansDayCompleteCelebration(int day) {
    return 'Reading Plan\nDay $day Complete!';
  }

  @override
  String get plansChangeWeek => 'Change week';

  @override
  String plansCalendarDayComplete(String label) {
    return '$label, reading complete';
  }

  @override
  String plansCalendarDayToday(String label) {
    return '$label, today';
  }

  @override
  String get plansDailyVerses => 'Daily Verses';

  @override
  String get plansToday => 'Today';

  @override
  String get plansYesterday => 'Yesterday';

  @override
  String plansDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get plansHello => 'Hello,';

  @override
  String plansOpenStory(String caption) {
    return 'Open story: $caption';
  }

  @override
  String get plansBibleStory => 'Bible story';

  @override
  String plansSlotsFull(int count) {
    return 'All $count plan slots are in use. Pause a plan to free a slot — progress is kept.';
  }

  @override
  String get plansPausedSnack => 'Plan paused — all progress is kept.';

  @override
  String get plansBrowseToStart => 'Browse Reading to start your first plan.';

  @override
  String get plansFriend => 'Friend';

  @override
  String get plansTitle => 'Plans';

  @override
  String get plansTabReading => 'Reading';

  @override
  String get plansTabBooks => 'Books';

  @override
  String plansTabMyPlans(int count) {
    return 'My Plans ($count)';
  }

  @override
  String get plansNotStarted => 'Not started';

  @override
  String plansPercentDone(int percent) {
    return '$percent% done';
  }

  @override
  String get plansOpen => 'Open';

  @override
  String get plansPaused => 'Paused';

  @override
  String get plansStarted => 'Started';

  @override
  String plansDaysBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days behind',
      one: '1 day behind',
    );
    return '$_temp0';
  }

  @override
  String get plansCaughtUp => 'Caught up';

  @override
  String get plansComplete => 'Complete';

  @override
  String plansDayOfTotalLeft(int current, int total, int left) {
    return 'Day $current of $total · $left left';
  }

  @override
  String get plansPauseKeepsProgress => 'Pause (keeps progress)';

  @override
  String get plansStart => 'Start';

  @override
  String plansPresetBookTitle(String book, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$book in $days days',
      one: '$book in 1 day',
    );
    return '$_temp0';
  }

  @override
  String plansPresetGospelsTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Gospels in $days days',
      one: 'Gospels in 1 day',
    );
    return '$_temp0';
  }

  @override
  String plansPresetSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days · tap to build',
      one: '1 day · tap to build',
    );
    return '$_temp0';
  }

  @override
  String get plansYourCustomPlans => 'YOUR CUSTOM PLANS';

  @override
  String plansDayOfTotal(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get plansCustomPlan => 'Custom plan';

  @override
  String get plansNoActivePlans => 'No active plans';

  @override
  String get plansNoActivePlansBody =>
      'Browse Reading or Books to start your first plan.';

  @override
  String get plansLetsRead => 'Let\'s read';

  @override
  String get plansVerseOfTheDay => 'Verse of the day';

  @override
  String get plansOpenTodaysReading => 'Open today\'s reading';

  @override
  String get plansLastDayOfYear => 'Last day of the year';

  @override
  String plansDaysLeftInYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left in the year',
      one: '1 day left in the year',
    );
    return '$_temp0';
  }

  @override
  String get plansCustomPlanDefaultTitle => 'Custom Plan';

  @override
  String get plansCustom => 'Custom';

  @override
  String plansBookRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String plansCouldNotSave(String error) {
    return 'Could not save plan: $error';
  }

  @override
  String get plansBuilderTitle => 'Custom Plan Builder';

  @override
  String plansError(String error) {
    return 'Error: $error';
  }

  @override
  String get plansPlanName => 'Plan name';

  @override
  String get plansPlanNameHint => 'e.g. Genesis in 30 Days';

  @override
  String get plansReadingTracks => 'Reading tracks';

  @override
  String get plansAddTrack => 'Add track';

  @override
  String get plansTracksOverlap =>
      'Tracks overlap — shared verses are counted once in the preview below.';

  @override
  String get plansDuration => 'Duration';

  @override
  String plansDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get plansDaysSuffix => 'days';

  @override
  String get plansStartRestReminder => 'Start, rest & reminder';

  @override
  String get plansStartDate => 'Start date';

  @override
  String get plansRestDaysNeutral => 'Rest days (neutral)';

  @override
  String get plansNone => 'None';

  @override
  String get plansDailyReminder => 'Daily reminder';

  @override
  String plansReminderAt(String time) {
    return 'At $time';
  }

  @override
  String get plansOff => 'Off';

  @override
  String get plansLivePreview => 'Live preview';

  @override
  String get plansPreviewEmpty =>
      'Add at least one track above to preview the word-balanced schedule.';

  @override
  String get plansWordBalanced => 'Word-balanced · pericope-aware';

  @override
  String plansPreviewSummary(int days, int readingDays) {
    return '$days days · $readingDays reading days';
  }

  @override
  String plansClampedNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'The gentlest pace for this selection is $days days. Title updated to the real day count.',
      one:
          'The gentlest pace for this selection is 1 day. Title updated to the real day count.',
    );
    return '$_temp0';
  }

  @override
  String plansPreviewDay(int day, String portions) {
    return 'Day $day: $portions';
  }

  @override
  String plansMoreBalancedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more balanced days',
      one: '1 more balanced day',
    );
    return '$_temp0';
  }

  @override
  String get plansSaving => 'Saving…';

  @override
  String get plansGenerateAndSave => 'Generate & save plan →';

  @override
  String get plansNameAndTrackHint =>
      'Name the plan and add at least one track to continue.';

  @override
  String get plansStartEllipsis => 'Start…';

  @override
  String get plansEndEllipsis => 'End…';

  @override
  String get plansStartLabel => 'START';

  @override
  String get plansEndLabel => 'END';

  @override
  String get plansRemoveTrack => 'Remove track';

  @override
  String plansRestChip(String days) {
    return 'Rest $days';
  }

  @override
  String plansRebasedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Schedule shifted by $count reading days. Completed days untouched.',
      one: 'Schedule shifted by 1 reading day. Completed days untouched.',
    );
    return '$_temp0';
  }

  @override
  String get plansPlan => 'Plan';

  @override
  String get plansNoReadingsYet => 'This plan has no readings yet.';

  @override
  String plansReadingDaysWeeks(int days, int weeks) {
    return '$days reading days · ~$weeks weeks';
  }

  @override
  String get plansBeginPlan => 'Begin plan';

  @override
  String get plansStartDayOne => 'Start Day 1 →';

  @override
  String get plansStartDateNote => 'Your plan begins on the date you choose.';

  @override
  String get plansScheduleLabel => 'SCHEDULE';

  @override
  String get plansNoReadings => 'No readings';

  @override
  String plansPercentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get plansFlexible => 'Flexible';

  @override
  String get plansScheduled => 'Scheduled';

  @override
  String plansBehindChip(int count) {
    return '$count behind';
  }

  @override
  String get plansOnTrack => 'On track';

  @override
  String get plansFlexibleHelp =>
      'Flexible: read the oldest unread day first. Missed days don\'t add up.';

  @override
  String get plansScheduledHelp =>
      'Scheduled: each date has its reading day. Missed days count as behind — catch up below.';

  @override
  String get plansCatchUp => 'Catch up';

  @override
  String plansBehindBy(int count, int day) {
    return 'Behind by $count — oldest unread is Day $day.';
  }

  @override
  String get plansCatchUpHelp =>
      'Marking days done records progress. Shifting moves the rest of the schedule forward instead.';

  @override
  String get plansGoToOldest => 'Go to oldest';

  @override
  String get plansMarkOldestDone => 'Mark oldest done';

  @override
  String get plansAllPreviousDone => 'Everything before today is already done.';

  @override
  String plansPreviousMarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count previous days marked as read.',
      one: '1 previous day marked as read.',
    );
    return '$_temp0';
  }

  @override
  String get plansMarkAllPrevious => 'Mark all previous done';

  @override
  String plansRebaseDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Shift +$count days',
      one: 'Shift +1 day',
    );
    return '$_temp0';
  }

  @override
  String plansReadingsHeader(int count) {
    return 'READINGS · $count DAYS';
  }

  @override
  String get plansJourneyMap => 'Journey map view';

  @override
  String get plansJumpToToday => 'Jump to today';

  @override
  String plansDayN(int day) {
    return 'Day $day';
  }

  @override
  String get plansLegendDone => 'Done';

  @override
  String get plansLegendToday => 'Today = ring';

  @override
  String get plansLegendMissed => 'Missed';

  @override
  String plansReminderAtTime(String time) {
    return 'Reminder · $time';
  }

  @override
  String get plansReminderOff => 'Reminder off';

  @override
  String get plansReminderHelp =>
      'Per-plan notification — skips rest days automatically.';

  @override
  String get plansRestDays => 'Rest days';

  @override
  String get plansNoRestDays => 'No rest days';

  @override
  String get plansSettings => 'Plan settings';

  @override
  String get plansAboutEllipsis => 'About this plan…';

  @override
  String get plansAbout => 'About this plan';

  @override
  String get plansChangeStartDate => 'Change start date…';

  @override
  String plansRestDaysValue(String days) {
    return 'Rest days: $days';
  }

  @override
  String get plansRestDaysHelp => 'Tap to choose any weekdays';

  @override
  String get plansRestartFromDayOne => 'Restart from Day 1…';

  @override
  String get plansRestartTitle => 'Restart plan?';

  @override
  String get plansRestartBody => 'Completed days will be cleared.';

  @override
  String get plansRestart => 'Restart';

  @override
  String get plansMarkUnread => 'Mark unread';

  @override
  String get plansMarkRead => 'Mark read';

  @override
  String get plansRestAndReflect => 'Rest & reflect';

  @override
  String get plansRestDayBody => 'A day of rest — no reading assigned today.';

  @override
  String get plansDayDetailHelp =>
      'Tap a passage to open it. Check each one off as you read.';

  @override
  String plansMilestone(int count) {
    return '$count readings completed — keep going!';
  }

  @override
  String get plansCompletedTapToUndo => 'Completed — tap to undo';

  @override
  String plansMarkDayRead(int day, int checked, int total) {
    return 'Mark Day $day as Read ✓ ($checked/$total passages)';
  }

  @override
  String get todayGoodMorning => 'Good morning';

  @override
  String get todayGoodAfternoon => 'Good afternoon';

  @override
  String get todayGoodEvening => 'Good evening';

  @override
  String get todayGoodNight => 'Good night';

  @override
  String get todayStreakNudge => 'Read today to save your streak!';

  @override
  String get todayNotificationsSoon => 'Notifications coming soon!';

  @override
  String get todaySectionResume => 'RESUME';

  @override
  String get todaySectionStreak => 'READING STREAK';

  @override
  String get todaySectionLatestNote => 'LATEST NOTE';

  @override
  String get todaySectionQuickActions => 'QUICK ACTIONS';

  @override
  String get todaySectionReminders => 'DAILY REMINDERS';

  @override
  String get todayTagline => 'Your daily moment of peace.';

  @override
  String get todayNoNotesYet => 'No notes yet';

  @override
  String get todayWriteFirstNote => 'Write your first note to see it here.';

  @override
  String get todayViewAllNotes => 'View all notes';

  @override
  String todayStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '1 day streak',
    );
    return '$_temp0';
  }

  @override
  String todayDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days of the year remaining.',
      one: '1 day of the year remaining.',
    );
    return '$_temp0';
  }

  @override
  String get todayActionRead => 'Read';

  @override
  String get todayActionSurprise => 'Surprise Me';

  @override
  String get todayActionReadingPlan => 'Reading Plan';

  @override
  String get todayActionYourSpace => 'Your Space';

  @override
  String get todayVotdArchive => 'Verse of the Day Archive';

  @override
  String get todayVotdArchiveBody => 'Catch up on verses from days you missed.';

  @override
  String get todayVotdArchiveExplore => 'Explore your past daily verses';

  @override
  String get readActionBookmark => 'Bookmark';

  @override
  String get readActionNote => 'Note';

  @override
  String get readActionNotes => 'Notes';

  @override
  String get readActionEditNote => 'Edit Note';

  @override
  String get readActionCommentary => 'Commentary';

  @override
  String get readActionRelated => 'Related';

  @override
  String get readActionHighlight => 'Highlight';

  @override
  String get readActionStudy => 'Study';

  @override
  String get readActionSaved => 'Saved';

  @override
  String get readActionSelectText => 'Select Text';

  @override
  String get readVerseActions => 'Verse actions';

  @override
  String readVersesSelected(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses selected',
      one: '1 verse selected',
    );
    return '$_temp0 · $where';
  }

  @override
  String get readCommentaryHint =>
      'Tap the bulb icon next to a verse for commentary';

  @override
  String get readPassageNotFound => 'Passage not found.';

  @override
  String get readChapterCommentary => 'Read commentary on this chapter';

  @override
  String get readPreviousChapter => '‹ Previous';

  @override
  String get readNextChapter => 'Next ›';

  @override
  String readPlanDay(int day) {
    return 'Reading Plan · Day $day';
  }

  @override
  String get readPlanCompleted => 'Plan completed! Congratulations! 🎉';

  @override
  String readMarkDoneContinue(String book, int chapter) {
    return 'Mark $book $chapter done & continue';
  }

  @override
  String get readNone => 'None';

  @override
  String readBookFallback(int number) {
    return 'Book $number';
  }

  @override
  String get readRelatedVerses => 'Related Verses';

  @override
  String get readNoCrossRefs => 'No cross-references found for this verse.';

  @override
  String get readCrossRefsComingSoon =>
      'Cross-references will be available\nafter the next app update.';

  @override
  String readCrossRefsLoadError(String error) {
    return 'Could not load cross-references.\n$error';
  }

  @override
  String get readVerseUnavailable => 'Verse not available';

  @override
  String get readLoading => 'Loading...';

  @override
  String get readVerseNotFound => 'Verse not found.';

  @override
  String get readBookOrChapterNotFound => 'Book or chapter not found.';

  @override
  String get readOpenInRead => 'Open in Read';

  @override
  String get readBookNotFound => 'Could not find the referenced book.';

  @override
  String readVerseLoadError(String error) {
    return 'Error loading verse: $error';
  }

  @override
  String get readTestament => 'Testament';

  @override
  String get readBook => 'Book';

  @override
  String get readChapter => 'Chapter';

  @override
  String get readVerse => 'Verse';

  @override
  String get readSelectBook => 'Select Book';

  @override
  String get readOtShort => 'OT';

  @override
  String get readNtShort => 'NT';

  @override
  String get readOldTestament => 'Old Testament';

  @override
  String get readNewTestament => 'New Testament';

  @override
  String get readOldTestamentTwoLine => 'Old\nTestament';

  @override
  String get readNewTestamentTwoLine => 'New\nTestament';

  @override
  String get readStoriesSections => 'Stories & Sections';

  @override
  String get readAllVerses => 'All Verses';

  @override
  String get readTranslationTitle => 'Bible Translation';

  @override
  String get readLayoutTitle => 'Reading Layout';

  @override
  String get readLayoutSingle => 'Single';

  @override
  String get readLayoutBilingual => 'Bilingual';

  @override
  String get readLayoutParallel => 'Parallel';

  @override
  String get readLayoutChips => 'Chips';

  @override
  String get readLayoutSingleDesc => 'One translation';

  @override
  String get readLayoutBilingualDesc => 'Two translations stacked per verse';

  @override
  String get readLayoutParallelDesc =>
      'Two translations in side-by-side columns';

  @override
  String get readLayoutChipsDesc => 'Tap a verse to switch its translation';

  @override
  String get readPrimary => 'Primary';

  @override
  String get readSecondary => 'Secondary';

  @override
  String readTranslationsLoadError(String error) {
    return 'Error loading translations: $error';
  }

  @override
  String readTranslationDeleted(String name) {
    return '$name deleted.';
  }

  @override
  String readDeleteFailed(String error) {
    return 'Could not delete: $error';
  }

  @override
  String readDeleteTranslation(String name) {
    return 'Delete $name';
  }

  @override
  String get readKjvAlwaysAvailable => 'Always available · app backbone';

  @override
  String get readCannotDeleteBackbone => 'Cannot delete — app backbone';

  @override
  String get readAvailableToAdd => 'AVAILABLE TO ADD';

  @override
  String get readNoInternet =>
      'No internet connection — try again when online.';

  @override
  String get readRestoreFailed => 'Restore failed';

  @override
  String get readDownloadFailed => 'Download failed';

  @override
  String readRestoreFailedDetail(String error) {
    return 'Restore failed ($error).';
  }

  @override
  String readDownloadFailedDetail(String error) {
    return 'Download failed ($error).';
  }

  @override
  String get readRestoreOffline => 'restore offline';

  @override
  String get homeVerseOfTheDay => 'VERSE OF THE DAY';

  @override
  String get homeDevotional => 'DEVOTIONAL';

  @override
  String get homeCommentary => 'COMMENTARY';

  @override
  String get homeGoDeeper => 'Go Deeper';

  @override
  String get homeReadFullDefinition => 'Read Full Definition';

  @override
  String get homeWordOfTheDayHeading => 'WORD OF THE DAY';

  @override
  String get homeWordOfTheDay => 'Word of the day';

  @override
  String get homeWotdEmpty => 'No word picked for today yet — try again later.';

  @override
  String homeWotdUnavailable(String error) {
    return 'Word of the day unavailable ($error).';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navRead => 'Read';

  @override
  String get navStudy => 'Study';

  @override
  String get navSearch => 'Search';

  @override
  String get navExitTitle => 'Exit The Blessed Bible?';

  @override
  String get navExitMessage => 'Are you sure you want to exit the app?';

  @override
  String get navExit => 'Exit';

  @override
  String get navCastLotsError => 'Could not cast lots — please try again.';

  @override
  String get navCastingLots => 'Casting lots...';

  @override
  String get searchHint => 'Search verses, commentary…';

  @override
  String get searchAllBooks => 'All Books';

  @override
  String get searchFilterMyNotes => 'My Notes';

  @override
  String get searchEmptyPrompt =>
      'Search the Bible, commentary\nand your notes';

  @override
  String get searchRecentSearches => 'RECENT SEARCHES';

  @override
  String get searchClear => 'CLEAR';

  @override
  String get searchRecentPlaces => 'RECENT PLACES';

  @override
  String get searchMostRead => 'MOST READ';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get searchTopResults => 'Showing top 100 results';

  @override
  String searchResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results found',
      one: '1 result found',
    );
    return '$_temp0';
  }

  @override
  String searchSectionDictionary(int count) {
    return 'DICTIONARY ($count)';
  }

  @override
  String searchSectionStories(int count) {
    return 'STORIES ($count)';
  }

  @override
  String searchSectionJumpTo(int count) {
    return 'JUMP TO ($count)';
  }

  @override
  String searchSectionVerses(int count) {
    return 'VERSES ($count)';
  }

  @override
  String searchSectionCommentary(int count) {
    return 'COMMENTARY ($count)';
  }

  @override
  String searchSectionMyNotes(int count) {
    return 'MY NOTES ($count)';
  }

  @override
  String get searchCopied => 'Copied to clipboard';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTabGeneral => 'General';

  @override
  String get settingsTabNavigation => 'Navigation';

  @override
  String get settingsTabReminders => 'Reminders';

  @override
  String get settingsTabInfo => 'Info';

  @override
  String get settingsWidgetsTitle => 'Home Screen Widgets';

  @override
  String get settingsWidgetsSubtitle =>
      'Customize gradients, transparency, and live preview';

  @override
  String get settingsStartPageTitle => 'Default start page';

  @override
  String get settingsStartPageSubtitle =>
      'Choose which page the app opens to on launch';

  @override
  String get settingsPageHome => 'Home';

  @override
  String get settingsPageRead => 'Read';

  @override
  String get settingsPageStudy => 'Study';

  @override
  String get settingsPageSearch => 'Search';

  @override
  String get settingsImmersiveReading => 'Immersive Reading';

  @override
  String get settingsImmersiveOffTitle => 'Anchored (Off)';

  @override
  String get settingsImmersiveOffSubtitle =>
      'Navigation remains visible at all times';

  @override
  String get settingsImmersivePartialTitle => 'Guided (Partial)';

  @override
  String get settingsImmersivePartialSubtitle =>
      'Auto-hides main navigation, but leaves the book & chapter pill';

  @override
  String get settingsImmersiveFullTitle => 'Deep Waters (Full)';

  @override
  String get settingsImmersiveFullSubtitle =>
      'Total immersion. All menus hide when scrolling';

  @override
  String get settingsShowStrongs => 'Show Strong\'s Numbers';

  @override
  String get settingsShowStrongsSubtitle =>
      'Displays original Hebrew/Greek identifiers alongside KJV text for deep word study';

  @override
  String get settingsStrongsGetIt => 'Get it';

  @override
  String get settingsStrongsMarkerAsterisk => 'Asterisk (*)';

  @override
  String get settingsStrongsMarkerChain => 'Chain (🔗)';

  @override
  String get settingsStrongsMarkerNumber => 'Number (H1234)';

  @override
  String get settingsReadingSpeed => 'Reading speed';

  @override
  String get settingsReadingSpeedSubtitle =>
      'Pace estimates for plans (words per minute)';

  @override
  String get settingsSpeedRelaxed => 'Relaxed';

  @override
  String get settingsSpeedStandard => 'Standard';

  @override
  String get settingsSpeedBrisk => 'Brisk';

  @override
  String get settingsDictUnderlines => 'Dictionary Underlines';

  @override
  String get settingsDictUnderlinesSubtitle =>
      'Dotted underlines on biblical terms and archaic words';

  @override
  String get settingsUnderlineScope => 'Underline Scope';

  @override
  String get settingsScopeNamesTitle => 'Names & terms only';

  @override
  String get settingsScopeNamesSubtitle =>
      'Proper nouns and specific biblical concepts';

  @override
  String get settingsScopeTrickyTitle => 'Names + tricky words (Recommended)';

  @override
  String get settingsScopeTrickySubtitle =>
      'Includes archaic words with changed meanings (e.g., let, prevent)';

  @override
  String get settingsScopeEverythingTitle => 'Everything';

  @override
  String get settingsScopeEverythingSubtitle =>
      'Highlights all archaic grammar (e.g., thee, thou, hath, unto)';

  @override
  String get settingsScopeDifficultTitle => 'Difficult words only';

  @override
  String get settingsScopeDifficultSubtitle =>
      'Archaic, misleading and contested words — easy words like god and son stay unmarked';

  @override
  String get settingsScopeDifficultNamesTitle => 'Difficult + names';

  @override
  String get settingsScopeDifficultNamesSubtitle =>
      'Adds people and places (e.g., David, Jerusalem) to difficult words';

  @override
  String get settingsOtherEnglishVersions => 'Other English versions';

  @override
  String get settingsContestedOnlyTitle => 'Contested words only';

  @override
  String get settingsContestedOnlySubtitle =>
      'BBE, WEB and other English versions mark disputed words (e.g., hell, baptism)';

  @override
  String get settingsFollowScopeTitle => 'Follow underline scope';

  @override
  String get settingsFollowScopeSubtitle =>
      'Same marking as KJV in every English version';

  @override
  String get settingsNoUnderlinesTitle => 'No underlines';

  @override
  String get settingsNoUnderlinesSubtitle =>
      'Other English versions show no dictionary marks';

  @override
  String get settingsPopupStyle => 'Popup Style';

  @override
  String get settingsPopupStyleSubtitle =>
      'How dictionary definitions and Strong\'s numbers are displayed';

  @override
  String get settingsPopupFloating => 'Floating';

  @override
  String get settingsPopupBottomSheet => 'Bottom sheet';

  @override
  String get settingsSavedInMyLanguage => 'Show saved items in my language';

  @override
  String get settingsSavedInMyLanguageSubtitle =>
      'Display Bookmarks, Highlights, and Commentary verses in your active primary translation';

  @override
  String get settingsTranslationChips =>
      'Show translation options on saved items';

  @override
  String get settingsTranslationChipsSubtitle =>
      'Adds a compact translation chip row to view saved verses in other translations';

  @override
  String get settingsVerseActionStyle => 'Verse Action Style';

  @override
  String get settingsVerseActionStyleSubtitle =>
      'Sheet (compact) or Classic (tall dock) when verses are selected; Radial moves the long-press menu to a circular ring';

  @override
  String get settingsActionSheet => 'Sheet';

  @override
  String get settingsActionClassic => 'Classic';

  @override
  String get settingsActionMinimal => 'Minimal';

  @override
  String get settingsActionRaindrop => 'Raindrop';

  @override
  String get settingsActionRadial => 'Radial';

  @override
  String get settingsKeepAwake => 'Keep Screen Awake';

  @override
  String get settingsKeepAwakeSubtitle =>
      'Prevent device from sleeping while reading';

  @override
  String get settingsRestartOnboarding => 'Restart onboarding';

  @override
  String get settingsRestartOnboardingSubtitle => 'Replay the first-time setup';

  @override
  String get settingsRestartOnboardingDialogTitle => 'Restart onboarding?';

  @override
  String get settingsRestartOnboardingDialogBody =>
      'This will replay the first-time setup. Your current theme, font, and translation stay unless you change them.';

  @override
  String get settingsRestart => 'Restart';

  @override
  String get settingsAppearanceText => 'Appearance & text';

  @override
  String get settingsAppearanceTextSubtitle =>
      'Theme, fonts, sizes and reading colors';

  @override
  String get settingsSabbathTitle => 'Friday Sunset Reminder';

  @override
  String get settingsSabbathSubtitle =>
      'Welcome the Sabbath at your local sunset time.';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsLocationNotSet => 'Not set (Tap to set)';

  @override
  String get settingsDailyReminderTitle => 'Daily Reading Reminder';

  @override
  String get settingsDailyReminderSubtitle =>
      'A daily nudge to spend time in the Word.';

  @override
  String get settingsTime => 'Time';

  @override
  String get settingsWeeklyReminderTitle => 'Custom Weekly Reminder';

  @override
  String get settingsWeeklyReminderSubtitle =>
      'Set a specific day and time each week for deeper study.';

  @override
  String get settingsDayAndTime => 'Day & Time';

  @override
  String get settingsChooseDay => 'Choose Day';

  @override
  String get settingsShowReadingTips => 'Show reading tips';

  @override
  String get settingsShowReadingTipsSubtitle =>
      'Show guided hints for reading actions like highlighting and swiping';

  @override
  String get settingsNavSteps => 'Navigation Steps';

  @override
  String get settingsNavStepsSubtitle =>
      'How many steps to reach a verse. 2-step: Book → Chapter. 3-step: Book → Chapter → Verse. 4-step: Testament → Book → Chapter → Verse.';

  @override
  String get settingsAutoClose => 'Auto-close sheet on final selection';

  @override
  String get settingsAutoCloseSubtitle =>
      'Automatically dismiss the picker after the last step';

  @override
  String get settingsSelectorHeight => 'Book selector height';

  @override
  String get settingsSelectorHeightSubtitle =>
      'Control how far up the book/chapter sheet opens';

  @override
  String get settingsHeightHalf => 'Half';

  @override
  String get settingsHeightFull => 'Full';

  @override
  String get settingsAutoOpenSingle => 'Auto-open single search result';

  @override
  String get settingsAutoOpenSingleSubtitle =>
      'Automatically navigate when a search returns exactly one result';

  @override
  String get settingsIncludeNotes => 'Include personal notes in search';

  @override
  String get settingsIncludeNotesSubtitle =>
      'Allow search to look through your personal notes';

  @override
  String get settingsWholeWords => 'Match whole words only';

  @override
  String get settingsWholeWordsSubtitle =>
      'Only find exact word matches (disables partial/prefix matching)';

  @override
  String get settingsFuzzySearch => 'Forgiving search';

  @override
  String get settingsFuzzySearchSubtitle =>
      'Also show close matches for typos (e.g. Jhon finds John)';

  @override
  String get settingsDefaultScopes => 'Default Search Scopes';

  @override
  String get settingsOldTestament => 'Old Testament';

  @override
  String get settingsNewTestament => 'New Testament';

  @override
  String get settingsCommentary => 'Commentary';

  @override
  String get settingsGestures => 'Gestures';

  @override
  String get settingsPullDownHome => 'Pull down on Home';

  @override
  String get settingsPullDownHomeSubtitle =>
      'Pull down past the top to open Settings or Appearance';

  @override
  String get settingsPullDownOpens => 'Pull-down opens';

  @override
  String get settingsPullDownOpensSubtitle =>
      'Destination of the Home pull-down gesture';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsSwipeLeftHome => 'Swipe left on Home';

  @override
  String get settingsSwipeLeftHomeSubtitle =>
      'Swipe left to jump to the Read tab';

  @override
  String get settingsLongPressNav => 'Long-press button to open navigation';

  @override
  String get settingsLongPressNavSubtitle =>
      'Long-press the bottom-right button to quickly open the Book/Chapter selector.';

  @override
  String get settingsBbeNoteTitle => 'BBE Translation Note';

  @override
  String get settingsBackup => 'Back up my data';

  @override
  String get settingsBackupSubtitle => 'Export notes, highlights, and settings';

  @override
  String get settingsRestoreBackup => 'Restore from backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Import your data from a backup JSON';

  @override
  String get settingsRestoreBackupDialogTitle => 'Restore from Backup';

  @override
  String get settingsRestoreHint => 'Paste your backup JSON here...';

  @override
  String get settingsRestore => 'Restore';

  @override
  String get settingsClearCache => 'Clear cache/downloaded data';

  @override
  String get settingsClearCacheSubtitle =>
      'Free up space by removing cached files';

  @override
  String get settingsNotImplemented => 'Not yet implemented';

  @override
  String get settingsResetSettings => 'Reset settings';

  @override
  String get settingsResetSettingsSubtitle =>
      'Restore original app settings (content is kept)';

  @override
  String get settingsResetDialogTitle => 'Reset settings?';

  @override
  String get settingsResetDialogBody =>
      'Reset all settings to default? This won\'t affect your bookmarks, notes, or highlights.';

  @override
  String get settingsResetDone => 'Settings reset to default.';

  @override
  String get settingsReset => 'Reset';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsUnknown => 'Unknown';

  @override
  String get settingsStorage => 'Storage & downloads';

  @override
  String get settingsStorageSubtitle =>
      'Cache, downloaded translations and what can be freed';

  @override
  String get settingsSendFeedback => 'Send Feedback';

  @override
  String get settingsCrashReports => 'Send crash reports';

  @override
  String get settingsCrashReportsSubtitle =>
      'Anonymous crash details help fix bugs. No Bible reading, notes or personal content is included.';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsCredits => 'Credits & sources';

  @override
  String get settingsCreditsSubtitle =>
      'Bible translations, commentary, study data, fonts and licenses';

  @override
  String get settingsSetSunsetLocation => 'Set Location for Sunset';

  @override
  String get settingsCurrentLocationGps => 'Current Location (GPS)';

  @override
  String get settingsUseMyLocation => 'Use my current location';

  @override
  String get settingsOrSelectCity => 'OR select a major city';

  @override
  String get settingsTypography => 'Typography';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsSearchSettings => 'Search Settings';

  @override
  String get settingsMatchTypeHeader => 'MATCH TYPE';

  @override
  String get settingsExactMatch => 'Exact Match';

  @override
  String get settingsExactMatchSubtitle => 'Only match the exact phrase';

  @override
  String get settingsScopeHeader => 'SCOPE';

  @override
  String get settingsDisabledBookFilter => 'Disabled (Book Filter Active)';

  @override
  String get settingsMyNotes => 'My Notes';

  @override
  String get settingsBehaviorHeader => 'BEHAVIOR';

  @override
  String get settingsAutoOpenSingleShort => 'Auto-open Single Result';

  @override
  String get settingsAutoOpenSingleShortSubtitle =>
      'Jump directly if only one result is found';

  @override
  String get settingsBackgroundGlow => 'Enable Background Glow';

  @override
  String get settingsBackgroundGlowSubtitle =>
      'Renders a subtle animated light behind the reader';

  @override
  String get settingsThemeGroupFoundations => 'FOUNDATIONS';

  @override
  String get settingsThemeDawn => 'Dawn';

  @override
  String get settingsThemeFresh => 'Fresh';

  @override
  String get settingsThemeGroupFirmament => 'FIRMAMENT';

  @override
  String get settingsThemeSun => 'Sun';

  @override
  String get settingsThemeMoon => 'Moon';

  @override
  String get settingsThemeStars => 'Stars';

  @override
  String get settingsThemeGroupEden => 'EDEN';

  @override
  String get settingsThemeLilies => 'Lilies';

  @override
  String get settingsThemeRoses => 'Roses';

  @override
  String get settingsThemeOlives => 'Olives';

  @override
  String get settingsThemeGroupSanctuary => 'SANCTUARY';

  @override
  String get settingsThemePurple => 'Priestly\nPurple';

  @override
  String get settingsThemeBlue => 'Galilee\nBlue';

  @override
  String get settingsThemeRed => 'Scarlet\nRed';

  @override
  String get settingsSurpriseMe => 'Surprise me';

  @override
  String get settingsThemeOledDark => 'OLED\nDark';

  @override
  String get settingsThemeDuskOled => 'Dusk\nOLED';

  @override
  String get settingsSurfaceStyle => 'Surface Style';

  @override
  String get settingsSurfaceStyleSubtitle =>
      'Visual depth and material rendering';

  @override
  String get settingsSurfaceEarth => 'Earth';

  @override
  String get settingsSurfaceEarthSubtitle => 'Flat surface';

  @override
  String get settingsSurfaceHeaven => 'Heaven';

  @override
  String get settingsSurfaceHeavenSubtitle => 'Frosted depth';

  @override
  String get settingsSurfacePaper => 'Paper';

  @override
  String get settingsSurfacePaperSubtitle => 'Warm e-reader';

  @override
  String get settingsSurfaceClay => 'Clay';

  @override
  String get settingsSurfaceClaySubtitle => 'Pillowy 3-D';

  @override
  String get settingsWidgetsLivePreview => 'Live preview & style customization';

  @override
  String get settingsWidgetPreviewHeader => 'LIVE WIDGET PREVIEW';

  @override
  String get settingsWidgetStreak => 'Streak Active! • Daily Goal';

  @override
  String get settingsWidgetWotd => 'WORD OF THE DAY';

  @override
  String get settingsWidgetVotd => 'VERSE OF THE DAY';

  @override
  String get settingsWidgetBackgroundHeader => 'BACKGROUND THEME & GRADIENTS';

  @override
  String get settingsWidgetContrastHeader => 'TEXT CONTRAST';

  @override
  String get settingsWidgetTextAuto => 'Auto ✨';

  @override
  String get settingsWidgetTextDark => 'Dark Text ☀️';

  @override
  String get settingsWidgetTextWhite => 'White Text 🌙';

  @override
  String get settingsWidgetSynced => 'Widgets synced with new style! ✨';

  @override
  String get settingsWidgetApply => 'Apply & Sync to Home Screen';

  @override
  String get settingsFontSizeHeader => 'FONT SIZE';

  @override
  String get settingsFontWeightHeader => 'FONT WEIGHT';

  @override
  String get settingsWeightLight => 'Light';

  @override
  String get settingsWeightRegular => 'Regular';

  @override
  String get settingsWeightMedium => 'Medium';

  @override
  String get settingsWeightBold => 'Bold';

  @override
  String get settingsLineSpacingHeader => 'LINE SPACING';

  @override
  String get settingsSpacingCompact => 'Compact';

  @override
  String get settingsSpacingNormal => 'Normal';

  @override
  String get settingsMarginsHeader => 'MARGINS';

  @override
  String get settingsAlignmentHeader => 'ALIGNMENT';

  @override
  String get settingsAlignLeft => 'Left';

  @override
  String get settingsAlignCenter => 'Center';

  @override
  String get settingsAlignRight => 'Right';

  @override
  String get settingsAlignJustified => 'Justified';

  @override
  String get settingsFontFamilyHeader => 'FONT FAMILY';

  @override
  String get settingsItalicHeader => 'ITALIC READING TEXT';

  @override
  String get settingsDailyReading => 'Daily Reading';

  @override
  String get settingsCustomReminder => 'Custom Reminder';

  @override
  String get settingsMonday => 'Monday';

  @override
  String get settingsTuesday => 'Tuesday';

  @override
  String get settingsWednesday => 'Wednesday';

  @override
  String get settingsThursday => 'Thursday';

  @override
  String get settingsFriday => 'Friday';

  @override
  String get settingsSaturday => 'Saturday';

  @override
  String get settingsSunday => 'Sunday';

  @override
  String settingsStrongsPackRequired(String size) {
    return 'Requires the “KJV with Strong\'s” pack ($size download).';
  }

  @override
  String settingsBbeNoteBody(int count) {
    return 'The Bible in Basic English originally left some verses untranslated or heavily truncated. For those ($count verses), the World English Bible (WEB) text is shown instead and marked with a WEB badge.';
  }

  @override
  String settingsDayAtTime(String day, String time) {
    return '$day at $time';
  }

  @override
  String get spaceTitle => 'Your Space';

  @override
  String get spaceTabHighlights => 'Highlights';

  @override
  String get spaceTabBookmarks => 'Bookmarks';

  @override
  String get spaceTabNotes => 'Notes';

  @override
  String get spaceTabJournal => 'Journal';

  @override
  String get spaceHighlighted => 'Highlighted';

  @override
  String get spaceNewFolder => 'New Folder';

  @override
  String get spaceFolderNameHint => 'Folder name';

  @override
  String get spaceCreate => 'Create';

  @override
  String get spaceRenameFolder => 'Rename Folder';

  @override
  String get spaceRename => 'Rename';

  @override
  String get spaceDeleteFolderTitle => 'Delete Folder?';

  @override
  String spaceDeleteFolderBody(String folderName) {
    return 'Are you sure you want to delete \"$folderName\"?\n\nYour bookmarks inside this folder will NOT be deleted; they will be moved to Unfiled.';
  }

  @override
  String get spaceMoveToFolder => 'Move to Folder';

  @override
  String get spaceUnfiled => 'Unfiled';

  @override
  String get spaceGroupEarlier => 'Earlier';

  @override
  String get spaceGroupLast7Days => 'Last 7 Days';

  @override
  String get spaceGroupLast30Days => 'Last 30 Days';

  @override
  String get spaceUnknownBook => 'Unknown Book';

  @override
  String get spaceNoBookmarks => 'No bookmarks here.';

  @override
  String get spaceFilterAll => 'All';

  @override
  String get spaceByDate => 'By Date';

  @override
  String get spaceByBook => 'By Book';

  @override
  String get spaceYourNotes => 'Your notes.';

  @override
  String get spaceNoNotesTapPlus => 'No notes yet.\nTap + to create one.';

  @override
  String get spaceMore => 'More';

  @override
  String get spaceNote => 'Note';

  @override
  String get spaceCopyText => 'Copy text';

  @override
  String get spaceDeleteNoteTitle => 'Delete note?';

  @override
  String spaceDeleteNoteBody(String title) {
    return '\"$title\" will be removed permanently.';
  }

  @override
  String get spaceUntitled => 'Untitled';

  @override
  String get spaceBookmarkedVerse => 'Bookmarked verse';

  @override
  String get spaceHighlightedVerse => 'Highlighted verse';

  @override
  String get spaceOpenInRead => 'Open in Read';

  @override
  String get spaceAddNote => 'Add note';

  @override
  String get spaceCopyVerse => 'Copy verse';

  @override
  String get spaceShareVerse => 'Share verse';

  @override
  String get spaceChangeColour => 'Change colour';

  @override
  String get spaceMoveToFolderAction => 'Move to folder';

  @override
  String get spaceRemoveBookmark => 'Remove bookmark';

  @override
  String get spaceRemoveHighlight => 'Remove highlight';

  @override
  String get spaceHighlightColour => 'Highlight colour';

  @override
  String spaceColourN(int index) {
    return 'Colour $index';
  }

  @override
  String get notesMyNotes => 'My Notes';

  @override
  String get notesEmptyTitle => 'No notes yet';

  @override
  String get notesEmptyBody => 'Tap the + button to add your first note.';

  @override
  String get notesVerseInserted => 'Verse inserted';

  @override
  String get notesAddCommentary => 'Add Commentary';

  @override
  String get notesChapterTitlePlaceholder => 'Chapter Title';

  @override
  String get notesEditNote => 'Edit Note';

  @override
  String notesNewNoteOn(String reference) {
    return 'New Note on $reference';
  }

  @override
  String get notesNewNote => 'New Note';

  @override
  String get notesTitleHint => 'Note Title';

  @override
  String get notesContentHint => 'Start typing... (type / for commands)';

  @override
  String get notesInsertVerse => 'Insert verse';

  @override
  String get notesInsertDate => 'Insert date';

  @override
  String get notesInsertChapterTitle => 'Insert chapter title';

  @override
  String get notesSaved => 'Note saved!';

  @override
  String get notesSaveChanges => 'Save Changes';

  @override
  String get notesSaveNote => 'Save Note';

  @override
  String get notesDeleted => 'Note deleted';

  @override
  String get notesDeleteNote => 'Delete Note';

  @override
  String get notesNewJournalEntry => 'New Journal Entry';

  @override
  String get notesJournalHint =>
      'How are you feeling today? Pour your heart out...';

  @override
  String get notesSaveAndAnalyze => 'Save & Analyze';

  @override
  String get notesNoJournalEntries => 'No journal entries yet.';

  @override
  String get notesWriteEntry => 'Write Entry';

  @override
  String get notesAiReflection => 'AI Reflection';

  @override
  String notesDetectedEmotion(String emotion) {
    return 'Detected Emotion: $emotion';
  }

  @override
  String notesVersesList(String verses) {
    return 'Verses: $verses';
  }

  @override
  String get accountGuest => 'Guest';

  @override
  String get accountSignInToSync => 'Sign in to sync across devices';

  @override
  String get accountAccount => 'Account';

  @override
  String get accountSettings => 'Settings';

  @override
  String get accountBackUp => 'Back up data';

  @override
  String get accountBackUpSubtitle => 'Export notes, highlights and settings';

  @override
  String get accountRestore => 'Restore data';

  @override
  String get accountRestoreSubtitle => 'Import from a backup file';

  @override
  String get accountSignInGoogle => 'Sign in with Google';

  @override
  String get accountSignInApple => 'Sign in with Apple';

  @override
  String get accountSignOut => 'Sign Out';

  @override
  String get accountResetApp => 'Reset app';

  @override
  String get accountResetAppSubtitle => 'Erase all on-device data';

  @override
  String get accountSignIn => 'Sign In';

  @override
  String get accountSignedIn => 'Signed In';

  @override
  String get accountDeleteAccount => 'Delete Account';

  @override
  String get accountDeleteAccountTitle => 'Delete Account?';

  @override
  String get accountDeleteAccountBody =>
      'This is permanent and irreversible.\n\nThe following will be completely removed:\n• Your sign-in account\n• Its cloud data in The Blessed Bible and Blessed Arcade (they share the account)\n• All on-device study data (bookmarks, highlights, history)';

  @override
  String get accountDeleted => 'Account deleted successfully.';

  @override
  String accountReauthFailed(String reason) {
    return 'Couldn\'t confirm it\'s you, so nothing was deleted. $reason';
  }

  @override
  String get accountDeleteFailed =>
      'Failed to delete account. Please try again.';

  @override
  String get accountOtherDataTitle =>
      'This device has data from another account';

  @override
  String get accountOtherDataBody =>
      'Your bookmarks, highlights and notes on this device came from a different account. What should happen to them?';

  @override
  String get accountStartFresh => 'Start fresh on this device';

  @override
  String get accountMerge => 'Merge into this account';

  @override
  String get accountSignOutTitle => 'Sign out?';

  @override
  String get accountSignOutBody =>
      'Your bookmarks, highlights and notes stay safe in your account. Keep a copy on this device?';

  @override
  String get accountRemoveFromDevice => 'Remove from device';

  @override
  String get accountKeepOnDevice => 'Keep on device';

  @override
  String get accountSyncing => 'Syncing…';

  @override
  String get accountSyncFailed => 'Couldn\'t sync';

  @override
  String get accountTapToRetry => 'Tap to try again';

  @override
  String get accountSyncPaused => 'Sync paused';

  @override
  String get accountSyncChoose => 'Choose what to do with this device\'s data';

  @override
  String get accountSyncNow => 'Sync now';

  @override
  String get accountNotSyncedYet => 'Not synced yet';

  @override
  String get accountSyncedJustNow => 'Synced just now';

  @override
  String accountSyncedMinAgo(int minutes) {
    return 'Synced $minutes min ago';
  }

  @override
  String accountSyncedHoursAgo(int hours) {
    return 'Synced $hours h ago';
  }

  @override
  String accountSyncedOn(int day, int month, int year) {
    return 'Synced $day/$month/$year';
  }

  @override
  String get accountRestoreTitle => 'Restore from Backup';

  @override
  String get accountRestoreHint => 'Paste your backup JSON here...';

  @override
  String get accountRestoreAction => 'Restore';

  @override
  String get accountResetTitle => 'Reset app?';

  @override
  String get accountResetBody =>
      'This erases all on-device data:\n• Bookmarks, highlights, notes & journal\n• Reading plans, progress & custom plans\n• Downloaded translations & streaks\n\nSettings, theme and the offline Bible stay untouched. This cannot be undone — back up first if needed.';

  @override
  String get accountResetDone => 'App data reset. Fresh start!';

  @override
  String get accountReset => 'Reset';

  @override
  String get shareBackdrop => 'Backdrop';

  @override
  String get shareBackdropDawn => 'Dawn';

  @override
  String get shareBackdropDusk => 'Dusk';

  @override
  String get shareBackdropArtwork => 'Artwork';

  @override
  String get shareBackdropGradient => 'Gradient';

  @override
  String get shareFont => 'Font';

  @override
  String get shareFontTheme => 'Theme';

  @override
  String get shareSize => 'Size';

  @override
  String get shareSpacing => 'Spacing';

  @override
  String get shareSpacingNormal => 'Normal';

  @override
  String shareSpacingWide(String value) {
    return 'Wide $value';
  }

  @override
  String get shareLineHeight => 'Line height';

  @override
  String get shareAlignment => 'Alignment';

  @override
  String get shareAlignCenter => 'Center';

  @override
  String get shareAlignLeft => 'Left';

  @override
  String get sharePreparing => 'Preparing…';

  @override
  String get shareImage => 'Share image';

  @override
  String get shareText => 'Share text';

  @override
  String get shareImageCard => 'Share image card';

  @override
  String get spaceStorageTitle => 'Storage';

  @override
  String get spaceClearCacheTitle => 'Clear cache?';

  @override
  String get spaceClearCacheBody =>
      'Removes temporary files (generated share cards, thumbnails). Your notes, bookmarks, highlights and downloads are untouched.';

  @override
  String get spaceClearCache => 'Clear cache';

  @override
  String get spaceCacheCleared => 'Cache cleared';

  @override
  String spaceDeletePackTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String spaceDeletePackBundled(String size) {
    return 'Frees $size. You can restore it offline from the app at any time.';
  }

  @override
  String spaceDeletePackDownloaded(String size) {
    return 'Frees $size. You can download it again later.';
  }

  @override
  String spacePackDeleted(String abbr) {
    return '$abbr deleted';
  }

  @override
  String spacePackDownloaded(String abbr) {
    return '$abbr downloaded';
  }

  @override
  String spaceCouldNotFinish(String error) {
    return 'Could not finish: $error';
  }

  @override
  String spaceFreed(String message, String size) {
    return '$message · freed $size';
  }

  @override
  String get spaceOnThisDevice => 'On this device';

  @override
  String get spaceBibleContent => 'Bible content (always kept)';

  @override
  String get spaceDownloadedPacks => 'Downloaded packs';

  @override
  String get spaceCache => 'Cache';

  @override
  String get spaceCacheExplain =>
      'Temporary files only — generated share cards and thumbnails. Safe to clear at any time.';

  @override
  String get spaceTranslationsDownloads => 'Translations & downloads';

  @override
  String get spaceBundledSuffix => ' · bundled';

  @override
  String get spaceCoreNotRemovable =>
      'Core KJV and BBE are part of the app and can\'t be removed.';

  @override
  String get spaceGet => 'Get';

  @override
  String spaceDeletePackTooltip(String name) {
    return 'Delete $name';
  }

  @override
  String studyCouldNotOpenScreen(String error) {
    return 'Could not open that screen. $error';
  }

  @override
  String get studyCardSize => 'Card size';

  @override
  String get studyPosition => 'Position';

  @override
  String get studySizeLarge => 'Large';

  @override
  String get studySizeLargeHint => 'Full width, same size as everything';

  @override
  String get studySizeExtraLarge => 'Extra Large';

  @override
  String get studySizeExtraLargeHint => 'Full width, roomier content';

  @override
  String get studySizeHalf => 'Half';

  @override
  String get studySizeHalfHint => 'Compact, two per row';

  @override
  String get studyMoveUp => 'Move up';

  @override
  String get studyMoveUpHint => 'Swap with the card above';

  @override
  String get studyMoveDown => 'Move down';

  @override
  String get studyMoveDownHint => 'Swap with the card below';

  @override
  String get studyCommentaryEyebrow => 'Commentary';

  @override
  String get studyCommentaryTitle => 'Verse-by-verse insight';

  @override
  String get studyCommentarySnippet =>
      'Historicist commentary with chapter + verse filters.';

  @override
  String get studyCommentaryCta => 'Open Commentary';

  @override
  String get studyDictionaryEyebrow => 'Dictionary';

  @override
  String get studyDictionaryTitle => 'Words defined';

  @override
  String get studyDictionarySnippet =>
      'Easton & Smith, offline, with saved words.';

  @override
  String get studyDictionaryCta => 'Look up';

  @override
  String get studyStoriesEyebrow => 'Bible stories';

  @override
  String get studyStoriesTitle => 'Narratives retold';

  @override
  String get studyStoriesSnippet => '66 stories across every book.';

  @override
  String get studyStoriesCta => 'Read stories';

  @override
  String get studyConcordanceEyebrow => 'Concordance';

  @override
  String get studyConcordanceTitle => 'Every occurrence';

  @override
  String get studyConcordanceSnippet => 'Find each verse where a word appears.';

  @override
  String get studyConcordanceCta => 'Search words';

  @override
  String get studySpaceSaved => 'Saved';

  @override
  String get studySpaceMarked => 'Marked';

  @override
  String get studySpaceNotes => 'Notes';

  @override
  String get studySpaceJournal => 'Journal';

  @override
  String get studySpaceTitle => 'Your Space';

  @override
  String get studySpaceSubtitle => 'Bookmarks, highlights, notes & journal';

  @override
  String get studyReadingPlan => 'Reading plan';

  @override
  String get studyStartReadingPlan => 'Start a reading plan';

  @override
  String get studyActivePlan => 'Active plan';

  @override
  String studyDayOfTotal(int current, int total) {
    return 'Day $current of $total';
  }

  @override
  String studyDaysBehind(int count) {
    return '$count behind';
  }

  @override
  String get studyPlans => 'Plans';

  @override
  String get studyGuidedReading => 'Guided reading';

  @override
  String get studyGuidedReadingSubtitle => 'Curated, paced and custom';

  @override
  String get studyReadyToBegin => 'Ready to begin';

  @override
  String studyTodayLabel(String label) {
    return 'Today: $label';
  }

  @override
  String get studyReview => 'Review';

  @override
  String get studyRead => 'Read';

  @override
  String studyCtaArrow(String cta) {
    return '$cta →';
  }

  @override
  String get studyWordOfTheDay => 'Word of the day';

  @override
  String get studyArchiveLink => 'Archive →';

  @override
  String get studyLoading => 'Loading…';

  @override
  String get studyUnavailableNow => 'Unavailable right now';

  @override
  String get studyReadingStreak => 'Reading streak';

  @override
  String get studyStartStreak => 'Start your streak';

  @override
  String studyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get studyStreakGrow => 'Open daily to grow it.';

  @override
  String get studyStreakStart => 'Complete a reading each day.';

  @override
  String get studyViewProgress => 'View progress →';

  @override
  String get studyPassageNotFound => 'Passage not found';

  @override
  String get studyPassageLoadError => 'Could not load passage data.';

  @override
  String get studyCompletedCheck => '✓ Completed';

  @override
  String get studyMarkAsRead => 'Mark as Read';

  @override
  String get studyNextPassage => 'Next Passage';

  @override
  String get studyFullChapter => 'Full chapter';

  @override
  String studyPassageOfTotal(int current, int total) {
    return 'Passage $current of $total';
  }

  @override
  String studySelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get studyHighlight => 'Highlight';

  @override
  String get studyBookmark => 'Bookmark';

  @override
  String get studyAddNote => 'Add Note';

  @override
  String studyChaptersWithContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters with content',
      one: '1 chapter with content',
    );
    return '$_temp0';
  }

  @override
  String get studyCommentaryLibrary => 'Commentary Library';

  @override
  String get studyCommentaryLoadError => 'Could not load commentary.';

  @override
  String get studyNoCommentaryYet => 'No commentary available yet.';

  @override
  String studyNoBooksMatch(String query) {
    return 'No books match \"$query\".';
  }

  @override
  String studySearchBooksCount(int count) {
    return 'Search $count books…';
  }

  @override
  String get studyClassicSources => 'Classic sources';

  @override
  String studyBookAuthorChapters(String author, int count) {
    return '$author · $count ch';
  }

  @override
  String studyReadingRef(String reference) {
    return 'Reading · $reference';
  }

  @override
  String get studyAllSources => 'All sources';

  @override
  String get studyVerseLevel => 'Verse-level';

  @override
  String studySearchWithin(String reference) {
    return 'Search within $reference…';
  }

  @override
  String studyEntriesLoadError(String error) {
    return 'Could not load entries.\n$error';
  }

  @override
  String get studyNoEntriesMatch =>
      'No entries match these filters.\nTry All sources, or browse the library.';

  @override
  String studyVerseN(int verse) {
    return 'Verse $verse';
  }

  @override
  String get studyChapter => 'Chapter';

  @override
  String get studyCategoryCommentary => 'Commentary';

  @override
  String get studyCategoryDevotional => 'Devotional';

  @override
  String get studyCategoryStudyNote => 'Study Note';

  @override
  String studyCommentaryLoadErrorDetail(String error) {
    return 'Could not load commentary.\n$error';
  }

  @override
  String get studyNoContentForFilters => 'No content found for these filters.';

  @override
  String studyVerseLabel(String verse) {
    return 'Verse $verse';
  }

  @override
  String get studyChapterView => 'Chapter View';

  @override
  String get studyFilterAll => 'All';

  @override
  String get studyFilterDevotionals => 'Devotionals';

  @override
  String get studyFilterAllContexts => 'All Contexts';

  @override
  String get studyFilterChapterLevel => 'Chapter Level';

  @override
  String get studyFilterVerseLevel => 'Verse Level';

  @override
  String get studyRemoveBookmark => 'Remove Bookmark';

  @override
  String get studyBookmarkCommentary => 'Bookmark Commentary';

  @override
  String get studyExpandFullScreen => 'Expand to full screen';

  @override
  String get studyTapToReadInContext => 'Tap to read in context';

  @override
  String get studyOnThisChapter => 'On this chapter';

  @override
  String get studyOnThisBook => 'On this book';

  @override
  String get studyNoCommentaryTitle => 'No commentary yet';

  @override
  String get studyNoCommentaryBody =>
      'We couldn\'t find specific commentary for this passage. Try exploring the chapter or book-level commentary below.';

  @override
  String get storiesTitle => 'Bible Stories';

  @override
  String get storiesFilters => 'Filters';

  @override
  String get storiesSubtitle =>
      '500 illustrated moments from Genesis to Revelation';

  @override
  String get storiesSearchHint => 'Search title, book, or reference…';

  @override
  String get storiesClearSearch => 'Clear search';

  @override
  String get storiesFilterAll => 'All';

  @override
  String get storiesFilterOt => 'OT';

  @override
  String get storiesFilterNt => 'NT';

  @override
  String storiesCountOfTotal(int count, int total) {
    return '$count of $total stories';
  }

  @override
  String get storiesFavorites => 'Favorites';

  @override
  String get storiesUnread => 'Unread';

  @override
  String storiesLoadError(String error) {
    return 'Could not load stories:\n$error';
  }

  @override
  String get storiesBooks => 'Books';

  @override
  String get storiesSearchBooks => 'Search books…';

  @override
  String get storiesAllBooks => 'All books';

  @override
  String get storiesNoMatch => 'No stories match these filters.';

  @override
  String get storiesNoFavorites => 'No favorites yet.';

  @override
  String get storiesBrowseAll => 'Browse all stories';

  @override
  String get storiesAllCaughtUp => 'You\'re all caught up.';

  @override
  String get storiesShowRead => 'Show read stories';

  @override
  String get storiesClearFilters => 'Clear filters';

  @override
  String get storiesFavoritesHint => 'Tap ♥ on any story to save it here.';

  @override
  String get storiesAttribution =>
      'Scripture from the King James Version (public domain). Narrative summaries adapted from The Graham Bible (grahambible.com), AI-assisted and human reviewed. Artwork: Gustave Doré (1832–1883), public domain, via Wikimedia Commons.';

  @override
  String get storiesReachedEnd => 'You have reached the end.';

  @override
  String get storiesFirstStory => 'This is the first story.';

  @override
  String get storiesFavorite => 'Favorite';

  @override
  String get storiesMarkAsRead => 'Mark as read';

  @override
  String storiesKeyVerse(String reference) {
    return 'KEY VERSE · $reference';
  }

  @override
  String get storiesTheStory => 'THE STORY';

  @override
  String storiesArtworkCaption(String caption) {
    return 'Artwork: $caption — Gustave Doré, public domain';
  }

  @override
  String get storiesPrevious => 'Previous story';

  @override
  String get storiesNext => 'Next story';

  @override
  String get studyDictionarySearchHint => 'Search 3,400+ words…';

  @override
  String get studyDictionarySavedFilter => '★ Saved';

  @override
  String studyDictionaryUnavailable(String error) {
    return 'Dictionary unavailable.\n$error';
  }

  @override
  String get studyNoHeadwords => 'No headwords found.';

  @override
  String get studyDictionaryNoMatches =>
      'No matches. Try “grace”, “atonement” or “wilderness”.';

  @override
  String studyResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get studyUntitledEntry => '(untitled entry)';

  @override
  String get studyRemoveSavedWord => 'Remove saved word';

  @override
  String get studySaveWord => 'Save word';

  @override
  String get studyNoDefinition => 'No definition found.';

  @override
  String studyFailedToLoad(String error) {
    return 'Failed to load: $error';
  }

  @override
  String studyStrongsShareText(String id, String lemma, String transliteration,
      String pronunciation, String definition) {
    return '$id - $lemma\n\nTransliteration: $transliteration\nPronunciation: $pronunciation\n\nDefinition:\n$definition';
  }

  @override
  String studyNoStrongsEntry(String id) {
    return 'No entry found for $id.';
  }

  @override
  String get studyStrongsLexicon => 'STRONG\'S LEXICON';

  @override
  String get studyConcordanceHint => 'Type a word (e.g., grace, covenant)…';

  @override
  String get studyConcordanceIntro =>
      'KJV occurrences — tap a verse to read it in context.';

  @override
  String get studyConcordanceEmpty =>
      'Every verse containing your word, in canonical order.';

  @override
  String get studyConcordanceSingleWord =>
      'Enter a single English word to search.';

  @override
  String studyConcordanceNoVerses(String word) {
    return 'No verses contain \"$word\".';
  }

  @override
  String studyConcordanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses',
      one: '1 verse',
    );
    return '$_temp0';
  }

  @override
  String studyConcordanceCountTruncated(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses',
      one: '1 verse',
    );
    return '$_temp0 (first $limit shown)';
  }

  @override
  String get creditsTitle => 'Credits & sources';

  @override
  String get creditsLicenses => 'Open-source licenses';

  @override
  String get creditsLicensesSubtitle => 'Fonts and software packages';

  @override
  String studyPreparingOfflineBible(int percent) {
    return 'Preparing offline Bible… $percent%';
  }

  @override
  String get errorTitle => 'Something Went Wrong';

  @override
  String get errorBody =>
      'An unexpected issue occurred. Tap below to return to the home screen.';

  @override
  String get errorBackHome => 'Back to Home';

  @override
  String studyWeekN(int week) {
    return 'Week $week';
  }

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyLoadError => 'Could not load the privacy policy.';

  @override
  String privacyEffectiveDate(String date) {
    return 'Effective Date: $date';
  }

  @override
  String get privacyEnglishOnly => 'This policy is provided in English.';

  @override
  String get privacyViewOnline => 'View online';
}
