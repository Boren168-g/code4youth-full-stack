import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:code4youth/data/curriculum.dart';
import 'package:code4youth/models/content.dart';
import 'package:code4youth/models/gamification.dart';
import 'package:code4youth/screens/auth/consent_pending_screen.dart';
import 'package:code4youth/screens/auth/forgot_password_screen.dart';
import 'package:code4youth/screens/auth/guardian_consent_screen.dart';
import 'package:code4youth/screens/auth/login_screen.dart';
import 'package:code4youth/screens/auth/onboarding_screen.dart';
import 'package:code4youth/screens/auth/reset_password_screen.dart';
import 'package:code4youth/screens/auth/sign_up_screen.dart';
import 'package:code4youth/screens/auth/verify_otp_screen.dart';
import 'package:code4youth/screens/auth/welcome_screen.dart';
import 'package:code4youth/screens/learn/badge_award_screen.dart';
import 'package:code4youth/screens/learn/challenge_screen.dart';
import 'package:code4youth/screens/learn/lesson_screen.dart';
import 'package:code4youth/screens/learn/level_up_screen.dart';
import 'package:code4youth/screens/learn/module_detail_screen.dart';
import 'package:code4youth/screens/learn/result_screen.dart';
import 'package:code4youth/screens/profile/edit_profile_screen.dart';
import 'package:code4youth/screens/profile/settings_screen.dart';
import 'package:code4youth/screens/progress/history_screen.dart';
import 'package:code4youth/screens/shell.dart';
import 'package:code4youth/state/app_state.dart';
import 'package:code4youth/theme/app_theme.dart';

/// A mid-range phone. Every screen has to fit here without overflowing.
const Size _phone = Size(375, 812);

/// A small phone, to catch layouts that only fit on roomy devices.
const Size _smallPhone = Size(320, 640);

