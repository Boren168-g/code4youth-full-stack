import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/brand.dart';
import '../shell.dart';
import 'consent_pending_screen.dart';
import 'welcome_screen.dart';

/// First frame after launch. Holds just long enough for the session check,
/// then routes to Home, the consent gate, or Welcome.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _resolveSession();
  }

  Future<void> _resolveSession() async {
    // Shorter delay
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final AppState state = context.read<AppState>();

    // Mirrors the Level 1 flow: valid session → Home; otherwise Welcome. An
    // account still waiting on guardian consent lands on the pending screen.
    final Widget destination = !state.isSignedIn
        ? const WelcomeScreen()
        : state.isActivated
        ? const AppShell()
        : const ConsentPendingScreen();

    Navigator.of(context).pushReplacement(
      FadeRoute<void>(child: destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.85, end: 1),
              duration: Motion.slow,
              curve: Motion.reward,
              builder: (BuildContext context, double scale, Widget? child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: const C4YLogo(size: 88),
            ),
            const SizedBox(height: Space.md),
            Text(
              'Learn to code on your phone',
              style: AppType.body.copyWith(color: context.textSecondary),
            ),
            const Spacer(),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                minHeight: 4,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: context.primaryTrack,
                color: context.primary,
              ),
            ),
            const SizedBox(height: Space.xxl),
            TextButton(
              onPressed: () async {
                try {
                  await context.read<AppState>().seedDatabase();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Database seeded!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error seeding: $e')),
                    );
                  }
                }
              },
              child: Text(
                'Seed Database',
                style: AppType.caption.copyWith(color: context.textSecondary.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: Space.md),
          ],
        ),
      ),
    );
  }
}
