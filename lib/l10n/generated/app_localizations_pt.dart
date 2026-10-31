// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get a11yTextSmaller => 'Smaller text';

  @override
  String get a11yTextLarger => 'Larger text';

  @override
  String get a11yNotifications => 'Notifications';

  @override
  String get a11yShowNav => 'Show navigation';

  @override
  String get a11yHideNav => 'Hide navigation';

  @override
  String a11yVersesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses selected',
      one: '1 verse selected',
    );
    return '$_temp0';
  }

  @override
  String get a11yMakePrimary => 'Make main translation';

  @override
  String get a11yPreviousWeek => 'Previous week';

  @override
  String get a11yNextWeek => 'Next week';

  @override
  String get a11yRead => 'Ler';

  @override
  String get accountEditName => 'Edit display name';

  @override
  String get accountChooseName => 'Choose display name';

  @override
  String get accountNameHint => 'Your display name';

  @override
  String get accountSave => 'Guardar';

  @override
  String get accountNameUpdated => 'Display name updated.';

  @override
  String get studyVerseOfTheDayHistory => 'Verse of the day history';

  @override
  String get studyWordOfTheDayHistory => 'Word of the day history';

  @override
  String get studyRecentWords => 'Recent words';

  @override
  String get accountAddName => 'Add your name';

  @override
  String get accountNameSaveFailed =>
      'Couldn\'t save your name. Check your connection and try again.';

  @override
  String get accountSignOutSheetBody =>
      'Your data stays safe in your account. Choose what this device keeps.';

  @override
  String get accountKeepStudyData => 'Keep my study data on this device';

  @override
  String get accountKeepStudyDataSubtitle =>
      'Bookmarks, highlights, notes, plans and progress';

  @override
  String get accountKeepName => 'Keep my name on this device';

  @override
  String accountKeepNameSubtitle(String name) {
    return 'You\'ll show as \"$name\" instead of \"Guest\"';
  }

  @override
  String get accountSigningOut => 'Signing out…';

  @override
  String accountSignedOutAs(String name) {
    return 'Signed out. You\'re using the app as $name.';
  }

  @override
  String get accountSignedOutGuest =>
      'Signed out. You\'re using the app as a guest.';

  @override
  String get accountResetDevice => 'Reset this device';

  @override
  String get accountResetDeviceSubtitle =>
      'Erase study data on this device only';

  @override
  String get accountResetErases => 'Erases on this device:';

  @override
  String get accountResetEraseItems =>
      '• Bookmarks, highlights, notes and journal\n• Reading plans, progress and streaks\n• Downloaded translations';

  @override
  String get accountResetStays =>
      'Stays: settings, theme, your name, the offline Bible and your account\'s cloud data.';

  @override
  String get accountResetSignOutOption => 'Sign out and reset';

  @override
  String get accountResetSignOutOptionSubtitle =>
      'Your data stays in your account. Sign in again to bring it back.';

  @override
  String get accountResetStayOption => 'Stay signed in and re-download';

  @override
  String get accountResetStayOptionSubtitle =>
      'Clears this device, then downloads a fresh copy from your account.';

  @override
  String get accountResetDeleteCloud => 'Also delete my cloud data';

  @override
  String get accountResetDeleteCloudSubtitle =>
      'Removes this app\'s bookmarks, highlights, notes and plans from your account for good. Your account and Blessed Arcade stay.';

  @override
  String get accountResetAndDeleteCloud => 'Reset and delete cloud data';

  @override
  String get accountDeleteCloudTitle => 'Delete your cloud data?';

  @override
  String get accountDeleteCloudWord => 'DELETE';

  @override
  String accountDeleteCloudBody(String word) {
    return 'This permanently removes this app\'s synced data from your account, on every device. It can\'t be undone.\n\nType $word to confirm.';
  }

  @override
  String get accountDeleteCloudAction => 'Delete cloud data';

  @override
  String get accountResetting => 'Resetting…';

  @override
  String get accountResetDeviceDone => 'This device has been reset.';

  @override
  String get accountCloudDeleteFailed =>
      'Couldn\'t delete your cloud data, so nothing was erased. Check your connection and try again.';

  @override
  String get accountDeletingAccount => 'Deleting account…';

  @override
  String get appTitle => 'A Bíblia Abençoada';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonDone => 'Concluído';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonShare => 'Partilhar';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonSearch => 'Pesquisar';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Same as device';

  @override
  String get languageSubtitle =>
      'The language of menus and buttons. Your Bible translation is chosen separately.';

  @override
  String get homeWotdUnavailableNow =>
      'Word of the day is unavailable right now.';

  @override
  String get spaceCouldNotFinishPlain =>
      'Couldn\'t finish that. Please try again.';

  @override
  String get readTranslationsLoadErrorPlain => 'Could not load translations.';

  @override
  String get readDeleteTranslationBody =>
      'You can get it again from the translations list at any time.';

  @override
  String get readDeleteFailedPlain => 'Couldn\'t delete it. Please try again.';

  @override
  String get readCrossRefsLoadErrorPlain => 'Could not load cross-references.';

  @override
  String get readVerseLoadErrorPlain => 'Could not load this verse.';

  @override
  String get searchClearRecentTitle => 'Clear recent searches?';

  @override
  String get searchClearRecentBody =>
      'Your recent searches will be removed from this device.';

  @override
  String get searchClearRecentConfirm => 'Clear';

  @override
  String readHighlightsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count highlights removed',
      one: 'Highlight removed',
    );
    return '$_temp0';
  }

  @override
  String readVersesHighlighted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses highlighted',
      one: 'Verse highlighted',
    );
    return '$_temp0';
  }

  @override
  String readBookmarksRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookmarks removed',
      one: 'Bookmark removed',
    );
    return '$_temp0';
  }

  @override
  String readVersesBookmarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses bookmarked',
      one: 'Verse bookmarked',
    );
    return '$_temp0';
  }

  @override
  String get storiesLoadFailed => 'Could not load stories.';

  @override
  String get studyEntriesLoadFailed => 'Could not load entries.';

  @override
  String get studyDictionaryLoadFailed => 'Could not load the dictionary.';

  @override
  String get studyEntryLoadFailed => 'Could not load this entry.';

  @override
  String get studyOpenScreenFailed => 'Could not open that screen.';

  @override
  String get studyWordUnsaved => 'Removed from saved words';

  @override
  String get plansBuilderSaveFailed => 'Could not save plan.';

  @override
  String get plansBuilderLoadFailed => 'Could not set up the plan builder.';

  @override
  String get plansDetailLoadFailed => 'Could not load this plan.';

  @override
  String get plansTrackRemoved => 'Track removed';

  @override
  String get yourSpaceBookmarkRemoved => 'Bookmark removed';

  @override
  String get yourSpaceHighlightRemoved => 'Highlight removed';

  @override
  String get onboardingTagline => 'As Escrituras, sem distrações.';

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
  String get onboardingPrimaryVersion => 'Main translation';

  @override
  String get onboardingSecondaryVersion => 'Second translation';

  @override
  String get onboardingSecondaryDesc =>
      'Shown alongside your main Bible in parallel view';

  @override
  String get onboardingLookTitle => 'Make it comfortable';

  @override
  String get onboardingLookBody =>
      'Choose a page color, font and text size. Everything can be fine-tuned later.';

  @override
  String get onboardingThemeDaily => 'Daily rotation';

  @override
  String get onboardingThemeDailyDesc =>
      'A new theme each day, light or dark to match your phone';

  @override
  String get onboardingFontFamily => 'Font style';

  @override
  String get onboardingShuffleHint => 'Tap to shuffle';

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
  String get onboardingFeatureWordTitle => 'A Palavra Pura';

  @override
  String get onboardingFeatureWordBody =>
      'Read without distraction, with highlights, notes and bookmarks.';

  @override
  String get onboardingFeaturePlansTitle => 'Reading plans';

  @override
  String get onboardingFeaturePlansBody =>
      'Chronological, thematic or your own — with gentle reminders.';

  @override
  String get onboardingFeatureStudyTitle => 'Deep study';

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
  String get onboardingReminderTitle => 'A gentle daily reminder';

  @override
  String get onboardingReminderBody =>
      'A short nudge at the time you choose helps build a daily habit. We only notify you for reading — never ads.';

  @override
  String get onboardingReminderToggle => 'Remind me to read each day';

  @override
  String get onboardingReminderTime => 'Reminder time';

  @override
  String get onboardingReminderPermission =>
      'Your phone will ask permission to show notifications. You can change this later in Settings.';

  @override
  String get onboardingAccountTitle => 'Keep your notes safe';

  @override
  String get onboardingAccountBody =>
      'Signing in is optional. The app works fully offline without an account. With one, your highlights, notes, bookmarks and plans are backed up and kept in step across your devices.';

  @override
  String onboardingSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get onboardingNotNow => 'Not now';

  @override
  String get planFlowEmptyTitle => 'Read the Bible with a plan';

  @override
  String get planFlowEmptyBody => 'A few chapters a day, at your own pace.';

  @override
  String get planFlowPickPlan => 'Pick a plan';

  @override
  String get planFlowAllPlans => 'All plans';

  @override
  String planFlowYourPlans(int count) {
    return 'Your plans · $count active';
  }

  @override
  String planFlowTodayDay(int day) {
    return 'Today · Day $day';
  }

  @override
  String planFlowCatchUpDay(int day) {
    return 'Catch up · Day $day';
  }

  @override
  String get planFlowDoneToday => 'Done for today ✓';

  @override
  String planFlowNextDay(int day) {
    return 'Next · Day $day';
  }

  @override
  String get planFlowReadToday => 'Read today';

  @override
  String planFlowReadDay(int day) {
    return 'Read day $day';
  }

  @override
  String get planFlowReadAhead => 'Read ahead';

  @override
  String get planFlowPlanComplete => 'Plan complete';

  @override
  String get planFlowPlanCompleteBody => 'You\'ve read every day of this plan.';

  @override
  String get planFlowStartAndRead => 'Start & read day 1';

  @override
  String planFlowStartOn(String date) {
    return 'Start on $date';
  }

  @override
  String get planFlowStartsToday => 'Starts today';

  @override
  String planFlowStartsOn(String date) {
    return 'Starts $date';
  }

  @override
  String get planFlowChangeDate => 'Change date';

  @override
  String planFlowShowEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count earlier days',
      one: 'Show 1 earlier day',
    );
    return '$_temp0';
  }

  @override
  String get planFlowPace => 'Pace';

  @override
  String planFlowFinishDay(int day) {
    return 'Finish day $day';
  }

  @override
  String get planFlowMarkDayComplete => 'Mark day complete';

  @override
  String planFlowUpNext(String label) {
    return 'Up next: $label';
  }

  @override
  String planFlowReaderSubtitle(int day, String plan) {
    return 'Day $day · $plan';
  }

  @override
  String planFlowPassages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passages',
      one: '1 passage',
    );
    return '$_temp0';
  }

  @override
  String get planFlowMyPlans => 'My Plans';

  @override
  String get plansContinueReading => 'Continue reading';

  @override
  String get plansResume => 'Retomar';

  @override
  String plansDayCompleteCelebration(int day) {
    return 'Reading Plan\nDay $day Complete!';
  }

  @override
  String plansCalendarDayComplete(String label) {
    return '$label, reading complete';
  }

  @override
  String plansCalendarDayToday(String label) {
    return '$label, today';
  }

  @override
  String get plansDailyVerses => 'Daily verses';

  @override
  String get plansToday => 'Hoje';

  @override
  String get plansYesterday => 'Ontem';

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
  String get plansHello => 'Olá,';

  @override
  String plansSlotsFull(int count) {
    return 'All $count plan slots are in use. Pause a plan to free a slot — progress is kept.';
  }

  @override
  String get plansPausedSnack => 'Plano em pausa — todo o progresso é mantido.';

  @override
  String get plansBrowseToStart =>
      'Navegue em Leitura para começar o seu primeiro plano.';

  @override
  String get plansFriend => 'Friend';

  @override
  String get plansTitle => 'Planos';

  @override
  String get plansTabReading => 'Reading';

  @override
  String get plansTabBooks => 'Books';

  @override
  String plansTabMyPlans(int count) {
    return 'My Plans ($count)';
  }

  @override
  String get plansNotStarted => 'Por começar';

  @override
  String plansPercentDone(int percent) {
    return '$percent% done';
  }

  @override
  String get plansOpen => 'Abrir';

  @override
  String get plansPaused => 'Em pausa';

  @override
  String get plansStarted => 'Iniciado';

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
  String get plansCaughtUp => 'Recuperado';

  @override
  String get plansComplete => 'Concluir';

  @override
  String plansDayOfTotalLeft(int current, int total, int left) {
    return 'Dia $current de $total · faltam $left';
  }

  @override
  String get plansPauseKeepsProgress => 'Pausar (mantém o progresso)';

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
  String get plansYourCustomPlans => 'OS TEUS PLANOS PERSONALIZADOS';

  @override
  String plansDayOfTotal(int day, int total) {
    return 'Dia $day de $total';
  }

  @override
  String get plansCustomPlan => 'Custom plan';

  @override
  String get plansNoActivePlans => 'Nenhum plano ativo';

  @override
  String get plansNoActivePlansBody =>
      'Navegue em Leitura ou Livros para começar o seu primeiro plano.';

  @override
  String get plansLetsRead => 'Let\'s read';

  @override
  String get plansVerseOfTheDay => 'Versículo do dia';

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
  String get plansCustomPlanDefaultTitle => 'Custom plan';

  @override
  String get plansCustom => 'Custom';

  @override
  String plansBookRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String get plansBuilderTitle => 'Custom plan builder';

  @override
  String get plansPlanName => 'Nome do plano';

  @override
  String get plansPlanNameHint => 'e.g. Genesis in 30 days';

  @override
  String get plansReadingTracks => 'Percursos de leitura';

  @override
  String get plansAddTrack => 'Adicionar faixa';

  @override
  String get plansTracksOverlap =>
      'Tracks overlap — shared verses are counted once in the preview below.';

  @override
  String get plansDuration => 'Duração';

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
  String get plansStartRestReminder => 'Começar, descansar e lembrete';

  @override
  String get plansStartDate => 'Data de início';

  @override
  String get plansRestDaysNeutral => 'Dias de descanso (neutros)';

  @override
  String get plansNone => 'Nenhum';

  @override
  String get plansDailyReminder => 'Lembrete diário';

  @override
  String plansReminderAt(String time) {
    return 'At $time';
  }

  @override
  String get plansOff => 'Off';

  @override
  String get plansLivePreview => 'Pré-visualização ao vivo';

  @override
  String get plansPreviewEmpty =>
      'Adicione ao menos uma faixa acima para prever o cronograma equilibrado por palavras.';

  @override
  String get plansWordBalanced =>
      'Equilibrado em palavras · sensível à perícopo';

  @override
  String plansPreviewSummary(int days, int readingDays) {
    return '$days dias · $readingDays dias de leitura';
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
    return 'Dia $day: $portions';
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
      'Dê um nome ao plano e adicione pelo menos um percurso para continuar.';

  @override
  String get plansStartEllipsis => 'Start…';

  @override
  String get plansEndEllipsis => 'End…';

  @override
  String get plansStartLabel => 'COMEÇAR';

  @override
  String get plansEndLabel => 'FIM';

  @override
  String get plansRemoveTrack => 'Remover percurso';

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
  String get plansPlan => 'Plano';

  @override
  String get plansNoReadingsYet => 'This plan has no readings yet.';

  @override
  String plansReadingDaysWeeks(int days, int weeks) {
    return '$days reading days · ~$weeks weeks';
  }

  @override
  String get plansBeginPlan => 'Iniciar plano';

  @override
  String get plansStartDayOne => 'Start day 1 →';

  @override
  String get plansStartDateNote => 'Your plan begins on the date you choose.';

  @override
  String get plansScheduleLabel => 'HORÁRIO';

  @override
  String get plansNoReadings => 'No readings';

  @override
  String plansPercentComplete(int percent) {
    return '$percent% concluído';
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
  String get plansCatchUp => 'Recuperar';

  @override
  String plansBehindBy(int count, int day) {
    return 'Atrasado $count — o dia mais antigo por ler é o Dia $day.';
  }

  @override
  String get plansCatchUpHelp =>
      'Marking days done records progress. Shifting moves the rest of the schedule forward instead.';

  @override
  String get plansGoToOldest => 'Ir ao mais antigo';

  @override
  String get plansMarkOldestDone => 'Marcar o mais antigo como concluído';

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
  String get plansMarkAllPrevious =>
      'Marcar todas as anteriores como concluídas';

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
    return 'LEITURAS · $count DIAS';
  }

  @override
  String get plansJourneyMap => 'Vista de mapa do percurso';

  @override
  String get plansJumpToToday => 'Ir para hoje';

  @override
  String plansDayN(int day) {
    return 'Day $day';
  }

  @override
  String get plansLegendDone => 'Concluído';

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
  String get plansRestDays => 'Dias de descanso';

  @override
  String get plansNoRestDays => 'No rest days';

  @override
  String get plansSettings => 'Definições do plano';

  @override
  String get plansAboutEllipsis => 'Sobre este plano…';

  @override
  String get plansAbout => 'Sobre este plano';

  @override
  String get plansChangeStartDate => 'Mudar data de início…';

  @override
  String plansRestDaysValue(String days) {
    return 'Dias de descanso: $days';
  }

  @override
  String get plansRestDaysHelp => 'Toque para escolher os dias da semana';

  @override
  String get plansRestartFromDayOne => 'Restart from day 1…';

  @override
  String get plansRestartTitle => 'Reiniciar o plano?';

  @override
  String get plansRestartBody => 'Os dias concluídos serão apagados.';

  @override
  String get plansRestart => 'Reiniciar';

  @override
  String get plansMarkUnread => 'Marcar como não lido';

  @override
  String get plansMarkRead => 'Marcar como lido';

  @override
  String get plansRestAndReflect => 'Descanse e reflita';

  @override
  String get plansRestDayBody => 'A day of rest — no reading assigned today.';

  @override
  String get plansDayDetailHelp =>
      'Toque numa passagem para a abrir. Assinale cada uma enquanto lê.';

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
  String get todaySectionResume => 'RETOMAR';

  @override
  String get todaySectionStreak => 'SEQUÊNCIA DE LEITURA';

  @override
  String get todaySectionLatestNote => 'ÚLTIMA NOTA';

  @override
  String get todaySectionQuickActions => 'AÇÕES RÁPIDAS';

  @override
  String get todaySectionReminders => 'LEMBRETES DIÁRIOS';

  @override
  String get todayTagline => 'O teu momento de paz diário.';

  @override
  String get todayNoNotesYet => 'Ainda não há notas';

  @override
  String get todayWriteFirstNote =>
      'Escreva a sua primeira nota para a ver aqui.';

  @override
  String get todayViewAllNotes => 'Ver todas as notas';

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
  String get todayActionRead => 'Ler';

  @override
  String get todayActionSurprise => 'Surpreenda-me';

  @override
  String get todayActionReadingPlan => 'Plano de leitura';

  @override
  String get todayActionYourSpace => 'O teu espaço';

  @override
  String get todayVotdArchive => 'Verse of the day archive';

  @override
  String get todayVotdArchiveBody =>
      'Recupere os versículos dos dias que perdeu.';

  @override
  String get todayVotdArchiveExplore =>
      'Explore os seus versículos diários anteriores';

  @override
  String get readActionBookmark => 'Favorito';

  @override
  String get readActionNote => 'Nota';

  @override
  String get readActionNotes => 'Notas';

  @override
  String get readActionEditNote => 'Edit note';

  @override
  String get readActionCommentary => 'Comentário';

  @override
  String get readActionRelated => 'Relacionados';

  @override
  String get readActionHighlight => 'Realçar';

  @override
  String get readActionStudy => 'Estudo';

  @override
  String get readActionSaved => 'Guardado';

  @override
  String get readActionSelectText => 'Select text';

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
  String get readPassageNotFound => 'Passagem não encontrada.';

  @override
  String get readChapterCommentary => 'Ler o comentário deste capítulo';

  @override
  String readEndOfChapter(String reference) {
    return '· Fim de $reference ·';
  }

  @override
  String get readPreviousChapter => '‹ Anterior';

  @override
  String get readNextChapter => 'Seguinte ›';

  @override
  String readPlanDay(int day) {
    return 'Plano de leitura · Dia $day';
  }

  @override
  String get readPlanCompleted => 'Plano concluído! Parabéns! 🎉';

  @override
  String readMarkDoneContinue(String book, int chapter) {
    return 'Marcar $book $chapter como concluído e continuar';
  }

  @override
  String get readNone => 'Nenhum';

  @override
  String readBookFallback(int number) {
    return 'Book $number';
  }

  @override
  String get readRelatedVerses => 'Related verses';

  @override
  String get readNoCrossRefs =>
      'Não foram encontradas referências cruzadas para este versículo.';

  @override
  String get readCrossRefsComingSoon =>
      'Cross-references will be available\nafter the next app update.';

  @override
  String get readVerseUnavailable => 'Verse not available';

  @override
  String get readLoading => 'A carregar…';

  @override
  String get readVerseNotFound => 'Versículo não encontrado.';

  @override
  String get readBookOrChapterNotFound => 'Book or chapter not found.';

  @override
  String get readOpenInRead => 'Abrir em Ler';

  @override
  String get readBookNotFound =>
      'Não foi possível encontrar o livro referenciado.';

  @override
  String get readTestament => 'Testament';

  @override
  String get readBook => 'Book';

  @override
  String get readChapter => 'Chapter';

  @override
  String get readVerse => 'Verse';

  @override
  String get readSelectBook => 'Select book';

  @override
  String get readOtShort => 'OT';

  @override
  String get readNtShort => 'NT';

  @override
  String get readOldTestament => 'Antigo Testamento';

  @override
  String get readNewTestament => 'Novo Testamento';

  @override
  String get readOldTestamentTwoLine => 'Antigo Testamento';

  @override
  String get readNewTestamentTwoLine => 'Novo Testamento';

  @override
  String get readStoriesSections => 'Stories & sections';

  @override
  String get readAllVerses => 'All verses';

  @override
  String get readTranslationTitle => 'Bible translation';

  @override
  String get readLayoutTitle => 'Reading layout';

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
  String readTranslationDeleted(String name) {
    return '$name eliminados.';
  }

  @override
  String readDeleteTranslation(String name) {
    return 'Eliminar $name';
  }

  @override
  String get readKjvAlwaysAvailable => 'Always available · app backbone';

  @override
  String get readCannotDeleteBackbone => 'Não é possível excluir — base do app';

  @override
  String get readAvailableToAdd => 'DISPONÍVEL PARA ADICIONAR';

  @override
  String get readNoInternet =>
      'No internet connection — try again when online.';

  @override
  String get readRestoreFailed => 'Restore failed';

  @override
  String get readDownloadFailed => 'Download failed';

  @override
  String get readRestoreOffline => 'restore offline';

  @override
  String get homeVerseOfTheDay => 'VERSÍCULO DO DIA';

  @override
  String get homeDevotional => 'DEVOTIONAL';

  @override
  String get homeCommentary => 'COMMENTARY';

  @override
  String get homeGoDeeper => 'Go deeper';

  @override
  String get homeReadFullDefinition => 'Read full definition';

  @override
  String get homeWordOfTheDayHeading => 'PALAVRA DO DIA';

  @override
  String get homeWordOfTheDay => 'Palavra do dia';

  @override
  String get homeWotdEmpty => 'No word picked for today yet — try again later.';

  @override
  String get homeStoryOfTheDayHeading => 'STORY OF THE DAY';

  @override
  String get homeStoryOfTheDay => 'Story of the day';

  @override
  String get homeReadStory => 'Read story';

  @override
  String get homeStoryEmpty => 'No story available for today.';

  @override
  String get navHome => 'Home';

  @override
  String get navRead => 'Ler';

  @override
  String get navStudy => 'Estudo';

  @override
  String get navSearch => 'Pesquisar';

  @override
  String get navExitTitle => 'Sair do The Blessed Bible?';

  @override
  String get navExitMessage => 'Tem certeza de que deseja sair do app?';

  @override
  String get navExit => 'Sair';

  @override
  String get navCastLotsError => 'Não foi possível sortear — tente novamente.';

  @override
  String get navCastingLots => 'Sorteando...';

  @override
  String get searchHint => 'Search verses, commentary…';

  @override
  String get searchAllBooks => 'Todos os livros';

  @override
  String get searchFilterMyNotes => 'My notes';

  @override
  String get searchEmptyPrompt =>
      'Search the Bible, commentary\nand your notes';

  @override
  String get searchRecentSearches => 'PESQUISAS RECENTES';

  @override
  String get searchClear => 'LIMPAR';

  @override
  String get searchRecentPlaces => 'LUGARES RECENTES';

  @override
  String get searchMostRead => 'MAIS LIDOS';

  @override
  String get searchNoResults => 'Não foram encontrados resultados';

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
  String get searchCopied => 'Copiado para a área de transferência';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsTabGeneral => 'Geral';

  @override
  String get settingsTabNavigation => 'Navegação';

  @override
  String get settingsTabReminders => 'Lembretes';

  @override
  String get settingsTabInfo => 'Informação';

  @override
  String get settingsWidgetsTitle => 'Home screen widgets';

  @override
  String get settingsWidgetsSubtitle =>
      'Personalizar gradientes, transparência e pré-visualização ao vivo';

  @override
  String get settingsStartPageTitle => 'Página inicial padrão';

  @override
  String get settingsStartPageSubtitle =>
      'Escolha a página que o app abre ao iniciar';

  @override
  String get settingsPageHome => 'Home';

  @override
  String get settingsPageRead => 'Ler';

  @override
  String get settingsPageStudy => 'Estudo';

  @override
  String get settingsPageSearch => 'Pesquisar';

  @override
  String get settingsImmersiveReading => 'Immersive reading';

  @override
  String get settingsImmersiveOffTitle => 'Anchored (off)';

  @override
  String get settingsImmersiveOffSubtitle =>
      'A navegação permanece sempre visível';

  @override
  String get settingsImmersivePartialTitle => 'Guided (partial)';

  @override
  String get settingsImmersivePartialSubtitle =>
      'Auto-hides main navigation, but leaves the book & chapter pill';

  @override
  String get settingsImmersiveFullTitle => 'Águas profundas (Completo)';

  @override
  String get settingsImmersiveFullSubtitle =>
      'Imersão total. Todos os menus ocultam-se ao deslocar';

  @override
  String get settingsShowStrongs => 'Show Strong\'s numbers';

  @override
  String get settingsShowStrongsSubtitle =>
      'Mostra os identificadores originais hebraicos/gregos ao lado do texto KJV para estudo profundo de palavras';

  @override
  String get settingsStrongsGetIt => 'Obter';

  @override
  String get settingsStrongsMarkerAsterisk => 'Asterisco (*)';

  @override
  String get settingsStrongsMarkerChain => 'Cadeia (🔗)';

  @override
  String get settingsStrongsMarkerNumber => 'Número (H1234)';

  @override
  String get settingsReadingSpeed => 'Velocidade de leitura';

  @override
  String get settingsReadingSpeedSubtitle =>
      'Estimativas de ritmo para os planos (palavras por minuto)';

  @override
  String get settingsSpeedRelaxed => 'Relaxado';

  @override
  String get settingsSpeedStandard => 'Padrão';

  @override
  String get settingsSpeedBrisk => 'Ágil';

  @override
  String get settingsDictUnderlines => 'Dictionary underlines';

  @override
  String get settingsDictUnderlinesSubtitle =>
      'Sublinhados pontilhados em termos bíblicos e palavras arcaicas';

  @override
  String get settingsUnderlineScope => 'Underline scope';

  @override
  String get settingsScopeNamesTitle => 'Apenas nomes e termos';

  @override
  String get settingsScopeNamesSubtitle =>
      'Nomes próprios e conceitos bíblicos específicos';

  @override
  String get settingsScopeTrickyTitle => 'Names + tricky words (recommended)';

  @override
  String get settingsScopeTrickySubtitle =>
      'Inclui palavras arcaicas com significado alterado (ex.: let, prevent)';

  @override
  String get settingsScopeEverythingTitle => 'Tudo';

  @override
  String get settingsScopeEverythingSubtitle =>
      'Realça toda a gramática arcaica (ex.: thee, thou, hath, unto)';

  @override
  String get settingsScopeDifficultTitle => 'Somente palavras difíceis';

  @override
  String get settingsScopeDifficultSubtitle =>
      'Archaic, misleading and contested words — easy words like god and son stay unmarked';

  @override
  String get settingsScopeDifficultNamesTitle => 'Difíceis + nomes';

  @override
  String get settingsScopeDifficultNamesSubtitle =>
      'Adds people and places (e.g., David, Jerusalem) to difficult words';

  @override
  String get settingsOtherEnglishVersions => 'Outras versões em inglês';

  @override
  String get settingsContestedOnlyTitle => 'Somente palavras contestadas';

  @override
  String get settingsContestedOnlySubtitle =>
      'BBE, WEB and other English versions mark disputed words (e.g., hell, baptism)';

  @override
  String get settingsFollowScopeTitle => 'Seguir o âmbito de sublinhado';

  @override
  String get settingsFollowScopeSubtitle =>
      'Same marking as KJV in every English version';

  @override
  String get settingsNoUnderlinesTitle => 'Sem sublinhados';

  @override
  String get settingsNoUnderlinesSubtitle =>
      'As outras versões em inglês não mostram marcas de dicionário';

  @override
  String get settingsPopupStyle => 'Popup style';

  @override
  String get settingsPopupStyleSubtitle =>
      'How dictionary definitions and Strong\'s numbers are displayed';

  @override
  String get settingsPopupFloating => 'Floating';

  @override
  String get settingsPopupBottomSheet => 'Bottom sheet';

  @override
  String get settingsSavedInMyLanguage =>
      'Mostrar os itens guardados no meu idioma';

  @override
  String get settingsSavedInMyLanguageSubtitle =>
      'Mostrar favoritos, realces e versículos de comentário na sua tradução principal ativa';

  @override
  String get settingsTranslationChips =>
      'Mostrar opções de tradução nos itens guardados';

  @override
  String get settingsTranslationChipsSubtitle =>
      'Adiciona uma fileira compacta de chips de tradução para ver os versículos salvos em outras traduções';

  @override
  String get settingsVerseActionStyle => 'Verse action style';

  @override
  String get settingsVerseActionStyleSubtitle =>
      'Sheet (compact) or Classic (tall dock) when verses are selected; Radial moves the long-press menu to a circular ring';

  @override
  String get settingsCommentaryStyle => 'Commentary look';

  @override
  String get settingsCommentaryStyleSubtitle =>
      'How commentary pages are laid out. Classic keeps the previous design.';

  @override
  String get settingsCommentaryRefined => 'Refined';

  @override
  String get settingsCommentaryClassic => 'Classic';

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
  String get settingsKeepAwake => 'Keep screen awake';

  @override
  String get settingsKeepAwakeSubtitle =>
      'Impedir que o dispositivo adormeça enquanto lê';

  @override
  String get settingsRestartOnboarding => 'Reiniciar a introdução';

  @override
  String get settingsRestartOnboardingSubtitle =>
      'Repetir a configuração inicial';

  @override
  String get settingsRestartOnboardingDialogTitle => 'Reiniciar a introdução?';

  @override
  String get settingsRestartOnboardingDialogBody =>
      'Isto repete a configuração inicial. O seu tema, tipo de letra e tradução atuais mantêm-se, a menos que os altere.';

  @override
  String get settingsRestart => 'Reiniciar';

  @override
  String get settingsAppearanceText => 'Aparência e texto';

  @override
  String get settingsAppearanceTextSubtitle =>
      'Tema, tipos de letra, tamanhos e cores de leitura';

  @override
  String get settingsSabbathTitle => 'Friday sunset reminder';

  @override
  String get settingsSabbathSubtitle =>
      'Bem-vindo ao sábado à hora do pôr do sol local.';

  @override
  String get settingsLocation => 'Localização';

  @override
  String get settingsLocationNotSet => 'Not set (tap to set)';

  @override
  String get settingsDailyReminderTitle => 'Daily reading reminder';

  @override
  String get settingsDailyReminderSubtitle =>
      'Um lembrete diário para dedicar tempo à Palabra.';

  @override
  String get settingsTime => 'Hora';

  @override
  String get settingsWeeklyReminderTitle => 'Custom weekly reminder';

  @override
  String get settingsWeeklyReminderSubtitle =>
      'Defina um dia e uma hora específica cada semana para um estudo mais profundo.';

  @override
  String get settingsDayAndTime => 'Day & time';

  @override
  String get settingsChooseDay => 'Choose day';

  @override
  String get settingsShowReadingTips => 'Mostrar dicas de leitura';

  @override
  String get settingsShowReadingTipsSubtitle =>
      'Mostrar dicas guiadas para ações de leitura como realçar e deslizar';

  @override
  String get settingsNavSteps => 'Navigation steps';

  @override
  String get settingsNavStepsSubtitle =>
      'How many steps to reach a verse. 2-step: Book → Chapter. 3-step: Book → Chapter → Verse. 4-step: Testament → Book → Chapter → Verse.';

  @override
  String get settingsAutoClose =>
      'Fechar automaticamente o painel na seleção final';

  @override
  String get settingsAutoCloseSubtitle =>
      'Dispensar automaticamente o seletor após o último passo';

  @override
  String get settingsSelectorHeight => 'Altura do seletor de livro';

  @override
  String get settingsSelectorHeightSubtitle =>
      'Controle quão alto o painel de livro/capítulo abre';

  @override
  String get settingsHeightHalf => 'Metade';

  @override
  String get settingsHeightFull => 'Full';

  @override
  String get settingsAutoOpenSingle =>
      'Abrir automaticamente o único resultado de busca';

  @override
  String get settingsAutoOpenSingleSubtitle =>
      'Navegar automaticamente quando uma busca retorna exatamente um resultado';

  @override
  String get settingsIncludeNotes =>
      'Incluir as suas notas pessoais na pesquisa';

  @override
  String get settingsIncludeNotesSubtitle =>
      'Permitir que a busca pesquise nas suas notas pessoais';

  @override
  String get settingsWholeWords =>
      'Correspondência apenas de palavras inteiras';

  @override
  String get settingsWholeWordsSubtitle =>
      'Procurar apenas correspondências exatas de palavras (desativa as correspondências parciais ou por prefixo)';

  @override
  String get settingsFuzzySearch => 'Busca indulgente';

  @override
  String get settingsFuzzySearchSubtitle =>
      'Mostrar também correspondências próximas para erros de digitação (ex.: Jhon encontra John)';

  @override
  String get settingsDefaultScopes => 'Default search scopes';

  @override
  String get settingsOldTestament => 'Antigo Testamento';

  @override
  String get settingsNewTestament => 'Novo Testamento';

  @override
  String get settingsCommentary => 'Comentário';

  @override
  String get settingsGestures => 'Gestos';

  @override
  String get settingsPullDownHome => 'Puxar para baixo no Início';

  @override
  String get settingsPullDownHomeSubtitle =>
      'Puxe para baixo para além do topo para abrir Definições ou Aparência';

  @override
  String get settingsPullDownOpens => 'Puxar para baixo abre';

  @override
  String get settingsPullDownOpensSubtitle =>
      'Destino do gesto de puxar para baixo na página inicial';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsSwipeLeftHome => 'Deslize para a esquerda no Início';

  @override
  String get settingsSwipeLeftHomeSubtitle =>
      'Deslize para a esquerda para ir para o separador Ler';

  @override
  String get settingsLongPressNav => 'Prima longamente para abrir a navegação';

  @override
  String get settingsLongPressNavSubtitle =>
      'Prima longamente o botão inferior direito para abrir rapidamente o seletor Livro/Capítulo.';

  @override
  String get settingsBbeNoteTitle => 'BBE translation note';

  @override
  String get settingsBackup => 'Fazer backup dos meus dados';

  @override
  String get settingsBackupSubtitle =>
      'Exportar notas, realces e configurações';

  @override
  String get settingsRestoreBackup =>
      'Restaurar a partir de uma cópia de segurança';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Importe os seus dados a partir de uma cópia de segurança JSON';

  @override
  String get settingsRestoreBackupDialogTitle =>
      'Restaurar a partir de uma cópia de segurança';

  @override
  String get settingsRestoreHint =>
      'Cole aqui a sua cópia de segurança JSON...';

  @override
  String get settingsRestore => 'Restaurar';

  @override
  String get settingsClearCache => 'Limpar cache/dados baixados';

  @override
  String get settingsClearCacheSubtitle =>
      'Libere espaço removendo arquivos em cache';

  @override
  String get settingsNotImplemented => 'Ainda não implementado';

  @override
  String get settingsResetSettings => 'Repor as definições';

  @override
  String get settingsResetSettingsSubtitle =>
      'Restaurar as definições originais da aplicação (o conteúdo é mantido)';

  @override
  String get settingsResetDialogTitle => 'Repor as definições?';

  @override
  String get settingsResetDialogBody =>
      'Reset all settings to default? This won\'t affect your bookmarks, notes, or highlights.';

  @override
  String get settingsResetDone => 'Definições repostas para o predefinido.';

  @override
  String get settingsReset => 'Repor';

  @override
  String get settingsVersion => 'Versão';

  @override
  String get settingsUnknown => 'Desconhecido';

  @override
  String get settingsStorage => 'Armazenamento e transferências';

  @override
  String get settingsStorageSubtitle =>
      'Cache, traduções baixadas e o que pode ser liberado';

  @override
  String get settingsSendFeedback => 'Send feedback';

  @override
  String get settingsCrashReports => 'Send crash reports';

  @override
  String get settingsCrashReportsSubtitle =>
      'Anonymous crash details help fix bugs. No Bible reading, notes or personal content is included.';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsCredits => 'Credits & sources';

  @override
  String get settingsCreditsSubtitle =>
      'Bible translations, commentary, study data, fonts and licenses';

  @override
  String get settingsSetSunsetLocation => 'Set location for sunset';

  @override
  String get settingsCurrentLocationGps => 'Current location (GPS)';

  @override
  String get settingsUseMyLocation => 'Usar a minha localização atual';

  @override
  String get settingsOrSelectCity => 'OU selecione uma cidade importante';

  @override
  String get settingsTypography => 'Tipografia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsSearchSettings => 'Search settings';

  @override
  String get settingsMatchTypeHeader => 'TIPO DE CORRESPONDÊNCIA';

  @override
  String get settingsExactMatch => 'Exact match';

  @override
  String get settingsExactMatchSubtitle =>
      'Correspondência apenas da frase exata';

  @override
  String get settingsScopeHeader => 'ÂMBITO';

  @override
  String get settingsDisabledBookFilter => 'Disabled (book filter active)';

  @override
  String get settingsMyNotes => 'My notes';

  @override
  String get settingsBehaviorHeader => 'COMPORTAMENTO';

  @override
  String get settingsAutoOpenSingleShort => 'Auto-open single result';

  @override
  String get settingsAutoOpenSingleShortSubtitle =>
      'Ir direto se for encontrado apenas um resultado';

  @override
  String get settingsBackgroundGlow => 'Enable background glow';

  @override
  String get settingsBackgroundGlowSubtitle =>
      'Mostra uma subtil luz animada por trás do leitor';

  @override
  String settingsThemeDailyToday(String theme) {
    return 'Hoje: $theme';
  }

  @override
  String get settingsThemeGroupFoundations => 'FUNDAMENTOS';

  @override
  String get settingsThemeDawn => 'Alvor';

  @override
  String get settingsThemeFresh => 'Fresco';

  @override
  String get settingsThemeGroupFirmament => 'FIRMAMENTO';

  @override
  String get settingsThemeSun => 'dom';

  @override
  String get settingsThemeMoon => 'Lua';

  @override
  String get settingsThemeStars => 'Estrelas';

  @override
  String get settingsThemeGroupEden => 'EDEN';

  @override
  String get settingsThemeLilies => 'Lírios';

  @override
  String get settingsThemeRoses => 'Rosas';

  @override
  String get settingsThemeOlives => 'Oliveiras';

  @override
  String get settingsThemeGroupSanctuary => 'SANTUÁRIO';

  @override
  String get settingsThemePurple => 'Priestly\nPurple';

  @override
  String get settingsThemeBlue => 'Galilee\nBlue';

  @override
  String get settingsThemeRed => 'Scarlet\nRed';

  @override
  String get settingsSurpriseMe => 'Surpreenda-me';

  @override
  String get settingsThemeOledDark => 'OLED\nDark';

  @override
  String get settingsThemeDuskOled => 'Dusk\nOLED';

  @override
  String get settingsSurfaceStyle => 'Surface style';

  @override
  String get settingsSurfaceStyleSubtitle =>
      'Profundidade visual e renderização de materiais';

  @override
  String get settingsSurfaceEarth => 'Terra';

  @override
  String get settingsSurfaceEarthSubtitle => 'Superfície plana';

  @override
  String get settingsSurfaceHeaven => 'Céus';

  @override
  String get settingsSurfaceHeavenSubtitle => 'Profundidade gelada';

  @override
  String get settingsSurfacePaper => 'Papel';

  @override
  String get settingsSurfacePaperSubtitle => 'Leitor eletrónico quente';

  @override
  String get settingsSurfaceClay => 'Argila';

  @override
  String get settingsSurfaceClaySubtitle => 'Acolchoado 3D';

  @override
  String get settingsWidgetsLivePreview =>
      'Pré-visualização ao vivo e personalização do estilo';

  @override
  String get settingsWidgetPreviewHeader =>
      'PRÉ-VISUALIZAÇÃO AO VIVO DO WIDGET';

  @override
  String get settingsWidgetStreak => 'Streak active! • Daily goal';

  @override
  String get settingsWidgetWotd => 'PALAVRA DO DIA';

  @override
  String get settingsWidgetVotd => 'VERSÍCULO DO DIA';

  @override
  String get settingsWidgetBackgroundHeader => 'TEMA E GRADIENTES DE FUNDO';

  @override
  String get settingsWidgetContrastHeader => 'CONTRASTE DO TEXTO';

  @override
  String get settingsWidgetTextAuto => 'Auto ✨';

  @override
  String get settingsWidgetTextDark => 'Dark text ☀️';

  @override
  String get settingsWidgetTextWhite => 'White text 🌙';

  @override
  String get settingsWidgetSynced => 'Widgets synced with new style! ✨';

  @override
  String get settingsWidgetApply => 'Apply & sync to home screen';

  @override
  String get settingsFontSizeHeader => 'TAMANHO DA FONTE';

  @override
  String get settingsFontWeightHeader => 'PESO DA FONTE';

  @override
  String get settingsWeightLight => 'Light';

  @override
  String get settingsWeightRegular => 'Regular';

  @override
  String get settingsWeightMedium => 'Medium';

  @override
  String get settingsWeightBold => 'Bold';

  @override
  String get settingsLineSpacingHeader => 'ESPAÇAMENTO DE LINHA';

  @override
  String get settingsSpacingCompact => 'Compact';

  @override
  String get settingsSpacingNormal => 'Normal';

  @override
  String get settingsMarginsHeader => 'MARGENS';

  @override
  String get settingsAlignmentHeader => 'ALINHAMENTO';

  @override
  String get settingsAlignLeft => 'Left';

  @override
  String get settingsAlignCenter => 'Center';

  @override
  String get settingsAlignRight => 'Right';

  @override
  String get settingsAlignJustified => 'Justified';

  @override
  String get settingsFontFamilyHeader => 'FAMÍLIA DE FONTES';

  @override
  String get settingsItalicHeader => 'TEXTO DE LEITURA EM ITÁLICO';

  @override
  String get settingsDailyReading => 'Daily reading';

  @override
  String get settingsCustomReminder => 'Custom reminder';

  @override
  String get settingsMonday => 'Segunda-feira';

  @override
  String get settingsTuesday => 'Terça-feira';

  @override
  String get settingsWednesday => 'Quarta-feira';

  @override
  String get settingsThursday => 'Quinta-feira';

  @override
  String get settingsFriday => 'Sexta-feira';

  @override
  String get settingsSaturday => 'Sábado';

  @override
  String get settingsSunday => 'Domingo';

  @override
  String settingsStrongsPackRequired(String size) {
    return 'Requires the “KJV with Strong\'s” pack ($size download).';
  }

  @override
  String settingsBbeNoteBody(int count) {
    return 'A Bíblia em inglês simples deixou inicialmente alguns versículos por traduzir ou muito truncados. Para esses ($count versículos), é mostrado o texto da World English Bible (WEB), marcado com um emblema WEB.';
  }

  @override
  String settingsDayAtTime(String day, String time) {
    return '$day at $time';
  }

  @override
  String get spaceTitle => 'O teu espaço';

  @override
  String get spaceTabHighlights => 'Realces';

  @override
  String get spaceTabBookmarks => 'Favoritos';

  @override
  String get spaceTabNotes => 'Notas';

  @override
  String get spaceTabJournal => 'Diário';

  @override
  String get spaceHighlighted => 'Realçado';

  @override
  String get spaceNewFolder => 'New folder';

  @override
  String get spaceFolderNameHint => 'Nome da pasta';

  @override
  String get spaceCreate => 'Criar';

  @override
  String get spaceRenameFolder => 'Rename folder';

  @override
  String get spaceRename => 'Renomear';

  @override
  String get spaceDeleteFolderTitle => 'Excluir pasta?';

  @override
  String spaceDeleteFolderBody(String folderName) {
    return 'Are you sure you want to delete \"$folderName\"?\n\nYour bookmarks inside this folder will NOT be deleted; they will be moved to Unfiled.';
  }

  @override
  String get spaceMoveToFolder => 'Mover para a pasta';

  @override
  String get spaceUnfiled => 'Sem pasta';

  @override
  String get spaceGroupEarlier => 'Earlier';

  @override
  String get spaceGroupLast7Days => 'Last 7 days';

  @override
  String get spaceGroupLast30Days => 'Last 30 days';

  @override
  String get spaceUnknownBook => 'Unknown book';

  @override
  String get spaceNoBookmarks => 'Não há marcadores aqui.';

  @override
  String get spaceFilterAll => 'Todos';

  @override
  String get spaceByDate => 'By date';

  @override
  String get spaceByBook => 'By book';

  @override
  String get spaceYourNotes => 'As suas notas.';

  @override
  String get spaceNoNotesTapPlus => 'No notes yet.\nTap + to create one.';

  @override
  String get spaceMore => 'Mais';

  @override
  String get spaceNote => 'Nota';

  @override
  String get spaceCopyText => 'Copiar texto';

  @override
  String get spaceUntitled => 'Untitled';

  @override
  String get spaceBookmarkedVerse => 'Versículo salvo';

  @override
  String get spaceHighlightedVerse => 'Versículo realçado';

  @override
  String get spaceOpenInRead => 'Abrir em Ler';

  @override
  String get spaceAddNote => 'Adicionar nota';

  @override
  String get spaceCopyVerse => 'Copiar versículo';

  @override
  String get spaceShareVerse => 'Partilhar versículo';

  @override
  String get spaceChangeColour => 'Change color';

  @override
  String get spaceMoveToFolderAction => 'Mover para a pasta';

  @override
  String get spaceRemoveBookmark => 'Remover marcador';

  @override
  String get spaceRemoveHighlight => 'Remover realce';

  @override
  String get spaceHighlightColour => 'Highlight color';

  @override
  String spaceColourN(int index) {
    return 'Color $index';
  }

  @override
  String get notesMyNotes => 'My notes';

  @override
  String get notesEmptyTitle => 'Ainda não há notas';

  @override
  String get notesEmptyBody =>
      'Toque no botão + para adicionar a sua primeira nota.';

  @override
  String get notesVerseInserted => 'Versículo inserido';

  @override
  String get notesAddCommentary => 'Add commentary';

  @override
  String get notesChapterTitlePlaceholder => 'Chapter title';

  @override
  String get notesEditNote => 'Edit note';

  @override
  String notesNewNoteOn(String reference) {
    return 'New Note on $reference';
  }

  @override
  String get notesNewNote => 'New note';

  @override
  String get notesTitleHint => 'Note title';

  @override
  String get notesContentHint =>
      'Comece a escrever... (escreva / para os comandos)';

  @override
  String get notesInsertVerse => 'Inserir o versículo';

  @override
  String get notesInsertDate => 'Inserir a data';

  @override
  String get notesInsertChapterTitle => 'Inserir o título do capítulo';

  @override
  String get notesSaved => 'Nota guardada!';

  @override
  String get notesSaveChanges => 'Save changes';

  @override
  String get notesSaveNote => 'Save note';

  @override
  String get notesDeleted => 'Nota eliminada';

  @override
  String get notesDeleteNote => 'Delete note';

  @override
  String get notesNewJournalEntry => 'New journal entry';

  @override
  String get notesJournalHint =>
      'Como você está hoje? Despeje o seu coração...';

  @override
  String get notesSaveAndAnalyze => 'Save & analyze';

  @override
  String get notesNoJournalEntries => 'Ainda não há entradas no diário.';

  @override
  String get notesWriteEntry => 'Write entry';

  @override
  String get notesAiReflection => 'AI reflection';

  @override
  String notesDetectedEmotion(String emotion) {
    return 'Emoção detetada: $emotion';
  }

  @override
  String notesVersesList(String verses) {
    return 'Versículos: $verses';
  }

  @override
  String get accountGuest => 'Guest';

  @override
  String get accountSignInToSync => 'Sign in to sync across devices';

  @override
  String get accountAccount => 'Conta';

  @override
  String get accountSettings => 'Definições';

  @override
  String get accountBackUp => 'Fazer backup dos dados';

  @override
  String get accountBackUpSubtitle => 'Exportar notas, realces e configurações';

  @override
  String get accountRestore => 'Restaurar os dados';

  @override
  String get accountRestoreSubtitle =>
      'Importar de um ficheiro de cópia de segurança';

  @override
  String get accountSignInGoogle => 'Iniciar sessão com o Google';

  @override
  String get accountSignInApple => 'Iniciar sessão com a Apple';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountResetApp => 'Repor a aplicação';

  @override
  String get accountResetAppSubtitle => 'Apagar todos os dados do dispositivo';

  @override
  String get accountSignIn => 'Sign in';

  @override
  String get accountSignedIn => 'Signed in';

  @override
  String get accountDeleteAccount => 'Delete account';

  @override
  String get accountDeleteAccountTitle => 'Excluir conta?';

  @override
  String get accountDeleteAccountBody =>
      'This is permanent and irreversible.\n\nThe following will be completely removed:\n• Your sign-in account\n• Its cloud data in The Blessed Bible and Blessed Arcade (they share the account)\n• All on-device study data (bookmarks, highlights, history)';

  @override
  String get accountDeleted => 'Conta excluída com sucesso.';

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
  String get accountRestoreTitle =>
      'Restaurar a partir de uma cópia de segurança';

  @override
  String get accountRestoreHint => 'Cole aqui a sua cópia de segurança JSON...';

  @override
  String get accountRestoreAction => 'Restaurar';

  @override
  String get accountResetTitle => 'Repor a aplicação?';

  @override
  String get accountResetBody =>
      'This erases all on-device data:\n• Bookmarks, highlights, notes & journal\n• Reading plans, progress & custom plans\n• Downloaded translations & streaks\n\nSettings, theme and the offline Bible stay untouched. This cannot be undone — back up first if needed.';

  @override
  String get accountResetDone => 'Dados do app redefinidos. Novo começo!';

  @override
  String get accountReset => 'Repor';

  @override
  String get shareBackdrop => 'Fundo';

  @override
  String get shareBackdropDawn => 'Alvor';

  @override
  String get shareBackdropDusk => 'Dusk';

  @override
  String get shareBackdropArtwork => 'Artwork';

  @override
  String get shareBackdropGradient => 'Gradient';

  @override
  String get shareFont => 'Fonte';

  @override
  String get shareFontTheme => 'Tema';

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
  String get shareText => 'Partilhar texto';

  @override
  String get shareImageCard => 'Partilhar cartão de imagem';

  @override
  String get shareModeText => 'Text';

  @override
  String get shareModeImage => 'Image';

  @override
  String get shareModePdf => 'PDF';

  @override
  String get shareFormat => 'Format';

  @override
  String get shareFlavorPlain => 'Plain text';

  @override
  String get shareFlavorWhatsapp => 'WhatsApp';

  @override
  String get shareFlavorPlainHint => 'No markup — pastes cleanly anywhere.';

  @override
  String get shareFlavorWhatsappHint =>
      'Bold headings and italic references, styled by WhatsApp.';

  @override
  String get shareIncludeReference => 'Include reference';

  @override
  String get shareFormatPortrait => 'Portrait';

  @override
  String get shareFormatSquare => 'Square';

  @override
  String get shareFormatStory => 'Story';

  @override
  String get shareStyle => 'Style';

  @override
  String get sharePdfTitle => 'Print-ready PDF';

  @override
  String get sharePdfBody =>
      'The complete text on a typeset page, with the reference and source. Ready to read, print or send.';

  @override
  String get shareSharePdf => 'Share PDF';

  @override
  String get shareBuildingPdf => 'Building PDF…';

  @override
  String get shareFailed => 'Couldn\'t share — please try again.';

  @override
  String get shareSaveImage => 'Save to gallery';

  @override
  String get shareSavedToGallery => 'Saved to your gallery';

  @override
  String get shareGalleryDenied => 'Allow photo access to save images.';

  @override
  String get shareSaveFailed => 'Couldn\'t save the image — please try again.';

  @override
  String get sharePdfPreviewNote => 'Page 1 preview · A4';

  @override
  String get spaceStorageTitle => 'Armazenamento';

  @override
  String get spaceClearCacheTitle => 'Limpar cache?';

  @override
  String get spaceClearCacheBody =>
      'Removes temporary files (generated share cards, thumbnails). Your notes, bookmarks, highlights and downloads are untouched.';

  @override
  String get spaceClearCache => 'Limpar cache';

  @override
  String get spaceCacheCleared => 'Cache cleared';

  @override
  String spaceDeletePackTitle(String name) {
    return 'Eliminar $name?';
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
  String spaceFreed(String message, String size) {
    return '$message · freed $size';
  }

  @override
  String get spaceOnThisDevice => 'Neste dispositivo';

  @override
  String get spaceBibleContent => 'Conteúdo bíblico (sempre mantido)';

  @override
  String get spaceDownloadedPacks => 'Pacotes baixados';

  @override
  String get spaceCache => 'Cache';

  @override
  String get spaceCacheExplain =>
      'Temporary files only — generated share cards and thumbnails. Safe to clear at any time.';

  @override
  String get spaceTranslationsDownloads => 'Traduções e transferências';

  @override
  String get spaceBundledSuffix => ' · bundled';

  @override
  String get spaceCoreNotRemovable =>
      'Core KJV and BBE are part of the app and can\'t be removed.';

  @override
  String get spaceGet => 'Obter';

  @override
  String spaceDeletePackTooltip(String name) {
    return 'Eliminar $name';
  }

  @override
  String get welcomeBackTitle => 'Welcome back';

  @override
  String get welcomeBackBody =>
      'Sign in to bring back your highlights, notes, bookmarks and reading plans.';

  @override
  String get stateLoading => 'Loading';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateErrorBody => 'Please try again in a moment.';

  @override
  String get commonUndo => 'Undo';

  @override
  String get spaceHighlightsIntro => 'Verses you\'ve marked in color.';

  @override
  String get storiesShowPassageTitle => 'Show scripture in stories';

  @override
  String get storiesShowPassageSubtitle =>
      'Print the full passage above each story. When off, tap the reference to read it.';

  @override
  String storiesOpenPassage(String reference) {
    return 'Read $reference';
  }

  @override
  String get storiesHighlight => 'Realçar';

  @override
  String get storiesUnderline => 'Underline';

  @override
  String get storiesRemoveMark => 'Remove mark';

  @override
  String storiesNextUp(String title) {
    return 'Next: $title';
  }

  @override
  String storiesInBook(String book) {
    return 'Stories in $book';
  }

  @override
  String get storiesMarkAsUnread => 'Mark as unread';

  @override
  String get storiesMarkedRead => 'Marked as read';

  @override
  String get storiesMarkedUnread => 'Marked as unread';

  @override
  String get storiesSavedToSpace => 'Saved to Your Space';

  @override
  String get storiesRemovedFromSaved => 'Removed from saved stories';

  @override
  String get storiesRemoveFromSaved => 'Remove from saved';

  @override
  String get spaceTabStories => 'Stories';

  @override
  String get spaceSavedStories => 'Saved stories';

  @override
  String get spaceStoryMarks => 'Highlights and underlines';

  @override
  String get spaceNoStories =>
      'No saved stories yet. Tap the bookmark on a story, or select its text to highlight it, and it will show up here.';

  @override
  String get storyOfTheDayOrderTitle => 'Story of the Day order';

  @override
  String get storyOfTheDayOrderSubtitle =>
      'Shuffled goes through all 500 stories without repeats. In order follows the Bible. Stories you have read are skipped.';

  @override
  String get storyOfTheDayOrderShuffled => 'Shuffled';

  @override
  String get storyOfTheDayOrderInOrder => 'In order';

  @override
  String get studyCardSize => 'Tamanho do cartão';

  @override
  String get studyPosition => 'Posição';

  @override
  String get studySizeLarge => 'Grande';

  @override
  String get studySizeLargeHint => 'Largura total, mesmo tamanho que tudo';

  @override
  String get studySizeExtraLarge => 'Extra large';

  @override
  String get studySizeExtraLargeHint => 'Largura total, conteúdo mais amplo';

  @override
  String get studySizeHalf => 'Metade';

  @override
  String get studySizeHalfHint => 'Compacto, dois por linha';

  @override
  String get studySizeFull => 'Full';

  @override
  String get studySizeFullHint => 'Full width, one per row';

  @override
  String get studyPresetLayout => 'Layout presets';

  @override
  String get studyPresetFull => 'All full';

  @override
  String get studyPresetHalf => 'All half';

  @override
  String get studyVerseOfTheDay => 'Versículo do dia';

  @override
  String get studyRecentVerses => 'Recent verses';

  @override
  String get studyWordLookUp => 'Pesquisar';

  @override
  String get studyConcordanceClear => 'Clear';

  @override
  String get studyConcordanceBrowseAll => 'Browse all terms';

  @override
  String get studyConcordanceFeatured => 'Featured biblical terms';

  @override
  String get studyConcordanceFilterAll => 'Todos';

  @override
  String get studyConcordanceFilterOT => 'Antigo Testamento';

  @override
  String get studyConcordanceFilterNT => 'Novo Testamento';

  @override
  String get studyMoveUp => 'Mover para cima';

  @override
  String get studyMoveUpHint => 'Trocar com o cartão acima';

  @override
  String get studyMoveDown => 'Mover para baixo';

  @override
  String get studyMoveDownHint => 'Trocar com o cartão abaixo';

  @override
  String get studyCommentaryEyebrow => 'Comentário';

  @override
  String get studyCommentaryTitle => 'Análise versículo por versículo';

  @override
  String get studyCommentarySnippet =>
      'Historicist commentary with chapter + verse filters.';

  @override
  String get studyCommentaryCta => 'Open commentary';

  @override
  String get studyDictionaryEyebrow => 'Dicionário';

  @override
  String get studyDictionaryTitle => 'Palavras definidas';

  @override
  String get studyDictionarySnippet =>
      'Easton & Smith, offline, with saved words.';

  @override
  String get studyDictionaryCta => 'Pesquisar';

  @override
  String get studyStoriesEyebrow => 'Bible stories';

  @override
  String get studyStoriesTitle => 'Narrativas recontaadas';

  @override
  String get studyStoriesSnippet => '66 stories across every book.';

  @override
  String get studyStoriesCta => 'Ler as narrativas';

  @override
  String get studyConcordanceEyebrow => 'Concordância';

  @override
  String get studyConcordanceTitle => 'Cada ocorrência';

  @override
  String get studyConcordanceSnippet => 'Find each verse where a word appears.';

  @override
  String get studyConcordanceCta => 'Pesquisar palavras';

  @override
  String get studySpaceSaved => 'Guardado';

  @override
  String get studySpaceMarked => 'Marked';

  @override
  String get studySpaceNotes => 'Notas';

  @override
  String get studySpaceJournal => 'Diário';

  @override
  String get studySpaceTitle => 'O teu espaço';

  @override
  String get studySpaceSubtitle => 'Favoritos, realces, notas e diário';

  @override
  String get studyReadingPlan => 'Plano de leitura';

  @override
  String get studyStartReadingPlan => 'Começar um plano de leitura';

  @override
  String get studyActivePlan => 'Plano ativo';

  @override
  String studyDayOfTotal(int current, int total) {
    return 'Dia $current de $total';
  }

  @override
  String studyDaysBehind(int count) {
    return '$count behind';
  }

  @override
  String get studyPlans => 'Planos';

  @override
  String get studyGuidedReading => 'Leitura guiada';

  @override
  String get studyGuidedReadingSubtitle =>
      'Selecionados, com ritmo e personalizados';

  @override
  String get studyReadyToBegin => 'Pronto para começar';

  @override
  String studyTodayLabel(String label) {
    return 'Hoje: $label';
  }

  @override
  String get studyReview => 'Review';

  @override
  String get studyRead => 'Ler';

  @override
  String studyCtaArrow(String cta) {
    return '$cta →';
  }

  @override
  String get studyWordOfTheDay => 'Palavra do dia';

  @override
  String get studyArchiveLink => 'Arquivo →';

  @override
  String get studyLoading => 'A carregar…';

  @override
  String get studyUnavailableNow => 'Unavailable right now';

  @override
  String get studyReadingStreak => 'Sequência de leitura';

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
  String get studyViewProgress => 'Ver o progresso →';

  @override
  String get studyPassageNotFound => 'Passagem não encontrada';

  @override
  String get studyPassageLoadError =>
      'Não foi possível carregar os dados da passagem.';

  @override
  String get studyCompletedCheck => '✓ Completed';

  @override
  String get studyMarkAsRead => 'Mark as Read';

  @override
  String get studyNextPassage => 'Next passage';

  @override
  String get studyFullChapter => 'Capítulo completo';

  @override
  String studyPassageOfTotal(int current, int total) {
    return 'Passagem $current de $total';
  }

  @override
  String studySelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get studyHighlight => 'Realçar';

  @override
  String get studyBookmark => 'Favorito';

  @override
  String get studyAddNote => 'Adicionar nota';

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
  String get studyCommentaryLibrary => 'Commentary library';

  @override
  String get studyCommentaryLoadError =>
      'Não foi possível carregar o comentário.';

  @override
  String get studyNoCommentaryYet => 'Ainda não há comentário disponível.';

  @override
  String get studyCommentaryShelf => 'The shelf';

  @override
  String get studyCommentaryByBook => 'By book';

  @override
  String studyCommentaryVolumes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count volumes',
      one: '1 volume',
    );
    return '$_temp0';
  }

  @override
  String studyCommentaryEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String studyCommentaryChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return '$_temp0';
  }

  @override
  String get studyCommentarySearchHint => 'Search volumes and books';

  @override
  String studyCommentaryNoMatch(String query) {
    return 'Nothing matches \"$query\".';
  }

  @override
  String studyReadingRef(String reference) {
    return 'Reading · $reference';
  }

  @override
  String get studyAllSources => 'Todas as fontes';

  @override
  String get studyVerseLevel => 'Ao nível do versículo';

  @override
  String studySearchWithin(String reference) {
    return 'Search within $reference…';
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
  String get studyCategoryCommentary => 'Comentário';

  @override
  String get studyCategoryDevotional => 'Devotional';

  @override
  String get studyCategoryStudyNote => 'Study note';

  @override
  String get studyNoContentForFilters =>
      'Não foi encontrado conteúdo para estes filtros.';

  @override
  String studyVerseLabel(String verse) {
    return 'Verse $verse';
  }

  @override
  String get studyChapterView => 'Chapter view';

  @override
  String get studyFilterAll => 'Todos';

  @override
  String get studyFilterDevotionals => 'Devotionals';

  @override
  String get studyFilterAllContexts => 'All contexts';

  @override
  String get studyFilterChapterLevel => 'Chapter level';

  @override
  String get studyFilterVerseLevel => 'Verse level';

  @override
  String get studyRemoveBookmark => 'Remover marcador';

  @override
  String get studyBookmarkCommentary => 'Bookmark commentary';

  @override
  String get studyExpandFullScreen => 'Expandir para tela cheia';

  @override
  String get studyTapToReadInContext => 'Toque para ler em contexto';

  @override
  String get studyOnThisChapter => 'Neste capítulo';

  @override
  String get studyOnThisBook => 'Neste livro';

  @override
  String get studyNoCommentaryTitle => 'Ainda não há comentário';

  @override
  String get studyNoCommentaryBody =>
      'We couldn\'t find specific commentary for this passage. Try exploring the chapter or book-level commentary below.';

  @override
  String get storiesTitle => 'Bible stories';

  @override
  String get storiesFilters => 'Filtros';

  @override
  String get storiesSubtitle =>
      '500 momentos ilustrados de Gênesis ao Apocalipse';

  @override
  String get storiesSearchHint => 'Pesquisar por título, livro ou referência…';

  @override
  String get storiesClearSearch => 'Clear search';

  @override
  String get storiesFilterAll => 'Todos';

  @override
  String get storiesFilterOt => 'OT';

  @override
  String get storiesFilterNt => 'NT';

  @override
  String storiesCountOfTotal(int count, int total) {
    return '$count de $total narrativas';
  }

  @override
  String get storiesFavorites => 'Guardado';

  @override
  String get storiesUnread => 'Por ler';

  @override
  String get storiesBooks => 'Books';

  @override
  String get storiesSearchBooks => 'Pesquisar livros…';

  @override
  String get storiesAllBooks => 'Todos os livros';

  @override
  String get storiesNoMatch => 'No stories match these filters.';

  @override
  String get storiesNoFavorites => 'No saved stories yet.';

  @override
  String get storiesBrowseAll => 'Browse all stories';

  @override
  String get storiesAllCaughtUp => 'You\'re all caught up.';

  @override
  String get storiesShowRead => 'Show read stories';

  @override
  String get storiesClearFilters => 'Clear filters';

  @override
  String get storiesFavoritesHint =>
      'Tap the bookmark on any story to save it here and in Your Space.';

  @override
  String get storiesAttribution =>
      'Scripture from the King James Version (public domain). Narrative summaries adapted from The Graham Bible (grahambible.com), AI-assisted and human reviewed. Artwork: Gustave Doré (1832–1883), public domain, via Wikimedia Commons.';

  @override
  String get storiesReachedEnd => 'You have reached the end.';

  @override
  String get storiesFirstStory => 'This is the first story.';

  @override
  String get storiesFavorite => 'Save story';

  @override
  String get storiesMarkAsRead => 'Marcar como lido';

  @override
  String storiesKeyVerse(String reference) {
    return 'VERSÍCULO-CHAVE · $reference';
  }

  @override
  String get storiesTheStory => 'A HISTÓRIA';

  @override
  String storiesArtworkCaption(String caption) {
    return 'Ilustração: $caption — Gustave Doré, domínio público';
  }

  @override
  String get storiesPrevious => 'Narrativa anterior';

  @override
  String get storiesNext => 'Narrativa seguinte';

  @override
  String storiesPosition(int index, int total, String book) {
    return '$index de $total em $book';
  }

  @override
  String get studyDictionarySearchHint => 'Pesquisar em mais de 3400 palavras…';

  @override
  String get studyDictionarySavedFilter => '★ Guardado';

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
  String get studyNoDefinition => 'Não foi encontrada nenhuma definição.';

  @override
  String studyStrongsShareText(String id, String lemma, String transliteration,
      String pronunciation, String definition) {
    return '$id - $lemma\n\nTransliteration: $transliteration\nPronunciation: $pronunciation\n\nDefinition:\n$definition';
  }

  @override
  String studyNoStrongsEntry(String id) {
    return 'Não foi encontrada nenhuma entrada para $id.';
  }

  @override
  String get studyStrongsLexicon => 'STRONG\'S LEXICON';

  @override
  String get studyConcordanceHint =>
      'Escreva uma palavra (ex.: graça, aliança)…';

  @override
  String studyConcordanceIntro(String translation) {
    return 'Ocorrências em $translation — toque num versículo para o ler em contexto.';
  }

  @override
  String get studyConcordanceEmpty =>
      'Every verse containing your word, in canonical order.';

  @override
  String get studyConcordanceSingleWord =>
      'Escreva uma palavra ou uma frase para pesquisar.';

  @override
  String studyConcordanceNoVerses(String word) {
    return 'Nenhum versículo contém «$word».';
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
    return 'A preparar a Bíblia offline… $percent%';
  }

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorBody =>
      'Ocorreu um problema inesperado. Toque abaixo para voltar à tela inicial.';

  @override
  String get errorBackHome => 'Voltar ao início';

  @override
  String studyWeekN(int week) {
    return 'Semana $week';
  }

  @override
  String get privacyTitle => 'Privacy policy';

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

  @override
  String get notifDailyTitle => 'Hora de ler';

  @override
  String get notifDailyBody => 'Reserve um momento para ler e refletir hoje.';

  @override
  String get notifDailyChannel => 'Daily reminders';

  @override
  String get notifDailyChannelDesc => 'Lembretes para a leitura diária';

  @override
  String get notifPrayerTitle => 'Time for prayer';

  @override
  String get notifPrayerBody =>
      'Faça uma pausa para um momento de reflexão e oração.';

  @override
  String get notifPrayerChannel => 'Prayer reminders';

  @override
  String get notifPrayerChannelDesc => 'Lembretes diários de oração';

  @override
  String get notifWeeklyTitle => 'Weekly study time';

  @override
  String get notifWeeklyBody =>
      'It\'s your scheduled time for study and reflection.';

  @override
  String get notifWeeklyChannel => 'Weekly reminders';

  @override
  String get notifWeeklyChannelDesc =>
      'Lembretes de estudo semanais personalizados';

  @override
  String get notifSabbathTitle => 'The Sabbath is approaching';

  @override
  String get notifSabbathBody => 'Bem-vindo ao dia de descanso.';

  @override
  String get notifSabbathChannel => 'Sabbath reminders';

  @override
  String get notifSabbathChannelDesc =>
      'Lembretes semanais do pôr do sol para o sábado';

  @override
  String get notifPlanBody =>
      'Reserve um momento para ler a sua passagem diária.';

  @override
  String get notifPlanChannel => 'Plano de leitura';

  @override
  String get notifPlanChannelDesc => 'Reading plan reminders';

  @override
  String get widgetStreakActive => 'Streak active!';

  @override
  String get widgetStreakInactive => 'Read today to keep your streak';

  @override
  String get widgetFallbackWord => 'Grace (Charis)';

  @override
  String get widgetFallbackDefinition =>
      'The unmerited favor and divine love of God bestowed upon humanity.';

  @override
  String get widgetStyleDusk => 'Celestial Dusk';

  @override
  String get widgetStyleDawn => 'Morning Dawn';

  @override
  String get widgetStyleEmerald => 'Sanctuary Emerald';

  @override
  String get widgetStyleGolden => 'Sacred Amber';

  @override
  String get widgetStyleRoyal => 'Royal Sapphire';

  @override
  String get widgetStyleGlassLight => 'Frosted Glass';

  @override
  String get widgetStyleGlassDark => 'Obsidian Glass';

  @override
  String get widgetStyleSolidLight => 'Clean Paper';

  @override
  String get widgetStyleSolidDark => 'Deep Charcoal';

  @override
  String get widgetStyleTransparent => 'Clear Wallpaper';

  @override
  String get backupShareSubject => 'The Blessed Bible Backup';

  @override
  String backupExportFailed(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String backupNewerVersion(int version) {
    return 'This backup is from a newer app version (v$version). Update the app first.';
  }

  @override
  String get backupConfirmTitle => 'Confirm restore';

  @override
  String get backupConfirmBody =>
      'Isto substituirá todas as notas, realces, marcadores e definições existentes. Tem a certeza?';

  @override
  String backupSkippedValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count values skipped',
      one: '1 value skipped',
    );
    return '$_temp0';
  }

  @override
  String backupRedownload(int count, String list) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 're-download $count translations: $list',
      one: 're-download 1 translation: $list',
    );
    return '$_temp0';
  }

  @override
  String get backupRestored => 'Backup restored successfully';

  @override
  String backupRestoredWithDetails(String details) {
    return 'Backup restored ($details)';
  }

  @override
  String backupRestoreFailed(String error) {
    return 'Restore failed: invalid or corrupted backup ($error)';
  }

  @override
  String get greetingDaily1Title => 'A paz seja convosco.';

  @override
  String get greetingDaily1Subtitle =>
      'Deixe que a sua palavra lhe traga descanso.';

  @override
  String get greetingDaily2Title => 'Caminhe na luz.';

  @override
  String get greetingDaily2Subtitle =>
      'A Sua palavra é uma lâmpada para o teu caminho.';

  @override
  String get greetingDaily3Title => 'Graça e paz para ti.';

  @override
  String get greetingDaily3Subtitle => 'Descansa hoje na vinha.';

  @override
  String get greetingDaily4Title => 'Vinde às águas.';

  @override
  String get greetingDaily4Subtitle => 'Jesus é a luz do mundo.';

  @override
  String get greetingDaily5Title => 'Que o Senhor o abençoe.';

  @override
  String get greetingDaily5Subtitle =>
      'Guarde as suas promessas perto do seu coração.';

  @override
  String get greetingDaily6Title => 'Sê quieto e sabe.';

  @override
  String get greetingDaily6Subtitle => 'Permanece na Sua presença serena.';

  @override
  String get greetingDaily7Title => 'As misericórdias da manhã, a cada dia.';

  @override
  String get greetingDaily7Subtitle => 'As Suas misericórdias não falham.';

  @override
  String get greetingDaily8Title => 'Enraizado no amor.';

  @override
  String get greetingDaily8Subtitle => 'Cresça em graça e verdade.';

  @override
  String get greetingDaily9Title => 'Que a sua luz brilhe.';

  @override
  String get greetingDaily9Subtitle =>
      'Uma cidade sobre um morro não pode ficar escondida.';

  @override
  String get greetingDaily10Title => 'Aproximai-vos de Deus.';

  @override
  String get greetingDaily10Subtitle => 'Já estende a mão para ti.';

  @override
  String get greetingDaily11Title => 'O Verbo se fez carne.';

  @override
  String get greetingDaily11Subtitle => 'Ele compreende a tua jornada.';

  @override
  String get greetingDaily12Title => 'Prove e veja.';

  @override
  String get greetingDaily12Subtitle => 'O Senhor é incredivelmente bom.';

  @override
  String get greetingMorning1Title => 'Desperta, tu que dormes.';

  @override
  String get greetingMorning1Subtitle => 'Cristo brilhará sobre ti.';

  @override
  String get greetingMorning2Title => 'A alegria vem pela manhã.';

  @override
  String get greetingMorning2Subtitle => 'Entre no novo dia d\'Ele.';

  @override
  String get greetingMorning3Title => 'Este é o dia que o Senhor fez.';

  @override
  String get greetingMorning3Subtitle => 'Regozijemo-nos nisso.';

  @override
  String get greetingEvening1Title => 'O dia terminou.';

  @override
  String get greetingEvening1Subtitle => 'Dá sono aos que ama.';

  @override
  String get greetingEvening2Title => 'Debaixo das suas asas.';

  @override
  String get greetingEvening2Subtitle => 'Vais encontrar refúgio esta noite.';

  @override
  String get greetingEvening3Title => 'Vinde a Mim, vós que estais cansados.';

  @override
  String get greetingEvening3Subtitle => 'e vos darei descanso.';

  @override
  String get greetingGrace1Title => 'Deixa toda a tua ansiedade a Ele.';

  @override
  String get greetingGrace1Subtitle => 'Porque Ele se importa contigo.';

  @override
  String get greetingGrace2Title => 'Dou-vos a minha paz.';

  @override
  String get greetingGrace2Subtitle => 'Não deixes o teu coração perturbado.';

  @override
  String get greetingGrace3Title => 'Sar coração quebrantado.';

  @override
  String get greetingGrace3Subtitle => 'e liga as suas feridas.';

  @override
  String get greetingGrace4Title => 'Nada nos pode separar.';

  @override
  String get greetingGrace4Subtitle => 'Do amor de Deus.';

  @override
  String get greetingCheer1Title => 'Sê forte e corajoso.';

  @override
  String get greetingCheer1Subtitle => 'O Senhor teu Deus caminha contigo.';

  @override
  String get greetingCheer2Title => 'Corre com perseverança.';

  @override
  String get greetingCheer2Subtitle => 'Mantenha os seus olhos fixos em Jesus.';

  @override
  String get greetingCheer3Title => 'O ferro afia o ferro.';

  @override
  String get greetingCheer3Subtitle => 'Cresçam juntos na Palavra.';

  @override
  String greetingEyebrowMorning(String day) {
    return '$day morning';
  }

  @override
  String greetingEyebrowAfternoon(String day) {
    return '$day afternoon';
  }

  @override
  String greetingEyebrowEvening(String day) {
    return '$day evening';
  }

  @override
  String greetingEyebrowNight(String day) {
    return '$day night';
  }

  @override
  String get creditsScripture => 'Scripture';

  @override
  String get creditsCommentary => 'Comentário';

  @override
  String get creditsStudyTools => 'Study tools';

  @override
  String get creditsBibleStories => 'Bible stories';

  @override
  String get creditsFonts => 'Fonts';

  @override
  String get creditsCommentaryPerspective =>
      'The library includes Seventh-day Adventist pioneer works and general Christian commentaries from other traditions. Interpretive perspectives vary; all are study aids alongside Scripture, not part of it.';

  @override
  String get creditsPublicDomain => 'Public domain.';

  @override
  String get creditsPublicDomainUs => 'Public domain in the US.';

  @override
  String get creditsKjvDetail =>
      'Public domain. Strong\'s-tagged edition also public domain.';

  @override
  String get creditsSelectedWriting => 'Selected writing.';

  @override
  String get creditsAdditionalTranslationsDetail =>
      'Downloaded from the Free Use Bible API (bible.helloao.org) and open-bibles (github.com/seven1m/open-bibles).';

  @override
  String get creditsNarrativeDetail =>
      'Adapted from The Graham Bible (grahambible.com), AI-assisted and human reviewed.';

  @override
  String creditsFontsDetail(String licenses) {
    return 'SIL Open Font License 1.1. Full notices under $licenses.';
  }

  @override
  String get miscPlanNotFound => 'Plan not found.';

  @override
  String get miscPaceUnsupported =>
      'This plan was created before pace adjustment was supported. Recreate it to enable this feature.';

  @override
  String miscPaceFailed(String error) {
    return 'Pace adjustment failed: $error';
  }

  @override
  String miscPlanLoadFailed(String error) {
    return 'Could not load this plan ($error).';
  }

  @override
  String get miscFolderSermon => 'Sermon prep';

  @override
  String get miscFolderMemorize => 'Memorize';

  @override
  String get miscFolderComfort => 'Comfort';

  @override
  String get miscFolderStudy => 'Estudo';

  @override
  String get miscColorPurple => 'Purple';

  @override
  String get miscColorGreen => 'Green';

  @override
  String get miscColorBlue => 'Blue';

  @override
  String get miscColorPink => 'Pink';

  @override
  String get miscColorRed => 'Red';

  @override
  String get miscSearchBibleVerse => 'Bible verse';

  @override
  String get miscSearchCommentary => 'Comentário';

  @override
  String miscSearchCommentaryBy(String author) {
    return '$author Commentary';
  }

  @override
  String miscSearchNote(String date) {
    return 'Note • $date';
  }

  @override
  String get miscSearchJumpTo => 'Jump to';

  @override
  String miscSearchGoToChapter(String book, int chapter) {
    return 'Go to $book chapter $chapter';
  }

  @override
  String miscSearchGoToVerse(String book, int chapter, int verse) {
    return 'Go to $book chapter $chapter, verse $verse';
  }

  @override
  String miscSearchDictionary(String sources) {
    return 'Dictionary ($sources)';
  }

  @override
  String miscMostReadSnippet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Frequently read passage ($count visits)',
      one: 'Frequently read passage (1 visit)',
    );
    return '$_temp0';
  }

  @override
  String get miscEmotionAnxiety => 'anxiety';

  @override
  String get miscEmotionFear => 'fear';

  @override
  String get miscEmotionSadness => 'sadness';

  @override
  String get miscEmotionLoneliness => 'loneliness';

  @override
  String get miscEmotionAnger => 'anger';

  @override
  String get miscEmotionTemptation => 'temptation';

  @override
  String get miscEmotionGuilt => 'guilt';

  @override
  String get miscEmotionHopelessness => 'hopelessness';

  @override
  String get miscEmotionConfusion => 'confusion';

  @override
  String get miscEmotionDoubt => 'doubt';

  @override
  String get miscEmotionExhaustion => 'exhaustion';

  @override
  String get miscEmotionGratitude => 'gratitude';

  @override
  String get miscEmotionJoy => 'joy';

  @override
  String get miscEmotionPeace => 'peace';

  @override
  String miscPrayerComfort(String emotion) {
    return 'Lord, bring comfort and strength as I navigate feelings of $emotion today.';
  }

  @override
  String miscPrayerScripture(String verse) {
    return 'Grant me the grace to reflect on scripture, especially $verse.';
  }

  @override
  String get miscPrayerGuide =>
      'Guide my steps in hope and peace, trusting in Your faithful promises.';
}
