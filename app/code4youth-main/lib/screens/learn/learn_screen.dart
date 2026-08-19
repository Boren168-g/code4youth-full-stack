import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../data/curriculum.dart';
import '../../models/content.dart';
import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/cards.dart';
import '../../widgets/progress.dart';
import 'module_detail_screen.dart';

/// The module list.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

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
        Text(l10n.learn, style: AppType.h1.copyWith(color: context.textPrimary)),
        const SizedBox(height: Space.sm),
        Text(
          l10n.learnDescription,
          style: AppType.body.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: Space.xl),

        C4YCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      l10n.courseProgress,
                      style: AppType.bodyStrong.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    l10n.lessonsCount(state.lessonsCompleted, state.totalLessons),
                    style: AppType.caption.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
              C4YProgressBar(value: state.courseProgress),
            ],
          ),
        ),
        const SizedBox(height: Space.xl),

        for (final Module module in Curriculum.modules) ...<Widget>[
          ModuleCard(
            module: module,
            completed: state.completedInModule(module.id),
            locked: state.isModuleLocked(module),
            unlockRequirement: state.unlockRequirement(module),
            onTap: () => Navigator.of(context).push(
              FadeRoute<void>(child: ModuleDetailScreen(module: module)),
            ),
            onUnlockTap: () {
              final Module? required = Curriculum.moduleById(
                module.requiresModuleId!,
              );
              if (required == null) return;
              Navigator.of(context).push(
                FadeRoute<void>(child: ModuleDetailScreen(module: required)),
              );
            },
          ),
          const SizedBox(height: Space.md),
        ],
      ],
    );
  }
}
