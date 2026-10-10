// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

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
  String get onboardingLookTitle => 'Leggi comodamente';

  @override
  String get onboardingLookBody =>
      'Scegli il colore della pagina e la dimensione del testo. Potrai regolare tutto in seguito.';

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
}
