// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'The Blessed Bible';

  @override
  String get commonCancel => 'Anulează';

  @override
  String get commonContinue => 'Continuă';

  @override
  String get commonSkip => 'Omite';

  @override
  String get commonBack => 'Înapoi';

  @override
  String get commonDone => 'Gata';

  @override
  String get commonSave => 'Salvează';

  @override
  String get commonDelete => 'Șterge';

  @override
  String get commonClose => 'Închide';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Încearcă din nou';

  @override
  String get commonShare => 'Distribuie';

  @override
  String get commonCopy => 'Copiază';

  @override
  String get commonEdit => 'Editează';

  @override
  String get commonSearch => 'Caută';

  @override
  String get languageTitle => 'Limbă';

  @override
  String get languageSystem => 'La fel ca dispozitivul';

  @override
  String get languageSubtitle =>
      'Limba meniurilor și a butoanelor. Traducerea Bibliei se alege separat.';

  @override
  String get onboardingTagline => 'Scriptura, fără distrageri.';

  @override
  String get onboardingPickLanguage => 'Alege limba';

  @override
  String get onboardingLanguageHint => 'O poți schimba oricând din Setări.';

  @override
  String get onboardingBibleTitle => 'Biblia ta';

  @override
  String get onboardingBibleBody =>
      'Alege traducerea pe care o citești cel mai des. Poți afișa și una a doua alături.';

  @override
  String onboardingParallel(String name) {
    return 'Afișează și $name alături';
  }

  @override
  String get onboardingLookTitle => 'Citește confortabil';

  @override
  String get onboardingLookBody =>
      'Alege culoarea paginii și mărimea textului. Totul se poate ajusta ulterior.';

  @override
  String get onboardingThemeLight => 'Luminos';

  @override
  String get onboardingThemeSepia => 'Sepia';

  @override
  String get onboardingThemeDark => 'Întunecat';

  @override
  String get onboardingTextSize => 'Mărimea textului';

  @override
  String get onboardingPreviewVerse =>
      'La început era Cuvântul, și Cuvântul era cu Dumnezeu, și Cuvântul era Dumnezeu.';

  @override
  String get onboardingPreviewRef => 'Ioan 1:1';

  @override
  String get onboardingFeaturesTitle => 'Tot ce-ți trebuie zi de zi';

  @override
  String get onboardingFeatureWordTitle => 'Cuvântul, simplu';

  @override
  String get onboardingFeatureWordBody =>
      'Citește fără distrageri, cu evidențieri, notițe și semne de carte.';

  @override
  String get onboardingFeaturePlansTitle => 'Planuri de citire';

  @override
  String get onboardingFeaturePlansBody =>
      'Cronologice, tematice sau proprii — cu mementouri discrete.';

  @override
  String get onboardingFeatureStudyTitle => 'Studiu aprofundat';

  @override
  String get onboardingFeatureStudyBody =>
      'Comentarii, dicționar, Strong și hărți, chiar lângă text.';

  @override
  String get onboardingFeatureSyncTitle => 'În siguranță';

  @override
  String get onboardingFeatureSyncBody =>
      'Conectează-te oricând pentru a sincroniza dispozitivele. Pentru citit nu ai nevoie de cont.';

  @override
  String get onboardingBegin => 'Începe să citești';

  @override
  String onboardingStep(int current, int total) {
    return 'Pasul $current din $total';
  }

  @override
  String get plansContinueReading => 'Continuă lectura';

  @override
  String get plansResume => 'Reia';

  @override
  String plansDayCompleteCelebration(int day) {
    return 'Plan de citire\nZiua $day încheiată!';
  }

  @override
  String get plansChangeWeek => 'Schimbă săptămâna';

  @override
  String plansCalendarDayComplete(String label) {
    return '$label, citire încheiată';
  }

  @override
  String plansCalendarDayToday(String label) {
    return '$label, astăzi';
  }

  @override
  String get plansDailyVerses => 'Versete zilnice';

  @override
  String get plansToday => 'Astăzi';

  @override
  String get plansYesterday => 'Ieri';

  @override
  String plansDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Acum $count de zile',
      few: 'Acum $count zile',
      one: 'Acum 1 zi',
    );
    return '$_temp0';
  }

  @override
  String get plansHello => 'Bună,';

  @override
  String plansOpenStory(String caption) {
    return 'Deschide povestea: $caption';
  }

  @override
  String get plansBibleStory => 'Poveste biblică';

  @override
  String plansSlotsFull(int count) {
    return 'Toate cele $count locuri pentru planuri sunt ocupate. Pune un plan pe pauză ca să eliberezi un loc — progresul se păstrează.';
  }

  @override
  String get plansPausedSnack =>
      'Plan pus pe pauză — tot progresul se păstrează.';

  @override
  String get plansBrowseToStart =>
      'Răsfoiește Lectură pentru a începe primul tău plan.';

  @override
  String get plansFriend => 'prietene';

  @override
  String get plansTitle => 'Planuri';

  @override
  String get plansTabReading => 'Lectură';

  @override
  String get plansTabBooks => 'Cărți';

  @override
  String plansTabMyPlans(int count) {
    return 'Planurile mele ($count)';
  }

  @override
  String get plansNotStarted => 'Neînceput';

  @override
  String plansPercentDone(int percent) {
    return '$percent% realizat';
  }

  @override
  String get plansOpen => 'Deschide';

  @override
  String get plansPaused => 'Pe pauză';

  @override
  String get plansStarted => 'Început';

  @override
  String plansDaysBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de zile în urmă',
      few: '$count zile în urmă',
      one: '1 zi în urmă',
    );
    return '$_temp0';
  }

  @override
  String get plansCaughtUp => 'La zi';

  @override
  String get plansComplete => 'Încheiat';

  @override
  String plansDayOfTotalLeft(int current, int total, int left) {
    return 'Ziua $current din $total · mai sunt $left';
  }

  @override
  String get plansPauseKeepsProgress => 'Pauză (păstrează progresul)';

  @override
  String get plansStart => 'Începe';

  @override
  String plansPresetBookTitle(String book, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$book în $days de zile',
      few: '$book în $days zile',
      one: '$book în 1 zi',
    );
    return '$_temp0';
  }

  @override
  String plansPresetGospelsTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Evangheliile în $days de zile',
      few: 'Evangheliile în $days zile',
      one: 'Evangheliile în 1 zi',
    );
    return '$_temp0';
  }

  @override
  String plansPresetSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days de zile · atinge pentru a crea',
      few: '$days zile · atinge pentru a crea',
      one: '1 zi · atinge pentru a crea',
    );
    return '$_temp0';
  }

  @override
  String get plansYourCustomPlans => 'PLANURILE TALE PERSONALIZATE';

  @override
  String plansDayOfTotal(int day, int total) {
    return 'Ziua $day din $total';
  }

  @override
  String get plansCustomPlan => 'Plan personalizat';

  @override
  String get plansNoActivePlans => 'Niciun plan activ';

  @override
  String get plansNoActivePlansBody =>
      'Răsfoiește Lectură sau Cărți pentru a începe primul tău plan.';

  @override
  String get plansLetsRead => 'Să citim';

  @override
  String get plansVerseOfTheDay => 'Versetul zilei';

  @override
  String get plansOpenTodaysReading => 'Deschide lectura de azi';

  @override
  String get plansLastDayOfYear => 'Ultima zi a anului';

  @override
  String plansDaysLeftInYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Au mai rămas $count de zile din an',
      few: 'Au mai rămas $count zile din an',
      one: 'A mai rămas 1 zi din an',
    );
    return '$_temp0';
  }

  @override
  String get plansCustomPlanDefaultTitle => 'Plan personalizat';

  @override
  String get plansCustom => 'Personalizat';

  @override
  String plansBookRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String plansCouldNotSave(String error) {
    return 'Planul nu a putut fi salvat: $error';
  }

  @override
  String get plansBuilderTitle => 'Creează un plan';

  @override
  String plansError(String error) {
    return 'Eroare: $error';
  }

  @override
  String get plansPlanName => 'Numele planului';

  @override
  String get plansPlanNameHint => 'ex. Geneza în 30 de zile';

  @override
  String get plansReadingTracks => 'Trasee de citire';

  @override
  String get plansAddTrack => 'Adaugă traseu';

  @override
  String get plansTracksOverlap =>
      'Traseele se suprapun — versetele comune sunt numărate o singură dată în previzualizarea de mai jos.';

  @override
  String get plansDuration => 'Durată';

  @override
  String plansDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de zile',
      few: '$count zile',
      one: '1 zi',
    );
    return '$_temp0';
  }

  @override
  String get plansDaysSuffix => 'zile';

  @override
  String get plansStartRestReminder => 'Început, odihnă și memento';

  @override
  String get plansStartDate => 'Data de început';

  @override
  String get plansRestDaysNeutral => 'Zile de odihnă (neutre)';

  @override
  String get plansNone => 'Niciuna';

  @override
  String get plansDailyReminder => 'Memento zilnic';

  @override
  String plansReminderAt(String time) {
    return 'La $time';
  }

  @override
  String get plansOff => 'Dezactivat';

  @override
  String get plansLivePreview => 'Previzualizare';

  @override
  String get plansPreviewEmpty =>
      'Adaugă cel puțin un traseu mai sus pentru a vedea programul echilibrat.';

  @override
  String get plansWordBalanced => 'Echilibrat pe cuvinte · respectă pericopele';

  @override
  String plansPreviewSummary(int days, int readingDays) {
    return '$days zile · $readingDays zile de citire';
  }

  @override
  String plansClampedNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Cel mai lejer ritm pentru această selecție este de $days de zile. Titlul a fost actualizat cu durata reală.',
      few:
          'Cel mai lejer ritm pentru această selecție este de $days zile. Titlul a fost actualizat cu durata reală.',
      one:
          'Cel mai lejer ritm pentru această selecție este de 1 zi. Titlul a fost actualizat cu durata reală.',
    );
    return '$_temp0';
  }

  @override
  String plansPreviewDay(int day, String portions) {
    return 'Ziua $day: $portions';
  }

  @override
  String plansMoreBalancedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Încă $count de zile echilibrate',
      few: 'Încă $count zile echilibrate',
      one: 'Încă 1 zi echilibrată',
    );
    return '$_temp0';
  }

  @override
  String get plansSaving => 'Se salvează…';

  @override
  String get plansGenerateAndSave => 'Creează și salvează →';

  @override
  String get plansNameAndTrackHint =>
      'Denumește planul și adaugă cel puțin un traseu pentru a continua.';

  @override
  String get plansStartEllipsis => 'Început…';

  @override
  String get plansEndEllipsis => 'Sfârșit…';

  @override
  String get plansStartLabel => 'ÎNCEPUT';

  @override
  String get plansEndLabel => 'SFÂRȘIT';

  @override
  String get plansRemoveTrack => 'Elimină traseul';

  @override
  String plansRestChip(String days) {
    return 'Odihnă $days';
  }

  @override
  String plansRebasedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Program decalat cu $count de zile de citire. Zilele încheiate rămân neschimbate.',
      few:
          'Program decalat cu $count zile de citire. Zilele încheiate rămân neschimbate.',
      one:
          'Program decalat cu 1 zi de citire. Zilele încheiate rămân neschimbate.',
    );
    return '$_temp0';
  }

  @override
  String get plansPlan => 'Plan';

  @override
  String get plansNoReadingsYet => 'Acest plan nu are încă lecturi.';

  @override
  String plansReadingDaysWeeks(int days, int weeks) {
    return '$days zile de citire · ~$weeks săptămâni';
  }

  @override
  String get plansBeginPlan => 'Începe planul';

  @override
  String get plansStartDayOne => 'Începe ziua 1 →';

  @override
  String get plansStartDateNote => 'Planul începe la data aleasă de tine.';

  @override
  String get plansScheduleLabel => 'PROGRAM';

  @override
  String get plansNoReadings => 'Nicio lectură';

  @override
  String plansPercentComplete(int percent) {
    return '$percent% încheiat';
  }

  @override
  String get plansFlexible => 'Flexibil';

  @override
  String get plansScheduled => 'Programat';

  @override
  String plansBehindChip(int count) {
    return '$count în urmă';
  }

  @override
  String get plansOnTrack => 'La zi';

  @override
  String get plansFlexibleHelp =>
      'Flexibil: citește mai întâi cea mai veche zi necitită. Zilele ratate nu se adună.';

  @override
  String get plansScheduledHelp =>
      'Programat: fiecare dată are ziua ei de citire. Zilele ratate se adună ca întârziere — recuperează mai jos.';

  @override
  String get plansCatchUp => 'Recuperează';

  @override
  String plansBehindBy(int count, int day) {
    return 'În urmă cu $count — cea mai veche necitită este ziua $day.';
  }

  @override
  String get plansCatchUpHelp =>
      'Marcarea zilelor ca citite înregistrează progresul. Decalarea mută în schimb restul programului mai încolo.';

  @override
  String get plansGoToOldest => 'Mergi la cea mai veche';

  @override
  String get plansMarkOldestDone => 'Marchează cea mai veche';

  @override
  String get plansAllPreviousDone => 'Tot ce e înainte de azi este deja făcut.';

  @override
  String plansPreviousMarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de zile anterioare marcate ca citite.',
      few: '$count zile anterioare marcate ca citite.',
      one: '1 zi anterioară marcată ca citită.',
    );
    return '$_temp0';
  }

  @override
  String get plansMarkAllPrevious => 'Marchează toate anterioarele';

  @override
  String plansRebaseDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Decalează +$count de zile',
      few: 'Decalează +$count zile',
      one: 'Decalează +1 zi',
    );
    return '$_temp0';
  }

  @override
  String plansReadingsHeader(int count) {
    return 'LECTURI · $count ZILE';
  }

  @override
  String get plansJourneyMap => 'Harta călătoriei';

  @override
  String get plansJumpToToday => 'Salt la azi';

  @override
  String plansDayN(int day) {
    return 'Ziua $day';
  }

  @override
  String get plansLegendDone => 'Citit';

  @override
  String get plansLegendToday => 'Azi = cerc';

  @override
  String get plansLegendMissed => 'Ratat';

  @override
  String plansReminderAtTime(String time) {
    return 'Memento · $time';
  }

  @override
  String get plansReminderOff => 'Memento dezactivat';

  @override
  String get plansReminderHelp =>
      'Notificare pentru acest plan — sare automat peste zilele de odihnă.';

  @override
  String get plansRestDays => 'Zile de odihnă';

  @override
  String get plansNoRestDays => 'Fără zile de odihnă';

  @override
  String get plansSettings => 'Setările planului';

  @override
  String get plansAboutEllipsis => 'Despre acest plan…';

  @override
  String get plansAbout => 'Despre acest plan';

  @override
  String get plansChangeStartDate => 'Schimbă data de început…';

  @override
  String plansRestDaysValue(String days) {
    return 'Zile de odihnă: $days';
  }

  @override
  String get plansRestDaysHelp => 'Atinge pentru a alege zilele';

  @override
  String get plansRestartFromDayOne => 'Reîncepe de la ziua 1…';

  @override
  String get plansRestartTitle => 'Reîncepi planul?';

  @override
  String get plansRestartBody => 'Zilele încheiate vor fi șterse.';

  @override
  String get plansRestart => 'Reîncepe';

  @override
  String get plansMarkUnread => 'Marchează necitit';

  @override
  String get plansMarkRead => 'Marchează citit';

  @override
  String get plansRestAndReflect => 'Odihnă și meditație';

  @override
  String get plansRestDayBody => 'O zi de odihnă — nicio lectură pentru azi.';

  @override
  String get plansDayDetailHelp =>
      'Atinge un pasaj pentru a-l deschide. Bifează-l pe măsură ce citești.';

  @override
  String plansMilestone(int count) {
    return '$count lecturi încheiate — continuă tot așa!';
  }

  @override
  String get plansCompletedTapToUndo => 'Încheiat — atinge pentru a anula';

  @override
  String plansMarkDayRead(int day, int checked, int total) {
    return 'Marchează ziua $day ca citită ✓ ($checked/$total pasaje)';
  }

  @override
  String get todayGoodMorning => 'Bună dimineața';

  @override
  String get todayGoodAfternoon => 'Bună ziua';

  @override
  String get todayGoodEvening => 'Bună seara';

  @override
  String get todayGoodNight => 'Noapte bună';

  @override
  String get todayStreakNudge => 'Citește azi ca să-ți păstrezi seria!';

  @override
  String get todayNotificationsSoon => 'Notificările vin în curând!';

  @override
  String get todaySectionResume => 'CONTINUĂ';

  @override
  String get todaySectionStreak => 'SERIA DE CITIRE';

  @override
  String get todaySectionLatestNote => 'ULTIMA NOTIȚĂ';

  @override
  String get todaySectionQuickActions => 'ACȚIUNI RAPIDE';

  @override
  String get todaySectionReminders => 'MEMENTOURI ZILNICE';

  @override
  String get todayTagline => 'Momentul tău zilnic de pace.';

  @override
  String get todayNoNotesYet => 'Încă nu ai notițe';

  @override
  String get todayWriteFirstNote => 'Scrie prima ta notiță ca s-o vezi aici.';

  @override
  String get todayViewAllNotes => 'Vezi toate notițele';

  @override
  String todayStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie de $count de zile',
      few: 'Serie de $count zile',
      one: 'Serie de 1 zi',
    );
    return '$_temp0';
  }

  @override
  String todayDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Au mai rămas $count de zile din an.',
      few: 'Au mai rămas $count zile din an.',
      one: 'A mai rămas 1 zi din an.',
    );
    return '$_temp0';
  }

  @override
  String get todayActionRead => 'Citește';

  @override
  String get todayActionSurprise => 'Surprinde-mă';

  @override
  String get todayActionReadingPlan => 'Plan de citire';

  @override
  String get todayActionYourSpace => 'Spațiul tău';

  @override
  String get todayVotdArchive => 'Arhiva versetului zilei';

  @override
  String get todayVotdArchiveBody => 'Recuperează versetele din zilele ratate.';

  @override
  String get todayVotdArchiveExplore => 'Explorează versetele zilelor trecute';

  @override
  String get readActionBookmark => 'Semn de carte';

  @override
  String get readActionNote => 'Notiță';

  @override
  String get readActionNotes => 'Notițe';

  @override
  String get readActionEditNote => 'Editează notița';

  @override
  String get readActionCommentary => 'Comentariu';

  @override
  String get readActionRelated => 'Corelate';

  @override
  String get readActionHighlight => 'Evidențiază';

  @override
  String get readActionStudy => 'Studiază';

  @override
  String get readActionSaved => 'Salvat';

  @override
  String get readActionSelectText => 'Selectează text';

  @override
  String get readVerseActions => 'Acțiuni verset';

  @override
  String readVersesSelected(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versete selectate',
      one: '1 verset selectat',
    );
    return '$_temp0 · $where';
  }

  @override
  String get readCommentaryHint =>
      'Atinge becul de lângă un verset pentru comentariu';

  @override
  String get readPassageNotFound => 'Pasaj negăsit.';

  @override
  String get readChapterCommentary => 'Citește comentariul capitolului';

  @override
  String get readPreviousChapter => '‹ Anterior';

  @override
  String get readNextChapter => 'Următorul ›';

  @override
  String readPlanDay(int day) {
    return 'Plan de citire · Ziua $day';
  }

  @override
  String get readPlanCompleted => 'Plan finalizat! Felicitări! 🎉';

  @override
  String readMarkDoneContinue(String book, int chapter) {
    return 'Marchează $book $chapter citit și continuă';
  }

  @override
  String get readNone => 'Niciuna';

  @override
  String readBookFallback(int number) {
    return 'Cartea $number';
  }

  @override
  String get readRelatedVerses => 'Versete corelate';

  @override
  String get readNoCrossRefs => 'Nicio trimitere pentru acest verset.';

  @override
  String get readCrossRefsComingSoon =>
      'Trimiterile vor fi disponibile\ndupă următoarea actualizare.';

  @override
  String readCrossRefsLoadError(String error) {
    return 'Trimiterile nu au putut fi încărcate.\n$error';
  }

  @override
  String get readVerseUnavailable => 'Verset indisponibil';

  @override
  String get readLoading => 'Se încarcă…';

  @override
  String get readVerseNotFound => 'Verset negăsit.';

  @override
  String get readBookOrChapterNotFound => 'Carte sau capitol negăsit.';

  @override
  String get readOpenInRead => 'Deschide în Citește';

  @override
  String get readBookNotFound => 'Cartea indicată nu a fost găsită.';

  @override
  String readVerseLoadError(String error) {
    return 'Eroare la încărcarea versetului: $error';
  }

  @override
  String get readTestament => 'Testament';

  @override
  String get readBook => 'Carte';

  @override
  String get readChapter => 'Capitol';

  @override
  String get readVerse => 'Verset';

  @override
  String get readSelectBook => 'Alege cartea';

  @override
  String get readOtShort => 'VT';

  @override
  String get readNtShort => 'NT';

  @override
  String get readOldTestament => 'Vechiul Testament';

  @override
  String get readNewTestament => 'Noul Testament';

  @override
  String get readOldTestamentTwoLine => 'Vechiul\nTestament';

  @override
  String get readNewTestamentTwoLine => 'Noul\nTestament';

  @override
  String get readStoriesSections => 'Relatări și secțiuni';

  @override
  String get readAllVerses => 'Toate versetele';

  @override
  String get readTranslationTitle => 'Traducerea Bibliei';

  @override
  String get readLayoutTitle => 'Aspect lectură';

  @override
  String get readLayoutSingle => 'Simplu';

  @override
  String get readLayoutBilingual => 'Bilingv';

  @override
  String get readLayoutParallel => 'Paralel';

  @override
  String get readLayoutChips => 'Butoane';

  @override
  String get readLayoutSingleDesc => 'O singură traducere';

  @override
  String get readLayoutBilingualDesc => 'Două traduceri suprapuse pe verset';

  @override
  String get readLayoutParallelDesc => 'Două traduceri în coloane alăturate';

  @override
  String get readLayoutChipsDesc =>
      'Atinge un verset pentru a schimba traducerea';

  @override
  String get readPrimary => 'Principală';

  @override
  String get readSecondary => 'Secundară';

  @override
  String readTranslationsLoadError(String error) {
    return 'Eroare la încărcarea traducerilor: $error';
  }

  @override
  String readTranslationDeleted(String name) {
    return '$name a fost ștearsă.';
  }

  @override
  String readDeleteFailed(String error) {
    return 'Nu s-a putut șterge: $error';
  }

  @override
  String readDeleteTranslation(String name) {
    return 'Șterge $name';
  }

  @override
  String get readKjvAlwaysAvailable => 'Mereu disponibilă · baza aplicației';

  @override
  String get readCannotDeleteBackbone => 'Nu se poate șterge — baza aplicației';

  @override
  String get readAvailableToAdd => 'DISPONIBILE PENTRU ADĂUGARE';

  @override
  String get readNoInternet =>
      'Fără conexiune la internet — încearcă din nou când ești online.';

  @override
  String get readRestoreFailed => 'Restaurare eșuată';

  @override
  String get readDownloadFailed => 'Descărcare eșuată';

  @override
  String readRestoreFailedDetail(String error) {
    return 'Restaurare eșuată ($error).';
  }

  @override
  String readDownloadFailedDetail(String error) {
    return 'Descărcare eșuată ($error).';
  }

  @override
  String get readRestoreOffline => 'restaurare offline';

  @override
  String get homeVerseOfTheDay => 'VERSETUL ZILEI';

  @override
  String get homeDevotional => 'DEVOȚIONAL';

  @override
  String get homeCommentary => 'COMENTARIU';

  @override
  String get homeGoDeeper => 'Aprofundează';

  @override
  String get homeReadFullDefinition => 'Citește definiția';

  @override
  String get homeWordOfTheDayHeading => 'CUVÂNTUL ZILEI';

  @override
  String get homeWordOfTheDay => 'Cuvântul zilei';

  @override
  String get homeWotdEmpty =>
      'Niciun cuvânt ales pentru azi — încearcă mai târziu.';

  @override
  String homeWotdUnavailable(String error) {
    return 'Cuvântul zilei indisponibil ($error).';
  }

  @override
  String get navHome => 'Acasă';

  @override
  String get navRead => 'Citește';

  @override
  String get navStudy => 'Studiu';

  @override
  String get navSearch => 'Caută';

  @override
  String get navExitTitle => 'Ieși din The Blessed Bible?';

  @override
  String get navExitMessage => 'Sigur vrei să ieși din aplicație?';

  @override
  String get navExit => 'Ieși';

  @override
  String get navCastLotsError =>
      'Nu s-a putut trage la sorți — încearcă din nou.';

  @override
  String get navCastingLots => 'Se trage la sorți…';

  @override
  String get searchHint => 'Caută versete, comentarii…';

  @override
  String get searchAllBooks => 'Toate cărțile';

  @override
  String get searchFilterMyNotes => 'Notițele mele';

  @override
  String get searchEmptyPrompt =>
      'Caută în Biblie, comentarii\nși notițele tale';

  @override
  String get searchRecentSearches => 'CĂUTĂRI RECENTE';

  @override
  String get searchClear => 'ȘTERGE';

  @override
  String get searchRecentPlaces => 'LOCURI RECENTE';

  @override
  String get searchMostRead => 'CELE MAI CITITE';

  @override
  String get searchNoResults => 'Niciun rezultat';

  @override
  String get searchTopResults => 'Se afișează primele 100 de rezultate';

  @override
  String searchResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de rezultate găsite',
      few: '$count rezultate găsite',
      one: '1 rezultat găsit',
    );
    return '$_temp0';
  }

  @override
  String searchSectionDictionary(int count) {
    return 'DICȚIONAR ($count)';
  }

  @override
  String searchSectionStories(int count) {
    return 'RELATĂRI ($count)';
  }

  @override
  String searchSectionJumpTo(int count) {
    return 'SALT LA ($count)';
  }

  @override
  String searchSectionVerses(int count) {
    return 'VERSETE ($count)';
  }

  @override
  String searchSectionCommentary(int count) {
    return 'COMENTARII ($count)';
  }

  @override
  String searchSectionMyNotes(int count) {
    return 'NOTIȚELE MELE ($count)';
  }

  @override
  String get searchCopied => 'Copiat în clipboard';

  @override
  String get settingsTitle => 'Setări';

  @override
  String get settingsTabGeneral => 'General';

  @override
  String get settingsTabNavigation => 'Navigare';

  @override
  String get settingsTabReminders => 'Mementouri';

  @override
  String get settingsTabInfo => 'Info';

  @override
  String get settingsWidgetsTitle => 'Widgeturi pe ecranul principal';

  @override
  String get settingsWidgetsSubtitle =>
      'Degradeuri, transparență și previzualizare live';

  @override
  String get settingsStartPageTitle => 'Pagina de pornire';

  @override
  String get settingsStartPageSubtitle => 'Alege pagina afișată la pornire';

  @override
  String get settingsPageHome => 'Acasă';

  @override
  String get settingsPageRead => 'Citește';

  @override
  String get settingsPageStudy => 'Studiu';

  @override
  String get settingsPageSearch => 'Căutare';

  @override
  String get settingsImmersiveReading => 'Lectură imersivă';

  @override
  String get settingsImmersiveOffTitle => 'Ancorat (oprit)';

  @override
  String get settingsImmersiveOffSubtitle => 'Navigarea rămâne mereu vizibilă';

  @override
  String get settingsImmersivePartialTitle => 'Ghidat (parțial)';

  @override
  String get settingsImmersivePartialSubtitle =>
      'Ascunde navigarea, dar păstrează pastila carte și capitol';

  @override
  String get settingsImmersiveFullTitle => 'Ape adânci (complet)';

  @override
  String get settingsImmersiveFullSubtitle =>
      'Imersiune totală. Toate meniurile se ascund la derulare';

  @override
  String get settingsShowStrongs => 'Afișează numerele Strong';

  @override
  String get settingsShowStrongsSubtitle =>
      'Afișează codurile ebraice/grecești lângă textul KJV pentru studiul cuvintelor';

  @override
  String get settingsStrongsGetIt => 'Obține';

  @override
  String get settingsStrongsMarkerAsterisk => 'Asterisc (*)';

  @override
  String get settingsStrongsMarkerChain => 'Lanț (🔗)';

  @override
  String get settingsStrongsMarkerNumber => 'Număr (H1234)';

  @override
  String get settingsReadingSpeed => 'Viteza de lectură';

  @override
  String get settingsReadingSpeedSubtitle =>
      'Ritm estimat pentru planuri (cuvinte pe minut)';

  @override
  String get settingsSpeedRelaxed => 'Relaxat';

  @override
  String get settingsSpeedStandard => 'Standard';

  @override
  String get settingsSpeedBrisk => 'Alert';

  @override
  String get settingsDictUnderlines => 'Sublinieri din dicționar';

  @override
  String get settingsDictUnderlinesSubtitle =>
      'Sublinieri punctate pentru termeni biblici și cuvinte arhaice';

  @override
  String get settingsUnderlineScope => 'Ce se subliniază';

  @override
  String get settingsScopeNamesTitle => 'Doar nume și termeni';

  @override
  String get settingsScopeNamesSubtitle =>
      'Nume proprii și concepte biblice specifice';

  @override
  String get settingsScopeTrickyTitle => 'Nume + cuvinte dificile (recomandat)';

  @override
  String get settingsScopeTrickySubtitle =>
      'Include cuvinte arhaice cu sens schimbat (ex. let, prevent)';

  @override
  String get settingsScopeEverythingTitle => 'Tot';

  @override
  String get settingsScopeEverythingSubtitle =>
      'Marchează toată gramatica arhaică (ex. thee, thou, hath, unto)';

  @override
  String get settingsScopeDifficultTitle => 'Doar cuvinte dificile';

  @override
  String get settingsScopeDifficultSubtitle =>
      'Cuvinte arhaice, înșelătoare și disputate — cele simple ca god și son rămân nemarcate';

  @override
  String get settingsScopeDifficultNamesTitle => 'Dificile + nume';

  @override
  String get settingsScopeDifficultNamesSubtitle =>
      'Adaugă persoane și locuri (ex. David, Ierusalim) la cuvintele dificile';

  @override
  String get settingsOtherEnglishVersions => 'Alte versiuni în engleză';

  @override
  String get settingsContestedOnlyTitle => 'Doar cuvinte disputate';

  @override
  String get settingsContestedOnlySubtitle =>
      'BBE, WEB și alte versiuni în engleză marchează cuvintele disputate (ex. hell, baptism)';

  @override
  String get settingsFollowScopeTitle => 'Urmează setarea de subliniere';

  @override
  String get settingsFollowScopeSubtitle =>
      'Același marcaj ca KJV în fiecare versiune în engleză';

  @override
  String get settingsNoUnderlinesTitle => 'Fără sublinieri';

  @override
  String get settingsNoUnderlinesSubtitle =>
      'Celelalte versiuni în engleză nu au marcaje';

  @override
  String get settingsPopupStyle => 'Stil fereastră';

  @override
  String get settingsPopupStyleSubtitle =>
      'Cum se afișează definițiile și numerele Strong';

  @override
  String get settingsPopupFloating => 'Flotant';

  @override
  String get settingsPopupBottomSheet => 'Panou inferior';

  @override
  String get settingsSavedInMyLanguage => 'Elemente salvate în limba mea';

  @override
  String get settingsSavedInMyLanguageSubtitle =>
      'Afișează semnele de carte, evidențierile și versetele comentate în traducerea principală';

  @override
  String get settingsTranslationChips =>
      'Opțiuni de traducere pe elementele salvate';

  @override
  String get settingsTranslationChipsSubtitle =>
      'Adaugă un rând compact pentru a vedea versetele salvate în alte traduceri';

  @override
  String get settingsVerseActionStyle => 'Stilul acțiunilor pe verset';

  @override
  String get settingsVerseActionStyleSubtitle =>
      'Panou (compact) sau Clasic (bară înaltă) la selectare; Radial afișează meniul de apăsare lungă în cerc';

  @override
  String get settingsActionSheet => 'Panou';

  @override
  String get settingsActionClassic => 'Clasic';

  @override
  String get settingsActionMinimal => 'Minimal';

  @override
  String get settingsActionRaindrop => 'Picătură';

  @override
  String get settingsActionRadial => 'Radial';

  @override
  String get settingsKeepAwake => 'Ecran mereu aprins';

  @override
  String get settingsKeepAwakeSubtitle =>
      'Împiedică intrarea în repaus în timpul lecturii';

  @override
  String get settingsRestartOnboarding => 'Reia configurarea';

  @override
  String get settingsRestartOnboardingSubtitle => 'Reia configurarea inițială';

  @override
  String get settingsRestartOnboardingDialogTitle => 'Reiei configurarea?';

  @override
  String get settingsRestartOnboardingDialogBody =>
      'Configurarea inițială va fi reluată. Tema, fontul și traducerea rămân la fel dacă nu le schimbi.';

  @override
  String get settingsRestart => 'Reia';

  @override
  String get settingsAppearanceText => 'Aspect și text';

  @override
  String get settingsAppearanceTextSubtitle =>
      'Temă, fonturi, mărimi și culori';

  @override
  String get settingsSabbathTitle => 'Memento apus de vineri';

  @override
  String get settingsSabbathSubtitle =>
      'Primește Sabatul la apusul soarelui local.';

  @override
  String get settingsLocation => 'Locație';

  @override
  String get settingsLocationNotSet => 'Nesetată (atinge pentru a seta)';

  @override
  String get settingsDailyReminderTitle => 'Memento lectură zilnică';

  @override
  String get settingsDailyReminderSubtitle =>
      'Un îndemn zilnic să petreci timp în Cuvânt.';

  @override
  String get settingsTime => 'Ora';

  @override
  String get settingsWeeklyReminderTitle => 'Memento săptămânal';

  @override
  String get settingsWeeklyReminderSubtitle =>
      'Alege o zi și o oră în fiecare săptămână pentru studiu aprofundat.';

  @override
  String get settingsDayAndTime => 'Zi și oră';

  @override
  String get settingsChooseDay => 'Alege ziua';

  @override
  String get settingsShowReadingTips => 'Afișează sfaturi de lectură';

  @override
  String get settingsShowReadingTipsSubtitle =>
      'Indicii pentru acțiuni precum evidențierea și glisarea';

  @override
  String get settingsNavSteps => 'Pași de navigare';

  @override
  String get settingsNavStepsSubtitle =>
      'Câți pași până la un verset. 2: Carte → Capitol. 3: Carte → Capitol → Verset. 4: Testament → Carte → Capitol → Verset.';

  @override
  String get settingsAutoClose => 'Închide după ultima selecție';

  @override
  String get settingsAutoCloseSubtitle =>
      'Închide automat selectorul după ultimul pas';

  @override
  String get settingsSelectorHeight => 'Înălțimea selectorului de cărți';

  @override
  String get settingsSelectorHeightSubtitle =>
      'Cât de sus se deschide panoul carte/capitol';

  @override
  String get settingsHeightHalf => 'Jumătate';

  @override
  String get settingsHeightFull => 'Complet';

  @override
  String get settingsAutoOpenSingle => 'Deschide rezultatul unic';

  @override
  String get settingsAutoOpenSingleSubtitle =>
      'Mergi direct când căutarea are un singur rezultat';

  @override
  String get settingsIncludeNotes => 'Include notițele în căutare';

  @override
  String get settingsIncludeNotesSubtitle =>
      'Permite căutarea în notițele tale';

  @override
  String get settingsWholeWords => 'Doar cuvinte întregi';

  @override
  String get settingsWholeWordsSubtitle =>
      'Doar cuvinte exacte (dezactivează potrivirea parțială)';

  @override
  String get settingsFuzzySearch => 'Căutare tolerantă';

  @override
  String get settingsFuzzySearchSubtitle =>
      'Arată și potriviri apropiate la greșeli (ex. Jhon găsește John)';

  @override
  String get settingsDefaultScopes => 'Domenii de căutare implicite';

  @override
  String get settingsOldTestament => 'Vechiul Testament';

  @override
  String get settingsNewTestament => 'Noul Testament';

  @override
  String get settingsCommentary => 'Comentariu';

  @override
  String get settingsGestures => 'Gesturi';

  @override
  String get settingsPullDownHome => 'Trage în jos pe Acasă';

  @override
  String get settingsPullDownHomeSubtitle =>
      'Trage peste partea de sus pentru Setări sau Aspect';

  @override
  String get settingsPullDownOpens => 'Gestul deschide';

  @override
  String get settingsPullDownOpensSubtitle => 'Destinația gestului pe Acasă';

  @override
  String get settingsAppearance => 'Aspect';

  @override
  String get settingsSwipeLeftHome => 'Glisează la stânga pe Acasă';

  @override
  String get settingsSwipeLeftHomeSubtitle =>
      'Glisează la stânga pentru Citește';

  @override
  String get settingsLongPressNav => 'Apăsare lungă pentru navigare';

  @override
  String get settingsLongPressNavSubtitle =>
      'Apasă lung butonul din dreapta jos pentru selectorul Carte/Capitol.';

  @override
  String get settingsBbeNoteTitle => 'Notă despre traducerea BBE';

  @override
  String get settingsBackup => 'Salvează datele mele';

  @override
  String get settingsBackupSubtitle => 'Exportă notițe, evidențieri și setări';

  @override
  String get settingsRestoreBackup => 'Restaurează din copie';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Importă datele dintr-o copie JSON';

  @override
  String get settingsRestoreBackupDialogTitle => 'Restaurează din copie';

  @override
  String get settingsRestoreHint => 'Lipește aici copia JSON…';

  @override
  String get settingsRestore => 'Restaurează';

  @override
  String get settingsClearCache => 'Golește cache-ul și descărcările';

  @override
  String get settingsClearCacheSubtitle =>
      'Eliberează spațiu ștergând fișierele din cache';

  @override
  String get settingsNotImplemented => 'Încă nu este disponibil';

  @override
  String get settingsResetSettings => 'Resetează setările';

  @override
  String get settingsResetSettingsSubtitle =>
      'Revino la setările inițiale (conținutul rămâne)';

  @override
  String get settingsResetDialogTitle => 'Resetezi setările?';

  @override
  String get settingsResetDialogBody =>
      'Resetezi toate setările? Semnele de carte, notițele și evidențierile nu vor fi afectate.';

  @override
  String get settingsResetDone => 'Setările au fost resetate.';

  @override
  String get settingsReset => 'Resetează';

  @override
  String get settingsVersion => 'Versiune';

  @override
  String get settingsUnknown => 'Necunoscut';

  @override
  String get settingsStorage => 'Stocare și descărcări';

  @override
  String get settingsStorageSubtitle =>
      'Cache, traduceri descărcate și spațiu eliberabil';

  @override
  String get settingsSendFeedback => 'Trimite feedback';

  @override
  String get settingsCrashReports => 'Trimite rapoarte de erori';

  @override
  String get settingsCrashReportsSubtitle =>
      'Detaliile anonime ajută la remedierea erorilor. Nu se includ lecturi biblice, notițe sau date personale.';

  @override
  String get settingsPrivacyPolicy => 'Politica de confidențialitate';

  @override
  String get settingsCredits => 'Credite și surse';

  @override
  String get settingsCreditsSubtitle =>
      'Traduceri biblice, comentarii, date de studiu, fonturi și licențe';

  @override
  String get settingsSetSunsetLocation => 'Locația pentru apus';

  @override
  String get settingsCurrentLocationGps => 'Locația actuală (GPS)';

  @override
  String get settingsUseMyLocation => 'Folosește locația mea';

  @override
  String get settingsOrSelectCity => 'SAU alege un oraș mare';

  @override
  String get settingsTypography => 'Tipografie';

  @override
  String get settingsTheme => 'Temă';

  @override
  String get settingsSearchSettings => 'Setări de căutare';

  @override
  String get settingsMatchTypeHeader => 'POTRIVIRE';

  @override
  String get settingsExactMatch => 'Potrivire exactă';

  @override
  String get settingsExactMatchSubtitle => 'Doar expresia exactă';

  @override
  String get settingsScopeHeader => 'DOMENIU';

  @override
  String get settingsDisabledBookFilter => 'Dezactivat (filtru de carte activ)';

  @override
  String get settingsMyNotes => 'Notițele mele';

  @override
  String get settingsBehaviorHeader => 'COMPORTAMENT';

  @override
  String get settingsAutoOpenSingleShort => 'Deschide rezultatul unic';

  @override
  String get settingsAutoOpenSingleShortSubtitle =>
      'Mergi direct dacă există un singur rezultat';

  @override
  String get settingsBackgroundGlow => 'Activează strălucirea de fundal';

  @override
  String get settingsBackgroundGlowSubtitle =>
      'O lumină animată discretă în spatele textului';

  @override
  String get settingsThemeGroupFoundations => 'TEMELII';

  @override
  String get settingsThemeDawn => 'Zori';

  @override
  String get settingsThemeFresh => 'Proaspăt';

  @override
  String get settingsThemeGroupFirmament => 'FIRMAMENT';

  @override
  String get settingsThemeSun => 'Soare';

  @override
  String get settingsThemeMoon => 'Lună';

  @override
  String get settingsThemeStars => 'Stele';

  @override
  String get settingsThemeGroupEden => 'EDEN';

  @override
  String get settingsThemeLilies => 'Crini';

  @override
  String get settingsThemeRoses => 'Trandafiri';

  @override
  String get settingsThemeOlives => 'Măslini';

  @override
  String get settingsThemeGroupSanctuary => 'SANCTUAR';

  @override
  String get settingsThemePurple => 'Purpuriu\npreoțesc';

  @override
  String get settingsThemeBlue => 'Albastru\nGalileea';

  @override
  String get settingsThemeRed => 'Roșu\nstacojiu';

  @override
  String get settingsSurpriseMe => 'Surprinde-mă';

  @override
  String get settingsThemeOledDark => 'OLED\nîntunecat';

  @override
  String get settingsThemeDuskOled => 'Amurg\nOLED';

  @override
  String get settingsSurfaceStyle => 'Stil suprafață';

  @override
  String get settingsSurfaceStyleSubtitle =>
      'Profunzime vizuală și redarea materialelor';

  @override
  String get settingsSurfaceEarth => 'Pământ';

  @override
  String get settingsSurfaceEarthSubtitle => 'Suprafață plată';

  @override
  String get settingsSurfaceHeaven => 'Cer';

  @override
  String get settingsSurfaceHeavenSubtitle => 'Adâncime mată';

  @override
  String get settingsSurfacePaper => 'Hârtie';

  @override
  String get settingsSurfacePaperSubtitle => 'E-reader cald';

  @override
  String get settingsSurfaceClay => 'Lut';

  @override
  String get settingsSurfaceClaySubtitle => '3D moale';

  @override
  String get settingsWidgetsLivePreview =>
      'Previzualizare live și personalizare';

  @override
  String get settingsWidgetPreviewHeader => 'PREVIZUALIZARE WIDGET';

  @override
  String get settingsWidgetStreak => 'Serie activă! • Obiectiv zilnic';

  @override
  String get settingsWidgetWotd => 'CUVÂNTUL ZILEI';

  @override
  String get settingsWidgetVotd => 'VERSETUL ZILEI';

  @override
  String get settingsWidgetBackgroundHeader => 'FUNDAL ȘI DEGRADEURI';

  @override
  String get settingsWidgetContrastHeader => 'CONTRAST TEXT';

  @override
  String get settingsWidgetTextAuto => 'Auto ✨';

  @override
  String get settingsWidgetTextDark => 'Text închis ☀️';

  @override
  String get settingsWidgetTextWhite => 'Text alb 🌙';

  @override
  String get settingsWidgetSynced => 'Widgeturile au fost sincronizate! ✨';

  @override
  String get settingsWidgetApply => 'Aplică pe ecranul principal';

  @override
  String get settingsFontSizeHeader => 'MĂRIME';

  @override
  String get settingsFontWeightHeader => 'GROSIME';

  @override
  String get settingsWeightLight => 'Subțire';

  @override
  String get settingsWeightRegular => 'Normal';

  @override
  String get settingsWeightMedium => 'Mediu';

  @override
  String get settingsWeightBold => 'Aldin';

  @override
  String get settingsLineSpacingHeader => 'SPAȚIERE';

  @override
  String get settingsSpacingCompact => 'Compact';

  @override
  String get settingsSpacingNormal => 'Normal';

  @override
  String get settingsMarginsHeader => 'MARGINI';

  @override
  String get settingsAlignmentHeader => 'ALINIERE';

  @override
  String get settingsAlignLeft => 'Stânga';

  @override
  String get settingsAlignCenter => 'Centru';

  @override
  String get settingsAlignRight => 'Dreapta';

  @override
  String get settingsAlignJustified => 'Justificat';

  @override
  String get settingsFontFamilyHeader => 'FONT';

  @override
  String get settingsItalicHeader => 'TEXT CURSIV';

  @override
  String get settingsDailyReading => 'Lectură zilnică';

  @override
  String get settingsCustomReminder => 'Memento personalizat';

  @override
  String get settingsMonday => 'Luni';

  @override
  String get settingsTuesday => 'Marți';

  @override
  String get settingsWednesday => 'Miercuri';

  @override
  String get settingsThursday => 'Joi';

  @override
  String get settingsFriday => 'Vineri';

  @override
  String get settingsSaturday => 'Sâmbătă';

  @override
  String get settingsSunday => 'Duminică';

  @override
  String settingsStrongsPackRequired(String size) {
    return 'Necesită pachetul „KJV with Strong\'s” ($size de descărcat).';
  }

  @override
  String settingsBbeNoteBody(int count) {
    return 'Bible in Basic English a lăsat unele versete netraduse sau mult prescurtate. Pentru acestea ($count versete) se afișează textul World English Bible (WEB), marcat cu o insignă WEB.';
  }

  @override
  String settingsDayAtTime(String day, String time) {
    return '$day la $time';
  }

  @override
  String get spaceTitle => 'Spațiul tău';

  @override
  String get spaceTabHighlights => 'Evidențieri';

  @override
  String get spaceTabBookmarks => 'Semne de carte';

  @override
  String get spaceTabNotes => 'Notițe';

  @override
  String get spaceTabJournal => 'Jurnal';

  @override
  String get spaceHighlighted => 'Evidențiat';

  @override
  String get spaceNewFolder => 'Dosar nou';

  @override
  String get spaceFolderNameHint => 'Numele dosarului';

  @override
  String get spaceCreate => 'Creează';

  @override
  String get spaceRenameFolder => 'Redenumește dosarul';

  @override
  String get spaceRename => 'Redenumește';

  @override
  String get spaceDeleteFolderTitle => 'Ștergi dosarul?';

  @override
  String spaceDeleteFolderBody(String folderName) {
    return 'Sigur vrei să ștergi „$folderName”?\n\nSemnele de carte din acest dosar NU vor fi șterse; vor fi mutate în Neclasate.';
  }

  @override
  String get spaceMoveToFolder => 'Mută în dosar';

  @override
  String get spaceUnfiled => 'Neclasate';

  @override
  String get spaceGroupEarlier => 'Mai devreme';

  @override
  String get spaceGroupLast7Days => 'Ultimele 7 zile';

  @override
  String get spaceGroupLast30Days => 'Ultimele 30 de zile';

  @override
  String get spaceUnknownBook => 'Carte necunoscută';

  @override
  String get spaceNoBookmarks => 'Niciun semn de carte aici.';

  @override
  String get spaceFilterAll => 'Toate';

  @override
  String get spaceByDate => 'După dată';

  @override
  String get spaceByBook => 'După carte';

  @override
  String get spaceYourNotes => 'Notițele tale.';

  @override
  String get spaceNoNotesTapPlus =>
      'Nicio notiță încă.\nApasă + pentru a crea una.';

  @override
  String get spaceMore => 'Mai mult';

  @override
  String get spaceNote => 'Notiță';

  @override
  String get spaceCopyText => 'Copiază textul';

  @override
  String get spaceDeleteNoteTitle => 'Ștergi notița?';

  @override
  String spaceDeleteNoteBody(String title) {
    return '„$title” va fi ștearsă definitiv.';
  }

  @override
  String get spaceUntitled => 'Fără titlu';

  @override
  String get spaceBookmarkedVerse => 'Verset marcat';

  @override
  String get spaceHighlightedVerse => 'Verset evidențiat';

  @override
  String get spaceOpenInRead => 'Deschide în Citire';

  @override
  String get spaceAddNote => 'Adaugă notiță';

  @override
  String get spaceCopyVerse => 'Copiază versetul';

  @override
  String get spaceShareVerse => 'Distribuie versetul';

  @override
  String get spaceChangeColour => 'Schimbă culoarea';

  @override
  String get spaceMoveToFolderAction => 'Mută în dosar';

  @override
  String get spaceRemoveBookmark => 'Elimină semnul de carte';

  @override
  String get spaceRemoveHighlight => 'Elimină evidențierea';

  @override
  String get spaceHighlightColour => 'Culoarea evidențierii';

  @override
  String spaceColourN(int index) {
    return 'Culoarea $index';
  }

  @override
  String get notesMyNotes => 'Notițele mele';

  @override
  String get notesEmptyTitle => 'Nicio notiță încă';

  @override
  String get notesEmptyBody => 'Apasă butonul + pentru a adăuga prima notiță.';

  @override
  String get notesVerseInserted => 'Verset inserat';

  @override
  String get notesAddCommentary => 'Adaugă comentariu';

  @override
  String get notesChapterTitlePlaceholder => 'Titlul capitolului';

  @override
  String get notesEditNote => 'Editează notița';

  @override
  String notesNewNoteOn(String reference) {
    return 'Notiță nouă la $reference';
  }

  @override
  String get notesNewNote => 'Notiță nouă';

  @override
  String get notesTitleHint => 'Titlul notiței';

  @override
  String get notesContentHint => 'Începe să scrii… (tastează / pentru comenzi)';

  @override
  String get notesInsertVerse => 'Inserează verset';

  @override
  String get notesInsertDate => 'Inserează data';

  @override
  String get notesInsertChapterTitle => 'Inserează titlul capitolului';

  @override
  String get notesSaved => 'Notiță salvată!';

  @override
  String get notesSaveChanges => 'Salvează modificările';

  @override
  String get notesSaveNote => 'Salvează notița';

  @override
  String get notesDeleted => 'Notiță ștearsă';

  @override
  String get notesDeleteNote => 'Șterge notița';

  @override
  String get notesNewJournalEntry => 'Intrare nouă în jurnal';

  @override
  String get notesJournalHint => 'Cum te simți azi? Deschide-ți inima…';

  @override
  String get notesSaveAndAnalyze => 'Salvează și analizează';

  @override
  String get notesNoJournalEntries => 'Nicio intrare în jurnal încă.';

  @override
  String get notesWriteEntry => 'Scrie';

  @override
  String get notesAiReflection => 'Reflecție AI';

  @override
  String notesDetectedEmotion(String emotion) {
    return 'Emoție detectată: $emotion';
  }

  @override
  String notesVersesList(String verses) {
    return 'Versete: $verses';
  }

  @override
  String get accountGuest => 'Invitat';

  @override
  String get accountSignInToSync => 'Conectează-te pentru sincronizare';

  @override
  String get accountAccount => 'Cont';

  @override
  String get accountSettings => 'Setări';

  @override
  String get accountBackUp => 'Salvează datele';

  @override
  String get accountBackUpSubtitle => 'Exportă notițe, evidențieri și setări';

  @override
  String get accountRestore => 'Restaurează datele';

  @override
  String get accountRestoreSubtitle => 'Importă dintr-o copie de rezervă';

  @override
  String get accountSignInGoogle => 'Conectează-te cu Google';

  @override
  String get accountSignInApple => 'Conectează-te cu Apple';

  @override
  String get accountSignOut => 'Deconectează-te';

  @override
  String get accountResetApp => 'Resetează aplicația';

  @override
  String get accountResetAppSubtitle => 'Șterge datele de pe dispozitiv';

  @override
  String get accountSignIn => 'Conectare';

  @override
  String get accountSignedIn => 'Conectat';

  @override
  String get accountDeleteAccount => 'Șterge contul';

  @override
  String get accountDeleteAccountTitle => 'Ștergi contul?';

  @override
  String get accountDeleteAccountBody =>
      'Acțiunea este permanentă și ireversibilă.\n\nVor fi eliminate complet:\n• Contul tău de conectare\n• Datele sale din cloud în The Blessed Bible și Blessed Arcade (cont comun)\n• Toate datele de studiu de pe dispozitiv (semne de carte, evidențieri, istoric)';

  @override
  String get accountDeleted => 'Cont șters cu succes.';

  @override
  String accountReauthFailed(String reason) {
    return 'Nu am putut confirma că ești tu, deci nu s-a șters nimic. $reason';
  }

  @override
  String get accountDeleteFailed =>
      'Contul nu a putut fi șters. Încearcă din nou.';

  @override
  String get accountOtherDataTitle => 'Dispozitivul are date din alt cont';

  @override
  String get accountOtherDataBody =>
      'Semnele de carte, evidențierile și notițele de pe acest dispozitiv provin din alt cont. Ce vrei să faci cu ele?';

  @override
  String get accountStartFresh => 'Începe de la zero aici';

  @override
  String get accountMerge => 'Combină cu acest cont';

  @override
  String get accountSignOutTitle => 'Te deconectezi?';

  @override
  String get accountSignOutBody =>
      'Semnele de carte, evidențierile și notițele rămân în siguranță în cont. Păstrezi o copie pe dispozitiv?';

  @override
  String get accountRemoveFromDevice => 'Elimină de pe dispozitiv';

  @override
  String get accountKeepOnDevice => 'Păstrează pe dispozitiv';

  @override
  String get accountSyncing => 'Se sincronizează…';

  @override
  String get accountSyncFailed => 'Sincronizare eșuată';

  @override
  String get accountTapToRetry => 'Apasă pentru a reîncerca';

  @override
  String get accountSyncPaused => 'Sincronizare întreruptă';

  @override
  String get accountSyncChoose => 'Alege ce faci cu datele acestui dispozitiv';

  @override
  String get accountSyncNow => 'Sincronizează acum';

  @override
  String get accountNotSyncedYet => 'Nesincronizat încă';

  @override
  String get accountSyncedJustNow => 'Sincronizat chiar acum';

  @override
  String accountSyncedMinAgo(int minutes) {
    return 'Sincronizat acum $minutes min';
  }

  @override
  String accountSyncedHoursAgo(int hours) {
    return 'Sincronizat acum $hours h';
  }

  @override
  String accountSyncedOn(int day, int month, int year) {
    return 'Sincronizat pe $day/$month/$year';
  }

  @override
  String get accountRestoreTitle => 'Restaurează din copie';

  @override
  String get accountRestoreHint => 'Lipește aici JSON-ul copiei…';

  @override
  String get accountRestoreAction => 'Restaurează';

  @override
  String get accountResetTitle => 'Resetezi aplicația?';

  @override
  String get accountResetBody =>
      'Se șterg toate datele de pe dispozitiv:\n• Semne de carte, evidențieri, notițe și jurnal\n• Planuri de citire, progres și planuri proprii\n• Traduceri descărcate și serii\n\nSetările, tema și Biblia offline rămân neatinse. Acțiunea nu poate fi anulată — fă o copie de rezervă dacă e nevoie.';

  @override
  String get accountResetDone => 'Datele au fost resetate. Un nou început!';

  @override
  String get accountReset => 'Resetează';

  @override
  String get shareBackdrop => 'Fundal';

  @override
  String get shareBackdropDawn => 'Zori';

  @override
  String get shareBackdropDusk => 'Amurg';

  @override
  String get shareBackdropArtwork => 'Ilustrație';

  @override
  String get shareBackdropGradient => 'Degradeu';

  @override
  String get shareFont => 'Font';

  @override
  String get shareFontTheme => 'Temă';

  @override
  String get shareSize => 'Mărime';

  @override
  String get shareSpacing => 'Spațiere';

  @override
  String get shareSpacingNormal => 'Normal';

  @override
  String shareSpacingWide(String value) {
    return 'Lată $value';
  }

  @override
  String get shareLineHeight => 'Înălțime rând';

  @override
  String get shareAlignment => 'Aliniere';

  @override
  String get shareAlignCenter => 'Centru';

  @override
  String get shareAlignLeft => 'Stânga';

  @override
  String get sharePreparing => 'Se pregătește…';

  @override
  String get shareImage => 'Distribuie imaginea';

  @override
  String get shareText => 'Distribuie textul';

  @override
  String get shareImageCard => 'Distribuie card-ul imagine';

  @override
  String get spaceStorageTitle => 'Stocare';

  @override
  String get spaceClearCacheTitle => 'Golești memoria cache?';

  @override
  String get spaceClearCacheBody =>
      'Elimină fișierele temporare (carduri generate, miniaturi). Notițele, semnele de carte, evidențierile și descărcările rămân neatinse.';

  @override
  String get spaceClearCache => 'Golește cache';

  @override
  String get spaceCacheCleared => 'Cache golit';

  @override
  String spaceDeletePackTitle(String name) {
    return 'Ștergi $name?';
  }

  @override
  String spaceDeletePackBundled(String size) {
    return 'Eliberează $size. O poți restaura offline oricând.';
  }

  @override
  String spaceDeletePackDownloaded(String size) {
    return 'Eliberează $size. O poți descărca din nou mai târziu.';
  }

  @override
  String spacePackDeleted(String abbr) {
    return '$abbr ștearsă';
  }

  @override
  String spacePackDownloaded(String abbr) {
    return '$abbr descărcată';
  }

  @override
  String spaceCouldNotFinish(String error) {
    return 'Nu s-a putut finaliza: $error';
  }

  @override
  String spaceFreed(String message, String size) {
    return '$message · eliberat $size';
  }

  @override
  String get spaceOnThisDevice => 'Pe acest dispozitiv';

  @override
  String get spaceBibleContent => 'Conținut biblic (păstrat mereu)';

  @override
  String get spaceDownloadedPacks => 'Pachete descărcate';

  @override
  String get spaceCache => 'Cache';

  @override
  String get spaceCacheExplain =>
      'Doar fișiere temporare — carduri generate și miniaturi. Poate fi golit oricând.';

  @override
  String get spaceTranslationsDownloads => 'Traduceri și descărcări';

  @override
  String get spaceBundledSuffix => ' · inclusă';

  @override
  String get spaceCoreNotRemovable =>
      'KJV și BBE fac parte din aplicație și nu pot fi eliminate.';

  @override
  String get spaceGet => 'Obține';

  @override
  String spaceDeletePackTooltip(String name) {
    return 'Șterge $name';
  }

  @override
  String studyCouldNotOpenScreen(String error) {
    return 'Ecranul nu a putut fi deschis. $error';
  }

  @override
  String get studyCardSize => 'Dimensiunea cardului';

  @override
  String get studyPosition => 'Poziție';

  @override
  String get studySizeLarge => 'Mare';

  @override
  String get studySizeLargeHint => 'Lățime completă, la fel ca restul';

  @override
  String get studySizeExtraLarge => 'Foarte mare';

  @override
  String get studySizeExtraLargeHint => 'Lățime completă, conținut mai aerisit';

  @override
  String get studySizeHalf => 'Jumătate';

  @override
  String get studySizeHalfHint => 'Compact, două pe rând';

  @override
  String get studyMoveUp => 'Mută în sus';

  @override
  String get studyMoveUpHint => 'Schimbă cu cardul de deasupra';

  @override
  String get studyMoveDown => 'Mută în jos';

  @override
  String get studyMoveDownHint => 'Schimbă cu cardul de dedesubt';

  @override
  String get studyCommentaryEyebrow => 'Comentariu';

  @override
  String get studyCommentaryTitle => 'Explicații verset cu verset';

  @override
  String get studyCommentarySnippet =>
      'Comentariu istoricist cu filtre pe capitol și verset.';

  @override
  String get studyCommentaryCta => 'Deschide comentariul';

  @override
  String get studyDictionaryEyebrow => 'Dicționar';

  @override
  String get studyDictionaryTitle => 'Cuvinte explicate';

  @override
  String get studyDictionarySnippet =>
      'Easton și Smith, offline, cu cuvinte salvate.';

  @override
  String get studyDictionaryCta => 'Caută';

  @override
  String get studyStoriesEyebrow => 'Povestiri biblice';

  @override
  String get studyStoriesTitle => 'Relatări repovestite';

  @override
  String get studyStoriesSnippet => '66 de povestiri din fiecare carte.';

  @override
  String get studyStoriesCta => 'Citește povestirile';

  @override
  String get studyConcordanceEyebrow => 'Concordanță';

  @override
  String get studyConcordanceTitle => 'Fiecare apariție';

  @override
  String get studyConcordanceSnippet =>
      'Găsește fiecare verset în care apare un cuvânt.';

  @override
  String get studyConcordanceCta => 'Caută cuvinte';

  @override
  String get studySpaceSaved => 'Salvate';

  @override
  String get studySpaceMarked => 'Evidențiate';

  @override
  String get studySpaceNotes => 'Notițe';

  @override
  String get studySpaceJournal => 'Jurnal';

  @override
  String get studySpaceTitle => 'Spațiul tău';

  @override
  String get studySpaceSubtitle =>
      'Semne de carte, evidențieri, notițe și jurnal';

  @override
  String get studyReadingPlan => 'Plan de citire';

  @override
  String get studyStartReadingPlan => 'Începe un plan de citire';

  @override
  String get studyActivePlan => 'Plan activ';

  @override
  String studyDayOfTotal(int current, int total) {
    return 'Ziua $current din $total';
  }

  @override
  String studyDaysBehind(int count) {
    return '$count în urmă';
  }

  @override
  String get studyPlans => 'Planuri';

  @override
  String get studyGuidedReading => 'Citire ghidată';

  @override
  String get studyGuidedReadingSubtitle =>
      'Selectate, ritmate și personalizate';

  @override
  String get studyReadyToBegin => 'Gata de început';

  @override
  String studyTodayLabel(String label) {
    return 'Azi: $label';
  }

  @override
  String get studyReview => 'Revezi';

  @override
  String get studyRead => 'Citește';

  @override
  String studyCtaArrow(String cta) {
    return '$cta →';
  }

  @override
  String get studyWordOfTheDay => 'Cuvântul zilei';

  @override
  String get studyArchiveLink => 'Arhivă →';

  @override
  String get studyLoading => 'Se încarcă…';

  @override
  String get studyUnavailableNow => 'Indisponibil momentan';

  @override
  String get studyReadingStreak => 'Serie de citire';

  @override
  String get studyStartStreak => 'Începe-ți seria';

  @override
  String studyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de zile',
      few: '$count zile',
      one: '1 zi',
    );
    return '$_temp0';
  }

  @override
  String get studyStreakGrow => 'Deschide zilnic ca s-o crești.';

  @override
  String get studyStreakStart => 'Finalizează o citire în fiecare zi.';

  @override
  String get studyViewProgress => 'Vezi progresul →';

  @override
  String get studyPassageNotFound => 'Pasaj negăsit';

  @override
  String get studyPassageLoadError => 'Pasajul nu a putut fi încărcat.';

  @override
  String get studyCompletedCheck => '✓ Finalizat';

  @override
  String get studyMarkAsRead => 'Marchează ca citit';

  @override
  String get studyNextPassage => 'Pasajul următor';

  @override
  String get studyFullChapter => 'Tot capitolul';

  @override
  String studyPassageOfTotal(int current, int total) {
    return 'Pasajul $current din $total';
  }

  @override
  String studySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de selectate',
      few: '$count selectate',
      one: '1 selectat',
    );
    return '$_temp0';
  }

  @override
  String get studyHighlight => 'Evidențiază';

  @override
  String get studyBookmark => 'Semn de carte';

  @override
  String get studyAddNote => 'Adaugă notiță';

  @override
  String studyChaptersWithContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de capitole cu conținut',
      few: '$count capitole cu conținut',
      one: '1 capitol cu conținut',
    );
    return '$_temp0';
  }

  @override
  String get studyCommentaryLibrary => 'Biblioteca de comentarii';

  @override
  String get studyCommentaryLoadError => 'Comentariul nu a putut fi încărcat.';

  @override
  String get studyNoCommentaryYet => 'Niciun comentariu disponibil încă.';

  @override
  String studyNoBooksMatch(String query) {
    return 'Nicio carte nu corespunde cu „$query”.';
  }

  @override
  String studySearchBooksCount(int count) {
    return 'Caută în $count cărți…';
  }

  @override
  String get studyClassicSources => 'Surse clasice';

  @override
  String studyBookAuthorChapters(String author, int count) {
    return '$author · $count cap.';
  }

  @override
  String studyReadingRef(String reference) {
    return 'Citire · $reference';
  }

  @override
  String get studyAllSources => 'Toate sursele';

  @override
  String get studyVerseLevel => 'La nivel de verset';

  @override
  String studySearchWithin(String reference) {
    return 'Caută în $reference…';
  }

  @override
  String studyEntriesLoadError(String error) {
    return 'Intrările nu au putut fi încărcate.\n$error';
  }

  @override
  String get studyNoEntriesMatch =>
      'Nicio intrare nu corespunde filtrelor.\nÎncearcă Toate sursele sau răsfoiește biblioteca.';

  @override
  String studyVerseN(int verse) {
    return 'Versetul $verse';
  }

  @override
  String get studyChapter => 'Capitol';

  @override
  String get studyCategoryCommentary => 'Comentariu';

  @override
  String get studyCategoryDevotional => 'Devoțional';

  @override
  String get studyCategoryStudyNote => 'Notă de studiu';

  @override
  String studyCommentaryLoadErrorDetail(String error) {
    return 'Comentariul nu a putut fi încărcat.\n$error';
  }

  @override
  String get studyNoContentForFilters =>
      'Niciun conținut pentru aceste filtre.';

  @override
  String studyVerseLabel(String verse) {
    return 'Versetul $verse';
  }

  @override
  String get studyChapterView => 'Tot capitolul';

  @override
  String get studyFilterAll => 'Toate';

  @override
  String get studyFilterDevotionals => 'Devoționale';

  @override
  String get studyFilterAllContexts => 'Toate contextele';

  @override
  String get studyFilterChapterLevel => 'La nivel de capitol';

  @override
  String get studyFilterVerseLevel => 'La nivel de verset';

  @override
  String get studyRemoveBookmark => 'Elimină semnul de carte';

  @override
  String get studyBookmarkCommentary => 'Adaugă semn de carte';

  @override
  String get studyExpandFullScreen => 'Ecran complet';

  @override
  String get studyTapToReadInContext => 'Atinge pentru a citi în context';

  @override
  String get studyOnThisChapter => 'Despre acest capitol';

  @override
  String get studyOnThisBook => 'Despre această carte';

  @override
  String get studyNoCommentaryTitle => 'Încă niciun comentariu';

  @override
  String get studyNoCommentaryBody =>
      'Nu am găsit un comentariu specific pentru acest pasaj. Explorează comentariile capitolului sau ale cărții de mai jos.';

  @override
  String get storiesTitle => 'Povestiri biblice';

  @override
  String get storiesFilters => 'Filtre';

  @override
  String get storiesSubtitle =>
      '500 de momente ilustrate de la Geneza la Apocalipsa';

  @override
  String get storiesSearchHint => 'Titlu, carte sau referință…';

  @override
  String get storiesClearSearch => 'Șterge căutarea';

  @override
  String get storiesFilterAll => 'Toate';

  @override
  String get storiesFilterOt => 'VT';

  @override
  String get storiesFilterNt => 'NT';

  @override
  String storiesCountOfTotal(int count, int total) {
    return '$count din $total povestiri';
  }

  @override
  String get storiesFavorites => 'Favorite';

  @override
  String get storiesUnread => 'Necitite';

  @override
  String storiesLoadError(String error) {
    return 'Povestirile nu au putut fi încărcate:\n$error';
  }

  @override
  String get storiesBooks => 'Cărți';

  @override
  String get storiesSearchBooks => 'Caută o carte…';

  @override
  String get storiesAllBooks => 'Toate cărțile';

  @override
  String get storiesNoMatch => 'Nicio povestire nu corespunde filtrelor.';

  @override
  String get storiesNoFavorites => 'Încă nicio favorită.';

  @override
  String get storiesBrowseAll => 'Răsfoiește toate povestirile';

  @override
  String get storiesAllCaughtUp => 'Ești la zi.';

  @override
  String get storiesShowRead => 'Arată povestirile citite';

  @override
  String get storiesClearFilters => 'Șterge filtrele';

  @override
  String get storiesFavoritesHint =>
      'Atinge ♥ pe o povestire ca s-o salvezi aici.';

  @override
  String get storiesAttribution =>
      'Scriptura din King James Version (domeniu public). Rezumate adaptate după The Graham Bible (grahambible.com), asistate de IA și revizuite de oameni. Ilustrații: Gustave Doré (1832–1883), domeniu public, prin Wikimedia Commons.';

  @override
  String get storiesReachedEnd => 'Ai ajuns la final.';

  @override
  String get storiesFirstStory => 'Aceasta este prima povestire.';

  @override
  String get storiesFavorite => 'Favorită';

  @override
  String get storiesMarkAsRead => 'Marchează ca citită';

  @override
  String storiesKeyVerse(String reference) {
    return 'VERSET CHEIE · $reference';
  }

  @override
  String get storiesTheStory => 'POVESTIREA';

  @override
  String storiesArtworkCaption(String caption) {
    return 'Ilustrație: $caption — Gustave Doré, domeniu public';
  }

  @override
  String get storiesPrevious => 'Povestirea anterioară';

  @override
  String get storiesNext => 'Povestirea următoare';

  @override
  String get studyDictionarySearchHint => 'Caută în peste 3.400 de cuvinte…';

  @override
  String get studyDictionarySavedFilter => '★ Salvate';

  @override
  String studyDictionaryUnavailable(String error) {
    return 'Dicționar indisponibil.\n$error';
  }

  @override
  String get studyNoHeadwords => 'Niciun cuvânt-titlu găsit.';

  @override
  String get studyDictionaryNoMatches =>
      'Niciun rezultat. Încearcă „grace”, „atonement” sau „wilderness” (dicționar în engleză).';

  @override
  String studyResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de rezultate',
      few: '$count rezultate',
      one: '1 rezultat',
    );
    return '$_temp0';
  }

  @override
  String get studyUntitledEntry => '(intrare fără titlu)';

  @override
  String get studyRemoveSavedWord => 'Elimină cuvântul salvat';

  @override
  String get studySaveWord => 'Salvează cuvântul';

  @override
  String get studyNoDefinition => 'Nicio definiție găsită.';

  @override
  String studyFailedToLoad(String error) {
    return 'Încărcarea a eșuat: $error';
  }

  @override
  String studyStrongsShareText(String id, String lemma, String transliteration,
      String pronunciation, String definition) {
    return '$id - $lemma\n\nTransliterare: $transliteration\nPronunție: $pronunciation\n\nDefiniție:\n$definition';
  }

  @override
  String studyNoStrongsEntry(String id) {
    return 'Nicio intrare pentru $id.';
  }

  @override
  String get studyStrongsLexicon => 'LEXICONUL STRONG';

  @override
  String get studyConcordanceHint => 'Cuvânt în engleză (ex. grace, covenant)…';

  @override
  String get studyConcordanceIntro =>
      'Apariții în KJV — atinge un verset pentru a-l citi în context.';

  @override
  String get studyConcordanceEmpty =>
      'Fiecare verset care conține cuvântul, în ordine canonică.';

  @override
  String get studyConcordanceSingleWord =>
      'Introdu un singur cuvânt în engleză.';

  @override
  String studyConcordanceNoVerses(String word) {
    return 'Niciun verset nu conține „$word”.';
  }

  @override
  String studyConcordanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de versete',
      few: '$count versete',
      one: '1 verset',
    );
    return '$_temp0';
  }

  @override
  String studyConcordanceCountTruncated(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de versete',
      few: '$count versete',
      one: '1 verset',
    );
    return '$_temp0 (primele $limit afișate)';
  }

  @override
  String get creditsTitle => 'Mulțumiri și surse';

  @override
  String get creditsLicenses => 'Licențe open source';

  @override
  String get creditsLicensesSubtitle => 'Fonturi și pachete software';

  @override
  String studyPreparingOfflineBible(int percent) {
    return 'Se pregătește Biblia offline… $percent%';
  }

  @override
  String get errorTitle => 'A apărut o problemă';

  @override
  String get errorBody =>
      'A apărut o problemă neașteptată. Atinge mai jos pentru a reveni la ecranul principal.';

  @override
  String get errorBackHome => 'Înapoi la început';

  @override
  String studyWeekN(int week) {
    return 'Săptămâna $week';
  }

  @override
  String get privacyTitle => 'Politica de confidențialitate';

  @override
  String get privacyLoadError =>
      'Politica de confidențialitate nu a putut fi încărcată.';

  @override
  String privacyEffectiveDate(String date) {
    return 'Data intrării în vigoare: $date';
  }

  @override
  String get privacyEnglishOnly =>
      'Această politică este disponibilă în limba engleză.';

  @override
  String get privacyViewOnline => 'Vezi online';
}
