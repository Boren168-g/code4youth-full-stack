import 'package:flutter/material.dart';

import '../../router/app_router.dart';
import '../../theme/tokens.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons.dart';
import '../../widgets/text_field.dart';
import 'auth_scaffold.dart';
import 'verify_otp_screen.dart';

/// Step one of a password reset: confirm which account.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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

    setState(() => _submitting = false);
    Navigator.of(context).push(
      FadeRoute<void>(
        child: VerifyOtpScreen(
          email: _email.text.trim(),
          purpose: OtpPurpose.passwordReset,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset your password',
      subtitle: 'Tell us the email on your account and we will send a code to '
          'it.',
      action: C4YButton.primary(
        label: 'Send code',
        loading: _submitting,
        onPressed: _submit,
      ),
      secondaryAction: C4YButton.text(
        label: 'Back to log in',
        fullWidth: true,
        onPressed: () => Navigator.of(context).pop(),
      ),
      children: <Widget>[
        Form(
          key: _form,
          child: C4YTextField(
            label: 'Email',
            controller: _email,
            hint: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.email],
            validator: Validators.email,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: Space.lg),
      ],
    );
  }
}
