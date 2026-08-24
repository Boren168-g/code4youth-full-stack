import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        leading: C4YIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Go back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: [
          Text(
            'System Management',
            style: AppType.h2.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: Space.md),
          _AdminCard(
            title: 'User Analytics',
            subtitle: 'View active learners and progress',
            icon: Icons.analytics_rounded,
            onTap: () {},
          ),
          const SizedBox(height: Space.md),
          _AdminCard(
            title: 'Content Management',
            subtitle: 'Edit modules and lessons',
            icon: Icons.library_books_rounded,
            onTap: () {},
          ),
          const SizedBox(height: Space.md),
          _AdminCard(
            title: 'System Logs',
            subtitle: 'Check for errors and sync events',
            icon: Icons.terminal_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return C4YCard(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: context.primarySubtle,
                borderRadius: Radii.cardRadius,
              ),
              child: Icon(icon, color: context.primary),
            ),
            const SizedBox(width: Space.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppType.bodyStrong.copyWith(color: context.textPrimary)),
                  Text(subtitle, style: AppType.caption.copyWith(color: context.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}
