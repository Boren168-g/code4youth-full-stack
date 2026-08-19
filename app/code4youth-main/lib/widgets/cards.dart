import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../models/content.dart';
import '../models/gamification.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'chips.dart';
import 'progress.dart';

/// The base card. Structure comes from the surface colour and a hairline
/// border rather than from shadow.
class C4YCard extends StatelessWidget {
  const C4YCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Space.lg),
    this.color,
    this.borderColor,
    this.selected = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;

  /// Selected learning content is outlined in Indigo.
  final bool selected;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Color border = borderColor ??
        (selected ? context.primary : context.divider);

    final Widget body = AnimatedContainer(
      duration: Motion.fast,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.surface,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: border, width: selected ? 1.5 : 1),
      ),
      child: child,
    );

    if (onTap == null) {
      return semanticLabel == null
          ? body
          : Semantics(label: semanticLabel, child: body);
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: Radii.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.cardRadius,
          child: body,
        ),
      ),
    );
  }
}

/// A module on the Learn screen.
class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.completed,
    required this.locked,
    required this.unlockRequirement,
    required this.onTap,
    this.onUnlockTap,
  });

  final Module module;
  final int completed;
  final bool locked;

  /// Plain-language description of what must be finished first.
  final String? unlockRequirement;

  final VoidCallback onTap;

  /// Opens the prerequisite module directly.
  final VoidCallback? onUnlockTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int total = module.lessons.length;
    final bool done = total > 0 && completed == total;
    final double progress = total == 0 ? 0 : completed / total;
    final title = module.localizedTitle(context);
    final description = module.localizedDescription(context);

    final Color iconColor = locked
        ? context.muted
        : done
        ? context.success
        : context.primary;
    final Color iconBackground = locked
        ? (context.isDark ? Neutral.dividerDark : Neutral.divider)
        : done
        ? context.successSubtle
        : context.primarySubtle;

    return C4YCard(
      onTap: onTap,
      selected: !locked && !done && completed > 0,
      semanticLabel: locked
          ? '$title, locked. ${unlockRequirement ?? ''}'
          : '$title, $completed of $total lessons complete',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(Radii.button),
                ),
                child: Icon(
                  locked ? Icons.lock_rounded : module.icon,
                  size: Sizes.iconFeature,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: Space.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppType.bodyStrong.copyWith(
                        color: locked ? context.muted : context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      '$total ${l10n.lessons} · ${module.totalMinutes} ${l10n.minutes}',
                      style: AppType.caption.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (done)
                StatusPill.complete(context, label: l10n.earned)
              else if (locked)
                StatusPill.locked(context, label: l10n.locked),
            ],
          ),
          const SizedBox(height: Space.lg),
          Text(
            description,
            style: AppType.body.copyWith(
              color: locked ? context.muted : context.textSecondary,
            ),
          ),
          if (locked && unlockRequirement != null) ...<Widget>[
            const SizedBox(height: Space.lg),
            Container(
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: context.accentSubtle,
                borderRadius: BorderRadius.circular(Radii.button),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.key_rounded,
                    size: Sizes.iconInline,
                    color: context.accentStrong,
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      unlockRequirement!,
                      style: AppType.caption.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  if (onUnlockTap != null)
                    TextButton(
                      onPressed: onUnlockTap,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(Sizes.minTouch, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.sm,
                        ),
                      ),
                      child: const Text('Go'),
                    ),
                ],
              ),
            ),
          ] else ...<Widget>[
            const SizedBox(height: Space.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: C4YProgressBar(
                    value: progress,
                    color: done ? context.success : context.primary,
                    trackColor: done
                        ? context.successSubtle
                        : context.primaryTrack,
                  ),
                ),
                const SizedBox(width: Space.md),
                Text(
                  '$completed/$total',
                  style: AppType.captionStrong.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One lesson row inside a module.
class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.index,
    required this.completed,
    required this.locked,
    required this.inProgress,
    required this.onTap,
  });

  final Lesson lesson;

  /// One-based position within the module.
  final int index;

  final bool completed;
  final bool locked;
  final bool inProgress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = lesson.localizedTitle(context);
    
    // Completed is Green, current is Indigo, locked is neutral grey.
    final Color markColor = locked
        ? context.muted
        : completed
        ? context.success
        : context.primary;
    final Color markBackground = locked
        ? (context.isDark ? Neutral.dividerDark : Neutral.divider)
        : completed
        ? context.successSubtle
        : context.primarySubtle;

    return C4YCard(
      onTap: locked ? null : onTap,
      selected: inProgress,
      padding: const EdgeInsets.all(Space.md),
      semanticLabel: '$title. '
          '${completed ? 'Completed' : locked ? 'Locked' : 'Not started'}',
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: markBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: completed
                ? Icon(
                    Icons.check_rounded,
                    size: Sizes.iconInline,
                    color: markColor,
                  )
                : locked
                ? Icon(
                    Icons.lock_rounded,
                    size: Sizes.iconInline,
                    color: markColor,
                  )
                : Text(
                    '$index',
                    style: AppType.captionStrong.copyWith(color: markColor),
                  ),
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
                    fontWeight: inProgress ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: Space.xs),
                    Text(
                      '${lesson.minutes} ${l10n.minutes}',
                      style: AppType.caption.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(width: Space.md),
                    Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: context.accentStrong,
                    ),
                    const SizedBox(width: Space.xs),
                    Text(
                      '${lesson.xp + lesson.challenge.xp} XP',
                      style: AppType.caption.copyWith(
                        color: context.accentStrong,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (inProgress)
            StatusPill.inProgress(context, label: l10n.resume)
          else if (!locked)
            Icon(
              Icons.chevron_right_rounded,
              color: context.textSecondary,
              size: Sizes.iconDefault,
            ),
        ],
      ),
    );
  }
}

/// A badge in the grid on the Progress screen.
class BadgeTile extends StatelessWidget {
  const BadgeTile({
    super.key,
    required this.badge,
    required this.earned,
    this.onTap,
  });

  final BadgeDef badge;
  final bool earned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = earned ? context.accentStrong : context.muted;
    final Color background = earned
        ? context.accentSubtle
        : (context.isDark ? Neutral.dividerDark : Neutral.divider);

    return C4YCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.lg,
      ),
      borderColor: earned ? context.accent.withValues(alpha: 0.5) : null,
      semanticLabel: earned
          ? '${badge.name}, earned. ${badge.description}'
          : '${badge.name}, locked. ${badge.requirement}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: background, shape: BoxShape.circle),
            child: Icon(
              earned ? badge.icon : Icons.lock_rounded,
              size: Sizes.iconFeature,
              color: color,
            ),
          ),
          const SizedBox(height: Space.md),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppType.captionStrong.copyWith(
              color: earned ? context.textPrimary : context.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// A section heading with an optional trailing text action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: AppType.h2.copyWith(color: context.textPrimary),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: const Size(Sizes.minTouch, Sizes.textButtonHeight),
              padding: const EdgeInsets.symmetric(horizontal: Space.sm),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
