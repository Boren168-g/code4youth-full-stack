import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Named routes for the whole app.
abstract final class Routes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String verifyOtp = '/verify-otp';
  static const String onboarding = '/onboarding';
  static const String guardianConsent = '/guardian-consent';
  static const String consentPending = '/consent-pending';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String shell = '/home';
  static const String module = '/module';
  static const String lesson = '/lesson';
  static const String challenge = '/challenge';
  static const String result = '/result';
  static const String levelUp = '/level-up';
  static const String badgeAward = '/badge-award';

  static const String history = '/history';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
}

/// A fade transition capped at 300 ms.
///
/// Screen changes fade rather than slide: it reads as calm, and it is cheaper
/// to render on the mid-range devices this app targets.
class FadeRoute<T> extends PageRouteBuilder<T> {
  FadeRoute({required this.child, super.settings, super.fullscreenDialog})
    : super(
        transitionDuration: Motion.slow,
        reverseTransitionDuration: Motion.base,
        pageBuilder: (_, _, _) => child,
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Motion.enter,
              reverseCurve: Motion.exit,
            ),
            child: child,
          );
        },
      );

  final Widget child;
}

/// A route that rises from the bottom — used for reward moments, which should
/// feel like they arrive rather than simply appear.
class RiseRoute<T> extends PageRouteBuilder<T> {
  RiseRoute({required this.child, super.settings})
    : super(
        transitionDuration: Motion.slow,
        reverseTransitionDuration: Motion.base,
        opaque: true,
        pageBuilder: (_, _, _) => child,
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) {
          final Animation<double> curved = CurvedAnimation(
            parent: animation,
            curve: Motion.enter,
            reverseCurve: Motion.exit,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );

  final Widget child;
}
