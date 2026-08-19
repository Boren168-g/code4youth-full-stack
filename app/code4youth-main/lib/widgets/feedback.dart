import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Answer feedback.
///
/// Colour never carries the message on its own — every variant pairs its
/// colour with an icon and a sentence, so a learner who cannot distinguish
/// green from red still knows what happened.
class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.background,
    this.action,
  });

  /// "✓ Correct!" — Green.
  FeedbackBanner.correct(
    BuildContext context, {
    super.key,
    String? title,
    required this.message,
    this.action,
  }) : icon = Icons.check_circle_rounded,
       title = title ?? 'Correct!',
       color = context.success,
       background = context.successSubtle;

  /// "✕ Not quite. Try again." — Red.
  FeedbackBanner.incorrect(
    BuildContext context, {
    super.key,
    String? title,
    required this.message,
    this.action,
  }) : icon = Icons.cancel_rounded,
       title = title ?? 'Not quite. Try again.',
       color = context.error,
       background = context.errorSubtle;

  /// A neutral hint or note — Indigo.
  FeedbackBanner.info(
    BuildContext context, {
    super.key,
    required this.title,
    required this.message,
    this.action,
    IconData? icon,
  }) : icon = icon ?? Icons.lightbulb_rounded,
       color = context.primary,
       background = context.primarySubtle;

  /// A caution — Amber. Used for offline and consent-pending states.
  FeedbackBanner.notice(
    BuildContext context, {
    super.key,
    required this.title,
    required this.message,
    this.action,
    IconData? icon,
  }) : icon = icon ?? Icons.info_rounded,
       color = context.accentStrong,
       background = context.accentSubtle;

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Color background;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Space.lg),
        decoration: BoxDecoration(
          color: background,
          borderRadius: Radii.cardRadius,
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: color, size: Sizes.iconDefault),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppType.bodyStrong.copyWith(color: color),
                  ),
                  if (message.isNotEmpty) ...<Widget>[
                    const SizedBox(height: Space.xs),
                    Text(
                      message,
                      style: AppType.body.copyWith(color: context.textPrimary),
                    ),
                  ],
                  if (action != null) ...<Widget>[
                    const SizedBox(height: Space.md),
                    action!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An empty-state block for screens with nothing to show yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: context.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: Sizes.iconBadge, color: context.primary),
            ),
            const SizedBox(height: Space.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppType.h2.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: Space.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppType.body.copyWith(color: context.textSecondary),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: Space.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// The floating "+25 XP" that animates in at the moment a challenge is passed,
/// so the reward lands on the behaviour that produced it.
class XpBurst extends StatefulWidget {
  const XpBurst({super.key, required this.xp});

  final int xp;

  @override
  State<XpBurst> createState() => _XpBurstState();
}

class _XpBurstState extends State<XpBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.slow,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> scale = CurvedAnimation(
      parent: _controller,
      curve: Motion.reward,
    );

    return ScaleTransition(
      scale: scale,
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.lg,
            vertical: Space.sm,
          ),
          decoration: BoxDecoration(
            color: context.accentSubtle,
            borderRadius: BorderRadius.circular(Radii.chip),
            border: Border.all(color: context.accent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.bolt_rounded,
                size: Sizes.iconDefault,
                color: context.accentStrong,
              ),
              const SizedBox(width: Space.xs),
              Text(
                '+${widget.xp} XP',
                style: AppType.bodyStrong.copyWith(color: context.accentStrong),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
