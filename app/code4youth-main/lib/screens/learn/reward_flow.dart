import 'package:flutter/material.dart';

import '../../models/gamification.dart';
import '../../router/app_router.dart';
import '../../state/app_state.dart';
import 'badge_award_screen.dart';
import 'level_up_screen.dart';
import 'result_screen.dart';

/// Plays the reward moments a finished lesson earned, in the order the flow
/// defines: each new badge, then a level-up if one was crossed, then the
/// lesson summary.
///
/// Rewards are shown here — at the moment they are earned — rather than being
/// discovered later on the dashboard.
void showRewardSequence(BuildContext context, LessonOutcome outcome) {
  // Captured once: each screen replaces the last, so the originating context
  // is gone by the time the later steps run.
  final NavigatorState navigator = Navigator.of(context);

  final List<BadgeDef> badges = outcome.newBadges;
  final int stepCount = badges.length + (outcome.leveledUp ? 1 : 0);

  void showSummary() {
    navigator.pushReplacement(
      RiseRoute<void>(child: ResultScreen(outcome: outcome)),
    );
  }

  void showStep(int index) {
    if (index >= stepCount) {
      showSummary();
      return;
    }

    void next() => showStep(index + 1);

    final Widget screen = index < badges.length
        ? BadgeAwardScreen(badge: badges[index], onContinue: next)
        : LevelUpScreen(level: outcome.newLevel, onContinue: next);

    navigator.pushReplacement(RiseRoute<void>(child: screen));
  }

  showStep(0);
}
