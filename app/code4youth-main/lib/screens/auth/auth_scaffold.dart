import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';

/// Shared layout for the auth and onboarding routes.
///
/// The heading explains where the learner is, the form scrolls, and the
/// primary action is pinned to the bottom so it stays in thumb reach and never
/// hides behind the keyboard.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.action,
    this.secondaryAction,
    this.onBack,
    this.showBack = true,
    this.progress,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  /// The pinned primary action.
  final Widget action;

  final Widget? secondaryAction;
  final VoidCallback? onBack;
  final bool showBack;

  /// 0.0–1.0 for multi-step flows such as onboarding.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.sm),
              child: Row(
                children: <Widget>[
                  if (showBack)
                    C4YIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Go back',
                      onPressed: onBack ?? () => Navigator.of(context).pop(),
                    )
                  else
                    const SizedBox(width: Sizes.minTouch),
                  if (progress != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.md,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: context.primaryTrack,
                            color: context.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: Sizes.minTouch),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.lg,
                  Space.lg,
                  Space.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppType.h1.copyWith(color: context.textPrimary),
                    ),
                    const SizedBox(height: Space.sm),
                    Text(
                      subtitle,
                      style: AppType.body.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: Space.xl),
                    ...children,
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                Space.lg,
                Space.lg,
                Space.lg,
                Space.lg + MediaQuery.viewInsetsOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: context.surface,
                border: Border(top: BorderSide(color: context.divider)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  action,
                  if (secondaryAction != null) ...<Widget>[
                    const SizedBox(height: Space.sm),
                    secondaryAction!,
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
