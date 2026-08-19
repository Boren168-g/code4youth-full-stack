import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/gamification.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/progress.dart';

/// The level-up moment.
///
/// This is one of the few places Poppins appears at Display size — reserving
/// it for moments like this is what keeps it distinctive everywhere else.
class LevelUpScreen extends StatefulWidget {
  const LevelUpScreen({
    super.key,
    required this.level,
    required this.onContinue,
  });

  final int level;
  final VoidCallback onContinue;

  @override
  State<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends State<LevelUpScreen>
    with SingleTickerProviderStateMixin {
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
    final AppState state = context.watch<AppState>();
    final Animation<double> pop = CurvedAnimation(
      parent: _controller,
      curve: Motion.reward,
    );

    return Scaffold(
      // The full-bleed Indigo panel marks this as a moment rather than a
      // screen. It is the only place the app fills the viewport with primary.
      backgroundColor: context.isDark ? Indigo.s900 : Indigo.s600,
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
                      FadeTransition(
                        opacity: _controller,
                        child: Text(
                          'LEVEL UP',
                          style: AppType.captionStrong.copyWith(
                            color: Amber.s300,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: Space.xl),

                      ScaleTransition(
                        scale: pop,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: Amber.s400, width: 3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${widget.level}',
                            style: AppType.display.copyWith(
                              fontSize: 72,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: Space.xxl),
                      FadeTransition(
                        opacity: _controller,
                        child: Column(
                          children: <Widget>[
                            Text(
                              state.levelTitle,
                              textAlign: TextAlign.center,
                              style: AppType.display.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: Space.md),
                            Text(
                              'You reached level ${widget.level}. New modules '
                              'and badges are within reach.',
                              textAlign: TextAlign.center,
                              style: AppType.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: Space.xxl),
                            _NextLevelHint(xp: state.xp),
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
              child: SizedBox(
                width: double.infinity,
                height: Sizes.buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Amber.s500,
                    foregroundColor: Neutral.textPrimary,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: Radii.buttonRadius,
                    ),
                    textStyle: AppType.button,
                  ),
                  onPressed: widget.onContinue,
                  child: const Text('Keep going'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextLevelHint extends StatelessWidget {
  const _NextLevelHint({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final int? remaining = Levels.remainingFor(xp);
    if (remaining == null) {
      return Text(
        'This is the highest level. Nothing left to climb.',
        textAlign: TextAlign.center,
        style: AppType.caption.copyWith(
          color: Colors.white.withValues(alpha: 0.75),
        ),
      );
    }

    return Column(
      children: <Widget>[
        C4YProgressBar(
          value: Levels.progressFor(xp),
          color: Amber.s400,
          trackColor: Colors.white.withValues(alpha: 0.2),
        ),
        const SizedBox(height: Space.sm),
        Text(
          '$remaining XP to level ${Levels.levelFor(xp) + 1}',
          style: AppType.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
