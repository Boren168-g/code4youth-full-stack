import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';

/// Shared layout for the auth and onboarding routes.
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
  final Widget action;
  final Widget? secondaryAction;
  final VoidCallback? onBack;
  final bool showBack;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      // We allow the scaffold to resize normally
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Fixed Header (Doesn't scroll)
            SliverToBoxAdapter(
              child: Padding(
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
                          padding: const EdgeInsets.symmetric(horizontal: Space.md),
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
            ),

            // 2. Main Content and Buttons (All scrollable together)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, Space.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppType.h1.copyWith(color: context.textPrimary),
                    ),
                    const SizedBox(height: Space.sm),
                    Text(
                      subtitle,
                      style: AppType.body.copyWith(color: context.textSecondary),
                    ),
                    const SizedBox(height: Space.xl),
                    
                    // Form fields
                    ...children,
                    
                    // Push buttons to the bottom of the available space
                    const Spacer(),
                    const SizedBox(height: Space.xxl),
                    
                    // Buttons
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
