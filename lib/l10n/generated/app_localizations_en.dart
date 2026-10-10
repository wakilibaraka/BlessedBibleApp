// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'The Blessed Bible';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonOk => 'OK';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonShare => 'Share';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSearch => 'Search';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Same as device';

  @override
  String get languageSubtitle =>
      'The language of menus and buttons. Your Bible translation is chosen separately.';

  @override
  String get onboardingTagline => 'Scripture, without distraction.';

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
  String get onboardingLookTitle => 'Make it comfortable';

  @override
  String get onboardingLookBody =>
      'Choose a page colour and text size. Everything can be fine-tuned later.';

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
  String get onboardingFeatureWordTitle => 'The Pure Word';

  @override
  String get onboardingFeatureWordBody =>
      'Read without distraction, with highlights, notes and bookmarks.';

  @override
  String get onboardingFeaturePlansTitle => 'Reading Plans';

  @override
  String get onboardingFeaturePlansBody =>
      'Chronological, thematic or your own — with gentle reminders.';

  @override
  String get onboardingFeatureStudyTitle => 'Deep Study';

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
}
