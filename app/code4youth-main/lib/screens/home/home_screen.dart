import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../data/curriculum.dart';
import '../../models/content.dart';
import '../../models/gamification.dart';
import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/cards.dart';
import '../../widgets/chips.dart';
import '../../widgets/feedback.dart';
import '../../widgets/progress.dart';
import '../learn/lesson_screen.dart';
import '../learn/module_detail_screen.dart';
import '../progress/history_screen.dart';
import '../shell.dart';

/// The dashboard.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Lesson? resume = state.resumableLesson;
    final Lesson? next = state.nextLesson;
    final Lesson? target = resume ?? next;
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.lg,
        Space.lg,
        Space.xxl,
      ),
      children: <Widget>[
        const _Greeting(),
        const SizedBox(height: Space.xl),

        if (!state.online) ...<Widget>[
          FeedbackBanner.notice(
            context,
            icon: Icons.cloud_off_rounded,
            title: 'You are offline',
            message: state.queuedEvents == 0
                ? 'Your downloaded lessons still work. Progress will sync when '
                      'you reconnect.'
                : '${state.queuedEvents} updates are saved on your phone and '
                      'will sync when you reconnect. Nothing is lost.',
          ),
          const SizedBox(height: Space.xl),
        ],

        const _LevelCard(),
        const SizedBox(height: Space.xl),

        if (target != null) ...<Widget>[
          _ContinueCard(lesson: target, resuming: resume != null),
          const SizedBox(height: Space.xl),
        ] else ...<Widget>[
          const _AllDoneCard(),
          const SizedBox(height: Space.xl),
        ],

        const _DailyGoal(),
        const SizedBox(height: Space.xl),

        SectionHeader(
          title: l10n.keepGoing,
          actionLabel: 'See all',
          onAction: () =>
              context.findAncestorStateOfType<AppShellState>()?.goToTab(1),
        ),
        const SizedBox(height: Space.md),
        const _CurrentModuleCard(),
        const SizedBox(height: Space.xl),

        SectionHeader(
          title: l10n.recentActivity,
          actionLabel: 'History',
          onAction: () => Navigator.of(context).push(
            FadeRoute<void>(child: const HistoryScreen()),
          ),
        ),
        const SizedBox(height: Space.md),
        const _RecentActivity(),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final String name = state.user?.displayName.split(' ').first ?? 'there';
    final int hour = DateTime.now().hour;
    final String part = hour < 12
        ? l10n.goodMorning
        : hour < 18
        ? l10n.goodAfternoon
        : l10n.goodEvening;

    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.primarySubtle,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            state.user?.avatar ?? '🦊',
            style: const TextStyle(fontSize: 26),
          ),
        ),
        const SizedBox(width: Space.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                part,
                style: AppType.caption.copyWith(color: context.textSecondary),
              ),
              Text(
                name,
                style: AppType.h2.copyWith(color: context.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        StatChip.streak(state.streakDays),
        const SizedBox(width: Space.sm),
        StatChip.xp(state.xp),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard();

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();

    return C4YCard(
      child: LevelProgress(
        level: state.level,
        title: state.levelTitle,
        progress: state.levelProgress,
        xpRemaining: state.xpToNextLevel,
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.lesson, required this.resuming});
  final Lesson lesson;
  final bool resuming;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Module module = Curriculum.moduleOf(lesson);
    final int savedStep = state.savedPosition(lesson.id);

    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: context.primary,
        borderRadius: Radii.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                resuming ? Icons.play_circle_rounded : Icons.school_rounded,
                size: Sizes.iconInline,
                color: context.onPrimary.withValues(alpha: 0.85),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  resuming ? 'Pick up where you stopped' : 'Up next',
                  style: AppType.captionStrong.copyWith(
                    color: context.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: context.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(Radii.chip),
                ),
                child: Text(
                  '${lesson.minutes} min',
                  style: AppType.caption.copyWith(color: context.onPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.md),
          Text(
            lesson.title,
            style: AppType.h1.copyWith(color: context.onPrimary),
          ),
          const SizedBox(height: Space.xs),
          Text(
            module.title,
            style: AppType.body.copyWith(
              color: context.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: Space.lg),
          if (resuming) ...<Widget>[
            C4YProgressBar(
              value: (savedStep + 1) / lesson.stepCount,
              color: context.onPrimary,
              trackColor: context.onPrimary.withValues(alpha: 0.25),
            ),
            const SizedBox(height: Space.sm),
            Text(
              'You stopped on step ${savedStep + 1} of ${lesson.stepCount}',
              style: AppType.caption.copyWith(
                color: context.onPrimary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: Space.lg),
          ],
          SizedBox(
            width: double.infinity,
            height: Sizes.buttonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Indigo.s700,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: Radii.buttonRadius,
                ),
                textStyle: AppType.button,
              ),
              onPressed: () => Navigator.of(context).push(
                FadeRoute<void>(child: LessonScreen(lesson: lesson)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      resuming ? 'Resume lesson' : 'Start lesson',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: Sizes.iconDefault,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard();

  @override
  Widget build(BuildContext context) {
    return C4YCard(
      color: context.successSubtle,
      borderColor: context.success.withValues(alpha: 0.4),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.emoji_events_rounded,
            size: Sizes.iconBadge,
            color: context.success,
          ),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Every lesson complete',
                  style: AppType.bodyStrong.copyWith(color: context.success),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  'You finished the whole curriculum. Revisit any lesson from '
                  'your history to practise.',
                  style: AppType.body.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoal extends StatelessWidget {
  const _DailyGoal();

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    const int weeklyTarget = 5;
    final int done = state.history
        .where(
          (HistoryEntry h) =>
              DateTime.now().difference(h.completedAt).inDays < 7,
        )
        .length
        .clamp(0, weeklyTarget);

    return C4YCard(
      child: Row(
        children: <Widget>[
          ProgressRing(
            value: done / weeklyTarget,
            size: 52,
            label: '$done/$weeklyTarget',
          ),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.thisWeek,
                  style: AppType.bodyStrong.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  done >= weeklyTarget
                      ? 'Weekly goal reached. Anything else is a bonus.'
                      : '${weeklyTarget - done} more lessons to hit your '
                            'weekly goal — about ${(weeklyTarget - done) * 10} '
                            'minutes.',
                  style: AppType.caption.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentModuleCard extends StatelessWidget {
  const _CurrentModuleCard();

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Module module = state.currentModule ?? Curriculum.modules.first;

    return ModuleCard(
      module: module,
      completed: state.completedInModule(module.id),
      locked: state.isModuleLocked(module),
      unlockRequirement: state.unlockRequirement(module),
      onTap: () => Navigator.of(context).push(
        FadeRoute<void>(child: ModuleDetailScreen(module: module)),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final List<HistoryEntry> recent = state.history.take(3).toList();

    if (recent.isEmpty) {
      return C4YCard(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.history_rounded,
              size: Sizes.iconFeature,
              color: context.textSecondary,
            ),
            const SizedBox(width: Space.lg),
            Expanded(
              child: Text(
                'Nothing here yet. Finish your first lesson and it will show '
                'up.',
                style: AppType.body.copyWith(color: context.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        for (final HistoryEntry entry in recent) ...<Widget>[
          C4YCard(
            padding: const EdgeInsets.all(Space.md),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.successSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: Sizes.iconInline,
                    color: context.success,
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.lessonTitle,
                        style: AppType.body.copyWith(
                          color: context.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        entry.moduleTitle,
                        style: AppType.caption.copyWith(
                          color: context.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatChip.xp(entry.xpEarned, compact: true),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
        ],
      ],
    );
  }
}
