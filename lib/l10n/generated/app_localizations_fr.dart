// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'The Blessed Bible';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Comme l\'appareil';

  @override
  String get languageSubtitle =>
      'La langue des menus et des boutons. Votre traduction de la Bible se choisit à part.';

  @override
  String get onboardingTagline => 'Les Écritures, sans distraction.';

  @override
  String get onboardingPickLanguage => 'Choisissez votre langue';

  @override
  String get onboardingLanguageHint =>
      'Vous pourrez la changer à tout moment dans les Réglages.';

  @override
  String get onboardingBibleTitle => 'Votre Bible';

  @override
  String get onboardingBibleBody =>
      'Choisissez la traduction que vous lisez le plus. Vous pouvez en afficher une seconde en parallèle.';

  @override
  String onboardingParallel(String name) {
    return 'Afficher aussi $name en parallèle';
  }

  @override
  String get onboardingLookTitle => 'Lisez à votre aise';

  @override
  String get onboardingLookBody =>
      'Choisissez une couleur de page et une taille de texte. Tout reste ajustable ensuite.';

  @override
  String get onboardingThemeLight => 'Clair';

  @override
  String get onboardingThemeSepia => 'Sépia';

  @override
  String get onboardingThemeDark => 'Sombre';

  @override
  String get onboardingTextSize => 'Taille du texte';

  @override
  String get onboardingPreviewVerse =>
      'Au commencement était la Parole, et la Parole était avec Dieu, et la Parole était Dieu.';

  @override
  String get onboardingPreviewRef => 'Jean 1:1';

  @override
  String get onboardingFeaturesTitle => 'Tout pour votre marche quotidienne';

  @override
  String get onboardingFeatureWordTitle => 'La Parole, simplement';

  @override
  String get onboardingFeatureWordBody =>
      'Lisez sans distraction, avec surlignages, notes et signets.';

  @override
  String get onboardingFeaturePlansTitle => 'Plans de lecture';

  @override
  String get onboardingFeaturePlansBody =>
      'Chronologiques, thématiques ou personnels — avec de doux rappels.';

  @override
  String get onboardingFeatureStudyTitle => 'Étude approfondie';

  @override
  String get onboardingFeatureStudyBody =>
      'Commentaires, dictionnaire, Strong et cartes, juste à côté du texte.';

  @override
  String get onboardingFeatureSyncTitle => 'En sécurité';

  @override
  String get onboardingFeatureSyncBody =>
      'Connectez-vous quand vous voulez pour synchroniser vos appareils. Aucun compte n\'est requis pour lire.';

  @override
  String get onboardingBegin => 'Commencer la lecture';

  @override
  String onboardingStep(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get plansContinueReading => 'Reprendre la lecture';

  @override
  String get plansResume => 'Reprendre';

  @override
  String plansDayCompleteCelebration(int day) {
    return 'Plan de lecture\nJour $day terminé !';
  }

  @override
  String get plansChangeWeek => 'Changer de semaine';

  @override
  String plansCalendarDayComplete(String label) {
    return '$label, lecture terminée';
  }

  @override
  String plansCalendarDayToday(String label) {
    return '$label, aujourd\'hui';
  }

  @override
  String get plansDailyVerses => 'Versets du jour';

  @override
  String get plansToday => 'Aujourd\'hui';

  @override
  String get plansYesterday => 'Hier';

  @override
  String plansDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get plansHello => 'Bonjour,';

  @override
  String plansOpenStory(String caption) {
    return 'Ouvrir l\'histoire : $caption';
  }

  @override
  String get plansBibleStory => 'Histoire biblique';

  @override
  String plansSlotsFull(int count) {
    return 'Les $count emplacements de plan sont utilisés. Mettez un plan en pause pour en libérer un — la progression est conservée.';
  }

  @override
  String get plansPausedSnack =>
      'Plan en pause — toute la progression est conservée.';

  @override
  String get plansBrowseToStart =>
      'Parcourez Lecture pour commencer votre premier plan.';

  @override
  String get plansFriend => 'ami';

  @override
  String get plansTitle => 'Plans';

  @override
  String get plansTabReading => 'Lecture';

  @override
  String get plansTabBooks => 'Livres';

  @override
  String plansTabMyPlans(int count) {
    return 'Mes plans ($count)';
  }

  @override
  String get plansNotStarted => 'Pas commencé';

  @override
  String plansPercentDone(int percent) {
    return '$percent % fait';
  }

  @override
  String get plansOpen => 'Ouvrir';

  @override
  String get plansPaused => 'En pause';

  @override
  String get plansStarted => 'Commencé';

  @override
  String plansDaysBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours de retard',
      one: '1 jour de retard',
    );
    return '$_temp0';
  }

  @override
  String get plansCaughtUp => 'À jour';

  @override
  String get plansComplete => 'Terminé';

  @override
  String plansDayOfTotalLeft(int current, int total, int left) {
    return 'Jour $current sur $total · reste $left';
  }

  @override
  String get plansPauseKeepsProgress => 'Pause (conserve la progression)';

  @override
  String get plansStart => 'Commencer';

  @override
  String plansPresetBookTitle(String book, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$book en $days jours',
      one: '$book en 1 jour',
    );
    return '$_temp0';
  }

  @override
  String plansPresetGospelsTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Évangiles en $days jours',
      one: 'Évangiles en 1 jour',
    );
    return '$_temp0';
  }

  @override
  String plansPresetSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours · touchez pour créer',
      one: '1 jour · touchez pour créer',
    );
    return '$_temp0';
  }

  @override
  String get plansYourCustomPlans => 'VOS PLANS PERSONNALISÉS';

  @override
  String plansDayOfTotal(int day, int total) {
    return 'Jour $day sur $total';
  }

  @override
  String get plansCustomPlan => 'Plan personnalisé';

  @override
  String get plansNoActivePlans => 'Aucun plan actif';

  @override
  String get plansNoActivePlansBody =>
      'Parcourez Lecture ou Livres pour commencer votre premier plan.';

  @override
  String get plansLetsRead => 'Lisons';

  @override
  String get plansVerseOfTheDay => 'Verset du jour';

  @override
  String get plansOpenTodaysReading => 'Ouvrir la lecture du jour';

  @override
  String get plansLastDayOfYear => 'Dernier jour de l\'année';

  @override
  String plansDaysLeftInYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Plus que $count jours cette année',
      one: 'Plus que 1 jour cette année',
    );
    return '$_temp0';
  }

  @override
  String get plansCustomPlanDefaultTitle => 'Plan personnalisé';

  @override
  String get plansCustom => 'Personnalisé';

  @override
  String plansBookRange(String start, String end) {
    return '$start à $end';
  }

  @override
  String plansCouldNotSave(String error) {
    return 'Impossible d\'enregistrer le plan : $error';
  }

  @override
  String get plansBuilderTitle => 'Créateur de plan';

  @override
  String plansError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get plansPlanName => 'Nom du plan';

  @override
  String get plansPlanNameHint => 'ex. Genèse en 30 jours';

  @override
  String get plansReadingTracks => 'Parcours de lecture';

  @override
  String get plansAddTrack => 'Ajouter un parcours';

  @override
  String get plansTracksOverlap =>
      'Les parcours se chevauchent — les versets communs ne sont comptés qu\'une fois dans l\'aperçu ci-dessous.';

  @override
  String get plansDuration => 'Durée';

  @override
  String plansDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get plansDaysSuffix => 'jours';

  @override
  String get plansStartRestReminder => 'Début, repos et rappel';

  @override
  String get plansStartDate => 'Date de début';

  @override
  String get plansRestDaysNeutral => 'Jours de repos (neutres)';

  @override
  String get plansNone => 'Aucun';

  @override
  String get plansDailyReminder => 'Rappel quotidien';

  @override
  String plansReminderAt(String time) {
    return 'À $time';
  }

  @override
  String get plansOff => 'Désactivé';

  @override
  String get plansLivePreview => 'Aperçu en direct';

  @override
  String get plansPreviewEmpty =>
      'Ajoutez au moins un parcours ci-dessus pour voir le programme équilibré.';

  @override
  String get plansWordBalanced => 'Équilibré par mots · respecte les péricopes';

  @override
  String plansPreviewSummary(int days, int readingDays) {
    return '$days jours · $readingDays jours de lecture';
  }

  @override
  String plansClampedNotice(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Le rythme le plus doux pour cette sélection est de $days jours. Titre mis à jour avec la durée réelle.',
      one:
          'Le rythme le plus doux pour cette sélection est de 1 jour. Titre mis à jour avec la durée réelle.',
    );
    return '$_temp0';
  }

  @override
  String plansPreviewDay(int day, String portions) {
    return 'Jour $day : $portions';
  }

  @override
  String plansMoreBalancedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres jours équilibrés',
      one: '1 autre jour équilibré',
    );
    return '$_temp0';
  }

  @override
  String get plansSaving => 'Enregistrement…';

  @override
  String get plansGenerateAndSave => 'Créer et enregistrer →';

  @override
  String get plansNameAndTrackHint =>
      'Nommez le plan et ajoutez au moins un parcours pour continuer.';

  @override
  String get plansStartEllipsis => 'Début…';

  @override
  String get plansEndEllipsis => 'Fin…';

  @override
  String get plansStartLabel => 'DÉBUT';

  @override
  String get plansEndLabel => 'FIN';

  @override
  String get plansRemoveTrack => 'Retirer le parcours';

  @override
  String plansRestChip(String days) {
    return 'Repos $days';
  }

  @override
  String plansRebasedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Programme décalé de $count jours de lecture. Les jours terminés restent inchangés.',
      one:
          'Programme décalé de 1 jour de lecture. Les jours terminés restent inchangés.',
    );
    return '$_temp0';
  }

  @override
  String get plansPlan => 'Plan';

  @override
  String get plansNoReadingsYet => 'Ce plan n\'a pas encore de lectures.';

  @override
  String plansReadingDaysWeeks(int days, int weeks) {
    return '$days jours de lecture · ~$weeks semaines';
  }

  @override
  String get plansBeginPlan => 'Commencer le plan';

  @override
  String get plansStartDayOne => 'Commencer le jour 1 →';

  @override
  String get plansStartDateNote => 'Votre plan commence à la date choisie.';

  @override
  String get plansScheduleLabel => 'PROGRAMME';

  @override
  String get plansNoReadings => 'Aucune lecture';

  @override
  String plansPercentComplete(int percent) {
    return '$percent % terminé';
  }

  @override
  String get plansFlexible => 'Flexible';

  @override
  String get plansScheduled => 'Programmé';

  @override
  String plansBehindChip(int count) {
    return '$count en retard';
  }

  @override
  String get plansOnTrack => 'Dans les temps';

  @override
  String get plansFlexibleHelp =>
      'Flexible : lisez d\'abord le jour non lu le plus ancien. Les jours manqués ne s\'accumulent pas.';

  @override
  String get plansScheduledHelp =>
      'Programmé : chaque date a son jour de lecture. Les jours manqués comptent comme du retard — rattrapez-les ci-dessous.';

  @override
  String get plansCatchUp => 'Rattraper';

  @override
  String plansBehindBy(int count, int day) {
    return '$count de retard — le plus ancien non lu est le jour $day.';
  }

  @override
  String get plansCatchUpHelp =>
      'Marquer des jours comme lus enregistre la progression. Décaler repousse plutôt le reste du programme.';

  @override
  String get plansGoToOldest => 'Aller au plus ancien';

  @override
  String get plansMarkOldestDone => 'Marquer le plus ancien lu';

  @override
  String get plansAllPreviousDone =>
      'Tout ce qui précède aujourd\'hui est déjà fait.';

  @override
  String plansPreviousMarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours précédents marqués comme lus.',
      one: '1 jour précédent marqué comme lu.',
    );
    return '$_temp0';
  }

  @override
  String get plansMarkAllPrevious => 'Tout marquer comme lu';

  @override
  String plansRebaseDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Décaler de +$count jours',
      one: 'Décaler de +1 jour',
    );
    return '$_temp0';
  }

  @override
  String plansReadingsHeader(int count) {
    return 'LECTURES · $count JOURS';
  }

  @override
  String get plansJourneyMap => 'Vue carte du parcours';

  @override
  String get plansJumpToToday => 'Aller à aujourd\'hui';

  @override
  String plansDayN(int day) {
    return 'Jour $day';
  }

  @override
  String get plansLegendDone => 'Lu';

  @override
  String get plansLegendToday => 'Aujourd\'hui = cercle';

  @override
  String get plansLegendMissed => 'Manqué';

  @override
  String plansReminderAtTime(String time) {
    return 'Rappel · $time';
  }

  @override
  String get plansReminderOff => 'Rappel désactivé';

  @override
  String get plansReminderHelp =>
      'Notification propre au plan — ignore automatiquement les jours de repos.';

  @override
  String get plansRestDays => 'Jours de repos';

  @override
  String get plansNoRestDays => 'Aucun jour de repos';

  @override
  String get plansSettings => 'Paramètres du plan';

  @override
  String get plansAboutEllipsis => 'À propos de ce plan…';

  @override
  String get plansAbout => 'À propos de ce plan';

  @override
  String get plansChangeStartDate => 'Modifier la date de début…';

  @override
  String plansRestDaysValue(String days) {
    return 'Jours de repos : $days';
  }

  @override
  String get plansRestDaysHelp => 'Touchez pour choisir les jours';

  @override
  String get plansRestartFromDayOne => 'Recommencer au jour 1…';

  @override
  String get plansRestartTitle => 'Recommencer le plan ?';

  @override
  String get plansRestartBody => 'Les jours terminés seront effacés.';

  @override
  String get plansRestart => 'Recommencer';

  @override
  String get plansMarkUnread => 'Marquer non lu';

  @override
  String get plansMarkRead => 'Marquer lu';

  @override
  String get plansRestAndReflect => 'Repos et méditation';

  @override
  String get plansRestDayBody =>
      'Un jour de repos — aucune lecture prévue aujourd\'hui.';

  @override
  String get plansDayDetailHelp =>
      'Touchez un passage pour l\'ouvrir. Cochez-les au fil de votre lecture.';

  @override
  String plansMilestone(int count) {
    return '$count lectures terminées — continuez !';
  }

  @override
  String get plansCompletedTapToUndo => 'Terminé — touchez pour annuler';

  @override
  String plansMarkDayRead(int day, int checked, int total) {
    return 'Marquer le jour $day comme lu ✓ ($checked/$total passages)';
  }

  @override
  String get todayGoodMorning => 'Bonjour';

  @override
  String get todayGoodAfternoon => 'Bon après-midi';

  @override
  String get todayGoodEvening => 'Bonsoir';

  @override
  String get todayGoodNight => 'Bonne nuit';

  @override
  String get todayStreakNudge => 'Lisez aujourd\'hui pour garder votre série !';

  @override
  String get todayNotificationsSoon => 'Notifications bientôt disponibles !';

  @override
  String get todaySectionResume => 'REPRENDRE';

  @override
  String get todaySectionStreak => 'SÉRIE DE LECTURE';

  @override
  String get todaySectionLatestNote => 'DERNIÈRE NOTE';

  @override
  String get todaySectionQuickActions => 'ACTIONS RAPIDES';

  @override
  String get todaySectionReminders => 'RAPPELS QUOTIDIENS';

  @override
  String get todayTagline => 'Votre moment de paix quotidien.';

  @override
  String get todayNoNotesYet => 'Pas encore de notes';

  @override
  String get todayWriteFirstNote =>
      'Écrivez votre première note pour la voir ici.';

  @override
  String get todayViewAllNotes => 'Voir toutes les notes';

  @override
  String todayStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série de $count jours',
      one: 'Série de 1 jour',
    );
    return '$_temp0';
  }

  @override
  String todayDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il reste $count jours dans l\'année.',
      one: 'Il reste 1 jour dans l\'année.',
    );
    return '$_temp0';
  }

  @override
  String get todayActionRead => 'Lire';

  @override
  String get todayActionSurprise => 'Surprenez-moi';

  @override
  String get todayActionReadingPlan => 'Plan de lecture';

  @override
  String get todayActionYourSpace => 'Votre espace';

  @override
  String get todayVotdArchive => 'Archives du verset du jour';

  @override
  String get todayVotdArchiveBody => 'Retrouvez les versets des jours manqués.';

  @override
  String get todayVotdArchiveExplore => 'Explorez les versets des jours passés';

  @override
  String get readActionBookmark => 'Signet';

  @override
  String get readActionNote => 'Note';

  @override
  String get readActionNotes => 'Notes';

  @override
  String get readActionEditNote => 'Modifier la note';

  @override
  String get readActionCommentary => 'Commentaire';

  @override
  String get readActionRelated => 'Liés';

  @override
  String get readActionHighlight => 'Surligner';

  @override
  String get readActionStudy => 'Étudier';

  @override
  String get readActionSaved => 'Enregistré';

  @override
  String get readActionSelectText => 'Sélectionner';

  @override
  String get readVerseActions => 'Actions sur le verset';

  @override
  String readVersesSelected(int count, String where) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versets sélectionnés',
      one: '1 verset sélectionné',
    );
    return '$_temp0 · $where';
  }

  @override
  String get readCommentaryHint =>
      'Touchez l’ampoule près d’un verset pour voir le commentaire';

  @override
  String get readPassageNotFound => 'Passage introuvable.';

  @override
  String get readChapterCommentary => 'Lire le commentaire du chapitre';

  @override
  String get readPreviousChapter => '‹ Précédent';

  @override
  String get readNextChapter => 'Suivant ›';

  @override
  String readPlanDay(int day) {
    return 'Plan de lecture · Jour $day';
  }

  @override
  String get readPlanCompleted => 'Plan terminé ! Félicitations ! 🎉';

  @override
  String readMarkDoneContinue(String book, int chapter) {
    return 'Terminer $book $chapter et continuer';
  }

  @override
  String get readNone => 'Aucun';

  @override
  String readBookFallback(int number) {
    return 'Livre $number';
  }

  @override
  String get readRelatedVerses => 'Versets liés';

  @override
  String get readNoCrossRefs => 'Aucune référence croisée pour ce verset.';

  @override
  String get readCrossRefsComingSoon =>
      'Les références croisées seront disponibles\naprès la prochaine mise à jour.';

  @override
  String readCrossRefsLoadError(String error) {
    return 'Impossible de charger les références croisées.\n$error';
  }

  @override
  String get readVerseUnavailable => 'Verset indisponible';

  @override
  String get readLoading => 'Chargement…';

  @override
  String get readVerseNotFound => 'Verset introuvable.';

  @override
  String get readBookOrChapterNotFound => 'Livre ou chapitre introuvable.';

  @override
  String get readOpenInRead => 'Ouvrir dans Lire';

  @override
  String get readBookNotFound => 'Livre de la référence introuvable.';

  @override
  String readVerseLoadError(String error) {
    return 'Erreur de chargement du verset : $error';
  }

  @override
  String get readTestament => 'Testament';

  @override
  String get readBook => 'Livre';

  @override
  String get readChapter => 'Chapitre';

  @override
  String get readVerse => 'Verset';

  @override
  String get readSelectBook => 'Choisir un livre';

  @override
  String get readOtShort => 'AT';

  @override
  String get readNtShort => 'NT';

  @override
  String get readOldTestament => 'Ancien Testament';

  @override
  String get readNewTestament => 'Nouveau Testament';

  @override
  String get readOldTestamentTwoLine => 'Ancien\nTestament';

  @override
  String get readNewTestamentTwoLine => 'Nouveau\nTestament';

  @override
  String get readStoriesSections => 'Récits et sections';

  @override
  String get readAllVerses => 'Tous les versets';

  @override
  String get readTranslationTitle => 'Traduction de la Bible';

  @override
  String get readLayoutTitle => 'Mise en page';

  @override
  String get readLayoutSingle => 'Simple';

  @override
  String get readLayoutBilingual => 'Bilingue';

  @override
  String get readLayoutParallel => 'Parallèle';

  @override
  String get readLayoutChips => 'Puces';

  @override
  String get readLayoutSingleDesc => 'Une seule traduction';

  @override
  String get readLayoutBilingualDesc =>
      'Deux traductions superposées par verset';

  @override
  String get readLayoutParallelDesc =>
      'Deux traductions en colonnes côte à côte';

  @override
  String get readLayoutChipsDesc =>
      'Touchez un verset pour changer sa traduction';

  @override
  String get readPrimary => 'Principale';

  @override
  String get readSecondary => 'Secondaire';

  @override
  String readTranslationsLoadError(String error) {
    return 'Erreur de chargement des traductions : $error';
  }

  @override
  String readTranslationDeleted(String name) {
    return '$name supprimée.';
  }

  @override
  String readDeleteFailed(String error) {
    return 'Suppression impossible : $error';
  }

  @override
  String readDeleteTranslation(String name) {
    return 'Supprimer $name';
  }

  @override
  String get readKjvAlwaysAvailable => 'Toujours disponible · base de l’app';

  @override
  String get readCannotDeleteBackbone =>
      'Suppression impossible — base de l’app';

  @override
  String get readAvailableToAdd => 'DISPONIBLES À AJOUTER';

  @override
  String get readNoInternet =>
      'Pas de connexion Internet — réessayez une fois en ligne.';

  @override
  String get readRestoreFailed => 'Échec de la restauration';

  @override
  String get readDownloadFailed => 'Échec du téléchargement';

  @override
  String readRestoreFailedDetail(String error) {
    return 'Échec de la restauration ($error).';
  }

  @override
  String readDownloadFailedDetail(String error) {
    return 'Échec du téléchargement ($error).';
  }

  @override
  String get readRestoreOffline => 'restauration hors ligne';

  @override
  String get homeVerseOfTheDay => 'VERSET DU JOUR';

  @override
  String get homeDevotional => 'MÉDITATION';

  @override
  String get homeCommentary => 'COMMENTAIRE';

  @override
  String get homeGoDeeper => 'Approfondir';

  @override
  String get homeReadFullDefinition => 'Lire la définition';

  @override
  String get homeWordOfTheDayHeading => 'MOT DU JOUR';

  @override
  String get homeWordOfTheDay => 'Mot du jour';

  @override
  String get homeWotdEmpty =>
      'Aucun mot choisi pour aujourd’hui — réessayez plus tard.';

  @override
  String homeWotdUnavailable(String error) {
    return 'Mot du jour indisponible ($error).';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navRead => 'Lire';

  @override
  String get navStudy => 'Étude';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navExitTitle => 'Quitter The Blessed Bible ?';

  @override
  String get navExitMessage => 'Voulez-vous vraiment quitter l’application ?';

  @override
  String get navExit => 'Quitter';

  @override
  String get navCastLotsError =>
      'Impossible de tirer au sort — veuillez réessayer.';

  @override
  String get navCastingLots => 'Tirage au sort…';

  @override
  String get searchHint => 'Rechercher versets, commentaires…';

  @override
  String get searchAllBooks => 'Tous les livres';

  @override
  String get searchFilterMyNotes => 'Mes notes';

  @override
  String get searchEmptyPrompt =>
      'Recherchez dans la Bible, les commentaires\net vos notes';

  @override
  String get searchRecentSearches => 'RECHERCHES RÉCENTES';

  @override
  String get searchClear => 'EFFACER';

  @override
  String get searchRecentPlaces => 'LIEUX RÉCENTS';

  @override
  String get searchMostRead => 'LES PLUS LUS';

  @override
  String get searchNoResults => 'Aucun résultat';

  @override
  String get searchTopResults => 'Affichage des 100 meilleurs résultats';

  @override
  String searchResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String searchSectionDictionary(int count) {
    return 'DICTIONNAIRE ($count)';
  }

  @override
  String searchSectionStories(int count) {
    return 'RÉCITS ($count)';
  }

  @override
  String searchSectionJumpTo(int count) {
    return 'ALLER À ($count)';
  }

  @override
  String searchSectionVerses(int count) {
    return 'VERSETS ($count)';
  }

  @override
  String searchSectionCommentary(int count) {
    return 'COMMENTAIRES ($count)';
  }

  @override
  String searchSectionMyNotes(int count) {
    return 'MES NOTES ($count)';
  }

  @override
  String get searchCopied => 'Copié dans le presse-papiers';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsTabGeneral => 'Général';

  @override
  String get settingsTabNavigation => 'Navigation';

  @override
  String get settingsTabReminders => 'Rappels';

  @override
  String get settingsTabInfo => 'Infos';

  @override
  String get settingsWidgetsTitle => 'Widgets d\'écran d\'accueil';

  @override
  String get settingsWidgetsSubtitle =>
      'Dégradés, transparence et aperçu en direct';

  @override
  String get settingsStartPageTitle => 'Page de démarrage';

  @override
  String get settingsStartPageSubtitle =>
      'Choisissez la page affichée à l\'ouverture';

  @override
  String get settingsPageHome => 'Accueil';

  @override
  String get settingsPageRead => 'Lire';

  @override
  String get settingsPageStudy => 'Étude';

  @override
  String get settingsPageSearch => 'Recherche';

  @override
  String get settingsImmersiveReading => 'Lecture immersive';

  @override
  String get settingsImmersiveOffTitle => 'Ancré (désactivé)';

  @override
  String get settingsImmersiveOffSubtitle =>
      'La navigation reste toujours visible';

  @override
  String get settingsImmersivePartialTitle => 'Guidé (partiel)';

  @override
  String get settingsImmersivePartialSubtitle =>
      'Masque la navigation, mais garde la pastille livre et chapitre';

  @override
  String get settingsImmersiveFullTitle => 'Eaux profondes (total)';

  @override
  String get settingsImmersiveFullSubtitle =>
      'Immersion totale. Tous les menus se masquent au défilement';

  @override
  String get settingsShowStrongs => 'Afficher les numéros Strong';

  @override
  String get settingsShowStrongsSubtitle =>
      'Affiche les codes hébreux/grecs à côté du texte KJV pour l\'étude des mots';

  @override
  String get settingsStrongsGetIt => 'Obtenir';

  @override
  String get settingsStrongsMarkerAsterisk => 'Astérisque (*)';

  @override
  String get settingsStrongsMarkerChain => 'Chaîne (🔗)';

  @override
  String get settingsStrongsMarkerNumber => 'Numéro (H1234)';

  @override
  String get settingsReadingSpeed => 'Vitesse de lecture';

  @override
  String get settingsReadingSpeedSubtitle =>
      'Rythme estimé des plans (mots par minute)';

  @override
  String get settingsSpeedRelaxed => 'Détendu';

  @override
  String get settingsSpeedStandard => 'Standard';

  @override
  String get settingsSpeedBrisk => 'Rapide';

  @override
  String get settingsDictUnderlines => 'Soulignements du dictionnaire';

  @override
  String get settingsDictUnderlinesSubtitle =>
      'Soulignement pointillé des termes bibliques et mots anciens';

  @override
  String get settingsUnderlineScope => 'Portée du soulignement';

  @override
  String get settingsScopeNamesTitle => 'Noms et termes uniquement';

  @override
  String get settingsScopeNamesSubtitle =>
      'Noms propres et notions bibliques précises';

  @override
  String get settingsScopeTrickyTitle => 'Noms + mots difficiles (recommandé)';

  @override
  String get settingsScopeTrickySubtitle =>
      'Inclut les mots anciens au sens changé (ex. let, prevent)';

  @override
  String get settingsScopeEverythingTitle => 'Tout';

  @override
  String get settingsScopeEverythingSubtitle =>
      'Marque toute la grammaire ancienne (ex. thee, thou, hath, unto)';

  @override
  String get settingsScopeDifficultTitle => 'Mots difficiles uniquement';

  @override
  String get settingsScopeDifficultSubtitle =>
      'Mots anciens, trompeurs ou contestés — les mots simples comme god et son restent non marqués';

  @override
  String get settingsScopeDifficultNamesTitle => 'Difficiles + noms';

  @override
  String get settingsScopeDifficultNamesSubtitle =>
      'Ajoute personnes et lieux (ex. David, Jérusalem) aux mots difficiles';

  @override
  String get settingsOtherEnglishVersions => 'Autres versions anglaises';

  @override
  String get settingsContestedOnlyTitle => 'Mots contestés uniquement';

  @override
  String get settingsContestedOnlySubtitle =>
      'BBE, WEB et autres versions anglaises marquent les mots débattus (ex. hell, baptism)';

  @override
  String get settingsFollowScopeTitle => 'Suivre la portée du soulignement';

  @override
  String get settingsFollowScopeSubtitle =>
      'Même marquage que la KJV dans chaque version anglaise';

  @override
  String get settingsNoUnderlinesTitle => 'Aucun soulignement';

  @override
  String get settingsNoUnderlinesSubtitle =>
      'Les autres versions anglaises n\'affichent aucune marque';

  @override
  String get settingsPopupStyle => 'Style des fenêtres';

  @override
  String get settingsPopupStyleSubtitle =>
      'Affichage des définitions et des numéros Strong';

  @override
  String get settingsPopupFloating => 'Flottant';

  @override
  String get settingsPopupBottomSheet => 'Panneau inférieur';

  @override
  String get settingsSavedInMyLanguage => 'Éléments enregistrés dans ma langue';

  @override
  String get settingsSavedInMyLanguageSubtitle =>
      'Affiche signets, surlignages et versets commentés dans votre traduction principale';

  @override
  String get settingsTranslationChips =>
      'Options de traduction sur les éléments enregistrés';

  @override
  String get settingsTranslationChipsSubtitle =>
      'Ajoute une rangée compacte pour lire les versets enregistrés dans d\'autres traductions';

  @override
  String get settingsVerseActionStyle => 'Style des actions de verset';

  @override
  String get settingsVerseActionStyleSubtitle =>
      'Panneau (compact) ou Classique (barre haute) à la sélection ; Radial place le menu d\'appui long en cercle';

  @override
  String get settingsActionSheet => 'Panneau';

  @override
  String get settingsActionClassic => 'Classique';

  @override
  String get settingsActionMinimal => 'Minimal';

  @override
  String get settingsActionRaindrop => 'Goutte';

  @override
  String get settingsActionRadial => 'Radial';

  @override
  String get settingsKeepAwake => 'Garder l\'écran allumé';

  @override
  String get settingsKeepAwakeSubtitle =>
      'Empêche la mise en veille pendant la lecture';

  @override
  String get settingsRestartOnboarding => 'Relancer l\'accueil';

  @override
  String get settingsRestartOnboardingSubtitle =>
      'Rejouer la configuration initiale';

  @override
  String get settingsRestartOnboardingDialogTitle => 'Relancer l\'accueil ?';

  @override
  String get settingsRestartOnboardingDialogBody =>
      'La configuration initiale sera rejouée. Votre thème, police et traduction restent inchangés sauf si vous les modifiez.';

  @override
  String get settingsRestart => 'Relancer';

  @override
  String get settingsAppearanceText => 'Apparence et texte';

  @override
  String get settingsAppearanceTextSubtitle =>
      'Thème, polices, tailles et couleurs';

  @override
  String get settingsSabbathTitle => 'Rappel du coucher du soleil le vendredi';

  @override
  String get settingsSabbathSubtitle =>
      'Accueillez le sabbat au coucher du soleil local.';

  @override
  String get settingsLocation => 'Lieu';

  @override
  String get settingsLocationNotSet => 'Non défini (touchez pour définir)';

  @override
  String get settingsDailyReminderTitle => 'Rappel de lecture quotidienne';

  @override
  String get settingsDailyReminderSubtitle =>
      'Un petit rappel quotidien pour passer du temps dans la Parole.';

  @override
  String get settingsTime => 'Heure';

  @override
  String get settingsWeeklyReminderTitle => 'Rappel hebdomadaire';

  @override
  String get settingsWeeklyReminderSubtitle =>
      'Choisissez un jour et une heure chaque semaine pour approfondir.';

  @override
  String get settingsDayAndTime => 'Jour et heure';

  @override
  String get settingsChooseDay => 'Choisir le jour';

  @override
  String get settingsShowReadingTips => 'Afficher les astuces de lecture';

  @override
  String get settingsShowReadingTipsSubtitle =>
      'Conseils guidés pour surligner, balayer, etc.';

  @override
  String get settingsNavSteps => 'Étapes de navigation';

  @override
  String get settingsNavStepsSubtitle =>
      'Nombre d\'étapes pour atteindre un verset. 2 : Livre → Chapitre. 3 : Livre → Chapitre → Verset. 4 : Testament → Livre → Chapitre → Verset.';

  @override
  String get settingsAutoClose => 'Fermer après la dernière sélection';

  @override
  String get settingsAutoCloseSubtitle =>
      'Ferme automatiquement le sélecteur après la dernière étape';

  @override
  String get settingsSelectorHeight => 'Hauteur du sélecteur de livre';

  @override
  String get settingsSelectorHeightSubtitle =>
      'Jusqu\'où s\'ouvre le panneau livre/chapitre';

  @override
  String get settingsHeightHalf => 'Moitié';

  @override
  String get settingsHeightFull => 'Plein';

  @override
  String get settingsAutoOpenSingle => 'Ouvrir un résultat unique';

  @override
  String get settingsAutoOpenSingleSubtitle =>
      'Y aller directement quand la recherche ne trouve qu\'un résultat';

  @override
  String get settingsIncludeNotes => 'Inclure mes notes dans la recherche';

  @override
  String get settingsIncludeNotesSubtitle =>
      'Permet de chercher dans vos notes personnelles';

  @override
  String get settingsWholeWords => 'Mots entiers uniquement';

  @override
  String get settingsWholeWordsSubtitle =>
      'Mots exacts seulement (désactive la correspondance partielle)';

  @override
  String get settingsFuzzySearch => 'Recherche tolérante';

  @override
  String get settingsFuzzySearchSubtitle =>
      'Affiche aussi les résultats proches en cas de faute (ex. Jhon trouve John)';

  @override
  String get settingsDefaultScopes => 'Portées de recherche par défaut';

  @override
  String get settingsOldTestament => 'Ancien Testament';

  @override
  String get settingsNewTestament => 'Nouveau Testament';

  @override
  String get settingsCommentary => 'Commentaire';

  @override
  String get settingsGestures => 'Gestes';

  @override
  String get settingsPullDownHome => 'Tirer vers le bas sur l\'accueil';

  @override
  String get settingsPullDownHomeSubtitle =>
      'Tirez au-delà du haut pour ouvrir Paramètres ou Apparence';

  @override
  String get settingsPullDownOpens => 'Le geste ouvre';

  @override
  String get settingsPullDownOpensSubtitle =>
      'Destination du geste sur l\'accueil';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsSwipeLeftHome => 'Balayer à gauche sur l\'accueil';

  @override
  String get settingsSwipeLeftHomeSubtitle =>
      'Balayez à gauche pour aller à Lire';

  @override
  String get settingsLongPressNav => 'Appui long pour ouvrir la navigation';

  @override
  String get settingsLongPressNavSubtitle =>
      'Appui long sur le bouton en bas à droite pour ouvrir le sélecteur Livre/Chapitre.';

  @override
  String get settingsBbeNoteTitle => 'Note sur la traduction BBE';

  @override
  String get settingsBackup => 'Sauvegarder mes données';

  @override
  String get settingsBackupSubtitle =>
      'Exporter notes, surlignages et paramètres';

  @override
  String get settingsRestoreBackup => 'Restaurer une sauvegarde';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Importer vos données depuis un JSON de sauvegarde';

  @override
  String get settingsRestoreBackupDialogTitle => 'Restaurer une sauvegarde';

  @override
  String get settingsRestoreHint => 'Collez votre JSON de sauvegarde ici…';

  @override
  String get settingsRestore => 'Restaurer';

  @override
  String get settingsClearCache => 'Vider le cache et les téléchargements';

  @override
  String get settingsClearCacheSubtitle =>
      'Libérer de l\'espace en supprimant le cache';

  @override
  String get settingsNotImplemented => 'Pas encore disponible';

  @override
  String get settingsResetSettings => 'Réinitialiser les paramètres';

  @override
  String get settingsResetSettingsSubtitle =>
      'Rétablir les paramètres d\'origine (contenu conservé)';

  @override
  String get settingsResetDialogTitle => 'Réinitialiser les paramètres ?';

  @override
  String get settingsResetDialogBody =>
      'Rétablir tous les paramètres par défaut ? Vos signets, notes et surlignages ne seront pas touchés.';

  @override
  String get settingsResetDone => 'Paramètres réinitialisés.';

  @override
  String get settingsReset => 'Réinitialiser';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsUnknown => 'Inconnu';

  @override
  String get settingsStorage => 'Stockage et téléchargements';

  @override
  String get settingsStorageSubtitle =>
      'Cache, traductions téléchargées et espace libérable';

  @override
  String get settingsSendFeedback => 'Envoyer un avis';

  @override
  String get settingsCrashReports => 'Envoyer les rapports de plantage';

  @override
  String get settingsCrashReportsSubtitle =>
      'Des détails anonymes aident à corriger les bugs. Aucune lecture biblique, note ou donnée personnelle n\'est incluse.';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsCredits => 'Crédits et sources';

  @override
  String get settingsCreditsSubtitle =>
      'Traductions bibliques, commentaires, données d\'étude, polices et licences';

  @override
  String get settingsSetSunsetLocation => 'Lieu pour le coucher du soleil';

  @override
  String get settingsCurrentLocationGps => 'Position actuelle (GPS)';

  @override
  String get settingsUseMyLocation => 'Utiliser ma position';

  @override
  String get settingsOrSelectCity => 'OU choisissez une grande ville';

  @override
  String get settingsTypography => 'Typographie';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsSearchSettings => 'Paramètres de recherche';

  @override
  String get settingsMatchTypeHeader => 'CORRESPONDANCE';

  @override
  String get settingsExactMatch => 'Correspondance exacte';

  @override
  String get settingsExactMatchSubtitle => 'Uniquement la phrase exacte';

  @override
  String get settingsScopeHeader => 'PORTÉE';

  @override
  String get settingsDisabledBookFilter => 'Désactivé (filtre de livre actif)';

  @override
  String get settingsMyNotes => 'Mes notes';

  @override
  String get settingsBehaviorHeader => 'COMPORTEMENT';

  @override
  String get settingsAutoOpenSingleShort => 'Ouvrir un résultat unique';

  @override
  String get settingsAutoOpenSingleShortSubtitle =>
      'Y aller directement s\'il n\'y a qu\'un résultat';

  @override
  String get settingsBackgroundGlow => 'Activer la lueur de fond';

  @override
  String get settingsBackgroundGlowSubtitle =>
      'Une douce lumière animée derrière le texte';

  @override
  String get settingsThemeGroupFoundations => 'FONDEMENTS';

  @override
  String get settingsThemeDawn => 'Aube';

  @override
  String get settingsThemeFresh => 'Frais';

  @override
  String get settingsThemeGroupFirmament => 'FIRMAMENT';

  @override
  String get settingsThemeSun => 'Soleil';

  @override
  String get settingsThemeMoon => 'Lune';

  @override
  String get settingsThemeStars => 'Étoiles';

  @override
  String get settingsThemeGroupEden => 'ÉDEN';

  @override
  String get settingsThemeLilies => 'Lys';

  @override
  String get settingsThemeRoses => 'Roses';

  @override
  String get settingsThemeOlives => 'Oliviers';

  @override
  String get settingsThemeGroupSanctuary => 'SANCTUAIRE';

  @override
  String get settingsThemePurple => 'Pourpre\nsacerdotal';

  @override
  String get settingsThemeBlue => 'Bleu\nGalilée';

  @override
  String get settingsThemeRed => 'Rouge\nécarlate';

  @override
  String get settingsSurpriseMe => 'Surprenez-moi';

  @override
  String get settingsThemeOledDark => 'OLED\nsombre';

  @override
  String get settingsThemeDuskOled => 'Crépuscule\nOLED';

  @override
  String get settingsSurfaceStyle => 'Style de surface';

  @override
  String get settingsSurfaceStyleSubtitle =>
      'Profondeur visuelle et rendu des matières';

  @override
  String get settingsSurfaceEarth => 'Terre';

  @override
  String get settingsSurfaceEarthSubtitle => 'Surface plane';

  @override
  String get settingsSurfaceHeaven => 'Ciel';

  @override
  String get settingsSurfaceHeavenSubtitle => 'Profondeur givrée';

  @override
  String get settingsSurfacePaper => 'Papier';

  @override
  String get settingsSurfacePaperSubtitle => 'Liseuse chaleureuse';

  @override
  String get settingsSurfaceClay => 'Argile';

  @override
  String get settingsSurfaceClaySubtitle => 'Relief moelleux';

  @override
  String get settingsWidgetsLivePreview =>
      'Aperçu en direct et personnalisation';

  @override
  String get settingsWidgetPreviewHeader => 'APERÇU DU WIDGET';

  @override
  String get settingsWidgetStreak => 'Série en cours ! • Objectif du jour';

  @override
  String get settingsWidgetWotd => 'MOT DU JOUR';

  @override
  String get settingsWidgetVotd => 'VERSET DU JOUR';

  @override
  String get settingsWidgetBackgroundHeader => 'FOND ET DÉGRADÉS';

  @override
  String get settingsWidgetContrastHeader => 'CONTRASTE DU TEXTE';

  @override
  String get settingsWidgetTextAuto => 'Auto ✨';

  @override
  String get settingsWidgetTextDark => 'Texte sombre ☀️';

  @override
  String get settingsWidgetTextWhite => 'Texte blanc 🌙';

  @override
  String get settingsWidgetSynced =>
      'Widgets synchronisés avec le nouveau style ! ✨';

  @override
  String get settingsWidgetApply => 'Appliquer à l\'écran d\'accueil';

  @override
  String get settingsFontSizeHeader => 'TAILLE';

  @override
  String get settingsFontWeightHeader => 'GRAISSE';

  @override
  String get settingsWeightLight => 'Fin';

  @override
  String get settingsWeightRegular => 'Normal';

  @override
  String get settingsWeightMedium => 'Moyen';

  @override
  String get settingsWeightBold => 'Gras';

  @override
  String get settingsLineSpacingHeader => 'INTERLIGNE';

  @override
  String get settingsSpacingCompact => 'Compact';

  @override
  String get settingsSpacingNormal => 'Normal';

  @override
  String get settingsMarginsHeader => 'MARGES';

  @override
  String get settingsAlignmentHeader => 'ALIGNEMENT';

  @override
  String get settingsAlignLeft => 'Gauche';

  @override
  String get settingsAlignCenter => 'Centré';

  @override
  String get settingsAlignRight => 'Droite';

  @override
  String get settingsAlignJustified => 'Justifié';

  @override
  String get settingsFontFamilyHeader => 'POLICE';

  @override
  String get settingsItalicHeader => 'TEXTE EN ITALIQUE';

  @override
  String get settingsDailyReading => 'Lecture quotidienne';

  @override
  String get settingsCustomReminder => 'Rappel personnalisé';

  @override
  String get settingsMonday => 'Lundi';

  @override
  String get settingsTuesday => 'Mardi';

  @override
  String get settingsWednesday => 'Mercredi';

  @override
  String get settingsThursday => 'Jeudi';

  @override
  String get settingsFriday => 'Vendredi';

  @override
  String get settingsSaturday => 'Samedi';

  @override
  String get settingsSunday => 'Dimanche';

  @override
  String settingsStrongsPackRequired(String size) {
    return 'Nécessite le pack « KJV with Strong\'s » ($size à télécharger).';
  }

  @override
  String settingsBbeNoteBody(int count) {
    return 'La Bible in Basic English a laissé certains versets non traduits ou très abrégés. Pour ceux-ci ($count versets), le texte de la World English Bible (WEB) est affiché à la place, avec un badge WEB.';
  }

  @override
  String settingsDayAtTime(String day, String time) {
    return '$day à $time';
  }

  @override
  String get spaceTitle => 'Votre espace';

  @override
  String get spaceTabHighlights => 'Surlignages';

  @override
  String get spaceTabBookmarks => 'Signets';

  @override
  String get spaceTabNotes => 'Notes';

  @override
  String get spaceTabJournal => 'Journal';

  @override
  String get spaceHighlighted => 'Surligné';

  @override
  String get spaceNewFolder => 'Nouveau dossier';

  @override
  String get spaceFolderNameHint => 'Nom du dossier';

  @override
  String get spaceCreate => 'Créer';

  @override
  String get spaceRenameFolder => 'Renommer le dossier';

  @override
  String get spaceRename => 'Renommer';

  @override
  String get spaceDeleteFolderTitle => 'Supprimer le dossier ?';

  @override
  String spaceDeleteFolderBody(String folderName) {
    return 'Voulez-vous vraiment supprimer « $folderName » ?\n\nVos signets dans ce dossier ne seront PAS supprimés ; ils seront déplacés vers Non classés.';
  }

  @override
  String get spaceMoveToFolder => 'Déplacer vers un dossier';

  @override
  String get spaceUnfiled => 'Non classés';

  @override
  String get spaceGroupEarlier => 'Plus ancien';

  @override
  String get spaceGroupLast7Days => '7 derniers jours';

  @override
  String get spaceGroupLast30Days => '30 derniers jours';

  @override
  String get spaceUnknownBook => 'Livre inconnu';

  @override
  String get spaceNoBookmarks => 'Aucun signet ici.';

  @override
  String get spaceFilterAll => 'Tous';

  @override
  String get spaceByDate => 'Par date';

  @override
  String get spaceByBook => 'Par livre';

  @override
  String get spaceYourNotes => 'Vos notes.';

  @override
  String get spaceNoNotesTapPlus =>
      'Aucune note.\nAppuyez sur + pour en créer une.';

  @override
  String get spaceMore => 'Plus';

  @override
  String get spaceNote => 'Note';

  @override
  String get spaceCopyText => 'Copier le texte';

  @override
  String get spaceDeleteNoteTitle => 'Supprimer la note ?';

  @override
  String spaceDeleteNoteBody(String title) {
    return '« $title » sera supprimée définitivement.';
  }

  @override
  String get spaceUntitled => 'Sans titre';

  @override
  String get spaceBookmarkedVerse => 'Verset en signet';

  @override
  String get spaceHighlightedVerse => 'Verset surligné';

  @override
  String get spaceOpenInRead => 'Ouvrir dans Lecture';

  @override
  String get spaceAddNote => 'Ajouter une note';

  @override
  String get spaceCopyVerse => 'Copier le verset';

  @override
  String get spaceShareVerse => 'Partager le verset';

  @override
  String get spaceChangeColour => 'Changer la couleur';

  @override
  String get spaceMoveToFolderAction => 'Déplacer vers un dossier';

  @override
  String get spaceRemoveBookmark => 'Retirer le signet';

  @override
  String get spaceRemoveHighlight => 'Retirer le surlignage';

  @override
  String get spaceHighlightColour => 'Couleur de surlignage';

  @override
  String spaceColourN(int index) {
    return 'Couleur $index';
  }

  @override
  String get notesMyNotes => 'Mes notes';

  @override
  String get notesEmptyTitle => 'Aucune note';

  @override
  String get notesEmptyBody =>
      'Appuyez sur + pour ajouter votre première note.';

  @override
  String get notesVerseInserted => 'Verset inséré';

  @override
  String get notesAddCommentary => 'Ajouter un commentaire';

  @override
  String get notesChapterTitlePlaceholder => 'Titre du chapitre';

  @override
  String get notesEditNote => 'Modifier la note';

  @override
  String notesNewNoteOn(String reference) {
    return 'Nouvelle note sur $reference';
  }

  @override
  String get notesNewNote => 'Nouvelle note';

  @override
  String get notesTitleHint => 'Titre de la note';

  @override
  String get notesContentHint =>
      'Commencez à écrire… (tapez / pour les commandes)';

  @override
  String get notesInsertVerse => 'Insérer un verset';

  @override
  String get notesInsertDate => 'Insérer la date';

  @override
  String get notesInsertChapterTitle => 'Insérer le titre du chapitre';

  @override
  String get notesSaved => 'Note enregistrée !';

  @override
  String get notesSaveChanges => 'Enregistrer';

  @override
  String get notesSaveNote => 'Enregistrer la note';

  @override
  String get notesDeleted => 'Note supprimée';

  @override
  String get notesDeleteNote => 'Supprimer la note';

  @override
  String get notesNewJournalEntry => 'Nouvelle entrée de journal';

  @override
  String get notesJournalHint =>
      'Comment vous sentez-vous aujourd\'hui ? Ouvrez votre cœur…';

  @override
  String get notesSaveAndAnalyze => 'Enregistrer et analyser';

  @override
  String get notesNoJournalEntries => 'Aucune entrée de journal.';

  @override
  String get notesWriteEntry => 'Écrire';

  @override
  String get notesAiReflection => 'Réflexion IA';

  @override
  String notesDetectedEmotion(String emotion) {
    return 'Émotion détectée : $emotion';
  }

  @override
  String notesVersesList(String verses) {
    return 'Versets : $verses';
  }

  @override
  String get accountGuest => 'Invité';

  @override
  String get accountSignInToSync =>
      'Connectez-vous pour synchroniser vos appareils';

  @override
  String get accountAccount => 'Compte';

  @override
  String get accountSettings => 'Paramètres';

  @override
  String get accountBackUp => 'Sauvegarder';

  @override
  String get accountBackUpSubtitle =>
      'Exporter notes, surlignages et paramètres';

  @override
  String get accountRestore => 'Restaurer';

  @override
  String get accountRestoreSubtitle => 'Importer depuis une sauvegarde';

  @override
  String get accountSignInGoogle => 'Se connecter avec Google';

  @override
  String get accountSignInApple => 'Se connecter avec Apple';

  @override
  String get accountSignOut => 'Se déconnecter';

  @override
  String get accountResetApp => 'Réinitialiser';

  @override
  String get accountResetAppSubtitle => 'Effacer les données de l\'appareil';

  @override
  String get accountSignIn => 'Se connecter';

  @override
  String get accountSignedIn => 'Connecté';

  @override
  String get accountDeleteAccount => 'Supprimer le compte';

  @override
  String get accountDeleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get accountDeleteAccountBody =>
      'Cette action est définitive et irréversible.\n\nSeront entièrement supprimés :\n• Votre compte de connexion\n• Ses données cloud dans The Blessed Bible et Blessed Arcade (compte partagé)\n• Toutes les données d\'étude sur l\'appareil (signets, surlignages, historique)';

  @override
  String get accountDeleted => 'Compte supprimé.';

  @override
  String accountReauthFailed(String reason) {
    return 'Impossible de confirmer votre identité ; rien n\'a été supprimé. $reason';
  }

  @override
  String get accountDeleteFailed =>
      'Échec de la suppression du compte. Réessayez.';

  @override
  String get accountOtherDataTitle =>
      'Cet appareil contient les données d\'un autre compte';

  @override
  String get accountOtherDataBody =>
      'Les signets, surlignages et notes de cet appareil proviennent d\'un autre compte. Que faut-il en faire ?';

  @override
  String get accountStartFresh => 'Repartir de zéro ici';

  @override
  String get accountMerge => 'Fusionner avec ce compte';

  @override
  String get accountSignOutTitle => 'Se déconnecter ?';

  @override
  String get accountSignOutBody =>
      'Vos signets, surlignages et notes restent en sécurité dans votre compte. Garder une copie sur cet appareil ?';

  @override
  String get accountRemoveFromDevice => 'Retirer de l\'appareil';

  @override
  String get accountKeepOnDevice => 'Garder sur l\'appareil';

  @override
  String get accountSyncing => 'Synchronisation…';

  @override
  String get accountSyncFailed => 'Échec de la synchro';

  @override
  String get accountTapToRetry => 'Appuyez pour réessayer';

  @override
  String get accountSyncPaused => 'Synchro en pause';

  @override
  String get accountSyncChoose =>
      'Choisissez quoi faire des données de cet appareil';

  @override
  String get accountSyncNow => 'Synchroniser';

  @override
  String get accountNotSyncedYet => 'Jamais synchronisé';

  @override
  String get accountSyncedJustNow => 'Synchronisé à l\'instant';

  @override
  String accountSyncedMinAgo(int minutes) {
    return 'Synchronisé il y a $minutes min';
  }

  @override
  String accountSyncedHoursAgo(int hours) {
    return 'Synchronisé il y a $hours h';
  }

  @override
  String accountSyncedOn(int day, int month, int year) {
    return 'Synchronisé le $day/$month/$year';
  }

  @override
  String get accountRestoreTitle => 'Restaurer une sauvegarde';

  @override
  String get accountRestoreHint => 'Collez ici le JSON de sauvegarde…';

  @override
  String get accountRestoreAction => 'Restaurer';

  @override
  String get accountResetTitle => 'Réinitialiser l\'app ?';

  @override
  String get accountResetBody =>
      'Cela efface toutes les données de l\'appareil :\n• Signets, surlignages, notes et journal\n• Plans de lecture, progression et plans perso\n• Traductions téléchargées et séries\n\nLes paramètres, le thème et la Bible hors ligne sont conservés. Action irréversible — sauvegardez d\'abord si besoin.';

  @override
  String get accountResetDone => 'Données réinitialisées. Nouveau départ !';

  @override
  String get accountReset => 'Réinitialiser';

  @override
  String get shareBackdrop => 'Arrière-plan';

  @override
  String get shareBackdropDawn => 'Aube';

  @override
  String get shareBackdropDusk => 'Crépuscule';

  @override
  String get shareBackdropArtwork => 'Illustration';

  @override
  String get shareBackdropGradient => 'Dégradé';

  @override
  String get shareFont => 'Police';

  @override
  String get shareFontTheme => 'Thème';

  @override
  String get shareSize => 'Taille';

  @override
  String get shareSpacing => 'Espacement';

  @override
  String get shareSpacingNormal => 'Normal';

  @override
  String shareSpacingWide(String value) {
    return 'Large $value';
  }

  @override
  String get shareLineHeight => 'Interligne';

  @override
  String get shareAlignment => 'Alignement';

  @override
  String get shareAlignCenter => 'Centré';

  @override
  String get shareAlignLeft => 'Gauche';

  @override
  String get sharePreparing => 'Préparation…';

  @override
  String get shareImage => 'Partager l\'image';

  @override
  String get shareText => 'Partager le texte';

  @override
  String get shareImageCard => 'Partager une carte image';

  @override
  String get spaceStorageTitle => 'Stockage';

  @override
  String get spaceClearCacheTitle => 'Vider le cache ?';

  @override
  String get spaceClearCacheBody =>
      'Supprime les fichiers temporaires (cartes de partage, miniatures). Vos notes, signets, surlignages et téléchargements sont conservés.';

  @override
  String get spaceClearCache => 'Vider le cache';

  @override
  String get spaceCacheCleared => 'Cache vidé';

  @override
  String spaceDeletePackTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String spaceDeletePackBundled(String size) {
    return 'Libère $size. Vous pourrez la restaurer hors ligne à tout moment.';
  }

  @override
  String spaceDeletePackDownloaded(String size) {
    return 'Libère $size. Vous pourrez la retélécharger plus tard.';
  }

  @override
  String spacePackDeleted(String abbr) {
    return '$abbr supprimée';
  }

  @override
  String spacePackDownloaded(String abbr) {
    return '$abbr téléchargée';
  }

  @override
  String spaceCouldNotFinish(String error) {
    return 'Échec : $error';
  }

  @override
  String spaceFreed(String message, String size) {
    return '$message · $size libérés';
  }

  @override
  String get spaceOnThisDevice => 'Sur cet appareil';

  @override
  String get spaceBibleContent => 'Contenu biblique (toujours conservé)';

  @override
  String get spaceDownloadedPacks => 'Packs téléchargés';

  @override
  String get spaceCache => 'Cache';

  @override
  String get spaceCacheExplain =>
      'Fichiers temporaires uniquement — cartes de partage et miniatures. Peut être vidé à tout moment.';

  @override
  String get spaceTranslationsDownloads => 'Traductions et téléchargements';

  @override
  String get spaceBundledSuffix => ' · intégrée';

  @override
  String get spaceCoreNotRemovable =>
      'Les versions KJV et BBE font partie de l\'app et ne peuvent pas être supprimées.';

  @override
  String get spaceGet => 'Obtenir';

  @override
  String spaceDeletePackTooltip(String name) {
    return 'Supprimer $name';
  }

  @override
  String studyCouldNotOpenScreen(String error) {
    return 'Impossible d\'ouvrir cet écran. $error';
  }

  @override
  String get studyCardSize => 'Taille de la carte';

  @override
  String get studyPosition => 'Position';

  @override
  String get studySizeLarge => 'Grande';

  @override
  String get studySizeLargeHint => 'Pleine largeur, même taille que le reste';

  @override
  String get studySizeExtraLarge => 'Très grande';

  @override
  String get studySizeExtraLargeHint => 'Pleine largeur, contenu plus aéré';

  @override
  String get studySizeHalf => 'Moitié';

  @override
  String get studySizeHalfHint => 'Compacte, deux par ligne';

  @override
  String get studyMoveUp => 'Monter';

  @override
  String get studyMoveUpHint => 'Échanger avec la carte du dessus';

  @override
  String get studyMoveDown => 'Descendre';

  @override
  String get studyMoveDownHint => 'Échanger avec la carte du dessous';

  @override
  String get studyCommentaryEyebrow => 'Commentaire';

  @override
  String get studyCommentaryTitle => 'Éclairage verset par verset';

  @override
  String get studyCommentarySnippet =>
      'Commentaire historiciste, filtrable par chapitre et verset.';

  @override
  String get studyCommentaryCta => 'Ouvrir le commentaire';

  @override
  String get studyDictionaryEyebrow => 'Dictionnaire';

  @override
  String get studyDictionaryTitle => 'Mots définis';

  @override
  String get studyDictionarySnippet =>
      'Easton et Smith, hors ligne, avec mots enregistrés.';

  @override
  String get studyDictionaryCta => 'Rechercher';

  @override
  String get studyStoriesEyebrow => 'Histoires bibliques';

  @override
  String get studyStoriesTitle => 'Récits racontés';

  @override
  String get studyStoriesSnippet => '66 histoires à travers chaque livre.';

  @override
  String get studyStoriesCta => 'Lire les histoires';

  @override
  String get studyConcordanceEyebrow => 'Concordance';

  @override
  String get studyConcordanceTitle => 'Chaque occurrence';

  @override
  String get studyConcordanceSnippet =>
      'Trouvez chaque verset où un mot apparaît.';

  @override
  String get studyConcordanceCta => 'Rechercher des mots';

  @override
  String get studySpaceSaved => 'Enregistrés';

  @override
  String get studySpaceMarked => 'Surlignés';

  @override
  String get studySpaceNotes => 'Notes';

  @override
  String get studySpaceJournal => 'Journal';

  @override
  String get studySpaceTitle => 'Votre espace';

  @override
  String get studySpaceSubtitle => 'Signets, surlignages, notes et journal';

  @override
  String get studyReadingPlan => 'Plan de lecture';

  @override
  String get studyStartReadingPlan => 'Commencer un plan de lecture';

  @override
  String get studyActivePlan => 'Plan en cours';

  @override
  String studyDayOfTotal(int current, int total) {
    return 'Jour $current sur $total';
  }

  @override
  String studyDaysBehind(int count) {
    return '$count en retard';
  }

  @override
  String get studyPlans => 'Plans';

  @override
  String get studyGuidedReading => 'Lecture guidée';

  @override
  String get studyGuidedReadingSubtitle =>
      'Sélectionnés, rythmés et personnalisés';

  @override
  String get studyReadyToBegin => 'Prêt à commencer';

  @override
  String studyTodayLabel(String label) {
    return 'Aujourd\'hui : $label';
  }

  @override
  String get studyReview => 'Revoir';

  @override
  String get studyRead => 'Lire';

  @override
  String studyCtaArrow(String cta) {
    return '$cta →';
  }

  @override
  String get studyWordOfTheDay => 'Mot du jour';

  @override
  String get studyArchiveLink => 'Archives →';

  @override
  String get studyLoading => 'Chargement…';

  @override
  String get studyUnavailableNow => 'Indisponible pour le moment';

  @override
  String get studyReadingStreak => 'Série de lecture';

  @override
  String get studyStartStreak => 'Lancez votre série';

  @override
  String studyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get studyStreakGrow => 'Revenez chaque jour pour la prolonger.';

  @override
  String get studyStreakStart => 'Faites une lecture chaque jour.';

  @override
  String get studyViewProgress => 'Voir la progression →';

  @override
  String get studyPassageNotFound => 'Passage introuvable';

  @override
  String get studyPassageLoadError => 'Impossible de charger le passage.';

  @override
  String get studyCompletedCheck => '✓ Terminé';

  @override
  String get studyMarkAsRead => 'Marquer comme lu';

  @override
  String get studyNextPassage => 'Passage suivant';

  @override
  String get studyFullChapter => 'Chapitre entier';

  @override
  String studyPassageOfTotal(int current, int total) {
    return 'Passage $current sur $total';
  }

  @override
  String studySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get studyHighlight => 'Surligner';

  @override
  String get studyBookmark => 'Signet';

  @override
  String get studyAddNote => 'Ajouter une note';

  @override
  String studyChaptersWithContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapitres commentés',
      one: '1 chapitre commenté',
    );
    return '$_temp0';
  }

  @override
  String get studyCommentaryLibrary => 'Bibliothèque de commentaires';

  @override
  String get studyCommentaryLoadError =>
      'Impossible de charger le commentaire.';

  @override
  String get studyNoCommentaryYet =>
      'Aucun commentaire disponible pour l\'instant.';

  @override
  String studyNoBooksMatch(String query) {
    return 'Aucun livre ne correspond à « $query ».';
  }

  @override
  String studySearchBooksCount(int count) {
    return 'Rechercher parmi $count livres…';
  }

  @override
  String get studyClassicSources => 'Sources classiques';

  @override
  String studyBookAuthorChapters(String author, int count) {
    return '$author · $count chap.';
  }

  @override
  String studyReadingRef(String reference) {
    return 'Lecture · $reference';
  }

  @override
  String get studyAllSources => 'Toutes les sources';

  @override
  String get studyVerseLevel => 'Par verset';

  @override
  String studySearchWithin(String reference) {
    return 'Rechercher dans $reference…';
  }

  @override
  String studyEntriesLoadError(String error) {
    return 'Impossible de charger les entrées.\n$error';
  }

  @override
  String get studyNoEntriesMatch =>
      'Aucune entrée ne correspond à ces filtres.\nEssayez Toutes les sources ou parcourez la bibliothèque.';

  @override
  String studyVerseN(int verse) {
    return 'Verset $verse';
  }

  @override
  String get studyChapter => 'Chapitre';

  @override
  String get studyCategoryCommentary => 'Commentaire';

  @override
  String get studyCategoryDevotional => 'Méditation';

  @override
  String get studyCategoryStudyNote => 'Note d\'étude';

  @override
  String studyCommentaryLoadErrorDetail(String error) {
    return 'Impossible de charger le commentaire.\n$error';
  }

  @override
  String get studyNoContentForFilters => 'Aucun contenu pour ces filtres.';

  @override
  String studyVerseLabel(String verse) {
    return 'Verset $verse';
  }

  @override
  String get studyChapterView => 'Vue du chapitre';

  @override
  String get studyFilterAll => 'Tout';

  @override
  String get studyFilterDevotionals => 'Méditations';

  @override
  String get studyFilterAllContexts => 'Tous les contextes';

  @override
  String get studyFilterChapterLevel => 'Par chapitre';

  @override
  String get studyFilterVerseLevel => 'Par verset';

  @override
  String get studyRemoveBookmark => 'Retirer le signet';

  @override
  String get studyBookmarkCommentary => 'Ajouter un signet';

  @override
  String get studyExpandFullScreen => 'Plein écran';

  @override
  String get studyTapToReadInContext => 'Touchez pour lire dans le contexte';

  @override
  String get studyOnThisChapter => 'Sur ce chapitre';

  @override
  String get studyOnThisBook => 'Sur ce livre';

  @override
  String get studyNoCommentaryTitle => 'Pas encore de commentaire';

  @override
  String get studyNoCommentaryBody =>
      'Aucun commentaire précis pour ce passage. Explorez les commentaires du chapitre ou du livre ci-dessous.';

  @override
  String get storiesTitle => 'Histoires bibliques';

  @override
  String get storiesFilters => 'Filtres';

  @override
  String get storiesSubtitle =>
      '500 moments illustrés de la Genèse à l\'Apocalypse';

  @override
  String get storiesSearchHint => 'Titre, livre ou référence…';

  @override
  String get storiesClearSearch => 'Effacer la recherche';

  @override
  String get storiesFilterAll => 'Tout';

  @override
  String get storiesFilterOt => 'AT';

  @override
  String get storiesFilterNt => 'NT';

  @override
  String storiesCountOfTotal(int count, int total) {
    return '$count histoires sur $total';
  }

  @override
  String get storiesFavorites => 'Favoris';

  @override
  String get storiesUnread => 'Non lues';

  @override
  String storiesLoadError(String error) {
    return 'Impossible de charger les histoires :\n$error';
  }

  @override
  String get storiesBooks => 'Livres';

  @override
  String get storiesSearchBooks => 'Rechercher un livre…';

  @override
  String get storiesAllBooks => 'Tous les livres';

  @override
  String get storiesNoMatch => 'Aucune histoire ne correspond à ces filtres.';

  @override
  String get storiesNoFavorites => 'Aucun favori pour l\'instant.';

  @override
  String get storiesBrowseAll => 'Parcourir toutes les histoires';

  @override
  String get storiesAllCaughtUp => 'Vous avez tout lu.';

  @override
  String get storiesShowRead => 'Afficher les histoires lues';

  @override
  String get storiesClearFilters => 'Effacer les filtres';

  @override
  String get storiesFavoritesHint =>
      'Touchez ♥ sur une histoire pour l\'enregistrer ici.';

  @override
  String get storiesAttribution =>
      'Écritures tirées de la King James Version (domaine public). Résumés adaptés de The Graham Bible (grahambible.com), assistés par IA et relus par des humains. Illustrations : Gustave Doré (1832–1883), domaine public, via Wikimedia Commons.';

  @override
  String get storiesReachedEnd => 'Vous êtes arrivé à la fin.';

  @override
  String get storiesFirstStory => 'C\'est la première histoire.';

  @override
  String get storiesFavorite => 'Favori';

  @override
  String get storiesMarkAsRead => 'Marquer comme lu';

  @override
  String storiesKeyVerse(String reference) {
    return 'VERSET CLÉ · $reference';
  }

  @override
  String get storiesTheStory => 'LE RÉCIT';

  @override
  String storiesArtworkCaption(String caption) {
    return 'Illustration : $caption — Gustave Doré, domaine public';
  }

  @override
  String get storiesPrevious => 'Histoire précédente';

  @override
  String get storiesNext => 'Histoire suivante';

  @override
  String get studyDictionarySearchHint => 'Rechercher parmi 3 400+ mots…';

  @override
  String get studyDictionarySavedFilter => '★ Enregistrés';

  @override
  String studyDictionaryUnavailable(String error) {
    return 'Dictionnaire indisponible.\n$error';
  }

  @override
  String get studyNoHeadwords => 'Aucune entrée trouvée.';

  @override
  String get studyDictionaryNoMatches =>
      'Aucun résultat. Essayez « grace », « atonement » ou « wilderness » (dictionnaire en anglais).';

  @override
  String studyResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
    );
    return '$_temp0';
  }

  @override
  String get studyUntitledEntry => '(entrée sans titre)';

  @override
  String get studyRemoveSavedWord => 'Retirer le mot enregistré';

  @override
  String get studySaveWord => 'Enregistrer le mot';

  @override
  String get studyNoDefinition => 'Aucune définition trouvée.';

  @override
  String studyFailedToLoad(String error) {
    return 'Échec du chargement : $error';
  }

  @override
  String studyStrongsShareText(String id, String lemma, String transliteration,
      String pronunciation, String definition) {
    return '$id - $lemma\n\nTranslittération : $transliteration\nPrononciation : $pronunciation\n\nDéfinition :\n$definition';
  }

  @override
  String studyNoStrongsEntry(String id) {
    return 'Aucune entrée pour $id.';
  }

  @override
  String get studyStrongsLexicon => 'LEXIQUE DE STRONG';

  @override
  String get studyConcordanceHint => 'Mot anglais (ex. grace, covenant)…';

  @override
  String get studyConcordanceIntro =>
      'Occurrences dans la KJV — touchez un verset pour le lire dans son contexte.';

  @override
  String get studyConcordanceEmpty =>
      'Chaque verset contenant votre mot, dans l\'ordre canonique.';

  @override
  String get studyConcordanceSingleWord => 'Saisissez un seul mot anglais.';

  @override
  String studyConcordanceNoVerses(String word) {
    return 'Aucun verset ne contient « $word ».';
  }

  @override
  String studyConcordanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versets',
      one: '1 verset',
    );
    return '$_temp0';
  }

  @override
  String studyConcordanceCountTruncated(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versets',
      one: '1 verset',
    );
    return '$_temp0 ($limit premiers affichés)';
  }

  @override
  String get creditsTitle => 'Crédits et sources';

  @override
  String get creditsLicenses => 'Licences open source';

  @override
  String get creditsLicensesSubtitle => 'Polices et logiciels';

  @override
  String studyPreparingOfflineBible(int percent) {
    return 'Préparation de la Bible hors ligne… $percent %';
  }

  @override
  String get errorTitle => 'Un problème est survenu';

  @override
  String get errorBody =>
      'Un problème inattendu s\'est produit. Touchez ci-dessous pour revenir à l\'accueil.';

  @override
  String get errorBackHome => 'Retour à l\'accueil';

  @override
  String studyWeekN(int week) {
    return 'Semaine $week';
  }

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacyLoadError =>
      'Impossible de charger la politique de confidentialité.';

  @override
  String privacyEffectiveDate(String date) {
    return 'Date d\'entrée en vigueur : $date';
  }

  @override
  String get privacyEnglishOnly => 'Cette politique est fournie en anglais.';

  @override
  String get privacyViewOnline => 'Voir en ligne';
}
