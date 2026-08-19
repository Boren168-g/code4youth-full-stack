import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// A horizontal progress track. Indigo fill on an Indigo-100 track by default;
/// pass [color] for the Amber and Green variants used by rewards and
/// completed content.
class C4YProgressBar extends StatelessWidget {
  const C4YProgressBar({
    super.key,
    required this.value,
    this.height = Sizes.progressTrackHeight,
    this.color,
    this.trackColor,
    this.animate = true,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final Color fill = color ?? context.primary;
    final Color track = trackColor ?? context.primaryTrack;
    final double clamped = value.clamp(0.0, 1.0);

    return Semantics(
      value: '${(clamped * 100).round()} percent',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: SizedBox(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: ColoredBox(color: track)),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  final double width = c.maxWidth * clamped;
                  final Widget bar = Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(height),
                    ),
                  );
                  if (!animate) return bar;
                  return AnimatedContainer(
                    duration: Motion.slow,
                    curve: Motion.enter,
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(height),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Position inside a lesson — "Step 3 of 8" above the track.
///
/// Advancement has to feel tangible, so the count is spelled out rather than
/// left to the bar alone.
class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.current,
    required this.total,
    this.trailing,
  });

  /// One-based step number.
  final int current;
  final int total;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Step $current of $total',
              style: AppType.captionStrong.copyWith(color: context.primary),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
        const SizedBox(height: Space.sm),
        C4YProgressBar(value: total == 0 ? 0 : current / total),
      ],
    );
  }
}

/// Level and XP progress for the dashboard and profile.
///
/// The bar is Indigo because it tracks learning progress; the XP figures beside
/// it are Amber because they are the reward.
class LevelProgress extends StatelessWidget {
  const LevelProgress({
    super.key,
    required this.level,
    required this.title,
    required this.progress,
    required this.xpRemaining,
  });

  final int level;
  final String title;
  final double progress;

  /// XP still needed for the next level, or null at max level.
  final int? xpRemaining;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Level $level',
                    style: AppType.h2.copyWith(color: context.textPrimary),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    title,
                    style: AppType.caption.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              xpRemaining == null ? 'Max level' : '$xpRemaining XP to go',
              style: AppType.captionStrong.copyWith(color: context.accentStrong),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        C4YProgressBar(value: progress),
      ],
    );
  }
}

/// A compact ring used on module cards and the progress screen.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 44,
    this.color,
    this.label,
  });

  final double value;
  final double size;
  final Color? color;

  /// Text drawn in the middle. Defaults to a rounded percentage.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Color fill = color ?? context.primary;
    final double clamped = value.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.square(
            dimension: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: clamped),
              duration: Motion.slow,
              curve: Motion.enter,
              builder: (BuildContext context, double v, _) {
                return CircularProgressIndicator(
                  value: v,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  color: fill,
                  backgroundColor: context.primaryTrack,
                );
              },
            ),
          ),
          Text(
            label ?? '${(clamped * 100).round()}%',
            style: AppType.navLabel.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
