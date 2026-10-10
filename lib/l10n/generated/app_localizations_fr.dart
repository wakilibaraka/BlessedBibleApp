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
}
