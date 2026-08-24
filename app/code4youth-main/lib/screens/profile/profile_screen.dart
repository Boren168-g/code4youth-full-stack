import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/user.dart';
import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/cards.dart';
import '../../widgets/chips.dart';
import '../../widgets/buttons.dart';
import '../auth/guardian_consent_screen.dart';
import '../auth/welcome_screen.dart';
import '../progress/history_screen.dart';
import '../admin/admin_dashboard.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

/// The account screen: who you are, then everything you can change.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final UserProfile? user = state.user;
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.lg,
        Space.lg,
        Space.xxl,
      ),
      children: <Widget>[
        Text(
          l10n.profile,
          style: AppType.h1.copyWith(color: context.textPrimary),
        ),
        const SizedBox(height: Space.xl),

        if (user == null || user.displayName == 'Guest Learner') 
          _NoProfileCard()
        else
          _ProfileHeader(user: user, state: state),

        const SizedBox(height: Space.lg),

        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                icon: Icons.bolt_rounded,
                value: '${state.xp}',
                label: l10n.totalXp,
                color: context.accentStrong,
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: StatTile(
                icon: Icons.check_circle_rounded,
                value: '${state.lessonsCompleted}',
                label: l10n.lessonsDone,
                color: context.success,
              ),
            ),
          ],
        ),

        if (user?.consent == ConsentStatus.pending) ...<Widget>[
          const SizedBox(height: Space.lg),
          ConsentPendingNotice(
            guardianEmail: user?.guardianEmail ?? 'your guardian',
          ),
        ],

        const SizedBox(height: Space.xl),
        Text(
          l10n.account,
          style: AppType.h2.copyWith(color: context.textPrimary),
        ),
        const SizedBox(height: Space.md),

        _MenuGroup(
          items: <_MenuItem>[
            if (user?.isAdmin ?? false)
              _MenuItem(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Admin Dashboard',
                detail: 'Manage system, content, and users',
                onTap: () => Navigator.of(context).push(
                  FadeRoute<void>(child: const AdminDashboard()),
                ),
              ),
            if (user != null && user.displayName != 'Guest Learner')
              _MenuItem(
                icon: Icons.edit_rounded,
                label: l10n.editProfile,
                detail: 'Name, avatar, grade, interests',
                onTap: () => Navigator.of(context).push(
                  FadeRoute<void>(child: const EditProfileScreen()),
                ),
              ),
            _MenuItem(
              icon: Icons.sync_rounded,
              label: l10n.syncToDocker,
              detail: state.backendStatus.split('\n').last,
              onTap: () async {
                await state.checkBackendConnection();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.backendStatus)),
                  );
                }
              },
            ),
            _MenuItem(
              icon: Icons.history_rounded,
              label: l10n.lessonHistory,
              detail: '${state.history.length} completed',
              onTap: () => Navigator.of(context).push(
                FadeRoute<void>(child: const HistoryScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.settings_rounded,
              label: l10n.settings,
              detail: 'Theme, language, privacy',
              onTap: () => Navigator.of(context).push(
                FadeRoute<void>(child: const SettingsScreen()),
              ),
            ),
          ],
        ),
        
        if (user == null || user.displayName == 'Guest Learner') ...[
          const SizedBox(height: Space.xl),
          C4YButton.primary(
            label: l10n.signInToSave,
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              FadeRoute<void>(child: const WelcomeScreen()),
              (route) => false,
            ),
          ),
        ],
      ],
    );
  }
}

class _NoProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return C4YCard(
      child: Row(
        children: [
          const Text('🦊', style: TextStyle(fontSize: 36)),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.guestLearner, style: AppType.h2.copyWith(color: context.textPrimary)),
                Text('Sign in to customize your profile', style: AppType.caption.copyWith(color: context.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.state});
  final UserProfile user;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return C4YCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: context.primarySubtle,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user.avatar,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
              const SizedBox(width: Space.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.displayName,
                      style: AppType.h2.copyWith(
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      user.email,
                      style: AppType.caption.copyWith(
                        color: context.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Space.sm),
                    Wrap(
                      spacing: Space.sm,
                      runSpacing: Space.sm,
                      children: <Widget>[
                        if (user.isAdmin)
                          _Tag(label: 'ADMIN', isPrimary: true),
                        _Tag(label: user.grade),
                        _Tag(label: 'Level ${state.level}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user.interests.isNotEmpty) ...<Widget>[
            const SizedBox(height: Space.lg),
            Divider(color: context.divider),
            const SizedBox(height: Space.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wants to build',
                style: AppType.captionStrong.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: Space.sm),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: <Widget>[
                for (final String interest in user.interests)
                  _Tag(label: interest),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.isPrimary = false});

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.xs,
      ),
      decoration: BoxDecoration(
        color: isPrimary ? context.primary : context.primarySubtle,
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Text(
        label,
        style: AppType.caption.copyWith(
          color: isPrimary ? context.onPrimary : context.primary,
          fontWeight: isPrimary ? FontWeight.bold : null,
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final VoidCallback onTap;
}

/// A grouped list of navigation rows, each meeting the 48 dp touch minimum.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: context.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: items[i].onTap,
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: Sizes.minTouch + Space.sm,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.lg,
                    vertical: Space.md,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        items[i].icon,
                        size: Sizes.iconDefault,
                        color: context.primary,
                      ),
                      const SizedBox(width: Space.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              items[i].label,
                              style: AppType.body.copyWith(
                                color: context.textPrimary,
                              ),
                            ),
                            if (items[i].detail != null) ...<Widget>[
                              const SizedBox(height: 2),
                              Text(
                                items[i].detail!,
                                style: AppType.caption.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: Sizes.iconDefault,
                        color: context.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i < items.length - 1)
              Divider(color: context.divider, height: 1),
          ],
        ],
      ),
    );
  }
}
