import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../router/app_router.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/brand.dart';
import '../../widgets/buttons.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

/// The unauthenticated entry point.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final List<(IconData, String, String)> promises = [
        (
          Icons.schedule_rounded,
          'Lessons under 20 minutes',
          'Learn on the bus or between classes. Stop anywhere and pick up '
              'exactly where you left off.',
        ),
        (
          Icons.wifi_off_rounded,
          'Works on your data plan',
          'Every lesson stays under 5 MB and is saved to your phone, so you '
              'never pay to download it twice.',
        ),
        (
          Icons.rocket_launch_rounded,
          'Build something real, early',
          'You write a working program in your first module — not after '
              'weeks of syntax drills.',
        ),
    ];

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Space.lg, Space.xxl, Space.lg, Space.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Center(child: C4YLogo(size: 72)),
                    const SizedBox(height: Space.xxl),
                    Text(
                      'Coding, on the phone you already have.',
                      style: AppType.h1.copyWith(color: context.textPrimary),
                    ),
                    const SizedBox(height: Space.md),
                    Text(
                      'No computer needed. No long sessions. Start with nothing and finish your first program today.',
                      style: AppType.bodyLarge.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: Space.xxl),
                    for (final (icon, title, body) in promises) ...<Widget>[
                      _Promise(icon: icon, title: title, body: body),
                      const SizedBox(height: Space.xl),
                    ],
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(Space.lg),
              decoration: BoxDecoration(color: context.surface, border: Border(top: BorderSide(color: context.divider))),
              child: Column(
                children: <Widget>[
                  C4YButton.primary(
                    label: l10n.startLearning,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => Navigator.of(context).push(FadeRoute<void>(child: const SignUpScreen())),
                  ),
                  const SizedBox(height: Space.md),
                  C4YButton.secondary(
                    label: l10n.alreadyHaveAccount,
                    onPressed: () => Navigator.of(context).push(FadeRoute<void>(child: const LoginScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Promise extends StatelessWidget {
  const _Promise({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: context.primarySubtle, borderRadius: BorderRadius.circular(Radii.button)),
          child: Icon(icon, size: Sizes.iconFeature, color: context.primary),
        ),
        const SizedBox(width: Space.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppType.bodyStrong.copyWith(color: context.textPrimary)),
              const SizedBox(height: Space.xs),
              Text(body, style: AppType.body.copyWith(color: context.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
