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

  /// No description provided for @plansContinueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get plansContinueReading;

  /// No description provided for @plansResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get plansResume;

  /// No description provided for @plansDayCompleteCelebration.
  ///
  /// In en, this message translates to:
  /// **'Reading Plan\nDay {day} Complete!'**
  String plansDayCompleteCelebration(int day);

  /// No description provided for @plansChangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Change week'**
  String get plansChangeWeek;

  /// No description provided for @plansCalendarDayComplete.
  ///
  /// In en, this message translates to:
  /// **'{label}, reading complete'**
  String plansCalendarDayComplete(String label);

  /// No description provided for @plansCalendarDayToday.
  ///
  /// In en, this message translates to:
  /// **'{label}, today'**
  String plansCalendarDayToday(String label);

  /// No description provided for @plansDailyVerses.
  ///
  /// In en, this message translates to:
  /// **'Daily Verses'**
  String get plansDailyVerses;

  /// No description provided for @plansToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get plansToday;

  /// No description provided for @plansYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get plansYesterday;

  /// No description provided for @plansDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String plansDaysAgo(int count);

  /// No description provided for @plansHello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get plansHello;

  /// No description provided for @plansOpenStory.
  ///
  /// In en, this message translates to:
  /// **'Open story: {caption}'**
  String plansOpenStory(String caption);

  /// No description provided for @plansBibleStory.
  ///
  /// In en, this message translates to:
  /// **'Bible story'**
  String get plansBibleStory;

  /// No description provided for @plansSlotsFull.
  ///
  /// In en, this message translates to:
  /// **'All {count} plan slots are in use. Pause a plan to free a slot — progress is kept.'**
  String plansSlotsFull(int count);

  /// No description provided for @plansPausedSnack.
  ///
  /// In en, this message translates to:
  /// **'Plan paused — all progress is kept.'**
  String get plansPausedSnack;

  /// No description provided for @plansBrowseToStart.
  ///
  /// In en, this message translates to:
  /// **'Browse Reading to start your first plan.'**
  String get plansBrowseToStart;

  /// No description provided for @plansFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get plansFriend;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plansTitle;

  /// No description provided for @plansTabReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get plansTabReading;

  /// No description provided for @plansTabBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get plansTabBooks;

  /// No description provided for @plansTabMyPlans.
  ///
  /// In en, this message translates to:
  /// **'My Plans ({count})'**
  String plansTabMyPlans(int count);

  /// No description provided for @plansNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get plansNotStarted;

  /// No description provided for @plansPercentDone.
  ///
  /// In en, this message translates to:
  /// **'{percent}% done'**
  String plansPercentDone(int percent);

  /// No description provided for @plansOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get plansOpen;

  /// No description provided for @plansPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get plansPaused;

  /// No description provided for @plansStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get plansStarted;

  /// No description provided for @plansDaysBehind.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day behind} other{{count} days behind}}'**
  String plansDaysBehind(int count);

  /// No description provided for @plansCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'Caught up'**
  String get plansCaughtUp;

  /// No description provided for @plansComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get plansComplete;

  /// No description provided for @plansDayOfTotalLeft.
  ///
  /// In en, this message translates to:
  /// **'Day {current} of {total} · {left} left'**
  String plansDayOfTotalLeft(int current, int total, int left);

  /// No description provided for @plansPauseKeepsProgress.
  ///
  /// In en, this message translates to:
  /// **'Pause (keeps progress)'**
  String get plansPauseKeepsProgress;

  /// No description provided for @plansStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get plansStart;

  /// No description provided for @plansPresetBookTitle.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{book} in 1 day} other{{book} in {days} days}}'**
  String plansPresetBookTitle(String book, int days);

  /// No description provided for @plansPresetGospelsTitle.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Gospels in 1 day} other{Gospels in {days} days}}'**
  String plansPresetGospelsTitle(int days);

  /// No description provided for @plansPresetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day · tap to build} other{{days} days · tap to build}}'**
  String plansPresetSubtitle(int days);

  /// No description provided for @plansYourCustomPlans.
  ///
  /// In en, this message translates to:
  /// **'YOUR CUSTOM PLANS'**
  String get plansYourCustomPlans;

  /// No description provided for @plansDayOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String plansDayOfTotal(int day, int total);

  /// No description provided for @plansCustomPlan.
  ///
  /// In en, this message translates to:
  /// **'Custom plan'**
  String get plansCustomPlan;

  /// No description provided for @plansNoActivePlans.
  ///
  /// In en, this message translates to:
  /// **'No active plans'**
  String get plansNoActivePlans;

  /// No description provided for @plansNoActivePlansBody.
  ///
  /// In en, this message translates to:
  /// **'Browse Reading or Books to start your first plan.'**
  String get plansNoActivePlansBody;

  /// No description provided for @plansLetsRead.
  ///
  /// In en, this message translates to:
  /// **'Let\'s read'**
  String get plansLetsRead;

  /// No description provided for @plansVerseOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Verse of the day'**
  String get plansVerseOfTheDay;

  /// No description provided for @plansOpenTodaysReading.
  ///
  /// In en, this message translates to:
  /// **'Open today\'s reading'**
  String get plansOpenTodaysReading;

  /// No description provided for @plansLastDayOfYear.
  ///
  /// In en, this message translates to:
  /// **'Last day of the year'**
  String get plansLastDayOfYear;

  /// No description provided for @plansDaysLeftInYear.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left in the year} other{{count} days left in the year}}'**
  String plansDaysLeftInYear(int count);

  /// No description provided for @plansCustomPlanDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Plan'**
  String get plansCustomPlanDefaultTitle;

  /// No description provided for @plansCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get plansCustom;

  /// No description provided for @plansBookRange.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String plansBookRange(String start, String end);

  /// No description provided for @plansCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save plan: {error}'**
  String plansCouldNotSave(String error);

  /// No description provided for @plansBuilderTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Plan Builder'**
  String get plansBuilderTitle;

  /// No description provided for @plansError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String plansError(String error);

  /// No description provided for @plansPlanName.
  ///
  /// In en, this message translates to:
  /// **'Plan name'**
  String get plansPlanName;

  /// No description provided for @plansPlanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Genesis in 30 Days'**
  String get plansPlanNameHint;

  /// No description provided for @plansReadingTracks.
  ///
  /// In en, this message translates to:
  /// **'Reading tracks'**
  String get plansReadingTracks;

  /// No description provided for @plansAddTrack.
  ///
  /// In en, this message translates to:
  /// **'Add track'**
  String get plansAddTrack;

  /// No description provided for @plansTracksOverlap.
  ///
  /// In en, this message translates to:
  /// **'Tracks overlap — shared verses are counted once in the preview below.'**
  String get plansTracksOverlap;

  /// No description provided for @plansDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get plansDuration;

  /// No description provided for @plansDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String plansDays(int count);

  /// No description provided for @plansDaysSuffix.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get plansDaysSuffix;

  /// No description provided for @plansStartRestReminder.
  ///
  /// In en, this message translates to:
  /// **'Start, rest & reminder'**
  String get plansStartRestReminder;

  /// No description provided for @plansStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get plansStartDate;

  /// No description provided for @plansRestDaysNeutral.
  ///
  /// In en, this message translates to:
  /// **'Rest days (neutral)'**
  String get plansRestDaysNeutral;

  /// No description provided for @plansNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get plansNone;

  /// No description provided for @plansDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get plansDailyReminder;

  /// No description provided for @plansReminderAt.
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String plansReminderAt(String time);

  /// No description provided for @plansOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get plansOff;

  /// No description provided for @plansLivePreview.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get plansLivePreview;

  /// No description provided for @plansPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add at least one track above to preview the word-balanced schedule.'**
  String get plansPreviewEmpty;

  /// No description provided for @plansWordBalanced.
  ///
  /// In en, this message translates to:
  /// **'Word-balanced · pericope-aware'**
  String get plansWordBalanced;

  /// No description provided for @plansPreviewSummary.
  ///
  /// In en, this message translates to:
  /// **'{days} days · {readingDays} reading days'**
  String plansPreviewSummary(int days, int readingDays);

  /// No description provided for @plansClampedNotice.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{The gentlest pace for this selection is 1 day. Title updated to the real day count.} other{The gentlest pace for this selection is {days} days. Title updated to the real day count.}}'**
  String plansClampedNotice(int days);

  /// No description provided for @plansPreviewDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}: {portions}'**
  String plansPreviewDay(int day, String portions);

  /// No description provided for @plansMoreBalancedDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more balanced day} other{{count} more balanced days}}'**
  String plansMoreBalancedDays(int count);

  /// No description provided for @plansSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get plansSaving;

  /// No description provided for @plansGenerateAndSave.
  ///
  /// In en, this message translates to:
  /// **'Generate & save plan →'**
  String get plansGenerateAndSave;

  /// No description provided for @plansNameAndTrackHint.
  ///
  /// In en, this message translates to:
  /// **'Name the plan and add at least one track to continue.'**
  String get plansNameAndTrackHint;

  /// No description provided for @plansStartEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Start…'**
  String get plansStartEllipsis;

  /// No description provided for @plansEndEllipsis.
  ///
  /// In en, this message translates to:
  /// **'End…'**
  String get plansEndEllipsis;

  /// No description provided for @plansStartLabel.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get plansStartLabel;

  /// No description provided for @plansEndLabel.
  ///
  /// In en, this message translates to:
  /// **'END'**
  String get plansEndLabel;

  /// No description provided for @plansRemoveTrack.
  ///
  /// In en, this message translates to:
  /// **'Remove track'**
  String get plansRemoveTrack;

  /// No description provided for @plansRestChip.
  ///
  /// In en, this message translates to:
  /// **'Rest {days}'**
  String plansRestChip(String days);

  /// No description provided for @plansRebasedSnack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Schedule shifted by 1 reading day. Completed days untouched.} other{Schedule shifted by {count} reading days. Completed days untouched.}}'**
  String plansRebasedSnack(int count);

  /// No description provided for @plansPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plansPlan;

  /// No description provided for @plansNoReadingsYet.
  ///
  /// In en, this message translates to:
  /// **'This plan has no readings yet.'**
  String get plansNoReadingsYet;

  /// No description provided for @plansReadingDaysWeeks.
  ///
  /// In en, this message translates to:
  /// **'{days} reading days · ~{weeks} weeks'**
  String plansReadingDaysWeeks(int days, int weeks);

  /// No description provided for @plansBeginPlan.
  ///
  /// In en, this message translates to:
  /// **'Begin plan'**
  String get plansBeginPlan;

  /// No description provided for @plansStartDayOne.
  ///
  /// In en, this message translates to:
  /// **'Start Day 1 →'**
  String get plansStartDayOne;

  /// No description provided for @plansStartDateNote.
  ///
  /// In en, this message translates to:
  /// **'Your plan begins on the date you choose.'**
  String get plansStartDateNote;

  /// No description provided for @plansScheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULE'**
  String get plansScheduleLabel;

  /// No description provided for @plansNoReadings.
  ///
  /// In en, this message translates to:
  /// **'No readings'**
  String get plansNoReadings;

  /// No description provided for @plansPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String plansPercentComplete(int percent);

  /// No description provided for @plansFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get plansFlexible;

  /// No description provided for @plansScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get plansScheduled;

  /// No description provided for @plansBehindChip.
  ///
  /// In en, this message translates to:
  /// **'{count} behind'**
  String plansBehindChip(int count);

  /// No description provided for @plansOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get plansOnTrack;

  /// No description provided for @plansFlexibleHelp.
  ///
  /// In en, this message translates to:
  /// **'Flexible: read the oldest unread day first. Missed days don\'t add up.'**
  String get plansFlexibleHelp;

  /// No description provided for @plansScheduledHelp.
  ///
  /// In en, this message translates to:
  /// **'Scheduled: each date has its reading day. Missed days count as behind — catch up below.'**
  String get plansScheduledHelp;

  /// No description provided for @plansCatchUp.
  ///
  /// In en, this message translates to:
  /// **'Catch up'**
  String get plansCatchUp;

  /// No description provided for @plansBehindBy.
  ///
  /// In en, this message translates to:
  /// **'Behind by {count} — oldest unread is Day {day}.'**
  String plansBehindBy(int count, int day);

  /// No description provided for @plansCatchUpHelp.
  ///
  /// In en, this message translates to:
  /// **'Marking days done records progress. Shifting moves the rest of the schedule forward instead.'**
  String get plansCatchUpHelp;

  /// No description provided for @plansGoToOldest.
  ///
  /// In en, this message translates to:
  /// **'Go to oldest'**
  String get plansGoToOldest;

  /// No description provided for @plansMarkOldestDone.
  ///
  /// In en, this message translates to:
  /// **'Mark oldest done'**
  String get plansMarkOldestDone;

  /// No description provided for @plansAllPreviousDone.
  ///
  /// In en, this message translates to:
  /// **'Everything before today is already done.'**
  String get plansAllPreviousDone;

  /// No description provided for @plansPreviousMarked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 previous day marked as read.} other{{count} previous days marked as read.}}'**
  String plansPreviousMarked(int count);

  /// No description provided for @plansMarkAllPrevious.
  ///
  /// In en, this message translates to:
  /// **'Mark all previous done'**
  String get plansMarkAllPrevious;

  /// No description provided for @plansRebaseDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Shift +1 day} other{Shift +{count} days}}'**
  String plansRebaseDays(int count);

  /// No description provided for @plansReadingsHeader.
  ///
  /// In en, this message translates to:
  /// **'READINGS · {count} DAYS'**
  String plansReadingsHeader(int count);

  /// No description provided for @plansJourneyMap.
  ///
  /// In en, this message translates to:
  /// **'Journey map view'**
  String get plansJourneyMap;

  /// No description provided for @plansJumpToToday.
  ///
  /// In en, this message translates to:
  /// **'Jump to today'**
  String get plansJumpToToday;

  /// No description provided for @plansDayN.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String plansDayN(int day);

  /// No description provided for @plansLegendDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get plansLegendDone;

  /// No description provided for @plansLegendToday.
  ///
  /// In en, this message translates to:
  /// **'Today = ring'**
  String get plansLegendToday;

  /// No description provided for @plansLegendMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get plansLegendMissed;

  /// No description provided for @plansReminderAtTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder · {time}'**
  String plansReminderAtTime(String time);

  /// No description provided for @plansReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Reminder off'**
  String get plansReminderOff;

  /// No description provided for @plansReminderHelp.
  ///
  /// In en, this message translates to:
  /// **'Per-plan notification — skips rest days automatically.'**
  String get plansReminderHelp;

  /// No description provided for @plansRestDays.
  ///
  /// In en, this message translates to:
  /// **'Rest days'**
  String get plansRestDays;

  /// No description provided for @plansNoRestDays.
  ///
  /// In en, this message translates to:
  /// **'No rest days'**
  String get plansNoRestDays;

  /// No description provided for @plansSettings.
  ///
  /// In en, this message translates to:
  /// **'Plan settings'**
  String get plansSettings;

  /// No description provided for @plansAboutEllipsis.
  ///
  /// In en, this message translates to:
  /// **'About this plan…'**
  String get plansAboutEllipsis;

  /// No description provided for @plansAbout.
  ///
  /// In en, this message translates to:
  /// **'About this plan'**
  String get plansAbout;

  /// No description provided for @plansChangeStartDate.
  ///
  /// In en, this message translates to:
  /// **'Change start date…'**
  String get plansChangeStartDate;

  /// No description provided for @plansRestDaysValue.
  ///
  /// In en, this message translates to:
  /// **'Rest days: {days}'**
  String plansRestDaysValue(String days);

  /// No description provided for @plansRestDaysHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose any weekdays'**
  String get plansRestDaysHelp;

  /// No description provided for @plansRestartFromDayOne.
  ///
  /// In en, this message translates to:
  /// **'Restart from Day 1…'**
  String get plansRestartFromDayOne;

  /// No description provided for @plansRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart plan?'**
  String get plansRestartTitle;

  /// No description provided for @plansRestartBody.
  ///
  /// In en, this message translates to:
  /// **'Completed days will be cleared.'**
  String get plansRestartBody;

  /// No description provided for @plansRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get plansRestart;

  /// No description provided for @plansMarkUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark unread'**
  String get plansMarkUnread;

  /// No description provided for @plansMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get plansMarkRead;

  /// No description provided for @plansRestAndReflect.
  ///
  /// In en, this message translates to:
  /// **'Rest & reflect'**
  String get plansRestAndReflect;

  /// No description provided for @plansRestDayBody.
  ///
  /// In en, this message translates to:
  /// **'A day of rest — no reading assigned today.'**
  String get plansRestDayBody;

  /// No description provided for @plansDayDetailHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a passage to open it. Check each one off as you read.'**
  String get plansDayDetailHelp;

  /// No description provided for @plansMilestone.
  ///
  /// In en, this message translates to:
  /// **'{count} readings completed — keep going!'**
  String plansMilestone(int count);

  /// No description provided for @plansCompletedTapToUndo.
  ///
  /// In en, this message translates to:
  /// **'Completed — tap to undo'**
  String get plansCompletedTapToUndo;

  /// No description provided for @plansMarkDayRead.
  ///
  /// In en, this message translates to:
  /// **'Mark Day {day} as Read ✓ ({checked}/{total} passages)'**
  String plansMarkDayRead(int day, int checked, int total);

  /// No description provided for @todayGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get todayGoodMorning;

  /// No description provided for @todayGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get todayGoodAfternoon;

  /// No description provided for @todayGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get todayGoodEvening;

  /// No description provided for @todayGoodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get todayGoodNight;

  /// No description provided for @todayStreakNudge.
  ///
  /// In en, this message translates to:
  /// **'Read today to save your streak!'**
  String get todayStreakNudge;

  /// No description provided for @todayNotificationsSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon!'**
  String get todayNotificationsSoon;

  /// No description provided for @todaySectionResume.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get todaySectionResume;

  /// No description provided for @todaySectionStreak.
  ///
  /// In en, this message translates to:
  /// **'READING STREAK'**
  String get todaySectionStreak;

  /// No description provided for @todaySectionLatestNote.
  ///
  /// In en, this message translates to:
  /// **'LATEST NOTE'**
  String get todaySectionLatestNote;

  /// No description provided for @todaySectionQuickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get todaySectionQuickActions;

  /// No description provided for @todaySectionReminders.
  ///
  /// In en, this message translates to:
  /// **'DAILY REMINDERS'**
  String get todaySectionReminders;

  /// No description provided for @todayTagline.
  ///
  /// In en, this message translates to:
  /// **'Your daily moment of peace.'**
  String get todayTagline;

  /// No description provided for @todayNoNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get todayNoNotesYet;

  /// No description provided for @todayWriteFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Write your first note to see it here.'**
  String get todayWriteFirstNote;

  /// No description provided for @todayViewAllNotes.
  ///
  /// In en, this message translates to:
  /// **'View all notes'**
  String get todayViewAllNotes;

  /// No description provided for @todayStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day streak} other{{count} day streak}}'**
  String todayStreakDays(int count);

  /// No description provided for @todayDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day of the year remaining.} other{{count} days of the year remaining.}}'**
  String todayDaysRemaining(int count);

  /// No description provided for @todayActionRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get todayActionRead;

  /// No description provided for @todayActionSurprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise Me'**
  String get todayActionSurprise;

  /// No description provided for @todayActionReadingPlan.
  ///
  /// In en, this message translates to:
  /// **'Reading Plan'**
  String get todayActionReadingPlan;

  /// No description provided for @todayActionYourSpace.
  ///
  /// In en, this message translates to:
  /// **'Your Space'**
  String get todayActionYourSpace;

  /// No description provided for @todayVotdArchive.
  ///
  /// In en, this message translates to:
  /// **'Verse of the Day Archive'**
  String get todayVotdArchive;

  /// No description provided for @todayVotdArchiveBody.
  ///
  /// In en, this message translates to:
  /// **'Catch up on verses from days you missed.'**
  String get todayVotdArchiveBody;

  /// No description provided for @todayVotdArchiveExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore your past daily verses'**
  String get todayVotdArchiveExplore;

  /// No description provided for @readActionBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get readActionBookmark;

  /// No description provided for @readActionNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get readActionNote;

  /// No description provided for @readActionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get readActionNotes;

  /// No description provided for @readActionEditNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get readActionEditNote;

  /// No description provided for @readActionCommentary.
  ///
  /// In en, this message translates to:
  /// **'Commentary'**
  String get readActionCommentary;

  /// No description provided for @readActionRelated.
  ///
  /// In en, this message translates to:
  /// **'Related'**
  String get readActionRelated;

  /// No description provided for @readActionHighlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get readActionHighlight;

  /// No description provided for @readActionStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get readActionStudy;

  /// No description provided for @readActionSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get readActionSaved;

  /// No description provided for @readActionSelectText.
  ///
  /// In en, this message translates to:
  /// **'Select Text'**
  String get readActionSelectText;

  /// No description provided for @readVerseActions.
  ///
  /// In en, this message translates to:
  /// **'Verse actions'**
  String get readVerseActions;

  /// No description provided for @readVersesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 verse selected} other{{count} verses selected}} · {where}'**
  String readVersesSelected(int count, String where);

  /// No description provided for @readCommentaryHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the bulb icon next to a verse for commentary'**
  String get readCommentaryHint;

  /// No description provided for @readPassageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Passage not found.'**
  String get readPassageNotFound;

  /// No description provided for @readChapterCommentary.
  ///
  /// In en, this message translates to:
  /// **'Read commentary on this chapter'**
  String get readChapterCommentary;

  /// No description provided for @readPreviousChapter.
  ///
  /// In en, this message translates to:
  /// **'‹ Previous'**
  String get readPreviousChapter;

  /// No description provided for @readNextChapter.
  ///
  /// In en, this message translates to:
  /// **'Next ›'**
  String get readNextChapter;

  /// No description provided for @readPlanDay.
  ///
  /// In en, this message translates to:
  /// **'Reading Plan · Day {day}'**
  String readPlanDay(int day);

  /// No description provided for @readPlanCompleted.
  ///
  /// In en, this message translates to:
  /// **'Plan completed! Congratulations! 🎉'**
  String get readPlanCompleted;

  /// No description provided for @readMarkDoneContinue.
  ///
  /// In en, this message translates to:
  /// **'Mark {book} {chapter} done & continue'**
  String readMarkDoneContinue(String book, int chapter);

  /// No description provided for @readNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get readNone;

  /// No description provided for @readBookFallback.
  ///
  /// In en, this message translates to:
  /// **'Book {number}'**
  String readBookFallback(int number);

  /// No description provided for @readRelatedVerses.
  ///
  /// In en, this message translates to:
  /// **'Related Verses'**
  String get readRelatedVerses;

  /// No description provided for @readNoCrossRefs.
  ///
  /// In en, this message translates to:
  /// **'No cross-references found for this verse.'**
  String get readNoCrossRefs;

  /// No description provided for @readCrossRefsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Cross-references will be available\nafter the next app update.'**
  String get readCrossRefsComingSoon;

  /// No description provided for @readCrossRefsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load cross-references.\n{error}'**
  String readCrossRefsLoadError(String error);

  /// No description provided for @readVerseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Verse not available'**
  String get readVerseUnavailable;

  /// No description provided for @readLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get readLoading;

  /// No description provided for @readVerseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Verse not found.'**
  String get readVerseNotFound;

  /// No description provided for @readBookOrChapterNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book or chapter not found.'**
  String get readBookOrChapterNotFound;

  /// No description provided for @readOpenInRead.
  ///
  /// In en, this message translates to:
  /// **'Open in Read'**
  String get readOpenInRead;

  /// No description provided for @readBookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find the referenced book.'**
  String get readBookNotFound;

  /// No description provided for @readVerseLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading verse: {error}'**
  String readVerseLoadError(String error);

  /// No description provided for @readTestament.
  ///
  /// In en, this message translates to:
  /// **'Testament'**
  String get readTestament;

  /// No description provided for @readBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get readBook;

  /// No description provided for @readChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get readChapter;

  /// No description provided for @readVerse.
  ///
  /// In en, this message translates to:
  /// **'Verse'**
  String get readVerse;

  /// No description provided for @readSelectBook.
  ///
  /// In en, this message translates to:
  /// **'Select Book'**
  String get readSelectBook;

  /// No description provided for @readOtShort.
  ///
  /// In en, this message translates to:
  /// **'OT'**
  String get readOtShort;

  /// No description provided for @readNtShort.
  ///
  /// In en, this message translates to:
  /// **'NT'**
  String get readNtShort;

  /// No description provided for @readOldTestament.
  ///
  /// In en, this message translates to:
  /// **'Old Testament'**
  String get readOldTestament;

  /// No description provided for @readNewTestament.
  ///
  /// In en, this message translates to:
  /// **'New Testament'**
  String get readNewTestament;

  /// No description provided for @readOldTestamentTwoLine.
  ///
  /// In en, this message translates to:
  /// **'Old\nTestament'**
  String get readOldTestamentTwoLine;

  /// No description provided for @readNewTestamentTwoLine.
  ///
  /// In en, this message translates to:
  /// **'New\nTestament'**
  String get readNewTestamentTwoLine;

  /// No description provided for @readStoriesSections.
  ///
  /// In en, this message translates to:
  /// **'Stories & Sections'**
  String get readStoriesSections;

  /// No description provided for @readAllVerses.
  ///
  /// In en, this message translates to:
  /// **'All Verses'**
  String get readAllVerses;

  /// No description provided for @readTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'Bible Translation'**
  String get readTranslationTitle;

  /// No description provided for @readLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Layout'**
  String get readLayoutTitle;

  /// No description provided for @readLayoutSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get readLayoutSingle;

  /// No description provided for @readLayoutBilingual.
  ///
  /// In en, this message translates to:
  /// **'Bilingual'**
  String get readLayoutBilingual;

  /// No description provided for @readLayoutParallel.
  ///
  /// In en, this message translates to:
  /// **'Parallel'**
  String get readLayoutParallel;

  /// No description provided for @readLayoutChips.
  ///
  /// In en, this message translates to:
  /// **'Chips'**
  String get readLayoutChips;

  /// No description provided for @readLayoutSingleDesc.
  ///
  /// In en, this message translates to:
  /// **'One translation'**
  String get readLayoutSingleDesc;

  /// No description provided for @readLayoutBilingualDesc.
  ///
  /// In en, this message translates to:
  /// **'Two translations stacked per verse'**
  String get readLayoutBilingualDesc;

  /// No description provided for @readLayoutParallelDesc.
  ///
  /// In en, this message translates to:
  /// **'Two translations in side-by-side columns'**
  String get readLayoutParallelDesc;

  /// No description provided for @readLayoutChipsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap a verse to switch its translation'**
  String get readLayoutChipsDesc;

  /// No description provided for @readPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get readPrimary;

  /// No description provided for @readSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get readSecondary;

  /// No description provided for @readTranslationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading translations: {error}'**
  String readTranslationsLoadError(String error);

  /// No description provided for @readTranslationDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted.'**
  String readTranslationDeleted(String name);

  /// No description provided for @readDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String readDeleteFailed(String error);

  /// No description provided for @readDeleteTranslation.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String readDeleteTranslation(String name);

  /// No description provided for @readKjvAlwaysAvailable.
  ///
  /// In en, this message translates to:
  /// **'Always available · app backbone'**
  String get readKjvAlwaysAvailable;

  /// No description provided for @readCannotDeleteBackbone.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete — app backbone'**
  String get readCannotDeleteBackbone;

  /// No description provided for @readAvailableToAdd.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE TO ADD'**
  String get readAvailableToAdd;

  /// No description provided for @readNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection — try again when online.'**
  String get readNoInternet;

  /// No description provided for @readRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get readRestoreFailed;

  /// No description provided for @readDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get readDownloadFailed;

  /// No description provided for @readRestoreFailedDetail.
  ///
  /// In en, this message translates to:
  /// **'Restore failed ({error}).'**
  String readRestoreFailedDetail(String error);

  /// No description provided for @readDownloadFailedDetail.
  ///
  /// In en, this message translates to:
  /// **'Download failed ({error}).'**
  String readDownloadFailedDetail(String error);

  /// No description provided for @readRestoreOffline.
  ///
  /// In en, this message translates to:
  /// **'restore offline'**
  String get readRestoreOffline;

  /// No description provided for @homeVerseOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'VERSE OF THE DAY'**
  String get homeVerseOfTheDay;

  /// No description provided for @homeDevotional.
  ///
  /// In en, this message translates to:
  /// **'DEVOTIONAL'**
  String get homeDevotional;

  /// No description provided for @homeCommentary.
  ///
  /// In en, this message translates to:
  /// **'COMMENTARY'**
  String get homeCommentary;

  /// No description provided for @homeGoDeeper.
  ///
  /// In en, this message translates to:
  /// **'Go Deeper'**
  String get homeGoDeeper;

  /// No description provided for @homeReadFullDefinition.
  ///
  /// In en, this message translates to:
  /// **'Read Full Definition'**
  String get homeReadFullDefinition;

  /// No description provided for @homeWordOfTheDayHeading.
  ///
  /// In en, this message translates to:
  /// **'WORD OF THE DAY'**
  String get homeWordOfTheDayHeading;

  /// No description provided for @homeWordOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Word of the day'**
  String get homeWordOfTheDay;

  /// No description provided for @homeWotdEmpty.
  ///
  /// In en, this message translates to:
  /// **'No word picked for today yet — try again later.'**
  String get homeWotdEmpty;

  /// No description provided for @homeWotdUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Word of the day unavailable ({error}).'**
  String homeWotdUnavailable(String error);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get navRead;

  /// No description provided for @navStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get navStudy;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit The Blessed Bible?'**
  String get navExitTitle;

  /// No description provided for @navExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get navExitMessage;

  /// No description provided for @navExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get navExit;

  /// No description provided for @navCastLotsError.
  ///
  /// In en, this message translates to:
  /// **'Could not cast lots — please try again.'**
  String get navCastLotsError;

  /// No description provided for @navCastingLots.
  ///
  /// In en, this message translates to:
  /// **'Casting lots...'**
  String get navCastingLots;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search verses, commentary…'**
  String get searchHint;

  /// No description provided for @searchAllBooks.
  ///
  /// In en, this message translates to:
  /// **'All Books'**
  String get searchAllBooks;

  /// No description provided for @searchFilterMyNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get searchFilterMyNotes;

  /// No description provided for @searchEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search the Bible, commentary\nand your notes'**
  String get searchEmptyPrompt;

  /// No description provided for @searchRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'RECENT SEARCHES'**
  String get searchRecentSearches;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get searchClear;

  /// No description provided for @searchRecentPlaces.
  ///
  /// In en, this message translates to:
  /// **'RECENT PLACES'**
  String get searchRecentPlaces;

  /// No description provided for @searchMostRead.
  ///
  /// In en, this message translates to:
  /// **'MOST READ'**
  String get searchMostRead;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// No description provided for @searchTopResults.
  ///
  /// In en, this message translates to:
  /// **'Showing top 100 results'**
  String get searchTopResults;

  /// No description provided for @searchResultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result found} other{{count} results found}}'**
  String searchResultsFound(int count);

  /// No description provided for @searchSectionDictionary.
  ///
  /// In en, this message translates to:
  /// **'DICTIONARY ({count})'**
  String searchSectionDictionary(int count);

  /// No description provided for @searchSectionStories.
  ///
  /// In en, this message translates to:
  /// **'STORIES ({count})'**
  String searchSectionStories(int count);

  /// No description provided for @searchSectionJumpTo.
  ///
  /// In en, this message translates to:
  /// **'JUMP TO ({count})'**
  String searchSectionJumpTo(int count);

  /// No description provided for @searchSectionVerses.
  ///
  /// In en, this message translates to:
  /// **'VERSES ({count})'**
  String searchSectionVerses(int count);

  /// No description provided for @searchSectionCommentary.
  ///
  /// In en, this message translates to:
  /// **'COMMENTARY ({count})'**
  String searchSectionCommentary(int count);

  /// No description provided for @searchSectionMyNotes.
  ///
  /// In en, this message translates to:
  /// **'MY NOTES ({count})'**
  String searchSectionMyNotes(int count);

  /// No description provided for @searchCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get searchCopied;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTabGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsTabGeneral;

  /// No description provided for @settingsTabNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get settingsTabNavigation;

  /// No description provided for @settingsTabReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsTabReminders;

  /// No description provided for @settingsTabInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settingsTabInfo;

  /// No description provided for @settingsWidgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Screen Widgets'**
  String get settingsWidgetsTitle;

  /// No description provided for @settingsWidgetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize gradients, transparency, and live preview'**
  String get settingsWidgetsSubtitle;

  /// No description provided for @settingsStartPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Default start page'**
  String get settingsStartPageTitle;

  /// No description provided for @settingsStartPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which page the app opens to on launch'**
  String get settingsStartPageSubtitle;

  /// No description provided for @settingsPageHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get settingsPageHome;

  /// No description provided for @settingsPageRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get settingsPageRead;

  /// No description provided for @settingsPageStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get settingsPageStudy;

  /// No description provided for @settingsPageSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get settingsPageSearch;

  /// No description provided for @settingsImmersiveReading.
  ///
  /// In en, this message translates to:
  /// **'Immersive Reading'**
  String get settingsImmersiveReading;

  /// No description provided for @settingsImmersiveOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Anchored (Off)'**
  String get settingsImmersiveOffTitle;

  /// No description provided for @settingsImmersiveOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation remains visible at all times'**
  String get settingsImmersiveOffSubtitle;

  /// No description provided for @settingsImmersivePartialTitle.
  ///
  /// In en, this message translates to:
  /// **'Guided (Partial)'**
  String get settingsImmersivePartialTitle;

  /// No description provided for @settingsImmersivePartialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-hides main navigation, but leaves the book & chapter pill'**
  String get settingsImmersivePartialSubtitle;

  /// No description provided for @settingsImmersiveFullTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Waters (Full)'**
  String get settingsImmersiveFullTitle;

  /// No description provided for @settingsImmersiveFullSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total immersion. All menus hide when scrolling'**
  String get settingsImmersiveFullSubtitle;

  /// No description provided for @settingsShowStrongs.
  ///
  /// In en, this message translates to:
  /// **'Show Strong\'s Numbers'**
  String get settingsShowStrongs;

  /// No description provided for @settingsShowStrongsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Displays original Hebrew/Greek identifiers alongside KJV text for deep word study'**
  String get settingsShowStrongsSubtitle;

  /// No description provided for @settingsStrongsGetIt.
  ///
  /// In en, this message translates to:
  /// **'Get it'**
  String get settingsStrongsGetIt;

  /// No description provided for @settingsStrongsMarkerAsterisk.
  ///
  /// In en, this message translates to:
  /// **'Asterisk (*)'**
  String get settingsStrongsMarkerAsterisk;

  /// No description provided for @settingsStrongsMarkerChain.
  ///
  /// In en, this message translates to:
  /// **'Chain (🔗)'**
  String get settingsStrongsMarkerChain;

  /// No description provided for @settingsStrongsMarkerNumber.
  ///
  /// In en, this message translates to:
  /// **'Number (H1234)'**
  String get settingsStrongsMarkerNumber;

  /// No description provided for @settingsReadingSpeed.
  ///
  /// In en, this message translates to:
  /// **'Reading speed'**
  String get settingsReadingSpeed;

  /// No description provided for @settingsReadingSpeedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pace estimates for plans (words per minute)'**
  String get settingsReadingSpeedSubtitle;

  /// No description provided for @settingsSpeedRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get settingsSpeedRelaxed;

  /// No description provided for @settingsSpeedStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get settingsSpeedStandard;

  /// No description provided for @settingsSpeedBrisk.
  ///
  /// In en, this message translates to:
  /// **'Brisk'**
  String get settingsSpeedBrisk;

  /// No description provided for @settingsDictUnderlines.
  ///
  /// In en, this message translates to:
  /// **'Dictionary Underlines'**
  String get settingsDictUnderlines;

  /// No description provided for @settingsDictUnderlinesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dotted underlines on biblical terms and archaic words'**
  String get settingsDictUnderlinesSubtitle;

  /// No description provided for @settingsUnderlineScope.
  ///
  /// In en, this message translates to:
  /// **'Underline Scope'**
  String get settingsUnderlineScope;

  /// No description provided for @settingsScopeNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Names & terms only'**
  String get settingsScopeNamesTitle;

  /// No description provided for @settingsScopeNamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Proper nouns and specific biblical concepts'**
  String get settingsScopeNamesSubtitle;

  /// No description provided for @settingsScopeTrickyTitle.
  ///
  /// In en, this message translates to:
  /// **'Names + tricky words (Recommended)'**
  String get settingsScopeTrickyTitle;

  /// No description provided for @settingsScopeTrickySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes archaic words with changed meanings (e.g., let, prevent)'**
  String get settingsScopeTrickySubtitle;

  /// No description provided for @settingsScopeEverythingTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get settingsScopeEverythingTitle;

  /// No description provided for @settingsScopeEverythingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highlights all archaic grammar (e.g., thee, thou, hath, unto)'**
  String get settingsScopeEverythingSubtitle;

  /// No description provided for @settingsScopeDifficultTitle.
  ///
  /// In en, this message translates to:
  /// **'Difficult words only'**
  String get settingsScopeDifficultTitle;

  /// No description provided for @settingsScopeDifficultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Archaic, misleading and contested words — easy words like god and son stay unmarked'**
  String get settingsScopeDifficultSubtitle;

  /// No description provided for @settingsScopeDifficultNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Difficult + names'**
  String get settingsScopeDifficultNamesTitle;

  /// No description provided for @settingsScopeDifficultNamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds people and places (e.g., David, Jerusalem) to difficult words'**
  String get settingsScopeDifficultNamesSubtitle;

  /// No description provided for @settingsOtherEnglishVersions.
  ///
  /// In en, this message translates to:
  /// **'Other English versions'**
  String get settingsOtherEnglishVersions;

  /// No description provided for @settingsContestedOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Contested words only'**
  String get settingsContestedOnlyTitle;

  /// No description provided for @settingsContestedOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'BBE, WEB and other English versions mark disputed words (e.g., hell, baptism)'**
  String get settingsContestedOnlySubtitle;

  /// No description provided for @settingsFollowScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow underline scope'**
  String get settingsFollowScopeTitle;

  /// No description provided for @settingsFollowScopeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same marking as KJV in every English version'**
  String get settingsFollowScopeSubtitle;

  /// No description provided for @settingsNoUnderlinesTitle.
  ///
  /// In en, this message translates to:
  /// **'No underlines'**
  String get settingsNoUnderlinesTitle;

  /// No description provided for @settingsNoUnderlinesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Other English versions show no dictionary marks'**
  String get settingsNoUnderlinesSubtitle;

  /// No description provided for @settingsPopupStyle.
  ///
  /// In en, this message translates to:
  /// **'Popup Style'**
  String get settingsPopupStyle;

  /// No description provided for @settingsPopupStyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How dictionary definitions and Strong\'s numbers are displayed'**
  String get settingsPopupStyleSubtitle;

  /// No description provided for @settingsPopupFloating.
  ///
  /// In en, this message translates to:
  /// **'Floating'**
  String get settingsPopupFloating;

  /// No description provided for @settingsPopupBottomSheet.
  ///
  /// In en, this message translates to:
  /// **'Bottom sheet'**
  String get settingsPopupBottomSheet;

  /// No description provided for @settingsSavedInMyLanguage.
  ///
  /// In en, this message translates to:
  /// **'Show saved items in my language'**
  String get settingsSavedInMyLanguage;

  /// No description provided for @settingsSavedInMyLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display Bookmarks, Highlights, and Commentary verses in your active primary translation'**
  String get settingsSavedInMyLanguageSubtitle;

  /// No description provided for @settingsTranslationChips.
  ///
  /// In en, this message translates to:
  /// **'Show translation options on saved items'**
  String get settingsTranslationChips;

  /// No description provided for @settingsTranslationChipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds a compact translation chip row to view saved verses in other translations'**
  String get settingsTranslationChipsSubtitle;

  /// No description provided for @settingsVerseActionStyle.
  ///
  /// In en, this message translates to:
  /// **'Verse Action Style'**
  String get settingsVerseActionStyle;

  /// No description provided for @settingsVerseActionStyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sheet (compact) or Classic (tall dock) when verses are selected; Radial moves the long-press menu to a circular ring'**
  String get settingsVerseActionStyleSubtitle;

  /// No description provided for @settingsActionSheet.
  ///
  /// In en, this message translates to:
  /// **'Sheet'**
  String get settingsActionSheet;

  /// No description provided for @settingsActionClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get settingsActionClassic;

  /// No description provided for @settingsActionMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get settingsActionMinimal;

  /// No description provided for @settingsActionRaindrop.
  ///
  /// In en, this message translates to:
  /// **'Raindrop'**
  String get settingsActionRaindrop;

  /// No description provided for @settingsActionRadial.
  ///
  /// In en, this message translates to:
  /// **'Radial'**
  String get settingsActionRadial;

  /// No description provided for @settingsKeepAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen Awake'**
  String get settingsKeepAwake;

  /// No description provided for @settingsKeepAwakeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent device from sleeping while reading'**
  String get settingsKeepAwakeSubtitle;

  /// No description provided for @settingsRestartOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Restart onboarding'**
  String get settingsRestartOnboarding;

  /// No description provided for @settingsRestartOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay the first-time setup'**
  String get settingsRestartOnboardingSubtitle;

  /// No description provided for @settingsRestartOnboardingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart onboarding?'**
  String get settingsRestartOnboardingDialogTitle;

  /// No description provided for @settingsRestartOnboardingDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This will replay the first-time setup. Your current theme, font, and translation stay unless you change them.'**
  String get settingsRestartOnboardingDialogBody;

  /// No description provided for @settingsRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get settingsRestart;

  /// No description provided for @settingsAppearanceText.
  ///
  /// In en, this message translates to:
  /// **'Appearance & text'**
  String get settingsAppearanceText;

  /// No description provided for @settingsAppearanceTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, fonts, sizes and reading colors'**
  String get settingsAppearanceTextSubtitle;

  /// No description provided for @settingsSabbathTitle.
  ///
  /// In en, this message translates to:
  /// **'Friday Sunset Reminder'**
  String get settingsSabbathTitle;

  /// No description provided for @settingsSabbathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome the Sabbath at your local sunset time.'**
  String get settingsSabbathSubtitle;

  /// No description provided for @settingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsLocation;

  /// No description provided for @settingsLocationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set (Tap to set)'**
  String get settingsLocationNotSet;

  /// No description provided for @settingsDailyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reading Reminder'**
  String get settingsDailyReminderTitle;

  /// No description provided for @settingsDailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A daily nudge to spend time in the Word.'**
  String get settingsDailyReminderSubtitle;

  /// No description provided for @settingsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get settingsTime;

  /// No description provided for @settingsWeeklyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Weekly Reminder'**
  String get settingsWeeklyReminderTitle;

  /// No description provided for @settingsWeeklyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a specific day and time each week for deeper study.'**
  String get settingsWeeklyReminderSubtitle;

  /// No description provided for @settingsDayAndTime.
  ///
  /// In en, this message translates to:
  /// **'Day & Time'**
  String get settingsDayAndTime;

  /// No description provided for @settingsChooseDay.
  ///
  /// In en, this message translates to:
  /// **'Choose Day'**
  String get settingsChooseDay;

  /// No description provided for @settingsShowReadingTips.
  ///
  /// In en, this message translates to:
  /// **'Show reading tips'**
  String get settingsShowReadingTips;

  /// No description provided for @settingsShowReadingTipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show guided hints for reading actions like highlighting and swiping'**
  String get settingsShowReadingTipsSubtitle;

  /// No description provided for @settingsNavSteps.
  ///
  /// In en, this message translates to:
  /// **'Navigation Steps'**
  String get settingsNavSteps;

  /// No description provided for @settingsNavStepsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How many steps to reach a verse. 2-step: Book → Chapter. 3-step: Book → Chapter → Verse. 4-step: Testament → Book → Chapter → Verse.'**
  String get settingsNavStepsSubtitle;

  /// No description provided for @settingsAutoClose.
  ///
  /// In en, this message translates to:
  /// **'Auto-close sheet on final selection'**
  String get settingsAutoClose;

  /// No description provided for @settingsAutoCloseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically dismiss the picker after the last step'**
  String get settingsAutoCloseSubtitle;

  /// No description provided for @settingsSelectorHeight.
  ///
  /// In en, this message translates to:
  /// **'Book selector height'**
  String get settingsSelectorHeight;

  /// No description provided for @settingsSelectorHeightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control how far up the book/chapter sheet opens'**
  String get settingsSelectorHeightSubtitle;

  /// No description provided for @settingsHeightHalf.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get settingsHeightHalf;

  /// No description provided for @settingsHeightFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get settingsHeightFull;

  /// No description provided for @settingsAutoOpenSingle.
  ///
  /// In en, this message translates to:
  /// **'Auto-open single search result'**
  String get settingsAutoOpenSingle;

  /// No description provided for @settingsAutoOpenSingleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically navigate when a search returns exactly one result'**
  String get settingsAutoOpenSingleSubtitle;

  /// No description provided for @settingsIncludeNotes.
  ///
  /// In en, this message translates to:
  /// **'Include personal notes in search'**
  String get settingsIncludeNotes;

  /// No description provided for @settingsIncludeNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow search to look through your personal notes'**
  String get settingsIncludeNotesSubtitle;

  /// No description provided for @settingsWholeWords.
  ///
  /// In en, this message translates to:
  /// **'Match whole words only'**
  String get settingsWholeWords;

  /// No description provided for @settingsWholeWordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only find exact word matches (disables partial/prefix matching)'**
  String get settingsWholeWordsSubtitle;

  /// No description provided for @settingsFuzzySearch.
  ///
  /// In en, this message translates to:
  /// **'Forgiving search'**
  String get settingsFuzzySearch;

  /// No description provided for @settingsFuzzySearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Also show close matches for typos (e.g. Jhon finds John)'**
  String get settingsFuzzySearchSubtitle;

  /// No description provided for @settingsDefaultScopes.
  ///
  /// In en, this message translates to:
  /// **'Default Search Scopes'**
  String get settingsDefaultScopes;

  /// No description provided for @settingsOldTestament.
  ///
  /// In en, this message translates to:
  /// **'Old Testament'**
  String get settingsOldTestament;

  /// No description provided for @settingsNewTestament.
  ///
  /// In en, this message translates to:
  /// **'New Testament'**
  String get settingsNewTestament;

  /// No description provided for @settingsCommentary.
  ///
  /// In en, this message translates to:
  /// **'Commentary'**
  String get settingsCommentary;

  /// No description provided for @settingsGestures.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get settingsGestures;

  /// No description provided for @settingsPullDownHome.
  ///
  /// In en, this message translates to:
  /// **'Pull down on Home'**
  String get settingsPullDownHome;

  /// No description provided for @settingsPullDownHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pull down past the top to open Settings or Appearance'**
  String get settingsPullDownHomeSubtitle;

  /// No description provided for @settingsPullDownOpens.
  ///
  /// In en, this message translates to:
  /// **'Pull-down opens'**
  String get settingsPullDownOpens;

  /// No description provided for @settingsPullDownOpensSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Destination of the Home pull-down gesture'**
  String get settingsPullDownOpensSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsSwipeLeftHome.
  ///
  /// In en, this message translates to:
  /// **'Swipe left on Home'**
  String get settingsSwipeLeftHome;

  /// No description provided for @settingsSwipeLeftHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to jump to the Read tab'**
  String get settingsSwipeLeftHomeSubtitle;

  /// No description provided for @settingsLongPressNav.
  ///
  /// In en, this message translates to:
  /// **'Long-press button to open navigation'**
  String get settingsLongPressNav;

  /// No description provided for @settingsLongPressNavSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Long-press the bottom-right button to quickly open the Book/Chapter selector.'**
  String get settingsLongPressNavSubtitle;

  /// No description provided for @settingsBbeNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'BBE Translation Note'**
  String get settingsBbeNoteTitle;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Back up my data'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export notes, highlights, and settings'**
  String get settingsBackupSubtitle;

  /// No description provided for @settingsRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get settingsRestoreBackup;

  /// No description provided for @settingsRestoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import your data from a backup JSON'**
  String get settingsRestoreBackupSubtitle;

  /// No description provided for @settingsRestoreBackupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get settingsRestoreBackupDialogTitle;

  /// No description provided for @settingsRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your backup JSON here...'**
  String get settingsRestoreHint;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get settingsRestore;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache/downloaded data'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free up space by removing cached files'**
  String get settingsClearCacheSubtitle;

  /// No description provided for @settingsNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not yet implemented'**
  String get settingsNotImplemented;

  /// No description provided for @settingsResetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset settings'**
  String get settingsResetSettings;

  /// No description provided for @settingsResetSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore original app settings (content is kept)'**
  String get settingsResetSettingsSubtitle;

  /// No description provided for @settingsResetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset settings?'**
  String get settingsResetDialogTitle;

  /// No description provided for @settingsResetDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to default? This won\'t affect your bookmarks, notes, or highlights.'**
  String get settingsResetDialogBody;

  /// No description provided for @settingsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to default.'**
  String get settingsResetDone;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsReset;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get settingsUnknown;

  /// No description provided for @settingsStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage & downloads'**
  String get settingsStorage;

  /// No description provided for @settingsStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cache, downloaded translations and what can be freed'**
  String get settingsStorageSubtitle;

  /// No description provided for @settingsSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get settingsSendFeedback;

  /// No description provided for @settingsCrashReports.
  ///
  /// In en, this message translates to:
  /// **'Send crash reports'**
  String get settingsCrashReports;

  /// No description provided for @settingsCrashReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Anonymous crash details help fix bugs. No Bible reading, notes or personal content is included.'**
  String get settingsCrashReportsSubtitle;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits & sources'**
  String get settingsCredits;

  /// No description provided for @settingsCreditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bible translations, commentary, study data, fonts and licenses'**
  String get settingsCreditsSubtitle;

  /// No description provided for @settingsSetSunsetLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location for Sunset'**
  String get settingsSetSunsetLocation;

  /// No description provided for @settingsCurrentLocationGps.
  ///
  /// In en, this message translates to:
  /// **'Current Location (GPS)'**
  String get settingsCurrentLocationGps;

  /// No description provided for @settingsUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get settingsUseMyLocation;

  /// No description provided for @settingsOrSelectCity.
  ///
  /// In en, this message translates to:
  /// **'OR select a major city'**
  String get settingsOrSelectCity;

  /// No description provided for @settingsTypography.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get settingsTypography;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsSearchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search Settings'**
  String get settingsSearchSettings;

  /// No description provided for @settingsMatchTypeHeader.
  ///
  /// In en, this message translates to:
  /// **'MATCH TYPE'**
  String get settingsMatchTypeHeader;

  /// No description provided for @settingsExactMatch.
  ///
  /// In en, this message translates to:
  /// **'Exact Match'**
  String get settingsExactMatch;

  /// No description provided for @settingsExactMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only match the exact phrase'**
  String get settingsExactMatchSubtitle;

  /// No description provided for @settingsScopeHeader.
  ///
  /// In en, this message translates to:
  /// **'SCOPE'**
  String get settingsScopeHeader;

  /// No description provided for @settingsDisabledBookFilter.
  ///
  /// In en, this message translates to:
  /// **'Disabled (Book Filter Active)'**
  String get settingsDisabledBookFilter;

  /// No description provided for @settingsMyNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get settingsMyNotes;

  /// No description provided for @settingsBehaviorHeader.
  ///
  /// In en, this message translates to:
  /// **'BEHAVIOR'**
  String get settingsBehaviorHeader;

  /// No description provided for @settingsAutoOpenSingleShort.
  ///
  /// In en, this message translates to:
  /// **'Auto-open Single Result'**
  String get settingsAutoOpenSingleShort;

  /// No description provided for @settingsAutoOpenSingleShortSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jump directly if only one result is found'**
  String get settingsAutoOpenSingleShortSubtitle;

  /// No description provided for @settingsBackgroundGlow.
  ///
  /// In en, this message translates to:
  /// **'Enable Background Glow'**
  String get settingsBackgroundGlow;

  /// No description provided for @settingsBackgroundGlowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Renders a subtle animated light behind the reader'**
  String get settingsBackgroundGlowSubtitle;

  /// No description provided for @settingsThemeGroupFoundations.
  ///
  /// In en, this message translates to:
  /// **'FOUNDATIONS'**
  String get settingsThemeGroupFoundations;

  /// No description provided for @settingsThemeDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get settingsThemeDawn;

  /// No description provided for @settingsThemeFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get settingsThemeFresh;

  /// No description provided for @settingsThemeGroupFirmament.
  ///
  /// In en, this message translates to:
  /// **'FIRMAMENT'**
  String get settingsThemeGroupFirmament;

  /// No description provided for @settingsThemeSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get settingsThemeSun;

  /// No description provided for @settingsThemeMoon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get settingsThemeMoon;

  /// No description provided for @settingsThemeStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get settingsThemeStars;

  /// No description provided for @settingsThemeGroupEden.
  ///
  /// In en, this message translates to:
  /// **'EDEN'**
  String get settingsThemeGroupEden;

  /// No description provided for @settingsThemeLilies.
  ///
  /// In en, this message translates to:
  /// **'Lilies'**
  String get settingsThemeLilies;

  /// No description provided for @settingsThemeRoses.
  ///
  /// In en, this message translates to:
  /// **'Roses'**
  String get settingsThemeRoses;

  /// No description provided for @settingsThemeOlives.
  ///
  /// In en, this message translates to:
  /// **'Olives'**
  String get settingsThemeOlives;

  /// No description provided for @settingsThemeGroupSanctuary.
  ///
  /// In en, this message translates to:
  /// **'SANCTUARY'**
  String get settingsThemeGroupSanctuary;

  /// No description provided for @settingsThemePurple.
  ///
  /// In en, this message translates to:
  /// **'Priestly\nPurple'**
  String get settingsThemePurple;

  /// No description provided for @settingsThemeBlue.
  ///
  /// In en, this message translates to:
  /// **'Galilee\nBlue'**
  String get settingsThemeBlue;

  /// No description provided for @settingsThemeRed.
  ///
  /// In en, this message translates to:
  /// **'Scarlet\nRed'**
  String get settingsThemeRed;

  /// No description provided for @settingsSurpriseMe.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get settingsSurpriseMe;

  /// No description provided for @settingsThemeOledDark.
  ///
  /// In en, this message translates to:
  /// **'OLED\nDark'**
  String get settingsThemeOledDark;

  /// No description provided for @settingsThemeDuskOled.
  ///
  /// In en, this message translates to:
  /// **'Dusk\nOLED'**
  String get settingsThemeDuskOled;

  /// No description provided for @settingsSurfaceStyle.
  ///
  /// In en, this message translates to:
  /// **'Surface Style'**
  String get settingsSurfaceStyle;

  /// No description provided for @settingsSurfaceStyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visual depth and material rendering'**
  String get settingsSurfaceStyleSubtitle;

  /// No description provided for @settingsSurfaceEarth.
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get settingsSurfaceEarth;

  /// No description provided for @settingsSurfaceEarthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flat surface'**
  String get settingsSurfaceEarthSubtitle;

  /// No description provided for @settingsSurfaceHeaven.
  ///
  /// In en, this message translates to:
  /// **'Heaven'**
  String get settingsSurfaceHeaven;

  /// No description provided for @settingsSurfaceHeavenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Frosted depth'**
  String get settingsSurfaceHeavenSubtitle;

  /// No description provided for @settingsSurfacePaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get settingsSurfacePaper;

  /// No description provided for @settingsSurfacePaperSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warm e-reader'**
  String get settingsSurfacePaperSubtitle;

  /// No description provided for @settingsSurfaceClay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get settingsSurfaceClay;

  /// No description provided for @settingsSurfaceClaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pillowy 3-D'**
  String get settingsSurfaceClaySubtitle;

  /// No description provided for @settingsWidgetsLivePreview.
  ///
  /// In en, this message translates to:
  /// **'Live preview & style customization'**
  String get settingsWidgetsLivePreview;

  /// No description provided for @settingsWidgetPreviewHeader.
  ///
  /// In en, this message translates to:
  /// **'LIVE WIDGET PREVIEW'**
  String get settingsWidgetPreviewHeader;

  /// No description provided for @settingsWidgetStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak Active! • Daily Goal'**
  String get settingsWidgetStreak;

  /// No description provided for @settingsWidgetWotd.
  ///
  /// In en, this message translates to:
  /// **'WORD OF THE DAY'**
  String get settingsWidgetWotd;

  /// No description provided for @settingsWidgetVotd.
  ///
  /// In en, this message translates to:
  /// **'VERSE OF THE DAY'**
  String get settingsWidgetVotd;

  /// No description provided for @settingsWidgetBackgroundHeader.
  ///
  /// In en, this message translates to:
  /// **'BACKGROUND THEME & GRADIENTS'**
  String get settingsWidgetBackgroundHeader;

  /// No description provided for @settingsWidgetContrastHeader.
  ///
  /// In en, this message translates to:
  /// **'TEXT CONTRAST'**
  String get settingsWidgetContrastHeader;

  /// No description provided for @settingsWidgetTextAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto ✨'**
  String get settingsWidgetTextAuto;

  /// No description provided for @settingsWidgetTextDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Text ☀️'**
  String get settingsWidgetTextDark;

  /// No description provided for @settingsWidgetTextWhite.
  ///
  /// In en, this message translates to:
  /// **'White Text 🌙'**
  String get settingsWidgetTextWhite;

  /// No description provided for @settingsWidgetSynced.
  ///
  /// In en, this message translates to:
  /// **'Widgets synced with new style! ✨'**
  String get settingsWidgetSynced;

  /// No description provided for @settingsWidgetApply.
  ///
  /// In en, this message translates to:
  /// **'Apply & Sync to Home Screen'**
  String get settingsWidgetApply;

  /// No description provided for @settingsFontSizeHeader.
  ///
  /// In en, this message translates to:
  /// **'FONT SIZE'**
  String get settingsFontSizeHeader;

  /// No description provided for @settingsFontWeightHeader.
  ///
  /// In en, this message translates to:
  /// **'FONT WEIGHT'**
  String get settingsFontWeightHeader;

  /// No description provided for @settingsWeightLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsWeightLight;

  /// No description provided for @settingsWeightRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get settingsWeightRegular;

  /// No description provided for @settingsWeightMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get settingsWeightMedium;

  /// No description provided for @settingsWeightBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get settingsWeightBold;

  /// No description provided for @settingsLineSpacingHeader.
  ///
  /// In en, this message translates to:
  /// **'LINE SPACING'**
  String get settingsLineSpacingHeader;

  /// No description provided for @settingsSpacingCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get settingsSpacingCompact;

  /// No description provided for @settingsSpacingNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsSpacingNormal;

  /// No description provided for @settingsMarginsHeader.
  ///
  /// In en, this message translates to:
  /// **'MARGINS'**
  String get settingsMarginsHeader;

  /// No description provided for @settingsAlignmentHeader.
  ///
  /// In en, this message translates to:
  /// **'ALIGNMENT'**
  String get settingsAlignmentHeader;

  /// No description provided for @settingsAlignLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get settingsAlignLeft;

  /// No description provided for @settingsAlignCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get settingsAlignCenter;

  /// No description provided for @settingsAlignRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get settingsAlignRight;

  /// No description provided for @settingsAlignJustified.
  ///
  /// In en, this message translates to:
  /// **'Justified'**
  String get settingsAlignJustified;

  /// No description provided for @settingsFontFamilyHeader.
  ///
  /// In en, this message translates to:
  /// **'FONT FAMILY'**
  String get settingsFontFamilyHeader;

  /// No description provided for @settingsItalicHeader.
  ///
  /// In en, this message translates to:
  /// **'ITALIC READING TEXT'**
  String get settingsItalicHeader;

  /// No description provided for @settingsDailyReading.
  ///
  /// In en, this message translates to:
  /// **'Daily Reading'**
  String get settingsDailyReading;

  /// No description provided for @settingsCustomReminder.
  ///
  /// In en, this message translates to:
  /// **'Custom Reminder'**
  String get settingsCustomReminder;

  /// No description provided for @settingsMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get settingsMonday;

  /// No description provided for @settingsTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get settingsTuesday;

  /// No description provided for @settingsWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get settingsWednesday;

  /// No description provided for @settingsThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get settingsThursday;

  /// No description provided for @settingsFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get settingsFriday;

  /// No description provided for @settingsSaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get settingsSaturday;

  /// No description provided for @settingsSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get settingsSunday;

  /// No description provided for @settingsStrongsPackRequired.
  ///
  /// In en, this message translates to:
  /// **'Requires the “KJV with Strong\'s” pack ({size} download).'**
  String settingsStrongsPackRequired(String size);

  /// No description provided for @settingsBbeNoteBody.
  ///
  /// In en, this message translates to:
  /// **'The Bible in Basic English originally left some verses untranslated or heavily truncated. For those ({count} verses), the World English Bible (WEB) text is shown instead and marked with a WEB badge.'**
  String settingsBbeNoteBody(int count);

  /// No description provided for @settingsDayAtTime.
  ///
  /// In en, this message translates to:
  /// **'{day} at {time}'**
  String settingsDayAtTime(String day, String time);

  /// No description provided for @spaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Space'**
  String get spaceTitle;

  /// No description provided for @spaceTabHighlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get spaceTabHighlights;

  /// No description provided for @spaceTabBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get spaceTabBookmarks;

  /// No description provided for @spaceTabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get spaceTabNotes;

  /// No description provided for @spaceTabJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get spaceTabJournal;

  /// No description provided for @spaceHighlighted.
  ///
  /// In en, this message translates to:
  /// **'Highlighted'**
  String get spaceHighlighted;

  /// No description provided for @spaceNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get spaceNewFolder;

  /// No description provided for @spaceFolderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get spaceFolderNameHint;

  /// No description provided for @spaceCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get spaceCreate;

  /// No description provided for @spaceRenameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename Folder'**
  String get spaceRenameFolder;

  /// No description provided for @spaceRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get spaceRename;

  /// No description provided for @spaceDeleteFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Folder?'**
  String get spaceDeleteFolderTitle;

  /// No description provided for @spaceDeleteFolderBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{folderName}\"?\n\nYour bookmarks inside this folder will NOT be deleted; they will be moved to Unfiled.'**
  String spaceDeleteFolderBody(String folderName);

  /// No description provided for @spaceMoveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to Folder'**
  String get spaceMoveToFolder;

  /// No description provided for @spaceUnfiled.
  ///
  /// In en, this message translates to:
  /// **'Unfiled'**
  String get spaceUnfiled;

  /// No description provided for @spaceGroupEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get spaceGroupEarlier;

  /// No description provided for @spaceGroupLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get spaceGroupLast7Days;

  /// No description provided for @spaceGroupLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get spaceGroupLast30Days;

  /// No description provided for @spaceUnknownBook.
  ///
  /// In en, this message translates to:
  /// **'Unknown Book'**
  String get spaceUnknownBook;

  /// No description provided for @spaceNoBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks here.'**
  String get spaceNoBookmarks;

  /// No description provided for @spaceFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get spaceFilterAll;

  /// No description provided for @spaceByDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get spaceByDate;

  /// No description provided for @spaceByBook.
  ///
  /// In en, this message translates to:
  /// **'By Book'**
  String get spaceByBook;

  /// No description provided for @spaceYourNotes.
  ///
  /// In en, this message translates to:
  /// **'Your notes.'**
  String get spaceYourNotes;

  /// No description provided for @spaceNoNotesTapPlus.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.\nTap + to create one.'**
  String get spaceNoNotesTapPlus;

  /// No description provided for @spaceMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get spaceMore;

  /// No description provided for @spaceNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get spaceNote;

  /// No description provided for @spaceCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get spaceCopyText;

  /// No description provided for @spaceDeleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get spaceDeleteNoteTitle;

  /// No description provided for @spaceDeleteNoteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed permanently.'**
  String spaceDeleteNoteBody(String title);

  /// No description provided for @spaceUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get spaceUntitled;

  /// No description provided for @spaceBookmarkedVerse.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked verse'**
  String get spaceBookmarkedVerse;

  /// No description provided for @spaceHighlightedVerse.
  ///
  /// In en, this message translates to:
  /// **'Highlighted verse'**
  String get spaceHighlightedVerse;

  /// No description provided for @spaceOpenInRead.
  ///
  /// In en, this message translates to:
  /// **'Open in Read'**
  String get spaceOpenInRead;

  /// No description provided for @spaceAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get spaceAddNote;

  /// No description provided for @spaceCopyVerse.
  ///
  /// In en, this message translates to:
  /// **'Copy verse'**
  String get spaceCopyVerse;

  /// No description provided for @spaceShareVerse.
  ///
  /// In en, this message translates to:
  /// **'Share verse'**
  String get spaceShareVerse;

  /// No description provided for @spaceChangeColour.
  ///
  /// In en, this message translates to:
  /// **'Change colour'**
  String get spaceChangeColour;

  /// No description provided for @spaceMoveToFolderAction.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get spaceMoveToFolderAction;

  /// No description provided for @spaceRemoveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get spaceRemoveBookmark;

  /// No description provided for @spaceRemoveHighlight.
  ///
  /// In en, this message translates to:
  /// **'Remove highlight'**
  String get spaceRemoveHighlight;

  /// No description provided for @spaceHighlightColour.
  ///
  /// In en, this message translates to:
  /// **'Highlight colour'**
  String get spaceHighlightColour;

  /// No description provided for @spaceColourN.
  ///
  /// In en, this message translates to:
  /// **'Colour {index}'**
  String spaceColourN(int index);

  /// No description provided for @notesMyNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get notesMyNotes;

  /// No description provided for @notesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesEmptyTitle;

  /// No description provided for @notesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first note.'**
  String get notesEmptyBody;

  /// No description provided for @notesVerseInserted.
  ///
  /// In en, this message translates to:
  /// **'Verse inserted'**
  String get notesVerseInserted;

  /// No description provided for @notesAddCommentary.
  ///
  /// In en, this message translates to:
  /// **'Add Commentary'**
  String get notesAddCommentary;

  /// No description provided for @notesChapterTitlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Chapter Title'**
  String get notesChapterTitlePlaceholder;

  /// No description provided for @notesEditNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get notesEditNote;

  /// No description provided for @notesNewNoteOn.
  ///
  /// In en, this message translates to:
  /// **'New Note on {reference}'**
  String notesNewNoteOn(String reference);

  /// No description provided for @notesNewNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get notesNewNote;

  /// No description provided for @notesTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Note Title'**
  String get notesTitleHint;

  /// No description provided for @notesContentHint.
  ///
  /// In en, this message translates to:
  /// **'Start typing... (type / for commands)'**
  String get notesContentHint;

  /// No description provided for @notesInsertVerse.
  ///
  /// In en, this message translates to:
  /// **'Insert verse'**
  String get notesInsertVerse;

  /// No description provided for @notesInsertDate.
  ///
  /// In en, this message translates to:
  /// **'Insert date'**
  String get notesInsertDate;

  /// No description provided for @notesInsertChapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Insert chapter title'**
  String get notesInsertChapterTitle;

  /// No description provided for @notesSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved!'**
  String get notesSaved;

  /// No description provided for @notesSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get notesSaveChanges;

  /// No description provided for @notesSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get notesSaveNote;

  /// No description provided for @notesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get notesDeleted;

  /// No description provided for @notesDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get notesDeleteNote;

  /// No description provided for @notesNewJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'New Journal Entry'**
  String get notesNewJournalEntry;

  /// No description provided for @notesJournalHint.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today? Pour your heart out...'**
  String get notesJournalHint;

  /// No description provided for @notesSaveAndAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Save & Analyze'**
  String get notesSaveAndAnalyze;

  /// No description provided for @notesNoJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet.'**
  String get notesNoJournalEntries;

  /// No description provided for @notesWriteEntry.
  ///
  /// In en, this message translates to:
  /// **'Write Entry'**
  String get notesWriteEntry;

  /// No description provided for @notesAiReflection.
  ///
  /// In en, this message translates to:
  /// **'AI Reflection'**
  String get notesAiReflection;

  /// No description provided for @notesDetectedEmotion.
  ///
  /// In en, this message translates to:
  /// **'Detected Emotion: {emotion}'**
  String notesDetectedEmotion(String emotion);

  /// No description provided for @notesVersesList.
  ///
  /// In en, this message translates to:
  /// **'Verses: {verses}'**
  String notesVersesList(String verses);

  /// No description provided for @accountGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get accountGuest;

  /// No description provided for @accountSignInToSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync across devices'**
  String get accountSignInToSync;

  /// No description provided for @accountAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountAccount;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get accountSettings;

  /// No description provided for @accountBackUp.
  ///
  /// In en, this message translates to:
  /// **'Back up data'**
  String get accountBackUp;

  /// No description provided for @accountBackUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export notes, highlights and settings'**
  String get accountBackUpSubtitle;

  /// No description provided for @accountRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore data'**
  String get accountRestore;

  /// No description provided for @accountRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import from a backup file'**
  String get accountRestoreSubtitle;

  /// No description provided for @accountSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get accountSignInGoogle;

  /// No description provided for @accountSignInApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get accountSignInApple;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get accountSignOut;

  /// No description provided for @accountResetApp.
  ///
  /// In en, this message translates to:
  /// **'Reset app'**
  String get accountResetApp;

  /// No description provided for @accountResetAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Erase all on-device data'**
  String get accountResetAppSubtitle;

  /// No description provided for @accountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get accountSignIn;

  /// No description provided for @accountSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed In'**
  String get accountSignedIn;

  /// No description provided for @accountDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get accountDeleteAccount;

  /// No description provided for @accountDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get accountDeleteAccountTitle;

  /// No description provided for @accountDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This is permanent and irreversible.\n\nThe following will be completely removed:\n• Your sign-in account\n• Its cloud data in The Blessed Bible and Blessed Arcade (they share the account)\n• All on-device study data (bookmarks, highlights, history)'**
  String get accountDeleteAccountBody;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeleted;

  /// No description provided for @accountReauthFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t confirm it\'s you, so nothing was deleted. {reason}'**
  String accountReauthFailed(String reason);

  /// No description provided for @accountDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get accountDeleteFailed;

  /// No description provided for @accountOtherDataTitle.
  ///
  /// In en, this message translates to:
  /// **'This device has data from another account'**
  String get accountOtherDataTitle;

  /// No description provided for @accountOtherDataBody.
  ///
  /// In en, this message translates to:
  /// **'Your bookmarks, highlights and notes on this device came from a different account. What should happen to them?'**
  String get accountOtherDataBody;

  /// No description provided for @accountStartFresh.
  ///
  /// In en, this message translates to:
  /// **'Start fresh on this device'**
  String get accountStartFresh;

  /// No description provided for @accountMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge into this account'**
  String get accountMerge;

  /// No description provided for @accountSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get accountSignOutTitle;

  /// No description provided for @accountSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your bookmarks, highlights and notes stay safe in your account. Keep a copy on this device?'**
  String get accountSignOutBody;

  /// No description provided for @accountRemoveFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Remove from device'**
  String get accountRemoveFromDevice;

  /// No description provided for @accountKeepOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Keep on device'**
  String get accountKeepOnDevice;

  /// No description provided for @accountSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get accountSyncing;

  /// No description provided for @accountSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync'**
  String get accountSyncFailed;

  /// No description provided for @accountTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to try again'**
  String get accountTapToRetry;

  /// No description provided for @accountSyncPaused.
  ///
  /// In en, this message translates to:
  /// **'Sync paused'**
  String get accountSyncPaused;

  /// No description provided for @accountSyncChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose what to do with this device\'s data'**
  String get accountSyncChoose;

  /// No description provided for @accountSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get accountSyncNow;

  /// No description provided for @accountNotSyncedYet.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get accountNotSyncedYet;

  /// No description provided for @accountSyncedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Synced just now'**
  String get accountSyncedJustNow;

  /// No description provided for @accountSyncedMinAgo.
  ///
  /// In en, this message translates to:
  /// **'Synced {minutes} min ago'**
  String accountSyncedMinAgo(int minutes);

  /// No description provided for @accountSyncedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Synced {hours} h ago'**
  String accountSyncedHoursAgo(int hours);

  /// No description provided for @accountSyncedOn.
  ///
  /// In en, this message translates to:
  /// **'Synced {day}/{month}/{year}'**
  String accountSyncedOn(int day, int month, int year);

  /// No description provided for @accountRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get accountRestoreTitle;

  /// No description provided for @accountRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your backup JSON here...'**
  String get accountRestoreHint;

  /// No description provided for @accountRestoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get accountRestoreAction;

  /// No description provided for @accountResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset app?'**
  String get accountResetTitle;

  /// No description provided for @accountResetBody.
  ///
  /// In en, this message translates to:
  /// **'This erases all on-device data:\n• Bookmarks, highlights, notes & journal\n• Reading plans, progress & custom plans\n• Downloaded translations & streaks\n\nSettings, theme and the offline Bible stay untouched. This cannot be undone — back up first if needed.'**
  String get accountResetBody;

  /// No description provided for @accountResetDone.
  ///
  /// In en, this message translates to:
  /// **'App data reset. Fresh start!'**
  String get accountResetDone;

  /// No description provided for @accountReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get accountReset;

  /// No description provided for @shareBackdrop.
  ///
  /// In en, this message translates to:
  /// **'Backdrop'**
  String get shareBackdrop;

  /// No description provided for @shareBackdropDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get shareBackdropDawn;

  /// No description provided for @shareBackdropDusk.
  ///
  /// In en, this message translates to:
  /// **'Dusk'**
  String get shareBackdropDusk;

  /// No description provided for @shareBackdropArtwork.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get shareBackdropArtwork;

  /// No description provided for @shareBackdropGradient.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get shareBackdropGradient;

  /// No description provided for @shareFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get shareFont;

  /// No description provided for @shareFontTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get shareFontTheme;

  /// No description provided for @shareSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get shareSize;

  /// No description provided for @shareSpacing.
  ///
  /// In en, this message translates to:
  /// **'Spacing'**
  String get shareSpacing;

  /// No description provided for @shareSpacingNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get shareSpacingNormal;

  /// No description provided for @shareSpacingWide.
  ///
  /// In en, this message translates to:
  /// **'Wide {value}'**
  String shareSpacingWide(String value);

  /// No description provided for @shareLineHeight.
  ///
  /// In en, this message translates to:
  /// **'Line height'**
  String get shareLineHeight;

  /// No description provided for @shareAlignment.
  ///
  /// In en, this message translates to:
  /// **'Alignment'**
  String get shareAlignment;

  /// No description provided for @shareAlignCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get shareAlignCenter;

  /// No description provided for @shareAlignLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get shareAlignLeft;

  /// No description provided for @sharePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get sharePreparing;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get shareImage;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Share text'**
  String get shareText;

  /// No description provided for @shareImageCard.
  ///
  /// In en, this message translates to:
  /// **'Share image card'**
  String get shareImageCard;

  /// No description provided for @spaceStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get spaceStorageTitle;

  /// No description provided for @spaceClearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cache?'**
  String get spaceClearCacheTitle;

  /// No description provided for @spaceClearCacheBody.
  ///
  /// In en, this message translates to:
  /// **'Removes temporary files (generated share cards, thumbnails). Your notes, bookmarks, highlights and downloads are untouched.'**
  String get spaceClearCacheBody;

  /// No description provided for @spaceClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get spaceClearCache;

  /// No description provided for @spaceCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get spaceCacheCleared;

  /// No description provided for @spaceDeletePackTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String spaceDeletePackTitle(String name);

  /// No description provided for @spaceDeletePackBundled.
  ///
  /// In en, this message translates to:
  /// **'Frees {size}. You can restore it offline from the app at any time.'**
  String spaceDeletePackBundled(String size);

  /// No description provided for @spaceDeletePackDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Frees {size}. You can download it again later.'**
  String spaceDeletePackDownloaded(String size);

  /// No description provided for @spacePackDeleted.
  ///
  /// In en, this message translates to:
  /// **'{abbr} deleted'**
  String spacePackDeleted(String abbr);

  /// No description provided for @spacePackDownloaded.
  ///
  /// In en, this message translates to:
  /// **'{abbr} downloaded'**
  String spacePackDownloaded(String abbr);

  /// No description provided for @spaceCouldNotFinish.
  ///
  /// In en, this message translates to:
  /// **'Could not finish: {error}'**
  String spaceCouldNotFinish(String error);

  /// No description provided for @spaceFreed.
  ///
  /// In en, this message translates to:
  /// **'{message} · freed {size}'**
  String spaceFreed(String message, String size);

  /// No description provided for @spaceOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get spaceOnThisDevice;

  /// No description provided for @spaceBibleContent.
  ///
  /// In en, this message translates to:
  /// **'Bible content (always kept)'**
  String get spaceBibleContent;

  /// No description provided for @spaceDownloadedPacks.
  ///
  /// In en, this message translates to:
  /// **'Downloaded packs'**
  String get spaceDownloadedPacks;

  /// No description provided for @spaceCache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get spaceCache;

  /// No description provided for @spaceCacheExplain.
  ///
  /// In en, this message translates to:
  /// **'Temporary files only — generated share cards and thumbnails. Safe to clear at any time.'**
  String get spaceCacheExplain;

  /// No description provided for @spaceTranslationsDownloads.
  ///
  /// In en, this message translates to:
  /// **'Translations & downloads'**
  String get spaceTranslationsDownloads;

  /// No description provided for @spaceBundledSuffix.
  ///
  /// In en, this message translates to:
  /// **' · bundled'**
  String get spaceBundledSuffix;

  /// No description provided for @spaceCoreNotRemovable.
  ///
  /// In en, this message translates to:
  /// **'Core KJV and BBE are part of the app and can\'t be removed.'**
  String get spaceCoreNotRemovable;

  /// No description provided for @spaceGet.
  ///
  /// In en, this message translates to:
  /// **'Get'**
  String get spaceGet;

  /// No description provided for @spaceDeletePackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String spaceDeletePackTooltip(String name);

  /// No description provided for @studyCouldNotOpenScreen.
  ///
  /// In en, this message translates to:
  /// **'Could not open that screen. {error}'**
  String studyCouldNotOpenScreen(String error);

  /// No description provided for @studyCardSize.
  ///
  /// In en, this message translates to:
  /// **'Card size'**
  String get studyCardSize;

  /// No description provided for @studyPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get studyPosition;

  /// No description provided for @studySizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get studySizeLarge;

  /// No description provided for @studySizeLargeHint.
  ///
  /// In en, this message translates to:
  /// **'Full width, same size as everything'**
  String get studySizeLargeHint;

  /// No description provided for @studySizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get studySizeExtraLarge;

  /// No description provided for @studySizeExtraLargeHint.
  ///
  /// In en, this message translates to:
  /// **'Full width, roomier content'**
  String get studySizeExtraLargeHint;

  /// No description provided for @studySizeHalf.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get studySizeHalf;

  /// No description provided for @studySizeHalfHint.
  ///
  /// In en, this message translates to:
  /// **'Compact, two per row'**
  String get studySizeHalfHint;

  /// No description provided for @studyMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get studyMoveUp;

  /// No description provided for @studyMoveUpHint.
  ///
  /// In en, this message translates to:
  /// **'Swap with the card above'**
  String get studyMoveUpHint;

  /// No description provided for @studyMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get studyMoveDown;

  /// No description provided for @studyMoveDownHint.
  ///
  /// In en, this message translates to:
  /// **'Swap with the card below'**
  String get studyMoveDownHint;

  /// No description provided for @studyCommentaryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Commentary'**
  String get studyCommentaryEyebrow;

  /// No description provided for @studyCommentaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Verse-by-verse insight'**
  String get studyCommentaryTitle;

  /// No description provided for @studyCommentarySnippet.
  ///
  /// In en, this message translates to:
  /// **'Historicist commentary with chapter + verse filters.'**
  String get studyCommentarySnippet;

  /// No description provided for @studyCommentaryCta.
  ///
  /// In en, this message translates to:
  /// **'Open Commentary'**
  String get studyCommentaryCta;

  /// No description provided for @studyDictionaryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get studyDictionaryEyebrow;

  /// No description provided for @studyDictionaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Words defined'**
  String get studyDictionaryTitle;

  /// No description provided for @studyDictionarySnippet.
  ///
  /// In en, this message translates to:
  /// **'Easton & Smith, offline, with saved words.'**
  String get studyDictionarySnippet;

  /// No description provided for @studyDictionaryCta.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get studyDictionaryCta;

  /// No description provided for @studyStoriesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Bible stories'**
  String get studyStoriesEyebrow;

  /// No description provided for @studyStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Narratives retold'**
  String get studyStoriesTitle;

  /// No description provided for @studyStoriesSnippet.
  ///
  /// In en, this message translates to:
  /// **'66 stories across every book.'**
  String get studyStoriesSnippet;

  /// No description provided for @studyStoriesCta.
  ///
  /// In en, this message translates to:
  /// **'Read stories'**
  String get studyStoriesCta;

  /// No description provided for @studyConcordanceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Concordance'**
  String get studyConcordanceEyebrow;

  /// No description provided for @studyConcordanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Every occurrence'**
  String get studyConcordanceTitle;

  /// No description provided for @studyConcordanceSnippet.
  ///
  /// In en, this message translates to:
  /// **'Find each verse where a word appears.'**
  String get studyConcordanceSnippet;

  /// No description provided for @studyConcordanceCta.
  ///
  /// In en, this message translates to:
  /// **'Search words'**
  String get studyConcordanceCta;

  /// No description provided for @studySpaceSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get studySpaceSaved;

  /// No description provided for @studySpaceMarked.
  ///
  /// In en, this message translates to:
  /// **'Marked'**
  String get studySpaceMarked;

  /// No description provided for @studySpaceNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get studySpaceNotes;

  /// No description provided for @studySpaceJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get studySpaceJournal;

  /// No description provided for @studySpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Space'**
  String get studySpaceTitle;

  /// No description provided for @studySpaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks, highlights, notes & journal'**
  String get studySpaceSubtitle;

  /// No description provided for @studyReadingPlan.
  ///
  /// In en, this message translates to:
  /// **'Reading plan'**
  String get studyReadingPlan;

  /// No description provided for @studyStartReadingPlan.
  ///
  /// In en, this message translates to:
  /// **'Start a reading plan'**
  String get studyStartReadingPlan;

  /// No description provided for @studyActivePlan.
  ///
  /// In en, this message translates to:
  /// **'Active plan'**
  String get studyActivePlan;

  /// No description provided for @studyDayOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Day {current} of {total}'**
  String studyDayOfTotal(int current, int total);

  /// No description provided for @studyDaysBehind.
  ///
  /// In en, this message translates to:
  /// **'{count} behind'**
  String studyDaysBehind(int count);

  /// No description provided for @studyPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get studyPlans;

  /// No description provided for @studyGuidedReading.
  ///
  /// In en, this message translates to:
  /// **'Guided reading'**
  String get studyGuidedReading;

  /// No description provided for @studyGuidedReadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Curated, paced and custom'**
  String get studyGuidedReadingSubtitle;

  /// No description provided for @studyReadyToBegin.
  ///
  /// In en, this message translates to:
  /// **'Ready to begin'**
  String get studyReadyToBegin;

  /// No description provided for @studyTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today: {label}'**
  String studyTodayLabel(String label);

  /// No description provided for @studyReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get studyReview;

  /// No description provided for @studyRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get studyRead;

  /// No description provided for @studyCtaArrow.
  ///
  /// In en, this message translates to:
  /// **'{cta} →'**
  String studyCtaArrow(String cta);

  /// No description provided for @studyWordOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Word of the day'**
  String get studyWordOfTheDay;

  /// No description provided for @studyArchiveLink.
  ///
  /// In en, this message translates to:
  /// **'Archive →'**
  String get studyArchiveLink;

  /// No description provided for @studyLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get studyLoading;

  /// No description provided for @studyUnavailableNow.
  ///
  /// In en, this message translates to:
  /// **'Unavailable right now'**
  String get studyUnavailableNow;

  /// No description provided for @studyReadingStreak.
  ///
  /// In en, this message translates to:
  /// **'Reading streak'**
  String get studyReadingStreak;

  /// No description provided for @studyStartStreak.
  ///
  /// In en, this message translates to:
  /// **'Start your streak'**
  String get studyStartStreak;

  /// No description provided for @studyStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String studyStreakDays(int count);

  /// No description provided for @studyStreakGrow.
  ///
  /// In en, this message translates to:
  /// **'Open daily to grow it.'**
  String get studyStreakGrow;

  /// No description provided for @studyStreakStart.
  ///
  /// In en, this message translates to:
  /// **'Complete a reading each day.'**
  String get studyStreakStart;

  /// No description provided for @studyViewProgress.
  ///
  /// In en, this message translates to:
  /// **'View progress →'**
  String get studyViewProgress;

  /// No description provided for @studyPassageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Passage not found'**
  String get studyPassageNotFound;

  /// No description provided for @studyPassageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load passage data.'**
  String get studyPassageLoadError;

  /// No description provided for @studyCompletedCheck.
  ///
  /// In en, this message translates to:
  /// **'✓ Completed'**
  String get studyCompletedCheck;

  /// No description provided for @studyMarkAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get studyMarkAsRead;

  /// No description provided for @studyNextPassage.
  ///
  /// In en, this message translates to:
  /// **'Next Passage'**
  String get studyNextPassage;

  /// No description provided for @studyFullChapter.
  ///
  /// In en, this message translates to:
  /// **'Full chapter'**
  String get studyFullChapter;

  /// No description provided for @studyPassageOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Passage {current} of {total}'**
  String studyPassageOfTotal(int current, int total);

  /// No description provided for @studySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String studySelectedCount(int count);

  /// No description provided for @studyHighlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get studyHighlight;

  /// No description provided for @studyBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get studyBookmark;

  /// No description provided for @studyAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get studyAddNote;

  /// No description provided for @studyChaptersWithContent.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter with content} other{{count} chapters with content}}'**
  String studyChaptersWithContent(int count);

  /// No description provided for @studyCommentaryLibrary.
  ///
  /// In en, this message translates to:
  /// **'Commentary Library'**
  String get studyCommentaryLibrary;

  /// No description provided for @studyCommentaryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load commentary.'**
  String get studyCommentaryLoadError;

  /// No description provided for @studyNoCommentaryYet.
  ///
  /// In en, this message translates to:
  /// **'No commentary available yet.'**
  String get studyNoCommentaryYet;

  /// No description provided for @studyNoBooksMatch.
  ///
  /// In en, this message translates to:
  /// **'No books match \"{query}\".'**
  String studyNoBooksMatch(String query);

  /// No description provided for @studySearchBooksCount.
  ///
  /// In en, this message translates to:
  /// **'Search {count} books…'**
  String studySearchBooksCount(int count);

  /// No description provided for @studyClassicSources.
  ///
  /// In en, this message translates to:
  /// **'Classic sources'**
  String get studyClassicSources;

  /// No description provided for @studyBookAuthorChapters.
  ///
  /// In en, this message translates to:
  /// **'{author} · {count} ch'**
  String studyBookAuthorChapters(String author, int count);

  /// No description provided for @studyReadingRef.
  ///
  /// In en, this message translates to:
  /// **'Reading · {reference}'**
  String studyReadingRef(String reference);

  /// No description provided for @studyAllSources.
  ///
  /// In en, this message translates to:
  /// **'All sources'**
  String get studyAllSources;

  /// No description provided for @studyVerseLevel.
  ///
  /// In en, this message translates to:
  /// **'Verse-level'**
  String get studyVerseLevel;

  /// No description provided for @studySearchWithin.
  ///
  /// In en, this message translates to:
  /// **'Search within {reference}…'**
  String studySearchWithin(String reference);

  /// No description provided for @studyEntriesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load entries.\n{error}'**
  String studyEntriesLoadError(String error);

  /// No description provided for @studyNoEntriesMatch.
  ///
  /// In en, this message translates to:
  /// **'No entries match these filters.\nTry All sources, or browse the library.'**
  String get studyNoEntriesMatch;

  /// No description provided for @studyVerseN.
  ///
  /// In en, this message translates to:
  /// **'Verse {verse}'**
  String studyVerseN(int verse);

  /// No description provided for @studyChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get studyChapter;

  /// No description provided for @studyCategoryCommentary.
  ///
  /// In en, this message translates to:
  /// **'Commentary'**
  String get studyCategoryCommentary;

  /// No description provided for @studyCategoryDevotional.
  ///
  /// In en, this message translates to:
  /// **'Devotional'**
  String get studyCategoryDevotional;

  /// No description provided for @studyCategoryStudyNote.
  ///
  /// In en, this message translates to:
  /// **'Study Note'**
  String get studyCategoryStudyNote;

  /// No description provided for @studyCommentaryLoadErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Could not load commentary.\n{error}'**
  String studyCommentaryLoadErrorDetail(String error);

  /// No description provided for @studyNoContentForFilters.
  ///
  /// In en, this message translates to:
  /// **'No content found for these filters.'**
  String get studyNoContentForFilters;

  /// No description provided for @studyVerseLabel.
  ///
  /// In en, this message translates to:
  /// **'Verse {verse}'**
  String studyVerseLabel(String verse);

  /// No description provided for @studyChapterView.
  ///
  /// In en, this message translates to:
  /// **'Chapter View'**
  String get studyChapterView;

  /// No description provided for @studyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get studyFilterAll;

  /// No description provided for @studyFilterDevotionals.
  ///
  /// In en, this message translates to:
  /// **'Devotionals'**
  String get studyFilterDevotionals;

  /// No description provided for @studyFilterAllContexts.
  ///
  /// In en, this message translates to:
  /// **'All Contexts'**
  String get studyFilterAllContexts;

  /// No description provided for @studyFilterChapterLevel.
  ///
  /// In en, this message translates to:
  /// **'Chapter Level'**
  String get studyFilterChapterLevel;

  /// No description provided for @studyFilterVerseLevel.
  ///
  /// In en, this message translates to:
  /// **'Verse Level'**
  String get studyFilterVerseLevel;

  /// No description provided for @studyRemoveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove Bookmark'**
  String get studyRemoveBookmark;

  /// No description provided for @studyBookmarkCommentary.
  ///
  /// In en, this message translates to:
  /// **'Bookmark Commentary'**
  String get studyBookmarkCommentary;

  /// No description provided for @studyExpandFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Expand to full screen'**
  String get studyExpandFullScreen;

  /// No description provided for @studyTapToReadInContext.
  ///
  /// In en, this message translates to:
  /// **'Tap to read in context'**
  String get studyTapToReadInContext;

  /// No description provided for @studyOnThisChapter.
  ///
  /// In en, this message translates to:
  /// **'On this chapter'**
  String get studyOnThisChapter;

  /// No description provided for @studyOnThisBook.
  ///
  /// In en, this message translates to:
  /// **'On this book'**
  String get studyOnThisBook;

  /// No description provided for @studyNoCommentaryTitle.
  ///
  /// In en, this message translates to:
  /// **'No commentary yet'**
  String get studyNoCommentaryTitle;

  /// No description provided for @studyNoCommentaryBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find specific commentary for this passage. Try exploring the chapter or book-level commentary below.'**
  String get studyNoCommentaryBody;

  /// No description provided for @storiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Bible Stories'**
  String get storiesTitle;

  /// No description provided for @storiesFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get storiesFilters;

  /// No description provided for @storiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'500 illustrated moments from Genesis to Revelation'**
  String get storiesSubtitle;

  /// No description provided for @storiesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, book, or reference…'**
  String get storiesSearchHint;

  /// No description provided for @storiesClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get storiesClearSearch;

  /// No description provided for @storiesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get storiesFilterAll;

  /// No description provided for @storiesFilterOt.
  ///
  /// In en, this message translates to:
  /// **'OT'**
  String get storiesFilterOt;

  /// No description provided for @storiesFilterNt.
  ///
  /// In en, this message translates to:
  /// **'NT'**
  String get storiesFilterNt;

  /// No description provided for @storiesCountOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} stories'**
  String storiesCountOfTotal(int count, int total);

  /// No description provided for @storiesFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get storiesFavorites;

  /// No description provided for @storiesUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get storiesUnread;

  /// No description provided for @storiesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load stories:\n{error}'**
  String storiesLoadError(String error);

  /// No description provided for @storiesBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get storiesBooks;

  /// No description provided for @storiesSearchBooks.
  ///
  /// In en, this message translates to:
  /// **'Search books…'**
  String get storiesSearchBooks;

  /// No description provided for @storiesAllBooks.
  ///
  /// In en, this message translates to:
  /// **'All books'**
  String get storiesAllBooks;

  /// No description provided for @storiesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No stories match these filters.'**
  String get storiesNoMatch;

  /// No description provided for @storiesNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.'**
  String get storiesNoFavorites;

  /// No description provided for @storiesBrowseAll.
  ///
  /// In en, this message translates to:
  /// **'Browse all stories'**
  String get storiesBrowseAll;

  /// No description provided for @storiesAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get storiesAllCaughtUp;

  /// No description provided for @storiesShowRead.
  ///
  /// In en, this message translates to:
  /// **'Show read stories'**
  String get storiesShowRead;

  /// No description provided for @storiesClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get storiesClearFilters;

  /// No description provided for @storiesFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap ♥ on any story to save it here.'**
  String get storiesFavoritesHint;

  /// No description provided for @storiesAttribution.
  ///
  /// In en, this message translates to:
  /// **'Scripture from the King James Version (public domain). Narrative summaries adapted from The Graham Bible (grahambible.com), AI-assisted and human reviewed. Artwork: Gustave Doré (1832–1883), public domain, via Wikimedia Commons.'**
  String get storiesAttribution;

  /// No description provided for @storiesReachedEnd.
  ///
  /// In en, this message translates to:
  /// **'You have reached the end.'**
  String get storiesReachedEnd;

  /// No description provided for @storiesFirstStory.
  ///
  /// In en, this message translates to:
  /// **'This is the first story.'**
  String get storiesFirstStory;

  /// No description provided for @storiesFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get storiesFavorite;

  /// No description provided for @storiesMarkAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get storiesMarkAsRead;

  /// No description provided for @storiesKeyVerse.
  ///
  /// In en, this message translates to:
  /// **'KEY VERSE · {reference}'**
  String storiesKeyVerse(String reference);

  /// No description provided for @storiesTheStory.
  ///
  /// In en, this message translates to:
  /// **'THE STORY'**
  String get storiesTheStory;

  /// No description provided for @storiesArtworkCaption.
  ///
  /// In en, this message translates to:
  /// **'Artwork: {caption} — Gustave Doré, public domain'**
  String storiesArtworkCaption(String caption);

  /// No description provided for @storiesPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous story'**
  String get storiesPrevious;

  /// No description provided for @storiesNext.
  ///
  /// In en, this message translates to:
  /// **'Next story'**
  String get storiesNext;

  /// No description provided for @studyDictionarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search 3,400+ words…'**
  String get studyDictionarySearchHint;

  /// No description provided for @studyDictionarySavedFilter.
  ///
  /// In en, this message translates to:
  /// **'★ Saved'**
  String get studyDictionarySavedFilter;

  /// No description provided for @studyDictionaryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dictionary unavailable.\n{error}'**
  String studyDictionaryUnavailable(String error);

  /// No description provided for @studyNoHeadwords.
  ///
  /// In en, this message translates to:
  /// **'No headwords found.'**
  String get studyNoHeadwords;

  /// No description provided for @studyDictionaryNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches. Try “grace”, “atonement” or “wilderness”.'**
  String get studyDictionaryNoMatches;

  /// No description provided for @studyResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String studyResultCount(int count);

  /// No description provided for @studyUntitledEntry.
  ///
  /// In en, this message translates to:
  /// **'(untitled entry)'**
  String get studyUntitledEntry;

  /// No description provided for @studyRemoveSavedWord.
  ///
  /// In en, this message translates to:
  /// **'Remove saved word'**
  String get studyRemoveSavedWord;

  /// No description provided for @studySaveWord.
  ///
  /// In en, this message translates to:
  /// **'Save word'**
  String get studySaveWord;

  /// No description provided for @studyNoDefinition.
  ///
  /// In en, this message translates to:
  /// **'No definition found.'**
  String get studyNoDefinition;

  /// No description provided for @studyFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String studyFailedToLoad(String error);

  /// No description provided for @studyStrongsShareText.
  ///
  /// In en, this message translates to:
  /// **'{id} - {lemma}\n\nTransliteration: {transliteration}\nPronunciation: {pronunciation}\n\nDefinition:\n{definition}'**
  String studyStrongsShareText(String id, String lemma, String transliteration,
      String pronunciation, String definition);

  /// No description provided for @studyNoStrongsEntry.
  ///
  /// In en, this message translates to:
  /// **'No entry found for {id}.'**
  String studyNoStrongsEntry(String id);

  /// No description provided for @studyStrongsLexicon.
  ///
  /// In en, this message translates to:
  /// **'STRONG\'S LEXICON'**
  String get studyStrongsLexicon;

  /// No description provided for @studyConcordanceHint.
  ///
  /// In en, this message translates to:
  /// **'Type a word (e.g., grace, covenant)…'**
  String get studyConcordanceHint;

  /// No description provided for @studyConcordanceIntro.
  ///
  /// In en, this message translates to:
  /// **'KJV occurrences — tap a verse to read it in context.'**
  String get studyConcordanceIntro;

  /// No description provided for @studyConcordanceEmpty.
  ///
  /// In en, this message translates to:
  /// **'Every verse containing your word, in canonical order.'**
  String get studyConcordanceEmpty;

  /// No description provided for @studyConcordanceSingleWord.
  ///
  /// In en, this message translates to:
  /// **'Enter a single English word to search.'**
  String get studyConcordanceSingleWord;

  /// No description provided for @studyConcordanceNoVerses.
  ///
  /// In en, this message translates to:
  /// **'No verses contain \"{word}\".'**
  String studyConcordanceNoVerses(String word);

  /// No description provided for @studyConcordanceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 verse} other{{count} verses}}'**
  String studyConcordanceCount(int count);

  /// No description provided for @studyConcordanceCountTruncated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 verse} other{{count} verses}} (first {limit} shown)'**
  String studyConcordanceCountTruncated(int count, int limit);

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits & sources'**
  String get creditsTitle;

  /// No description provided for @creditsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get creditsLicenses;

  /// No description provided for @creditsLicensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fonts and software packages'**
  String get creditsLicensesSubtitle;

  /// No description provided for @studyPreparingOfflineBible.
  ///
  /// In en, this message translates to:
  /// **'Preparing offline Bible… {percent}%'**
  String studyPreparingOfflineBible(int percent);

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In en, this message translates to:
  /// **'An unexpected issue occurred. Tap below to return to the home screen.'**
  String get errorBody;

  /// No description provided for @errorBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get errorBackHome;

  /// No description provided for @studyWeekN.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String studyWeekN(int week);

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the privacy policy.'**
  String get privacyLoadError;

  /// No description provided for @privacyEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: {date}'**
  String privacyEffectiveDate(String date);

  /// No description provided for @privacyEnglishOnly.
  ///
  /// In en, this message translates to:
  /// **'This policy is provided in English.'**
  String get privacyEnglishOnly;

  /// No description provided for @privacyViewOnline.
  ///
  /// In en, this message translates to:
  /// **'View online'**
  String get privacyViewOnline;
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
