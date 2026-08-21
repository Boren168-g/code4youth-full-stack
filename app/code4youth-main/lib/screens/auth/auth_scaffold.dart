import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';

/// Shared layout for the auth and onboarding routes.
///
/// The heading explains where the learner is, the form scrolls, and the
/// primary action follows the content. This prevents the keyboard from 
/// pushing the buttons over the input fields.
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

  /// The primary action button.
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
      // Fixed: Set to false to prevent the keyboard from pushing the whole screen up.
      // This keeps the buttons at the absolute bottom of the scroll view.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header with back button and progress bar
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
            
            // Content and Actions together in a scrollable view
            Expanded(
              child: SingleChildScrollView(
                // We add extra padding at the bottom so content isn't cut off by the keyboard
                padding: EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.lg,
                  Space.lg,
                  Space.xl + MediaQuery.viewInsetsOf(context).bottom,
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
                    
                    // Input fields/form content
                    ...children,
                    
                    const SizedBox(height: Space.xxl),
                    
                    // Buttons now follow the content instead of being pinned
                    action,
                    if (secondaryAction != null) ...<Widget>[
                      const SizedBox(height: Space.sm),
                      secondaryAction!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
