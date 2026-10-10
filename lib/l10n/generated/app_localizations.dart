import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_tl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('ro'),
    Locale('sw'),
    Locale('tl')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'The Blessed Bible'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Same as device'**
  String get languageSystem;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The language of menus and buttons. Your Bible translation is chosen separately.'**
  String get languageSubtitle;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Scripture, without distraction.'**
  String get onboardingTagline;

  /// No description provided for @onboardingPickLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingPickLanguage;

  /// No description provided for @onboardingLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'You can change this any time in Settings.'**
  String get onboardingLanguageHint;

  /// No description provided for @onboardingBibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Bible'**
  String get onboardingBibleTitle;

  /// No description provided for @onboardingBibleBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the translation you read most. You can show a second one side by side.'**
  String get onboardingBibleBody;

  /// No description provided for @onboardingParallel.
  ///
  /// In en, this message translates to:
  /// **'Also show {name} alongside'**
  String onboardingParallel(String name);

  /// No description provided for @onboardingLookTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it comfortable'**
  String get onboardingLookTitle;

  /// No description provided for @onboardingLookBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a page colour and text size. Everything can be fine-tuned later.'**
  String get onboardingLookBody;

  /// No description provided for @onboardingThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get onboardingThemeLight;

  /// No description provided for @onboardingThemeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get onboardingThemeSepia;

  /// No description provided for @onboardingThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get onboardingThemeDark;

  /// No description provided for @onboardingTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get onboardingTextSize;

  /// No description provided for @onboardingPreviewVerse.
  ///
  /// In en, this message translates to:
  /// **'In the beginning was the Word, and the Word was with God, and the Word was God.'**
  String get onboardingPreviewVerse;

  /// No description provided for @onboardingPreviewRef.
  ///
  /// In en, this message translates to:
  /// **'John 1:1'**
  String get onboardingPreviewRef;

  /// No description provided for @onboardingFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything for your daily walk'**
  String get onboardingFeaturesTitle;

  /// No description provided for @onboardingFeatureWordTitle.
  ///
  /// In en, this message translates to:
  /// **'The Pure Word'**
  String get onboardingFeatureWordTitle;

  /// No description provided for @onboardingFeatureWordBody.
  ///
  /// In en, this message translates to:
  /// **'Read without distraction, with highlights, notes and bookmarks.'**
  String get onboardingFeatureWordBody;

  /// No description provided for @onboardingFeaturePlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Plans'**
  String get onboardingFeaturePlansTitle;

  /// No description provided for @onboardingFeaturePlansBody.
  ///
  /// In en, this message translates to:
  /// **'Chronological, thematic or your own — with gentle reminders.'**
  String get onboardingFeaturePlansBody;

  /// No description provided for @onboardingFeatureStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Study'**
  String get onboardingFeatureStudyTitle;

  /// No description provided for @onboardingFeatureStudyBody.
  ///
  /// In en, this message translates to:
  /// **'Commentary, dictionary, Strong\'s and maps, right beside the text.'**
  String get onboardingFeatureStudyBody;

  /// No description provided for @onboardingFeatureSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Kept safe'**
  String get onboardingFeatureSyncTitle;

  /// No description provided for @onboardingFeatureSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in any time to sync across your devices. No account needed to read.'**
  String get onboardingFeatureSyncBody;

  /// No description provided for @onboardingBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin reading'**
  String get onboardingBegin;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'fr',
        'it',
        'ro',
        'sw',
        'tl'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ro':
      return AppLocalizationsRo();
    case 'sw':
      return AppLocalizationsSw();
    case 'tl':
      return AppLocalizationsTl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
