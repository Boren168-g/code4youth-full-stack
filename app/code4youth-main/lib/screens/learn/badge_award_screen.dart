import 'package:flutter/material.dart';

import '../../models/gamification.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';

/// A badge unlock, played the moment it is earned.
///
/// The scale-and-pop is a hand-built stand-in for the Lottie animation the
/// design system specifies — same motion, same sub-300 ms budget, no asset.
class BadgeAwardScreen extends StatefulWidget {
  const BadgeAwardScreen({
    super.key,
    required this.badge,
    required this.onContinue,
  });

  final BadgeDef badge;
  final VoidCallback onContinue;

  @override
  State<BadgeAwardScreen> createState() => _BadgeAwardScreenState();
}

class _BadgeAwardScreenState extends State<BadgeAwardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: Motion.slow,
  );

  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    _pop.forward();
    _shimmer.repeat();
  }

  @override
  void dispose() {
    _pop.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Space.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Badge unlocked',
                        style: AppType.captionStrong.copyWith(
                          color: context.accentStrong,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: Space.xl),

                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _pop,
                          curve: Motion.reward,
                        ),
                        child: _BadgeMedal(
                          icon: widget.badge.icon,
                          shimmer: _shimmer,
                        ),
                      ),

                      const SizedBox(height: Space.xxl),
                      FadeTransition(
                        opacity: _pop,
                        child: Column(
                          children: <Widget>[
                            Text(
                              widget.badge.name,
                              textAlign: TextAlign.center,
                              style: AppType.display.copyWith(
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: Space.md),
                            Text(
                              widget.badge.description,
                              textAlign: TextAlign.center,
                              style: AppType.bodyLarge.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: C4YButton.accent(
                label: 'Claim badge',
                icon: Icons.workspace_premium_rounded,
                onPressed: widget.onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The medal itself: concentric Amber rings with a slow sweep of light.
class _BadgeMedal extends StatelessWidget {
  const _BadgeMedal({required this.icon, required this.shimmer});

  final IconData icon;
  final Animation<double> shimmer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: context.accentSubtle,
              shape: BoxShape.circle,
            ),
          ),
          AnimatedBuilder(
            animation: shimmer,
            builder: (BuildContext context, Widget? child) {
              return Transform.rotate(
                angle: shimmer.value * 6.283,
                child: child,
              );
            },
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: <Color>[
                    context.accent.withValues(alpha: 0.0),
                    context.accent.withValues(alpha: 0.55),
                    context.accent.withValues(alpha: 0.0),
                  ],
                  stops: const <double>[0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: context.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: Neutral.textPrimary),
          ),
        ],
      ),
    );
  }
}
