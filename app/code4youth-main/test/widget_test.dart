import 'package:flutter_test/flutter_test.dart';

import 'package:code4youth/app.dart';
import 'package:code4youth/data/curriculum.dart';
import 'package:code4youth/models/content.dart';
import 'package:code4youth/state/app_state.dart';

void main() {
  group('AppState', () {
    test('a fresh account starts empty and on level 1', () {
      final AppState state = AppState();

      expect(state.isSignedIn, isFalse);
      expect(state.xp, 0);
      expect(state.level, 1);
      expect(state.lessonsCompleted, 0);
      expect(state.courseProgress, 0);
    });

    test('only the first module is unlocked at the start', () {
      final AppState state = AppState();

      expect(state.isModuleLocked(Curriculum.modules.first), isFalse);
      for (final Module m in Curriculum.modules.skip(1)) {
        expect(
          state.isModuleLocked(m),
          isTrue,
          reason: '${m.title} should be locked before its prerequisite',
        );
      }
    });

    test('a locked module names what unlocks it', () {
      final AppState state = AppState();
      final Module second = Curriculum.modules[1];

      final String? requirement = state.unlockRequirement(second);
      expect(requirement, isNotNull);
      expect(requirement, contains(Curriculum.modules.first.title));
    });

    test('completing a lesson awards XP and records history', () {
      final AppState state = AppState()
        ..register(displayName: 'Test', email: 't@example.com');
      final Lesson lesson = Curriculum.modules.first.lessons.first;

      final LessonOutcome outcome = state.completeLesson(lesson, attempts: 1);

      expect(outcome.xpEarned, lesson.xp + lesson.challenge.xp);
      expect(outcome.firstTry, isTrue);
      expect(state.xp, outcome.xpEarned);
      expect(state.isLessonComplete(lesson.id), isTrue);
      expect(state.history.single.lessonId, lesson.id);
    });

    test('finishing module one unlocks module two', () {
      final AppState state = AppState();
      for (final Lesson lesson in Curriculum.modules.first.lessons) {
        state.completeLesson(lesson, attempts: 1);
      }

      expect(state.isModuleComplete('m1'), isTrue);
      expect(state.isModuleLocked(Curriculum.modules[1]), isFalse);
      expect(state.unlockRequirement(Curriculum.modules[1]), isNull);
    });

    test('a saved position survives and is cleared on completion', () {
      final AppState state = AppState();
      final Lesson lesson = Curriculum.modules.first.lessons.first;

      state.savePosition(lesson.id, 2);
      expect(state.savedPosition(lesson.id), 2);
      expect(state.hasSavedPosition(lesson.id), isTrue);
      expect(state.resumableLesson?.id, lesson.id);

      state.completeLesson(lesson, attempts: 1);
      expect(state.savedPosition(lesson.id), 0);
      expect(state.hasSavedPosition(lesson.id), isFalse);
    });

    test('progress made offline is queued, and flushed on reconnect', () {
      final AppState state = AppState()..setOnline(false);
      final Lesson lesson = Curriculum.modules.first.lessons.first;

      final LessonOutcome outcome = state.completeLesson(lesson, attempts: 1);

      expect(outcome.queuedOffline, isTrue);
      expect(state.queuedEvents, greaterThan(0));

      state.setOnline(true);
      expect(state.queuedEvents, 0);
    });

    test('deleting the account erases every trace of progress', () {
      final AppState state = AppState()..signInReturning();
      expect(state.xp, greaterThan(0));
      expect(state.history, isNotEmpty);

      state.deleteAccount();

      expect(state.isSignedIn, isFalse);
      expect(state.xp, 0);
      expect(state.history, isEmpty);
      expect(state.earnedBadges, isEmpty);
      expect(state.completedLessons, isEmpty);
    });
  });

  group('Curriculum', () {
    test('every lesson fits the twenty minute budget', () {
      for (final Lesson lesson in Curriculum.allLessons) {
        expect(
          lesson.minutes,
          lessThanOrEqualTo(20),
          reason: '${lesson.title} is longer than a single sitting',
        );
      }
    });

    test('every lesson has steps and a challenge with a hint', () {
      for (final Lesson lesson in Curriculum.allLessons) {
        expect(lesson.steps, isNotEmpty, reason: lesson.title);
        expect(lesson.challenge.hint, isNotEmpty, reason: lesson.title);
        expect(lesson.challenge.answer, isNotEmpty, reason: lesson.title);
      }
    });

    test('multiple-choice answers are always among the options', () {
      for (final Lesson lesson in Curriculum.allLessons) {
        final Challenge c = lesson.challenge;
        if (c.kind != ChallengeKind.multipleChoice) continue;
        expect(
          c.options,
          contains(c.answer),
          reason: '${lesson.title} has an unreachable answer',
        );
      }
    });

    test('answer checking ignores case and surrounding whitespace', () {
      const Challenge c = Challenge(
        kind: ChallengeKind.fillBlank,
        prompt: 'p',
        answer: 'print',
        hint: 'h',
      );

      expect(c.isCorrect('print'), isTrue);
      expect(c.isCorrect('  PRINT '), isTrue);
      expect(c.isCorrect('printt'), isFalse);
    });

    test('every prerequisite points at a module that exists', () {
      for (final Module m in Curriculum.modules) {
        final String? required = m.requiresModuleId;
        if (required == null) continue;
        expect(Curriculum.moduleById(required), isNotNull, reason: m.title);
      }
    });
  });

  group('App', () {
    testWidgets('launches on the splash screen and reaches Welcome', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const Code4YouthApp());

      expect(find.text('Learn to code on your phone'), findsOneWidget);

      // Splash holds briefly, then resolves the session.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Start learning'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('sign up refuses to submit an empty form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const Code4YouthApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start learning'));
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      // Still on the form, with the policy gate called out.
      expect(find.text('Create your account'), findsOneWidget);
      expect(
        find.text('You need to accept the Privacy Policy to continue.'),
        findsOneWidget,
      );
    });

    testWidgets('logging in reaches the dashboard with the bottom nav', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const Code4YouthApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();

      // The demo-credentials block sits below the fold on a phone viewport.
      final Finder fill = find.text('Fill it in for me');
      await tester.ensureVisible(fill);
      await tester.pumpAndSettle();
      await tester.tap(fill);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
