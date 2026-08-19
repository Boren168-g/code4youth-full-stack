// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get learning => 'Learning';

  @override
  String get data => 'Data';

  @override
  String get privacy => 'Privacy';

  @override
  String get account => 'Account';

  @override
  String get syncToDocker => 'Sync to Firebase';

  @override
  String get lessonHistory => 'Lesson History';

  @override
  String get history => 'History';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get guestLearner => 'Guest Learner';

  @override
  String get signInToSave => 'Sign in to save progress';

  @override
  String get totalXp => 'Total XP';

  @override
  String get lessonsDone => 'Lessons done';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get thisWeek => 'This week';

  @override
  String get keepGoing => 'Keep going';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get startLearning => 'Start learning';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get learn => 'Learn';

  @override
  String get progress => 'Progress';

  @override
  String get home => 'Home';

  @override
  String get seeAll => 'See all';

  @override
  String get courseProgress => 'Course progress';

  @override
  String lessonsFinished(Object completed, Object total) {
    return '$completed of $total lessons finished';
  }

  @override
  String lessonsCount(Object completed, Object total) {
    return '$completed of $total lessons';
  }

  @override
  String get minutes => 'min';

  @override
  String get resume => 'Resume';

  @override
  String get locked => 'Locked';

  @override
  String get start => 'Start';

  @override
  String get lessons => 'lessons';

  @override
  String get wholeCourse => 'Whole course';

  @override
  String get dayStreak => 'Day streak';

  @override
  String get badges => 'Badges';

  @override
  String get firstTryAnswers => 'First-try answers';

  @override
  String get byModule => 'By module';

  @override
  String get earned => 'Earned';

  @override
  String get notYetEarned => 'Not yet earned';

  @override
  String get startChallenge => 'Start challenge';

  @override
  String get continue_ => 'Continue';

  @override
  String get leaveLesson => 'Leave this lesson?';

  @override
  String get saveAndLeave => 'Save and leave';

  @override
  String get keepLearning => 'Keep learning';

  @override
  String saveMessage(Object step) {
    return 'We will save you on step $step. When you come back you will start right here, not from the beginning.';
  }

  @override
  String get thisModuleIsLocked => 'This module is locked';

  @override
  String get finishPreviousModule => 'Finish the previous module first.';

  @override
  String get challenge => 'Challenge';

  @override
  String get checkAnswer => 'Check answer';

  @override
  String get checkAgain => 'Check again';

  @override
  String get tryAgain => 'Try again';

  @override
  String collectXp(Object xp) {
    return 'Collect $xp XP';
  }

  @override
  String get correctMessage => 'First try. That is exactly right.';

  @override
  String get passedMessage => 'You got there. That is what matters.';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get missingPart => 'Type the missing part';

  @override
  String get typeOutput => 'Type the output exactly';

  @override
  String get displayPrompt => 'What does it display?';

  @override
  String get learnDescription =>
      'Five modules, from your first line of code to a working app.';

  @override
  String get theme => 'Theme';

  @override
  String get themeDescription =>
      'Dark mode is easier on the eyes at night and uses less battery.';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get default_ => 'Default';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get dailyReminderDesc =>
      'One nudge a day, at the time you usually study.';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get reduceMotionDesc =>
      'Turns off the reward animations and keeps transitions plain.';

  @override
  String get simulateOffline => 'Simulate offline';

  @override
  String get simulateOfflineDesc =>
      'Pretends the connection dropped, so you can see how offline progress is queued.';

  @override
  String updatesQueued(Object count) {
    return '$count updates queued. Turn this off to sync them.';
  }

  @override
  String get downloadedLessons => 'Downloaded lessons';

  @override
  String downloadedLessonsDesc(Object count) {
    return '$count lessons · about 4.2 MB';
  }

  @override
  String get pushProfile => 'Push profile to Docker database';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacyPolicyDesc => 'What we collect and how long we keep it';

  @override
  String get guardianConsent => 'Guardian consent';

  @override
  String get approved => 'Approved';

  @override
  String get waitingApproval => 'Waiting for approval';

  @override
  String get notRequired => 'Not required';

  @override
  String get confirmDeleteTitle => 'Delete your account?';

  @override
  String get confirmDeleteDesc =>
      'Your profile, XP, badges and lesson history are erased permanently. There is no way to get them back.';

  @override
  String get keepAccount => 'Keep my account';

  @override
  String get deleteEverything => 'Delete everything';

  @override
  String get deleteWarning =>
      'Deleting removes your account and every lesson record with it. It cannot be undone.';

  @override
  String get displayName => 'Display name';

  @override
  String get grade => 'Grade';

  @override
  String get interestsTitle => 'What you want to build';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get goBack => 'Go back';
}
