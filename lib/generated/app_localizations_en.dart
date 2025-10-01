// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pépito App';

  @override
  String get homeTab => 'Home';

  @override
  String get activitiesTab => 'Activities';

  @override
  String get statisticsTab => 'Statistics';

  @override
  String get settingsTab => 'Settings';

  @override
  String get lastActivity => 'Last activity';

  @override
  String get activitiesToday => 'Activities today';

  @override
  String get status => 'Status';

  @override
  String get atHome => 'At home';

  @override
  String get awayFromHome => 'Away from home';

  @override
  String get recentActivities => 'Recent activities';

  @override
  String get viewAll => 'View all';

  @override
  String get noRecentActivities => 'No recent activities';

  @override
  String get pepitoActivitiesWillAppearHere =>
      'Pépito\'s activities will appear here';

  @override
  String get errorLoadingActivities => 'Error loading activities';

  @override
  String get activityDetails => 'Activity details';

  @override
  String get noActivity => 'No activity';

  @override
  String get aFewMomentsAgo => 'A few moments ago';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get activities => 'activities';

  @override
  String get activeFilters => 'Active filters';

  @override
  String get clear => 'Clear';

  @override
  String get entries => 'Entries';

  @override
  String get exits => 'Exits';

  @override
  String get noActivities => 'No activities';

  @override
  String get pepitoActivitiesWillAppearWhenAvailable =>
      'Pépito\'s activities will appear here when available';

  @override
  String get update => 'Update';

  @override
  String get filterActivities => 'Filter activities';

  @override
  String get activityType => 'Activity type';

  @override
  String get dateRange => 'Date range';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get all => 'All';

  @override
  String get entry => 'Entry';

  @override
  String get exit => 'Exit';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get statistics => 'Statistics';

  @override
  String get overview => 'Overview';

  @override
  String get charts => 'Charts';

  @override
  String get insights => 'Insights';

  @override
  String get totalActivities => 'Total activities';

  @override
  String get inSelectedPeriod => 'In the selected period';

  @override
  String ofTotal(String percentage) {
    return '$percentage% of total';
  }

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get activitiesPerDay => 'Activities per day';

  @override
  String get activitiesByDay => 'Activities by day';

  @override
  String get notEnoughDataForInsights =>
      'Not enough data to generate insights.';

  @override
  String get pepitoSpendsMoreTimeAtHome =>
      'Pépito tends to spend more time at home than outside.';

  @override
  String get pepitoIsAdventurous =>
      'Pépito is very adventurous and likes to explore outside.';

  @override
  String get pepitoIsMoreActiveMornings =>
      'Pépito is more active in the mornings.';

  @override
  String get pepitoPrefersEveningActivities =>
      'Pépito prefers evening activities.';

  @override
  String get notEnoughDataForPatterns => 'Not enough data to detect patterns.';

  @override
  String get mondaysAreMostActive =>
      'Mondays are the most active days for Pépito.';

  @override
  String get tuesdaysAreMostActive =>
      'Tuesdays are the most active days for Pépito.';

  @override
  String get wednesdaysAreMostActive =>
      'Wednesdays are the most active days for Pépito.';

  @override
  String get thursdaysAreMostActive =>
      'Thursdays are the most active days for Pépito.';

  @override
  String get fridaysAreMostActive =>
      'Fridays are the most active days for Pépito.';

  @override
  String get saturdaysAreMostActive =>
      'Saturdays are the most active days for Pépito.';

  @override
  String get sundaysAreMostActive =>
      'Sundays are the most active days for Pépito.';

  @override
  String get pepitoHasRegularPattern =>
      'Pépito has a very regular activity pattern.';

  @override
  String get pepitoHasLowActivityPeriods =>
      'Pépito has periods of low activity.';

  @override
  String get configureNotifications =>
      'Configure notifications to receive activity alerts.';

  @override
  String get considerAdjustingSensor =>
      'Consider adjusting sensor configuration to improve accuracy.';

  @override
  String get pepitoGoesOutMuch =>
      'Pépito goes out a lot. Consider checking his outdoor safety.';

  @override
  String get reviewStatisticsRegularly =>
      'Review statistics regularly to better understand Pépito\'s habits.';

  @override
  String get timeAnalysis => 'Time analysis';

  @override
  String get monday => 'monday';

  @override
  String get tuesday => 'tuesday';

  @override
  String get wednesday => 'wednesday';

  @override
  String get thursday => 'thursday';

  @override
  String get friday => 'friday';

  @override
  String get saturday => 'saturday';

  @override
  String get sunday => 'sunday';

  @override
  String get spendsMoreTimeInside =>
      'Pépito tends to spend more time at home than outside.';

  @override
  String get adventurousOutside =>
      'Pépito is very adventurous and likes to explore outside the house.';

  @override
  String get moreActiveMornings => 'Pépito is more active in the mornings.';

  @override
  String get prefersEveningActivities => 'Pépito prefers evening activities.';

  @override
  String mostActiveDays(String day) {
    return '${day}s are the most active days for Pépito.';
  }

  @override
  String get checkOutdoorSafety =>
      'Pépito goes out a lot. Consider reviewing his outdoor safety.';

  @override
  String get pepitoSafeAtHome => 'Pépito is safe at home';

  @override
  String get pepitoExploring => 'Pépito is exploring';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get additionalInformation => 'Additional information:';

  @override
  String get away => 'Away';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noActivitiesInPeriod => 'No activities in this period';

  @override
  String get summaryOf => 'Summary of';

  @override
  String get mostActiveHour => 'Most active hour';

  @override
  String get entriesToday => 'Entries today';

  @override
  String get exitsToday => 'Exits today';

  @override
  String get timeAtHome => 'Time at home';

  @override
  String get atHomeStatus => 'At home';

  @override
  String get awayStatus => 'Away';

  @override
  String get hoursAway => 'h away';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get aboutDesign => 'About design';

  @override
  String get appDesign => 'App design';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get contact => 'Contact';

  @override
  String get data => 'Data';

  @override
  String get updateData => 'Update data';

  @override
  String get syncWithServer => 'Sync with server';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get freeStorageSpace => 'Free storage space';

  @override
  String get exportData => 'Export data';

  @override
  String get downloadActivityHistory => 'Download activity history';

  @override
  String get versionInfo => 'Version information';

  @override
  String get version => 'Version';

  @override
  String get build => 'Build';

  @override
  String get flutter => 'Flutter: 3.8.1';

  @override
  String get dart => 'Dart: 3.0.0';

  @override
  String get appDescription =>
      'Application to monitor Pépito the cat\'s activities.';

  @override
  String get close => 'Close';

  @override
  String get contactDescription =>
      'Do you have any problems or suggestions?\n\nYou can contact us through:\n\n• GitHub Issues\n• Email: pedrojuuu@gmail.com\n• Twitter: @pedrojuuu\n\nWe\'ll be happy to help you.';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get notifications => 'Notifications';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get quietHours => 'Quiet hours';

  @override
  String get selectTheme => 'Select theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get clearCacheConfirmation =>
      'Are you sure you want to clear the cache?';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get dataExported => 'Data exported successfully';

  @override
  String get exportError => 'Error exporting data';

  @override
  String get noData => 'No data';

  @override
  String get averageTimeAtHome => 'Average time at home';

  @override
  String get averageTimeAway => 'Average time away';

  @override
  String get justNow => 'Just now';

  @override
  String get home => 'Home';

  @override
  String get viewDetailedAnalysis => 'View detailed analysis';

  @override
  String get configureAlerts => 'Configure alerts';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get receiveNotificationsWhenPepitoEntersOrLeaves =>
      'Receive notifications when Pépito enters or leaves';

  @override
  String get entryNotifications => 'Entry notifications';

  @override
  String get notifyWhenPepitoArrivesHome => 'Notify when Pépito arrives home';

  @override
  String get exitNotifications => 'Exit notifications';

  @override
  String get notifyWhenPepitoLeavesHome => 'Notify when Pépito leaves home';

  @override
  String get playSoundWithNotifications => 'Play sound with notifications';

  @override
  String get vibrateWithNotifications => 'Vibrate with notifications';

  @override
  String get doNotDisturbDuringCertainHours =>
      'Do not disturb during certain hours';

  @override
  String get quietHoursStart => 'Quiet hours start';

  @override
  String get quietHoursEnd => 'Quiet hours end';

  @override
  String get automatic => 'Automatic (system)';

  @override
  String get understood => 'Understood';

  @override
  String get appVersion => 'App version';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get howWeProtectYourData => 'How we protect your data';

  @override
  String get termsOfServiceFull => 'Terms of service';

  @override
  String get conditionsOfUse => 'Conditions of use';

  @override
  String get reportProblemsOrSuggestions => 'Report problems or suggestions';

  @override
  String get sourceCode => 'Source code';

  @override
  String get viewOnGitHub => 'View on GitHub';

  @override
  String get about => 'About';

  @override
  String get dataUpdated => 'Data updated';

  @override
  String errorUpdating(String error) {
    return 'Error updating: $error';
  }

  @override
  String get importantInformation => 'Important information';

  @override
  String get currentStatusOnly => 'Only current status of Pépito is shown';

  @override
  String get percentOfTotal => '% of total';

  @override
  String get temporalAnalysis => 'Temporal analysis';

  @override
  String get leastActiveHour => 'Least active hour';

  @override
  String get averageConfidence => 'Average confidence';

  @override
  String get hourlyDistribution => 'Hourly distribution';

  @override
  String get weeklyPattern => 'Weekly pattern';

  @override
  String get behaviorInsights => 'Behavior insights';

  @override
  String get detectedPatterns => 'Detected patterns';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get errorLoadingStatistics => 'Error loading statistics';

  @override
  String get customPeriod => 'custom period';

  @override
  String get notEnoughDataInsights => 'Not enough data to generate insights.';

  @override
  String get pepitoHomeTendency =>
      'Pépito tends to spend more time at home than outside.';

  @override
  String get pepitoAdventurous =>
      'Pépito is very adventurous and likes to explore outside the house.';

  @override
  String get pepitoMorningActive => 'Pépito is more active in the mornings.';

  @override
  String get pepitoEveningActive => 'Pépito prefers evening activities.';

  @override
  String get notEnoughDataPatterns => 'Not enough data to detect patterns.';

  @override
  String get mondaysActive => 'Mondays are the most active days for Pépito.';

  @override
  String get tuesdaysActive => 'Tuesdays are the most active days for Pépito.';

  @override
  String get wednesdaysActive =>
      'Wednesdays are the most active days for Pépito.';

  @override
  String get thursdaysActive =>
      'Thursdays are the most active days for Pépito.';

  @override
  String get fridaysActive => 'Fridays are the most active days for Pépito.';

  @override
  String get saturdaysActive =>
      'Saturdays are the most active days for Pépito.';

  @override
  String get sundaysActive => 'Sundays are the most active days for Pépito.';

  @override
  String get regularActivityPattern =>
      'Pépito has a very regular activity pattern.';

  @override
  String get lowActivityPeriods => 'Pépito has periods of low activity.';

  @override
  String get adjustSensorConfiguration =>
      'Consider adjusting the sensor configuration to improve accuracy.';

  @override
  String get reviewOutdoorSafety =>
      'Pépito goes out a lot. Consider reviewing his outdoor safety.';

  @override
  String get errorClearingCache => 'Error clearing cache';

  @override
  String get openingGitHub => 'Opening GitHub...';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get errorRequestingPermissions => 'Error requesting permissions';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This week';

  @override
  String get lastWeek => 'Last week';

  @override
  String get thisMonth => 'This month';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get analysis => 'Analysis';

  @override
  String get refreshData => 'Refresh data';

  @override
  String get synchronizeWithServer => 'Synchronize with server';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get reportIssuesOrSuggestions => 'Report issues or suggestions';

  @override
  String get appDesignDescription =>
      'This application uses the native design system of each platform:\n\n• Android/Web: Material 3 Expressive\n• iOS/macOS: Liquid Glass Design\n• Windows: Fluent Design\n\nThis ensures a familiar and consistent experience on each device.';

  @override
  String get versionInformation => 'Version information';

  @override
  String get release => 'Release';

  @override
  String get applicationToMonitorPepito =>
      'Application to monitor Pepito the cat\'s activities.';

  @override
  String get privacyPolicyTitle => 'PRIVACY POLICY';

  @override
  String get informationWeCollect => '1. INFORMATION WE COLLECT';

  @override
  String get informationWeCollectDescription =>
      'This application only collects Pepito\'s activity data provided by the official API.';

  @override
  String get useOfInformation => '2. USE OF INFORMATION';

  @override
  String get useOfInformationDescription =>
      'Data is used exclusively to display Pepito\'s status and activities.';

  @override
  String get storage => '3. STORAGE';

  @override
  String get storageDescription =>
      'Pepito\'s status data is retrieved from the API and temporarily stored in local cache to improve performance.';

  @override
  String get notificationsSection => '4. NOTIFICATIONS';

  @override
  String get notificationsSectionDescription =>
      'Push notifications require a device token that is handled securely.';

  @override
  String get thirdParties => '5. THIRD PARTIES';

  @override
  String get thirdPartiesDescription =>
      'We do not share personal information with third parties.';

  @override
  String get lastUpdated => 'Last updated: October 2025';

  @override
  String get termsOfServiceTitle => 'TERMS OF SERVICE';

  @override
  String get acceptance => '1. ACCEPTANCE';

  @override
  String get acceptanceDescription =>
      'By using this application, you accept these terms.';

  @override
  String get permittedUse => '2. PERMITTED USE';

  @override
  String get permittedUseDescription =>
      'This application is for personal use and monitoring Pepito.';

  @override
  String get availability => '3. AVAILABILITY';

  @override
  String get availabilityDescription =>
      'The service depends on Pepito\'s API and may not be available at all times.';

  @override
  String get responsibility => '4. RESPONSIBILITY';

  @override
  String get responsibilityDescription =>
      'We are not responsible for decisions made based on the data displayed.';

  @override
  String get modifications => '5. MODIFICATIONS';

  @override
  String get modificationsDescription =>
      'We reserve the right to modify these terms.';
}
