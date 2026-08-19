import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

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
import 'lesson_screen.dart';

/// Every lesson in one module, in order.
class ModuleDetailScreen extends StatelessWidget {
  const ModuleDetailScreen({super.key, required this.module});

  final Module module;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool moduleLocked = state.isModuleLocked(module);
    final int completed = state.completedInModule(module.id);
    final l10n = AppLocalizations.of(context)!;
    final title = module.localizedTitle(context);
    final description = module.localizedDescription(context);

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        leading: C4YIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Go back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.lg,
          Space.sm,
          Space.lg,
          Space.xxl,
        ),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: moduleLocked
                      ? (context.isDark ? Neutral.dividerDark : Neutral.divider)
                      : context.primarySubtle,
                  borderRadius: BorderRadius.circular(Radii.card),
                ),
                child: Icon(
                  moduleLocked ? Icons.lock_rounded : module.icon,
                  size: Sizes.iconFeature,
                  color: moduleLocked ? context.muted : context.primary,
                ),
              ),
              const SizedBox(width: Space.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppType.h2.copyWith(color: context.textPrimary),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      '${module.lessonCount} ${l10n.lessons} · '
                      '${module.totalMinutes} ${l10n.minutes} total',
                      style: AppType.caption.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          Text(
            description,
            style: AppType.bodyLarge.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: Space.xl),

          if (moduleLocked) ...<Widget>[
            FeedbackBanner.notice(
              context,
              icon: Icons.lock_rounded,
              title: l10n.thisModuleIsLocked,
              message:
                  state.unlockRequirement(module) ??
                  l10n.finishPreviousModule,
              action: C4YButton.text(
                label: 'Open ${Curriculum.moduleById(module.requiresModuleId!)?.localizedTitle(context) ?? 'the previous module'}',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  final Module? required = Curriculum.moduleById(
                    module.requiresModuleId!,
                  );
                  if (required == null) return;
                  Navigator.of(context).pushReplacement(
                    FadeRoute<void>(
                      child: ModuleDetailScreen(module: required),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Space.xl),
          ] else ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: C4YProgressBar(
                    value: state.moduleProgress(module.id),
                  ),
                ),
                const SizedBox(width: Space.md),
                Text(
                  '$completed/${module.lessonCount}',
                  style: AppType.captionStrong.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.xl),
          ],

          Text(
            l10n.lessons,
            style: AppType.h2.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: Space.md),

          for (int i = 0; i < module.lessons.length; i++) ...<Widget>[
            Builder(
              builder: (BuildContext context) {
                final Lesson lesson = module.lessons[i];
                final bool done = state.isLessonComplete(lesson.id);

                final bool previousDone =
                    i == 0 ||
                    state.isLessonComplete(module.lessons[i - 1].id);
                final bool locked = moduleLocked || !previousDone;

                return LessonTile(
                  lesson: lesson,
                  index: i + 1,
                  completed: done,
                  locked: locked,
                  inProgress: state.hasSavedPosition(lesson.id),
                  onTap: () => Navigator.of(context).push(
                    FadeRoute<void>(child: LessonScreen(lesson: lesson)),
                  ),
                );
              },
            ),
            const SizedBox(height: Space.sm),
          ],
        ],
      ),
    );
  }
}
