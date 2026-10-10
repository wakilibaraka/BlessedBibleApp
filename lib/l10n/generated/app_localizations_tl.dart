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
}
