import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rosa'**
  String get appTitle;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get tabTrack;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get tabStats;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String loadFailed(String error);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextStep;

  /// No description provided for @prevStep.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get prevStep;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @pressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit'**
  String get pressAgainToExit;

  /// No description provided for @currentCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Cycle'**
  String get currentCycleTitle;

  /// No description provided for @howAreYouToday.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouToday;

  /// No description provided for @periodDayN.
  ///
  /// In en, this message translates to:
  /// **'Period · Day {n}'**
  String periodDayN(int n);

  /// No description provided for @yourNextPeriodIs.
  ///
  /// In en, this message translates to:
  /// **'Your next period is on'**
  String get yourNextPeriodIs;

  /// No description provided for @daysUntilNextPeriod.
  ///
  /// In en, this message translates to:
  /// **'days until your next period'**
  String get daysUntilNextPeriod;

  /// No description provided for @possibleFertileDays.
  ///
  /// In en, this message translates to:
  /// **'Possible fertile days'**
  String get possibleFertileDays;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one {{n} day} other {{n} days}}'**
  String daysCount(int n);

  /// No description provided for @backToTodayHint.
  ///
  /// In en, this message translates to:
  /// **'Tap empty ring to return to today'**
  String get backToTodayHint;

  /// No description provided for @dayUnitShort.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get dayUnitShort;

  /// No description provided for @predictedChip.
  ///
  /// In en, this message translates to:
  /// **'Predicted'**
  String get predictedChip;

  /// No description provided for @confirmedChip.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmedChip;

  /// No description provided for @predictedPeriodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'±{n} days from last prediction (predicted)'**
  String predictedPeriodSubtitle(int n);

  /// No description provided for @ovulationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today is the center of your fertile window (predicted)'**
  String get ovulationSubtitle;

  /// No description provided for @fertileWindowSubtitleToday.
  ///
  /// In en, this message translates to:
  /// **'Ovulation expected today'**
  String get fertileWindowSubtitleToday;

  /// No description provided for @fertileWindowSubtitleInDays.
  ///
  /// In en, this message translates to:
  /// **'Ovulation expected in {n} days'**
  String fertileWindowSubtitleInDays(int n);

  /// No description provided for @normalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{n} days until next period'**
  String normalSubtitle(int n);

  /// No description provided for @fertileWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get fertileWindowLabel;

  /// No description provided for @predictedOvulationLabel.
  ///
  /// In en, this message translates to:
  /// **'Predicted ovulation day'**
  String get predictedOvulationLabel;

  /// No description provided for @fertileDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The fertile window includes the days before and the possible ovulation day. It is only an estimate and should not be used for contraception or trying to conceive.'**
  String get fertileDisclaimer;

  /// No description provided for @prevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get prevMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get backToToday;

  /// No description provided for @legendPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get legendPeriod;

  /// No description provided for @legendPredictedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Predicted period'**
  String get legendPredictedPeriod;

  /// No description provided for @legendFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get legendFertileWindow;

  /// No description provided for @legendOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get legendOvulation;

  /// No description provided for @categoryPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get categoryPeriod;

  /// No description provided for @categorySymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get categorySymptoms;

  /// No description provided for @categoryMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get categoryMood;

  /// No description provided for @categorySex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get categorySex;

  /// No description provided for @categoryMetrics.
  ///
  /// In en, this message translates to:
  /// **'Body metrics'**
  String get categoryMetrics;

  /// No description provided for @categoryNote.
  ///
  /// In en, this message translates to:
  /// **'Daily note'**
  String get categoryNote;

  /// No description provided for @categoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Category filter'**
  String get categoryFilter;

  /// No description provided for @categoryFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Turn categories on or off to filter your view. Hold and drag a category to reorder.'**
  String get categoryFilterHint;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @flowVeryHeavy.
  ///
  /// In en, this message translates to:
  /// **'Very heavy'**
  String get flowVeryHeavy;

  /// No description provided for @symptomAbdominalPain.
  ///
  /// In en, this message translates to:
  /// **'Abdominal pain'**
  String get symptomAbdominalPain;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomBreastTenderness.
  ///
  /// In en, this message translates to:
  /// **'Breast tenderness'**
  String get symptomBreastTenderness;

  /// No description provided for @symptomMoodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get symptomMoodSwings;

  /// No description provided for @symptomInsomnia.
  ///
  /// In en, this message translates to:
  /// **'Insomnia'**
  String get symptomInsomnia;

  /// No description provided for @symptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomAcne;

  /// No description provided for @symptomLowerBackPain.
  ///
  /// In en, this message translates to:
  /// **'Lower back pain'**
  String get symptomLowerBackPain;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get moodLow;

  /// No description provided for @moodIrritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get moodIrritable;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodSensitive.
  ///
  /// In en, this message translates to:
  /// **'Sensitive'**
  String get moodSensitive;

  /// No description provided for @moodTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get moodTired;

  /// No description provided for @sexProtected.
  ///
  /// In en, this message translates to:
  /// **'Protected sex'**
  String get sexProtected;

  /// No description provided for @sexUnprotected.
  ///
  /// In en, this message translates to:
  /// **'Unprotected sex'**
  String get sexUnprotected;

  /// No description provided for @sexWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get sexWithdrawal;

  /// No description provided for @sexNoSex.
  ///
  /// In en, this message translates to:
  /// **'No sex today'**
  String get sexNoSex;

  /// No description provided for @sexOrgasm.
  ///
  /// In en, this message translates to:
  /// **'Orgasm'**
  String get sexOrgasm;

  /// No description provided for @sexNoOrgasm.
  ///
  /// In en, this message translates to:
  /// **'No orgasm'**
  String get sexNoOrgasm;

  /// No description provided for @sexFantasy.
  ///
  /// In en, this message translates to:
  /// **'Sexual fantasy'**
  String get sexFantasy;

  /// No description provided for @sexPainfulSex.
  ///
  /// In en, this message translates to:
  /// **'Painful sex'**
  String get sexPainfulSex;

  /// No description provided for @sexHighLibido.
  ///
  /// In en, this message translates to:
  /// **'High libido'**
  String get sexHighLibido;

  /// No description provided for @sexLowLibido.
  ///
  /// In en, this message translates to:
  /// **'Low libido'**
  String get sexLowLibido;

  /// No description provided for @sexMasturbation.
  ///
  /// In en, this message translates to:
  /// **'Masturbation'**
  String get sexMasturbation;

  /// No description provided for @metricWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get metricWeight;

  /// No description provided for @metricTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get metricTemperature;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight kg'**
  String get weightKg;

  /// No description provided for @tempC.
  ///
  /// In en, this message translates to:
  /// **'Temperature ℃'**
  String get tempC;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Any other details to add today?'**
  String get noteHint;

  /// No description provided for @autoSaveHint.
  ///
  /// In en, this message translates to:
  /// **'Changes save instantly'**
  String get autoSaveHint;

  /// No description provided for @allCategoriesOff.
  ///
  /// In en, this message translates to:
  /// **'All categories are off. Tap the filter icon to enable.'**
  String get allCategoriesOff;

  /// No description provided for @chooseYear.
  ///
  /// In en, this message translates to:
  /// **'Choose year'**
  String get chooseYear;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @last6Cycles.
  ///
  /// In en, this message translates to:
  /// **'Last 6 cycles'**
  String get last6Cycles;

  /// No description provided for @avgCycle.
  ///
  /// In en, this message translates to:
  /// **'Average cycle'**
  String get avgCycle;

  /// No description provided for @avgPeriod.
  ///
  /// In en, this message translates to:
  /// **'Average period'**
  String get avgPeriod;

  /// No description provided for @dayUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get dayUnit;

  /// No description provided for @cycleLengthTrend.
  ///
  /// In en, this message translates to:
  /// **'Cycle length trend'**
  String get cycleLengthTrend;

  /// No description provided for @statsHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: more data means more accurate predictions; log complete cycles.'**
  String get statsHint;

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log 1–2 complete cycles to see trends'**
  String get statsEmpty;

  /// No description provided for @statsOverview.
  ///
  /// In en, this message translates to:
  /// **'Record overview'**
  String get statsOverview;

  /// No description provided for @trackedDays.
  ///
  /// In en, this message translates to:
  /// **'Tracked days'**
  String get trackedDays;

  /// No description provided for @periodDays.
  ///
  /// In en, this message translates to:
  /// **'Period days'**
  String get periodDays;

  /// No description provided for @symptomDays.
  ///
  /// In en, this message translates to:
  /// **'Symptom days'**
  String get symptomDays;

  /// No description provided for @moodDays.
  ///
  /// In en, this message translates to:
  /// **'Mood days'**
  String get moodDays;

  /// No description provided for @sexDays.
  ///
  /// In en, this message translates to:
  /// **'Sex days'**
  String get sexDays;

  /// No description provided for @metricDays.
  ///
  /// In en, this message translates to:
  /// **'Metric days'**
  String get metricDays;

  /// No description provided for @symptomFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequent symptoms'**
  String get symptomFrequency;

  /// No description provided for @moodDistribution.
  ///
  /// In en, this message translates to:
  /// **'Mood distribution'**
  String get moodDistribution;

  /// No description provided for @weightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight trend'**
  String get weightTrend;

  /// No description provided for @tempTrend.
  ///
  /// In en, this message translates to:
  /// **'Temperature trend'**
  String get tempTrend;

  /// No description provided for @noTrackingData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noTrackingData;

  /// No description provided for @metricRangeStats.
  ///
  /// In en, this message translates to:
  /// **'Min {min} · Max {max} · Avg {avg}'**
  String metricRangeStats(String min, String max, String avg);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @customizeTracking.
  ///
  /// In en, this message translates to:
  /// **'Customize tracking'**
  String get customizeTracking;

  /// No description provided for @customizeTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Category switches and order'**
  String get customizeTrackingSubtitle;

  /// No description provided for @cyclePersonalization.
  ///
  /// In en, this message translates to:
  /// **'Cycle personalization'**
  String get cyclePersonalization;

  /// No description provided for @cyclePersonalizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ovulation / fertile window display'**
  String get cyclePersonalizationSubtitle;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'JSON merge & dedupe'**
  String get importDataSubtitle;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto backup'**
  String get autoBackup;

  /// No description provided for @autoBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Silently export JSON on exit'**
  String get autoBackupSubtitle;

  /// No description provided for @backupDir.
  ///
  /// In en, this message translates to:
  /// **'Backup folder'**
  String get backupDir;

  /// No description provided for @backupDirNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected (tap to choose and authorize)'**
  String get backupDirNotSelected;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupNow;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @exportJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full data → clipboard'**
  String get exportJsonSubtitle;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAllData;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local-first storage · export/delete anytime'**
  String get privacyPolicySubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageSystem;

  /// No description provided for @languageZh.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageZh;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'{label} saved'**
  String exportSaved(String label);

  /// No description provided for @exportSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} in total'**
  String exportSavedCount(String count);

  /// No description provided for @exportCopyHint.
  ///
  /// In en, this message translates to:
  /// **'Copy the content to send it to others.'**
  String get exportCopyHint;

  /// No description provided for @shareSaveToSystem.
  ///
  /// In en, this message translates to:
  /// **'Share / Save to system'**
  String get shareSaveToSystem;

  /// No description provided for @copyContent.
  ///
  /// In en, this message translates to:
  /// **'Copy content'**
  String get copyContent;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Content copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @exportShareText.
  ///
  /// In en, this message translates to:
  /// **'Period tracking data export ({label})'**
  String exportShareText(String label);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @importErrorJsonParse.
  ///
  /// In en, this message translates to:
  /// **'JSON parse failed. Select a valid export file.'**
  String get importErrorJsonParse;

  /// No description provided for @importErrorInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON format.'**
  String get importErrorInvalidJson;

  /// No description provided for @importErrorSchemaMismatch.
  ///
  /// In en, this message translates to:
  /// **'Schema version mismatch: import is {imported}, current is {current}'**
  String importErrorSchemaMismatch(String imported, String current);

  /// No description provided for @importErrorMissingData.
  ///
  /// In en, this message translates to:
  /// **'Missing data root node.'**
  String get importErrorMissingData;

  /// No description provided for @importErrorInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Unparseable date field.'**
  String get importErrorInvalidDate;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get importDone;

  /// No description provided for @importSummary.
  ///
  /// In en, this message translates to:
  /// **'{inserted} added · {skipped} skipped'**
  String importSummary(int inserted, int skipped);

  /// No description provided for @addedCount.
  ///
  /// In en, this message translates to:
  /// **'Added {n}'**
  String addedCount(int n);

  /// No description provided for @skippedCount.
  ///
  /// In en, this message translates to:
  /// **'Skipped {n}'**
  String skippedCount(int n);

  /// No description provided for @importSkippedHint.
  ///
  /// In en, this message translates to:
  /// **'Skipped = same unique key already exists locally and is kept as-is.'**
  String get importSkippedHint;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @backupDone.
  ///
  /// In en, this message translates to:
  /// **'Backup complete'**
  String get backupDone;

  /// No description provided for @backupShareText.
  ///
  /// In en, this message translates to:
  /// **'Period tracking backup'**
  String get backupShareText;

  /// No description provided for @shareSaveAs.
  ///
  /// In en, this message translates to:
  /// **'Share / Save as'**
  String get shareSaveAs;

  /// No description provided for @clearAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all data?'**
  String get clearAllConfirmTitle;

  /// No description provided for @clearAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes all period records, symptoms, moods and predictions on this device, and cannot be undone.'**
  String get clearAllConfirmBody;

  /// No description provided for @clearedAllData.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get clearedAllData;

  /// No description provided for @tablePeriodDays.
  ///
  /// In en, this message translates to:
  /// **'Period records'**
  String get tablePeriodDays;

  /// No description provided for @tableSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get tableSymptoms;

  /// No description provided for @tableBodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Body metrics'**
  String get tableBodyMetrics;

  /// No description provided for @tableMoods.
  ///
  /// In en, this message translates to:
  /// **'Moods'**
  String get tableMoods;

  /// No description provided for @tablePredictions.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get tablePredictions;

  /// No description provided for @charsCount.
  ///
  /// In en, this message translates to:
  /// **'{n} chars'**
  String charsCount(int n);

  /// No description provided for @displaySection.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displaySection;

  /// No description provided for @showOvulation.
  ///
  /// In en, this message translates to:
  /// **'Show ovulation'**
  String get showOvulation;

  /// No description provided for @showFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Show fertile window'**
  String get showFertileWindow;

  /// No description provided for @restoreDefault.
  ///
  /// In en, this message translates to:
  /// **'Restore default'**
  String get restoreDefault;

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get recordTitle;

  /// No description provided for @recordDate.
  ///
  /// In en, this message translates to:
  /// **'Record date'**
  String get recordDate;

  /// No description provided for @stepPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get stepPeriod;

  /// No description provided for @stepFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get stepFlow;

  /// No description provided for @stepSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get stepSymptoms;

  /// No description provided for @stepMetrics.
  ///
  /// In en, this message translates to:
  /// **'Metrics'**
  String get stepMetrics;

  /// No description provided for @stepMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get stepMood;

  /// No description provided for @stepPeriodHint.
  ///
  /// In en, this message translates to:
  /// **'Are you on your period this day?'**
  String get stepPeriodHint;

  /// No description provided for @stepFlowHint.
  ///
  /// In en, this message translates to:
  /// **'How heavy is the bleeding?'**
  String get stepFlowHint;

  /// No description provided for @stepSymptomsHint.
  ///
  /// In en, this message translates to:
  /// **'Which symptoms do you have?'**
  String get stepSymptomsHint;

  /// No description provided for @stepMetricsHint.
  ///
  /// In en, this message translates to:
  /// **'Body metrics (optional)'**
  String get stepMetricsHint;

  /// No description provided for @stepMoodHint.
  ///
  /// In en, this message translates to:
  /// **'How do you feel?'**
  String get stepMoodHint;

  /// No description provided for @yesPeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Yes, period today'**
  String get yesPeriodToday;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @weightKgOptional.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg, optional)'**
  String get weightKgOptional;

  /// No description provided for @tempCOptional.
  ///
  /// In en, this message translates to:
  /// **'Basal temperature (℃, optional)'**
  String get tempCOptional;

  /// No description provided for @recordSaved.
  ///
  /// In en, this message translates to:
  /// **'Record saved'**
  String get recordSaved;

  /// No description provided for @recordFlowSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get recordFlowSpotting;

  /// No description provided for @recordFlowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get recordFlowLight;

  /// No description provided for @recordFlowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get recordFlowMedium;

  /// No description provided for @recordFlowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get recordFlowHeavy;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync & account'**
  String get accountTitle;

  /// No description provided for @currentMode.
  ///
  /// In en, this message translates to:
  /// **'Current mode'**
  String get currentMode;

  /// No description provided for @localFreeMode.
  ///
  /// In en, this message translates to:
  /// **'Local mode · full features free'**
  String get localFreeMode;

  /// No description provided for @accountId.
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get accountId;

  /// No description provided for @anonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Anonymous user #{id}'**
  String anonymousUser(String id);

  /// No description provided for @noLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'No login required'**
  String get noLoginRequired;

  /// No description provided for @accountPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'For privacy first, this version does not sync to the cloud. All period, symptom, mood and prediction data stays on this device. To migrate, use “Export JSON” then “Import data” on the new device.'**
  String get accountPrivacyBody;

  /// No description provided for @accountMigrateHint.
  ///
  /// In en, this message translates to:
  /// **'To migrate, return to “More” and use “Export / Import”.'**
  String get accountMigrateHint;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Local-first storage'**
  String get privacyLocalTitle;

  /// No description provided for @privacyLocalBody.
  ///
  /// In en, this message translates to:
  /// **'All period, symptom, mood and prediction data stays only in this device\'s database. Nothing is uploaded, with no ad tracking or third-party sharing.'**
  String get privacyLocalBody;

  /// No description provided for @privacyEncryptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted storage'**
  String get privacyEncryptedTitle;

  /// No description provided for @privacyEncryptedBody.
  ///
  /// In en, this message translates to:
  /// **'The database is protected by an encryption scheme whose key is held in system secure storage (iOS Keychain / Android Keystore); day-to-day data is only decrypted on device.'**
  String get privacyEncryptedBody;

  /// No description provided for @privacyClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Controlled deletion'**
  String get privacyClearTitle;

  /// No description provided for @privacyClearBody.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all local records under “Clear all data”. Deletion cannot be undone, so export a backup first.'**
  String get privacyClearBody;

  /// No description provided for @privacyMigrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Migrate anytime'**
  String get privacyMigrateTitle;

  /// No description provided for @privacyMigrateBody.
  ///
  /// In en, this message translates to:
  /// **'Export as JSON and save or share it, then import on a new device to merge, dedupe and restore.'**
  String get privacyMigrateBody;

  /// No description provided for @placeholderModule.
  ///
  /// In en, this message translates to:
  /// **'The “{title}” module will be implemented in a later stage'**
  String placeholderModule(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
