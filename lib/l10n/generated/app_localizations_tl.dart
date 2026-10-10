// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get appTitle => 'The Blessed Bible';

  @override
  String get commonCancel => 'Kanselahin';

  @override
  String get commonContinue => 'Magpatuloy';

  @override
  String get commonSkip => 'Laktawan';

  @override
  String get commonBack => 'Bumalik';

  @override
  String get commonDone => 'Tapos na';

  @override
  String get commonSave => 'I-save';

  @override
  String get commonDelete => 'Burahin';

  @override
  String get commonClose => 'Isara';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Subukan muli';

  @override
  String get commonShare => 'Ibahagi';

  @override
  String get commonCopy => 'Kopyahin';

  @override
  String get commonEdit => 'I-edit';

  @override
  String get commonSearch => 'Maghanap';

  @override
  String get languageTitle => 'Wika';

  @override
  String get languageSystem => 'Kapareho ng device';

  @override
  String get languageSubtitle =>
      'Ang wika ng mga menu at button. Hiwalay na pinipili ang salin ng Bibliya.';

  @override
  String get onboardingTagline => 'Ang Kasulatan, walang abala.';

  @override
  String get onboardingPickLanguage => 'Piliin ang iyong wika';

  @override
  String get onboardingLanguageHint =>
      'Mababago mo ito anumang oras sa Settings.';

  @override
  String get onboardingBibleTitle => 'Ang iyong Bibliya';

  @override
  String get onboardingBibleBody =>
      'Piliin ang saling madalas mong basahin. Maaari kang magpakita ng pangalawa nang magkatabi.';

  @override
  String onboardingParallel(String name) {
    return 'Ipakita rin ang $name sa tabi';
  }

  @override
  String get onboardingLookTitle => 'Gawing komportable';

  @override
  String get onboardingLookBody =>
      'Pumili ng kulay ng pahina at laki ng teksto. Maaaring ayusin ang lahat mamaya.';

  @override
  String get onboardingThemeLight => 'Maliwanag';

  @override
  String get onboardingThemeSepia => 'Sepia';

  @override
  String get onboardingThemeDark => 'Madilim';

  @override
  String get onboardingTextSize => 'Laki ng teksto';

  @override
  String get onboardingPreviewVerse =>
      'Nang pasimula ay ang Salita, at ang Salita ay kasama ng Diyos, at ang Salita ay Diyos.';

  @override
  String get onboardingPreviewRef => 'Juan 1:1';

  @override
  String get onboardingFeaturesTitle =>
      'Lahat para sa iyong araw-araw na paglakad';

  @override
  String get onboardingFeatureWordTitle => 'Ang Dalisay na Salita';

  @override
  String get onboardingFeatureWordBody =>
      'Magbasa nang walang abala, may highlight, tala at bookmark.';

  @override
  String get onboardingFeaturePlansTitle => 'Mga Plano sa Pagbasa';

  @override
  String get onboardingFeaturePlansBody =>
      'Kronolohikal, ayon sa paksa o sarili mo — may banayad na paalala.';

  @override
  String get onboardingFeatureStudyTitle => 'Malalim na Pag-aaral';

  @override
  String get onboardingFeatureStudyBody =>
      'Komentaryo, diksyunaryo, Strong at mapa, katabi ng teksto.';

  @override
  String get onboardingFeatureSyncTitle => 'Ligtas';

  @override
  String get onboardingFeatureSyncBody =>
      'Mag-sign in anumang oras para i-sync ang iyong mga device. Hindi kailangan ng account para magbasa.';

  @override
  String get onboardingBegin => 'Simulan ang pagbasa';

  @override
  String onboardingStep(int current, int total) {
    return 'Hakbang $current sa $total';
  }

  @override
  String get plansContinueReading => 'Ituloy ang Pagbasa';

  @override
  String get plansResume => 'Ituloy';

  @override
  String plansDayCompleteCelebration(int day) {
    return 'Plano sa Pagbasa\nTapos na ang Araw $day!';
  }

  @override
  String get plansChangeWeek => 'Palitan ang linggo';

  @override
  String plansCalendarDayComplete(String label) {
    return '$label, tapos na ang pagbasa';
  }

  @override
  String plansCalendarDayToday(String label) {
    return '$label, ngayon';
  }

  @override
  String get plansDailyVerses => 'Talata sa Araw-araw';

  @override
  String get plansToday => 'Ngayon';

  @override
  String get plansYesterday => 'Kahapon';

  @override
  String plansDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw na ang nakalipas',
      one: '1 araw na ang nakalipas',
    );
    return '$_temp0';
  }

  @override
  String get plansHello => 'Kumusta,';

  @override
  String plansOpenStory(String caption) {
    return 'Buksan ang kuwento: $caption';
  }

  @override
  String get plansBibleStory => 'Kuwento sa Biblia';

  @override
  String plansSlotsFull(int count) {
    return 'Ginagamit na ang lahat ng $count puwesto ng plano. I-pause ang isang plano para magbakante — mananatili ang progreso.';
  }

  @override
  String get plansPausedSnack =>
      'Naka-pause ang plano — mananatili ang lahat ng progreso.';

  @override
  String get plansBrowseToStart =>
      'Tingnan ang Pagbasa para simulan ang iyong unang plano.';

  @override
  String get plansFriend => 'Kaibigan';

  @override
  String get plansTitle => 'Mga Plano';

  @override
  String get plansTabReading => 'Pagbasa';

  @override
  String get plansTabBooks => 'Mga Aklat';

  @override
  String plansTabMyPlans(int count) {
    return 'Aking Plano ($count)';
  }

  @override
  String get plansNotStarted => 'Hindi pa nasisimulan';

  @override
  String plansPercentDone(int percent) {
    return '$percent% tapos';
  }

  @override
  String get plansOpen => 'Buksan';

  @override
  String get plansPaused => 'Naka-pause';

  @override
  String get plansStarted => 'Nasimulan na';

  @override
  String plansDaysBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw na huli',
      one: '1 araw na huli',
    );
    return '$_temp0';
  }

  @override
  String get plansCaughtUp => 'Nakahabol na';

  @override
  String get plansComplete => 'Kumpleto';

  @override
  String plansDayOfTotalLeft(int current, int total, int left) {
    return 'Araw $current sa $total · $left pa';
  }

  @override
  String get plansPauseKeepsProgress => 'I-pause (mananatili ang progreso)';

  @override
  String get plansStart => 'Simulan';

  @override
  String plansPresetBookTitle(String book, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$book sa $days araw',
      one: '$book sa 1 araw',
    );
    return '$_temp0';
  }

  @override
  String plansPresetGospelsTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Mga Ebanghelyo sa $days araw',
      one: 'Mga Ebanghelyo sa 1 araw',
    );
    return '$_temp0';
  }

  @override
  String plansPresetSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days araw · i-tap para buuin',
      one: '1 araw · i-tap para buuin',
    );
    return '$_temp0';
  }

  @override
  String get plansYourCustomPlans => 'IYONG MGA SARILING PLANO';

  @override
  String plansDayOfTotal(int day, int total) {
    return 'Araw $day sa $total';
  }

  @override
  String get plansCustomPlan => 'Sariling plano';

  @override
  String get plansNoActivePlans => 'Walang aktibong plano';

  @override
  String get plansNoActivePlansBody =>
      'Tingnan ang Pagbasa o Mga Aklat para simulan ang iyong unang plano.';

  @override
  String get plansLetsRead => 'Tara, magbasa';

  @override
  String get plansVerseOfTheDay => 'Talata ng araw';

  @override
  String get plansOpenTodaysReading => 'Buksan ang pagbasa ngayon';

  @override
  String get plansLastDayOfYear => 'Huling araw ng taon';

  @override
  String plansDaysLeftInYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw na lang ngayong taon',
      one: '1 araw na lang ngayong taon',
    );
    return '$_temp0';
  }

  @override
  String get plansCustomPlanDefaultTitle => 'Sariling Plano';

  @override
  String get plansCustom => 'Sarili';

  @override
  String plansBookRange(String start, String end) {
    return '$start hanggang $end';
  }

  @override
  String plansCouldNotSave(String error) {
    return 'Hindi ma-save ang plano: $error';
  }

  @override
  String get plansBuilderTitle => 'Bumuo ng Plano';

  @override
  String plansError(String error) {
    return 'Error: $error';
  }

  @override
  String get plansPlanName => 'Pangalan ng plano';

  @override
  String get plansPlanNameHint => 'hal. Genesis sa 30 Araw';

  @override
  String get plansReadingTracks => 'Mga ruta ng pagbasa';

  @override
  String get plansAddTrack => 'Magdagdag ng ruta';

  @override
  String get plansTracksOverlap =>
      'Nagsasapawan ang mga ruta — isang beses lang bibilangin ang magkaparehong talata sa preview sa ibaba.';

  @override
  String get plansDuration => 'Tagal';

  @override
  String plansDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw',
      one: '1 araw',
    );
    return '$_temp0';
  }

  @override
  String get plansDaysSuffix => 'araw';

  @override
  String get plansStartRestReminder => 'Simula, pahinga at paalala';

  @override
  String get plansStartDate => 'Petsa ng simula';

  @override
  String get plansRestDaysNeutral => 'Araw ng pahinga (neutral)';

  @override
  String get plansNone => 'Wala';

  @override
  String get plansDailyReminder => 'Araw-araw na paalala';

  @override
  String plansReminderAt(String time) {
    return 'Sa $time';
  }

  @override
  String get plansOff => 'Naka-off';

  @override
  String get plansLivePreview => 'Live na preview';

  @override
  String get plansPreviewEmpty =>
      'Magdagdag ng kahit isang ruta sa itaas para makita ang balanseng iskedyul.';

  @override
  String get plansWordBalanced => 'Balanse sa salita · sumusunod sa mga talata';

  @override
  String plansPreviewSummary(int days, int readingDays) {
    return '$days araw · $readingDays araw ng pagbasa';
  }

  @override
  String plansClampedNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Ang pinakamagaan na takbo para sa napili ay $days araw. Na-update ang pamagat sa tunay na bilang ng araw.',
      one:
          'Ang pinakamagaan na takbo para sa napili ay 1 araw. Na-update ang pamagat sa tunay na bilang ng araw.',
    );
    return '$_temp0';
  }

  @override
  String plansPreviewDay(int day, String portions) {
    return 'Araw $day: $portions';
  }

  @override
  String plansMoreBalancedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pang balanseng araw',
      one: '1 pang balanseng araw',
    );
    return '$_temp0';
  }

  @override
  String get plansSaving => 'Sine-save…';

  @override
  String get plansGenerateAndSave => 'Buuin at i-save →';

  @override
  String get plansNameAndTrackHint =>
      'Pangalanan ang plano at magdagdag ng kahit isang ruta para magpatuloy.';

  @override
  String get plansStartEllipsis => 'Simula…';

  @override
  String get plansEndEllipsis => 'Wakas…';

  @override
  String get plansStartLabel => 'SIMULA';

  @override
  String get plansEndLabel => 'WAKAS';

  @override
  String get plansRemoveTrack => 'Alisin ang ruta';

  @override
  String plansRestChip(String days) {
    return 'Pahinga $days';
  }

  @override
  String plansRebasedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Inusog ang iskedyul nang $count araw ng pagbasa. Hindi nagalaw ang mga natapos na araw.',
      one:
          'Inusog ang iskedyul nang 1 araw ng pagbasa. Hindi nagalaw ang mga natapos na araw.',
    );
    return '$_temp0';
  }

  @override
  String get plansPlan => 'Plano';

  @override
  String get plansNoReadingsYet => 'Wala pang babasahin ang planong ito.';

  @override
  String plansReadingDaysWeeks(int days, int weeks) {
    return '$days araw ng pagbasa · ~$weeks linggo';
  }

  @override
  String get plansBeginPlan => 'Simulan ang plano';

  @override
  String get plansStartDayOne => 'Simulan ang Araw 1 →';

  @override
  String get plansStartDateNote =>
      'Magsisimula ang plano sa petsang pipiliin mo.';

  @override
  String get plansScheduleLabel => 'ISKEDYUL';

  @override
  String get plansNoReadings => 'Walang babasahin';

  @override
  String plansPercentComplete(int percent) {
    return '$percent% kumpleto';
  }

  @override
  String get plansFlexible => 'Flexible';

  @override
  String get plansScheduled => 'May iskedyul';

  @override
  String plansBehindChip(int count) {
    return '$count huli';
  }

  @override
  String get plansOnTrack => 'Nasa tamang takbo';

  @override
  String get plansFlexibleHelp =>
      'Flexible: unahin ang pinakalumang hindi pa nabasang araw. Hindi naiipon ang mga na-miss na araw.';

  @override
  String get plansScheduledHelp =>
      'May iskedyul: may nakatakdang pagbasa ang bawat petsa. Ang na-miss na araw ay bibilanging huli — humabol sa ibaba.';

  @override
  String get plansCatchUp => 'Humabol';

  @override
  String plansBehindBy(int count, int day) {
    return 'Huli nang $count — ang pinakalumang hindi pa nababasa ay Araw $day.';
  }

  @override
  String get plansCatchUpHelp =>
      'Ang pagmarka ng mga araw ay nagtatala ng progreso. Ang pag-usog naman ay iniuurong ang natitirang iskedyul.';

  @override
  String get plansGoToOldest => 'Pumunta sa pinakaluma';

  @override
  String get plansMarkOldestDone => 'Markahan ang pinakaluma';

  @override
  String get plansAllPreviousDone => 'Tapos na ang lahat bago ngayong araw.';

  @override
  String plansPreviousMarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nakaraang araw ang minarkahang nabasa.',
      one: '1 nakaraang araw ang minarkahang nabasa.',
    );
    return '$_temp0';
  }

  @override
  String get plansMarkAllPrevious => 'Markahan lahat ng nakaraan';

  @override
  String plansRebaseDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Iusog nang +$count araw',
      one: 'Iusog nang +1 araw',
    );
    return '$_temp0';
  }

  @override
  String plansReadingsHeader(int count) {
    return 'PAGBASA · $count ARAW';
  }

  @override
  String get plansJourneyMap => 'Mapa ng paglalakbay';

  @override
  String get plansJumpToToday => 'Pumunta sa ngayon';

  @override
  String plansDayN(int day) {
    return 'Araw $day';
  }

  @override
  String get plansLegendDone => 'Nabasa';

  @override
  String get plansLegendToday => 'Ngayon = bilog';

  @override
  String get plansLegendMissed => 'Na-miss';

  @override
  String plansReminderAtTime(String time) {
    return 'Paalala · $time';
  }

  @override
  String get plansReminderOff => 'Naka-off ang paalala';

  @override
  String get plansReminderHelp =>
      'Abiso para sa planong ito — awtomatikong nilalaktawan ang araw ng pahinga.';

  @override
  String get plansRestDays => 'Araw ng pahinga';

  @override
  String get plansNoRestDays => 'Walang araw ng pahinga';

  @override
  String get plansSettings => 'Mga setting ng plano';

  @override
  String get plansAboutEllipsis => 'Tungkol sa planong ito…';

  @override
  String get plansAbout => 'Tungkol sa planong ito';

  @override
  String get plansChangeStartDate => 'Palitan ang petsa ng simula…';

  @override
  String plansRestDaysValue(String days) {
    return 'Araw ng pahinga: $days';
  }

  @override
  String get plansRestDaysHelp => 'I-tap para pumili ng mga araw';

  @override
  String get plansRestartFromDayOne => 'Magsimulang muli sa Araw 1…';

  @override
  String get plansRestartTitle => 'Simulan muli ang plano?';

  @override
  String get plansRestartBody => 'Mabubura ang mga natapos na araw.';

  @override
  String get plansRestart => 'Simulan muli';

  @override
  String get plansMarkUnread => 'Markahang hindi pa nabasa';

  @override
  String get plansMarkRead => 'Markahang nabasa';

  @override
  String get plansRestAndReflect => 'Magpahinga at magnilay';

  @override
  String get plansRestDayBody =>
      'Araw ng pahinga — walang nakatakdang pagbasa ngayon.';

  @override
  String get plansDayDetailHelp =>
      'I-tap ang isang talata para buksan. Lagyan ng tsek habang nagbabasa.';

  @override
  String plansMilestone(int count) {
    return '$count pagbasa ang natapos — ituloy mo!';
  }

  @override
  String get plansCompletedTapToUndo => 'Tapos na — i-tap para i-undo';

  @override
  String plansMarkDayRead(int day, int checked, int total) {
    return 'Markahang nabasa ang Araw $day ✓ ($checked/$total talata)';
  }

  @override
  String get todayGoodMorning => 'Magandang umaga';

  @override
  String get todayGoodAfternoon => 'Magandang hapon';

  @override
  String get todayGoodEvening => 'Magandang gabi';

  @override
  String get todayGoodNight => 'Magandang gabi';

  @override
  String get todayStreakNudge =>
      'Magbasa ngayon para mapanatili ang iyong streak!';

  @override
  String get todayNotificationsSoon => 'Malapit na ang mga abiso!';

  @override
  String get todaySectionResume => 'ITULOY';

  @override
  String get todaySectionStreak => 'STREAK SA PAGBASA';

  @override
  String get todaySectionLatestNote => 'PINAKABAGONG TALA';

  @override
  String get todaySectionQuickActions => 'MABILISANG AKSIYON';

  @override
  String get todaySectionReminders => 'ARAW-ARAW NA PAALALA';

  @override
  String get todayTagline => 'Ang iyong araw-araw na sandali ng kapayapaan.';

  @override
  String get todayNoNotesYet => 'Wala pang tala';

  @override
  String get todayWriteFirstNote =>
      'Isulat ang iyong unang tala para makita ito rito.';

  @override
  String get todayViewAllNotes => 'Tingnan lahat ng tala';

  @override
  String todayStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw na streak',
      one: '1 araw na streak',
    );
    return '$_temp0';
  }

  @override
  String todayDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw na lang ang natitira ngayong taon.',
      one: '1 araw na lang ang natitira ngayong taon.',
    );
    return '$_temp0';
  }

  @override
  String get todayActionRead => 'Basahin';

  @override
  String get todayActionSurprise => 'Sorpresahin Ako';

  @override
  String get todayActionReadingPlan => 'Plano sa Pagbasa';

  @override
  String get todayActionYourSpace => 'Iyong Espasyo';

  @override
  String get todayVotdArchive => 'Archive ng Talata ng Araw';

  @override
  String get todayVotdArchiveBody =>
      'Balikan ang mga talata sa mga araw na na-miss mo.';

  @override
  String get todayVotdArchiveExplore => 'Tuklasin ang mga nakaraang talata';

  @override
  String get readActionBookmark => 'Bookmark';

  @override
  String get readActionNote => 'Tala';

  @override
  String get readActionNotes => 'Mga tala';

  @override
  String get readActionEditNote => 'I-edit ang tala';

  @override
  String get readActionCommentary => 'Komentaryo';

  @override
  String get readActionRelated => 'Kaugnay';

  @override
  String get readActionHighlight => 'I-highlight';

  @override
  String get readActionStudy => 'Pag-aralan';

  @override
  String get readActionSaved => 'Na-save';

  @override
  String get readActionSelectText => 'Pumili ng teksto';

  @override
  String get readVerseActions => 'Mga aksyon sa talata';

  @override
  String readVersesSelected(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count talata ang napili',
      one: '1 talata ang napili',
    );
    return '$_temp0 · $where';
  }

  @override
  String get readCommentaryHint =>
      'I-tap ang bombilya sa tabi ng talata para sa komentaryo';

  @override
  String get readPassageNotFound => 'Hindi nakita ang talata.';

  @override
  String get readChapterCommentary =>
      'Basahin ang komentaryo sa kabanatang ito';

  @override
  String get readPreviousChapter => '‹ Nakaraan';

  @override
  String get readNextChapter => 'Susunod ›';

  @override
  String readPlanDay(int day) {
    return 'Plano sa Pagbasa · Araw $day';
  }

  @override
  String get readPlanCompleted => 'Tapos na ang plano! Binabati kita! 🎉';

  @override
  String readMarkDoneContinue(String book, int chapter) {
    return 'Tapusin ang $book $chapter at magpatuloy';
  }

  @override
  String get readNone => 'Wala';

  @override
  String readBookFallback(int number) {
    return 'Aklat $number';
  }

  @override
  String get readRelatedVerses => 'Mga kaugnay na talata';

  @override
  String get readNoCrossRefs => 'Walang cross-reference para sa talatang ito.';

  @override
  String get readCrossRefsComingSoon =>
      'Magiging available ang cross-reference\npagkatapos ng susunod na update.';

  @override
  String readCrossRefsLoadError(String error) {
    return 'Hindi ma-load ang cross-reference.\n$error';
  }

  @override
  String get readVerseUnavailable => 'Hindi available ang talata';

  @override
  String get readLoading => 'Naglo-load…';

  @override
  String get readVerseNotFound => 'Hindi nakita ang talata.';

  @override
  String get readBookOrChapterNotFound => 'Hindi nakita ang aklat o kabanata.';

  @override
  String get readOpenInRead => 'Buksan sa Basahin';

  @override
  String get readBookNotFound => 'Hindi nakita ang tinukoy na aklat.';

  @override
  String readVerseLoadError(String error) {
    return 'Error sa pag-load ng talata: $error';
  }

  @override
  String get readTestament => 'Tipan';

  @override
  String get readBook => 'Aklat';

  @override
  String get readChapter => 'Kabanata';

  @override
  String get readVerse => 'Talata';

  @override
  String get readSelectBook => 'Pumili ng aklat';

  @override
  String get readOtShort => 'LT';

  @override
  String get readNtShort => 'BT';

  @override
  String get readOldTestament => 'Lumang Tipan';

  @override
  String get readNewTestament => 'Bagong Tipan';

  @override
  String get readOldTestamentTwoLine => 'Lumang\nTipan';

  @override
  String get readNewTestamentTwoLine => 'Bagong\nTipan';

  @override
  String get readStoriesSections => 'Mga Kuwento at Seksyon';

  @override
  String get readAllVerses => 'Lahat ng talata';

  @override
  String get readTranslationTitle => 'Salin ng Bibliya';

  @override
  String get readLayoutTitle => 'Layout ng pagbasa';

  @override
  String get readLayoutSingle => 'Isa';

  @override
  String get readLayoutBilingual => 'Bilingual';

  @override
  String get readLayoutParallel => 'Magkatabi';

  @override
  String get readLayoutChips => 'Chips';

  @override
  String get readLayoutSingleDesc => 'Isang salin';

  @override
  String get readLayoutBilingualDesc => 'Dalawang salin bawat talata';

  @override
  String get readLayoutParallelDesc => 'Dalawang salin sa magkatabing kolum';

  @override
  String get readLayoutChipsDesc => 'I-tap ang talata para palitan ang salin';

  @override
  String get readPrimary => 'Pangunahin';

  @override
  String get readSecondary => 'Pangalawa';

  @override
  String readTranslationsLoadError(String error) {
    return 'Error sa pag-load ng mga salin: $error';
  }

  @override
  String readTranslationDeleted(String name) {
    return 'Nabura ang $name.';
  }

  @override
  String readDeleteFailed(String error) {
    return 'Hindi mabura: $error';
  }

  @override
  String readDeleteTranslation(String name) {
    return 'Burahin ang $name';
  }

  @override
  String get readKjvAlwaysAvailable => 'Laging available · pundasyon ng app';

  @override
  String get readCannotDeleteBackbone => 'Hindi mabubura — pundasyon ng app';

  @override
  String get readAvailableToAdd => 'PUWEDENG IDAGDAG';

  @override
  String get readNoInternet => 'Walang internet — subukan muli kapag online.';

  @override
  String get readRestoreFailed => 'Nabigo ang pag-restore';

  @override
  String get readDownloadFailed => 'Nabigo ang pag-download';

  @override
  String readRestoreFailedDetail(String error) {
    return 'Nabigo ang pag-restore ($error).';
  }

  @override
  String readDownloadFailedDetail(String error) {
    return 'Nabigo ang pag-download ($error).';
  }

  @override
  String get readRestoreOffline => 'i-restore offline';

  @override
  String get homeVerseOfTheDay => 'TALATA NG ARAW';

  @override
  String get homeDevotional => 'DEBOSYONAL';

  @override
  String get homeCommentary => 'KOMENTARYO';

  @override
  String get homeGoDeeper => 'Lumalim pa';

  @override
  String get homeReadFullDefinition => 'Basahin ang buong kahulugan';

  @override
  String get homeWordOfTheDayHeading => 'SALITA NG ARAW';

  @override
  String get homeWordOfTheDay => 'Salita ng araw';

  @override
  String get homeWotdEmpty =>
      'Wala pang salitang napili ngayon — subukan mamaya.';

  @override
  String homeWotdUnavailable(String error) {
    return 'Hindi available ang salita ng araw ($error).';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navRead => 'Basahin';

  @override
  String get navStudy => 'Pag-aaral';

  @override
  String get navSearch => 'Hanapin';

  @override
  String get navExitTitle => 'Lumabas sa The Blessed Bible?';

  @override
  String get navExitMessage => 'Sigurado ka bang gusto mong lumabas sa app?';

  @override
  String get navExit => 'Lumabas';

  @override
  String get navCastLotsError => 'Hindi makapagsapalaran — subukan muli.';

  @override
  String get navCastingLots => 'Nagsasapalaran…';

  @override
  String get searchHint => 'Hanapin ang talata, komentaryo…';

  @override
  String get searchAllBooks => 'Lahat ng aklat';

  @override
  String get searchFilterMyNotes => 'Aking mga tala';

  @override
  String get searchEmptyPrompt =>
      'Hanapin sa Bibliya, komentaryo\nat iyong mga tala';

  @override
  String get searchRecentSearches => 'MGA HULING HINANAP';

  @override
  String get searchClear => 'BURAHIN';

  @override
  String get searchRecentPlaces => 'MGA HULING BINASA';

  @override
  String get searchMostRead => 'PINAKABINABASA';

  @override
  String get searchNoResults => 'Walang nakitang resulta';

  @override
  String get searchTopResults => 'Ipinapakita ang nangungunang 100 resulta';

  @override
  String searchResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resulta ang nakita',
      one: '1 resulta ang nakita',
    );
    return '$_temp0';
  }

  @override
  String searchSectionDictionary(int count) {
    return 'DIKSYUNARYO ($count)';
  }

  @override
  String searchSectionStories(int count) {
    return 'MGA KUWENTO ($count)';
  }

  @override
  String searchSectionJumpTo(int count) {
    return 'PUMUNTA SA ($count)';
  }

  @override
  String searchSectionVerses(int count) {
    return 'MGA TALATA ($count)';
  }

  @override
  String searchSectionCommentary(int count) {
    return 'KOMENTARYO ($count)';
  }

  @override
  String searchSectionMyNotes(int count) {
    return 'AKING MGA TALA ($count)';
  }

  @override
  String get searchCopied => 'Nakopya sa clipboard';

  @override
  String get settingsTitle => 'Mga Setting';

  @override
  String get settingsTabGeneral => 'Pangkalahatan';

  @override
  String get settingsTabNavigation => 'Nabigasyon';

  @override
  String get settingsTabReminders => 'Mga Paalala';

  @override
  String get settingsTabInfo => 'Impormasyon';

  @override
  String get settingsWidgetsTitle => 'Mga Widget sa Home Screen';

  @override
  String get settingsWidgetsSubtitle =>
      'I-customize ang gradient, transparency at live preview';

  @override
  String get settingsStartPageTitle => 'Panimulang pahina';

  @override
  String get settingsStartPageSubtitle =>
      'Piliin ang pahinang bubukas sa pagsisimula';

  @override
  String get settingsPageHome => 'Home';

  @override
  String get settingsPageRead => 'Basahin';

  @override
  String get settingsPageStudy => 'Pag-aaral';

  @override
  String get settingsPageSearch => 'Hanapin';

  @override
  String get settingsImmersiveReading => 'Malalim na Pagbabasa';

  @override
  String get settingsImmersiveOffTitle => 'Nakaangkla (Off)';

  @override
  String get settingsImmersiveOffSubtitle => 'Laging nakikita ang nabigasyon';

  @override
  String get settingsImmersivePartialTitle => 'Gabay (Bahagya)';

  @override
  String get settingsImmersivePartialSubtitle =>
      'Itinatago ang nabigasyon, pero iniiwan ang aklat at kabanata';

  @override
  String get settingsImmersiveFullTitle => 'Malalim na Tubig (Buo)';

  @override
  String get settingsImmersiveFullSubtitle =>
      'Buong paglubog. Nagtatago ang lahat ng menu kapag nag-scroll';

  @override
  String get settingsShowStrongs => 'Ipakita ang mga Numero ng Strong';

  @override
  String get settingsShowStrongsSubtitle =>
      'Ipinapakita ang orihinal na Hebreo/Griyego kasama ng KJV para sa pag-aaral ng salita';

  @override
  String get settingsStrongsGetIt => 'Kunin';

  @override
  String get settingsStrongsMarkerAsterisk => 'Asterisk (*)';

  @override
  String get settingsStrongsMarkerChain => 'Kadena (🔗)';

  @override
  String get settingsStrongsMarkerNumber => 'Numero (H1234)';

  @override
  String get settingsReadingSpeed => 'Bilis ng pagbasa';

  @override
  String get settingsReadingSpeedSubtitle =>
      'Tantiyang bilis para sa mga plano (salita kada minuto)';

  @override
  String get settingsSpeedRelaxed => 'Maluwag';

  @override
  String get settingsSpeedStandard => 'Karaniwan';

  @override
  String get settingsSpeedBrisk => 'Mabilis';

  @override
  String get settingsDictUnderlines => 'Mga Salungguhit ng Diksiyonaryo';

  @override
  String get settingsDictUnderlinesSubtitle =>
      'May tuldok na salungguhit sa mga terminong biblikal at lumang salita';

  @override
  String get settingsUnderlineScope => 'Saklaw ng Salungguhit';

  @override
  String get settingsScopeNamesTitle => 'Mga pangalan at termino lamang';

  @override
  String get settingsScopeNamesSubtitle =>
      'Mga pangngalang pantangi at tiyak na konseptong biblikal';

  @override
  String get settingsScopeTrickyTitle =>
      'Pangalan + mahirap na salita (Inirerekomenda)';

  @override
  String get settingsScopeTrickySubtitle =>
      'Kasama ang lumang salitang nagbago ang kahulugan (hal. let, prevent)';

  @override
  String get settingsScopeEverythingTitle => 'Lahat';

  @override
  String get settingsScopeEverythingSubtitle =>
      'Minamarkahan ang lahat ng lumang gramatika (hal. thee, thou, hath, unto)';

  @override
  String get settingsScopeDifficultTitle => 'Mahirap na salita lamang';

  @override
  String get settingsScopeDifficultSubtitle =>
      'Luma, nakalilito at pinagtatalunang salita — hindi minamarkahan ang madadali gaya ng god at son';

  @override
  String get settingsScopeDifficultNamesTitle => 'Mahirap + pangalan';

  @override
  String get settingsScopeDifficultNamesSubtitle =>
      'Idinadagdag ang tao at lugar (hal. David, Jerusalem) sa mahirap na salita';

  @override
  String get settingsOtherEnglishVersions => 'Ibang bersyong Ingles';

  @override
  String get settingsContestedOnlyTitle => 'Pinagtatalunang salita lamang';

  @override
  String get settingsContestedOnlySubtitle =>
      'Minamarkahan ng BBE, WEB at ibang bersyong Ingles ang pinagtatalunang salita (hal. hell, baptism)';

  @override
  String get settingsFollowScopeTitle => 'Sundin ang saklaw ng salungguhit';

  @override
  String get settingsFollowScopeSubtitle =>
      'Kaparehong marka ng KJV sa bawat bersyong Ingles';

  @override
  String get settingsNoUnderlinesTitle => 'Walang salungguhit';

  @override
  String get settingsNoUnderlinesSubtitle =>
      'Walang marka ng diksiyonaryo sa ibang bersyong Ingles';

  @override
  String get settingsPopupStyle => 'Estilo ng Popup';

  @override
  String get settingsPopupStyleSubtitle =>
      'Paano ipinapakita ang kahulugan at numero ng Strong';

  @override
  String get settingsPopupFloating => 'Lumulutang';

  @override
  String get settingsPopupBottomSheet => 'Bottom sheet';

  @override
  String get settingsSavedInMyLanguage => 'Ipakita ang naka-save sa aking wika';

  @override
  String get settingsSavedInMyLanguageSubtitle =>
      'Ipakita ang bookmark, highlight at talatang may komentaryo sa iyong pangunahing salin';

  @override
  String get settingsTranslationChips =>
      'Ipakita ang opsyon ng salin sa naka-save';

  @override
  String get settingsTranslationChipsSubtitle =>
      'Nagdaragdag ng hanay para makita ang naka-save na talata sa ibang salin';

  @override
  String get settingsVerseActionStyle => 'Estilo ng Aksyon sa Talata';

  @override
  String get settingsVerseActionStyleSubtitle =>
      'Sheet (siksik) o Classic (mataas) kapag pumili ng talata; inilalagay ng Radial ang long-press menu sa bilog';

  @override
  String get settingsActionSheet => 'Sheet';

  @override
  String get settingsActionClassic => 'Classic';

  @override
  String get settingsActionMinimal => 'Minimal';

  @override
  String get settingsActionRaindrop => 'Patak';

  @override
  String get settingsActionRadial => 'Radial';

  @override
  String get settingsKeepAwake => 'Panatilihing Bukas ang Screen';

  @override
  String get settingsKeepAwakeSubtitle =>
      'Pigilan ang pag-sleep habang nagbabasa';

  @override
  String get settingsRestartOnboarding => 'Ulitin ang onboarding';

  @override
  String get settingsRestartOnboardingSubtitle => 'Ulitin ang unang setup';

  @override
  String get settingsRestartOnboardingDialogTitle => 'Ulitin ang onboarding?';

  @override
  String get settingsRestartOnboardingDialogBody =>
      'Uulitin nito ang unang setup. Mananatili ang iyong tema, font at salin maliban kung baguhin mo.';

  @override
  String get settingsRestart => 'Ulitin';

  @override
  String get settingsAppearanceText => 'Itsura at teksto';

  @override
  String get settingsAppearanceTextSubtitle => 'Tema, font, laki at kulay';

  @override
  String get settingsSabbathTitle =>
      'Paalala sa Paglubog ng Araw tuwing Biyernes';

  @override
  String get settingsSabbathSubtitle =>
      'Salubungin ang Sabbath sa paglubog ng araw sa inyong lugar.';

  @override
  String get settingsLocation => 'Lokasyon';

  @override
  String get settingsLocationNotSet => 'Hindi nakatakda (I-tap para itakda)';

  @override
  String get settingsDailyReminderTitle => 'Paalala sa Araw-araw na Pagbasa';

  @override
  String get settingsDailyReminderSubtitle =>
      'Araw-araw na paalala na maglaan ng oras sa Salita.';

  @override
  String get settingsTime => 'Oras';

  @override
  String get settingsWeeklyReminderTitle => 'Lingguhang Paalala';

  @override
  String get settingsWeeklyReminderSubtitle =>
      'Pumili ng araw at oras bawat linggo para sa mas malalim na pag-aaral.';

  @override
  String get settingsDayAndTime => 'Araw at Oras';

  @override
  String get settingsChooseDay => 'Pumili ng Araw';

  @override
  String get settingsShowReadingTips => 'Ipakita ang mga tip sa pagbasa';

  @override
  String get settingsShowReadingTipsSubtitle =>
      'Gabay para sa pag-highlight, pag-swipe at iba pa';

  @override
  String get settingsNavSteps => 'Mga Hakbang sa Nabigasyon';

  @override
  String get settingsNavStepsSubtitle =>
      'Ilang hakbang bago marating ang talata. 2: Aklat → Kabanata. 3: Aklat → Kabanata → Talata. 4: Tipan → Aklat → Kabanata → Talata.';

  @override
  String get settingsAutoClose => 'Isara pagkatapos ng huling pili';

  @override
  String get settingsAutoCloseSubtitle =>
      'Kusang isara ang picker pagkatapos ng huling hakbang';

  @override
  String get settingsSelectorHeight => 'Taas ng pagpili ng aklat';

  @override
  String get settingsSelectorHeightSubtitle =>
      'Gaano kataas bubukas ang aklat/kabanata';

  @override
  String get settingsHeightHalf => 'Kalahati';

  @override
  String get settingsHeightFull => 'Buo';

  @override
  String get settingsAutoOpenSingle => 'Kusang buksan ang iisang resulta';

  @override
  String get settingsAutoOpenSingleSubtitle =>
      'Direktang pumunta kapag iisa lang ang resulta';

  @override
  String get settingsIncludeNotes => 'Isama ang personal na tala sa paghahanap';

  @override
  String get settingsIncludeNotesSubtitle =>
      'Payagang hanapin sa iyong mga tala';

  @override
  String get settingsWholeWords => 'Buong salita lamang';

  @override
  String get settingsWholeWordsSubtitle =>
      'Eksaktong salita lamang (walang bahagyang tugma)';

  @override
  String get settingsFuzzySearch => 'Mapagpatawad na paghahanap';

  @override
  String get settingsFuzzySearchSubtitle =>
      'Ipakita rin ang malapit na tugma sa mali (hal. Jhon → John)';

  @override
  String get settingsDefaultScopes => 'Default na Saklaw ng Paghahanap';

  @override
  String get settingsOldTestament => 'Lumang Tipan';

  @override
  String get settingsNewTestament => 'Bagong Tipan';

  @override
  String get settingsCommentary => 'Komentaryo';

  @override
  String get settingsGestures => 'Mga Kumpas';

  @override
  String get settingsPullDownHome => 'Hilahin pababa sa Home';

  @override
  String get settingsPullDownHomeSubtitle =>
      'Hilahin lampas sa itaas para buksan ang Settings o Itsura';

  @override
  String get settingsPullDownOpens => 'Binubuksan ng paghila';

  @override
  String get settingsPullDownOpensSubtitle => 'Patutunguhan ng paghila sa Home';

  @override
  String get settingsAppearance => 'Itsura';

  @override
  String get settingsSwipeLeftHome => 'Mag-swipe pakaliwa sa Home';

  @override
  String get settingsSwipeLeftHomeSubtitle =>
      'Mag-swipe pakaliwa papunta sa Basahin';

  @override
  String get settingsLongPressNav => 'Pindutin nang matagal para sa nabigasyon';

  @override
  String get settingsLongPressNavSubtitle =>
      'Pindutin nang matagal ang button sa kanang ibaba para sa Aklat/Kabanata.';

  @override
  String get settingsBbeNoteTitle => 'Tala sa Salin ng BBE';

  @override
  String get settingsBackup => 'I-back up ang aking data';

  @override
  String get settingsBackupSubtitle =>
      'I-export ang tala, highlight at setting';

  @override
  String get settingsRestoreBackup => 'I-restore mula sa backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'I-import ang data mula sa backup JSON';

  @override
  String get settingsRestoreBackupDialogTitle => 'I-restore mula sa Backup';

  @override
  String get settingsRestoreHint => 'I-paste dito ang backup JSON…';

  @override
  String get settingsRestore => 'I-restore';

  @override
  String get settingsClearCache => 'I-clear ang cache/na-download';

  @override
  String get settingsClearCacheSubtitle =>
      'Magbakante ng espasyo sa pagbura ng cache';

  @override
  String get settingsNotImplemented => 'Hindi pa available';

  @override
  String get settingsResetSettings => 'I-reset ang mga setting';

  @override
  String get settingsResetSettingsSubtitle =>
      'Ibalik ang orihinal na setting (mananatili ang nilalaman)';

  @override
  String get settingsResetDialogTitle => 'I-reset ang mga setting?';

  @override
  String get settingsResetDialogBody =>
      'I-reset ang lahat ng setting? Hindi maaapektuhan ang iyong bookmark, tala o highlight.';

  @override
  String get settingsResetDone => 'Na-reset ang mga setting.';

  @override
  String get settingsReset => 'I-reset';

  @override
  String get settingsVersion => 'Bersyon';

  @override
  String get settingsUnknown => 'Hindi alam';

  @override
  String get settingsStorage => 'Storage at download';

  @override
  String get settingsStorageSubtitle =>
      'Cache, na-download na salin at maaaring bakantehin';

  @override
  String get settingsSendFeedback => 'Magpadala ng Feedback';

  @override
  String get settingsCrashReports => 'Magpadala ng crash report';

  @override
  String get settingsCrashReportsSubtitle =>
      'Nakatutulong ang anonimong detalye sa pag-aayos ng bug. Walang pagbasa ng Biblia, tala o personal na nilalaman.';

  @override
  String get settingsPrivacyPolicy => 'Patakaran sa Privacy';

  @override
  String get settingsCredits => 'Credits at pinagmulan';

  @override
  String get settingsCreditsSubtitle =>
      'Salin ng Biblia, komentaryo, datos sa pag-aaral, font at lisensya';

  @override
  String get settingsSetSunsetLocation =>
      'Itakda ang Lokasyon ng Paglubog ng Araw';

  @override
  String get settingsCurrentLocationGps => 'Kasalukuyang Lokasyon (GPS)';

  @override
  String get settingsUseMyLocation => 'Gamitin ang aking lokasyon';

  @override
  String get settingsOrSelectCity => 'O pumili ng malaking lungsod';

  @override
  String get settingsTypography => 'Tipograpiya';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsSearchSettings => 'Mga Setting sa Paghahanap';

  @override
  String get settingsMatchTypeHeader => 'URI NG TUGMA';

  @override
  String get settingsExactMatch => 'Eksaktong Tugma';

  @override
  String get settingsExactMatchSubtitle => 'Eksaktong parirala lamang';

  @override
  String get settingsScopeHeader => 'SAKLAW';

  @override
  String get settingsDisabledBookFilter => 'Naka-off (May filter ng aklat)';

  @override
  String get settingsMyNotes => 'Aking mga Tala';

  @override
  String get settingsBehaviorHeader => 'PAG-UUGALI';

  @override
  String get settingsAutoOpenSingleShort => 'Kusang Buksan ang Iisang Resulta';

  @override
  String get settingsAutoOpenSingleShortSubtitle =>
      'Direktang pumunta kung iisa ang resulta';

  @override
  String get settingsBackgroundGlow => 'I-on ang Liwanag sa Background';

  @override
  String get settingsBackgroundGlowSubtitle =>
      'Banayad na gumagalaw na liwanag sa likod ng teksto';

  @override
  String get settingsThemeGroupFoundations => 'MGA SALIGAN';

  @override
  String get settingsThemeDawn => 'Bukang-liwayway';

  @override
  String get settingsThemeFresh => 'Sariwa';

  @override
  String get settingsThemeGroupFirmament => 'KALAWAKAN';

  @override
  String get settingsThemeSun => 'Araw';

  @override
  String get settingsThemeMoon => 'Buwan';

  @override
  String get settingsThemeStars => 'Bituin';

  @override
  String get settingsThemeGroupEden => 'EDEN';

  @override
  String get settingsThemeLilies => 'Liryo';

  @override
  String get settingsThemeRoses => 'Rosas';

  @override
  String get settingsThemeOlives => 'Olibo';

  @override
  String get settingsThemeGroupSanctuary => 'SANTUWARYO';

  @override
  String get settingsThemePurple => 'Lilang\nPari';

  @override
  String get settingsThemeBlue => 'Bughaw\nng Galilea';

  @override
  String get settingsThemeRed => 'Pulang\nEskarlata';

  @override
  String get settingsSurpriseMe => 'Sorpresahin ako';

  @override
  String get settingsThemeOledDark => 'OLED\nMadilim';

  @override
  String get settingsThemeDuskOled => 'Takipsilim\nOLED';

  @override
  String get settingsSurfaceStyle => 'Estilo ng Surface';

  @override
  String get settingsSurfaceStyleSubtitle => 'Lalim ng biswal at materyal';

  @override
  String get settingsSurfaceEarth => 'Lupa';

  @override
  String get settingsSurfaceEarthSubtitle => 'Patag na surface';

  @override
  String get settingsSurfaceHeaven => 'Langit';

  @override
  String get settingsSurfaceHeavenSubtitle => 'Malabong lalim';

  @override
  String get settingsSurfacePaper => 'Papel';

  @override
  String get settingsSurfacePaperSubtitle => 'Mainit na e-reader';

  @override
  String get settingsSurfaceClay => 'Luwad';

  @override
  String get settingsSurfaceClaySubtitle => 'Malambot na 3-D';

  @override
  String get settingsWidgetsLivePreview =>
      'Live preview at pag-customize ng estilo';

  @override
  String get settingsWidgetPreviewHeader => 'LIVE PREVIEW NG WIDGET';

  @override
  String get settingsWidgetStreak => 'Tuloy-tuloy! • Layunin sa Araw';

  @override
  String get settingsWidgetWotd => 'SALITA NG ARAW';

  @override
  String get settingsWidgetVotd => 'TALATA NG ARAW';

  @override
  String get settingsWidgetBackgroundHeader => 'BACKGROUND AT GRADIENT';

  @override
  String get settingsWidgetContrastHeader => 'CONTRAST NG TEKSTO';

  @override
  String get settingsWidgetTextAuto => 'Auto ✨';

  @override
  String get settingsWidgetTextDark => 'Madilim na Teksto ☀️';

  @override
  String get settingsWidgetTextWhite => 'Puting Teksto 🌙';

  @override
  String get settingsWidgetSynced =>
      'Na-sync ang mga widget sa bagong estilo! ✨';

  @override
  String get settingsWidgetApply => 'I-apply at i-sync sa Home Screen';

  @override
  String get settingsFontSizeHeader => 'LAKI NG FONT';

  @override
  String get settingsFontWeightHeader => 'KAPAL NG FONT';

  @override
  String get settingsWeightLight => 'Manipis';

  @override
  String get settingsWeightRegular => 'Regular';

  @override
  String get settingsWeightMedium => 'Katamtaman';

  @override
  String get settingsWeightBold => 'Makapal';

  @override
  String get settingsLineSpacingHeader => 'PAGITAN NG LINYA';

  @override
  String get settingsSpacingCompact => 'Siksik';

  @override
  String get settingsSpacingNormal => 'Normal';

  @override
  String get settingsMarginsHeader => 'MARGIN';

  @override
  String get settingsAlignmentHeader => 'PAGHAHANAY';

  @override
  String get settingsAlignLeft => 'Kaliwa';

  @override
  String get settingsAlignCenter => 'Gitna';

  @override
  String get settingsAlignRight => 'Kanan';

  @override
  String get settingsAlignJustified => 'Justified';

  @override
  String get settingsFontFamilyHeader => 'URI NG FONT';

  @override
  String get settingsItalicHeader => 'ITALIC NA TEKSTO';

  @override
  String get settingsDailyReading => 'Araw-araw na Pagbasa';

  @override
  String get settingsCustomReminder => 'Sariling Paalala';

  @override
  String get settingsMonday => 'Lunes';

  @override
  String get settingsTuesday => 'Martes';

  @override
  String get settingsWednesday => 'Miyerkules';

  @override
  String get settingsThursday => 'Huwebes';

  @override
  String get settingsFriday => 'Biyernes';

  @override
  String get settingsSaturday => 'Sabado';

  @override
  String get settingsSunday => 'Linggo';

  @override
  String settingsStrongsPackRequired(String size) {
    return 'Kailangan ang “KJV with Strong\'s” pack ($size na download).';
  }

  @override
  String settingsBbeNoteBody(int count) {
    return 'May mga talatang hindi isinalin o pinaikli nang husto sa Bible in Basic English. Para sa mga iyon ($count talata), ipinapakita ang World English Bible (WEB) na may markang WEB.';
  }

  @override
  String settingsDayAtTime(String day, String time) {
    return '$day nang $time';
  }

  @override
  String get spaceTitle => 'Iyong Espasyo';

  @override
  String get spaceTabHighlights => 'Mga Highlight';

  @override
  String get spaceTabBookmarks => 'Mga Bookmark';

  @override
  String get spaceTabNotes => 'Mga Tala';

  @override
  String get spaceTabJournal => 'Talaarawan';

  @override
  String get spaceHighlighted => 'Naka-highlight';

  @override
  String get spaceNewFolder => 'Bagong Folder';

  @override
  String get spaceFolderNameHint => 'Pangalan ng folder';

  @override
  String get spaceCreate => 'Gumawa';

  @override
  String get spaceRenameFolder => 'Palitan ang Pangalan ng Folder';

  @override
  String get spaceRename => 'Palitan ang pangalan';

  @override
  String get spaceDeleteFolderTitle => 'Burahin ang Folder?';

  @override
  String spaceDeleteFolderBody(String folderName) {
    return 'Sigurado ka bang buburahin ang \"$folderName\"?\n\nHINDI mabubura ang mga bookmark sa folder na ito; ililipat sila sa Walang Folder.';
  }

  @override
  String get spaceMoveToFolder => 'Ilipat sa Folder';

  @override
  String get spaceUnfiled => 'Walang Folder';

  @override
  String get spaceGroupEarlier => 'Mas maaga';

  @override
  String get spaceGroupLast7Days => 'Huling 7 Araw';

  @override
  String get spaceGroupLast30Days => 'Huling 30 Araw';

  @override
  String get spaceUnknownBook => 'Hindi kilalang aklat';

  @override
  String get spaceNoBookmarks => 'Walang bookmark dito.';

  @override
  String get spaceFilterAll => 'Lahat';

  @override
  String get spaceByDate => 'Ayon sa Petsa';

  @override
  String get spaceByBook => 'Ayon sa Aklat';

  @override
  String get spaceYourNotes => 'Iyong mga tala.';

  @override
  String get spaceNoNotesTapPlus =>
      'Wala pang tala.\nPindutin ang + para gumawa.';

  @override
  String get spaceMore => 'Higit pa';

  @override
  String get spaceNote => 'Tala';

  @override
  String get spaceCopyText => 'Kopyahin ang teksto';

  @override
  String get spaceDeleteNoteTitle => 'Burahin ang tala?';

  @override
  String spaceDeleteNoteBody(String title) {
    return 'Permanenteng aalisin ang \"$title\".';
  }

  @override
  String get spaceUntitled => 'Walang pamagat';

  @override
  String get spaceBookmarkedVerse => 'Naka-bookmark na talata';

  @override
  String get spaceHighlightedVerse => 'Naka-highlight na talata';

  @override
  String get spaceOpenInRead => 'Buksan sa Basahin';

  @override
  String get spaceAddNote => 'Magdagdag ng tala';

  @override
  String get spaceCopyVerse => 'Kopyahin ang talata';

  @override
  String get spaceShareVerse => 'Ibahagi ang talata';

  @override
  String get spaceChangeColour => 'Palitan ang kulay';

  @override
  String get spaceMoveToFolderAction => 'Ilipat sa folder';

  @override
  String get spaceRemoveBookmark => 'Alisin ang bookmark';

  @override
  String get spaceRemoveHighlight => 'Alisin ang highlight';

  @override
  String get spaceHighlightColour => 'Kulay ng highlight';

  @override
  String spaceColourN(int index) {
    return 'Kulay $index';
  }

  @override
  String get notesMyNotes => 'Aking mga Tala';

  @override
  String get notesEmptyTitle => 'Wala pang tala';

  @override
  String get notesEmptyBody => 'Pindutin ang + para idagdag ang una mong tala.';

  @override
  String get notesVerseInserted => 'Naisingit ang talata';

  @override
  String get notesAddCommentary => 'Magdagdag ng Komentaryo';

  @override
  String get notesChapterTitlePlaceholder => 'Pamagat ng Kabanata';

  @override
  String get notesEditNote => 'I-edit ang Tala';

  @override
  String notesNewNoteOn(String reference) {
    return 'Bagong Tala sa $reference';
  }

  @override
  String get notesNewNote => 'Bagong Tala';

  @override
  String get notesTitleHint => 'Pamagat ng Tala';

  @override
  String get notesContentHint =>
      'Magsimulang mag-type... (i-type ang / para sa mga utos)';

  @override
  String get notesInsertVerse => 'Isingit ang talata';

  @override
  String get notesInsertDate => 'Isingit ang petsa';

  @override
  String get notesInsertChapterTitle => 'Isingit ang pamagat ng kabanata';

  @override
  String get notesSaved => 'Na-save ang tala!';

  @override
  String get notesSaveChanges => 'I-save ang mga Pagbabago';

  @override
  String get notesSaveNote => 'I-save ang Tala';

  @override
  String get notesDeleted => 'Nabura ang tala';

  @override
  String get notesDeleteNote => 'Burahin ang Tala';

  @override
  String get notesNewJournalEntry => 'Bagong Tala sa Talaarawan';

  @override
  String get notesJournalHint =>
      'Kumusta ang pakiramdam mo ngayon? Ibuhos ang iyong puso...';

  @override
  String get notesSaveAndAnalyze => 'I-save at Suriin';

  @override
  String get notesNoJournalEntries => 'Wala pang tala sa talaarawan.';

  @override
  String get notesWriteEntry => 'Sumulat';

  @override
  String get notesAiReflection => 'Pagninilay ng AI';

  @override
  String notesDetectedEmotion(String emotion) {
    return 'Natukoy na Damdamin: $emotion';
  }

  @override
  String notesVersesList(String verses) {
    return 'Mga Talata: $verses';
  }

  @override
  String get accountGuest => 'Bisita';

  @override
  String get accountSignInToSync => 'Mag-sign in para mag-sync sa mga device';

  @override
  String get accountAccount => 'Account';

  @override
  String get accountSettings => 'Mga Setting';

  @override
  String get accountBackUp => 'I-back up ang data';

  @override
  String get accountBackUpSubtitle => 'I-export ang tala, highlight at setting';

  @override
  String get accountRestore => 'Ibalik ang data';

  @override
  String get accountRestoreSubtitle => 'Mag-import mula sa backup';

  @override
  String get accountSignInGoogle => 'Mag-sign in gamit ang Google';

  @override
  String get accountSignInApple => 'Mag-sign in gamit ang Apple';

  @override
  String get accountSignOut => 'Mag-sign out';

  @override
  String get accountResetApp => 'I-reset ang app';

  @override
  String get accountResetAppSubtitle => 'Burahin ang lahat ng data sa device';

  @override
  String get accountSignIn => 'Mag-sign in';

  @override
  String get accountSignedIn => 'Naka-sign in';

  @override
  String get accountDeleteAccount => 'Burahin ang Account';

  @override
  String get accountDeleteAccountTitle => 'Burahin ang Account?';

  @override
  String get accountDeleteAccountBody =>
      'Permanente ito at hindi na maibabalik.\n\nTuluyang aalisin ang mga sumusunod:\n• Ang iyong sign-in account\n• Ang cloud data nito sa The Blessed Bible at Blessed Arcade (iisang account)\n• Lahat ng study data sa device (bookmark, highlight, history)';

  @override
  String get accountDeleted => 'Matagumpay na nabura ang account.';

  @override
  String accountReauthFailed(String reason) {
    return 'Hindi makumpirma na ikaw ito, kaya walang nabura. $reason';
  }

  @override
  String get accountDeleteFailed =>
      'Hindi nabura ang account. Pakisubukan muli.';

  @override
  String get accountOtherDataTitle =>
      'May data mula sa ibang account ang device na ito';

  @override
  String get accountOtherDataBody =>
      'Galing sa ibang account ang mga bookmark, highlight at tala sa device na ito. Ano ang gagawin sa mga ito?';

  @override
  String get accountStartFresh => 'Magsimula muli sa device na ito';

  @override
  String get accountMerge => 'Isama sa account na ito';

  @override
  String get accountSignOutTitle => 'Mag-sign out?';

  @override
  String get accountSignOutBody =>
      'Ligtas sa iyong account ang mga bookmark, highlight at tala. Magtabi ng kopya sa device na ito?';

  @override
  String get accountRemoveFromDevice => 'Alisin sa device';

  @override
  String get accountKeepOnDevice => 'Itabi sa device';

  @override
  String get accountSyncing => 'Nagsi-sync…';

  @override
  String get accountSyncFailed => 'Hindi ma-sync';

  @override
  String get accountTapToRetry => 'Pindutin para subukan muli';

  @override
  String get accountSyncPaused => 'Naka-pause ang sync';

  @override
  String get accountSyncChoose => 'Piliin ang gagawin sa data ng device na ito';

  @override
  String get accountSyncNow => 'I-sync ngayon';

  @override
  String get accountNotSyncedYet => 'Hindi pa naka-sync';

  @override
  String get accountSyncedJustNow => 'Na-sync ngayon lang';

  @override
  String accountSyncedMinAgo(int minutes) {
    return 'Na-sync $minutes min ang nakalipas';
  }

  @override
  String accountSyncedHoursAgo(int hours) {
    return 'Na-sync $hours oras ang nakalipas';
  }

  @override
  String accountSyncedOn(int day, int month, int year) {
    return 'Na-sync noong $day/$month/$year';
  }

  @override
  String get accountRestoreTitle => 'Ibalik mula sa Backup';

  @override
  String get accountRestoreHint => 'I-paste dito ang backup JSON...';

  @override
  String get accountRestoreAction => 'Ibalik';

  @override
  String get accountResetTitle => 'I-reset ang app?';

  @override
  String get accountResetBody =>
      'Buburahin nito ang lahat ng data sa device:\n• Bookmark, highlight, tala at talaarawan\n• Mga plano sa pagbasa, progreso at sariling plano\n• Na-download na salin at streak\n\nHindi gagalawin ang setting, tema at offline na Biblia. Hindi na ito maibabalik — mag-back up muna kung kailangan.';

  @override
  String get accountResetDone => 'Na-reset ang data. Bagong simula!';

  @override
  String get accountReset => 'I-reset';

  @override
  String get shareBackdrop => 'Background';

  @override
  String get shareBackdropDawn => 'Bukang-liwayway';

  @override
  String get shareBackdropDusk => 'Takipsilim';

  @override
  String get shareBackdropArtwork => 'Likhang-sining';

  @override
  String get shareBackdropGradient => 'Gradient';

  @override
  String get shareFont => 'Font';

  @override
  String get shareFontTheme => 'Tema';

  @override
  String get shareSize => 'Laki';

  @override
  String get shareSpacing => 'Pagitan';

  @override
  String get shareSpacingNormal => 'Normal';

  @override
  String shareSpacingWide(String value) {
    return 'Malapad $value';
  }

  @override
  String get shareLineHeight => 'Taas ng linya';

  @override
  String get shareAlignment => 'Pagkakahanay';

  @override
  String get shareAlignCenter => 'Gitna';

  @override
  String get shareAlignLeft => 'Kaliwa';

  @override
  String get sharePreparing => 'Inihahanda…';

  @override
  String get shareImage => 'Ibahagi ang larawan';

  @override
  String get shareText => 'Ibahagi ang teksto';

  @override
  String get shareImageCard => 'Ibahagi ang image card';

  @override
  String get spaceStorageTitle => 'Storage';

  @override
  String get spaceClearCacheTitle => 'I-clear ang cache?';

  @override
  String get spaceClearCacheBody =>
      'Inaalis ang pansamantalang file (share card, thumbnail). Hindi gagalawin ang iyong tala, bookmark, highlight at download.';

  @override
  String get spaceClearCache => 'I-clear ang cache';

  @override
  String get spaceCacheCleared => 'Na-clear ang cache';

  @override
  String spaceDeletePackTitle(String name) {
    return 'Burahin ang $name?';
  }

  @override
  String spaceDeletePackBundled(String size) {
    return 'Magpapalaya ng $size. Maibabalik mo ito offline anumang oras.';
  }

  @override
  String spaceDeletePackDownloaded(String size) {
    return 'Magpapalaya ng $size. Mada-download mo ulit ito mamaya.';
  }

  @override
  String spacePackDeleted(String abbr) {
    return 'Nabura ang $abbr';
  }

  @override
  String spacePackDownloaded(String abbr) {
    return 'Na-download ang $abbr';
  }

  @override
  String spaceCouldNotFinish(String error) {
    return 'Hindi natapos: $error';
  }

  @override
  String spaceFreed(String message, String size) {
    return '$message · napalaya ang $size';
  }

  @override
  String get spaceOnThisDevice => 'Sa device na ito';

  @override
  String get spaceBibleContent => 'Nilalaman ng Biblia (laging itinatabi)';

  @override
  String get spaceDownloadedPacks => 'Na-download na pack';

  @override
  String get spaceCache => 'Cache';

  @override
  String get spaceCacheExplain =>
      'Pansamantalang file lang — share card at thumbnail. Ligtas i-clear anumang oras.';

  @override
  String get spaceTranslationsDownloads => 'Mga salin at download';

  @override
  String get spaceBundledSuffix => ' · kasama';

  @override
  String get spaceCoreNotRemovable =>
      'Bahagi ng app ang KJV at BBE at hindi maaalis.';

  @override
  String get spaceGet => 'Kunin';

  @override
  String spaceDeletePackTooltip(String name) {
    return 'Burahin ang $name';
  }

  @override
  String studyCouldNotOpenScreen(String error) {
    return 'Hindi mabuksan ang screen na iyon. $error';
  }

  @override
  String get studyCardSize => 'Laki ng card';

  @override
  String get studyPosition => 'Posisyon';

  @override
  String get studySizeLarge => 'Malaki';

  @override
  String get studySizeLargeHint => 'Buong lapad, kapareho ng lahat';

  @override
  String get studySizeExtraLarge => 'Napakalaki';

  @override
  String get studySizeExtraLargeHint => 'Buong lapad, mas maluwag na nilalaman';

  @override
  String get studySizeHalf => 'Kalahati';

  @override
  String get studySizeHalfHint => 'Siksik, dalawa bawat hanay';

  @override
  String get studyMoveUp => 'Iakyat';

  @override
  String get studyMoveUpHint => 'Ipagpalit sa card sa itaas';

  @override
  String get studyMoveDown => 'Ibaba';

  @override
  String get studyMoveDownHint => 'Ipagpalit sa card sa ibaba';

  @override
  String get studyCommentaryEyebrow => 'Komentaryo';

  @override
  String get studyCommentaryTitle => 'Pag-unawa bawat talata';

  @override
  String get studyCommentarySnippet =>
      'Historisistang komentaryo na may filter sa kabanata at talata.';

  @override
  String get studyCommentaryCta => 'Buksan ang komentaryo';

  @override
  String get studyDictionaryEyebrow => 'Diksiyunaryo';

  @override
  String get studyDictionaryTitle => 'Kahulugan ng mga salita';

  @override
  String get studyDictionarySnippet =>
      'Easton at Smith, offline, may naka-save na salita.';

  @override
  String get studyDictionaryCta => 'Hanapin';

  @override
  String get studyStoriesEyebrow => 'Mga kuwento sa Bibliya';

  @override
  String get studyStoriesTitle => 'Mga salaysay na muling isinalaysay';

  @override
  String get studyStoriesSnippet => '66 kuwento mula sa bawat aklat.';

  @override
  String get studyStoriesCta => 'Basahin ang mga kuwento';

  @override
  String get studyConcordanceEyebrow => 'Konkordansya';

  @override
  String get studyConcordanceTitle => 'Bawat paglitaw';

  @override
  String get studyConcordanceSnippet =>
      'Hanapin ang bawat talata kung saan lumilitaw ang salita.';

  @override
  String get studyConcordanceCta => 'Maghanap ng salita';

  @override
  String get studySpaceSaved => 'Naka-save';

  @override
  String get studySpaceMarked => 'Minarkahan';

  @override
  String get studySpaceNotes => 'Tala';

  @override
  String get studySpaceJournal => 'Journal';

  @override
  String get studySpaceTitle => 'Iyong Espasyo';

  @override
  String get studySpaceSubtitle => 'Bookmark, highlight, tala at journal';

  @override
  String get studyReadingPlan => 'Plano sa pagbasa';

  @override
  String get studyStartReadingPlan => 'Magsimula ng plano sa pagbasa';

  @override
  String get studyActivePlan => 'Aktibong plano';

  @override
  String studyDayOfTotal(int current, int total) {
    return 'Araw $current ng $total';
  }

  @override
  String studyDaysBehind(int count) {
    return '$count nahuhuli';
  }

  @override
  String get studyPlans => 'Mga plano';

  @override
  String get studyGuidedReading => 'Gabay na pagbasa';

  @override
  String get studyGuidedReadingSubtitle => 'Pinili, may takbo at pasadya';

  @override
  String get studyReadyToBegin => 'Handa nang magsimula';

  @override
  String studyTodayLabel(String label) {
    return 'Ngayon: $label';
  }

  @override
  String get studyReview => 'Balikan';

  @override
  String get studyRead => 'Basahin';

  @override
  String studyCtaArrow(String cta) {
    return '$cta →';
  }

  @override
  String get studyWordOfTheDay => 'Salita ng araw';

  @override
  String get studyArchiveLink => 'Archive →';

  @override
  String get studyLoading => 'Naglo-load…';

  @override
  String get studyUnavailableNow => 'Hindi available ngayon';

  @override
  String get studyReadingStreak => 'Sunod-sunod na pagbasa';

  @override
  String get studyStartStreak => 'Simulan ang iyong streak';

  @override
  String studyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw',
      one: '1 araw',
    );
    return '$_temp0';
  }

  @override
  String get studyStreakGrow => 'Buksan araw-araw para lumago ito.';

  @override
  String get studyStreakStart => 'Tapusin ang isang pagbasa araw-araw.';

  @override
  String get studyViewProgress => 'Tingnan ang progreso →';

  @override
  String get studyPassageNotFound => 'Hindi nakita ang talata';

  @override
  String get studyPassageLoadError => 'Hindi ma-load ang talata.';

  @override
  String get studyCompletedCheck => '✓ Natapos';

  @override
  String get studyMarkAsRead => 'Markahang nabasa';

  @override
  String get studyNextPassage => 'Susunod na talata';

  @override
  String get studyFullChapter => 'Buong kabanata';

  @override
  String studyPassageOfTotal(int current, int total) {
    return 'Talata $current ng $total';
  }

  @override
  String studySelectedCount(int count) {
    return '$count ang napili';
  }

  @override
  String get studyHighlight => 'I-highlight';

  @override
  String get studyBookmark => 'Bookmark';

  @override
  String get studyAddNote => 'Magdagdag ng tala';

  @override
  String studyChaptersWithContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kabanata na may nilalaman',
      one: '1 kabanata na may nilalaman',
    );
    return '$_temp0';
  }

  @override
  String get studyCommentaryLibrary => 'Aklatan ng komentaryo';

  @override
  String get studyCommentaryLoadError => 'Hindi ma-load ang komentaryo.';

  @override
  String get studyNoCommentaryYet => 'Wala pang komentaryo.';

  @override
  String studyNoBooksMatch(String query) {
    return 'Walang aklat na tugma sa \"$query\".';
  }

  @override
  String studySearchBooksCount(int count) {
    return 'Maghanap sa $count aklat…';
  }

  @override
  String get studyClassicSources => 'Mga klasikong sanggunian';

  @override
  String studyBookAuthorChapters(String author, int count) {
    return '$author · $count kab.';
  }

  @override
  String studyReadingRef(String reference) {
    return 'Binabasa · $reference';
  }

  @override
  String get studyAllSources => 'Lahat ng sanggunian';

  @override
  String get studyVerseLevel => 'Bawat talata';

  @override
  String studySearchWithin(String reference) {
    return 'Maghanap sa $reference…';
  }

  @override
  String studyEntriesLoadError(String error) {
    return 'Hindi ma-load ang mga entry.\n$error';
  }

  @override
  String get studyNoEntriesMatch =>
      'Walang entry na tugma sa mga filter.\nSubukan ang Lahat ng sanggunian, o tingnan ang aklatan.';

  @override
  String studyVerseN(int verse) {
    return 'Talata $verse';
  }

  @override
  String get studyChapter => 'Kabanata';

  @override
  String get studyCategoryCommentary => 'Komentaryo';

  @override
  String get studyCategoryDevotional => 'Debosyonal';

  @override
  String get studyCategoryStudyNote => 'Tala sa pag-aaral';

  @override
  String studyCommentaryLoadErrorDetail(String error) {
    return 'Hindi ma-load ang komentaryo.\n$error';
  }

  @override
  String get studyNoContentForFilters =>
      'Walang nilalaman para sa mga filter na ito.';

  @override
  String studyVerseLabel(String verse) {
    return 'Talata $verse';
  }

  @override
  String get studyChapterView => 'Buong kabanata';

  @override
  String get studyFilterAll => 'Lahat';

  @override
  String get studyFilterDevotionals => 'Mga debosyonal';

  @override
  String get studyFilterAllContexts => 'Lahat ng konteksto';

  @override
  String get studyFilterChapterLevel => 'Bawat kabanata';

  @override
  String get studyFilterVerseLevel => 'Bawat talata';

  @override
  String get studyRemoveBookmark => 'Alisin ang bookmark';

  @override
  String get studyBookmarkCommentary => 'I-bookmark ang komentaryo';

  @override
  String get studyExpandFullScreen => 'I-full screen';

  @override
  String get studyTapToReadInContext => 'I-tap para basahin sa konteksto';

  @override
  String get studyOnThisChapter => 'Tungkol sa kabanatang ito';

  @override
  String get studyOnThisBook => 'Tungkol sa aklat na ito';

  @override
  String get studyNoCommentaryTitle => 'Wala pang komentaryo';

  @override
  String get studyNoCommentaryBody =>
      'Walang tiyak na komentaryo para sa talatang ito. Subukan ang komentaryo sa kabanata o aklat sa ibaba.';

  @override
  String get storiesTitle => 'Mga Kuwento sa Bibliya';

  @override
  String get storiesFilters => 'Mga filter';

  @override
  String get storiesSubtitle =>
      '500 larawang sandali mula Genesis hanggang Pahayag';

  @override
  String get storiesSearchHint => 'Pamagat, aklat, o sanggunian…';

  @override
  String get storiesClearSearch => 'I-clear ang paghahanap';

  @override
  String get storiesFilterAll => 'Lahat';

  @override
  String get storiesFilterOt => 'LT';

  @override
  String get storiesFilterNt => 'BT';

  @override
  String storiesCountOfTotal(int count, int total) {
    return '$count sa $total kuwento';
  }

  @override
  String get storiesFavorites => 'Mga paborito';

  @override
  String get storiesUnread => 'Hindi pa nabasa';

  @override
  String storiesLoadError(String error) {
    return 'Hindi ma-load ang mga kuwento:\n$error';
  }

  @override
  String get storiesBooks => 'Mga aklat';

  @override
  String get storiesSearchBooks => 'Maghanap ng aklat…';

  @override
  String get storiesAllBooks => 'Lahat ng aklat';

  @override
  String get storiesNoMatch => 'Walang kuwentong tugma sa mga filter.';

  @override
  String get storiesNoFavorites => 'Wala pang paborito.';

  @override
  String get storiesBrowseAll => 'Tingnan ang lahat ng kuwento';

  @override
  String get storiesAllCaughtUp => 'Nabasa mo na lahat.';

  @override
  String get storiesShowRead => 'Ipakita ang mga nabasa na';

  @override
  String get storiesClearFilters => 'I-clear ang mga filter';

  @override
  String get storiesFavoritesHint =>
      'I-tap ang ♥ sa kuwento para i-save ito rito.';

  @override
  String get storiesAttribution =>
      'Kasulatan mula sa King James Version (pampublikong domain). Mga buod na hinango mula sa The Graham Bible (grahambible.com), tinulungan ng AI at sinuri ng tao. Likhang-sining: Gustave Doré (1832–1883), pampublikong domain, sa pamamagitan ng Wikimedia Commons.';

  @override
  String get storiesReachedEnd => 'Narating mo na ang dulo.';

  @override
  String get storiesFirstStory => 'Ito ang unang kuwento.';

  @override
  String get storiesFavorite => 'Paborito';

  @override
  String get storiesMarkAsRead => 'Markahang nabasa';

  @override
  String storiesKeyVerse(String reference) {
    return 'SUSING TALATA · $reference';
  }

  @override
  String get storiesTheStory => 'ANG KUWENTO';

  @override
  String storiesArtworkCaption(String caption) {
    return 'Likhang-sining: $caption — Gustave Doré, pampublikong domain';
  }

  @override
  String get storiesPrevious => 'Nakaraang kuwento';

  @override
  String get storiesNext => 'Susunod na kuwento';

  @override
  String get studyDictionarySearchHint => 'Maghanap sa 3,400+ salita…';

  @override
  String get studyDictionarySavedFilter => '★ Naka-save';

  @override
  String studyDictionaryUnavailable(String error) {
    return 'Hindi available ang diksiyunaryo.\n$error';
  }

  @override
  String get studyNoHeadwords => 'Walang nahanap na salita.';

  @override
  String get studyDictionaryNoMatches =>
      'Walang tugma. Subukan ang “grace”, “atonement” o “wilderness” (diksiyunaryong Ingles).';

  @override
  String studyResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resulta',
      one: '1 resulta',
    );
    return '$_temp0';
  }

  @override
  String get studyUntitledEntry => '(entry na walang pamagat)';

  @override
  String get studyRemoveSavedWord => 'Alisin ang naka-save na salita';

  @override
  String get studySaveWord => 'I-save ang salita';

  @override
  String get studyNoDefinition => 'Walang nahanap na kahulugan.';

  @override
  String studyFailedToLoad(String error) {
    return 'Hindi na-load: $error';
  }

  @override
  String studyStrongsShareText(String id, String lemma, String transliteration,
      String pronunciation, String definition) {
    return '$id - $lemma\n\nTransliterasyon: $transliteration\nBigkas: $pronunciation\n\nKahulugan:\n$definition';
  }

  @override
  String studyNoStrongsEntry(String id) {
    return 'Walang entry para sa $id.';
  }

  @override
  String get studyStrongsLexicon => 'LEKSIKON NI STRONG';

  @override
  String get studyConcordanceHint => 'Salitang Ingles (hal. grace, covenant)…';

  @override
  String get studyConcordanceIntro =>
      'Mga paglitaw sa KJV — i-tap ang talata para basahin sa konteksto.';

  @override
  String get studyConcordanceEmpty =>
      'Bawat talatang may iyong salita, ayon sa kanonikong ayos.';

  @override
  String get studyConcordanceSingleWord => 'Maglagay ng isang salitang Ingles.';

  @override
  String studyConcordanceNoVerses(String word) {
    return 'Walang talatang may \"$word\".';
  }

  @override
  String studyConcordanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count talata',
      one: '1 talata',
    );
    return '$_temp0';
  }

  @override
  String studyConcordanceCountTruncated(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count talata',
      one: '1 talata',
    );
    return '$_temp0 (unang $limit ang ipinapakita)';
  }

  @override
  String get creditsTitle => 'Mga kredito at sanggunian';

  @override
  String get creditsLicenses => 'Mga open-source na lisensya';

  @override
  String get creditsLicensesSubtitle => 'Mga font at software package';

  @override
  String studyPreparingOfflineBible(int percent) {
    return 'Inihahanda ang offline na Bibliya… $percent%';
  }

  @override
  String get errorTitle => 'May nangyaring mali';

  @override
  String get errorBody =>
      'May hindi inaasahang problema. I-tap sa ibaba para bumalik sa home screen.';

  @override
  String get errorBackHome => 'Bumalik sa Home';

  @override
  String studyWeekN(int week) {
    return 'Linggo $week';
  }

  @override
  String get privacyTitle => 'Patakaran sa Privacy';

  @override
  String get privacyLoadError => 'Hindi ma-load ang patakaran sa privacy.';

  @override
  String privacyEffectiveDate(String date) {
    return 'Petsa ng bisa: $date';
  }

  @override
  String get privacyEnglishOnly => 'Ang patakarang ito ay nasa Ingles.';

  @override
  String get privacyViewOnline => 'Tingnan online';
}
