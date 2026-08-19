import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/curriculum.dart';
import '../../models/content.dart';
import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/feedback.dart';
import '../../widgets/progress.dart';
import '../shell.dart';
import 'lesson_screen.dart';

/// Lesson complete.
///
/// The summary is honest about how the challenge went — first try or third —
/// because a learner who retried still finished, and the screen should say so
/// without pretending the retries did not happen.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.outcome});

  final LessonOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Lesson lesson = outcome.lesson;
    final Module module = Curriculum.moduleOf(lesson);
    final bool moduleDone = state.isModuleComplete(module.id);
    final Lesson? next = state.nextLesson;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.xxl,
                  Space.lg,
                  Space.xl,
                ),
                children: <Widget>[
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.7, end: 1),
                      duration: Motion.slow,
                      curve: Motion.reward,
                      builder:
                          (BuildContext context, double v, Widget? child) =>
                              Transform.scale(scale: v, child: child),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: context.successSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: Sizes.iconBadge,
                          color: context.success,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  Text(
                    'Lesson complete',
                    textAlign: TextAlign.center,
                    style: AppType.h1.copyWith(color: context.textPrimary),
                  ),
                  const SizedBox(height: Space.sm),
                  Text(
                    lesson.title,
                    textAlign: TextAlign.center,
                    style: AppType.body.copyWith(color: context.textSecondary),
                  ),
                  const SizedBox(height: Space.xxl),

                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _ResultStat(
                          icon: Icons.bolt_rounded,
                          value: '+${outcome.xpEarned}',
                          label: 'XP earned',
                          color: context.accentStrong,
                          background: context.accentSubtle,
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: _ResultStat(
                          icon: outcome.firstTry
                              ? Icons.star_rounded
                              : Icons.refresh_rounded,
                          value: outcome.firstTry
                              ? 'First try'
                              : '${outcome.attempts} tries',
                          label: 'Challenge',
                          color: outcome.firstTry
                              ? context.success
                              : context.primary,
                          background: outcome.firstTry
                              ? context.successSubtle
                              : context.primarySubtle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.lg),

                  C4YCard(
                    child: LevelProgress(
                      level: state.level,
                      title: state.levelTitle,
                      progress: state.levelProgress,
                      xpRemaining: state.xpToNextLevel,
                    ),
                  ),
                  const SizedBox(height: Space.lg),

                  C4YCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                module.title,
                                style: AppType.bodyStrong.copyWith(
                                  color: context.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${state.completedInModule(module.id)}/'
                              '${module.lessonCount}',
                              style: AppType.captionStrong.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Space.md),
                        C4YProgressBar(
                          value: state.moduleProgress(module.id),
                          color: moduleDone ? context.success : context.primary,
                        ),
                        if (moduleDone) ...<Widget>[
                          const SizedBox(height: Space.md),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.emoji_events_rounded,
                                size: Sizes.iconInline,
                                color: context.success,
                              ),
                              const SizedBox(width: Space.sm),
                              Expanded(
                                child: Text(
                                  'Module finished. The next one is unlocked.',
                                  style: AppType.caption.copyWith(
                                    color: context.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (outcome.queuedOffline) ...<Widget>[
                    const SizedBox(height: Space.lg),
                    FeedbackBanner.notice(
                      context,
                      icon: Icons.cloud_off_rounded,
                      title: 'Saved on your phone',
                      message: 'You are offline, so this result is queued and '
                          'will sync the moment you reconnect. Nothing is lost.',
                    ),
                  ],
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(Space.lg),
              decoration: BoxDecoration(
                color: context.surface,
                border: Border(top: BorderSide(color: context.divider)),
              ),
              child: Column(
                children: <Widget>[
                  if (next != null)
                    C4YButton.primary(
                      label: 'Next: ${next.title}',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => Navigator.of(context).pushReplacement(
                        FadeRoute<void>(child: LessonScreen(lesson: next)),
                      ),
                    )
                  else
                    C4YButton.primary(
                      label: 'Back to home',
                      icon: Icons.home_rounded,
                      onPressed: () => _goHome(context),
                    ),
                  if (next != null) ...<Widget>[
                    const SizedBox(height: Space.sm),
                    C4YButton.text(
                      label: 'Back to home',
                      fullWidth: true,
                      onPressed: () => _goHome(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      FadeRoute<void>(child: const AppShell()),
      (Route<void> r) => false,
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: Radii.cardRadius,
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: Sizes.iconFeature, color: color),
          const SizedBox(height: Space.sm),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppType.h2.copyWith(color: color),
          ),
          const SizedBox(height: Space.xs),
          Text(
            label,
            style: AppType.caption.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
