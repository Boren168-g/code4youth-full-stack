// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get profile => 'ប្រវត្តិរូប';

  @override
  String get settings => 'ការកំណត់';

  @override
  String get appearance => 'រូបរាង';

  @override
  String get language => 'ភាសា';

  @override
  String get learning => 'ការសិក្សា';

  @override
  String get data => 'ទិន្នន័យ';

  @override
  String get privacy => 'ឯកជនភាព';

  @override
  String get account => 'គណនី';

  @override
  String get syncToDocker => 'ធ្វើសមកាលកម្មទៅ Firebase';

  @override
  String get lessonHistory => 'ប្រវត្តិនៃមេរៀន';

  @override
  String get history => 'ប្រវត្តិ';

  @override
  String get editProfile => 'កែសម្រួលប្រវត្តិរូប';

  @override
  String get guestLearner => 'អ្នកសិក្សាបណ្តោះអាសន្ន';

  @override
  String get signInToSave => 'ចូលគណនីដើម្បីរក្សាទុកវឌ្ឍនភាព';

  @override
  String get totalXp => 'XP សរុប';

  @override
  String get lessonsDone => 'មេរៀនដែលបានបញ្ចប់';

  @override
  String get signOut => 'ចាកចេញ';

  @override
  String get deleteAccount => 'លុបគណនីរបស់ខ្ញុំ';

  @override
  String get goodMorning => 'អរុណសួស្តី';

  @override
  String get goodAfternoon => 'ទិវាសួស្តី';

  @override
  String get goodEvening => 'សាយ័ណ្ហសួស្តី';

  @override
  String get thisWeek => 'សប្តាហ៍នេះ';

  @override
  String get keepGoing => 'បន្តទៀត';

  @override
  String get recentActivity => 'សកម្មភាពថ្មីៗ';

  @override
  String get startLearning => 'ចាប់ផ្តើមរៀន';

  @override
  String get alreadyHaveAccount => 'ខ្ញុំមានគណនីរួចហើយ';

  @override
  String get learn => 'រៀន';

  @override
  String get progress => 'វឌ្ឍនភាព';

  @override
  String get home => 'ទំព័រដើម';

  @override
  String get seeAll => 'មើលទាំងអស់';

  @override
  String get courseProgress => 'វឌ្ឍនភាពវគ្គសិក្សា';

  @override
  String lessonsFinished(Object completed, Object total) {
    return '$completed ក្នុងចំណោម $total មេរៀនដែលបានបញ្ចប់';
  }

  @override
  String lessonsCount(Object completed, Object total) {
    return '$completed ក្នុងចំណោម $total មេរៀន';
  }

  @override
  String get minutes => 'នាទី';

  @override
  String get resume => 'បន្ត';

  @override
  String get locked => 'ចាក់សោ';

  @override
  String get start => 'ចាប់ផ្តើម';

  @override
  String get lessons => 'មេរៀន';

  @override
  String get wholeCourse => 'វគ្គសិក្សាទាំងមូល';

  @override
  String get dayStreak => 'ចំនួនថ្ងៃជាប់ៗគ្នា';

  @override
  String get badges => 'មេដាយ';

  @override
  String get firstTryAnswers => 'ចម្លើយត្រឹមត្រូវលើកដំបូង';

  @override
  String get byModule => 'តាមម៉ូឌុល';

  @override
  String get earned => 'ទទួលបានហើយ';

  @override
  String get notYetEarned => 'មិនទាន់ទទួលបាន';

  @override
  String get startChallenge => 'ចាប់ផ្តើមការប្រកួតប្រជែង';

  @override
  String get continue_ => 'បន្ត';

  @override
  String get leaveLesson => 'ចាកចេញពីមេរៀននេះ?';

  @override
  String get saveAndLeave => 'រក្សាទុក និងចាកចេញ';

  @override
  String get keepLearning => 'បន្តរៀនទៀត';

  @override
  String saveMessage(Object step) {
    return 'យើងនឹងរក្សាទុកអ្នកនៅជំហានទី $step។ នៅពេលអ្នកត្រឡប់មកវិញ អ្នកនឹងចាប់ផ្តើមពីទីនេះ មិនមែនតាំងពីដំបូងឡើយ។';
  }

  @override
  String get thisModuleIsLocked => 'ម៉ូឌុលនេះត្រូវបានចាក់សោ';

  @override
  String get finishPreviousModule => 'សូមបញ្ចប់ម៉ូឌុលមុនជាមុនសិន។';

  @override
  String get challenge => 'ការប្រកួតប្រជែង';

  @override
  String get checkAnswer => 'ពិនិត្យចម្លើយ';

  @override
  String get checkAgain => 'ពិនិត្យម្តងទៀត';

  @override
  String get tryAgain => 'ព្យាយាមម្តងទៀត';

  @override
  String collectXp(Object xp) {
    return 'ប្រមូល $xp XP';
  }

  @override
  String get correctMessage => 'លើកដំបូង។ ពិតជាត្រឹមត្រូវណាស់។';

  @override
  String get passedMessage => 'អ្នកធ្វើបានហើយ។ នោះហើយជាអ្វីដែលសំខាន់។';

  @override
  String get yourAnswer => 'ចម្លើយរបស់អ្នក';

  @override
  String get missingPart => 'វាយបញ្ចូលផ្នែកដែលបាត់';

  @override
  String get typeOutput => 'វាយបញ្ចូលលទ្ធផលឱ្យបានត្រឹមត្រូវ';

  @override
  String get displayPrompt => 'តើវាបង្ហាញអ្វីខ្លះ?';

  @override
  String get learnDescription =>
      'ប្រាំម៉ូឌុល ចាប់ពីបន្ទាត់កូដដំបូងរបស់អ្នក រហូតដល់កម្មវិធីដែលដំណើរការបាន។';

  @override
  String get theme => 'រូបរាង';

  @override
  String get themeDescription =>
      'របៀបងងឹតគឺងាយស្រួលសម្រាប់ភ្នែកនៅពេលយប់ និងប្រើប្រាស់ថាមពលថ្មតិច។';

  @override
  String get system => 'ប្រព័ន្ធ';

  @override
  String get light => 'ភ្លឺ';

  @override
  String get dark => 'ងងឹត';

  @override
  String get default_ => 'លំនាំដើម';

  @override
  String get dailyReminder => 'ការរំលឹកប្រចាំថ្ងៃ';

  @override
  String get dailyReminderDesc =>
      'ការដាស់តឿនម្តងក្នុងមួយថ្ងៃ នៅពេលដែលអ្នកធ្លាប់រៀន។';

  @override
  String get reduceMotion => 'កាត់បន្ថយចលនា';

  @override
  String get reduceMotionDesc =>
      'បិទចលនារង្វាន់ និងរក្សាការផ្លាស់ប្តូរឱ្យនៅធម្មតា។';

  @override
  String get simulateOffline => 'ក្លែងធ្វើជាគ្មានអ៊ីនធឺណិត';

  @override
  String get simulateOfflineDesc =>
      'បន្លំថាការភ្ជាប់ត្រូវបានកាត់ផ្តាច់ ដើម្បីមើលពីរបៀបដែលវឌ្ឍនភាពត្រូវបានតម្រង់ជួរ។';

  @override
  String updatesQueued(Object count) {
    return 'មានការធ្វើបច្ចុប្បន្នភាពចំនួន $count កំពុងតម្រង់ជួរ។ បិទមុខងារនេះដើម្បីធ្វើសមកាលកម្មពួកវា។';
  }

  @override
  String get downloadedLessons => 'មេរៀនដែលបានទាញយក';

  @override
  String downloadedLessonsDesc(Object count) {
    return '$count មេរៀន · ប្រហែល 4.2 MB';
  }

  @override
  String get pushProfile => 'រុញប្រវត្តិរូបទៅកាន់មូលដ្ឋានទិន្នន័យ Docker';

  @override
  String get privacyPolicy => 'គោលការណ៍ឯកជនភាព';

  @override
  String get privacyPolicyDesc => 'អ្វីដែលយើងប្រមូល និងរយៈពេលដែលយើងរក្សាទុកវា';

  @override
  String get guardianConsent => 'ការយល់ព្រមពីអាណាព្យាបាល';

  @override
  String get approved => 'បានអនុម័ត';

  @override
  String get waitingApproval => 'កំពុងរង់ចាំការអនុម័ត';

  @override
  String get notRequired => 'មិនតម្រូវឱ្យមាន';

  @override
  String get confirmDeleteTitle => 'លុបគណនីរបស់អ្នក?';

  @override
  String get confirmDeleteDesc =>
      'ប្រវត្តិរូប, XP, មេដាយ និងប្រវត្តិនៃមេរៀនរបស់អ្នកនឹងត្រូវបានលុបជាអចិន្ត្រៃយ៍។ មិនមានវិធីដើម្បីយកពួកវាត្រឡប់មកវិញទេ។';

  @override
  String get keepAccount => 'រក្សាទុកគណនីរបស់ខ្ញុំ';

  @override
  String get deleteEverything => 'លុបអ្វីៗទាំងអស់';

  @override
  String get deleteWarning =>
      'ការលុបនឹងលុបគណនីរបស់អ្នក និងរាល់កំណត់ត្រាមេរៀនទាំងអស់ជាមួយវា។ វាមិនអាចត្រឡប់វិញបានទេ។';

  @override
  String get displayName => 'ឈ្មោះបង្ហាញ';

  @override
  String get grade => 'កម្រិតថ្នាក់';

  @override
  String get interestsTitle => 'អ្វីដែលអ្នកចង់បង្កើត';

  @override
  String get saveChanges => 'រក្សាទុកការផ្លាស់ប្តូរ';

  @override
  String get profileUpdated => 'ប្រវត្តិរូបត្រូវបានធ្វើបច្ចុប្បន្នភាព។';

  @override
  String get goBack => 'ត្រឡប់ក្រោយ';
}
