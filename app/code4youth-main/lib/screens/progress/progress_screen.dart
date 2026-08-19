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
import '../../widgets/progress.dart';
import 'history_screen.dart';

/// Progress and badges.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.lg,
        Space.lg,
        Space.xxl,
      ),
      children: <Widget>[
        Text(
          l10n.progress,
          style: AppType.h1.copyWith(color: context.textPrimary),
        ),
        const SizedBox(height: Space.xl),

        C4YCard(
          child: Column(
            children: <Widget>[
              LevelProgress(
                level: state.level,
                title: state.levelTitle,
                progress: state.levelProgress,
                xpRemaining: state.xpToNextLevel,
              ),
              const SizedBox(height: Space.lg),
              Divider(color: context.divider),
              const SizedBox(height: Space.lg),
              Row(
                children: <Widget>[
                  ProgressRing(value: state.courseProgress, size: 56),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.wholeCourse,
                          style: AppType.bodyStrong.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: Space.xs),
                        Text(
                          l10n.lessonsFinished(state.lessonsCompleted, state.totalLessons),
                          style: AppType.caption.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.xl),

        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                icon: Icons.bolt_rounded,
                value: '${state.xp}',
                label: l10n.totalXp,
                color: context.accentStrong,
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: StatTile(
                icon: Icons.local_fire_department_rounded,
                value: '${state.streakDays}',
                label: l10n.dayStreak,
                color: context.accentStrong,
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                icon: Icons.workspace_premium_rounded,
                value: '${state.earnedBadges.length}/${Badges.all.length}',
                label: l10n.badges,
                color: context.accentStrong,
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: StatTile(
                icon: Icons.star_rounded,
                value: '${state.firstTryCorrect}',
                label: l10n.firstTryAnswers,
                color: context.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.xl),

        SectionHeader(
          title: l10n.badges,
          actionLabel: l10n.history,
          onAction: () => Navigator.of(context).push(
            FadeRoute<void>(child: const HistoryScreen()),
          ),
        ),
        const SizedBox(height: Space.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: Badges.all.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: Space.md,
            crossAxisSpacing: Space.md,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (BuildContext context, int i) {
            final BadgeDef badge = Badges.all[i];
            final bool earned = state.hasBadge(badge.id);
            return BadgeTile(
              badge: badge,
              earned: earned,
              onTap: () => _showBadgeSheet(context, badge, earned),
            );
          },
        ),
        const SizedBox(height: Space.xl),

        Text(
          l10n.byModule,
          style: AppType.h2.copyWith(color: context.textPrimary),
        ),
        const SizedBox(height: Space.md),
        for (final Module module in Curriculum.modules) ...<Widget>[
          _ModuleProgressRow(module: module),
          const SizedBox(height: Space.sm),
        ],
      ],
    );
  }

  void _showBadgeSheet(BuildContext context, BadgeDef badge, bool earned) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
          Space.lg,
          Space.sm,
          Space.lg,
          Space.xl + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: earned
                    ? context.accentSubtle
                    : (context.isDark ? Neutral.dividerDark : Neutral.divider),
                shape: BoxShape.circle,
              ),
              child: Icon(
                earned ? badge.icon : Icons.lock_rounded,
                size: Sizes.iconBadge,
                color: earned ? context.accentStrong : context.muted,
              ),
            ),
            const SizedBox(height: Space.lg),
            Text(
              badge.name,
              style: AppType.h2.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: Space.sm),
            Text(
              earned ? badge.description : badge.requirement,
              textAlign: TextAlign.center,
              style: AppType.body.copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: Space.lg),
            earned
                ? StatusPill.complete(context, label: l10n.earned)
                : StatusPill.locked(context, label: l10n.notYetEarned),
          ],
        ),
      ),
    );
  }
}

class _ModuleProgressRow extends StatelessWidget {
  const _ModuleProgressRow({required this.module});
  final Module module;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final int done = state.completedInModule(module.id);
    final bool complete = state.isModuleComplete(module.id);
    final bool locked = state.isModuleLocked(module);
    final title = module.localizedTitle(context);

    return C4YCard(
      padding: const EdgeInsets.all(Space.md),
      child: Row(
        children: <Widget>[
          Icon(
            locked ? Icons.lock_rounded : module.icon,
            size: Sizes.iconDefault,
            color: locked
                ? context.muted
                : complete
                ? context.success
                : context.primary,
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppType.body.copyWith(
                    color: locked ? context.muted : context.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Space.sm),
                C4YProgressBar(
                  value: state.moduleProgress(module.id),
                  height: 6,
                  color: complete ? context.success : context.primary,
                  trackColor: complete
                      ? context.successSubtle
                      : context.primaryTrack,
                ),
              ],
            ),
          ),
          const SizedBox(width: Space.md),
          Text(
            '$done/${module.lessonCount}',
            style: AppType.captionStrong.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
