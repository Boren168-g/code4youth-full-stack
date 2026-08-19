import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons.dart';
import '../../widgets/feedback.dart';
import '../../widgets/text_field.dart';
import 'auth_scaffold.dart';
import 'consent_pending_screen.dart';

/// Guardian consent for an under-18 account.
///
/// The account is created but cannot be used until a guardian responds, so
/// this screen is a gate rather than a notice. It also states plainly what
/// data is collected, because that is the question a guardian will ask.
class GuardianConsentScreen extends StatefulWidget {
  const GuardianConsentScreen({super.key});

  @override
  State<GuardianConsentScreen> createState() => _GuardianConsentScreenState();
}

class _GuardianConsentScreenState extends State<GuardianConsentScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    context.read<AppState>().submitGuardianEmail(_email.text.trim());
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadeRoute<void>(child: const ConsentPendingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? ownEmail = context.read<AppState>().user?.email;

    return AuthScaffold(
      showBack: false,
      title: 'One more step',
      subtitle: 'You told us you are under 18, so we need a parent or '
          'guardian to approve your account before you start.',
      action: C4YButton.primary(
        label: 'Send approval email',
        icon: Icons.send_rounded,
        loading: _submitting,
        onPressed: _submit,
      ),
      children: <Widget>[
        Form(
          key: _form,
          child: C4YTextField(
            label: 'Parent or guardian email',
            controller: _email,
            hint: 'guardian@example.com',
            prefixIcon: Icons.family_restroom_rounded,
            keyboardType: TextInputType.emailAddress,
            helper: 'We email them a link. Nothing is shared with anyone else.',
            validator: (String? v) =>
                Validators.guardianEmail(v, ownEmail: ownEmail),
          ),
        ),
        const SizedBox(height: Space.xl),
        const _DataDisclosure(),
      ],
    );
  }
}

/// What is collected, what is not, and how long it is kept.
class _DataDisclosure extends StatelessWidget {
  const _DataDisclosure();

  static const List<(IconData, String)> _collected = <(IconData, String)>[
    (Icons.badge_outlined, 'Your display name and email'),
    (Icons.school_outlined, 'Your grade and what you want to build'),
    (Icons.trending_up_rounded, 'Which lessons you finished and your score'),
  ];

  static const List<String> _notCollected = <String>[
    'Photos, contacts, or location',
    'Phone number or home address',
    'Anything shared with advertisers',
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
            'What we collect',
            style: AppType.bodyStrong.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: Space.md),
          for (final (IconData icon, String label) in _collected) ...<Widget>[
            _Line(icon: icon, label: label, color: context.textSecondary),
            const SizedBox(height: Space.sm),
          ],
          const SizedBox(height: Space.md),
          Text(
            'What we never collect',
            style: AppType.bodyStrong.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: Space.md),
          for (final String label in _notCollected) ...<Widget>[
            _Line(
              icon: Icons.block_rounded,
              label: label,
              color: context.success,
            ),
            const SizedBox(height: Space.sm),
          ],
          const SizedBox(height: Space.md),
          Divider(color: context.divider),
          const SizedBox(height: Space.md),
          Text(
            'You or your guardian can delete the account, and everything in '
            'it, at any time from Settings.',
            style: AppType.caption.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: Sizes.iconInline, color: color),
        const SizedBox(width: Space.sm),
        Expanded(
          child: Text(
            label,
            style: AppType.body.copyWith(color: context.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Reusable notice for screens that need to explain the limited state.
class ConsentPendingNotice extends StatelessWidget {
  const ConsentPendingNotice({super.key, required this.guardianEmail});

  final String guardianEmail;

  @override
  Widget build(BuildContext context) {
    return FeedbackBanner.notice(
      context,
      icon: Icons.hourglass_top_rounded,
      title: 'Waiting for approval',
      message: 'We emailed $guardianEmail. Your account opens as soon as they '
          'approve it.',
    );
  }
}
