// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get a11yRead => 'Leer';

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
  String get appTitle => 'La Biblia Bendita';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonShare => 'Compartir';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonSearch => 'Buscar';

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
  String get onboardingTagline => 'La Escritura, sin distracciones.';

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
  String get onboardingFeatureWordTitle => 'La Palabra Pura';

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
  String get plansResume => 'Reanudar';

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
  String get plansToday => 'Hoy';

  @override
  String get plansYesterday => 'Ayer';

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
  String get plansHello => 'Hola,';

  @override
  String plansSlotsFull(int count) {
    return 'All $count plan slots are in use. Pause a plan to free a slot — progress is kept.';
  }

  @override
  String get plansPausedSnack => 'Plan en pausa: todo el progreso se conserva.';

  @override
  String get plansBrowseToStart =>
      'Explora Lectura para comenzar tu primer plan.';

  @override
  String get plansFriend => 'Friend';

  @override
  String get plansTitle => 'Planes';

  @override
  String get plansTabReading => 'Reading';

  @override
  String get plansTabBooks => 'Books';

  @override
  String plansTabMyPlans(int count) {
    return 'My Plans ($count)';
  }

  @override
  String get plansNotStarted => 'Sin empezar';

  @override
  String plansPercentDone(int percent) {
    return '$percent% done';
  }

  @override
  String get plansOpen => 'Abrir';

  @override
  String get plansPaused => 'En pausa';

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
  String get plansCaughtUp => 'Al día';

  @override
  String get plansComplete => 'Completar';

  @override
  String plansDayOfTotalLeft(int current, int total, int left) {
    return 'Día $current de $total · quedan $left';
  }

  @override
  String get plansPauseKeepsProgress => 'Pausar (conserva el progreso)';

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
  String get plansYourCustomPlans => 'TUS PLANES PERSONALIZADOS';

  @override
  String plansDayOfTotal(int day, int total) {
    return 'Día $day de $total';
  }

  @override
  String get plansCustomPlan => 'Custom plan';

  @override
  String get plansNoActivePlans => 'No hay planes activos';

  @override
  String get plansNoActivePlansBody =>
      'Explora Lectura o Libros para comenzar tu primer plan.';

  @override
  String get plansLetsRead => 'Let\'s read';

  @override
  String get plansVerseOfTheDay => 'Versículo del día';

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
  String get plansPlanName => 'Nombre del plan';

  @override
  String get plansPlanNameHint => 'e.g. Genesis in 30 days';

  @override
  String get plansReadingTracks => 'Recorridos de lectura';

  @override
  String get plansAddTrack => 'Añadir pista';

  @override
  String get plansTracksOverlap =>
      'Tracks overlap — shared verses are counted once in the preview below.';

  @override
  String get plansDuration => 'Duración';

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
  String get plansStartRestReminder => 'Empezar, descansar y recordatorio';

  @override
  String get plansStartDate => 'Fecha de inicio';

  @override
  String get plansRestDaysNeutral => 'Días de descanso (neutrales)';

  @override
  String get plansNone => 'NINGuno';

  @override
  String get plansDailyReminder => 'Recordatorio diário';

  @override
  String plansReminderAt(String time) {
    return 'At $time';
  }

  @override
  String get plansOff => 'Off';

  @override
  String get plansLivePreview => 'Vista previa en vivo';

  @override
  String get plansPreviewEmpty =>
      'Añade al menos una pista arriba para previsualizar el programa equilibrado por palabras.';

  @override
  String get plansWordBalanced =>
      'Equilibrado en palabras · consciente de la perícopa';

  @override
  String plansPreviewSummary(int days, int readingDays) {
    return '$days días · $readingDays días de lectura';
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
    return 'Día $day: $portions';
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
      'Ponle nombre al plan y añade al menos un recorrido para continuar.';

  @override
  String get plansStartEllipsis => 'Start…';

  @override
  String get plansEndEllipsis => 'End…';

  @override
  String get plansStartLabel => 'EMPEZAR';

  @override
  String get plansEndLabel => 'FIN';

  @override
  String get plansRemoveTrack => 'Quitar recorrido';

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
  String get plansBeginPlan => 'Comenzar plan';

  @override
  String get plansStartDayOne => 'Start day 1 →';

  @override
  String get plansStartDateNote => 'Your plan begins on the date you choose.';

  @override
  String get plansScheduleLabel => 'HORARIO';

  @override
  String get plansNoReadings => 'No readings';

  @override
  String plansPercentComplete(int percent) {
    return '$percent % completado';
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
  String get plansCatchUp => 'Poner al día';

  @override
  String plansBehindBy(int count, int day) {
    return 'Atrasado $count — el día más antiguo sin leer es el Día $day.';
  }

  @override
  String get plansCatchUpHelp =>
      'Marking days done records progress. Shifting moves the rest of the schedule forward instead.';

  @override
  String get plansGoToOldest => 'Ir al más antiguo';

  @override
  String get plansMarkOldestDone => 'Marcar el más antiguo como completado';

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
      'Marcar todas las anteriores como completadas';

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
    return 'LECTURAS · $count DÍAS';
  }

  @override
  String get plansJourneyMap => 'Vista de mapa del recorrido';

  @override
  String get plansJumpToToday => 'Ir a hoy';

  @override
  String plansDayN(int day) {
    return 'Day $day';
  }

  @override
  String get plansLegendDone => 'Listo';

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
  String get plansRestDays => 'Días de descanso';

  @override
  String get plansNoRestDays => 'No rest days';

  @override
  String get plansSettings => 'Ajustes del plan';

  @override
  String get plansAboutEllipsis => 'Sobre este plan…';

  @override
  String get plansAbout => 'Sobre este plan';

  @override
  String get plansChangeStartDate => 'Cambiar fecha de inicio…';

  @override
  String plansRestDaysValue(String days) {
    return 'Días de descanso: $days';
  }

  @override
  String get plansRestDaysHelp => 'Toca para elegir los días de la semana';

  @override
  String get plansRestartFromDayOne => 'Restart from day 1…';

  @override
  String get plansRestartTitle => '¿Reiniciar el plan?';

  @override
  String get plansRestartBody => 'Los días completados se borrarán.';

  @override
  String get plansRestart => 'Reiniciar';

  @override
  String get plansMarkUnread => 'Marcar como no leído';

  @override
  String get plansMarkRead => 'Marcar como leído';

  @override
  String get plansRestAndReflect => 'Descansa y reflexiona';

  @override
  String get plansRestDayBody => 'A day of rest — no reading assigned today.';

  @override
  String get plansDayDetailHelp =>
      'Toca un pasaje para abrirlo. Marca cada uno mientras lees.';

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
  String get todaySectionResume => 'REANUDAR';

  @override
  String get todaySectionStreak => 'RACHA DE LECTURA';

  @override
  String get todaySectionLatestNote => 'ÚLTIMA NOTA';

  @override
  String get todaySectionQuickActions => 'ACCIONES RÁPIDAS';

  @override
  String get todaySectionReminders => 'RECORDATORIOS DIARIOS';

  @override
  String get todayTagline => 'Tu momento de paz diario.';

  @override
  String get todayNoNotesYet => 'Todavía no hay notas';

  @override
  String get todayWriteFirstNote => 'Escribe tu primera nota para verla aquí.';

  @override
  String get todayViewAllNotes => 'Ver todas las notas';

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
  String get todayActionRead => 'Leer';

  @override
  String get todayActionSurprise => 'Sorpréndeme';

  @override
  String get todayActionReadingPlan => 'Plan de lectura';

  @override
  String get todayActionYourSpace => 'Tu espacio';

  @override
  String get todayVotdArchive => 'Verse of the day archive';

  @override
  String get todayVotdArchiveBody =>
      'Pon al día los versos de los días que perdiste.';

  @override
  String get todayVotdArchiveExplore =>
      'Explora tus versículos diarios anteriores';

  @override
  String get readActionBookmark => 'Marcador';

  @override
  String get readActionNote => 'Nota';

  @override
  String get readActionNotes => 'Notas';

  @override
  String get readActionEditNote => 'Edit note';

  @override
  String get readActionCommentary => 'Comentario';

  @override
  String get readActionRelated => 'Relacionados';

  @override
  String get readActionHighlight => 'Resaltar';

  @override
  String get readActionStudy => 'Estudio';

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
  String get readPassageNotFound => 'Pasaje no encontrado.';

  @override
  String get readChapterCommentary => 'Leer el comentario de este capítulo';

  @override
  String readEndOfChapter(String reference) {
    return '· Fin de $reference ·';
  }

  @override
  String get readPreviousChapter => '‹ Anterior';

  @override
  String get readNextChapter => 'Siguiente ›';

  @override
  String readPlanDay(int day) {
    return 'Plan de lectura · Día $day';
  }

  @override
  String get readPlanCompleted => '¡Plan completado! ¡Enhorabuena! 🎉';

  @override
  String readMarkDoneContinue(String book, int chapter) {
    return 'Marcar $book $chapter como completado y continuar';
  }

  @override
  String get readNone => 'NINGuno';

  @override
  String readBookFallback(int number) {
    return 'Book $number';
  }

  @override
  String get readRelatedVerses => 'Related verses';

  @override
  String get readNoCrossRefs =>
      'No se encontraron referencias cruzadas para este versículo.';

  @override
  String get readCrossRefsComingSoon =>
      'Cross-references will be available\nafter the next app update.';

  @override
  String get readVerseUnavailable => 'Verse not available';

  @override
  String get readLoading => 'Cargando…';

  @override
  String get readVerseNotFound => 'Versículo no encontrado.';

  @override
  String get readBookOrChapterNotFound => 'Book or chapter not found.';

  @override
  String get readOpenInRead => 'Abrir en Leer';

  @override
  String get readBookNotFound => 'No se encontró el libro referenciado.';

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
  String get readOldTestament => 'Antiguo Testamento';

  @override
  String get readNewTestament => 'Nuevo Testamento';

  @override
  String get readOldTestamentTwoLine => 'Antiguo Testamento';

  @override
  String get readNewTestamentTwoLine => 'Nuevo Testamento';

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
  String get readCannotDeleteBackbone =>
      'No se puede eliminar — base de la aplicación';

  @override
  String get readAvailableToAdd => 'DISPONIBLE PARA AÑADIR';

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
  String get homeVerseOfTheDay => 'VERSÍCULO DEL DÍA';

  @override
  String get homeDevotional => 'DEVOTIONAL';

  @override
  String get homeCommentary => 'COMMENTARY';

  @override
  String get homeGoDeeper => 'Go deeper';

  @override
  String get homeReadFullDefinition => 'Read full definition';

  @override
  String get homeWordOfTheDayHeading => 'PALABRA DEL DÍA';

  @override
  String get homeWordOfTheDay => 'Palabra del día';

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
  String get navRead => 'Leer';

  @override
  String get navStudy => 'Estudio';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navExitTitle => '¿Salir de The Blessed Bible?';

  @override
  String get navExitMessage => '¿Seguro que quieres salir de la aplicación?';

  @override
  String get navExit => 'Salir';

  @override
  String get navCastLotsError =>
      'No se pudieron echar las suertes — inténtalo de nuevo.';

  @override
  String get navCastingLots => 'Se están echando las suertes...';

  @override
  String get searchHint => 'Search verses, commentary…';

  @override
  String get searchAllBooks => 'Todos los libros';

  @override
  String get searchFilterMyNotes => 'My notes';

  @override
  String get searchEmptyPrompt =>
      'Search the Bible, commentary\nand your notes';

  @override
  String get searchRecentSearches => 'BÚSQUEDAS RECENTES';

  @override
  String get searchClear => 'LIMPIAR';

  @override
  String get searchRecentPlaces => 'LUGARES RECIENTES';

  @override
  String get searchMostRead => 'MÁS LEÍDOS';

  @override
  String get searchNoResults => 'No se encontraron resultados';

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
  String get searchCopied => 'Copiado al portapapeles';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTabGeneral => 'General';

  @override
  String get settingsTabNavigation => 'Navegación';

  @override
  String get settingsTabReminders => 'Recordatorios';

  @override
  String get settingsTabInfo => 'Información';

  @override
  String get settingsWidgetsTitle => 'Home screen widgets';

  @override
  String get settingsWidgetsSubtitle =>
      'Personalizar degradados, transparencia y vista previa en vivo';

  @override
  String get settingsStartPageTitle => 'Página de inicio predeterminada';

  @override
  String get settingsStartPageSubtitle =>
      'Elije la página con la que abre la app';

  @override
  String get settingsPageHome => 'Home';

  @override
  String get settingsPageRead => 'Leer';

  @override
  String get settingsPageStudy => 'Estudio';

  @override
  String get settingsPageSearch => 'Buscar';

  @override
  String get settingsImmersiveReading => 'Immersive reading';

  @override
  String get settingsImmersiveOffTitle => 'Anchored (off)';

  @override
  String get settingsImmersiveOffSubtitle =>
      'La navegación permanece visible en todo momento';

  @override
  String get settingsImmersivePartialTitle => 'Guided (partial)';

  @override
  String get settingsImmersivePartialSubtitle =>
      'Auto-hides main navigation, but leaves the book & chapter pill';

  @override
  String get settingsImmersiveFullTitle => 'Aguas profundas (Completo)';

  @override
  String get settingsImmersiveFullSubtitle =>
      'Inmersión total. Todos los menús se ocultan al desplazarse';

  @override
  String get settingsShowStrongs => 'Show Strong\'s numbers';

  @override
  String get settingsShowStrongsSubtitle =>
      'Muestra los identificadores hebreos/griegos originales junto al texto KJV para estudio profundo de palabras';

  @override
  String get settingsStrongsGetIt => 'Obtenerlo';

  @override
  String get settingsStrongsMarkerAsterisk => 'Asterisco (*)';

  @override
  String get settingsStrongsMarkerChain => 'Cadena (🔗)';

  @override
  String get settingsStrongsMarkerNumber => 'Número (H1234)';

  @override
  String get settingsReadingSpeed => 'Velocidad de lectura';

  @override
  String get settingsReadingSpeedSubtitle =>
      'Estimaciones de ritmo para los planes (palabras por minuto)';

  @override
  String get settingsSpeedRelaxed => 'Relajado';

  @override
  String get settingsSpeedStandard => 'Estándar';

  @override
  String get settingsSpeedBrisk => 'Rápido';

  @override
  String get settingsDictUnderlines => 'Dictionary underlines';

  @override
  String get settingsDictUnderlinesSubtitle =>
      'Subrayados punteados en términos bíblicos y palabras arcaicas';

  @override
  String get settingsUnderlineScope => 'Underline scope';

  @override
  String get settingsScopeNamesTitle => 'Solo nombres y términos';

  @override
  String get settingsScopeNamesSubtitle =>
      'Nombres propios y conceptos bíblicos específicos';

  @override
  String get settingsScopeTrickyTitle => 'Names + tricky words (recommended)';

  @override
  String get settingsScopeTrickySubtitle =>
      'Incluye palabras arcaicas con significado cambiado (p. ej. let, prevent)';

  @override
  String get settingsScopeEverythingTitle => 'Todo';

  @override
  String get settingsScopeEverythingSubtitle =>
      'Resalta toda la gramática arcaica (ej.: thee, thou, hath, unto)';

  @override
  String get settingsScopeDifficultTitle => 'Solo palabras difíciles';

  @override
  String get settingsScopeDifficultSubtitle =>
      'Archaic, misleading and contested words — easy words like god and son stay unmarked';

  @override
  String get settingsScopeDifficultNamesTitle => 'Difíciles + nombres';

  @override
  String get settingsScopeDifficultNamesSubtitle =>
      'Adds people and places (e.g., David, Jerusalem) to difficult words';

  @override
  String get settingsOtherEnglishVersions => 'Otras versiones en inglés';

  @override
  String get settingsContestedOnlyTitle => 'Solo palabras controvertidas';

  @override
  String get settingsContestedOnlySubtitle =>
      'BBE, WEB and other English versions mark disputed words (e.g., hell, baptism)';

  @override
  String get settingsFollowScopeTitle => 'Seguir el ámbito de subrayado';

  @override
  String get settingsFollowScopeSubtitle =>
      'Same marking as KJV in every English version';

  @override
  String get settingsNoUnderlinesTitle => 'Sin subrayados';

  @override
  String get settingsNoUnderlinesSubtitle =>
      'Las otras versiones en inglés no muestran marcas de diccionario';

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
      'Mostrar los elementos guardados en mi idioma';

  @override
  String get settingsSavedInMyLanguageSubtitle =>
      'Mostrar marcadores, resaltados y versos de comentario en tu traducción principal activa';

  @override
  String get settingsTranslationChips =>
      'Mostrar opciones de traducción en los elementos guardados';

  @override
  String get settingsTranslationChipsSubtitle =>
      'Añade una fila compacta de chips de traducción para ver los versos guardados en otras traducciones';

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
      'Evitar que el dispositivo se duerma mientras lees';

  @override
  String get settingsRestartOnboarding => 'Reiniciar la incorporación';

  @override
  String get settingsRestartOnboardingSubtitle =>
      'Repetir la configuración inicial';

  @override
  String get settingsRestartOnboardingDialogTitle =>
      '¿Reiniciar la incorporación?';

  @override
  String get settingsRestartOnboardingDialogBody =>
      'Esto repetirá la configuración inicial. Tu tema, fuente y traducción actuales se mantienen salvo que los cambies.';

  @override
  String get settingsRestart => 'Reiniciar';

  @override
  String get settingsAppearanceText => 'Apariencia y texto';

  @override
  String get settingsAppearanceTextSubtitle =>
      'Tema, fuentes, tamaños y colores de lectura';

  @override
  String get settingsSabbathTitle => 'Friday sunset reminder';

  @override
  String get settingsSabbathSubtitle =>
      'Bienvenido al sábado a la hora del atardecer local.';

  @override
  String get settingsLocation => 'Ubicación';

  @override
  String get settingsLocationNotSet => 'Not set (tap to set)';

  @override
  String get settingsDailyReminderTitle => 'Daily reading reminder';

  @override
  String get settingsDailyReminderSubtitle =>
      'Un recordatorio diario para pasar tiempo en la Palabra.';

  @override
  String get settingsTime => 'Hora';

  @override
  String get settingsWeeklyReminderTitle => 'Custom weekly reminder';

  @override
  String get settingsWeeklyReminderSubtitle =>
      'Fija un día y una hora cada semana para un estudio más profundo.';

  @override
  String get settingsDayAndTime => 'Day & time';

  @override
  String get settingsChooseDay => 'Choose day';

  @override
  String get settingsShowReadingTips => 'Mostrar consejos de lectura';

  @override
  String get settingsShowReadingTipsSubtitle =>
      'Mostrar consejos guiados para acciones de lectura como resaltar y deslizar';

  @override
  String get settingsNavSteps => 'Navigation steps';

  @override
  String get settingsNavStepsSubtitle =>
      'How many steps to reach a verse. 2-step: Book → Chapter. 3-step: Book → Chapter → Verse. 4-step: Testament → Book → Chapter → Verse.';

  @override
  String get settingsAutoClose =>
      'Cerrar automáticamente el panel en la selección final';

  @override
  String get settingsAutoCloseSubtitle =>
      'Descartar automáticamente el selector tras el último paso';

  @override
  String get settingsSelectorHeight => 'Altura del selector de libro';

  @override
  String get settingsSelectorHeightSubtitle =>
      'Controla cuánto se abre la hoja de libro/capítulo';

  @override
  String get settingsHeightHalf => 'Mitad';

  @override
  String get settingsHeightFull => 'Full';

  @override
  String get settingsAutoOpenSingle =>
      'Abrir automáticamente el único resultado de búsqueda';

  @override
  String get settingsAutoOpenSingleSubtitle =>
      'Navegar automáticamente cuando una búsqueda devuelve exactamente un resultado';

  @override
  String get settingsIncludeNotes =>
      'Incluir tus notas personales en la búsqueda';

  @override
  String get settingsIncludeNotesSubtitle =>
      'Permitir que la búsqueda busque en tus notas personales';

  @override
  String get settingsWholeWords => 'Coincidir solo palabras completas';

  @override
  String get settingsWholeWordsSubtitle =>
      'Buscar solo coincidencias exactas de palabras (desactiva las coincidencias parciales o por prefijo)';

  @override
  String get settingsFuzzySearch => 'Búsqueda indulgente';

  @override
  String get settingsFuzzySearchSubtitle =>
      'Mostrar también coincidencias cercanas para errores de escritura (ej.: Jhon encuentra John)';

  @override
  String get settingsDefaultScopes => 'Default search scopes';

  @override
  String get settingsOldTestament => 'Antiguo Testamento';

  @override
  String get settingsNewTestament => 'Nuevo Testamento';

  @override
  String get settingsCommentary => 'Comentario';

  @override
  String get settingsGestures => 'Gestos';

  @override
  String get settingsPullDownHome => 'Desliza hacia abajo en Inicio';

  @override
  String get settingsPullDownHomeSubtitle =>
      'Desliza hacia abajo más allá del borde superior para abrir Ajustes o Apariencia';

  @override
  String get settingsPullDownOpens => 'Deslizar hacia abajo abre';

  @override
  String get settingsPullDownOpensSubtitle =>
      'Destino del gesto de arrastrar hacia abajo en Inicio';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsSwipeLeftHome => 'Desliza a la izquierda en Inicio';

  @override
  String get settingsSwipeLeftHomeSubtitle =>
      'Desliza a la izquierda para ir a la pestaña Leer';

  @override
  String get settingsLongPressNav => 'Mantén pulsado para abrir la navegación';

  @override
  String get settingsLongPressNavSubtitle =>
      'Mantén pulsado el botón inferior derecho para abrir rápido el selector de Libro/Capítulo.';

  @override
  String get settingsBbeNoteTitle => 'BBE translation note';

  @override
  String get settingsBackup => 'Copia de seguridad de mis datos';

  @override
  String get settingsBackupSubtitle => 'Exportar notas, resaltados y ajustes';

  @override
  String get settingsRestoreBackup => 'Restaurar desde una copia de seguridad';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Importa tus datos desde una copia de seguridad JSON';

  @override
  String get settingsRestoreBackupDialogTitle =>
      'Restaurar desde una copia de seguridad';

  @override
  String get settingsRestoreHint => 'Pega aquí tu copia de seguridad JSON...';

  @override
  String get settingsRestore => 'Restaurar';

  @override
  String get settingsClearCache => 'Borrar caché/datos descargados';

  @override
  String get settingsClearCacheSubtitle =>
      'Libre espacio eliminando archivos en caché';

  @override
  String get settingsNotImplemented => 'Aún no implementado';

  @override
  String get settingsResetSettings => 'Restablecer los ajustes';

  @override
  String get settingsResetSettingsSubtitle =>
      'Restaurar los ajustes originales de la aplicación (se conserva el contenido)';

  @override
  String get settingsResetDialogTitle => '¿Restablecer los ajustes?';

  @override
  String get settingsResetDialogBody =>
      'Reset all settings to default? This won\'t affect your bookmarks, notes, or highlights.';

  @override
  String get settingsResetDone =>
      'Ajustes restablecidos a los valores predeterminados.';

  @override
  String get settingsReset => 'Restablecer';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsUnknown => 'Desconocido';

  @override
  String get settingsStorage => 'Almacenamiento y descargas';

  @override
  String get settingsStorageSubtitle =>
      'Caché, traducciones descargadas y lo que se puede liberar';

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
  String get settingsUseMyLocation => 'Usar mi ubicación actual';

  @override
  String get settingsOrSelectCity => 'O selecciona una ciudad importante';

  @override
  String get settingsTypography => 'Tipografía';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsSearchSettings => 'Search settings';

  @override
  String get settingsMatchTypeHeader => 'TIPO DE COINCIDENCIA';

  @override
  String get settingsExactMatch => 'Exact match';

  @override
  String get settingsExactMatchSubtitle => 'Coincidir solo la frase exacta';

  @override
  String get settingsScopeHeader => 'ÁMBITO';

  @override
  String get settingsDisabledBookFilter => 'Disabled (book filter active)';

  @override
  String get settingsMyNotes => 'My notes';

  @override
  String get settingsBehaviorHeader => 'COMPORTAMIENTO';

  @override
  String get settingsAutoOpenSingleShort => 'Auto-open single result';

  @override
  String get settingsAutoOpenSingleShortSubtitle =>
      'Ir directamente si solo se encuentra un resultado';

  @override
  String get settingsBackgroundGlow => 'Enable background glow';

  @override
  String get settingsBackgroundGlowSubtitle =>
      'Muestra una sutil luz animada detrás del lector';

  @override
  String settingsThemeDailyToday(String theme) {
    return 'Hoy: $theme';
  }

  @override
  String get settingsThemeGroupFoundations => 'FUNDAMENTOS';

  @override
  String get settingsThemeDawn => 'Amanecer';

  @override
  String get settingsThemeFresh => 'Fresco';

  @override
  String get settingsThemeGroupFirmament => 'FIRMAMENTO';

  @override
  String get settingsThemeSun => 'dom';

  @override
  String get settingsThemeMoon => 'Luna';

  @override
  String get settingsThemeStars => 'Estrellas';

  @override
  String get settingsThemeGroupEden => 'EDEN';

  @override
  String get settingsThemeLilies => 'Lirios';

  @override
  String get settingsThemeRoses => 'Rosas';

  @override
  String get settingsThemeOlives => 'Olivos';

  @override
  String get settingsThemeGroupSanctuary => 'SANTUARIO';

  @override
  String get settingsThemePurple => 'Priestly\nPurple';

  @override
  String get settingsThemeBlue => 'Galilee\nBlue';

  @override
  String get settingsThemeRed => 'Scarlet\nRed';

  @override
  String get settingsSurpriseMe => 'Sorpréndeme';

  @override
  String get settingsThemeOledDark => 'OLED\nDark';

  @override
  String get settingsThemeDuskOled => 'Dusk\nOLED';

  @override
  String get settingsSurfaceStyle => 'Surface style';

  @override
  String get settingsSurfaceStyleSubtitle =>
      'Profundidad visual y renderizado de materiales';

  @override
  String get settingsSurfaceEarth => 'Tierra';

  @override
  String get settingsSurfaceEarthSubtitle => 'Superficie plana';

  @override
  String get settingsSurfaceHeaven => 'Cielos';

  @override
  String get settingsSurfaceHeavenSubtitle => 'Profundidad helada';

  @override
  String get settingsSurfacePaper => 'Papel';

  @override
  String get settingsSurfacePaperSubtitle => 'Lector electrónico cálido';

  @override
  String get settingsSurfaceClay => 'Arcilla';

  @override
  String get settingsSurfaceClaySubtitle => 'Acolchado 3D';

  @override
  String get settingsWidgetsLivePreview =>
      'Vista previa en vivo y personalización de estilo';

  @override
  String get settingsWidgetPreviewHeader => 'VISTA PREVIA EN VIVO DEL WIDGET';

  @override
  String get settingsWidgetStreak => 'Streak active! • Daily goal';

  @override
  String get settingsWidgetWotd => 'PALABRA DEL DÍA';

  @override
  String get settingsWidgetVotd => 'VERSÍCULO DEL DÍA';

  @override
  String get settingsWidgetBackgroundHeader => 'TEMA Y DEGRADADOS DE FONDO';

  @override
  String get settingsWidgetContrastHeader => 'CONTRASTE DEL TEXTO';

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
  String get settingsFontSizeHeader => 'TAMAÑO DE FUENTE';

  @override
  String get settingsFontWeightHeader => 'GROSOR DE FUENTE';

  @override
  String get settingsWeightLight => 'Light';

  @override
  String get settingsWeightRegular => 'Regular';

  @override
  String get settingsWeightMedium => 'Medium';

  @override
  String get settingsWeightBold => 'Bold';

  @override
  String get settingsLineSpacingHeader => 'INTERLINEADO';

  @override
  String get settingsSpacingCompact => 'Compact';

  @override
  String get settingsSpacingNormal => 'Normal';

  @override
  String get settingsMarginsHeader => 'MÁRGENES';

  @override
  String get settingsAlignmentHeader => 'ALINEACIÓN';

  @override
  String get settingsAlignLeft => 'Left';

  @override
  String get settingsAlignCenter => 'Center';

  @override
  String get settingsAlignRight => 'Right';

  @override
  String get settingsAlignJustified => 'Justified';

  @override
  String get settingsFontFamilyHeader => 'FAMILIA DE FUENTES';

  @override
  String get settingsItalicHeader => 'TEXTO DE LECTURA EN CURSIVA';

  @override
  String get settingsDailyReading => 'Daily reading';

  @override
  String get settingsCustomReminder => 'Custom reminder';

  @override
  String get settingsMonday => 'Lunes';

  @override
  String get settingsTuesday => 'Martes';

  @override
  String get settingsWednesday => 'Miércoles';

  @override
  String get settingsThursday => 'Jueves';

  @override
  String get settingsFriday => 'Viernes';

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
    return 'La Biblia en inglés sencillo dejó sin traducir algunos versículos o muy truncados. Para esos ($count versículos), se muestra el texto de la World English Bible (WEB) marcado con una insignia WEB.';
  }

  @override
  String settingsDayAtTime(String day, String time) {
    return '$day at $time';
  }

  @override
  String get spaceTitle => 'Tu espacio';

  @override
  String get spaceTabHighlights => 'Resaltados';

  @override
  String get spaceTabBookmarks => 'Marcadores';

  @override
  String get spaceTabNotes => 'Notas';

  @override
  String get spaceTabJournal => 'Diario';

  @override
  String get spaceHighlighted => 'Resaltado';

  @override
  String get spaceNewFolder => 'New folder';

  @override
  String get spaceFolderNameHint => 'Nombre de la carpeta';

  @override
  String get spaceCreate => 'Crear';

  @override
  String get spaceRenameFolder => 'Rename folder';

  @override
  String get spaceRename => 'Renombrar';

  @override
  String get spaceDeleteFolderTitle => '¿Eliminar carpeta?';

  @override
  String spaceDeleteFolderBody(String folderName) {
    return 'Are you sure you want to delete \"$folderName\"?\n\nYour bookmarks inside this folder will NOT be deleted; they will be moved to Unfiled.';
  }

  @override
  String get spaceMoveToFolder => 'Mover a la carpeta';

  @override
  String get spaceUnfiled => 'Sin carpeta';

  @override
  String get spaceGroupEarlier => 'Earlier';

  @override
  String get spaceGroupLast7Days => 'Last 7 days';

  @override
  String get spaceGroupLast30Days => 'Last 30 days';

  @override
  String get spaceUnknownBook => 'Unknown book';

  @override
  String get spaceNoBookmarks => 'No hay marcadores aquí.';

  @override
  String get spaceFilterAll => 'Todos';

  @override
  String get spaceByDate => 'By date';

  @override
  String get spaceByBook => 'By book';

  @override
  String get spaceYourNotes => 'Tus notas.';

  @override
  String get spaceNoNotesTapPlus => 'No notes yet.\nTap + to create one.';

  @override
  String get spaceMore => 'Más';

  @override
  String get spaceNote => 'Nota';

  @override
  String get spaceCopyText => 'Copiar texto';

  @override
  String get spaceUntitled => 'Untitled';

  @override
  String get spaceBookmarkedVerse => 'Versículo guardado';

  @override
  String get spaceHighlightedVerse => 'Versículo resaltado';

  @override
  String get spaceOpenInRead => 'Abrir en Leer';

  @override
  String get spaceAddNote => 'Añadir nota';

  @override
  String get spaceCopyVerse => 'Copiar versículo';

  @override
  String get spaceShareVerse => 'Compartir versículo';

  @override
  String get spaceChangeColour => 'Change color';

  @override
  String get spaceMoveToFolderAction => 'Mover a la carpeta';

  @override
  String get spaceRemoveBookmark => 'Quitar marcador';

  @override
  String get spaceRemoveHighlight => 'Quitar resaltado';

  @override
  String get spaceHighlightColour => 'Highlight color';

  @override
  String spaceColourN(int index) {
    return 'Color $index';
  }

  @override
  String get notesMyNotes => 'My notes';

  @override
  String get notesEmptyTitle => 'Todavía no hay notas';

  @override
  String get notesEmptyBody => 'Toca el botón + para añadir tu primera nota.';

  @override
  String get notesVerseInserted => 'Versículo insertado';

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
      'Empieza a escribir... (escribe / para los comandos)';

  @override
  String get notesInsertVerse => 'Insertar el versículo';

  @override
  String get notesInsertDate => 'Insertar la fecha';

  @override
  String get notesInsertChapterTitle => 'Insertar el título del capítulo';

  @override
  String get notesSaved => '¡Nota guardada!';

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
  String get notesJournalHint => '¿Cómo te sientes hoy? Vuelca tu corazón...';

  @override
  String get notesSaveAndAnalyze => 'Save & analyze';

  @override
  String get notesNoJournalEntries => 'Todavía no hay entradas de diario.';

  @override
  String get notesWriteEntry => 'Write entry';

  @override
  String get notesAiReflection => 'AI reflection';

  @override
  String notesDetectedEmotion(String emotion) {
    return 'Emoción detectada: $emotion';
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
  String get accountAccount => 'Cuenta';

  @override
  String get accountSettings => 'Ajustes';

  @override
  String get accountBackUp => 'Copia de seguridad de datos';

  @override
  String get accountBackUpSubtitle => 'Exportar notas, resaltados y ajustes';

  @override
  String get accountRestore => 'Restaurar los datos';

  @override
  String get accountRestoreSubtitle =>
      'Importar desde un archivo de copia de seguridad';

  @override
  String get accountSignInGoogle => 'Iniciar sesión con Google';

  @override
  String get accountSignInApple => 'Iniciar sesión con Apple';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountResetApp => 'Restablecer la aplicación';

  @override
  String get accountResetAppSubtitle =>
      'Borrar todos los datos del dispositivo';

  @override
  String get accountSignIn => 'Sign in';

  @override
  String get accountSignedIn => 'Signed in';

  @override
  String get accountDeleteAccount => 'Delete account';

  @override
  String get accountDeleteAccountTitle => '¿Eliminar cuenta?';

  @override
  String get accountDeleteAccountBody =>
      'This is permanent and irreversible.\n\nThe following will be completely removed:\n• Your sign-in account\n• Its cloud data in The Blessed Bible and Blessed Arcade (they share the account)\n• All on-device study data (bookmarks, highlights, history)';

  @override
  String get accountDeleted => 'Cuenta eliminada con sucesso.';

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
  String get accountRestoreTitle => 'Restaurar desde una copia de seguridad';

  @override
  String get accountRestoreHint => 'Pega aquí tu copia de seguridad JSON...';

  @override
  String get accountRestoreAction => 'Restaurar';

  @override
  String get accountResetTitle => '¿Restablecer la aplicación?';

  @override
  String get accountResetBody =>
      'This erases all on-device data:\n• Bookmarks, highlights, notes & journal\n• Reading plans, progress & custom plans\n• Downloaded translations & streaks\n\nSettings, theme and the offline Bible stay untouched. This cannot be undone — back up first if needed.';

  @override
  String get accountResetDone =>
      'Datos de la aplicación restablecidos. ¡Nuevo comienzo!';

  @override
  String get accountReset => 'Restablecer';

  @override
  String get shareBackdrop => 'Fondo';

  @override
  String get shareBackdropDawn => 'Amanecer';

  @override
  String get shareBackdropDusk => 'Dusk';

  @override
  String get shareBackdropArtwork => 'Artwork';

  @override
  String get shareBackdropGradient => 'Gradient';

  @override
  String get shareFont => 'Font';

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
  String get shareText => 'Compartir texto';

  @override
  String get shareImageCard => 'Compartir tarjeta de imagen';

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
  String get spaceStorageTitle => 'Almacenamiento';

  @override
  String get spaceClearCacheTitle => '¿Borrar caché?';

  @override
  String get spaceClearCacheBody =>
      'Removes temporary files (generated share cards, thumbnails). Your notes, bookmarks, highlights and downloads are untouched.';

  @override
  String get spaceClearCache => 'Borrar caché';

  @override
  String get spaceCacheCleared => 'Cache cleared';

  @override
  String spaceDeletePackTitle(String name) {
    return '¿Eliminar $name?';
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
  String get spaceOnThisDevice => 'En este dispositivo';

  @override
  String get spaceBibleContent => 'Contenido bíblico (siempre conservado)';

  @override
  String get spaceDownloadedPacks => 'Paquetes descargados';

  @override
  String get spaceCache => 'Caché';

  @override
  String get spaceCacheExplain =>
      'Temporary files only — generated share cards and thumbnails. Safe to clear at any time.';

  @override
  String get spaceTranslationsDownloads => 'Traducciones y descargas';

  @override
  String get spaceBundledSuffix => ' · bundled';

  @override
  String get spaceCoreNotRemovable =>
      'Core KJV and BBE are part of the app and can\'t be removed.';

  @override
  String get spaceGet => 'Obtener';

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
  String get storiesHighlight => 'Resaltar';

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
  String get studyCardSize => 'Tamaño de la tarjeta';

  @override
  String get studyPosition => 'Posición';

  @override
  String get studySizeLarge => 'Grande';

  @override
  String get studySizeLargeHint => 'Ancho completo, mismo tamaño que todo';

  @override
  String get studySizeExtraLarge => 'Extra large';

  @override
  String get studySizeExtraLargeHint =>
      'Ancho completo, contenido más espacioso';

  @override
  String get studySizeHalf => 'Mitad';

  @override
  String get studySizeHalfHint => 'Compacto, dos por fila';

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
  String get studyVerseOfTheDay => 'Versículo del día';

  @override
  String get studyRecentVerses => 'Recent verses';

  @override
  String get studyWordLookUp => 'Buscar';

  @override
  String get studyConcordanceClear => 'Clear';

  @override
  String get studyConcordanceBrowseAll => 'Browse all terms';

  @override
  String get studyConcordanceFeatured => 'Featured biblical terms';

  @override
  String get studyConcordanceFilterAll => 'Todos';

  @override
  String get studyConcordanceFilterOT => 'Antiguo Testamento';

  @override
  String get studyConcordanceFilterNT => 'Nuevo Testamento';

  @override
  String get studyMoveUp => 'Mover arriba';

  @override
  String get studyMoveUpHint => 'Intercambiar con la tarjeta de arriba';

  @override
  String get studyMoveDown => 'Mover abajo';

  @override
  String get studyMoveDownHint => 'Intercambiar con la tarjeta de abajo';

  @override
  String get studyCommentaryEyebrow => 'Comentario';

  @override
  String get studyCommentaryTitle => 'Análisis versículo por versículo';

  @override
  String get studyCommentarySnippet =>
      'Historicist commentary with chapter + verse filters.';

  @override
  String get studyCommentaryCta => 'Open commentary';

  @override
  String get studyDictionaryEyebrow => 'Diccionario';

  @override
  String get studyDictionaryTitle => 'Palabras definidas';

  @override
  String get studyDictionarySnippet =>
      'Easton & Smith, offline, with saved words.';

  @override
  String get studyDictionaryCta => 'Buscar';

  @override
  String get studyStoriesEyebrow => 'Bible stories';

  @override
  String get studyStoriesTitle => 'Relatos recreados';

  @override
  String get studyStoriesSnippet => '66 stories across every book.';

  @override
  String get studyStoriesCta => 'Leer los relatos';

  @override
  String get studyConcordanceEyebrow => 'Concordancia';

  @override
  String get studyConcordanceTitle => 'Cada aparición';

  @override
  String get studyConcordanceSnippet => 'Find each verse where a word appears.';

  @override
  String get studyConcordanceCta => 'Buscar palabras';

  @override
  String get studySpaceSaved => 'Guardado';

  @override
  String get studySpaceMarked => 'Marked';

  @override
  String get studySpaceNotes => 'Notas';

  @override
  String get studySpaceJournal => 'Diario';

  @override
  String get studySpaceTitle => 'Tu espacio';

  @override
  String get studySpaceSubtitle => 'Marcadores, resaltados, notas y diario';

  @override
  String get studyReadingPlan => 'Plan de lectura';

  @override
  String get studyStartReadingPlan => 'Empezar un plan de lectura';

  @override
  String get studyActivePlan => 'Plan activo';

  @override
  String studyDayOfTotal(int current, int total) {
    return 'Día $current de $total';
  }

  @override
  String studyDaysBehind(int count) {
    return '$count behind';
  }

  @override
  String get studyPlans => 'Planes';

  @override
  String get studyGuidedReading => 'Lectura guiada';

  @override
  String get studyGuidedReadingSubtitle =>
      'Seleccionados, a ritmo y personalizados';

  @override
  String get studyReadyToBegin => 'Listo para empezar';

  @override
  String studyTodayLabel(String label) {
    return 'Hoy: $label';
  }

  @override
  String get studyReview => 'Review';

  @override
  String get studyRead => 'Leer';

  @override
  String studyCtaArrow(String cta) {
    return '$cta →';
  }

  @override
  String get studyWordOfTheDay => 'Palabra del día';

  @override
  String get studyArchiveLink => 'Archivo →';

  @override
  String get studyLoading => 'Cargando…';

  @override
  String get studyUnavailableNow => 'Unavailable right now';

  @override
  String get studyReadingStreak => 'Racha de lectura';

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
  String get studyViewProgress => 'Ver el progreso →';

  @override
  String get studyPassageNotFound => 'Pasaje no encontrado';

  @override
  String get studyPassageLoadError =>
      'No se pudieron cargar los datos del pasaje.';

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
    return 'Pasaje $current de $total';
  }

  @override
  String studySelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get studyHighlight => 'Resaltar';

  @override
  String get studyBookmark => 'Marcador';

  @override
  String get studyAddNote => 'Añadir nota';

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
  String get studyCommentaryLoadError => 'No se pudo cargar el comentario.';

  @override
  String get studyNoCommentaryYet => 'Todavía no hay comentario disponible.';

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
  String get studyAllSources => 'Todas las fuentes';

  @override
  String get studyVerseLevel => 'A nivel de versículo';

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
  String get studyCategoryCommentary => 'Comentario';

  @override
  String get studyCategoryDevotional => 'Devotional';

  @override
  String get studyCategoryStudyNote => 'Study note';

  @override
  String get studyNoContentForFilters =>
      'No se encontró contenido para estos filtros.';

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
  String get studyRemoveBookmark => 'Quitar marcador';

  @override
  String get studyBookmarkCommentary => 'Bookmark commentary';

  @override
  String get studyExpandFullScreen => 'Ampliar a pantalla completa';

  @override
  String get studyTapToReadInContext => 'Toca para leer en contexto';

  @override
  String get studyOnThisChapter => 'En este capítulo';

  @override
  String get studyOnThisBook => 'En este libro';

  @override
  String get studyNoCommentaryTitle => 'Todavía no hay comentario';

  @override
  String get studyNoCommentaryBody =>
      'We couldn\'t find specific commentary for this passage. Try exploring the chapter or book-level commentary below.';

  @override
  String get storiesTitle => 'Bible stories';

  @override
  String get storiesFilters => 'Filtros';

  @override
  String get storiesSubtitle =>
      '500 momentos ilustrados del Génesis al Apocalipsis';

  @override
  String get storiesSearchHint => 'Busca por título, libro o referencia…';

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
    return '$count de $total relatos';
  }

  @override
  String get storiesFavorites => 'Guardado';

  @override
  String get storiesUnread => 'No leído';

  @override
  String get storiesBooks => 'Books';

  @override
  String get storiesSearchBooks => 'Buscar libros…';

  @override
  String get storiesAllBooks => 'Todos los libros';

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
  String get storiesMarkAsRead => 'Marcar como leído';

  @override
  String storiesKeyVerse(String reference) {
    return 'VERSÍCULO CLAVE · $reference';
  }

  @override
  String get storiesTheStory => 'EL RELATO';

  @override
  String storiesArtworkCaption(String caption) {
    return 'Ilustración: $caption — Gustave Doré, dominio público';
  }

  @override
  String get storiesPrevious => 'Relato anterior';

  @override
  String get storiesNext => 'Relato siguiente';

  @override
  String storiesPosition(int index, int total, String book) {
    return '$index de $total en $book';
  }

  @override
  String get studyDictionarySearchHint => 'Busca entre más de 3400 palabras…';

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
  String get studyNoDefinition => 'No se encontró ninguna definición.';

  @override
  String studyStrongsShareText(String id, String lemma, String transliteration,
      String pronunciation, String definition) {
    return '$id - $lemma\n\nTransliteration: $transliteration\nPronunciation: $pronunciation\n\nDefinition:\n$definition';
  }

  @override
  String studyNoStrongsEntry(String id) {
    return 'No se encontró ninguna entrada para $id.';
  }

  @override
  String get studyStrongsLexicon => 'STRONG\'S LEXICON';

  @override
  String get studyConcordanceHint =>
      'Escribe una palabra (p. ej. gracia, pacto)…';

  @override
  String studyConcordanceIntro(String translation) {
    return 'Apariciones en $translation — toca un versículo para leerlo en contexto.';
  }

  @override
  String get studyConcordanceEmpty =>
      'Every verse containing your word, in canonical order.';

  @override
  String get studyConcordanceSingleWord =>
      'Escribe una palabra o una frase para buscar.';

  @override
  String studyConcordanceNoVerses(String word) {
    return 'Ningún versículo contiene «$word».';
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
    return 'Preparando la Biblia sin conexión… $percent %';
  }

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorBody =>
      'Ocurrió un problema inesperado. Toca abajo para volver a la pantalla de inicio.';

  @override
  String get errorBackHome => 'Volver al inicio';

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
  String get notifDailyTitle => 'Hora de leer';

  @override
  String get notifDailyBody => 'Tómate un momento para leer y reflexionar hoy.';

  @override
  String get notifDailyChannel => 'Daily reminders';

  @override
  String get notifDailyChannelDesc => 'Recordatorios para la lectura diaria';

  @override
  String get notifPrayerTitle => 'Time for prayer';

  @override
  String get notifPrayerBody =>
      'Haz una pausa para un momento de reflexión y oración.';

  @override
  String get notifPrayerChannel => 'Prayer reminders';

  @override
  String get notifPrayerChannelDesc => 'Recordatorios diarios de oración';

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
  String get notifSabbathBody => 'Bienvenido al día de descanso.';

  @override
  String get notifSabbathChannel => 'Sabbath reminders';

  @override
  String get notifSabbathChannelDesc =>
      'Recordatorios semanales del atardecer para el sábado';

  @override
  String get notifPlanBody => 'Tómate un momento para leer tu pasaje diario.';

  @override
  String get notifPlanChannel => 'Plan de lectura';

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
    return 'Error al exportar: $error';
  }

  @override
  String backupNewerVersion(int version) {
    return 'This backup is from a newer app version (v$version). Update the app first.';
  }

  @override
  String get backupConfirmTitle => 'Confirm restore';

  @override
  String get backupConfirmBody =>
      'Esto sobrescribirá todas las notas, resaltados, marcadores y ajustes existentes. ¿Seguro?';

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
  String get greetingDaily1Title => 'La paz sea con vosotros.';

  @override
  String get greetingDaily1Subtitle => 'Deja que su palabra te traiga reposo.';

  @override
  String get greetingDaily2Title => 'Camina en la luz.';

  @override
  String get greetingDaily2Subtitle =>
      'Su palabra es una lámpara para tu camino.';

  @override
  String get greetingDaily3Title => 'Gracia y paz para ti';

  @override
  String get greetingDaily3Subtitle => 'Descansa hoy en la vid.';

  @override
  String get greetingDaily4Title => 'Venid a las aguas.';

  @override
  String get greetingDaily4Subtitle => 'Jesús es la luz del mundo.';

  @override
  String get greetingDaily5Title => 'Que el Señor te bendiga.';

  @override
  String get greetingDaily5Subtitle =>
      'Mantén sus promesas cerca de tu corazón.';

  @override
  String get greetingDaily6Title => 'Estate quieto y sabe.';

  @override
  String get greetingDaily6Subtitle => 'Habita en Su presencia serena';

  @override
  String get greetingDaily7Title => 'Las misericordias de la mañana, cada día.';

  @override
  String get greetingDaily7Subtitle => 'Sus misericordias no fallan.';

  @override
  String get greetingDaily8Title => 'Raíz en el amor.';

  @override
  String get greetingDaily8Subtitle => 'Crece en gracia y verdad.';

  @override
  String get greetingDaily9Title => 'Deja que tu luz brille.';

  @override
  String get greetingDaily9Subtitle =>
      'Una ciudad sobre un cerro no puede quedar oculta.';

  @override
  String get greetingDaily10Title => 'Aproximai-vos de Deus';

  @override
  String get greetingDaily10Subtitle => 'Ya tiende la mano hacia ti.';

  @override
  String get greetingDaily11Title => 'La Palabra se hizo carne.';

  @override
  String get greetingDaily11Subtitle => 'Él comprende tu viaje.';

  @override
  String get greetingDaily12Title => 'Gusta y ved.';

  @override
  String get greetingDaily12Subtitle => 'El Señor es increíblemente bueno.';

  @override
  String get greetingMorning1Title => 'Despierta, tú que duermes.';

  @override
  String get greetingMorning1Subtitle => 'Cristo brillará sobre ti.';

  @override
  String get greetingMorning2Title => 'El gozo llega por la mañana.';

  @override
  String get greetingMorning2Subtitle => 'Entra en Su nuevo día.';

  @override
  String get greetingMorning3Title => 'Este es el día que hizo el Señor.';

  @override
  String get greetingMorning3Subtitle => 'Regocijémonos en ello.';

  @override
  String get greetingEvening1Title => 'El día ha terminado.';

  @override
  String get greetingEvening1Subtitle => 'Da sueño a los que ama.';

  @override
  String get greetingEvening2Title => 'Bajo sus alas.';

  @override
  String get greetingEvening2Subtitle => 'Encontrarás refugio esta noche.';

  @override
  String get greetingEvening3Title => 'Venid a Mí, los que estáis cansados.';

  @override
  String get greetingEvening3Subtitle => 'y os daré descanso.';

  @override
  String get greetingGrace1Title => 'Deixa toda a tua ansiedade a Ele.';

  @override
  String get greetingGrace1Subtitle => 'Porque Él se preocupa por ti.';

  @override
  String get greetingGrace2Title => 'La paz os doy.';

  @override
  String get greetingGrace2Subtitle => 'No dejes que tu corazón se turbe.';

  @override
  String get greetingGrace3Title => 'Sana a los de corazón quebrado.';

  @override
  String get greetingGrace3Subtitle => 'y venda sus heridas.';

  @override
  String get greetingGrace4Title => 'Nada puede separarnos.';

  @override
  String get greetingGrace4Subtitle => 'Del amor de Dios';

  @override
  String get greetingCheer1Title => 'Sé fuerte y valiente.';

  @override
  String get greetingCheer1Subtitle => 'El Señor tu Dios va contigo.';

  @override
  String get greetingCheer2Title => 'Corre con perseverancia.';

  @override
  String get greetingCheer2Subtitle => 'Mantén tus ojos fijos en Jesús.';

  @override
  String get greetingCheer3Title => 'El hierro afila el hierro.';

  @override
  String get greetingCheer3Subtitle => 'Crescan juntos en la Palabra.';

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
  String get creditsCommentary => 'Comentario';

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
  String get miscFolderStudy => 'Estudio';

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
  String get miscSearchCommentary => 'Comentario';

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
