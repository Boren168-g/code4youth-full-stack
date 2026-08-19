import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('km'),
  ];

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @syncToDocker.
  ///
  /// In en, this message translates to:
  /// **'Sync to Firebase'**
  String get syncToDocker;

  /// No description provided for @lessonHistory.
  ///
  /// In en, this message translates to:
  /// **'Lesson History'**
  String get lessonHistory;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @guestLearner.
  ///
  /// In en, this message translates to:
  /// **'Guest Learner'**
  String get guestLearner;

  /// No description provided for @signInToSave.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save progress'**
  String get signInToSave;

  /// No description provided for @totalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXp;

  /// No description provided for @lessonsDone.
  ///
  /// In en, this message translates to:
  /// **'Lessons done'**
  String get lessonsDone;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccount;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get startLearning;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @courseProgress.
  ///
  /// In en, this message translates to:
  /// **'Course progress'**
  String get courseProgress;

  /// No description provided for @lessonsFinished.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} lessons finished'**
  String lessonsFinished(Object completed, Object total);

  /// No description provided for @lessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} lessons'**
  String lessonsCount(Object completed, Object total);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'lessons'**
  String get lessons;

  /// No description provided for @wholeCourse.
  ///
  /// In en, this message translates to:
  /// **'Whole course'**
  String get wholeCourse;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get dayStreak;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @firstTryAnswers.
  ///
  /// In en, this message translates to:
  /// **'First-try answers'**
  String get firstTryAnswers;

  /// No description provided for @byModule.
  ///
  /// In en, this message translates to:
  /// **'By module'**
  String get byModule;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @notYetEarned.
  ///
  /// In en, this message translates to:
  /// **'Not yet earned'**
  String get notYetEarned;

  /// No description provided for @startChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start challenge'**
  String get startChallenge;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @leaveLesson.
  ///
  /// In en, this message translates to:
  /// **'Leave this lesson?'**
  String get leaveLesson;

  /// No description provided for @saveAndLeave.
  ///
  /// In en, this message translates to:
  /// **'Save and leave'**
  String get saveAndLeave;

  /// No description provided for @keepLearning.
  ///
  /// In en, this message translates to:
  /// **'Keep learning'**
  String get keepLearning;

  /// No description provided for @saveMessage.
  ///
  /// In en, this message translates to:
  /// **'We will save you on step {step}. When you come back you will start right here, not from the beginning.'**
  String saveMessage(Object step);

  /// No description provided for @thisModuleIsLocked.
  ///
  /// In en, this message translates to:
  /// **'This module is locked'**
  String get thisModuleIsLocked;

  /// No description provided for @finishPreviousModule.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous module first.'**
  String get finishPreviousModule;

  /// No description provided for @challenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get challenge;

  /// No description provided for @checkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get checkAnswer;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgain;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @collectXp.
  ///
  /// In en, this message translates to:
  /// **'Collect {xp} XP'**
  String collectXp(Object xp);

  /// No description provided for @correctMessage.
  ///
  /// In en, this message translates to:
  /// **'First try. That is exactly right.'**
  String get correctMessage;

  /// No description provided for @passedMessage.
  ///
  /// In en, this message translates to:
  /// **'You got there. That is what matters.'**
  String get passedMessage;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @missingPart.
  ///
  /// In en, this message translates to:
  /// **'Type the missing part'**
  String get missingPart;

  /// No description provided for @typeOutput.
  ///
  /// In en, this message translates to:
  /// **'Type the output exactly'**
  String get typeOutput;

  /// No description provided for @displayPrompt.
  ///
  /// In en, this message translates to:
  /// **'What does it display?'**
  String get displayPrompt;

  /// No description provided for @learnDescription.
  ///
  /// In en, this message translates to:
  /// **'Five modules, from your first line of code to a working app.'**
  String get learnDescription;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Dark mode is easier on the eyes at night and uses less battery.'**
  String get themeDescription;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @default_.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get default_;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'One nudge a day, at the time you usually study.'**
  String get dailyReminderDesc;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @reduceMotionDesc.
  ///
  /// In en, this message translates to:
  /// **'Turns off the reward animations and keeps transitions plain.'**
  String get reduceMotionDesc;

  /// No description provided for @simulateOffline.
  ///
  /// In en, this message translates to:
  /// **'Simulate offline'**
  String get simulateOffline;

  /// No description provided for @simulateOfflineDesc.
  ///
  /// In en, this message translates to:
  /// **'Pretends the connection dropped, so you can see how offline progress is queued.'**
  String get simulateOfflineDesc;

  /// No description provided for @updatesQueued.
  ///
  /// In en, this message translates to:
  /// **'{count} updates queued. Turn this off to sync them.'**
  String updatesQueued(Object count);

  /// No description provided for @downloadedLessons.
  ///
  /// In en, this message translates to:
  /// **'Downloaded lessons'**
  String get downloadedLessons;

  /// No description provided for @downloadedLessonsDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons · about 4.2 MB'**
  String downloadedLessonsDesc(Object count);

  /// No description provided for @pushProfile.
  ///
  /// In en, this message translates to:
  /// **'Push profile to Docker database'**
  String get pushProfile;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'What we collect and how long we keep it'**
  String get privacyPolicyDesc;

  /// No description provided for @guardianConsent.
  ///
  /// In en, this message translates to:
  /// **'Guardian consent'**
  String get guardianConsent;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @waitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get waitingApproval;

  /// No description provided for @notRequired.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get notRequired;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Your profile, XP, badges and lesson history are erased permanently. There is no way to get them back.'**
  String get confirmDeleteDesc;

  /// No description provided for @keepAccount.
  ///
  /// In en, this message translates to:
  /// **'Keep my account'**
  String get keepAccount;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteEverything;

  /// No description provided for @deleteWarning.
  ///
  /// In en, this message translates to:
  /// **'Deleting removes your account and every lesson record with it. It cannot be undone.'**
  String get deleteWarning;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @interestsTitle.
  ///
  /// In en, this message translates to:
  /// **'What you want to build'**
  String get interestsTitle;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;
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
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
