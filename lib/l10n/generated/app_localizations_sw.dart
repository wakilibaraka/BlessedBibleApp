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
}
