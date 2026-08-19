import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// The reward metrics, in Amber. Surfaced anywhere progress can change so
/// effort is never invisible.
class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.semanticLabel,
    this.color,
    this.background,
    this.compact = false,
  });

  // Not const: the label is interpolated from a runtime value.
  // ignore: prefer_const_constructors_in_immutables
  StatChip.xp(int xp, {super.key, this.compact = false})
    : icon = Icons.bolt_rounded,
      value = '$xp',
      semanticLabel = '$xp experience points',
      color = null,
      background = null;

  // ignore: prefer_const_constructors_in_immutables
  StatChip.streak(int days, {super.key, this.compact = false})
    : icon = Icons.local_fire_department_rounded,
      value = '$days',
      semanticLabel = '$days day streak',
      color = null,
      background = null;

  final IconData icon;
  final String value;
  final String semanticLabel;
  final Color? color;
  final Color? background;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color fg = color ?? context.accentStrong;
    final Color bg = background ?? context.accentSubtle;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? Space.sm : Space.md,
          vertical: compact ? Space.xs : Space.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Radii.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: Sizes.iconInline, color: fg),
            const SizedBox(width: Space.xs),
            Text(
              value,
              style: AppType.captionStrong.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled statistic for the progress and profile screens.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: context.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: Sizes.iconFeature, color: color),
          const SizedBox(height: Space.md),
          Text(
            value,
            style: AppType.h1.copyWith(color: context.textPrimary),
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

/// A selectable pill, used for grades and interests during onboarding.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? context.onPrimary : context.textPrimary;
    final Color bg = selected ? context.primary : context.surface;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.chip),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: Motion.fast,
            constraints: const BoxConstraints(minHeight: Sizes.minTouch),
            padding: const EdgeInsets.symmetric(
              horizontal: Space.lg,
              vertical: Space.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.chip),
              border: Border.all(
                color: selected ? context.primary : context.divider,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: Sizes.iconInline, color: fg),
                  const SizedBox(width: Space.sm),
                ],
                Text(label, style: AppType.body.copyWith(color: fg)),
                // Selection is carried by a check as well as by colour, so it
                // does not depend on colour perception alone.
                if (selected) ...<Widget>[
                  const SizedBox(width: Space.sm),
                  Icon(Icons.check_rounded, size: Sizes.iconInline, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small status label. Always pairs its colour with an icon and words, so
/// state is never communicated by colour alone.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  /// Completed content — Green.
  StatusPill.complete(BuildContext context, {super.key, String? label})
    : icon = Icons.check_circle_rounded,
      label = label ?? 'Completed',
      color = context.success,
      background = context.successSubtle;

  /// Current content — Indigo.
  StatusPill.inProgress(BuildContext context, {super.key, String? label})
    : icon = Icons.play_circle_rounded,
      label = label ?? 'In progress',
      color = context.primary,
      background = context.primarySubtle;

  /// Locked content — neutral grey with reduced emphasis.
  StatusPill.locked(BuildContext context, {super.key, String? label})
    : icon = Icons.lock_rounded,
      label = label ?? 'Locked',
      color = context.textSecondary,
      background = context.isDark ? Neutral.dividerDark : Neutral.divider;

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: Sizes.iconInline, color: color),
          const SizedBox(width: Space.xs),
          Text(label, style: AppType.captionStrong.copyWith(color: color)),
        ],
      ),
    );
  }
}
