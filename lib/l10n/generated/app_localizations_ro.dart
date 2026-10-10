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
}
