import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/feedback.dart';
import '../shell.dart';
import 'welcome_screen.dart';

/// The holding state for an account waiting on guardian approval.
///
/// The account exists and the learner is signed in, but nothing is unlocked
/// until consent arrives. This is deliberately a full screen rather than a
/// dismissible banner.
class ConsentPendingScreen extends StatelessWidget {
  const ConsentPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final String guardian = state.user?.guardianEmail ?? 'your guardian';

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Space.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: Space.xxl),
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: context.accentSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mark_email_unread_rounded,
                          size: Sizes.iconBadge,
                          color: context.accentStrong,
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.xl),
                    Text(
                      'Almost there',
                      textAlign: TextAlign.center,
                      style: AppType.h1.copyWith(color: context.textPrimary),
                    ),
                    const SizedBox(height: Space.sm),
                    Text(
                      'We sent an approval link to $guardian. Once they open '
                      'it, your account unlocks and your first lesson is ready.',
                      textAlign: TextAlign.center,
                      style: AppType.body.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: Space.xxl),
                    const _WhatHappensNext(),
                    const SizedBox(height: Space.xl),
                    FeedbackBanner.info(
                      context,
                      title: 'Demo build',
                      message: 'No email was actually sent. Use the button '
                          'below to act as the guardian and approve the account.',
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Space.lg),
              decoration: BoxDecoration(
                color: context.surface,
                border: Border(top: BorderSide(color: context.divider)),
              ),
              child: Column(
                children: <Widget>[
                  C4YButton.primary(
                    label: 'Simulate guardian approval',
                    icon: Icons.verified_user_rounded,
                    onPressed: () {
                      context.read<AppState>().grantConsent();
                      Navigator.of(context).pushAndRemoveUntil(
                        FadeRoute<void>(child: const AppShell()),
                        (Route<void> r) => false,
                      );
                    },
                  ),
                  const SizedBox(height: Space.sm),
                  C4YButton.text(
                    label: 'Sign out',
                    fullWidth: true,
                    onPressed: () {
                      context.read<AppState>().signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        FadeRoute<void>(child: const WelcomeScreen()),
                        (Route<void> r) => false,
                      );
                    },
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

class _WhatHappensNext extends StatelessWidget {
  const _WhatHappensNext();

  static const List<(String, String)> _steps = <(String, String)>[
    (
      'They open the link',
      'It explains what the app teaches and exactly what data is stored.',
    ),
    (
      'They approve',
      'One tap. No account needed on their side.',
    ),
    (
      'You start learning',
      'Your first lesson opens straight away.',
    ),
  ];

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
          Text(
            'What happens next',
            style: AppType.bodyStrong.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: Space.lg),
          for (int i = 0; i < _steps.length; i++) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.primarySubtle,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: AppType.captionStrong.copyWith(
                      color: context.primary,
                    ),
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _steps[i].$1,
                        style: AppType.body.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _steps[i].$2,
                        style: AppType.caption.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < _steps.length - 1) const SizedBox(height: Space.lg),
          ],
        ],
      ),
    );
  }
}