void main() {
  /// Pumps [child] inside the real app theme and asserts it laid out cleanly.
  ///
  /// `pumpWidget` surfaces a RenderFlex overflow as a thrown exception, so an
  /// overflowing screen fails here rather than shipping with a yellow-and-black
  /// stripe across it.
  Future<void> expectRenders(
    WidgetTester tester,
    Widget child, {
    AppState? state,
    Brightness brightness = Brightness.light,
    Size size = _phone,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state ?? (AppState()..signInReturning()),
        child: MaterialApp(
          theme: brightness == Brightness.dark
              ? AppTheme.dark
              : AppTheme.light,
          home: child,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  }

  final Lesson lesson = Curriculum.modules.first.lessons.first;

  group('every screen lays out on a mid-range phone', () {
    testWidgets('Welcome', (WidgetTester t) async {
      await expectRenders(t, const WelcomeScreen());
    });

    testWidgets('Sign up', (WidgetTester t) async {
      await expectRenders(t, const SignUpScreen());
    });

    testWidgets('Login', (WidgetTester t) async {
      await expectRenders(t, const LoginScreen());
    });

    testWidgets('Verify OTP', (WidgetTester t) async {
      await expectRenders(
        t,
        const VerifyOtpScreen(
          email: 'a@example.com',
          purpose: OtpPurpose.signUp,
        ),
      );
    });

    testWidgets('Onboarding', (WidgetTester t) async {
      await expectRenders(t, const OnboardingScreen());
    });

    testWidgets('Guardian consent', (WidgetTester t) async {
      await expectRenders(t, const GuardianConsentScreen());
    });

    testWidgets('Consent pending', (WidgetTester t) async {
      await expectRenders(t, const ConsentPendingScreen());
    });

    testWidgets('Forgot password', (WidgetTester t) async {
      await expectRenders(t, const ForgotPasswordScreen());
    });

    testWidgets('Reset password', (WidgetTester t) async {
      await expectRenders(t, const ResetPasswordScreen());
    });

    testWidgets('Shell — Home', (WidgetTester t) async {
      await expectRenders(t, const AppShell());
    });

    testWidgets('Shell — Learn', (WidgetTester t) async {
      await expectRenders(t, const AppShell(initialIndex: 1));
    });

    testWidgets('Shell — Progress', (WidgetTester t) async {
      await expectRenders(t, const AppShell(initialIndex: 2));
    });

    testWidgets('Shell — Profile', (WidgetTester t) async {
      await expectRenders(t, const AppShell(initialIndex: 3));
    });

    testWidgets('Module detail — unlocked', (WidgetTester t) async {
      await expectRenders(
        t,
        ModuleDetailScreen(module: Curriculum.modules.first),
      );
    });

    testWidgets('Module detail — locked', (WidgetTester t) async {
      await expectRenders(
        t,
        ModuleDetailScreen(module: Curriculum.modules.last),
        state: AppState(),
      );
    });

    testWidgets('Lesson', (WidgetTester t) async {
      await expectRenders(t, LessonScreen(lesson: lesson));
    });

    testWidgets('Challenge', (WidgetTester t) async {
      await expectRenders(t, ChallengeScreen(lesson: lesson));
    });

    testWidgets('Result', (WidgetTester t) async {
      await expectRenders(
        t,
        ResultScreen(
          outcome: LessonOutcome(
            lesson: lesson,
            xpEarned: 50,
            attempts: 1,
            newBadges: const <BadgeDef>[],
            leveledUp: false,
            newLevel: 2,
            queuedOffline: false,
          ),
        ),
      );
    });

    testWidgets('Badge award', (WidgetTester t) async {
      await expectRenders(
        t,
        BadgeAwardScreen(badge: Badges.all.first, onContinue: () {}),
      );
    });

    testWidgets('Level up', (WidgetTester t) async {
      await expectRenders(t, LevelUpScreen(level: 3, onContinue: () {}));
    });

    testWidgets('History', (WidgetTester t) async {
      await expectRenders(t, const HistoryScreen());
    });

    testWidgets('Edit profile', (WidgetTester t) async {
      await expectRenders(t, const EditProfileScreen());
    });

    testWidgets('Settings', (WidgetTester t) async {
      await expectRenders(t, const SettingsScreen());
    });
  });

  group('key screens also lay out in dark mode', () {
    for (final (String name, Widget Function() build) in <(
      String,
      Widget Function(),
    )>[
      ('Welcome', WelcomeScreen.new),
      ('Home', AppShell.new),
      ('Lesson', () => LessonScreen(lesson: lesson)),
      ('Challenge', () => ChallengeScreen(lesson: lesson)),
      ('Settings', SettingsScreen.new),
    ]) {
      testWidgets(name, (WidgetTester t) async {
        await expectRenders(t, build(), brightness: Brightness.dark);
      });
    }
  });

  group('key screens also lay out on a 320 dp phone', () {
    for (final (String name, Widget Function() build) in <(
      String,
      Widget Function(),
    )>[
      ('Welcome', WelcomeScreen.new),
      ('Home', AppShell.new),
      ('Lesson', () => LessonScreen(lesson: lesson)),
      ('Challenge', () => ChallengeScreen(lesson: lesson)),
    ]) {
      testWidgets(name, (WidgetTester t) async {
        await expectRenders(t, build(), size: _smallPhone);
      });
    }
  });

  group('Challenge behaviour', () {
    testWidgets('refuses an empty answer without burning an attempt', (
      WidgetTester t,
    ) async {
      // A fill-in-the-blank lesson, so there is a text field to leave empty.
      final Lesson blank = Curriculum.lessonById('m1l2')!;
      await expectRenders(t, ChallengeScreen(lesson: blank));

      await t.tap(find.text('Check answer'));
      await t.pumpAndSettle();

      expect(find.text('Type your answer before checking it.'), findsOneWidget);
      expect(find.text('Correct!'), findsNothing);
      expect(find.text('Not quite. Try again.'), findsNothing);
    });

    testWidgets('a wrong answer shows the hint and offers a retry', (
      WidgetTester t,
    ) async {
      final Lesson blank = Curriculum.lessonById('m1l2')!;
      await expectRenders(t, ChallengeScreen(lesson: blank));

      await t.enterText(find.byType(TextFormField), 'nonsense');
      await t.tap(find.text('Check answer'));
      await t.pumpAndSettle();

      expect(find.text('Not quite. Try again.'), findsOneWidget);
      expect(find.text(blank.challenge.hint), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('a correct answer pays out on the spot', (
      WidgetTester t,
    ) async {
      final Lesson blank = Curriculum.lessonById('m1l2')!;
      await expectRenders(t, ChallengeScreen(lesson: blank));

      await t.enterText(find.byType(TextFormField), blank.challenge.answer);
      await t.tap(find.text('Check answer'));
      await t.pumpAndSettle();

      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('+${blank.challenge.xp} XP'), findsOneWidget);
      expect(
        find.text('Collect ${blank.challenge.xp} XP'),
        findsOneWidget,
      );
    });

    testWidgets('answers are case and whitespace forgiving', (
      WidgetTester t,
    ) async {
      final Lesson blank = Curriculum.lessonById('m1l2')!;
      await expectRenders(t, ChallengeScreen(lesson: blank));

      await t.enterText(
        find.byType(TextFormField),
        '  ${blank.challenge.answer.toUpperCase()}  ',
      );
      await t.tap(find.text('Check answer'));
      await t.pumpAndSettle();

      expect(find.text('Correct!'), findsOneWidget);
    });
  });

  group('Lesson behaviour', () {
    testWidgets('resumes at the saved step rather than step one', (
      WidgetTester t,
    ) async {
      final AppState state = AppState()..signInReturning();
      final Lesson long = Curriculum.lessonById('m1l1')!;
      state.savePosition(long.id, 2);

      await expectRenders(t, LessonScreen(lesson: long), state: state);

      expect(find.text('Step 3 of ${long.stepCount}'), findsOneWidget);
      expect(find.text('Step 1 of ${long.stepCount}'), findsNothing);
    });

    testWidgets('advancing a step writes the new position', (
      WidgetTester t,
    ) async {
      final AppState state = AppState()..signInReturning();
      final Lesson long = Curriculum.lessonById('m1l1')!;

      await expectRenders(t, LessonScreen(lesson: long), state: state);
      expect(state.savedPosition(long.id), 0);

      await t.tap(find.text('Continue'));
      await t.pumpAndSettle();

      expect(state.savedPosition(long.id), 1);
      expect(find.text('Step 2 of ${long.stepCount}'), findsOneWidget);
    });
  });
}
