// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rosa';

  @override
  String get tabToday => 'Today';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabTrack => 'Track';

  @override
  String get tabStats => 'Analysis';

  @override
  String get tabMore => 'More';

  @override
  String loadFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get delete => 'Delete';

  @override
  String get import => 'Import';

  @override
  String get save => 'Save';

  @override
  String get nextStep => 'Next';

  @override
  String get prevStep => 'Back';

  @override
  String get confirm => 'Confirm';

  @override
  String get pressAgainToExit => 'Press again to exit';

  @override
  String get currentCycleTitle => 'Current Cycle';

  @override
  String get howAreYouToday => 'How are you feeling today?';

  @override
  String periodDayN(int n) {
    return 'Period · Day $n';
  }

  @override
  String get yourNextPeriodIs => 'Your next period is on';

  @override
  String get daysUntilNextPeriod => 'days until your next period';

  @override
  String get possibleFertileDays => 'Possible fertile days';

  @override
  String daysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '$n day',
    );
    return '$_temp0';
  }

  @override
  String get backToTodayHint => 'Tap empty ring to return to today';

  @override
  String get dayUnitShort => 'day';

  @override
  String get predictedChip => 'Predicted';

  @override
  String get confirmedChip => 'Confirmed';

  @override
  String predictedPeriodSubtitle(int n) {
    return '±$n days from last prediction (predicted)';
  }

  @override
  String get ovulationSubtitle =>
      'Today is the center of your fertile window (predicted)';

  @override
  String get fertileWindowSubtitleToday => 'Ovulation expected today';

  @override
  String fertileWindowSubtitleInDays(int n) {
    return 'Ovulation expected in $n days';
  }

  @override
  String normalSubtitle(int n) {
    return '$n days until next period';
  }

  @override
  String get fertileWindowLabel => 'Fertile window';

  @override
  String get predictedOvulationLabel => 'Predicted ovulation day';

  @override
  String get fertileDisclaimer =>
      'The fertile window includes the days before and the possible ovulation day. It is only an estimate and should not be used for contraception or trying to conceive.';

  @override
  String get prevMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get backToToday => 'Back to today';

  @override
  String get legendPeriod => 'Period';

  @override
  String get legendPredictedPeriod => 'Predicted period';

  @override
  String get legendFertileWindow => 'Fertile window';

  @override
  String get legendOvulation => 'Ovulation';

  @override
  String get categoryPeriod => 'Period';

  @override
  String get categorySymptoms => 'Symptoms';

  @override
  String get categoryMood => 'Mood';

  @override
  String get categorySex => 'Sex';

  @override
  String get categoryMetrics => 'Body metrics';

  @override
  String get categoryNote => 'Daily note';

  @override
  String get categoryFilter => 'Category filter';

  @override
  String get categoryFilterHint =>
      'Turn categories on or off to filter your view. Hold and drag a category to reorder.';

  @override
  String get allCategories => 'All categories';

  @override
  String get flowLight => 'Light';

  @override
  String get flowMedium => 'Medium';

  @override
  String get flowHeavy => 'Heavy';

  @override
  String get flowVeryHeavy => 'Very heavy';

  @override
  String get symptomAbdominalPain => 'Abdominal pain';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomBreastTenderness => 'Breast tenderness';

  @override
  String get symptomMoodSwings => 'Mood swings';

  @override
  String get symptomInsomnia => 'Insomnia';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomLowerBackPain => 'Lower back pain';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodLow => 'Low';

  @override
  String get moodIrritable => 'Irritable';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodSensitive => 'Sensitive';

  @override
  String get moodTired => 'Tired';

  @override
  String get sexProtected => 'Protected sex';

  @override
  String get sexUnprotected => 'Unprotected sex';

  @override
  String get sexWithdrawal => 'Withdrawal';

  @override
  String get sexNoSex => 'No sex today';

  @override
  String get sexOrgasm => 'Orgasm';

  @override
  String get sexNoOrgasm => 'No orgasm';

  @override
  String get sexFantasy => 'Sexual fantasy';

  @override
  String get sexPainfulSex => 'Painful sex';

  @override
  String get sexHighLibido => 'High libido';

  @override
  String get sexLowLibido => 'Low libido';

  @override
  String get sexMasturbation => 'Masturbation';

  @override
  String get metricWeight => 'Weight';

  @override
  String get metricTemperature => 'Temperature';

  @override
  String get weightKg => 'Weight kg';

  @override
  String get tempC => 'Temperature ℃';

  @override
  String get noteHint => 'Any other details to add today?';

  @override
  String get autoSaveHint => 'Changes save instantly';

  @override
  String get allCategoriesOff =>
      'All categories are off. Tap the filter icon to enable.';

  @override
  String get chooseYear => 'Choose year';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get last6Cycles => 'Last 6 cycles';

  @override
  String get avgCycle => 'Average cycle';

  @override
  String get avgPeriod => 'Average period';

  @override
  String get dayUnit => 'days';

  @override
  String get cycleLengthTrend => 'Cycle length trend';

  @override
  String get statsHint =>
      'Tip: more data means more accurate predictions; log complete cycles.';

  @override
  String get statsEmpty => 'Log 1–2 complete cycles to see trends';

  @override
  String get statsOverview => 'Record overview';

  @override
  String get trackedDays => 'Tracked days';

  @override
  String get periodDays => 'Period days';

  @override
  String get symptomDays => 'Symptom days';

  @override
  String get moodDays => 'Mood days';

  @override
  String get sexDays => 'Sex days';

  @override
  String get metricDays => 'Metric days';

  @override
  String get symptomFrequency => 'Frequent symptoms';

  @override
  String get moodDistribution => 'Mood distribution';

  @override
  String get weightTrend => 'Weight trend';

  @override
  String get tempTrend => 'Temperature trend';

  @override
  String get noTrackingData => 'No data yet';

  @override
  String metricRangeStats(String min, String max, String avg) {
    return 'Min $min · Max $max · Avg $avg';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get customizeTracking => 'Customize tracking';

  @override
  String get customizeTrackingSubtitle => 'Category switches and order';

  @override
  String get cyclePersonalization => 'Cycle personalization';

  @override
  String get cyclePersonalizationSubtitle =>
      'Ovulation / fertile window display';

  @override
  String get importData => 'Import data';

  @override
  String get importDataSubtitle => 'JSON merge & dedupe';

  @override
  String get autoBackup => 'Auto backup';

  @override
  String get autoBackupSubtitle => 'Silently export JSON on exit';

  @override
  String get backupDir => 'Backup folder';

  @override
  String get backupDirNotSelected =>
      'Not selected (tap to choose and authorize)';

  @override
  String get backupNow => 'Back up now';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get exportJsonSubtitle => 'Full data → clipboard';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get privacyPolicy => 'Privacy';

  @override
  String get privacyPolicySubtitle =>
      'Local-first storage · export/delete anytime';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageEn => 'English';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String exportSaved(String label) {
    return '$label saved';
  }

  @override
  String exportSavedCount(String count) {
    return '$count in total';
  }

  @override
  String get exportCopyHint => 'Copy the content to send it to others.';

  @override
  String get shareSaveToSystem => 'Share / Save to system';

  @override
  String get copyContent => 'Copy content';

  @override
  String get copiedToClipboard => 'Content copied to clipboard';

  @override
  String exportShareText(String label) {
    return 'Period tracking data export ($label)';
  }

  @override
  String get importFromFile => 'Import from file';

  @override
  String get importFromFileSubtitle => 'Choose a local .json export file';

  @override
  String get pasteJson => 'Paste JSON';

  @override
  String get pasteJsonSubtitle => 'From clipboard or manual paste';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get importErrorJsonParse =>
      'JSON parse failed. Paste a valid export file.';

  @override
  String get importErrorInvalidJson => 'Invalid JSON format.';

  @override
  String importErrorSchemaMismatch(String imported, String current) {
    return 'Schema version mismatch: import is $imported, current is $current';
  }

  @override
  String get importErrorMissingData => 'Missing data root node.';

  @override
  String get importErrorInvalidDate => 'Unparseable date field.';

  @override
  String get importDedupeHint =>
      'Merged by unique key; existing records are not overwritten.';

  @override
  String get pasteJsonHint => 'Paste JSON…';

  @override
  String get importDone => 'Import complete';

  @override
  String importSummary(int inserted, int skipped) {
    return '$inserted added · $skipped skipped';
  }

  @override
  String addedCount(int n) {
    return 'Added $n';
  }

  @override
  String skippedCount(int n) {
    return 'Skipped $n';
  }

  @override
  String get importSkippedHint =>
      'Skipped = same unique key already exists locally and is kept as-is.';

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get unknownError => 'Unknown error';

  @override
  String get backupDone => 'Backup complete';

  @override
  String get backupShareText => 'Period tracking backup';

  @override
  String get shareSaveAs => 'Share / Save as';

  @override
  String get clearAllConfirmTitle => 'Clear all data?';

  @override
  String get clearAllConfirmBody =>
      'This deletes all period records, symptoms, moods and predictions on this device, and cannot be undone.';

  @override
  String get clearedAllData => 'All data cleared';

  @override
  String get tablePeriodDays => 'Period records';

  @override
  String get tableSymptoms => 'Symptoms';

  @override
  String get tableBodyMetrics => 'Body metrics';

  @override
  String get tableMoods => 'Moods';

  @override
  String get tablePredictions => 'Predictions';

  @override
  String charsCount(int n) {
    return '$n chars';
  }

  @override
  String get displaySection => 'Display';

  @override
  String get showOvulation => 'Show ovulation';

  @override
  String get showFertileWindow => 'Show fertile window';

  @override
  String get restoreDefault => 'Restore default';

  @override
  String get recordTitle => 'Log';

  @override
  String get recordDate => 'Record date';

  @override
  String get stepPeriod => 'Period';

  @override
  String get stepFlow => 'Flow';

  @override
  String get stepSymptoms => 'Symptoms';

  @override
  String get stepMetrics => 'Metrics';

  @override
  String get stepMood => 'Mood';

  @override
  String get stepPeriodHint => 'Are you on your period this day?';

  @override
  String get stepFlowHint => 'How heavy is the bleeding?';

  @override
  String get stepSymptomsHint => 'Which symptoms do you have?';

  @override
  String get stepMetricsHint => 'Body metrics (optional)';

  @override
  String get stepMoodHint => 'How do you feel?';

  @override
  String get yesPeriodToday => 'Yes, period today';

  @override
  String get no => 'No';

  @override
  String get weightKgOptional => 'Weight (kg, optional)';

  @override
  String get tempCOptional => 'Basal temperature (℃, optional)';

  @override
  String get recordSaved => 'Record saved';

  @override
  String get recordFlowSpotting => 'Spotting';

  @override
  String get recordFlowLight => 'Light';

  @override
  String get recordFlowMedium => 'Medium';

  @override
  String get recordFlowHeavy => 'Heavy';

  @override
  String get accountTitle => 'Sync & account';

  @override
  String get currentMode => 'Current mode';

  @override
  String get localFreeMode => 'Local mode · full features free';

  @override
  String get accountId => 'Account ID';

  @override
  String anonymousUser(String id) {
    return 'Anonymous user #$id';
  }

  @override
  String get noLoginRequired => 'No login required';

  @override
  String get accountPrivacyBody =>
      'For privacy first, this version does not sync to the cloud. All period, symptom, mood and prediction data stays on this device. To migrate, use “Export JSON” then “Import data” on the new device.';

  @override
  String get accountMigrateHint =>
      'To migrate, return to “More” and use “Export / Import”.';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyLocalTitle => 'Local-first storage';

  @override
  String get privacyLocalBody =>
      'All period, symptom, mood and prediction data stays only in this device\'s database. Nothing is uploaded, with no ad tracking or third-party sharing.';

  @override
  String get privacyEncryptedTitle => 'Encrypted storage';

  @override
  String get privacyEncryptedBody =>
      'The database is protected by an encryption scheme whose key is held in system secure storage (iOS Keychain / Android Keystore); day-to-day data is only decrypted on device.';

  @override
  String get privacyClearTitle => 'Controlled deletion';

  @override
  String get privacyClearBody =>
      'Permanently delete all local records under “Clear all data”. Deletion cannot be undone, so export a backup first.';

  @override
  String get privacyMigrateTitle => 'Migrate anytime';

  @override
  String get privacyMigrateBody =>
      'Export as JSON and save or share it, then import on a new device to merge, dedupe and restore.';

  @override
  String placeholderModule(String title) {
    return 'The “$title” module will be implemented in a later stage';
  }
}
