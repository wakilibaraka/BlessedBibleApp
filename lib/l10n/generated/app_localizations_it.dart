// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get a11yTextSmaller => 'Testo più piccolo';

  @override
  String get a11yTextLarger => 'Testo più grande';

  @override
  String get a11yNotifications => 'Notifiche';

  @override
  String get a11yShowNav => 'Mostra navigazione';

  @override
  String get a11yHideNav => 'Nascondi navigazione';

  @override
  String a11yVersesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versetti selezionati',
      one: '1 versetto selezionato',
    );
    return '$_temp0';
  }

  @override
  String get a11yMakePrimary => 'Imposta come traduzione principale';

  @override
  String get a11yPreviousWeek => 'Settimana precedente';

  @override
  String get a11yNextWeek => 'Settimana successiva';

  @override
  String get a11yRead => 'Letto';

  @override
  String get appTitle => 'The Blessed Bible';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonContinue => 'Continua';

  @override
  String get commonSkip => 'Salta';

  @override
  String get commonBack => 'Indietro';

  @override
  String get commonDone => 'Fatto';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonClear => 'Cancella';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Riprova';

  @override
  String get commonShare => 'Condividi';

  @override
  String get commonCopy => 'Copia';

  @override
  String get commonEdit => 'Modifica';

  @override
  String get commonSearch => 'Cerca';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get languageSystem => 'Come il dispositivo';

  @override
  String get languageSubtitle =>
      'La lingua di menu e pulsanti. La traduzione della Bibbia si sceglie a parte.';

  @override
  String get homeWotdUnavailableNow =>
      'La parola del giorno non è disponibile al momento.';

  @override
  String get spaceCouldNotFinishPlain => 'Impossibile completare. Riprova.';

  @override
  String get readTranslationsLoadErrorPlain =>
      'Impossibile caricare le traduzioni.';

  @override
  String get readDeleteTranslationBody =>
      'Potrai riaverla in qualsiasi momento dall\'elenco delle traduzioni.';

  @override
  String get readDeleteFailedPlain => 'Impossibile eliminarla. Riprova.';

  @override
  String get readCrossRefsLoadErrorPlain =>
      'Impossibile caricare i riferimenti incrociati.';

  @override
  String get readVerseLoadErrorPlain => 'Impossibile caricare questo versetto.';

  @override
  String get searchClearRecentTitle => 'Cancellare le ricerche recenti?';

  @override
  String get searchClearRecentBody =>
      'Le ricerche recenti verranno rimosse da questo dispositivo.';

  @override
  String get searchClearRecentConfirm => 'Cancella';

  @override
  String readHighlightsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count evidenziazioni rimosse',
      one: 'Evidenziazione rimossa',
    );
    return '$_temp0';
  }

  @override
  String readVersesHighlighted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versetti evidenziati',
      one: 'Versetto evidenziato',
    );
    return '$_temp0';
  }

  @override
  String readBookmarksRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segnalibri rimossi',
      one: 'Segnalibro rimosso',
    );
    return '$_temp0';
  }

  @override
  String readVersesBookmarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versetti aggiunti ai segnalibri',
      one: 'Versetto aggiunto ai segnalibri',
    );
    return '$_temp0';
  }

  @override
  String get storiesLoadFailed => 'Impossibile caricare le storie.';

  @override
  String get studyEntriesLoadFailed => 'Impossibile caricare le voci.';

  @override
  String get studyDictionaryLoadFailed => 'Impossibile caricare il dizionario.';

  @override
  String get studyEntryLoadFailed => 'Impossibile caricare questa voce.';

  @override
  String get studyOpenScreenFailed => 'Impossibile aprire questa schermata.';

  @override
  String get studyWordUnsaved => 'Rimossa dalle parole salvate';

  @override
  String get plansBuilderSaveFailed => 'Impossibile salvare il piano.';

  @override
  String get plansBuilderLoadFailed =>
      'Impossibile preparare il creatore di piani.';

  @override
  String get plansDetailLoadFailed => 'Impossibile caricare questo piano.';

  @override
  String get plansTrackRemoved => 'Percorso rimosso';

  @override
  String get yourSpaceBookmarkRemoved => 'Segnalibro rimosso';

  @override
  String get yourSpaceHighlightRemoved => 'Evidenziazione rimossa';

  @override
  String get onboardingTagline => 'Le Scritture, senza distrazioni.';

  @override
  String get onboardingPickLanguage => 'Scegli la tua lingua';

  @override
  String get onboardingLanguageHint =>
      'Puoi cambiarla in qualsiasi momento nelle Impostazioni.';

  @override
  String get onboardingBibleTitle => 'La tua Bibbia';

  @override
  String get onboardingBibleBody =>
      'Scegli la traduzione che leggi di più. Puoi affiancarne una seconda.';

  @override
  String onboardingParallel(String name) {
    return 'Mostra anche $name a fianco';
  }

  @override
  String get onboardingPrimaryVersion => 'Traduzione principale';

  @override
  String get onboardingSecondaryVersion => 'Seconda traduzione';

  @override
  String get onboardingSecondaryDesc =>
      'Mostrata a fianco della tua Bibbia principale nella vista parallela';

  @override
  String get onboardingLookTitle => 'Leggi comodamente';

  @override
  String get onboardingLookBody =>
      'Scegli il colore della pagina, il carattere e la dimensione del testo. Potrai regolare tutto in seguito.';

  @override
  String get onboardingThemeDaily => 'Rotazione giornaliera';

  @override
  String get onboardingThemeDailyDesc =>
      'Cambia ogni giorno per riflettere i ricchi temi delle Scritture';

  @override
  String get onboardingFontFamily => 'Stile del carattere';

  @override
  String get onboardingShuffleHint => 'Tocca per mescolare';

  @override
  String get onboardingThemeLight => 'Chiaro';

  @override
  String get onboardingThemeSepia => 'Seppia';

  @override
  String get onboardingThemeDark => 'Scuro';

  @override
  String get onboardingTextSize => 'Dimensione del testo';

  @override
  String get onboardingPreviewVerse =>
      'Nel principio era la Parola, e la Parola era presso Dio, e la Parola era Dio.';

  @override
  String get onboardingPreviewRef => 'Giovanni 1:1';

  @override
  String get onboardingFeaturesTitle => 'Tutto per il tuo cammino quotidiano';

  @override
  String get onboardingFeatureWordTitle => 'La Parola, semplicemente';

  @override
  String get onboardingFeatureWordBody =>
      'Leggi senza distrazioni, con evidenziazioni, note e segnalibri.';

  @override
  String get onboardingFeaturePlansTitle => 'Piani di lettura';

  @override
  String get onboardingFeaturePlansBody =>
      'Cronologici, tematici o personali — con promemoria discreti.';

  @override
  String get onboardingFeatureStudyTitle => 'Studio approfondito';

  @override
  String get onboardingFeatureStudyBody =>
      'Commentari, dizionario, Strong e mappe, accanto al testo.';

  @override
  String get onboardingFeatureSyncTitle => 'Al sicuro';

  @override
  String get onboardingFeatureSyncBody =>
      'Accedi quando vuoi per sincronizzare i tuoi dispositivi. Per leggere non serve un account.';

  @override
  String get onboardingBegin => 'Inizia a leggere';

  @override
  String onboardingStep(int current, int total) {
    return 'Passo $current di $total';
  }

  @override
  String get onboardingReminderTitle => 'Un promemoria quotidiano';

  @override
  String get onboardingReminderBody =>
      'Un piccolo promemoria all\'ora che scegli aiuta a creare un\'abitudine quotidiana. Solo per la lettura — mai pubblicità.';

  @override
  String get onboardingReminderToggle => 'Ricordami di leggere ogni giorno';

  @override
  String get onboardingReminderTime => 'Ora del promemoria';

  @override
  String get onboardingReminderPermission =>
      'Il telefono chiederà il permesso di mostrare notifiche. Potrai cambiarlo nelle Impostazioni.';

  @override
  String get onboardingAccountTitle => 'Tieni al sicuro le tue note';

  @override
  String get onboardingAccountBody =>
      'L\'accesso è facoltativo. L\'app funziona completamente offline senza account. Con un account, evidenziazioni, note, segnalibri e piani vengono salvati e sincronizzati tra i tuoi dispositivi.';

  @override
  String onboardingSignedInAs(String name) {
    return 'Accesso eseguito come $name';
  }

  @override
  String get onboardingNotNow => 'Non ora';

  @override
  String get planFlowEmptyTitle => 'Leggi la Bibbia con un piano';

  @override
  String get planFlowEmptyBody => 'Pochi capitoli al giorno, al tuo ritmo.';

  @override
  String get planFlowPickPlan => 'Scegli un piano';

  @override
  String get planFlowAllPlans => 'Tutti i piani';

  @override
  String planFlowYourPlans(int count) {
    return 'I tuoi piani · $count attivi';
  }

  @override
  String planFlowTodayDay(int day) {
    return 'Oggi · Giorno $day';
  }

  @override
  String planFlowCatchUpDay(int day) {
    return 'Recupero · Giorno $day';
  }

  @override
  String get planFlowDoneToday => 'Fatto per oggi ✓';

  @override
  String planFlowNextDay(int day) {
    return 'Prossimo · Giorno $day';
  }

  @override
  String get planFlowReadToday => 'Leggi oggi';

  @override
  String planFlowReadDay(int day) {
    return 'Leggi il giorno $day';
  }

  @override
  String get planFlowReadAhead => 'Leggi in anticipo';

  @override
  String get planFlowPlanComplete => 'Piano completato';

  @override
  String get planFlowPlanCompleteBody =>
      'Hai letto ogni giorno di questo piano.';

  @override
  String get planFlowStartAndRead => 'Inizia e leggi il giorno 1';

  @override
  String planFlowStartOn(String date) {
    return 'Inizia il $date';
  }

  @override
  String get planFlowStartsToday => 'Inizia oggi';

  @override
  String planFlowStartsOn(String date) {
    return 'Inizia il $date';
  }

  @override
  String get planFlowChangeDate => 'Cambia data';

  @override
  String planFlowShowEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostra $count giorni precedenti',
      one: 'Mostra 1 giorno precedente',
    );
    return '$_temp0';
  }

  @override
  String get planFlowPace => 'Ritmo';

  @override
  String planFlowFinishDay(int day) {
    return 'Completa il giorno $day';
  }

  @override
  String get planFlowMarkDayComplete => 'Segna il giorno come completato';

  @override
  String planFlowUpNext(String label) {
    return 'Prossimo: $label';
  }

  @override
  String planFlowReaderSubtitle(int day, String plan) {
    return 'Giorno $day · $plan';
  }

  @override
  String planFlowPassages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brani',
      one: '1 brano',
    );
    return '$_temp0';
  }

  @override
  String get planFlowMyPlans => 'I miei piani';

  @override
  String get plansContinueReading => 'Continua a leggere';

  @override
  String get plansResume => 'Riprendi';

  @override
  String plansDayCompleteCelebration(int day) {
    return 'Piano di lettura\nGiorno $day completato!';
  }

  @override
  String plansCalendarDayComplete(String label) {
    return '$label, lettura completata';
  }

  @override
  String plansCalendarDayToday(String label) {
    return '$label, oggi';
  }

  @override
  String get plansDailyVerses => 'Versetti del giorno';

  @override
  String get plansToday => 'Oggi';

  @override
  String get plansYesterday => 'Ieri';

  @override
  String plansDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni fa',
      one: '1 giorno fa',
    );
    return '$_temp0';
  }

  @override
  String get plansHello => 'Ciao,';

  @override
  String plansSlotsFull(int count) {
    return 'Tutti i $count posti per i piani sono occupati. Metti in pausa un piano per liberarne uno: i progressi restano salvati.';
  }

  @override
  String get plansPausedSnack =>
      'Piano in pausa: tutti i progressi restano salvati.';

  @override
  String get plansBrowseToStart =>
      'Sfoglia Letture per iniziare il tuo primo piano.';

  @override
  String get plansFriend => 'amico';

  @override
  String get plansTitle => 'Piani';

  @override
  String get plansTabReading => 'Letture';

  @override
  String get plansTabBooks => 'Libri';

  @override
  String plansTabMyPlans(int count) {
    return 'I miei piani ($count)';
  }

  @override
  String get plansNotStarted => 'Non iniziato';

  @override
  String plansPercentDone(int percent) {
    return '$percent% fatto';
  }

  @override
  String get plansOpen => 'Apri';

  @override
  String get plansPaused => 'In pausa';

  @override
  String get plansStarted => 'Iniziato';

  @override
  String plansDaysBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni indietro',
      one: '1 giorno indietro',
    );
    return '$_temp0';
  }

  @override
  String get plansCaughtUp => 'In pari';

  @override
  String get plansComplete => 'Completato';

  @override
  String plansDayOfTotalLeft(int current, int total, int left) {
    return 'Giorno $current di $total · ne mancano $left';
  }

  @override
  String get plansPauseKeepsProgress => 'Pausa (mantiene i progressi)';

  @override
  String get plansStart => 'Inizia';

  @override
  String plansPresetBookTitle(String book, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$book in $days giorni',
      one: '$book in 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String plansPresetGospelsTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Vangeli in $days giorni',
      one: 'Vangeli in 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String plansPresetSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni · tocca per creare',
      one: '1 giorno · tocca per creare',
    );
    return '$_temp0';
  }

  @override
  String get plansYourCustomPlans => 'I TUOI PIANI PERSONALIZZATI';

  @override
  String plansDayOfTotal(int day, int total) {
    return 'Giorno $day di $total';
  }

  @override
  String get plansCustomPlan => 'Piano personalizzato';

  @override
  String get plansNoActivePlans => 'Nessun piano attivo';

  @override
  String get plansNoActivePlansBody =>
      'Sfoglia Letture o Libri per iniziare il tuo primo piano.';

  @override
  String get plansLetsRead => 'Leggiamo';

  @override
  String get plansVerseOfTheDay => 'Versetto del giorno';

  @override
  String get plansOpenTodaysReading => 'Apri la lettura di oggi';

  @override
  String get plansLastDayOfYear => 'Ultimo giorno dell\'anno';

  @override
  String plansDaysLeftInYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mancano $count giorni alla fine dell\'anno',
      one: 'Manca 1 giorno alla fine dell\'anno',
    );
    return '$_temp0';
  }

  @override
  String get plansCustomPlanDefaultTitle => 'Piano personalizzato';

  @override
  String get plansCustom => 'Personalizzato';

  @override
  String plansBookRange(String start, String end) {
    return 'Da $start a $end';
  }

  @override
  String get plansBuilderTitle => 'Crea il tuo piano';

  @override
  String get plansPlanName => 'Nome del piano';

  @override
  String get plansPlanNameHint => 'es. Genesi in 30 giorni';

  @override
  String get plansReadingTracks => 'Percorsi di lettura';

  @override
  String get plansAddTrack => 'Aggiungi percorso';

  @override
  String get plansTracksOverlap =>
      'I percorsi si sovrappongono: i versetti in comune sono contati una sola volta nell\'anteprima qui sotto.';

  @override
  String get plansDuration => 'Durata';

  @override
  String plansDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get plansDaysSuffix => 'giorni';

  @override
  String get plansStartRestReminder => 'Inizio, riposo e promemoria';

  @override
  String get plansStartDate => 'Data di inizio';

  @override
  String get plansRestDaysNeutral => 'Giorni di riposo (neutri)';

  @override
  String get plansNone => 'Nessuno';

  @override
  String get plansDailyReminder => 'Promemoria giornaliero';

  @override
  String plansReminderAt(String time) {
    return 'Alle $time';
  }

  @override
  String get plansOff => 'Disattivato';

  @override
  String get plansLivePreview => 'Anteprima dal vivo';

  @override
  String get plansPreviewEmpty =>
      'Aggiungi almeno un percorso qui sopra per vedere il programma bilanciato.';

  @override
  String get plansWordBalanced =>
      'Bilanciato per parole · rispetta le pericopi';

  @override
  String plansPreviewSummary(int days, int readingDays) {
    return '$days giorni · $readingDays giorni di lettura';
  }

  @override
  String plansClampedNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Il ritmo più leggero per questa selezione è di $days giorni. Titolo aggiornato alla durata reale.',
      one:
          'Il ritmo più leggero per questa selezione è di 1 giorno. Titolo aggiornato alla durata reale.',
    );
    return '$_temp0';
  }

  @override
  String plansPreviewDay(int day, String portions) {
    return 'Giorno $day: $portions';
  }

  @override
  String plansMoreBalancedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Altri $count giorni bilanciati',
      one: 'Ancora 1 giorno bilanciato',
    );
    return '$_temp0';
  }

  @override
  String get plansSaving => 'Salvataggio…';

  @override
  String get plansGenerateAndSave => 'Crea e salva il piano →';

  @override
  String get plansNameAndTrackHint =>
      'Dai un nome al piano e aggiungi almeno un percorso per continuare.';

  @override
  String get plansStartEllipsis => 'Inizio…';

  @override
  String get plansEndEllipsis => 'Fine…';

  @override
  String get plansStartLabel => 'INIZIO';

  @override
  String get plansEndLabel => 'FINE';

  @override
  String get plansRemoveTrack => 'Rimuovi percorso';

  @override
  String plansRestChip(String days) {
    return 'Riposo $days';
  }

  @override
  String plansRebasedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Programma spostato di $count giorni di lettura. I giorni completati restano invariati.',
      one:
          'Programma spostato di 1 giorno di lettura. I giorni completati restano invariati.',
    );
    return '$_temp0';
  }

  @override
  String get plansPlan => 'Piano';

  @override
  String get plansNoReadingsYet => 'Questo piano non ha ancora letture.';

  @override
  String plansReadingDaysWeeks(int days, int weeks) {
    return '$days giorni di lettura · ~$weeks settimane';
  }

  @override
  String get plansBeginPlan => 'Inizia il piano';

  @override
  String get plansStartDayOne => 'Inizia il giorno 1 →';

  @override
  String get plansStartDateNote => 'Il piano inizia nella data che scegli.';

  @override
  String get plansScheduleLabel => 'PROGRAMMA';

  @override
  String get plansNoReadings => 'Nessuna lettura';

  @override
  String plansPercentComplete(int percent) {
    return '$percent% completato';
  }

  @override
  String get plansFlexible => 'Flessibile';

  @override
  String get plansScheduled => 'Programmato';

  @override
  String plansBehindChip(int count) {
    return '$count indietro';
  }

  @override
  String get plansOnTrack => 'In linea';

  @override
  String get plansFlexibleHelp =>
      'Flessibile: leggi prima il giorno non letto più vecchio. I giorni persi non si accumulano.';

  @override
  String get plansScheduledHelp =>
      'Programmato: ogni data ha il suo giorno di lettura. I giorni persi contano come ritardo: recuperali qui sotto.';

  @override
  String get plansCatchUp => 'Recupera';

  @override
  String plansBehindBy(int count, int day) {
    return 'Indietro di $count: il più vecchio non letto è il giorno $day.';
  }

  @override
  String get plansCatchUpHelp =>
      'Segnare i giorni come letti registra i progressi. Spostare, invece, posticipa il resto del programma.';

  @override
  String get plansGoToOldest => 'Vai al più vecchio';

  @override
  String get plansMarkOldestDone => 'Segna il più vecchio letto';

  @override
  String get plansAllPreviousDone => 'Tutto ciò che precede oggi è già fatto.';

  @override
  String plansPreviousMarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni precedenti segnati come letti.',
      one: '1 giorno precedente segnato come letto.',
    );
    return '$_temp0';
  }

  @override
  String get plansMarkAllPrevious => 'Segna tutti i precedenti';

  @override
  String plansRebaseDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sposta di +$count giorni',
      one: 'Sposta di +1 giorno',
    );
    return '$_temp0';
  }

  @override
  String plansReadingsHeader(int count) {
    return 'LETTURE · $count GIORNI';
  }

  @override
  String get plansJourneyMap => 'Mappa del percorso';

  @override
  String get plansJumpToToday => 'Vai a oggi';

  @override
  String plansDayN(int day) {
    return 'Giorno $day';
  }

  @override
  String get plansLegendDone => 'Letto';

  @override
  String get plansLegendToday => 'Oggi = cerchio';

  @override
  String get plansLegendMissed => 'Saltato';

  @override
  String plansReminderAtTime(String time) {
    return 'Promemoria · $time';
  }

  @override
  String get plansReminderOff => 'Promemoria disattivato';

  @override
  String get plansReminderHelp =>
      'Notifica per questo piano: salta automaticamente i giorni di riposo.';

  @override
  String get plansRestDays => 'Giorni di riposo';

  @override
  String get plansNoRestDays => 'Nessun giorno di riposo';

  @override
  String get plansSettings => 'Impostazioni del piano';

  @override
  String get plansAboutEllipsis => 'Informazioni sul piano…';

  @override
  String get plansAbout => 'Informazioni sul piano';

  @override
  String get plansChangeStartDate => 'Cambia data di inizio…';

  @override
  String plansRestDaysValue(String days) {
    return 'Giorni di riposo: $days';
  }

  @override
  String get plansRestDaysHelp => 'Tocca per scegliere i giorni';

  @override
  String get plansRestartFromDayOne => 'Ricomincia dal giorno 1…';

  @override
  String get plansRestartTitle => 'Ricominciare il piano?';

  @override
  String get plansRestartBody => 'I giorni completati verranno azzerati.';

  @override
  String get plansRestart => 'Ricomincia';

  @override
  String get plansMarkUnread => 'Segna come non letto';

  @override
  String get plansMarkRead => 'Segna come letto';

  @override
  String get plansRestAndReflect => 'Riposo e riflessione';

  @override
  String get plansRestDayBody =>
      'Un giorno di riposo: nessuna lettura prevista oggi.';

  @override
  String get plansDayDetailHelp =>
      'Tocca un brano per aprirlo. Spuntalo man mano che leggi.';

  @override
  String plansMilestone(int count) {
    return '$count letture completate: continua così!';
  }

  @override
  String get plansCompletedTapToUndo => 'Completato: tocca per annullare';

  @override
  String plansMarkDayRead(int day, int checked, int total) {
    return 'Segna il giorno $day come letto ✓ ($checked/$total brani)';
  }

  @override
  String get todayGoodMorning => 'Buongiorno';

  @override
  String get todayGoodAfternoon => 'Buon pomeriggio';

  @override
  String get todayGoodEvening => 'Buonasera';

  @override
  String get todayGoodNight => 'Buonanotte';

  @override
  String get todayStreakNudge => 'Leggi oggi per non perdere la tua serie!';

  @override
  String get todayNotificationsSoon => 'Notifiche in arrivo!';

  @override
  String get todaySectionResume => 'RIPRENDI';

  @override
  String get todaySectionStreak => 'SERIE DI LETTURA';

  @override
  String get todaySectionLatestNote => 'ULTIMA NOTA';

  @override
  String get todaySectionQuickActions => 'AZIONI RAPIDE';

  @override
  String get todaySectionReminders => 'PROMEMORIA GIORNALIERI';

  @override
  String get todayTagline => 'Il tuo momento quotidiano di pace.';

  @override
  String get todayNoNotesYet => 'Ancora nessuna nota';

  @override
  String get todayWriteFirstNote => 'Scrivi la tua prima nota per vederla qui.';

  @override
  String get todayViewAllNotes => 'Vedi tutte le note';

  @override
  String todayStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie di $count giorni',
      one: 'Serie di 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String todayDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mancano $count giorni alla fine dell\'anno.',
      one: 'Manca 1 giorno alla fine dell\'anno.',
    );
    return '$_temp0';
  }

  @override
  String get todayActionRead => 'Leggi';

  @override
  String get todayActionSurprise => 'Sorprendimi';

  @override
  String get todayActionReadingPlan => 'Piano di lettura';

  @override
  String get todayActionYourSpace => 'Il tuo spazio';

  @override
  String get todayVotdArchive => 'Archivio del versetto del giorno';

  @override
  String get todayVotdArchiveBody => 'Recupera i versetti dei giorni persi.';

  @override
  String get todayVotdArchiveExplore => 'Esplora i versetti dei giorni passati';

  @override
  String get readActionBookmark => 'Segnalibro';

  @override
  String get readActionNote => 'Nota';

  @override
  String get readActionNotes => 'Note';

  @override
  String get readActionEditNote => 'Modifica nota';

  @override
  String get readActionCommentary => 'Commento';

  @override
  String get readActionRelated => 'Correlati';

  @override
  String get readActionHighlight => 'Evidenzia';

  @override
  String get readActionStudy => 'Studia';

  @override
  String get readActionSaved => 'Salvato';

  @override
  String get readActionSelectText => 'Seleziona testo';

  @override
  String get readVerseActions => 'Azioni sul versetto';

  @override
  String readVersesSelected(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versetti selezionati',
      one: '1 versetto selezionato',
    );
    return '$_temp0 · $where';
  }

  @override
  String get readCommentaryHint =>
      'Tocca la lampadina accanto a un versetto per il commento';

  @override
  String get readPassageNotFound => 'Passo non trovato.';

  @override
  String get readChapterCommentary => 'Leggi il commento al capitolo';

  @override
  String readEndOfChapter(String reference) {
    return '· Fine di $reference ·';
  }

  @override
  String get readPreviousChapter => '‹ Precedente';

  @override
  String get readNextChapter => 'Successivo ›';

  @override
  String readPlanDay(int day) {
    return 'Piano di lettura · Giorno $day';
  }

  @override
  String get readPlanCompleted => 'Piano completato! Congratulazioni! 🎉';

  @override
  String readMarkDoneContinue(String book, int chapter) {
    return 'Segna $book $chapter come letto e continua';
  }

  @override
  String get readNone => 'Nessuno';

  @override
  String readBookFallback(int number) {
    return 'Libro $number';
  }

  @override
  String get readRelatedVerses => 'Versetti correlati';

  @override
  String get readNoCrossRefs =>
      'Nessun riferimento incrociato per questo versetto.';

  @override
  String get readCrossRefsComingSoon =>
      'I riferimenti incrociati saranno disponibili\ncon il prossimo aggiornamento.';

  @override
  String get readVerseUnavailable => 'Versetto non disponibile';

  @override
  String get readLoading => 'Caricamento…';

  @override
  String get readVerseNotFound => 'Versetto non trovato.';

  @override
  String get readBookOrChapterNotFound => 'Libro o capitolo non trovato.';

  @override
  String get readOpenInRead => 'Apri in Leggi';

  @override
  String get readBookNotFound => 'Impossibile trovare il libro indicato.';

  @override
  String get readTestament => 'Testamento';

  @override
  String get readBook => 'Libro';

  @override
  String get readChapter => 'Capitolo';

  @override
  String get readVerse => 'Versetto';

  @override
  String get readSelectBook => 'Scegli libro';

  @override
  String get readOtShort => 'AT';

  @override
  String get readNtShort => 'NT';

  @override
  String get readOldTestament => 'Antico Testamento';

  @override
  String get readNewTestament => 'Nuovo Testamento';

  @override
  String get readOldTestamentTwoLine => 'Antico\nTestamento';

  @override
  String get readNewTestamentTwoLine => 'Nuovo\nTestamento';

  @override
  String get readStoriesSections => 'Racconti e sezioni';

  @override
  String get readAllVerses => 'Tutti i versetti';

  @override
  String get readTranslationTitle => 'Traduzione della Bibbia';

  @override
  String get readLayoutTitle => 'Layout di lettura';

  @override
  String get readLayoutSingle => 'Singola';

  @override
  String get readLayoutBilingual => 'Bilingue';

  @override
  String get readLayoutParallel => 'Parallela';

  @override
  String get readLayoutChips => 'Chip';

  @override
  String get readLayoutSingleDesc => 'Una traduzione';

  @override
  String get readLayoutBilingualDesc =>
      'Due traduzioni sovrapposte per versetto';

  @override
  String get readLayoutParallelDesc => 'Due traduzioni in colonne affiancate';

  @override
  String get readLayoutChipsDesc =>
      'Tocca un versetto per cambiarne la traduzione';

  @override
  String get readPrimary => 'Principale';

  @override
  String get readSecondary => 'Secondaria';

  @override
  String readTranslationDeleted(String name) {
    return '$name eliminata.';
  }

  @override
  String readDeleteTranslation(String name) {
    return 'Elimina $name';
  }

  @override
  String get readKjvAlwaysAvailable => 'Sempre disponibile · base dell’app';

  @override
  String get readCannotDeleteBackbone => 'Non eliminabile — base dell’app';

  @override
  String get readAvailableToAdd => 'DISPONIBILI DA AGGIUNGERE';

  @override
  String get readNoInternet =>
      'Nessuna connessione — riprova quando sei online.';

  @override
  String get readRestoreFailed => 'Ripristino non riuscito';

  @override
  String get readDownloadFailed => 'Download non riuscito';

  @override
  String get readRestoreOffline => 'ripristino offline';

  @override
  String get homeVerseOfTheDay => 'VERSETTO DEL GIORNO';

  @override
  String get homeDevotional => 'MEDITAZIONE';

  @override
  String get homeCommentary => 'COMMENTO';

  @override
  String get homeGoDeeper => 'Approfondisci';

  @override
  String get homeReadFullDefinition => 'Leggi la definizione';

  @override
  String get homeWordOfTheDayHeading => 'PAROLA DEL GIORNO';

  @override
  String get homeWordOfTheDay => 'Parola del giorno';

  @override
  String get homeWotdEmpty =>
      'Nessuna parola scelta per oggi — riprova più tardi.';

  @override
  String get homeStoryOfTheDayHeading => 'STORIA DEL GIORNO';

  @override
  String get homeStoryOfTheDay => 'Storia del giorno';

  @override
  String get homeReadStory => 'Leggi la storia';

  @override
  String get homeStoryEmpty => 'Nessuna storia disponibile per oggi.';

  @override
  String get navHome => 'Home';

  @override
  String get navRead => 'Leggi';

  @override
  String get navStudy => 'Studio';

  @override
  String get navSearch => 'Cerca';

  @override
  String get navExitTitle => 'Uscire da The Blessed Bible?';

  @override
  String get navExitMessage => 'Vuoi davvero uscire dall’app?';

  @override
  String get navExit => 'Esci';

  @override
  String get navCastLotsError => 'Impossibile tirare a sorte — riprova.';

  @override
  String get navCastingLots => 'Tirando a sorte…';

  @override
  String get searchHint => 'Cerca versetti, commenti…';

  @override
  String get searchAllBooks => 'Tutti i libri';

  @override
  String get searchFilterMyNotes => 'Le mie note';

  @override
  String get searchEmptyPrompt =>
      'Cerca nella Bibbia, nei commenti\ne nelle tue note';

  @override
  String get searchRecentSearches => 'RICERCHE RECENTI';

  @override
  String get searchClear => 'CANCELLA';

  @override
  String get searchRecentPlaces => 'LUOGHI RECENTI';

  @override
  String get searchMostRead => 'I PIÙ LETTI';

  @override
  String get searchNoResults => 'Nessun risultato';

  @override
  String get searchTopResults => 'Primi 100 risultati';

  @override
  String searchResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati trovati',
      one: '1 risultato trovato',
    );
    return '$_temp0';
  }

  @override
  String searchSectionDictionary(int count) {
    return 'DIZIONARIO ($count)';
  }

  @override
  String searchSectionStories(int count) {
    return 'RACCONTI ($count)';
  }

  @override
  String searchSectionJumpTo(int count) {
    return 'VAI A ($count)';
  }

  @override
  String searchSectionVerses(int count) {
    return 'VERSETTI ($count)';
  }

  @override
  String searchSectionCommentary(int count) {
    return 'COMMENTI ($count)';
  }

  @override
  String searchSectionMyNotes(int count) {
    return 'LE MIE NOTE ($count)';
  }

  @override
  String get searchCopied => 'Copiato negli appunti';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsTabGeneral => 'Generali';

  @override
  String get settingsTabNavigation => 'Navigazione';

  @override
  String get settingsTabReminders => 'Promemoria';

  @override
  String get settingsTabInfo => 'Info';

  @override
  String get settingsWidgetsTitle => 'Widget della schermata Home';

  @override
  String get settingsWidgetsSubtitle =>
      'Gradienti, trasparenza e anteprima dal vivo';

  @override
  String get settingsStartPageTitle => 'Pagina iniziale';

  @override
  String get settingsStartPageSubtitle =>
      'Scegli la pagina mostrata all\'avvio';

  @override
  String get settingsPageHome => 'Home';

  @override
  String get settingsPageRead => 'Leggi';

  @override
  String get settingsPageStudy => 'Studio';

  @override
  String get settingsPageSearch => 'Cerca';

  @override
  String get settingsImmersiveReading => 'Lettura immersiva';

  @override
  String get settingsImmersiveOffTitle => 'Ancorato (disattivo)';

  @override
  String get settingsImmersiveOffSubtitle =>
      'La navigazione resta sempre visibile';

  @override
  String get settingsImmersivePartialTitle => 'Guidato (parziale)';

  @override
  String get settingsImmersivePartialSubtitle =>
      'Nasconde la navigazione, ma lascia la pillola libro e capitolo';

  @override
  String get settingsImmersiveFullTitle => 'Acque profonde (totale)';

  @override
  String get settingsImmersiveFullSubtitle =>
      'Immersione totale. Tutti i menu si nascondono scorrendo';

  @override
  String get settingsShowStrongs => 'Mostra numeri Strong';

  @override
  String get settingsShowStrongsSubtitle =>
      'Mostra i codici ebraici/greci accanto al testo KJV per lo studio delle parole';

  @override
  String get settingsStrongsGetIt => 'Scarica';

  @override
  String get settingsStrongsMarkerAsterisk => 'Asterisco (*)';

  @override
  String get settingsStrongsMarkerChain => 'Catena (🔗)';

  @override
  String get settingsStrongsMarkerNumber => 'Numero (H1234)';

  @override
  String get settingsReadingSpeed => 'Velocità di lettura';

  @override
  String get settingsReadingSpeedSubtitle =>
      'Ritmo stimato dei piani (parole al minuto)';

  @override
  String get settingsSpeedRelaxed => 'Rilassato';

  @override
  String get settingsSpeedStandard => 'Standard';

  @override
  String get settingsSpeedBrisk => 'Svelto';

  @override
  String get settingsDictUnderlines => 'Sottolineature del dizionario';

  @override
  String get settingsDictUnderlinesSubtitle =>
      'Sottolineatura a punti di termini biblici e parole arcaiche';

  @override
  String get settingsUnderlineScope => 'Ambito sottolineatura';

  @override
  String get settingsScopeNamesTitle => 'Solo nomi e termini';

  @override
  String get settingsScopeNamesSubtitle =>
      'Nomi propri e concetti biblici specifici';

  @override
  String get settingsScopeTrickyTitle =>
      'Nomi + parole insidiose (consigliato)';

  @override
  String get settingsScopeTrickySubtitle =>
      'Include parole arcaiche dal significato cambiato (es. let, prevent)';

  @override
  String get settingsScopeEverythingTitle => 'Tutto';

  @override
  String get settingsScopeEverythingSubtitle =>
      'Evidenzia tutta la grammatica arcaica (es. thee, thou, hath, unto)';

  @override
  String get settingsScopeDifficultTitle => 'Solo parole difficili';

  @override
  String get settingsScopeDifficultSubtitle =>
      'Parole arcaiche, fuorvianti e contestate — quelle semplici come god e son restano senza segno';

  @override
  String get settingsScopeDifficultNamesTitle => 'Difficili + nomi';

  @override
  String get settingsScopeDifficultNamesSubtitle =>
      'Aggiunge persone e luoghi (es. Davide, Gerusalemme) alle parole difficili';

  @override
  String get settingsOtherEnglishVersions => 'Altre versioni inglesi';

  @override
  String get settingsContestedOnlyTitle => 'Solo parole contestate';

  @override
  String get settingsContestedOnlySubtitle =>
      'BBE, WEB e altre versioni inglesi segnano le parole dibattute (es. hell, baptism)';

  @override
  String get settingsFollowScopeTitle => 'Segui l\'ambito sottolineatura';

  @override
  String get settingsFollowScopeSubtitle =>
      'Stessa marcatura della KJV in ogni versione inglese';

  @override
  String get settingsNoUnderlinesTitle => 'Nessuna sottolineatura';

  @override
  String get settingsNoUnderlinesSubtitle =>
      'Le altre versioni inglesi non mostrano segni';

  @override
  String get settingsPopupStyle => 'Stile popup';

  @override
  String get settingsPopupStyleSubtitle =>
      'Come vengono mostrate definizioni e numeri Strong';

  @override
  String get settingsPopupFloating => 'Fluttuante';

  @override
  String get settingsPopupBottomSheet => 'Pannello inferiore';

  @override
  String get settingsSavedInMyLanguage => 'Elementi salvati nella mia lingua';

  @override
  String get settingsSavedInMyLanguageSubtitle =>
      'Mostra segnalibri, evidenziazioni e versetti commentati nella traduzione principale';

  @override
  String get settingsTranslationChips =>
      'Opzioni di traduzione sugli elementi salvati';

  @override
  String get settingsTranslationChipsSubtitle =>
      'Aggiunge una riga compatta per leggere i versetti salvati in altre traduzioni';

  @override
  String get settingsVerseActionStyle => 'Stile azioni versetto';

  @override
  String get settingsVerseActionStyleSubtitle =>
      'Pannello (compatto) o Classico (barra alta) alla selezione; Radiale mette il menu a pressione lunga in cerchio';

  @override
  String get settingsCommentaryStyle => 'Stile del commento';

  @override
  String get settingsCommentaryStyleSubtitle =>
      'Impaginazione dei commenti. Classico mantiene il design precedente.';

  @override
  String get settingsCommentaryRefined => 'Rifinito';

  @override
  String get settingsCommentaryClassic => 'Classico';

  @override
  String get settingsActionSheet => 'Pannello';

  @override
  String get settingsActionClassic => 'Classico';

  @override
  String get settingsActionMinimal => 'Minimale';

  @override
  String get settingsActionRaindrop => 'Goccia';

  @override
  String get settingsActionRadial => 'Radiale';

  @override
  String get settingsKeepAwake => 'Schermo sempre acceso';

  @override
  String get settingsKeepAwakeSubtitle =>
      'Impedisce lo standby durante la lettura';

  @override
  String get settingsRestartOnboarding => 'Riavvia la configurazione';

  @override
  String get settingsRestartOnboardingSubtitle =>
      'Ripeti la configurazione iniziale';

  @override
  String get settingsRestartOnboardingDialogTitle =>
      'Riavviare la configurazione?';

  @override
  String get settingsRestartOnboardingDialogBody =>
      'Verrà ripetuta la configurazione iniziale. Tema, carattere e traduzione restano invariati se non li cambi.';

  @override
  String get settingsRestart => 'Riavvia';

  @override
  String get settingsAppearanceText => 'Aspetto e testo';

  @override
  String get settingsAppearanceTextSubtitle =>
      'Tema, caratteri, dimensioni e colori';

  @override
  String get settingsSabbathTitle => 'Promemoria tramonto del venerdì';

  @override
  String get settingsSabbathSubtitle => 'Accogli il sabato al tramonto locale.';

  @override
  String get settingsLocation => 'Posizione';

  @override
  String get settingsLocationNotSet => 'Non impostata (tocca per impostare)';

  @override
  String get settingsDailyReminderTitle => 'Promemoria lettura quotidiana';

  @override
  String get settingsDailyReminderSubtitle =>
      'Un invito quotidiano a dedicare tempo alla Parola.';

  @override
  String get settingsTime => 'Orario';

  @override
  String get settingsWeeklyReminderTitle => 'Promemoria settimanale';

  @override
  String get settingsWeeklyReminderSubtitle =>
      'Scegli un giorno e un orario ogni settimana per approfondire.';

  @override
  String get settingsDayAndTime => 'Giorno e ora';

  @override
  String get settingsChooseDay => 'Scegli il giorno';

  @override
  String get settingsShowReadingTips => 'Mostra suggerimenti di lettura';

  @override
  String get settingsShowReadingTipsSubtitle =>
      'Suggerimenti guidati per evidenziare, scorrere e altro';

  @override
  String get settingsNavSteps => 'Passaggi di navigazione';

  @override
  String get settingsNavStepsSubtitle =>
      'Quanti passaggi per arrivare a un versetto. 2: Libro → Capitolo. 3: Libro → Capitolo → Versetto. 4: Testamento → Libro → Capitolo → Versetto.';

  @override
  String get settingsAutoClose => 'Chiudi dopo l\'ultima selezione';

  @override
  String get settingsAutoCloseSubtitle =>
      'Chiude il selettore dopo l\'ultimo passaggio';

  @override
  String get settingsSelectorHeight => 'Altezza selettore libri';

  @override
  String get settingsSelectorHeightSubtitle =>
      'Quanto si apre il pannello libro/capitolo';

  @override
  String get settingsHeightHalf => 'Metà';

  @override
  String get settingsHeightFull => 'Intero';

  @override
  String get settingsAutoOpenSingle => 'Apri il risultato unico';

  @override
  String get settingsAutoOpenSingleSubtitle =>
      'Vai direttamente se la ricerca trova un solo risultato';

  @override
  String get settingsIncludeNotes => 'Includi le note personali nella ricerca';

  @override
  String get settingsIncludeNotesSubtitle =>
      'Consente di cercare nelle tue note';

  @override
  String get settingsWholeWords => 'Solo parole intere';

  @override
  String get settingsWholeWordsSubtitle =>
      'Solo parole esatte (disattiva corrispondenze parziali)';

  @override
  String get settingsFuzzySearch => 'Ricerca tollerante';

  @override
  String get settingsFuzzySearchSubtitle =>
      'Mostra anche risultati simili per refusi (es. Jhon trova John)';

  @override
  String get settingsDefaultScopes => 'Ambiti di ricerca predefiniti';

  @override
  String get settingsOldTestament => 'Antico Testamento';

  @override
  String get settingsNewTestament => 'Nuovo Testamento';

  @override
  String get settingsCommentary => 'Commento';

  @override
  String get settingsGestures => 'Gesti';

  @override
  String get settingsPullDownHome => 'Trascina giù nella Home';

  @override
  String get settingsPullDownHomeSubtitle =>
      'Trascina oltre l\'inizio per aprire Impostazioni o Aspetto';

  @override
  String get settingsPullDownOpens => 'Il trascinamento apre';

  @override
  String get settingsPullDownOpensSubtitle =>
      'Destinazione del gesto nella Home';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsSwipeLeftHome => 'Scorri a sinistra nella Home';

  @override
  String get settingsSwipeLeftHomeSubtitle =>
      'Scorri a sinistra per andare a Leggi';

  @override
  String get settingsLongPressNav =>
      'Pressione lunga per aprire la navigazione';

  @override
  String get settingsLongPressNavSubtitle =>
      'Tieni premuto il pulsante in basso a destra per aprire il selettore Libro/Capitolo.';

  @override
  String get settingsBbeNoteTitle => 'Nota sulla traduzione BBE';

  @override
  String get settingsBackup => 'Backup dei miei dati';

  @override
  String get settingsBackupSubtitle =>
      'Esporta note, evidenziazioni e impostazioni';

  @override
  String get settingsRestoreBackup => 'Ripristina da backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Importa i dati da un backup JSON';

  @override
  String get settingsRestoreBackupDialogTitle => 'Ripristina da backup';

  @override
  String get settingsRestoreHint => 'Incolla qui il backup JSON…';

  @override
  String get settingsRestore => 'Ripristina';

  @override
  String get settingsClearCache => 'Svuota cache e download';

  @override
  String get settingsClearCacheSubtitle =>
      'Libera spazio rimuovendo i file in cache';

  @override
  String get settingsNotImplemented => 'Non ancora disponibile';

  @override
  String get settingsResetSettings => 'Ripristina impostazioni';

  @override
  String get settingsResetSettingsSubtitle =>
      'Ripristina le impostazioni originali (contenuti conservati)';

  @override
  String get settingsResetDialogTitle => 'Ripristinare le impostazioni?';

  @override
  String get settingsResetDialogBody =>
      'Ripristinare tutte le impostazioni? Segnalibri, note ed evidenziazioni non saranno toccati.';

  @override
  String get settingsResetDone => 'Impostazioni ripristinate.';

  @override
  String get settingsReset => 'Ripristina';

  @override
  String get settingsVersion => 'Versione';

  @override
  String get settingsUnknown => 'Sconosciuto';

  @override
  String get settingsStorage => 'Spazio e download';

  @override
  String get settingsStorageSubtitle =>
      'Cache, traduzioni scaricate e spazio liberabile';

  @override
  String get settingsSendFeedback => 'Invia feedback';

  @override
  String get settingsCrashReports => 'Invia report di arresto';

  @override
  String get settingsCrashReportsSubtitle =>
      'Dettagli anonimi aiutano a correggere i bug. Nessuna lettura biblica, nota o contenuto personale è incluso.';

  @override
  String get settingsPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get settingsCredits => 'Crediti e fonti';

  @override
  String get settingsCreditsSubtitle =>
      'Traduzioni bibliche, commenti, dati di studio, caratteri e licenze';

  @override
  String get settingsSetSunsetLocation => 'Posizione per il tramonto';

  @override
  String get settingsCurrentLocationGps => 'Posizione attuale (GPS)';

  @override
  String get settingsUseMyLocation => 'Usa la mia posizione';

  @override
  String get settingsOrSelectCity => 'OPPURE scegli una grande città';

  @override
  String get settingsTypography => 'Tipografia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsSearchSettings => 'Impostazioni di ricerca';

  @override
  String get settingsMatchTypeHeader => 'CORRISPONDENZA';

  @override
  String get settingsExactMatch => 'Corrispondenza esatta';

  @override
  String get settingsExactMatchSubtitle => 'Solo la frase esatta';

  @override
  String get settingsScopeHeader => 'AMBITO';

  @override
  String get settingsDisabledBookFilter => 'Disattivato (filtro libro attivo)';

  @override
  String get settingsMyNotes => 'Le mie note';

  @override
  String get settingsBehaviorHeader => 'COMPORTAMENTO';

  @override
  String get settingsAutoOpenSingleShort => 'Apri risultato unico';

  @override
  String get settingsAutoOpenSingleShortSubtitle =>
      'Vai direttamente se c\'è un solo risultato';

  @override
  String get settingsBackgroundGlow => 'Attiva bagliore di sfondo';

  @override
  String get settingsBackgroundGlowSubtitle =>
      'Una luce animata discreta dietro al testo';

  @override
  String get settingsThemeGroupFoundations => 'FONDAMENTA';

  @override
  String get settingsThemeDawn => 'Alba';

  @override
  String get settingsThemeFresh => 'Fresco';

  @override
  String get settingsThemeGroupFirmament => 'FIRMAMENTO';

  @override
  String get settingsThemeSun => 'Sole';

  @override
  String get settingsThemeMoon => 'Luna';

  @override
  String get settingsThemeStars => 'Stelle';

  @override
  String get settingsThemeGroupEden => 'EDEN';

  @override
  String get settingsThemeLilies => 'Gigli';

  @override
  String get settingsThemeRoses => 'Rose';

  @override
  String get settingsThemeOlives => 'Ulivi';

  @override
  String get settingsThemeGroupSanctuary => 'SANTUARIO';

  @override
  String get settingsThemePurple => 'Porpora\nsacerdotale';

  @override
  String get settingsThemeBlue => 'Blu\nGalilea';

  @override
  String get settingsThemeRed => 'Rosso\nscarlatto';

  @override
  String get settingsSurpriseMe => 'Sorprendimi';

  @override
  String get settingsThemeOledDark => 'OLED\nscuro';

  @override
  String get settingsThemeDuskOled => 'Crepuscolo\nOLED';

  @override
  String get settingsSurfaceStyle => 'Stile superficie';

  @override
  String get settingsSurfaceStyleSubtitle =>
      'Profondità visiva e resa dei materiali';

  @override
  String get settingsSurfaceEarth => 'Terra';

  @override
  String get settingsSurfaceEarthSubtitle => 'Superficie piatta';

  @override
  String get settingsSurfaceHeaven => 'Cielo';

  @override
  String get settingsSurfaceHeavenSubtitle => 'Profondità satinata';

  @override
  String get settingsSurfacePaper => 'Carta';

  @override
  String get settingsSurfacePaperSubtitle => 'E-reader caldo';

  @override
  String get settingsSurfaceClay => 'Argilla';

  @override
  String get settingsSurfaceClaySubtitle => '3D morbido';

  @override
  String get settingsWidgetsLivePreview =>
      'Anteprima dal vivo e personalizzazione';

  @override
  String get settingsWidgetPreviewHeader => 'ANTEPRIMA WIDGET';

  @override
  String get settingsWidgetStreak => 'Serie attiva! • Obiettivo del giorno';

  @override
  String get settingsWidgetWotd => 'PAROLA DEL GIORNO';

  @override
  String get settingsWidgetVotd => 'VERSETTO DEL GIORNO';

  @override
  String get settingsWidgetBackgroundHeader => 'SFONDO E GRADIENTI';

  @override
  String get settingsWidgetContrastHeader => 'CONTRASTO TESTO';

  @override
  String get settingsWidgetTextAuto => 'Auto ✨';

  @override
  String get settingsWidgetTextDark => 'Testo scuro ☀️';

  @override
  String get settingsWidgetTextWhite => 'Testo bianco 🌙';

  @override
  String get settingsWidgetSynced =>
      'Widget sincronizzati con il nuovo stile! ✨';

  @override
  String get settingsWidgetApply => 'Applica alla schermata Home';

  @override
  String get settingsFontSizeHeader => 'DIMENSIONE';

  @override
  String get settingsFontWeightHeader => 'SPESSORE';

  @override
  String get settingsWeightLight => 'Leggero';

  @override
  String get settingsWeightRegular => 'Normale';

  @override
  String get settingsWeightMedium => 'Medio';

  @override
  String get settingsWeightBold => 'Grassetto';

  @override
  String get settingsLineSpacingHeader => 'INTERLINEA';

  @override
  String get settingsSpacingCompact => 'Compatto';

  @override
  String get settingsSpacingNormal => 'Normale';

  @override
  String get settingsMarginsHeader => 'MARGINI';

  @override
  String get settingsAlignmentHeader => 'ALLINEAMENTO';

  @override
  String get settingsAlignLeft => 'Sinistra';

  @override
  String get settingsAlignCenter => 'Centro';

  @override
  String get settingsAlignRight => 'Destra';

  @override
  String get settingsAlignJustified => 'Giustificato';

  @override
  String get settingsFontFamilyHeader => 'CARATTERE';

  @override
  String get settingsItalicHeader => 'TESTO IN CORSIVO';

  @override
  String get settingsDailyReading => 'Lettura quotidiana';

  @override
  String get settingsCustomReminder => 'Promemoria personalizzato';

  @override
  String get settingsMonday => 'Lunedì';

  @override
  String get settingsTuesday => 'Martedì';

  @override
  String get settingsWednesday => 'Mercoledì';

  @override
  String get settingsThursday => 'Giovedì';

  @override
  String get settingsFriday => 'Venerdì';

  @override
  String get settingsSaturday => 'Sabato';

  @override
  String get settingsSunday => 'Domenica';

  @override
  String settingsStrongsPackRequired(String size) {
    return 'Richiede il pacchetto “KJV with Strong\'s” ($size da scaricare).';
  }

  @override
  String settingsBbeNoteBody(int count) {
    return 'La Bible in Basic English ha lasciato alcuni versetti non tradotti o molto abbreviati. Per questi ($count versetti) viene mostrato il testo della World English Bible (WEB), segnato con un badge WEB.';
  }

  @override
  String settingsDayAtTime(String day, String time) {
    return '$day alle $time';
  }

  @override
  String get spaceTitle => 'Il tuo spazio';

  @override
  String get spaceTabHighlights => 'Evidenziazioni';

  @override
  String get spaceTabBookmarks => 'Segnalibri';

  @override
  String get spaceTabNotes => 'Note';

  @override
  String get spaceTabJournal => 'Diario';

  @override
  String get spaceHighlighted => 'Evidenziato';

  @override
  String get spaceNewFolder => 'Nuova cartella';

  @override
  String get spaceFolderNameHint => 'Nome cartella';

  @override
  String get spaceCreate => 'Crea';

  @override
  String get spaceRenameFolder => 'Rinomina cartella';

  @override
  String get spaceRename => 'Rinomina';

  @override
  String get spaceDeleteFolderTitle => 'Eliminare la cartella?';

  @override
  String spaceDeleteFolderBody(String folderName) {
    return 'Eliminare davvero \"$folderName\"?\n\nI segnalibri in questa cartella NON verranno eliminati; saranno spostati in Non archiviati.';
  }

  @override
  String get spaceMoveToFolder => 'Sposta in cartella';

  @override
  String get spaceUnfiled => 'Non archiviati';

  @override
  String get spaceGroupEarlier => 'Precedenti';

  @override
  String get spaceGroupLast7Days => 'Ultimi 7 giorni';

  @override
  String get spaceGroupLast30Days => 'Ultimi 30 giorni';

  @override
  String get spaceUnknownBook => 'Libro sconosciuto';

  @override
  String get spaceNoBookmarks => 'Nessun segnalibro qui.';

  @override
  String get spaceFilterAll => 'Tutti';

  @override
  String get spaceByDate => 'Per data';

  @override
  String get spaceByBook => 'Per libro';

  @override
  String get spaceYourNotes => 'Le tue note.';

  @override
  String get spaceNoNotesTapPlus =>
      'Ancora nessuna nota.\nTocca + per crearne una.';

  @override
  String get spaceMore => 'Altro';

  @override
  String get spaceNote => 'Nota';

  @override
  String get spaceCopyText => 'Copia testo';

  @override
  String get spaceUntitled => 'Senza titolo';

  @override
  String get spaceBookmarkedVerse => 'Versetto salvato';

  @override
  String get spaceHighlightedVerse => 'Versetto evidenziato';

  @override
  String get spaceOpenInRead => 'Apri in Lettura';

  @override
  String get spaceAddNote => 'Aggiungi nota';

  @override
  String get spaceCopyVerse => 'Copia versetto';

  @override
  String get spaceShareVerse => 'Condividi versetto';

  @override
  String get spaceChangeColour => 'Cambia colore';

  @override
  String get spaceMoveToFolderAction => 'Sposta in cartella';

  @override
  String get spaceRemoveBookmark => 'Rimuovi segnalibro';

  @override
  String get spaceRemoveHighlight => 'Rimuovi evidenziazione';

  @override
  String get spaceHighlightColour => 'Colore evidenziazione';

  @override
  String spaceColourN(int index) {
    return 'Colore $index';
  }

  @override
  String get notesMyNotes => 'Le mie note';

  @override
  String get notesEmptyTitle => 'Ancora nessuna nota';

  @override
  String get notesEmptyBody => 'Tocca + per aggiungere la tua prima nota.';

  @override
  String get notesVerseInserted => 'Versetto inserito';

  @override
  String get notesAddCommentary => 'Aggiungi commento';

  @override
  String get notesChapterTitlePlaceholder => 'Titolo del capitolo';

  @override
  String get notesEditNote => 'Modifica nota';

  @override
  String notesNewNoteOn(String reference) {
    return 'Nuova nota su $reference';
  }

  @override
  String get notesNewNote => 'Nuova nota';

  @override
  String get notesTitleHint => 'Titolo della nota';

  @override
  String get notesContentHint => 'Inizia a scrivere… (digita / per i comandi)';

  @override
  String get notesInsertVerse => 'Inserisci versetto';

  @override
  String get notesInsertDate => 'Inserisci data';

  @override
  String get notesInsertChapterTitle => 'Inserisci titolo capitolo';

  @override
  String get notesSaved => 'Nota salvata!';

  @override
  String get notesSaveChanges => 'Salva modifiche';

  @override
  String get notesSaveNote => 'Salva nota';

  @override
  String get notesDeleted => 'Nota eliminata';

  @override
  String get notesDeleteNote => 'Elimina nota';

  @override
  String get notesNewJournalEntry => 'Nuova voce di diario';

  @override
  String get notesJournalHint => 'Come ti senti oggi? Apri il tuo cuore…';

  @override
  String get notesSaveAndAnalyze => 'Salva e analizza';

  @override
  String get notesNoJournalEntries => 'Ancora nessuna voce nel diario.';

  @override
  String get notesWriteEntry => 'Scrivi';

  @override
  String get notesAiReflection => 'Riflessione IA';

  @override
  String notesDetectedEmotion(String emotion) {
    return 'Emozione rilevata: $emotion';
  }

  @override
  String notesVersesList(String verses) {
    return 'Versetti: $verses';
  }

  @override
  String get accountGuest => 'Ospite';

  @override
  String get accountSignInToSync => 'Accedi per sincronizzare i dispositivi';

  @override
  String get accountAccount => 'Account';

  @override
  String get accountSettings => 'Impostazioni';

  @override
  String get accountBackUp => 'Backup dati';

  @override
  String get accountBackUpSubtitle =>
      'Esporta note, evidenziazioni e impostazioni';

  @override
  String get accountRestore => 'Ripristina dati';

  @override
  String get accountRestoreSubtitle => 'Importa da un file di backup';

  @override
  String get accountSignInGoogle => 'Accedi con Google';

  @override
  String get accountSignInApple => 'Accedi con Apple';

  @override
  String get accountSignOut => 'Esci';

  @override
  String get accountResetApp => 'Reimposta app';

  @override
  String get accountResetAppSubtitle => 'Cancella i dati sul dispositivo';

  @override
  String get accountSignIn => 'Accedi';

  @override
  String get accountSignedIn => 'Accesso effettuato';

  @override
  String get accountDeleteAccount => 'Elimina account';

  @override
  String get accountDeleteAccountTitle => 'Eliminare l\'account?';

  @override
  String get accountDeleteAccountBody =>
      'Questa azione è permanente e irreversibile.\n\nVerranno rimossi completamente:\n• Il tuo account di accesso\n• I suoi dati cloud in The Blessed Bible e Blessed Arcade (account condiviso)\n• Tutti i dati di studio sul dispositivo (segnalibri, evidenziazioni, cronologia)';

  @override
  String get accountDeleted => 'Account eliminato.';

  @override
  String accountReauthFailed(String reason) {
    return 'Impossibile confermare la tua identità, nulla è stato eliminato. $reason';
  }

  @override
  String get accountDeleteFailed =>
      'Impossibile eliminare l\'account. Riprova.';

  @override
  String get accountOtherDataTitle =>
      'Questo dispositivo ha dati di un altro account';

  @override
  String get accountOtherDataBody =>
      'Segnalibri, evidenziazioni e note su questo dispositivo provengono da un altro account. Cosa vuoi farne?';

  @override
  String get accountStartFresh => 'Ricomincia da zero qui';

  @override
  String get accountMerge => 'Unisci a questo account';

  @override
  String get accountSignOutTitle => 'Uscire?';

  @override
  String get accountSignOutBody =>
      'Segnalibri, evidenziazioni e note restano al sicuro nel tuo account. Tenere una copia su questo dispositivo?';

  @override
  String get accountRemoveFromDevice => 'Rimuovi dal dispositivo';

  @override
  String get accountKeepOnDevice => 'Tieni sul dispositivo';

  @override
  String get accountSyncing => 'Sincronizzazione…';

  @override
  String get accountSyncFailed => 'Sincronizzazione non riuscita';

  @override
  String get accountTapToRetry => 'Tocca per riprovare';

  @override
  String get accountSyncPaused => 'Sincronizzazione in pausa';

  @override
  String get accountSyncChoose => 'Scegli cosa fare con i dati del dispositivo';

  @override
  String get accountSyncNow => 'Sincronizza ora';

  @override
  String get accountNotSyncedYet => 'Non ancora sincronizzato';

  @override
  String get accountSyncedJustNow => 'Sincronizzato ora';

  @override
  String accountSyncedMinAgo(int minutes) {
    return 'Sincronizzato $minutes min fa';
  }

  @override
  String accountSyncedHoursAgo(int hours) {
    return 'Sincronizzato $hours h fa';
  }

  @override
  String accountSyncedOn(int day, int month, int year) {
    return 'Sincronizzato il $day/$month/$year';
  }

  @override
  String get accountRestoreTitle => 'Ripristina dal backup';

  @override
  String get accountRestoreHint => 'Incolla qui il JSON di backup…';

  @override
  String get accountRestoreAction => 'Ripristina';

  @override
  String get accountResetTitle => 'Reimpostare l\'app?';

  @override
  String get accountResetBody =>
      'Cancella tutti i dati sul dispositivo:\n• Segnalibri, evidenziazioni, note e diario\n• Piani di lettura, progressi e piani personali\n• Traduzioni scaricate e serie\n\nImpostazioni, tema e Bibbia offline restano intatti. Non si può annullare: fai prima un backup se serve.';

  @override
  String get accountResetDone => 'Dati reimpostati. Si riparte!';

  @override
  String get accountReset => 'Reimposta';

  @override
  String get shareBackdrop => 'Sfondo';

  @override
  String get shareBackdropDawn => 'Alba';

  @override
  String get shareBackdropDusk => 'Tramonto';

  @override
  String get shareBackdropArtwork => 'Illustrazione';

  @override
  String get shareBackdropGradient => 'Sfumatura';

  @override
  String get shareFont => 'Carattere';

  @override
  String get shareFontTheme => 'Tema';

  @override
  String get shareSize => 'Dimensione';

  @override
  String get shareSpacing => 'Spaziatura';

  @override
  String get shareSpacingNormal => 'Normale';

  @override
  String shareSpacingWide(String value) {
    return 'Ampia $value';
  }

  @override
  String get shareLineHeight => 'Interlinea';

  @override
  String get shareAlignment => 'Allineamento';

  @override
  String get shareAlignCenter => 'Centro';

  @override
  String get shareAlignLeft => 'Sinistra';

  @override
  String get sharePreparing => 'Preparazione…';

  @override
  String get shareImage => 'Condividi immagine';

  @override
  String get shareText => 'Condividi testo';

  @override
  String get shareImageCard => 'Condividi card immagine';

  @override
  String get shareModeText => 'Testo';

  @override
  String get shareModeImage => 'Immagine';

  @override
  String get shareModePdf => 'PDF';

  @override
  String get shareFormat => 'Formato';

  @override
  String get shareFlavorPlain => 'Testo semplice';

  @override
  String get shareFlavorWhatsapp => 'WhatsApp';

  @override
  String get shareFlavorPlainHint =>
      'Nessuna formattazione — si incolla ovunque.';

  @override
  String get shareFlavorWhatsappHint =>
      'Titoli in grassetto e riferimenti in corsivo, formattati da WhatsApp.';

  @override
  String get shareIncludeReference => 'Includi riferimento';

  @override
  String get shareFormatPortrait => 'Ritratto';

  @override
  String get shareFormatSquare => 'Quadrato';

  @override
  String get shareFormatStory => 'Story';

  @override
  String get shareStyle => 'Stile';

  @override
  String get sharePdfTitle => 'PDF pronto per la stampa';

  @override
  String get sharePdfBody =>
      'Il testo completo su una pagina impaginata, con riferimento e fonte. Pronto da leggere, stampare o inviare.';

  @override
  String get shareSharePdf => 'Condividi PDF';

  @override
  String get shareBuildingPdf => 'Creazione del PDF…';

  @override
  String get shareFailed => 'Impossibile condividere — riprova.';

  @override
  String get shareSaveImage => 'Salva nella galleria';

  @override
  String get shareSavedToGallery => 'Salvato nella galleria';

  @override
  String get shareGalleryDenied =>
      'Consenti l\'accesso alle foto per salvare le immagini.';

  @override
  String get shareSaveFailed => 'Impossibile salvare l\'immagine — riprova.';

  @override
  String get sharePdfPreviewNote => 'Anteprima pagina 1 · A4';

  @override
  String get spaceStorageTitle => 'Spazio di archiviazione';

  @override
  String get spaceClearCacheTitle => 'Svuotare la cache?';

  @override
  String get spaceClearCacheBody =>
      'Rimuove i file temporanei (card di condivisione, miniature). Note, segnalibri, evidenziazioni e download restano intatti.';

  @override
  String get spaceClearCache => 'Svuota cache';

  @override
  String get spaceCacheCleared => 'Cache svuotata';

  @override
  String spaceDeletePackTitle(String name) {
    return 'Eliminare $name?';
  }

  @override
  String spaceDeletePackBundled(String size) {
    return 'Libera $size. Puoi ripristinarla offline in qualsiasi momento.';
  }

  @override
  String spaceDeletePackDownloaded(String size) {
    return 'Libera $size. Potrai scaricarla di nuovo in seguito.';
  }

  @override
  String spacePackDeleted(String abbr) {
    return '$abbr eliminata';
  }

  @override
  String spacePackDownloaded(String abbr) {
    return '$abbr scaricata';
  }

  @override
  String spaceFreed(String message, String size) {
    return '$message · liberati $size';
  }

  @override
  String get spaceOnThisDevice => 'Su questo dispositivo';

  @override
  String get spaceBibleContent => 'Contenuto biblico (sempre conservato)';

  @override
  String get spaceDownloadedPacks => 'Pacchetti scaricati';

  @override
  String get spaceCache => 'Cache';

  @override
  String get spaceCacheExplain =>
      'Solo file temporanei: card di condivisione e miniature. Puoi svuotarla in qualsiasi momento.';

  @override
  String get spaceTranslationsDownloads => 'Traduzioni e download';

  @override
  String get spaceBundledSuffix => ' · inclusa';

  @override
  String get spaceCoreNotRemovable =>
      'KJV e BBE fanno parte dell\'app e non possono essere rimosse.';

  @override
  String get spaceGet => 'Scarica';

  @override
  String spaceDeletePackTooltip(String name) {
    return 'Elimina $name';
  }

  @override
  String get welcomeBackTitle => 'Bentornato';

  @override
  String get welcomeBackBody =>
      'Accedi per ripristinare evidenziazioni, note, segnalibri e piani di lettura.';

  @override
  String get stateLoading => 'Caricamento';

  @override
  String get stateErrorTitle => 'Qualcosa è andato storto';

  @override
  String get stateErrorBody => 'Riprova tra un momento.';

  @override
  String get commonUndo => 'Annulla';

  @override
  String get spaceHighlightsIntro => 'I versetti che hai evidenziato.';

  @override
  String get storiesShowPassageTitle => 'Mostra il testo biblico nei racconti';

  @override
  String get storiesShowPassageSubtitle =>
      'Mostra il passo completo sopra ogni racconto. Se disattivato, tocca il riferimento per leggerlo.';

  @override
  String storiesOpenPassage(String reference) {
    return 'Leggi $reference';
  }

  @override
  String get studyCardSize => 'Dimensione scheda';

  @override
  String get studyPosition => 'Posizione';

  @override
  String get studySizeLarge => 'Grande';

  @override
  String get studySizeLargeHint => 'Larghezza piena, come le altre';

  @override
  String get studySizeExtraLarge => 'Extra grande';

  @override
  String get studySizeExtraLargeHint => 'Larghezza piena, contenuto più ampio';

  @override
  String get studySizeHalf => 'Metà';

  @override
  String get studySizeHalfHint => 'Compatta, due per riga';

  @override
  String get studySizeFull => 'Piena';

  @override
  String get studySizeFullHint => 'Larghezza piena, una per riga';

  @override
  String get studyPresetLayout => 'Layout predefiniti';

  @override
  String get studyPresetFull => 'Tutte piene';

  @override
  String get studyPresetHalf => 'Tutte a metà';

  @override
  String get studyVerseOfTheDay => 'Versetto del giorno';

  @override
  String get studyRecentVerses => 'Versetti recenti';

  @override
  String get studyWordLookUp => 'Cerca';

  @override
  String get studyConcordanceClear => 'Cancella';

  @override
  String get studyConcordanceBrowseAll => 'Sfoglia tutti i termini';

  @override
  String get studyConcordanceFeatured => 'Termini biblici in evidenza';

  @override
  String get studyConcordanceFilterAll => 'Tutti';

  @override
  String get studyConcordanceFilterOT => 'Antico Testamento';

  @override
  String get studyConcordanceFilterNT => 'Nuovo Testamento';

  @override
  String get studyMoveUp => 'Sposta su';

  @override
  String get studyMoveUpHint => 'Scambia con la scheda sopra';

  @override
  String get studyMoveDown => 'Sposta giù';

  @override
  String get studyMoveDownHint => 'Scambia con la scheda sotto';

  @override
  String get studyCommentaryEyebrow => 'Commento';

  @override
  String get studyCommentaryTitle => 'Approfondimento versetto per versetto';

  @override
  String get studyCommentarySnippet =>
      'Commento storicista con filtri per capitolo e versetto.';

  @override
  String get studyCommentaryCta => 'Apri il commento';

  @override
  String get studyDictionaryEyebrow => 'Dizionario';

  @override
  String get studyDictionaryTitle => 'Parole spiegate';

  @override
  String get studyDictionarySnippet =>
      'Easton e Smith, offline, con parole salvate.';

  @override
  String get studyDictionaryCta => 'Cerca';

  @override
  String get studyStoriesEyebrow => 'Storie bibliche';

  @override
  String get studyStoriesTitle => 'Racconti narrati';

  @override
  String get studyStoriesSnippet => '66 storie da ogni libro.';

  @override
  String get studyStoriesCta => 'Leggi le storie';

  @override
  String get studyConcordanceEyebrow => 'Concordanza';

  @override
  String get studyConcordanceTitle => 'Ogni occorrenza';

  @override
  String get studyConcordanceSnippet =>
      'Trova ogni versetto in cui compare una parola.';

  @override
  String get studyConcordanceCta => 'Cerca parole';

  @override
  String get studySpaceSaved => 'Salvati';

  @override
  String get studySpaceMarked => 'Evidenziati';

  @override
  String get studySpaceNotes => 'Note';

  @override
  String get studySpaceJournal => 'Diario';

  @override
  String get studySpaceTitle => 'Il tuo spazio';

  @override
  String get studySpaceSubtitle => 'Segnalibri, evidenziazioni, note e diario';

  @override
  String get studyReadingPlan => 'Piano di lettura';

  @override
  String get studyStartReadingPlan => 'Inizia un piano di lettura';

  @override
  String get studyActivePlan => 'Piano attivo';

  @override
  String studyDayOfTotal(int current, int total) {
    return 'Giorno $current di $total';
  }

  @override
  String studyDaysBehind(int count) {
    return '$count indietro';
  }

  @override
  String get studyPlans => 'Piani';

  @override
  String get studyGuidedReading => 'Lettura guidata';

  @override
  String get studyGuidedReadingSubtitle =>
      'Selezionati, cadenzati e personalizzati';

  @override
  String get studyReadyToBegin => 'Pronto per iniziare';

  @override
  String studyTodayLabel(String label) {
    return 'Oggi: $label';
  }

  @override
  String get studyReview => 'Rivedi';

  @override
  String get studyRead => 'Leggi';

  @override
  String studyCtaArrow(String cta) {
    return '$cta →';
  }

  @override
  String get studyWordOfTheDay => 'Parola del giorno';

  @override
  String get studyArchiveLink => 'Archivio →';

  @override
  String get studyLoading => 'Caricamento…';

  @override
  String get studyUnavailableNow => 'Non disponibile al momento';

  @override
  String get studyReadingStreak => 'Serie di lettura';

  @override
  String get studyStartStreak => 'Inizia la tua serie';

  @override
  String studyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get studyStreakGrow => 'Aprila ogni giorno per farla crescere.';

  @override
  String get studyStreakStart => 'Completa una lettura ogni giorno.';

  @override
  String get studyViewProgress => 'Vedi i progressi →';

  @override
  String get studyPassageNotFound => 'Passo non trovato';

  @override
  String get studyPassageLoadError => 'Impossibile caricare il passo.';

  @override
  String get studyCompletedCheck => '✓ Completato';

  @override
  String get studyMarkAsRead => 'Segna come letto';

  @override
  String get studyNextPassage => 'Passo successivo';

  @override
  String get studyFullChapter => 'Capitolo intero';

  @override
  String studyPassageOfTotal(int current, int total) {
    return 'Passo $current di $total';
  }

  @override
  String studySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selezionati',
      one: '1 selezionato',
    );
    return '$_temp0';
  }

  @override
  String get studyHighlight => 'Evidenzia';

  @override
  String get studyBookmark => 'Segnalibro';

  @override
  String get studyAddNote => 'Aggiungi nota';

  @override
  String studyChaptersWithContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capitoli con contenuti',
      one: '1 capitolo con contenuti',
    );
    return '$_temp0';
  }

  @override
  String get studyCommentaryLibrary => 'Biblioteca dei commenti';

  @override
  String get studyCommentaryLoadError => 'Impossibile caricare il commento.';

  @override
  String get studyNoCommentaryYet => 'Nessun commento ancora disponibile.';

  @override
  String get studyCommentaryShelf => 'Lo scaffale';

  @override
  String get studyCommentaryByBook => 'Per libro';

  @override
  String studyCommentaryVolumes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volumi',
      one: '1 volume',
    );
    return '$_temp0';
  }

  @override
  String studyCommentaryEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voci',
      one: '1 voce',
    );
    return '$_temp0';
  }

  @override
  String studyCommentaryChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capitoli',
      one: '1 capitolo',
    );
    return '$_temp0';
  }

  @override
  String get studyCommentarySearchHint => 'Cerca volumi e libri';

  @override
  String studyCommentaryNoMatch(String query) {
    return 'Nessuna corrispondenza per \"$query\".';
  }

  @override
  String studyReadingRef(String reference) {
    return 'Lettura · $reference';
  }

  @override
  String get studyAllSources => 'Tutte le fonti';

  @override
  String get studyVerseLevel => 'Per versetto';

  @override
  String studySearchWithin(String reference) {
    return 'Cerca in $reference…';
  }

  @override
  String get studyNoEntriesMatch =>
      'Nessuna voce corrisponde ai filtri.\nProva Tutte le fonti o sfoglia la biblioteca.';

  @override
  String studyVerseN(int verse) {
    return 'Versetto $verse';
  }

  @override
  String get studyChapter => 'Capitolo';

  @override
  String get studyCategoryCommentary => 'Commento';

  @override
  String get studyCategoryDevotional => 'Meditazione';

  @override
  String get studyCategoryStudyNote => 'Nota di studio';

  @override
  String get studyNoContentForFilters => 'Nessun contenuto per questi filtri.';

  @override
  String studyVerseLabel(String verse) {
    return 'Versetto $verse';
  }

  @override
  String get studyChapterView => 'Vista capitolo';

  @override
  String get studyFilterAll => 'Tutto';

  @override
  String get studyFilterDevotionals => 'Meditazioni';

  @override
  String get studyFilterAllContexts => 'Tutti i contesti';

  @override
  String get studyFilterChapterLevel => 'Per capitolo';

  @override
  String get studyFilterVerseLevel => 'Per versetto';

  @override
  String get studyRemoveBookmark => 'Rimuovi segnalibro';

  @override
  String get studyBookmarkCommentary => 'Aggiungi ai segnalibri';

  @override
  String get studyExpandFullScreen => 'Schermo intero';

  @override
  String get studyTapToReadInContext => 'Tocca per leggere nel contesto';

  @override
  String get studyOnThisChapter => 'Su questo capitolo';

  @override
  String get studyOnThisBook => 'Su questo libro';

  @override
  String get studyNoCommentaryTitle => 'Ancora nessun commento';

  @override
  String get studyNoCommentaryBody =>
      'Nessun commento specifico per questo passo. Esplora i commenti al capitolo o al libro qui sotto.';

  @override
  String get storiesTitle => 'Storie bibliche';

  @override
  String get storiesFilters => 'Filtri';

  @override
  String get storiesSubtitle =>
      '500 momenti illustrati dalla Genesi all\'Apocalisse';

  @override
  String get storiesSearchHint => 'Titolo, libro o riferimento…';

  @override
  String get storiesClearSearch => 'Cancella ricerca';

  @override
  String get storiesFilterAll => 'Tutte';

  @override
  String get storiesFilterOt => 'AT';

  @override
  String get storiesFilterNt => 'NT';

  @override
  String storiesCountOfTotal(int count, int total) {
    return '$count storie su $total';
  }

  @override
  String get storiesFavorites => 'Preferiti';

  @override
  String get storiesUnread => 'Non lette';

  @override
  String get storiesBooks => 'Libri';

  @override
  String get storiesSearchBooks => 'Cerca un libro…';

  @override
  String get storiesAllBooks => 'Tutti i libri';

  @override
  String get storiesNoMatch => 'Nessuna storia corrisponde ai filtri.';

  @override
  String get storiesNoFavorites => 'Ancora nessun preferito.';

  @override
  String get storiesBrowseAll => 'Sfoglia tutte le storie';

  @override
  String get storiesAllCaughtUp => 'Sei in pari.';

  @override
  String get storiesShowRead => 'Mostra storie lette';

  @override
  String get storiesClearFilters => 'Cancella filtri';

  @override
  String get storiesFavoritesHint => 'Tocca ♥ su una storia per salvarla qui.';

  @override
  String get storiesAttribution =>
      'Scritture dalla King James Version (pubblico dominio). Sintesi adattate da The Graham Bible (grahambible.com), con assistenza IA e revisione umana. Illustrazioni: Gustave Doré (1832–1883), pubblico dominio, tramite Wikimedia Commons.';

  @override
  String get storiesReachedEnd => 'Sei arrivato alla fine.';

  @override
  String get storiesFirstStory => 'Questa è la prima storia.';

  @override
  String get storiesFavorite => 'Preferito';

  @override
  String get storiesMarkAsRead => 'Segna come letta';

  @override
  String storiesKeyVerse(String reference) {
    return 'VERSETTO CHIAVE · $reference';
  }

  @override
  String get storiesTheStory => 'IL RACCONTO';

  @override
  String storiesArtworkCaption(String caption) {
    return 'Illustrazione: $caption — Gustave Doré, pubblico dominio';
  }

  @override
  String get storiesPrevious => 'Storia precedente';

  @override
  String get storiesNext => 'Storia successiva';

  @override
  String storiesPosition(int index, int total, String book) {
    return '$index di $total in $book';
  }

  @override
  String get studyDictionarySearchHint => 'Cerca tra oltre 3.400 parole…';

  @override
  String get studyDictionarySavedFilter => '★ Salvate';

  @override
  String get studyNoHeadwords => 'Nessun lemma trovato.';

  @override
  String get studyDictionaryNoMatches =>
      'Nessun risultato. Prova “grace”, “atonement” o “wilderness” (dizionario in inglese).';

  @override
  String studyResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '1 risultato',
    );
    return '$_temp0';
  }

  @override
  String get studyUntitledEntry => '(voce senza titolo)';

  @override
  String get studyRemoveSavedWord => 'Rimuovi parola salvata';

  @override
  String get studySaveWord => 'Salva parola';

  @override
  String get studyNoDefinition => 'Nessuna definizione trovata.';

  @override
  String studyStrongsShareText(String id, String lemma, String transliteration,
      String pronunciation, String definition) {
    return '$id - $lemma\n\nTraslitterazione: $transliteration\nPronuncia: $pronunciation\n\nDefinizione:\n$definition';
  }

  @override
  String studyNoStrongsEntry(String id) {
    return 'Nessuna voce per $id.';
  }

  @override
  String get studyStrongsLexicon => 'LESSICO DI STRONG';

  @override
  String get studyConcordanceHint => 'Parola inglese (es. grace, covenant)…';

  @override
  String get studyConcordanceIntro =>
      'Occorrenze nella KJV — tocca un versetto per leggerlo nel contesto.';

  @override
  String get studyConcordanceEmpty =>
      'Ogni versetto che contiene la parola, in ordine canonico.';

  @override
  String get studyConcordanceSingleWord => 'Inserisci una sola parola inglese.';

  @override
  String studyConcordanceNoVerses(String word) {
    return 'Nessun versetto contiene \"$word\".';
  }

  @override
  String studyConcordanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versetti',
      one: '1 versetto',
    );
    return '$_temp0';
  }

  @override
  String studyConcordanceCountTruncated(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versetti',
      one: '1 versetto',
    );
    return '$_temp0 (primi $limit mostrati)';
  }

  @override
  String get creditsTitle => 'Crediti e fonti';

  @override
  String get creditsLicenses => 'Licenze open source';

  @override
  String get creditsLicensesSubtitle => 'Font e pacchetti software';

  @override
  String studyPreparingOfflineBible(int percent) {
    return 'Preparazione della Bibbia offline… $percent%';
  }

  @override
  String get errorTitle => 'Qualcosa è andato storto';

  @override
  String get errorBody =>
      'Si è verificato un problema imprevisto. Tocca qui sotto per tornare alla home.';

  @override
  String get errorBackHome => 'Torna alla home';

  @override
  String studyWeekN(int week) {
    return 'Settimana $week';
  }

  @override
  String get privacyTitle => 'Informativa sulla privacy';

  @override
  String get privacyLoadError =>
      'Impossibile caricare l\'informativa sulla privacy.';

  @override
  String privacyEffectiveDate(String date) {
    return 'Data di entrata in vigore: $date';
  }

  @override
  String get privacyEnglishOnly =>
      'Questa informativa è disponibile in inglese.';

  @override
  String get privacyViewOnline => 'Vedi online';

  @override
  String get notifDailyTitle => 'È ora di leggere';

  @override
  String get notifDailyBody =>
      'Prenditi un momento per leggere e riflettere oggi.';

  @override
  String get notifDailyChannel => 'Promemoria giornalieri';

  @override
  String get notifDailyChannelDesc => 'Promemoria per la lettura quotidiana';

  @override
  String get notifPrayerTitle => 'È ora di pregare';

  @override
  String get notifPrayerBody =>
      'Fermati per un momento di riflessione e preghiera.';

  @override
  String get notifPrayerChannel => 'Promemoria di preghiera';

  @override
  String get notifPrayerChannelDesc => 'Promemoria giornalieri di preghiera';

  @override
  String get notifWeeklyTitle => 'Studio settimanale';

  @override
  String get notifWeeklyBody =>
      'È il momento che hai scelto per lo studio e la riflessione.';

  @override
  String get notifWeeklyChannel => 'Promemoria settimanali';

  @override
  String get notifWeeklyChannelDesc =>
      'Promemoria settimanali di studio personalizzati';

  @override
  String get notifSabbathTitle => 'Il sabato si avvicina';

  @override
  String get notifSabbathBody => 'Accogli il giorno del riposo.';

  @override
  String get notifSabbathChannel => 'Promemoria del sabato';

  @override
  String get notifSabbathChannelDesc =>
      'Promemoria settimanali al tramonto per il sabato';

  @override
  String get notifPlanBody =>
      'Prenditi un momento per leggere il brano di oggi.';

  @override
  String get notifPlanChannel => 'Piano di lettura';

  @override
  String get notifPlanChannelDesc => 'Promemoria del piano di lettura';

  @override
  String get widgetStreakActive => 'Serie attiva!';

  @override
  String get widgetStreakInactive => 'Leggi oggi per mantenere la serie';

  @override
  String get widgetFallbackWord => 'Grazia (Charis)';

  @override
  String get widgetFallbackDefinition =>
      'Il favore immeritato e l\'amore divino di Dio donati all\'umanità.';

  @override
  String get widgetStyleDusk => 'Crepuscolo celeste';

  @override
  String get widgetStyleDawn => 'Alba mattutina';

  @override
  String get widgetStyleEmerald => 'Smeraldo del santuario';

  @override
  String get widgetStyleGolden => 'Ambra sacra';

  @override
  String get widgetStyleRoyal => 'Zaffiro reale';

  @override
  String get widgetStyleGlassLight => 'Vetro smerigliato';

  @override
  String get widgetStyleGlassDark => 'Vetro d\'ossidiana';

  @override
  String get widgetStyleSolidLight => 'Carta bianca';

  @override
  String get widgetStyleSolidDark => 'Carbone intenso';

  @override
  String get widgetStyleTransparent => 'Sfondo trasparente';

  @override
  String get backupShareSubject => 'Backup di The Blessed Bible';

  @override
  String backupExportFailed(String error) {
    return 'Esportazione non riuscita: $error';
  }

  @override
  String backupNewerVersion(int version) {
    return 'Questo backup proviene da una versione più recente dell\'app (v$version). Aggiorna prima l\'app.';
  }

  @override
  String get backupConfirmTitle => 'Conferma ripristino';

  @override
  String get backupConfirmBody =>
      'Verranno sovrascritti note, evidenziazioni, segnalibri e impostazioni esistenti. Sei sicuro?';

  @override
  String backupSkippedValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valori saltati',
      one: '1 valore saltato',
    );
    return '$_temp0';
  }

  @override
  String backupRedownload(int count, String list) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'scarica di nuovo $count traduzioni: $list',
      one: 'scarica di nuovo 1 traduzione: $list',
    );
    return '$_temp0';
  }

  @override
  String get backupRestored => 'Backup ripristinato correttamente';

  @override
  String backupRestoredWithDetails(String details) {
    return 'Backup ripristinato ($details)';
  }

  @override
  String backupRestoreFailed(String error) {
    return 'Ripristino non riuscito: backup non valido o danneggiato ($error)';
  }

  @override
  String get greetingDaily1Title => 'Pace a te.';

  @override
  String get greetingDaily1Subtitle => 'La sua parola ti doni riposo.';

  @override
  String get greetingDaily2Title => 'Cammina nella luce.';

  @override
  String get greetingDaily2Subtitle =>
      'La sua parola è una lampada al tuo cammino.';

  @override
  String get greetingDaily3Title => 'Grazia e pace a te.';

  @override
  String get greetingDaily3Subtitle => 'Rimani nella Vite oggi.';

  @override
  String get greetingDaily4Title => 'Vieni alle acque.';

  @override
  String get greetingDaily4Subtitle => 'Gesù è la luce del mondo.';

  @override
  String get greetingDaily5Title => 'Il Signore ti benedica.';

  @override
  String get greetingDaily5Subtitle => 'Custodisci le sue promesse nel cuore.';

  @override
  String get greetingDaily6Title => 'Fermati e riconosci.';

  @override
  String get greetingDaily6Subtitle => 'Dimora nella sua quieta presenza.';

  @override
  String get greetingDaily7Title => 'Misericordie nuove ogni mattina.';

  @override
  String get greetingDaily7Subtitle => 'Le sue compassioni non vengono meno.';

  @override
  String get greetingDaily8Title => 'Radicato nell\'amore.';

  @override
  String get greetingDaily8Subtitle => 'Cresci nella grazia e nella verità.';

  @override
  String get greetingDaily9Title => 'Risplenda la tua luce.';

  @override
  String get greetingDaily9Subtitle =>
      'Una città posta sopra un monte non può restare nascosta.';

  @override
  String get greetingDaily10Title => 'Avvicinati a Dio.';

  @override
  String get greetingDaily10Subtitle => 'Ti sta già tendendo la mano.';

  @override
  String get greetingDaily11Title => 'La Parola si è fatta carne.';

  @override
  String get greetingDaily11Subtitle => 'Egli comprende il tuo cammino.';

  @override
  String get greetingDaily12Title => 'Gusta e vedi.';

  @override
  String get greetingDaily12Subtitle => 'Quanto è buono il Signore.';

  @override
  String get greetingMorning1Title => 'Svegliati, o tu che dormi.';

  @override
  String get greetingMorning1Subtitle => 'Cristo ti illuminerà.';

  @override
  String get greetingMorning2Title => 'Al mattino viene la gioia.';

  @override
  String get greetingMorning2Subtitle => 'Entra nel suo nuovo giorno.';

  @override
  String get greetingMorning3Title =>
      'Questo è il giorno che il Signore ha fatto.';

  @override
  String get greetingMorning3Subtitle => 'Rallegriamoci ed esultiamo in esso.';

  @override
  String get greetingEvening1Title => 'Il giorno è finito.';

  @override
  String get greetingEvening1Subtitle => 'Egli dà il sonno ai suoi amati.';

  @override
  String get greetingEvening2Title => 'Sotto le sue ali.';

  @override
  String get greetingEvening2Subtitle => 'Troverai rifugio stanotte.';

  @override
  String get greetingEvening3Title =>
      'Venite a me, voi tutti che siete affaticati.';

  @override
  String get greetingEvening3Subtitle => 'E io vi darò riposo.';

  @override
  String get greetingGrace1Title => 'Getta su di Lui ogni tua preoccupazione.';

  @override
  String get greetingGrace1Subtitle => 'Perché Egli ha cura di te.';

  @override
  String get greetingGrace2Title => 'Vi do la mia pace.';

  @override
  String get greetingGrace2Subtitle => 'Il vostro cuore non sia turbato.';

  @override
  String get greetingGrace3Title => 'Egli guarisce chi ha il cuore spezzato.';

  @override
  String get greetingGrace3Subtitle => 'E fascia le loro ferite.';

  @override
  String get greetingGrace4Title => 'Nulla potrà separarci.';

  @override
  String get greetingGrace4Subtitle => 'Dall\'amore di Dio.';

  @override
  String get greetingCheer1Title => 'Sii forte e coraggioso.';

  @override
  String get greetingCheer1Subtitle => 'Il Signore, il tuo Dio, è con te.';

  @override
  String get greetingCheer2Title => 'Corri con perseveranza.';

  @override
  String get greetingCheer2Subtitle => 'Tieni lo sguardo fisso su Gesù.';

  @override
  String get greetingCheer3Title => 'Il ferro affila il ferro.';

  @override
  String get greetingCheer3Subtitle => 'Crescete insieme nella Parola.';

  @override
  String greetingEyebrowMorning(String day) {
    return '$day mattina';
  }

  @override
  String greetingEyebrowAfternoon(String day) {
    return '$day pomeriggio';
  }

  @override
  String greetingEyebrowEvening(String day) {
    return '$day sera';
  }

  @override
  String greetingEyebrowNight(String day) {
    return '$day notte';
  }

  @override
  String get creditsScripture => 'Scrittura';

  @override
  String get creditsCommentary => 'Commentario';

  @override
  String get creditsStudyTools => 'Strumenti di studio';

  @override
  String get creditsBibleStories => 'Storie bibliche';

  @override
  String get creditsFonts => 'Caratteri';

  @override
  String get creditsCommentaryPerspective =>
      'I commenti provengono da autori del XIX e XX secolo della tradizione avventista del settimo giorno e leggono la profezia biblica secondo la prospettiva storicista. Sono offerti come aiuto allo studio accanto alla Scrittura, non come parte di essa.';

  @override
  String get creditsPublicDomain => 'Pubblico dominio.';

  @override
  String get creditsPublicDomainUs => 'Pubblico dominio negli Stati Uniti.';

  @override
  String get creditsKjvDetail =>
      'Pubblico dominio. Anche l\'edizione con i numeri Strong è di pubblico dominio.';

  @override
  String get creditsSelectedWriting => 'Scritti scelti.';

  @override
  String get creditsAdditionalTranslationsDetail =>
      'Scaricate dalla Free Use Bible API (bible.helloao.org) e da open-bibles (github.com/seven1m/open-bibles).';

  @override
  String get creditsNarrativeDetail =>
      'Adattati da The Graham Bible (grahambible.com), con l\'aiuto dell\'IA e revisionati da persone.';

  @override
  String creditsFontsDetail(String licenses) {
    return 'SIL Open Font License 1.1. Avvisi completi in $licenses.';
  }

  @override
  String get miscPlanNotFound => 'Piano non trovato.';

  @override
  String get miscPaceUnsupported =>
      'Questo piano è stato creato prima che fosse possibile regolare il ritmo. Ricrealo per attivare questa funzione.';

  @override
  String miscPaceFailed(String error) {
    return 'Regolazione del ritmo non riuscita: $error';
  }

  @override
  String miscPlanLoadFailed(String error) {
    return 'Impossibile caricare questo piano ($error).';
  }

  @override
  String get miscFolderSermon => 'Preparazione sermoni';

  @override
  String get miscFolderMemorize => 'Da memorizzare';

  @override
  String get miscFolderComfort => 'Conforto';

  @override
  String get miscFolderStudy => 'Studio';

  @override
  String get miscColorPurple => 'Viola';

  @override
  String get miscColorGreen => 'Verde';

  @override
  String get miscColorBlue => 'Blu';

  @override
  String get miscColorPink => 'Rosa';

  @override
  String get miscColorRed => 'Rosso';

  @override
  String get miscSearchBibleVerse => 'Versetto biblico';

  @override
  String get miscSearchCommentary => 'Commento';

  @override
  String miscSearchCommentaryBy(String author) {
    return 'Commento di $author';
  }

  @override
  String miscSearchNote(String date) {
    return 'Nota • $date';
  }

  @override
  String get miscSearchJumpTo => 'Vai a';

  @override
  String miscSearchGoToChapter(String book, int chapter) {
    return 'Vai a $book, capitolo $chapter';
  }

  @override
  String miscSearchGoToVerse(String book, int chapter, int verse) {
    return 'Vai a $book, capitolo $chapter, versetto $verse';
  }

  @override
  String miscSearchDictionary(String sources) {
    return 'Dizionario ($sources)';
  }

  @override
  String miscMostReadSnippet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Brano letto spesso ($count visite)',
      one: 'Brano letto spesso (1 visita)',
    );
    return '$_temp0';
  }

  @override
  String get miscEmotionAnxiety => 'ansia';

  @override
  String get miscEmotionFear => 'paura';

  @override
  String get miscEmotionSadness => 'tristezza';

  @override
  String get miscEmotionLoneliness => 'solitudine';

  @override
  String get miscEmotionAnger => 'rabbia';

  @override
  String get miscEmotionTemptation => 'tentazione';

  @override
  String get miscEmotionGuilt => 'senso di colpa';

  @override
  String get miscEmotionHopelessness => 'sconforto';

  @override
  String get miscEmotionConfusion => 'confusione';

  @override
  String get miscEmotionDoubt => 'dubbio';

  @override
  String get miscEmotionExhaustion => 'sfinimento';

  @override
  String get miscEmotionGratitude => 'gratitudine';

  @override
  String get miscEmotionJoy => 'gioia';

  @override
  String get miscEmotionPeace => 'pace';

  @override
  String miscPrayerComfort(String emotion) {
    return 'Signore, donami conforto e forza mentre oggi affronto sentimenti di $emotion.';
  }

  @override
  String miscPrayerScripture(String verse) {
    return 'Concedimi la grazia di meditare la Scrittura, in particolare $verse.';
  }

  @override
  String get miscPrayerGuide =>
      'Guida i miei passi nella speranza e nella pace, confidando nelle tue promesse fedeli.';
}
