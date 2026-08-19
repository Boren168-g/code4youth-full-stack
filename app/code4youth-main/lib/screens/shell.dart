import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/bottom_nav.dart';
import 'home/home_screen.dart';
import 'learn/learn_screen.dart';
import 'profile/profile_screen.dart';
import 'progress/progress_screen.dart';

/// The signed-in container: four destinations behind a bottom navigation bar.
///
/// Tabs are kept alive in an [IndexedStack] so scroll position and in-progress
/// state survive switching between them.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  /// Lets a child screen move the shell — "See all" on Home opens the Learn
  /// tab rather than pushing a duplicate route.
  void goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: const <Widget>[
            HomeScreen(),
            LearnScreen(),
            ProgressScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: C4YBottomNav(
        currentIndex: _index,
        onSelected: goToTab,
      ),
    );
  }
}
