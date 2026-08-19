import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../auth/welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        leading: C4YIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Go back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.lg,
          Space.lg,
          Space.lg,
          Space.xxl,
        ),
        children: <Widget>[
          _Group(
            title: l10n.appearance,
            children: <Widget>[
              _SegmentedRow(
                label: l10n.theme,
                description: l10n.themeDescription,
                options: <(String, IconData, ThemeMode)>[
                  (l10n.system, Icons.brightness_auto_rounded, ThemeMode.system),
                  (l10n.light, Icons.light_mode_rounded, ThemeMode.light),
                  (l10n.dark, Icons.dark_mode_rounded, ThemeMode.dark),
                ],
                selected: state.themeMode,
                onSelect: (ThemeMode mode) =>
                    context.read<AppState>().setThemeMode(mode),
              ),
            ],
          ),

          _Group(
            title: l10n.language,
            children: <Widget>[
              _LanguageRow(
                label: 'English',
                sublabel: l10n.default_,
                selected: !state.isKhmer,
                onTap: () =>
                    context.read<AppState>().setLocale(const Locale('en')),
              ),
              _LanguageRow(
                label: 'ភាសាខ្មែរ',
                sublabel: 'Khmer — lesson text where it is translated',
                selected: state.isKhmer,
                onTap: () =>
                    context.read<AppState>().setLocale(const Locale('km')),
              ),
            ],
          ),

          _Group(
            title: l10n.learning,
            children: <Widget>[
              _SwitchRow(
                icon: Icons.notifications_rounded,
                label: l10n.dailyReminder,
                description: l10n.dailyReminderDesc,
                value: state.dailyReminder,
                onChanged: (bool v) =>
                    context.read<AppState>().setDailyReminder(v),
              ),
              _SwitchRow(
                icon: Icons.animation_rounded,
                label: l10n.reduceMotion,
                description: l10n.reduceMotionDesc,
                value: state.reduceMotion,
                onChanged: (bool v) =>
                    context.read<AppState>().setReduceMotion(v),
              ),
            ],
          ),

          _Group(
            title: l10n.data,
            children: <Widget>[
              _SwitchRow(
                icon: Icons.cloud_off_rounded,
                label: l10n.simulateOffline,
                description: state.queuedEvents == 0
                    ? l10n.simulateOfflineDesc
                    : l10n.updatesQueued(state.queuedEvents),
                value: !state.online,
                onChanged: (bool v) => context.read<AppState>().setOnline(!v),
              ),
              _InfoRow(
                icon: Icons.download_done_rounded,
                label: l10n.downloadedLessons,
                value: l10n.downloadedLessonsDesc(state.totalLessons),
              ),
            ],
          ),

          _Group(
            title: 'Backend (Firebase)',
            children: <Widget>[
              _InfoRow(
                icon: Icons.lan_rounded,
                label: 'Status',
                value: state.backendStatus,
                onTap: () => context.read<AppState>().checkBackendConnection(),
              ),
              _InfoRow(
                icon: Icons.sync_rounded,
                label: l10n.syncToDocker,
                value: l10n.pushProfile,
                onTap: () async {
                  await context.read<AppState>().checkBackendConnection();
                },
              ),
            ],
          ),

          _Group(
            title: l10n.privacy,
            children: <Widget>[
              _InfoRow(
                icon: Icons.policy_rounded,
                label: l10n.privacyPolicy,
                value: l10n.privacyPolicyDesc,
                onTap: () => _showPolicy(context),
              ),
              _InfoRow(
                icon: Icons.family_restroom_rounded,
                label: l10n.guardianConsent,
                value: switch (state.user?.consent) {
                  null => l10n.notRequired,
                  _ when state.isActivated => l10n.approved,
                  _ => l10n.waitingApproval,
                },
              ),
            ],
          ),

          const SizedBox(height: Space.xl),
          C4YButton.secondary(
            label: l10n.signOut,
            icon: Icons.logout_rounded,
            onPressed: () => _signOut(context),
          ),
          const SizedBox(height: Space.md),
          C4YButton.destructive(
            label: l10n.deleteAccount,
            icon: Icons.delete_outline_rounded,
            onPressed: () => _confirmDelete(context, l10n),
          ),
          const SizedBox(height: Space.md),
          Text(
            l10n.deleteWarning,
            textAlign: TextAlign.center,
            style: AppType.caption.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    context.read<AppState>().signOut();
    Navigator.of(context).pushAndRemoveUntil(
      FadeRoute<void>(child: const WelcomeScreen()),
      (Route<void> r) => false,
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteDesc),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepAccount),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.error),
            child: Text(l10n.deleteEverything),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<AppState>().deleteAccount();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      FadeRoute<void>(child: const WelcomeScreen()),
      (Route<void> r) => false,
    );
  }

  void _showPolicy(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController controller) =>
            ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                Space.sm,
                Space.lg,
                Space.xxl,
              ),
              children: <Widget>[
                Text(
                  'Privacy policy',
                  style: AppType.h2.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: Space.lg),
                for (final (String heading, String body) in _policy) ...<Widget>[
                  Text(
                    heading,
                    style: AppType.bodyStrong.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    body,
                    style: AppType.body.copyWith(color: context.textSecondary),
                  ),
                  const SizedBox(height: Space.lg),
                ],
              ],
            ),
      ),
    );
  }

  static const List<(String, String)> _policy = <(String, String)>[
    (
      'What we store',
      'Your display name, email, grade, chosen interests, and which lessons '
          'you finished. That is the whole list.',
    ),
    (
      'What we never store',
      'Photos, contacts, location, phone number, or home address. We do not '
          'sell or share anything with advertisers.',
    ),
    (
      'Guardian consent',
      'If you are under 18, your account stays inactive until a parent or '
          'guardian approves it by email.',
    ),
    (
      'How long we keep it',
      'Until you delete your account. Deleting removes everything within 30 '
          'days, including backups.',
    ),
    (
      'Offline data',
      'Lessons are cached on your phone so you are not charged twice for the '
          'same material. Clearing app data removes them.',
    ),
  ];
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: Space.md),
          child: Text(
            title,
            style: AppType.captionStrong.copyWith(
              color: context.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: Radii.cardRadius,
            border: Border.all(color: context.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                children[i],
                if (i < children.length - 1)
                  Divider(color: context.divider, height: 1),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.xl),
      ],
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  const _SegmentedRow({
    required this.label,
    required this.description,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final String description;
  final List<(String, IconData, ThemeMode)> options;
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppType.body.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: Space.xs),
          Text(
            description,
            style: AppType.caption.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: Space.md),
          Row(
            children: <Widget>[
              for (final (String name, IconData icon, ThemeMode mode)
                  in options) ...<Widget>[
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: mode == selected,
                    child: Material(
                      color: mode == selected
                          ? context.primary
                          : context.background,
                      borderRadius: Radii.buttonRadius,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => onSelect(mode),
                        child: Container(
                          height: Sizes.minTouch,
                          decoration: BoxDecoration(
                            borderRadius: Radii.buttonRadius,
                            border: Border.all(
                              color: mode == selected
                                  ? context.primary
                                  : context.divider,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                icon,
                                size: Sizes.iconInline,
                                color: mode == selected
                                    ? context.onPrimary
                                    : context.textSecondary,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                name,
                                style: AppType.navLabel.copyWith(
                                  color: mode == selected
                                      ? context.onPrimary
                                      : context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (mode != options.last.$3) const SizedBox(width: Space.sm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: Sizes.minTouch),
          padding: const EdgeInsets.all(Space.lg),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: AppType.body.copyWith(color: context.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: AppType.caption.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: Sizes.iconDefault,
                color: selected ? context.primary : context.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: Sizes.iconDefault, color: context.primary),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: AppType.body.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppType.caption.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Space.md),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: Sizes.minTouch),
          padding: const EdgeInsets.all(Space.lg),
          child: Row(
            children: <Widget>[
              Icon(icon, size: Sizes.iconDefault, color: context.primary),
              const SizedBox(width: Space.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: AppType.body.copyWith(color: context.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppType.caption.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: Sizes.iconDefault,
                  color: context.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
