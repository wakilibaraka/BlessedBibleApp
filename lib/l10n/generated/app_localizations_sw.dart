// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'The Blessed Bible';

  @override
  String get commonCancel => 'Ghairi';

  @override
  String get commonContinue => 'Endelea';

  @override
  String get commonSkip => 'Ruka';

  @override
  String get commonBack => 'Rudi';

  @override
  String get commonDone => 'Imekamilika';

  @override
  String get commonSave => 'Hifadhi';

  @override
  String get commonDelete => 'Futa';

  @override
  String get commonClose => 'Funga';

  @override
  String get commonOk => 'Sawa';

  @override
  String get commonRetry => 'Jaribu tena';

  @override
  String get commonShare => 'Shiriki';

  @override
  String get commonCopy => 'Nakili';

  @override
  String get commonEdit => 'Hariri';

  @override
  String get commonSearch => 'Tafuta';

  @override
  String get languageTitle => 'Lugha';

  @override
  String get languageSystem => 'Sawa na kifaa';

  @override
  String get languageSubtitle =>
      'Lugha ya menyu na vitufe. Tafsiri ya Biblia huchaguliwa kando.';

  @override
  String get onboardingTagline => 'Maandiko, bila usumbufu.';

  @override
  String get onboardingPickLanguage => 'Chagua lugha yako';

  @override
  String get onboardingLanguageHint =>
      'Unaweza kuibadilisha wakati wowote kwenye Mipangilio.';

  @override
  String get onboardingBibleTitle => 'Biblia yako';

  @override
  String get onboardingBibleBody =>
      'Chagua tafsiri unayosoma zaidi. Unaweza kuonyesha nyingine ya pili kando yake.';

  @override
  String onboardingParallel(String name) {
    return 'Onyesha pia $name kando';
  }

  @override
  String get onboardingLookTitle => 'Soma kwa starehe';

  @override
  String get onboardingLookBody =>
      'Chagua rangi ya ukurasa na ukubwa wa maandishi. Kila kitu kinaweza kurekebishwa baadaye.';

  @override
  String get onboardingThemeLight => 'Mwanga';

  @override
  String get onboardingThemeSepia => 'Sepia';

  @override
  String get onboardingThemeDark => 'Giza';

  @override
  String get onboardingTextSize => 'Ukubwa wa maandishi';

  @override
  String get onboardingPreviewVerse =>
      'Hapo mwanzo kulikuwako Neno, naye Neno alikuwako kwa Mungu, naye Neno alikuwa Mungu.';

  @override
  String get onboardingPreviewRef => 'Yohana 1:1';

  @override
  String get onboardingFeaturesTitle =>
      'Kila kitu kwa safari yako ya kila siku';

  @override
  String get onboardingFeatureWordTitle => 'Neno Safi';

  @override
  String get onboardingFeatureWordBody =>
      'Soma bila usumbufu, ukiwa na alama, maelezo na vialamisho.';

  @override
  String get onboardingFeaturePlansTitle => 'Mipango ya Kusoma';

  @override
  String get onboardingFeaturePlansBody =>
      'Ya mpangilio wa wakati, ya mada au yako mwenyewe — pamoja na vikumbusho vya upole.';

  @override
  String get onboardingFeatureStudyTitle => 'Mafunzo ya Kina';

  @override
  String get onboardingFeatureStudyBody =>
      'Maelezo, kamusi, Strong na ramani, kando ya maandiko.';

  @override
  String get onboardingFeatureSyncTitle => 'Salama';

  @override
  String get onboardingFeatureSyncBody =>
      'Ingia wakati wowote ili kusawazisha vifaa vyako. Huhitaji akaunti ili kusoma.';

  @override
  String get onboardingBegin => 'Anza kusoma';

  @override
  String onboardingStep(int current, int total) {
    return 'Hatua $current kati ya $total';
  }

  @override
  String get plansContinueReading => 'Endelea Kusoma';

  @override
  String get plansResume => 'Endelea';

  @override
  String plansDayCompleteCelebration(int day) {
    return 'Mpango wa Kusoma\nSiku $day Imekamilika!';
  }

  @override
  String get plansChangeWeek => 'Badilisha wiki';

  @override
  String plansCalendarDayComplete(String label) {
    return '$label, usomaji umekamilika';
  }

  @override
  String plansCalendarDayToday(String label) {
    return '$label, leo';
  }

  @override
  String get plansDailyVerses => 'Mistari ya Kila Siku';

  @override
  String get plansToday => 'Leo';

  @override
  String get plansYesterday => 'Jana';

  @override
  String plansDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Siku $count zilizopita',
      one: 'Siku 1 iliyopita',
    );
    return '$_temp0';
  }

  @override
  String get plansHello => 'Habari,';

  @override
  String plansOpenStory(String caption) {
    return 'Fungua hadithi: $caption';
  }

  @override
  String get plansBibleStory => 'Hadithi ya Biblia';

  @override
  String plansSlotsFull(int count) {
    return 'Nafasi zote $count za mipango zinatumika. Sitisha mpango mmoja ili kupata nafasi — maendeleo yanahifadhiwa.';
  }

  @override
  String get plansPausedSnack =>
      'Mpango umesitishwa — maendeleo yote yamehifadhiwa.';

  @override
  String get plansBrowseToStart =>
      'Vinjari Kusoma ili kuanza mpango wako wa kwanza.';

  @override
  String get plansFriend => 'Rafiki';

  @override
  String get plansTitle => 'Mipango';

  @override
  String get plansTabReading => 'Kusoma';

  @override
  String get plansTabBooks => 'Vitabu';

  @override
  String plansTabMyPlans(int count) {
    return 'Mipango Yangu ($count)';
  }

  @override
  String get plansNotStarted => 'Haujaanza';

  @override
  String plansPercentDone(int percent) {
    return '$percent% imekamilika';
  }

  @override
  String get plansOpen => 'Fungua';

  @override
  String get plansPaused => 'Imesitishwa';

  @override
  String get plansStarted => 'Imeanza';

  @override
  String plansDaysBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nyuma kwa siku $count',
      one: 'Nyuma kwa siku 1',
    );
    return '$_temp0';
  }

  @override
  String get plansCaughtUp => 'Umefikia';

  @override
  String get plansComplete => 'Imekamilika';

  @override
  String plansDayOfTotalLeft(int current, int total, int left) {
    return 'Siku $current kati ya $total · zimebaki $left';
  }

  @override
  String get plansPauseKeepsProgress => 'Sitisha (huhifadhi maendeleo)';

  @override
  String get plansStart => 'Anza';

  @override
  String plansPresetBookTitle(String book, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$book kwa siku $days',
      one: '$book kwa siku 1',
    );
    return '$_temp0';
  }

  @override
  String plansPresetGospelsTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Injili kwa siku $days',
      one: 'Injili kwa siku 1',
    );
    return '$_temp0';
  }

  @override
  String plansPresetSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Siku $days · gusa ili kuunda',
      one: 'Siku 1 · gusa ili kuunda',
    );
    return '$_temp0';
  }

  @override
  String get plansYourCustomPlans => 'MIPANGO YAKO MAALUM';

  @override
  String plansDayOfTotal(int day, int total) {
    return 'Siku $day kati ya $total';
  }

  @override
  String get plansCustomPlan => 'Mpango maalum';

  @override
  String get plansNoActivePlans => 'Hakuna mipango inayoendelea';

  @override
  String get plansNoActivePlansBody =>
      'Vinjari Kusoma au Vitabu ili kuanza mpango wako wa kwanza.';

  @override
  String get plansLetsRead => 'Tusome';

  @override
  String get plansVerseOfTheDay => 'Mstari wa siku';

  @override
  String get plansOpenTodaysReading => 'Fungua somo la leo';

  @override
  String get plansLastDayOfYear => 'Siku ya mwisho ya mwaka';

  @override
  String plansDaysLeftInYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zimebaki siku $count mwaka huu',
      one: 'Imebaki siku 1 mwaka huu',
    );
    return '$_temp0';
  }

  @override
  String get plansCustomPlanDefaultTitle => 'Mpango Maalum';

  @override
  String get plansCustom => 'Maalum';

  @override
  String plansBookRange(String start, String end) {
    return '$start hadi $end';
  }

  @override
  String plansCouldNotSave(String error) {
    return 'Imeshindwa kuhifadhi mpango: $error';
  }

  @override
  String get plansBuilderTitle => 'Unda Mpango Wako';

  @override
  String plansError(String error) {
    return 'Hitilafu: $error';
  }

  @override
  String get plansPlanName => 'Jina la mpango';

  @override
  String get plansPlanNameHint => 'mf. Mwanzo kwa Siku 30';

  @override
  String get plansReadingTracks => 'Njia za kusoma';

  @override
  String get plansAddTrack => 'Ongeza njia';

  @override
  String get plansTracksOverlap =>
      'Njia zinaingiliana — mistari inayoshirikiwa inahesabiwa mara moja tu katika onyesho hapa chini.';

  @override
  String get plansDuration => 'Muda';

  @override
  String plansDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Siku $count',
      one: 'Siku 1',
    );
    return '$_temp0';
  }

  @override
  String get plansDaysSuffix => 'siku';

  @override
  String get plansStartRestReminder => 'Kuanza, mapumziko na kikumbusho';

  @override
  String get plansStartDate => 'Tarehe ya kuanza';

  @override
  String get plansRestDaysNeutral => 'Siku za mapumziko (hazihesabiwi)';

  @override
  String get plansNone => 'Hakuna';

  @override
  String get plansDailyReminder => 'Kikumbusho cha kila siku';

  @override
  String plansReminderAt(String time) {
    return 'Saa $time';
  }

  @override
  String get plansOff => 'Imezimwa';

  @override
  String get plansLivePreview => 'Onyesho la moja kwa moja';

  @override
  String get plansPreviewEmpty =>
      'Ongeza angalau njia moja hapo juu ili kuona ratiba iliyosawazishwa.';

  @override
  String get plansWordBalanced =>
      'Imesawazishwa kwa maneno · inazingatia vifungu';

  @override
  String plansPreviewSummary(int days, int readingDays) {
    return 'Siku $days · siku $readingDays za kusoma';
  }

  @override
  String plansClampedNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Kasi ya taratibu zaidi kwa uchaguzi huu ni siku $days. Kichwa kimesasishwa kwa idadi halisi ya siku.',
      one:
          'Kasi ya taratibu zaidi kwa uchaguzi huu ni siku 1. Kichwa kimesasishwa kwa idadi halisi ya siku.',
    );
    return '$_temp0';
  }

  @override
  String plansPreviewDay(int day, String portions) {
    return 'Siku $day: $portions';
  }

  @override
  String plansMoreBalancedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Siku $count zaidi zilizosawazishwa',
      one: 'Siku 1 zaidi iliyosawazishwa',
    );
    return '$_temp0';
  }

  @override
  String get plansSaving => 'Inahifadhi…';

  @override
  String get plansGenerateAndSave => 'Unda na uhifadhi →';

  @override
  String get plansNameAndTrackHint =>
      'Ipe mpango jina na uongeze angalau njia moja ili kuendelea.';

  @override
  String get plansStartEllipsis => 'Mwanzo…';

  @override
  String get plansEndEllipsis => 'Mwisho…';

  @override
  String get plansStartLabel => 'MWANZO';

  @override
  String get plansEndLabel => 'MWISHO';

  @override
  String get plansRemoveTrack => 'Ondoa njia';

  @override
  String plansRestChip(String days) {
    return 'Pumziko $days';
  }

  @override
  String plansRebasedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ratiba imesogezwa kwa siku $count za kusoma. Siku zilizokamilika hazijaguswa.',
      one:
          'Ratiba imesogezwa kwa siku 1 ya kusoma. Siku zilizokamilika hazijaguswa.',
    );
    return '$_temp0';
  }

  @override
  String get plansPlan => 'Mpango';

  @override
  String get plansNoReadingsYet => 'Mpango huu bado hauna masomo.';

  @override
  String plansReadingDaysWeeks(int days, int weeks) {
    return 'Siku $days za kusoma · ~wiki $weeks';
  }

  @override
  String get plansBeginPlan => 'Anza mpango';

  @override
  String get plansStartDayOne => 'Anza Siku 1 →';

  @override
  String get plansStartDateNote => 'Mpango wako utaanza tarehe utakayochagua.';

  @override
  String get plansScheduleLabel => 'RATIBA';

  @override
  String get plansNoReadings => 'Hakuna masomo';

  @override
  String plansPercentComplete(int percent) {
    return '$percent% imekamilika';
  }

  @override
  String get plansFlexible => 'Huru';

  @override
  String get plansScheduled => 'Kwa ratiba';

  @override
  String plansBehindChip(int count) {
    return '$count nyuma';
  }

  @override
  String get plansOnTrack => 'Uko sawa';

  @override
  String get plansFlexibleHelp =>
      'Huru: soma kwanza siku ya zamani zaidi ambayo hujasoma. Siku ulizokosa hazilimbikizwi.';

  @override
  String get plansScheduledHelp =>
      'Kwa ratiba: kila tarehe ina siku yake ya kusoma. Siku ulizokosa zinahesabiwa kama kuchelewa — fidia hapa chini.';

  @override
  String get plansCatchUp => 'Fidia';

  @override
  String plansBehindBy(int count, int day) {
    return 'Nyuma kwa $count — ya zamani zaidi ambayo hujasoma ni Siku $day.';
  }

  @override
  String get plansCatchUpHelp =>
      'Kuweka alama kwenye siku hurekodi maendeleo. Kusogeza husogeza ratiba iliyobaki mbele badala yake.';

  @override
  String get plansGoToOldest => 'Nenda ya zamani zaidi';

  @override
  String get plansMarkOldestDone => 'Weka ya zamani imesomwa';

  @override
  String get plansAllPreviousDone =>
      'Kila kitu kabla ya leo tayari kimekamilika.';

  @override
  String plansPreviousMarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Siku $count zilizopita zimewekwa kuwa zimesomwa.',
      one: 'Siku 1 iliyopita imewekwa kuwa imesomwa.',
    );
    return '$_temp0';
  }

  @override
  String get plansMarkAllPrevious => 'Weka zote zilizopita';

  @override
  String plansRebaseDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sogeza siku +$count',
      one: 'Sogeza siku +1',
    );
    return '$_temp0';
  }

  @override
  String plansReadingsHeader(int count) {
    return 'MASOMO · SIKU $count';
  }

  @override
  String get plansJourneyMap => 'Ramani ya safari';

  @override
  String get plansJumpToToday => 'Nenda leo';

  @override
  String plansDayN(int day) {
    return 'Siku $day';
  }

  @override
  String get plansLegendDone => 'Imesomwa';

  @override
  String get plansLegendToday => 'Leo = duara';

  @override
  String get plansLegendMissed => 'Imekosa';

  @override
  String plansReminderAtTime(String time) {
    return 'Kikumbusho · $time';
  }

  @override
  String get plansReminderOff => 'Kikumbusho kimezimwa';

  @override
  String get plansReminderHelp =>
      'Arifa ya mpango huu — inaruka siku za mapumziko yenyewe.';

  @override
  String get plansRestDays => 'Siku za mapumziko';

  @override
  String get plansNoRestDays => 'Hakuna siku za mapumziko';

  @override
  String get plansSettings => 'Mipangilio ya mpango';

  @override
  String get plansAboutEllipsis => 'Kuhusu mpango huu…';

  @override
  String get plansAbout => 'Kuhusu mpango huu';

  @override
  String get plansChangeStartDate => 'Badilisha tarehe ya kuanza…';

  @override
  String plansRestDaysValue(String days) {
    return 'Siku za mapumziko: $days';
  }

  @override
  String get plansRestDaysHelp => 'Gusa ili kuchagua siku';

  @override
  String get plansRestartFromDayOne => 'Anza upya kutoka Siku 1…';

  @override
  String get plansRestartTitle => 'Anza mpango upya?';

  @override
  String get plansRestartBody => 'Siku zilizokamilika zitafutwa.';

  @override
  String get plansRestart => 'Anza upya';

  @override
  String get plansMarkUnread => 'Weka haijasomwa';

  @override
  String get plansMarkRead => 'Weka imesomwa';

  @override
  String get plansRestAndReflect => 'Pumzika na tafakari';

  @override
  String get plansRestDayBody => 'Siku ya mapumziko — hakuna somo leo.';

  @override
  String get plansDayDetailHelp =>
      'Gusa kifungu ili kukifungua. Weka alama kila kimoja unaposoma.';

  @override
  String plansMilestone(int count) {
    return 'Masomo $count yamekamilika — endelea!';
  }

  @override
  String get plansCompletedTapToUndo => 'Imekamilika — gusa kutendua';

  @override
  String plansMarkDayRead(int day, int checked, int total) {
    return 'Weka Siku $day imesomwa ✓ (vifungu $checked/$total)';
  }

  @override
  String get todayGoodMorning => 'Habari za asubuhi';

  @override
  String get todayGoodAfternoon => 'Habari za mchana';

  @override
  String get todayGoodEvening => 'Habari za jioni';

  @override
  String get todayGoodNight => 'Usiku mwema';

  @override
  String get todayStreakNudge => 'Soma leo ili kulinda mfululizo wako!';

  @override
  String get todayNotificationsSoon => 'Arifa zinakuja hivi karibuni!';

  @override
  String get todaySectionResume => 'ENDELEA';

  @override
  String get todaySectionStreak => 'MFULULIZO WA KUSOMA';

  @override
  String get todaySectionLatestNote => 'DOKEZO LA KARIBUNI';

  @override
  String get todaySectionQuickActions => 'VITENDO VYA HARAKA';

  @override
  String get todaySectionReminders => 'VIKUMBUSHO VYA KILA SIKU';

  @override
  String get todayTagline => 'Wakati wako wa amani kila siku.';

  @override
  String get todayNoNotesYet => 'Bado hakuna madokezo';

  @override
  String get todayWriteFirstNote => 'Andika dokezo lako la kwanza ulione hapa.';

  @override
  String get todayViewAllNotes => 'Tazama madokezo yote';

  @override
  String todayStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mfululizo wa siku $count',
      one: 'Mfululizo wa siku 1',
    );
    return '$_temp0';
  }

  @override
  String todayDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zimebaki siku $count mwaka huu.',
      one: 'Imebaki siku 1 mwaka huu.',
    );
    return '$_temp0';
  }

  @override
  String get todayActionRead => 'Soma';

  @override
  String get todayActionSurprise => 'Nishangaze';

  @override
  String get todayActionReadingPlan => 'Mpango wa Kusoma';

  @override
  String get todayActionYourSpace => 'Nafasi Yako';

  @override
  String get todayVotdArchive => 'Kumbukumbu ya Mstari wa Siku';

  @override
  String get todayVotdArchiveBody => 'Pata mistari ya siku ulizokosa.';

  @override
  String get todayVotdArchiveExplore => 'Chunguza mistari ya siku zilizopita';

  @override
  String get readActionBookmark => 'Alamisho';

  @override
  String get readActionNote => 'Dokezo';

  @override
  String get readActionNotes => 'Madokezo';

  @override
  String get readActionEditNote => 'Hariri dokezo';

  @override
  String get readActionCommentary => 'Ufafanuzi';

  @override
  String get readActionRelated => 'Inayohusiana';

  @override
  String get readActionHighlight => 'Angazia';

  @override
  String get readActionStudy => 'Jifunze';

  @override
  String get readActionSaved => 'Imehifadhiwa';

  @override
  String get readActionSelectText => 'Chagua maandishi';

  @override
  String get readVerseActions => 'Vitendo vya mstari';

  @override
  String readVersesSelected(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mistari $count imechaguliwa',
      one: 'Mstari 1 umechaguliwa',
    );
    return '$_temp0 · $where';
  }

  @override
  String get readCommentaryHint =>
      'Gusa aikoni ya balbu kando ya mstari kupata ufafanuzi';

  @override
  String get readPassageNotFound => 'Kifungu hakikupatikana.';

  @override
  String get readChapterCommentary => 'Soma ufafanuzi wa sura hii';

  @override
  String get readPreviousChapter => '‹ Iliyotangulia';

  @override
  String get readNextChapter => 'Inayofuata ›';

  @override
  String readPlanDay(int day) {
    return 'Mpango wa Kusoma · Siku $day';
  }

  @override
  String get readPlanCompleted => 'Mpango umekamilika! Hongera! 🎉';

  @override
  String readMarkDoneContinue(String book, int chapter) {
    return 'Weka $book $chapter imekamilika, endelea';
  }

  @override
  String get readNone => 'Hakuna';

  @override
  String readBookFallback(int number) {
    return 'Kitabu $number';
  }

  @override
  String get readRelatedVerses => 'Mistari inayohusiana';

  @override
  String get readNoCrossRefs => 'Hakuna marejeo mtambuka kwa mstari huu.';

  @override
  String get readCrossRefsComingSoon =>
      'Marejeo mtambuka yatapatikana\nbaada ya sasisho lijalo.';

  @override
  String readCrossRefsLoadError(String error) {
    return 'Imeshindwa kupakia marejeo mtambuka.\n$error';
  }

  @override
  String get readVerseUnavailable => 'Mstari haupatikani';

  @override
  String get readLoading => 'Inapakia…';

  @override
  String get readVerseNotFound => 'Mstari haukupatikana.';

  @override
  String get readBookOrChapterNotFound => 'Kitabu au sura haikupatikana.';

  @override
  String get readOpenInRead => 'Fungua katika Soma';

  @override
  String get readBookNotFound => 'Kitabu kilichotajwa hakikupatikana.';

  @override
  String readVerseLoadError(String error) {
    return 'Hitilafu kupakia mstari: $error';
  }

  @override
  String get readTestament => 'Agano';

  @override
  String get readBook => 'Kitabu';

  @override
  String get readChapter => 'Sura';

  @override
  String get readVerse => 'Mstari';

  @override
  String get readSelectBook => 'Chagua kitabu';

  @override
  String get readOtShort => 'AK';

  @override
  String get readNtShort => 'AJ';

  @override
  String get readOldTestament => 'Agano la Kale';

  @override
  String get readNewTestament => 'Agano Jipya';

  @override
  String get readOldTestamentTwoLine => 'Agano\nla Kale';

  @override
  String get readNewTestamentTwoLine => 'Agano\nJipya';

  @override
  String get readStoriesSections => 'Hadithi na Sehemu';

  @override
  String get readAllVerses => 'Mistari yote';

  @override
  String get readTranslationTitle => 'Tafsiri ya Biblia';

  @override
  String get readLayoutTitle => 'Mpangilio wa kusoma';

  @override
  String get readLayoutSingle => 'Moja';

  @override
  String get readLayoutBilingual => 'Lugha mbili';

  @override
  String get readLayoutParallel => 'Sambamba';

  @override
  String get readLayoutChips => 'Vitufe';

  @override
  String get readLayoutSingleDesc => 'Tafsiri moja';

  @override
  String get readLayoutBilingualDesc => 'Tafsiri mbili kwa kila mstari';

  @override
  String get readLayoutParallelDesc =>
      'Tafsiri mbili katika safu kando kwa kando';

  @override
  String get readLayoutChipsDesc => 'Gusa mstari kubadili tafsiri yake';

  @override
  String get readPrimary => 'Kuu';

  @override
  String get readSecondary => 'Ya pili';

  @override
  String readTranslationsLoadError(String error) {
    return 'Hitilafu kupakia tafsiri: $error';
  }

  @override
  String readTranslationDeleted(String name) {
    return '$name imefutwa.';
  }

  @override
  String readDeleteFailed(String error) {
    return 'Imeshindwa kufuta: $error';
  }

  @override
  String readDeleteTranslation(String name) {
    return 'Futa $name';
  }

  @override
  String get readKjvAlwaysAvailable => 'Inapatikana daima · msingi wa programu';

  @override
  String get readCannotDeleteBackbone => 'Haiwezi kufutwa — msingi wa programu';

  @override
  String get readAvailableToAdd => 'ZINAZOWEZA KUONGEZWA';

  @override
  String get readNoInternet => 'Hakuna mtandao — jaribu tena ukiwa mtandaoni.';

  @override
  String get readRestoreFailed => 'Kurejesha kumeshindwa';

  @override
  String get readDownloadFailed => 'Upakuaji umeshindwa';

  @override
  String readRestoreFailedDetail(String error) {
    return 'Kurejesha kumeshindwa ($error).';
  }

  @override
  String readDownloadFailedDetail(String error) {
    return 'Upakuaji umeshindwa ($error).';
  }

  @override
  String get readRestoreOffline => 'rejesha bila mtandao';

  @override
  String get homeVerseOfTheDay => 'MSTARI WA SIKU';

  @override
  String get homeDevotional => 'IBADA';

  @override
  String get homeCommentary => 'UFAFANUZI';

  @override
  String get homeGoDeeper => 'Ingia ndani zaidi';

  @override
  String get homeReadFullDefinition => 'Soma maana kamili';

  @override
  String get homeWordOfTheDayHeading => 'NENO LA SIKU';

  @override
  String get homeWordOfTheDay => 'Neno la siku';

  @override
  String get homeWotdEmpty =>
      'Hakuna neno lililochaguliwa leo — jaribu baadaye.';

  @override
  String homeWotdUnavailable(String error) {
    return 'Neno la siku halipatikani ($error).';
  }

  @override
  String get navHome => 'Nyumbani';

  @override
  String get navRead => 'Soma';

  @override
  String get navStudy => 'Jifunze';

  @override
  String get navSearch => 'Tafuta';

  @override
  String get navExitTitle => 'Ondoka The Blessed Bible?';

  @override
  String get navExitMessage => 'Una uhakika unataka kuondoka kwenye programu?';

  @override
  String get navExit => 'Ondoka';

  @override
  String get navCastLotsError => 'Imeshindwa kupiga kura — jaribu tena.';

  @override
  String get navCastingLots => 'Inapiga kura…';

  @override
  String get searchHint => 'Tafuta mistari, ufafanuzi…';

  @override
  String get searchAllBooks => 'Vitabu vyote';

  @override
  String get searchFilterMyNotes => 'Madokezo yangu';

  @override
  String get searchEmptyPrompt => 'Tafuta Biblia, ufafanuzi\nna madokezo yako';

  @override
  String get searchRecentSearches => 'UTAFUTAJI WA KARIBUNI';

  @override
  String get searchClear => 'FUTA';

  @override
  String get searchRecentPlaces => 'MAHALI PA KARIBUNI';

  @override
  String get searchMostRead => 'ZINAZOSOMWA ZAIDI';

  @override
  String get searchNoResults => 'Hakuna matokeo';

  @override
  String get searchTopResults => 'Matokeo 100 bora yanaonyeshwa';

  @override
  String searchResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Matokeo $count yamepatikana',
      one: 'Tokeo 1 limepatikana',
    );
    return '$_temp0';
  }

  @override
  String searchSectionDictionary(int count) {
    return 'KAMUSI ($count)';
  }

  @override
  String searchSectionStories(int count) {
    return 'HADITHI ($count)';
  }

  @override
  String searchSectionJumpTo(int count) {
    return 'NENDA KWA ($count)';
  }

  @override
  String searchSectionVerses(int count) {
    return 'MISTARI ($count)';
  }

  @override
  String searchSectionCommentary(int count) {
    return 'UFAFANUZI ($count)';
  }

  @override
  String searchSectionMyNotes(int count) {
    return 'MADOKEZO YANGU ($count)';
  }

  @override
  String get searchCopied => 'Imenakiliwa';

  @override
  String get settingsTitle => 'Mipangilio';

  @override
  String get settingsTabGeneral => 'Jumla';

  @override
  String get settingsTabNavigation => 'Urambazaji';

  @override
  String get settingsTabReminders => 'Vikumbusho';

  @override
  String get settingsTabInfo => 'Taarifa';

  @override
  String get settingsWidgetsTitle => 'Wijeti za Skrini ya Nyumbani';

  @override
  String get settingsWidgetsSubtitle =>
      'Badilisha rangi, uwazi na hakikisho la moja kwa moja';

  @override
  String get settingsStartPageTitle => 'Ukurasa wa kuanzia';

  @override
  String get settingsStartPageSubtitle =>
      'Chagua ukurasa programu inaofungua nao';

  @override
  String get settingsPageHome => 'Nyumbani';

  @override
  String get settingsPageRead => 'Soma';

  @override
  String get settingsPageStudy => 'Jifunze';

  @override
  String get settingsPageSearch => 'Tafuta';

  @override
  String get settingsImmersiveReading => 'Usomaji wa Kuzama';

  @override
  String get settingsImmersiveOffTitle => 'Imetia nanga (Imezimwa)';

  @override
  String get settingsImmersiveOffSubtitle =>
      'Urambazaji unaonekana wakati wote';

  @override
  String get settingsImmersivePartialTitle => 'Kuongozwa (Sehemu)';

  @override
  String get settingsImmersivePartialSubtitle =>
      'Huficha urambazaji, lakini huacha kitufe cha kitabu na sura';

  @override
  String get settingsImmersiveFullTitle => 'Maji Makuu (Kamili)';

  @override
  String get settingsImmersiveFullSubtitle =>
      'Kuzama kabisa. Menyu zote hujificha unaposogeza';

  @override
  String get settingsShowStrongs => 'Onyesha Namba za Strong';

  @override
  String get settingsShowStrongsSubtitle =>
      'Huonyesha alama za Kiebrania/Kigiriki kando ya maandishi ya KJV kwa kujifunza maneno';

  @override
  String get settingsStrongsGetIt => 'Pata';

  @override
  String get settingsStrongsMarkerAsterisk => 'Nyota (*)';

  @override
  String get settingsStrongsMarkerChain => 'Mnyororo (🔗)';

  @override
  String get settingsStrongsMarkerNumber => 'Namba (H1234)';

  @override
  String get settingsReadingSpeed => 'Kasi ya kusoma';

  @override
  String get settingsReadingSpeedSubtitle =>
      'Makadirio ya kasi kwa mipango (maneno kwa dakika)';

  @override
  String get settingsSpeedRelaxed => 'Taratibu';

  @override
  String get settingsSpeedStandard => 'Kawaida';

  @override
  String get settingsSpeedBrisk => 'Haraka';

  @override
  String get settingsDictUnderlines => 'Mistari ya Kamusi';

  @override
  String get settingsDictUnderlinesSubtitle =>
      'Mistari ya nukta chini ya maneno ya kibiblia na ya kale';

  @override
  String get settingsUnderlineScope => 'Wigo wa Mistari';

  @override
  String get settingsScopeNamesTitle => 'Majina na istilahi pekee';

  @override
  String get settingsScopeNamesSubtitle =>
      'Majina halisi na dhana maalum za kibiblia';

  @override
  String get settingsScopeTrickyTitle =>
      'Majina + maneno magumu (Inapendekezwa)';

  @override
  String get settingsScopeTrickySubtitle =>
      'Inajumuisha maneno ya kale yaliyobadilika maana (k.m. let, prevent)';

  @override
  String get settingsScopeEverythingTitle => 'Kila kitu';

  @override
  String get settingsScopeEverythingSubtitle =>
      'Huangazia sarufi yote ya kale (k.m. thee, thou, hath, unto)';

  @override
  String get settingsScopeDifficultTitle => 'Maneno magumu pekee';

  @override
  String get settingsScopeDifficultSubtitle =>
      'Maneno ya kale, yanayopotosha na yenye utata — maneno rahisi kama god na son hayawekwi alama';

  @override
  String get settingsScopeDifficultNamesTitle => 'Magumu + majina';

  @override
  String get settingsScopeDifficultNamesSubtitle =>
      'Huongeza watu na mahali (k.m. Daudi, Yerusalemu) kwa maneno magumu';

  @override
  String get settingsOtherEnglishVersions => 'Matoleo mengine ya Kiingereza';

  @override
  String get settingsContestedOnlyTitle => 'Maneno yenye utata pekee';

  @override
  String get settingsContestedOnlySubtitle =>
      'BBE, WEB na matoleo mengine ya Kiingereza huweka alama maneno yenye utata (k.m. hell, baptism)';

  @override
  String get settingsFollowScopeTitle => 'Fuata wigo wa mistari';

  @override
  String get settingsFollowScopeSubtitle =>
      'Alama sawa na KJV katika kila toleo la Kiingereza';

  @override
  String get settingsNoUnderlinesTitle => 'Hakuna mistari';

  @override
  String get settingsNoUnderlinesSubtitle =>
      'Matoleo mengine ya Kiingereza hayaonyeshi alama za kamusi';

  @override
  String get settingsPopupStyle => 'Mtindo wa Dirisha';

  @override
  String get settingsPopupStyleSubtitle =>
      'Jinsi maana za kamusi na namba za Strong zinavyoonyeshwa';

  @override
  String get settingsPopupFloating => 'Inayoelea';

  @override
  String get settingsPopupBottomSheet => 'Paneli ya chini';

  @override
  String get settingsSavedInMyLanguage =>
      'Onyesha vilivyohifadhiwa kwa lugha yangu';

  @override
  String get settingsSavedInMyLanguageSubtitle =>
      'Onyesha alamisho, maangazio na mistari ya maelezo katika tafsiri yako kuu';

  @override
  String get settingsTranslationChips =>
      'Onyesha chaguo za tafsiri kwenye vilivyohifadhiwa';

  @override
  String get settingsTranslationChipsSubtitle =>
      'Huongeza safu fupi ya kuona mistari iliyohifadhiwa katika tafsiri nyingine';

  @override
  String get settingsVerseActionStyle => 'Mtindo wa Vitendo vya Mstari';

  @override
  String get settingsVerseActionStyleSubtitle =>
      'Paneli (fupi) au Kawaida (ndefu) ukichagua mistari; Mviringo huweka menyu ya kubonyeza kwa muda katika duara';

  @override
  String get settingsActionSheet => 'Paneli';

  @override
  String get settingsActionClassic => 'Kawaida';

  @override
  String get settingsActionMinimal => 'Rahisi';

  @override
  String get settingsActionRaindrop => 'Tone la mvua';

  @override
  String get settingsActionRadial => 'Mviringo';

  @override
  String get settingsKeepAwake => 'Skrini Ibaki Imewaka';

  @override
  String get settingsKeepAwakeSubtitle => 'Zuia kifaa kulala unaposoma';

  @override
  String get settingsRestartOnboarding => 'Anza upya utangulizi';

  @override
  String get settingsRestartOnboardingSubtitle =>
      'Rudia mpangilio wa mara ya kwanza';

  @override
  String get settingsRestartOnboardingDialogTitle => 'Anza upya utangulizi?';

  @override
  String get settingsRestartOnboardingDialogBody =>
      'Hii itarudia mpangilio wa mara ya kwanza. Mandhari, fonti na tafsiri yako vitabaki isipokuwa uvibadilishe.';

  @override
  String get settingsRestart => 'Anza upya';

  @override
  String get settingsAppearanceText => 'Mwonekano na maandishi';

  @override
  String get settingsAppearanceTextSubtitle =>
      'Mandhari, fonti, ukubwa na rangi';

  @override
  String get settingsSabbathTitle => 'Kikumbusho cha Machweo ya Ijumaa';

  @override
  String get settingsSabbathSubtitle =>
      'Karibisha Sabato wakati wa machweo mahali ulipo.';

  @override
  String get settingsLocation => 'Mahali';

  @override
  String get settingsLocationNotSet => 'Haijawekwa (Gusa kuweka)';

  @override
  String get settingsDailyReminderTitle => 'Kikumbusho cha Kusoma Kila Siku';

  @override
  String get settingsDailyReminderSubtitle =>
      'Kikumbusho cha kila siku kutumia muda katika Neno.';

  @override
  String get settingsTime => 'Saa';

  @override
  String get settingsWeeklyReminderTitle => 'Kikumbusho cha Kila Wiki';

  @override
  String get settingsWeeklyReminderSubtitle =>
      'Weka siku na saa maalum kila wiki kwa kujifunza zaidi.';

  @override
  String get settingsDayAndTime => 'Siku na Saa';

  @override
  String get settingsChooseDay => 'Chagua Siku';

  @override
  String get settingsShowReadingTips => 'Onyesha vidokezo vya kusoma';

  @override
  String get settingsShowReadingTipsSubtitle =>
      'Vidokezo vya vitendo kama kuangazia na kutelezesha';

  @override
  String get settingsNavSteps => 'Hatua za Urambazaji';

  @override
  String get settingsNavStepsSubtitle =>
      'Hatua ngapi kufikia mstari. 2: Kitabu → Sura. 3: Kitabu → Sura → Mstari. 4: Agano → Kitabu → Sura → Mstari.';

  @override
  String get settingsAutoClose => 'Funga paneli baada ya chaguo la mwisho';

  @override
  String get settingsAutoCloseSubtitle =>
      'Funga kiteuzi kiotomatiki baada ya hatua ya mwisho';

  @override
  String get settingsSelectorHeight => 'Urefu wa kiteuzi cha kitabu';

  @override
  String get settingsSelectorHeightSubtitle =>
      'Jinsi paneli ya kitabu/sura inavyofunguka juu';

  @override
  String get settingsHeightHalf => 'Nusu';

  @override
  String get settingsHeightFull => 'Kamili';

  @override
  String get settingsAutoOpenSingle => 'Fungua tokeo moja moja kwa moja';

  @override
  String get settingsAutoOpenSingleSubtitle =>
      'Nenda moja kwa moja utafutaji ukipata tokeo moja tu';

  @override
  String get settingsIncludeNotes => 'Jumuisha maelezo yangu kwenye utafutaji';

  @override
  String get settingsIncludeNotesSubtitle =>
      'Ruhusu utafutaji kupitia maelezo yako';

  @override
  String get settingsWholeWords => 'Maneno kamili pekee';

  @override
  String get settingsWholeWordsSubtitle =>
      'Tafuta maneno kamili tu (huzima ulinganisho wa sehemu)';

  @override
  String get settingsFuzzySearch => 'Utafutaji wenye uvumilivu';

  @override
  String get settingsFuzzySearchSubtitle =>
      'Onyesha pia yanayokaribiana kwa makosa ya tahajia (k.m. Jhon hupata John)';

  @override
  String get settingsDefaultScopes => 'Wigo wa Utafutaji wa Msingi';

  @override
  String get settingsOldTestament => 'Agano la Kale';

  @override
  String get settingsNewTestament => 'Agano Jipya';

  @override
  String get settingsCommentary => 'Maelezo';

  @override
  String get settingsGestures => 'Ishara';

  @override
  String get settingsPullDownHome => 'Vuta chini Nyumbani';

  @override
  String get settingsPullDownHomeSubtitle =>
      'Vuta chini kupita juu kufungua Mipangilio au Mwonekano';

  @override
  String get settingsPullDownOpens => 'Kuvuta hufungua';

  @override
  String get settingsPullDownOpensSubtitle =>
      'Mahali ishara ya kuvuta Nyumbani inapofungua';

  @override
  String get settingsAppearance => 'Mwonekano';

  @override
  String get settingsSwipeLeftHome => 'Telezesha kushoto Nyumbani';

  @override
  String get settingsSwipeLeftHomeSubtitle => 'Telezesha kushoto kwenda Soma';

  @override
  String get settingsLongPressNav => 'Bonyeza kwa muda kufungua urambazaji';

  @override
  String get settingsLongPressNavSubtitle =>
      'Bonyeza kwa muda kitufe cha chini kulia kufungua kiteuzi cha Kitabu/Sura.';

  @override
  String get settingsBbeNoteTitle => 'Dokezo la Tafsiri ya BBE';

  @override
  String get settingsBackup => 'Hifadhi nakala ya data yangu';

  @override
  String get settingsBackupSubtitle =>
      'Hamisha maelezo, maangazio na mipangilio';

  @override
  String get settingsRestoreBackup => 'Rejesha kutoka nakala';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Leta data yako kutoka nakala ya JSON';

  @override
  String get settingsRestoreBackupDialogTitle => 'Rejesha kutoka Nakala';

  @override
  String get settingsRestoreHint => 'Bandika JSON ya nakala hapa…';

  @override
  String get settingsRestore => 'Rejesha';

  @override
  String get settingsClearCache => 'Futa akiba/data iliyopakuliwa';

  @override
  String get settingsClearCacheSubtitle =>
      'Ongeza nafasi kwa kufuta faili za akiba';

  @override
  String get settingsNotImplemented => 'Bado haipatikani';

  @override
  String get settingsResetSettings => 'Weka upya mipangilio';

  @override
  String get settingsResetSettingsSubtitle =>
      'Rejesha mipangilio asili (maudhui yanabaki)';

  @override
  String get settingsResetDialogTitle => 'Weka upya mipangilio?';

  @override
  String get settingsResetDialogBody =>
      'Weka upya mipangilio yote? Alamisho, maelezo na maangazio yako hayataathirika.';

  @override
  String get settingsResetDone => 'Mipangilio imewekwa upya.';

  @override
  String get settingsReset => 'Weka upya';

  @override
  String get settingsVersion => 'Toleo';

  @override
  String get settingsUnknown => 'Haijulikani';

  @override
  String get settingsStorage => 'Hifadhi na vipakuliwa';

  @override
  String get settingsStorageSubtitle =>
      'Akiba, tafsiri zilizopakuliwa na nafasi inayoweza kuachiliwa';

  @override
  String get settingsSendFeedback => 'Tuma Maoni';

  @override
  String get settingsCrashReports => 'Tuma ripoti za hitilafu';

  @override
  String get settingsCrashReportsSubtitle =>
      'Maelezo yasiyo na jina husaidia kurekebisha hitilafu. Hakuna usomaji wa Biblia, maelezo wala maudhui binafsi.';

  @override
  String get settingsPrivacyPolicy => 'Sera ya Faragha';

  @override
  String get settingsCredits => 'Shukrani na vyanzo';

  @override
  String get settingsCreditsSubtitle =>
      'Tafsiri za Biblia, maelezo, data ya kujifunza, fonti na leseni';

  @override
  String get settingsSetSunsetLocation => 'Weka Mahali pa Machweo';

  @override
  String get settingsCurrentLocationGps => 'Mahali Ulipo (GPS)';

  @override
  String get settingsUseMyLocation => 'Tumia mahali nilipo';

  @override
  String get settingsOrSelectCity => 'AU chagua jiji kubwa';

  @override
  String get settingsTypography => 'Mpangilio wa Herufi';

  @override
  String get settingsTheme => 'Mandhari';

  @override
  String get settingsSearchSettings => 'Mipangilio ya Utafutaji';

  @override
  String get settingsMatchTypeHeader => 'AINA YA ULINGANISHO';

  @override
  String get settingsExactMatch => 'Ulinganisho Kamili';

  @override
  String get settingsExactMatchSubtitle => 'Kifungu kamili pekee';

  @override
  String get settingsScopeHeader => 'WIGO';

  @override
  String get settingsDisabledBookFilter =>
      'Imezimwa (Kichujio cha Kitabu Kipo)';

  @override
  String get settingsMyNotes => 'Maelezo Yangu';

  @override
  String get settingsBehaviorHeader => 'TABIA';

  @override
  String get settingsAutoOpenSingleShort => 'Fungua Tokeo Moja';

  @override
  String get settingsAutoOpenSingleShortSubtitle =>
      'Ruka moja kwa moja tokeo moja likipatikana';

  @override
  String get settingsBackgroundGlow => 'Washa Mng\'ao wa Nyuma';

  @override
  String get settingsBackgroundGlowSubtitle =>
      'Mwanga hafifu unaosonga nyuma ya msomaji';

  @override
  String get settingsThemeGroupFoundations => 'MISINGI';

  @override
  String get settingsThemeDawn => 'Alfajiri';

  @override
  String get settingsThemeFresh => 'Safi';

  @override
  String get settingsThemeGroupFirmament => 'ANGA';

  @override
  String get settingsThemeSun => 'Jua';

  @override
  String get settingsThemeMoon => 'Mwezi';

  @override
  String get settingsThemeStars => 'Nyota';

  @override
  String get settingsThemeGroupEden => 'EDENI';

  @override
  String get settingsThemeLilies => 'Mayungiyungi';

  @override
  String get settingsThemeRoses => 'Waridi';

  @override
  String get settingsThemeOlives => 'Mizeituni';

  @override
  String get settingsThemeGroupSanctuary => 'PATAKATIFU';

  @override
  String get settingsThemePurple => 'Zambarau\nya Kikuhani';

  @override
  String get settingsThemeBlue => 'Buluu\nya Galilaya';

  @override
  String get settingsThemeRed => 'Nyekundu\nsana';

  @override
  String get settingsSurpriseMe => 'Nishangaze';

  @override
  String get settingsThemeOledDark => 'OLED\nGiza';

  @override
  String get settingsThemeDuskOled => 'Jioni\nOLED';

  @override
  String get settingsSurfaceStyle => 'Mtindo wa Uso';

  @override
  String get settingsSurfaceStyleSubtitle => 'Kina cha mwonekano na umbile';

  @override
  String get settingsSurfaceEarth => 'Dunia';

  @override
  String get settingsSurfaceEarthSubtitle => 'Uso tambarare';

  @override
  String get settingsSurfaceHeaven => 'Mbingu';

  @override
  String get settingsSurfaceHeavenSubtitle => 'Kina cha barafu';

  @override
  String get settingsSurfacePaper => 'Karatasi';

  @override
  String get settingsSurfacePaperSubtitle => 'Kisomaji chenye joto';

  @override
  String get settingsSurfaceClay => 'Udongo';

  @override
  String get settingsSurfaceClaySubtitle => '3-D laini';

  @override
  String get settingsWidgetsLivePreview =>
      'Hakikisho la moja kwa moja na mtindo';

  @override
  String get settingsWidgetPreviewHeader => 'HAKIKISHO LA WIJETI';

  @override
  String get settingsWidgetStreak => 'Mfululizo Unaendelea! • Lengo la Siku';

  @override
  String get settingsWidgetWotd => 'NENO LA SIKU';

  @override
  String get settingsWidgetVotd => 'MSTARI WA SIKU';

  @override
  String get settingsWidgetBackgroundHeader => 'MANDHARI YA NYUMA NA RANGI';

  @override
  String get settingsWidgetContrastHeader => 'UTOFAUTI WA MAANDISHI';

  @override
  String get settingsWidgetTextAuto => 'Otomatiki ✨';

  @override
  String get settingsWidgetTextDark => 'Maandishi Meusi ☀️';

  @override
  String get settingsWidgetTextWhite => 'Maandishi Meupe 🌙';

  @override
  String get settingsWidgetSynced => 'Wijeti zimesawazishwa na mtindo mpya! ✨';

  @override
  String get settingsWidgetApply => 'Tumia na Sawazisha Skrini ya Nyumbani';

  @override
  String get settingsFontSizeHeader => 'UKUBWA WA HERUFI';

  @override
  String get settingsFontWeightHeader => 'UNENE WA HERUFI';

  @override
  String get settingsWeightLight => 'Nyembamba';

  @override
  String get settingsWeightRegular => 'Kawaida';

  @override
  String get settingsWeightMedium => 'Wastani';

  @override
  String get settingsWeightBold => 'Nene';

  @override
  String get settingsLineSpacingHeader => 'NAFASI YA MISTARI';

  @override
  String get settingsSpacingCompact => 'Kubana';

  @override
  String get settingsSpacingNormal => 'Kawaida';

  @override
  String get settingsMarginsHeader => 'PAMBIZO';

  @override
  String get settingsAlignmentHeader => 'MPANGILIO';

  @override
  String get settingsAlignLeft => 'Kushoto';

  @override
  String get settingsAlignCenter => 'Katikati';

  @override
  String get settingsAlignRight => 'Kulia';

  @override
  String get settingsAlignJustified => 'Pande zote';

  @override
  String get settingsFontFamilyHeader => 'AINA YA HERUFI';

  @override
  String get settingsItalicHeader => 'MAANDISHI YA MLALO';

  @override
  String get settingsDailyReading => 'Kusoma Kila Siku';

  @override
  String get settingsCustomReminder => 'Kikumbusho Maalum';

  @override
  String get settingsMonday => 'Jumatatu';

  @override
  String get settingsTuesday => 'Jumanne';

  @override
  String get settingsWednesday => 'Jumatano';

  @override
  String get settingsThursday => 'Alhamisi';

  @override
  String get settingsFriday => 'Ijumaa';

  @override
  String get settingsSaturday => 'Jumamosi';

  @override
  String get settingsSunday => 'Jumapili';

  @override
  String settingsStrongsPackRequired(String size) {
    return 'Inahitaji kifurushi cha “KJV with Strong\'s” (upakuaji wa $size).';
  }

  @override
  String settingsBbeNoteBody(int count) {
    return 'Bible in Basic English iliacha baadhi ya mistari bila kutafsiriwa au ikiwa imefupishwa sana. Kwa hiyo ($count mistari), maandishi ya World English Bible (WEB) yanaonyeshwa badala yake na kuwekwa alama ya WEB.';
  }

  @override
  String settingsDayAtTime(String day, String time) {
    return '$day saa $time';
  }

  @override
  String get spaceTitle => 'Nafasi Yako';

  @override
  String get spaceTabHighlights => 'Vivutio';

  @override
  String get spaceTabBookmarks => 'Alamisho';

  @override
  String get spaceTabNotes => 'Maelezo';

  @override
  String get spaceTabJournal => 'Shajara';

  @override
  String get spaceHighlighted => 'Imeangaziwa';

  @override
  String get spaceNewFolder => 'Folda Mpya';

  @override
  String get spaceFolderNameHint => 'Jina la folda';

  @override
  String get spaceCreate => 'Unda';

  @override
  String get spaceRenameFolder => 'Badilisha Jina la Folda';

  @override
  String get spaceRename => 'Badilisha jina';

  @override
  String get spaceDeleteFolderTitle => 'Futa Folda?';

  @override
  String spaceDeleteFolderBody(String folderName) {
    return 'Una uhakika unataka kufuta \"$folderName\"?\n\nAlamisho ndani ya folda hii HAZITAFUTWA; zitahamishiwa Bila Folda.';
  }

  @override
  String get spaceMoveToFolder => 'Hamishia Folda';

  @override
  String get spaceUnfiled => 'Bila Folda';

  @override
  String get spaceGroupEarlier => 'Awali';

  @override
  String get spaceGroupLast7Days => 'Siku 7 Zilizopita';

  @override
  String get spaceGroupLast30Days => 'Siku 30 Zilizopita';

  @override
  String get spaceUnknownBook => 'Kitabu Kisichojulikana';

  @override
  String get spaceNoBookmarks => 'Hakuna alamisho hapa.';

  @override
  String get spaceFilterAll => 'Zote';

  @override
  String get spaceByDate => 'Kwa Tarehe';

  @override
  String get spaceByBook => 'Kwa Kitabu';

  @override
  String get spaceYourNotes => 'Maelezo yako.';

  @override
  String get spaceNoNotesTapPlus => 'Hakuna maelezo bado.\nGusa + kuunda moja.';

  @override
  String get spaceMore => 'Zaidi';

  @override
  String get spaceNote => 'Maelezo';

  @override
  String get spaceCopyText => 'Nakili maandishi';

  @override
  String get spaceDeleteNoteTitle => 'Futa maelezo?';

  @override
  String spaceDeleteNoteBody(String title) {
    return '\"$title\" itaondolewa kabisa.';
  }

  @override
  String get spaceUntitled => 'Bila kichwa';

  @override
  String get spaceBookmarkedVerse => 'Mstari ulioalamishwa';

  @override
  String get spaceHighlightedVerse => 'Mstari ulioangaziwa';

  @override
  String get spaceOpenInRead => 'Fungua katika Soma';

  @override
  String get spaceAddNote => 'Ongeza maelezo';

  @override
  String get spaceCopyVerse => 'Nakili mstari';

  @override
  String get spaceShareVerse => 'Shiriki mstari';

  @override
  String get spaceChangeColour => 'Badilisha rangi';

  @override
  String get spaceMoveToFolderAction => 'Hamishia folda';

  @override
  String get spaceRemoveBookmark => 'Ondoa alamisho';

  @override
  String get spaceRemoveHighlight => 'Ondoa kivutio';

  @override
  String get spaceHighlightColour => 'Rangi ya kivutio';

  @override
  String spaceColourN(int index) {
    return 'Rangi $index';
  }

  @override
  String get notesMyNotes => 'Maelezo Yangu';

  @override
  String get notesEmptyTitle => 'Hakuna maelezo bado';

  @override
  String get notesEmptyBody =>
      'Gusa kitufe cha + kuongeza maelezo yako ya kwanza.';

  @override
  String get notesVerseInserted => 'Mstari umeingizwa';

  @override
  String get notesAddCommentary => 'Ongeza Ufafanuzi';

  @override
  String get notesChapterTitlePlaceholder => 'Kichwa cha Sura';

  @override
  String get notesEditNote => 'Hariri Maelezo';

  @override
  String notesNewNoteOn(String reference) {
    return 'Maelezo Mapya juu ya $reference';
  }

  @override
  String get notesNewNote => 'Maelezo Mapya';

  @override
  String get notesTitleHint => 'Kichwa cha Maelezo';

  @override
  String get notesContentHint => 'Anza kuandika... (andika / kwa amri)';

  @override
  String get notesInsertVerse => 'Ingiza mstari';

  @override
  String get notesInsertDate => 'Ingiza tarehe';

  @override
  String get notesInsertChapterTitle => 'Ingiza kichwa cha sura';

  @override
  String get notesSaved => 'Maelezo yamehifadhiwa!';

  @override
  String get notesSaveChanges => 'Hifadhi Mabadiliko';

  @override
  String get notesSaveNote => 'Hifadhi Maelezo';

  @override
  String get notesDeleted => 'Maelezo yamefutwa';

  @override
  String get notesDeleteNote => 'Futa Maelezo';

  @override
  String get notesNewJournalEntry => 'Ingizo Jipya la Shajara';

  @override
  String get notesJournalHint => 'Unajisikiaje leo? Mimina moyo wako...';

  @override
  String get notesSaveAndAnalyze => 'Hifadhi na Uchambue';

  @override
  String get notesNoJournalEntries => 'Hakuna maingizo ya shajara bado.';

  @override
  String get notesWriteEntry => 'Andika';

  @override
  String get notesAiReflection => 'Tafakari ya AI';

  @override
  String notesDetectedEmotion(String emotion) {
    return 'Hisia Iliyogunduliwa: $emotion';
  }

  @override
  String notesVersesList(String verses) {
    return 'Mistari: $verses';
  }

  @override
  String get accountGuest => 'Mgeni';

  @override
  String get accountSignInToSync => 'Ingia ili kusawazisha vifaa';

  @override
  String get accountAccount => 'Akaunti';

  @override
  String get accountSettings => 'Mipangilio';

  @override
  String get accountBackUp => 'Hifadhi nakala';

  @override
  String get accountBackUpSubtitle => 'Hamisha maelezo, vivutio na mipangilio';

  @override
  String get accountRestore => 'Rejesha data';

  @override
  String get accountRestoreSubtitle => 'Leta kutoka faili la nakala';

  @override
  String get accountSignInGoogle => 'Ingia kwa Google';

  @override
  String get accountSignInApple => 'Ingia kwa Apple';

  @override
  String get accountSignOut => 'Toka';

  @override
  String get accountResetApp => 'Weka upya programu';

  @override
  String get accountResetAppSubtitle => 'Futa data yote kwenye kifaa';

  @override
  String get accountSignIn => 'Ingia';

  @override
  String get accountSignedIn => 'Umeingia';

  @override
  String get accountDeleteAccount => 'Futa Akaunti';

  @override
  String get accountDeleteAccountTitle => 'Futa Akaunti?';

  @override
  String get accountDeleteAccountBody =>
      'Hili ni la kudumu na haliwezi kutenduliwa.\n\nVifuatavyo vitaondolewa kabisa:\n• Akaunti yako ya kuingia\n• Data yake ya wingu katika The Blessed Bible na Blessed Arcade (zinashiriki akaunti)\n• Data yote ya kujifunza kwenye kifaa (alamisho, vivutio, historia)';

  @override
  String get accountDeleted => 'Akaunti imefutwa.';

  @override
  String accountReauthFailed(String reason) {
    return 'Hatukuweza kuthibitisha ni wewe, hivyo hakuna kilichofutwa. $reason';
  }

  @override
  String get accountDeleteFailed =>
      'Imeshindwa kufuta akaunti. Tafadhali jaribu tena.';

  @override
  String get accountOtherDataTitle =>
      'Kifaa hiki kina data ya akaunti nyingine';

  @override
  String get accountOtherDataBody =>
      'Alamisho, vivutio na maelezo kwenye kifaa hiki yametoka akaunti nyingine. Yafanywe nini?';

  @override
  String get accountStartFresh => 'Anza upya kwenye kifaa hiki';

  @override
  String get accountMerge => 'Unganisha na akaunti hii';

  @override
  String get accountSignOutTitle => 'Toka?';

  @override
  String get accountSignOutBody =>
      'Alamisho, vivutio na maelezo yako yako salama kwenye akaunti yako. Uhifadhi nakala kwenye kifaa hiki?';

  @override
  String get accountRemoveFromDevice => 'Ondoa kwenye kifaa';

  @override
  String get accountKeepOnDevice => 'Weka kwenye kifaa';

  @override
  String get accountSyncing => 'Inasawazisha…';

  @override
  String get accountSyncFailed => 'Imeshindwa kusawazisha';

  @override
  String get accountTapToRetry => 'Gusa kujaribu tena';

  @override
  String get accountSyncPaused => 'Usawazishaji umesitishwa';

  @override
  String get accountSyncChoose => 'Chagua la kufanya na data ya kifaa hiki';

  @override
  String get accountSyncNow => 'Sawazisha sasa';

  @override
  String get accountNotSyncedYet => 'Bado haijasawazishwa';

  @override
  String get accountSyncedJustNow => 'Imesawazishwa sasa hivi';

  @override
  String accountSyncedMinAgo(int minutes) {
    return 'Imesawazishwa dak $minutes zilizopita';
  }

  @override
  String accountSyncedHoursAgo(int hours) {
    return 'Imesawazishwa saa $hours zilizopita';
  }

  @override
  String accountSyncedOn(int day, int month, int year) {
    return 'Imesawazishwa $day/$month/$year';
  }

  @override
  String get accountRestoreTitle => 'Rejesha kutoka Nakala';

  @override
  String get accountRestoreHint => 'Bandika JSON ya nakala hapa...';

  @override
  String get accountRestoreAction => 'Rejesha';

  @override
  String get accountResetTitle => 'Weka upya programu?';

  @override
  String get accountResetBody =>
      'Hii inafuta data yote kwenye kifaa:\n• Alamisho, vivutio, maelezo na shajara\n• Mipango ya kusoma, maendeleo na mipango yako\n• Tafsiri zilizopakuliwa na mfululizo\n\nMipangilio, mandhari na Biblia ya nje ya mtandao havitaguswa. Haiwezi kutenduliwa — hifadhi nakala kwanza ikihitajika.';

  @override
  String get accountResetDone => 'Data imewekwa upya. Mwanzo mpya!';

  @override
  String get accountReset => 'Weka upya';

  @override
  String get shareBackdrop => 'Mandharinyuma';

  @override
  String get shareBackdropDawn => 'Alfajiri';

  @override
  String get shareBackdropDusk => 'Machweo';

  @override
  String get shareBackdropArtwork => 'Mchoro';

  @override
  String get shareBackdropGradient => 'Upinde rangi';

  @override
  String get shareFont => 'Fonti';

  @override
  String get shareFontTheme => 'Mandhari';

  @override
  String get shareSize => 'Ukubwa';

  @override
  String get shareSpacing => 'Nafasi';

  @override
  String get shareSpacingNormal => 'Kawaida';

  @override
  String shareSpacingWide(String value) {
    return 'Pana $value';
  }

  @override
  String get shareLineHeight => 'Urefu wa mstari';

  @override
  String get shareAlignment => 'Mpangilio';

  @override
  String get shareAlignCenter => 'Katikati';

  @override
  String get shareAlignLeft => 'Kushoto';

  @override
  String get sharePreparing => 'Inaandaa…';

  @override
  String get shareImage => 'Shiriki picha';

  @override
  String get shareText => 'Shiriki maandishi';

  @override
  String get shareImageCard => 'Shiriki kadi ya picha';

  @override
  String get spaceStorageTitle => 'Hifadhi';

  @override
  String get spaceClearCacheTitle => 'Futa akiba?';

  @override
  String get spaceClearCacheBody =>
      'Huondoa faili za muda (kadi za kushiriki, picha ndogo). Maelezo, alamisho, vivutio na vipakuliwa vyako havitaguswa.';

  @override
  String get spaceClearCache => 'Futa akiba';

  @override
  String get spaceCacheCleared => 'Akiba imefutwa';

  @override
  String spaceDeletePackTitle(String name) {
    return 'Futa $name?';
  }

  @override
  String spaceDeletePackBundled(String size) {
    return 'Inaachilia $size. Unaweza kuirejesha bila mtandao wakati wowote.';
  }

  @override
  String spaceDeletePackDownloaded(String size) {
    return 'Inaachilia $size. Unaweza kuipakua tena baadaye.';
  }

  @override
  String spacePackDeleted(String abbr) {
    return '$abbr imefutwa';
  }

  @override
  String spacePackDownloaded(String abbr) {
    return '$abbr imepakuliwa';
  }

  @override
  String spaceCouldNotFinish(String error) {
    return 'Imeshindwa kukamilisha: $error';
  }

  @override
  String spaceFreed(String message, String size) {
    return '$message · $size zimeachiliwa';
  }

  @override
  String get spaceOnThisDevice => 'Kwenye kifaa hiki';

  @override
  String get spaceBibleContent => 'Maudhui ya Biblia (huhifadhiwa daima)';

  @override
  String get spaceDownloadedPacks => 'Vifurushi vilivyopakuliwa';

  @override
  String get spaceCache => 'Akiba';

  @override
  String get spaceCacheExplain =>
      'Faili za muda tu — kadi za kushiriki na picha ndogo. Ni salama kufuta wakati wowote.';

  @override
  String get spaceTranslationsDownloads => 'Tafsiri na vipakuliwa';

  @override
  String get spaceBundledSuffix => ' · imejumuishwa';

  @override
  String get spaceCoreNotRemovable =>
      'KJV na BBE ni sehemu ya programu na haziwezi kuondolewa.';

  @override
  String get spaceGet => 'Pata';

  @override
  String spaceDeletePackTooltip(String name) {
    return 'Futa $name';
  }

  @override
  String studyCouldNotOpenScreen(String error) {
    return 'Imeshindwa kufungua skrini hiyo. $error';
  }

  @override
  String get studyCardSize => 'Ukubwa wa kadi';

  @override
  String get studyPosition => 'Mahali';

  @override
  String get studySizeLarge => 'Kubwa';

  @override
  String get studySizeLargeHint => 'Upana kamili, sawa na zingine';

  @override
  String get studySizeExtraLarge => 'Kubwa zaidi';

  @override
  String get studySizeExtraLargeHint => 'Upana kamili, maudhui yenye nafasi';

  @override
  String get studySizeHalf => 'Nusu';

  @override
  String get studySizeHalfHint => 'Ndogo, mbili kwa safu';

  @override
  String get studyMoveUp => 'Sogeza juu';

  @override
  String get studyMoveUpHint => 'Badilisha na kadi ya juu';

  @override
  String get studyMoveDown => 'Sogeza chini';

  @override
  String get studyMoveDownHint => 'Badilisha na kadi ya chini';

  @override
  String get studyCommentaryEyebrow => 'Ufafanuzi';

  @override
  String get studyCommentaryTitle => 'Maarifa mstari kwa mstari';

  @override
  String get studyCommentarySnippet =>
      'Ufafanuzi wa kihistoria wenye vichujio vya sura na mstari.';

  @override
  String get studyCommentaryCta => 'Fungua ufafanuzi';

  @override
  String get studyDictionaryEyebrow => 'Kamusi';

  @override
  String get studyDictionaryTitle => 'Maneno yamefafanuliwa';

  @override
  String get studyDictionarySnippet =>
      'Easton na Smith, nje ya mtandao, na maneno yaliyohifadhiwa.';

  @override
  String get studyDictionaryCta => 'Tafuta';

  @override
  String get studyStoriesEyebrow => 'Hadithi za Biblia';

  @override
  String get studyStoriesTitle => 'Simulizi zilizosimuliwa upya';

  @override
  String get studyStoriesSnippet => 'Hadithi 66 kutoka kila kitabu.';

  @override
  String get studyStoriesCta => 'Soma hadithi';

  @override
  String get studyConcordanceEyebrow => 'Konkodansi';

  @override
  String get studyConcordanceTitle => 'Kila mahali neno lilipo';

  @override
  String get studyConcordanceSnippet =>
      'Pata kila mstari ambapo neno linaonekana.';

  @override
  String get studyConcordanceCta => 'Tafuta maneno';

  @override
  String get studySpaceSaved => 'Zilizohifadhiwa';

  @override
  String get studySpaceMarked => 'Zilizowekwa alama';

  @override
  String get studySpaceNotes => 'Maelezo';

  @override
  String get studySpaceJournal => 'Shajara';

  @override
  String get studySpaceTitle => 'Nafasi yako';

  @override
  String get studySpaceSubtitle => 'Alamisho, vivutio, maelezo na shajara';

  @override
  String get studyReadingPlan => 'Mpango wa kusoma';

  @override
  String get studyStartReadingPlan => 'Anza mpango wa kusoma';

  @override
  String get studyActivePlan => 'Mpango unaoendelea';

  @override
  String studyDayOfTotal(int current, int total) {
    return 'Siku $current kati ya $total';
  }

  @override
  String studyDaysBehind(int count) {
    return '$count nyuma';
  }

  @override
  String get studyPlans => 'Mipango';

  @override
  String get studyGuidedReading => 'Usomaji ulioongozwa';

  @override
  String get studyGuidedReadingSubtitle => 'Teule, kwa mwendo na maalum';

  @override
  String get studyReadyToBegin => 'Tayari kuanza';

  @override
  String studyTodayLabel(String label) {
    return 'Leo: $label';
  }

  @override
  String get studyReview => 'Pitia';

  @override
  String get studyRead => 'Soma';

  @override
  String studyCtaArrow(String cta) {
    return '$cta →';
  }

  @override
  String get studyWordOfTheDay => 'Neno la siku';

  @override
  String get studyArchiveLink => 'Kumbukumbu →';

  @override
  String get studyLoading => 'Inapakia…';

  @override
  String get studyUnavailableNow => 'Haipatikani kwa sasa';

  @override
  String get studyReadingStreak => 'Mfululizo wa kusoma';

  @override
  String get studyStartStreak => 'Anza mfululizo wako';

  @override
  String studyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Siku $count',
      one: 'Siku 1',
    );
    return '$_temp0';
  }

  @override
  String get studyStreakGrow => 'Fungua kila siku ili uikuze.';

  @override
  String get studyStreakStart => 'Kamilisha usomaji kila siku.';

  @override
  String get studyViewProgress => 'Tazama maendeleo →';

  @override
  String get studyPassageNotFound => 'Kifungu hakijapatikana';

  @override
  String get studyPassageLoadError => 'Imeshindwa kupakia kifungu.';

  @override
  String get studyCompletedCheck => '✓ Imekamilika';

  @override
  String get studyMarkAsRead => 'Weka kuwa imesomwa';

  @override
  String get studyNextPassage => 'Kifungu kijacho';

  @override
  String get studyFullChapter => 'Sura nzima';

  @override
  String studyPassageOfTotal(int current, int total) {
    return 'Kifungu $current kati ya $total';
  }

  @override
  String studySelectedCount(int count) {
    return '$count vimechaguliwa';
  }

  @override
  String get studyHighlight => 'Angazia';

  @override
  String get studyBookmark => 'Alamisho';

  @override
  String get studyAddNote => 'Ongeza maelezo';

  @override
  String studyChaptersWithContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sura $count zenye maudhui',
      one: 'Sura 1 yenye maudhui',
    );
    return '$_temp0';
  }

  @override
  String get studyCommentaryLibrary => 'Maktaba ya ufafanuzi';

  @override
  String get studyCommentaryLoadError => 'Imeshindwa kupakia ufafanuzi.';

  @override
  String get studyNoCommentaryYet => 'Bado hakuna ufafanuzi.';

  @override
  String studyNoBooksMatch(String query) {
    return 'Hakuna kitabu kinacholingana na \"$query\".';
  }

  @override
  String studySearchBooksCount(int count) {
    return 'Tafuta katika vitabu $count…';
  }

  @override
  String get studyClassicSources => 'Vyanzo vya kale';

  @override
  String studyBookAuthorChapters(String author, int count) {
    return '$author · sura $count';
  }

  @override
  String studyReadingRef(String reference) {
    return 'Usomaji · $reference';
  }

  @override
  String get studyAllSources => 'Vyanzo vyote';

  @override
  String get studyVerseLevel => 'Kwa mstari';

  @override
  String studySearchWithin(String reference) {
    return 'Tafuta ndani ya $reference…';
  }

  @override
  String studyEntriesLoadError(String error) {
    return 'Imeshindwa kupakia maingizo.\n$error';
  }

  @override
  String get studyNoEntriesMatch =>
      'Hakuna maingizo yanayolingana na vichujio hivi.\nJaribu Vyanzo vyote, au vinjari maktaba.';

  @override
  String studyVerseN(int verse) {
    return 'Mstari $verse';
  }

  @override
  String get studyChapter => 'Sura';

  @override
  String get studyCategoryCommentary => 'Ufafanuzi';

  @override
  String get studyCategoryDevotional => 'Ibada';

  @override
  String get studyCategoryStudyNote => 'Dokezo la funzo';

  @override
  String studyCommentaryLoadErrorDetail(String error) {
    return 'Imeshindwa kupakia ufafanuzi.\n$error';
  }

  @override
  String get studyNoContentForFilters => 'Hakuna maudhui kwa vichujio hivi.';

  @override
  String studyVerseLabel(String verse) {
    return 'Mstari $verse';
  }

  @override
  String get studyChapterView => 'Mwonekano wa sura';

  @override
  String get studyFilterAll => 'Zote';

  @override
  String get studyFilterDevotionals => 'Ibada';

  @override
  String get studyFilterAllContexts => 'Miktadha yote';

  @override
  String get studyFilterChapterLevel => 'Kwa sura';

  @override
  String get studyFilterVerseLevel => 'Kwa mstari';

  @override
  String get studyRemoveBookmark => 'Ondoa alamisho';

  @override
  String get studyBookmarkCommentary => 'Weka alamisho';

  @override
  String get studyExpandFullScreen => 'Panua skrini nzima';

  @override
  String get studyTapToReadInContext => 'Gusa kusoma katika muktadha';

  @override
  String get studyOnThisChapter => 'Kuhusu sura hii';

  @override
  String get studyOnThisBook => 'Kuhusu kitabu hiki';

  @override
  String get studyNoCommentaryTitle => 'Bado hakuna ufafanuzi';

  @override
  String get studyNoCommentaryBody =>
      'Hatukupata ufafanuzi maalum wa kifungu hiki. Jaribu ufafanuzi wa sura au kitabu hapa chini.';

  @override
  String get storiesTitle => 'Hadithi za Biblia';

  @override
  String get storiesFilters => 'Vichujio';

  @override
  String get storiesSubtitle =>
      'Matukio 500 yenye picha kutoka Mwanzo hadi Ufunuo';

  @override
  String get storiesSearchHint => 'Tafuta kichwa, kitabu au rejea…';

  @override
  String get storiesClearSearch => 'Futa utafutaji';

  @override
  String get storiesFilterAll => 'Zote';

  @override
  String get storiesFilterOt => 'AK';

  @override
  String get storiesFilterNt => 'AJ';

  @override
  String storiesCountOfTotal(int count, int total) {
    return 'Hadithi $count kati ya $total';
  }

  @override
  String get storiesFavorites => 'Vipendwa';

  @override
  String get storiesUnread => 'Hazijasomwa';

  @override
  String storiesLoadError(String error) {
    return 'Imeshindwa kupakia hadithi:\n$error';
  }

  @override
  String get storiesBooks => 'Vitabu';

  @override
  String get storiesSearchBooks => 'Tafuta vitabu…';

  @override
  String get storiesAllBooks => 'Vitabu vyote';

  @override
  String get storiesNoMatch => 'Hakuna hadithi inayolingana na vichujio hivi.';

  @override
  String get storiesNoFavorites => 'Bado hakuna vipendwa.';

  @override
  String get storiesBrowseAll => 'Vinjari hadithi zote';

  @override
  String get storiesAllCaughtUp => 'Umesoma zote.';

  @override
  String get storiesShowRead => 'Onyesha hadithi zilizosomwa';

  @override
  String get storiesClearFilters => 'Futa vichujio';

  @override
  String get storiesFavoritesHint =>
      'Gusa ♥ kwenye hadithi yoyote kuihifadhi hapa.';

  @override
  String get storiesAttribution =>
      'Maandiko kutoka King James Version (kikoa cha umma). Muhtasari umetoholewa kutoka The Graham Bible (grahambible.com), kwa msaada wa AI na kukaguliwa na binadamu. Picha: Gustave Doré (1832–1883), kikoa cha umma, kupitia Wikimedia Commons.';

  @override
  String get storiesReachedEnd => 'Umefika mwisho.';

  @override
  String get storiesFirstStory => 'Hii ni hadithi ya kwanza.';

  @override
  String get storiesFavorite => 'Kipendwa';

  @override
  String get storiesMarkAsRead => 'Weka kuwa imesomwa';

  @override
  String storiesKeyVerse(String reference) {
    return 'MSTARI MKUU · $reference';
  }

  @override
  String get storiesTheStory => 'HADITHI';

  @override
  String storiesArtworkCaption(String caption) {
    return 'Picha: $caption — Gustave Doré, kikoa cha umma';
  }

  @override
  String get storiesPrevious => 'Hadithi iliyotangulia';

  @override
  String get storiesNext => 'Hadithi inayofuata';

  @override
  String get studyDictionarySearchHint => 'Tafuta maneno 3,400+…';

  @override
  String get studyDictionarySavedFilter => '★ Zilizohifadhiwa';

  @override
  String studyDictionaryUnavailable(String error) {
    return 'Kamusi haipatikani.\n$error';
  }

  @override
  String get studyNoHeadwords => 'Hakuna vichwa vya maneno vilivyopatikana.';

  @override
  String get studyDictionaryNoMatches =>
      'Hakuna matokeo. Jaribu “grace”, “atonement” au “wilderness” (kamusi ya Kiingereza).';

  @override
  String studyResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Matokeo $count',
      one: 'Tokeo 1',
    );
    return '$_temp0';
  }

  @override
  String get studyUntitledEntry => '(ingizo bila kichwa)';

  @override
  String get studyRemoveSavedWord => 'Ondoa neno lililohifadhiwa';

  @override
  String get studySaveWord => 'Hifadhi neno';

  @override
  String get studyNoDefinition => 'Hakuna maana iliyopatikana.';

  @override
  String studyFailedToLoad(String error) {
    return 'Imeshindwa kupakia: $error';
  }

  @override
  String studyStrongsShareText(String id, String lemma, String transliteration,
      String pronunciation, String definition) {
    return '$id - $lemma\n\nUnukuzi: $transliteration\nMatamshi: $pronunciation\n\nMaana:\n$definition';
  }

  @override
  String studyNoStrongsEntry(String id) {
    return 'Hakuna ingizo la $id.';
  }

  @override
  String get studyStrongsLexicon => 'KAMUSI YA STRONG';

  @override
  String get studyConcordanceHint =>
      'Neno la Kiingereza (k.m. grace, covenant)…';

  @override
  String get studyConcordanceIntro =>
      'Matukio katika KJV — gusa mstari kuusoma katika muktadha.';

  @override
  String get studyConcordanceEmpty =>
      'Kila mstari wenye neno lako, kwa mpangilio wa vitabu.';

  @override
  String get studyConcordanceSingleWord => 'Andika neno moja la Kiingereza.';

  @override
  String studyConcordanceNoVerses(String word) {
    return 'Hakuna mstari wenye \"$word\".';
  }

  @override
  String studyConcordanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mistari $count',
      one: 'Mstari 1',
    );
    return '$_temp0';
  }

  @override
  String studyConcordanceCountTruncated(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mistari $count',
      one: 'Mstari 1',
    );
    return '$_temp0 ($limit ya kwanza yameonyeshwa)';
  }

  @override
  String get creditsTitle => 'Shukrani na vyanzo';

  @override
  String get creditsLicenses => 'Leseni za chanzo huria';

  @override
  String get creditsLicensesSubtitle => 'Fonti na vifurushi vya programu';

  @override
  String studyPreparingOfflineBible(int percent) {
    return 'Inaandaa Biblia nje ya mtandao… $percent%';
  }

  @override
  String get errorTitle => 'Hitilafu imetokea';

  @override
  String get errorBody =>
      'Tatizo lisilotarajiwa limetokea. Gusa hapa chini kurudi mwanzo.';

  @override
  String get errorBackHome => 'Rudi mwanzo';

  @override
  String studyWeekN(int week) {
    return 'Wiki $week';
  }

  @override
  String get privacyTitle => 'Sera ya faragha';

  @override
  String get privacyLoadError => 'Imeshindwa kupakia sera ya faragha.';

  @override
  String privacyEffectiveDate(String date) {
    return 'Tarehe ya kuanza kutumika: $date';
  }

  @override
  String get privacyEnglishOnly => 'Sera hii inapatikana kwa Kiingereza.';

  @override
  String get privacyViewOnline => 'Tazama mtandaoni';
}
