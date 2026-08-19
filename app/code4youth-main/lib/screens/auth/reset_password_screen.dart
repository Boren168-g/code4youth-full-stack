import 'package:flutter/material.dart';

import '../../router/app_router.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons.dart';
import '../../widgets/text_field.dart';
import 'auth_scaffold.dart';
import 'login_screen.dart';

/// Final step of a password reset. Returns to the login form on success, which
/// is where the learner expects to end up.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      FadeRoute<void>(child: const LoginScreen()),
      (Route<void> r) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed. Log in with your new one.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Choose a new password',
      subtitle: 'Make it something you will remember but others will not guess.',
      action: C4YButton.primary(
        label: 'Save new password',
        loading: _submitting,
        onPressed: _submit,
      ),
      children: <Widget>[
        Form(
          key: _form,
          child: Column(
            children: <Widget>[
              C4YTextField(
                label: 'New password',
                controller: _password,
                hint: 'At least 8 characters',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: true,
                autofillHints: const <String>[AutofillHints.newPassword],
                validator: Validators.password,
              ),
              const SizedBox(height: Space.lg),
              C4YTextField(
                label: 'Confirm new password',
                controller: _confirm,
                prefixIcon: Icons.lock_outline_rounded,
                obscure: true,
                validator: (String? v) =>
                    Validators.confirmPassword(v, _password.text),
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.shield_outlined,
              size: Sizes.iconInline,
              color: context.textSecondary,
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(
                'Changing your password signs you out on every other device.',
                style: AppType.caption.copyWith(color: context.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
