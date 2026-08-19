import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons.dart';
import '../../widgets/feedback.dart';
import '../../widgets/text_field.dart';
import '../shell.dart';
import 'auth_scaffold.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

/// Sign in to an existing account.
///
/// A failed attempt keeps the typed email, states plainly what went wrong, and
/// offers the password reset route rather than leaving the learner stuck.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _demoEmail = 'sokha.chan@example.com';
  static const String _demoPassword = 'learn1234';

  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _submitting = false;
  bool _failed = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _failed = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    await context.read<AppState>().signIn(
      _email.text.trim().toLowerCase(),
      _password.text,
    );

    if (!mounted) return;

    final bool ok = context.read<AppState>().isSignedIn;

    if (!ok) {
      setState(() {
        _submitting = false;
        _failed = true;
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      FadeRoute<void>(child: const AppShell()),
      (Route<void> r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Your progress is exactly where you left it.',
      action: C4YButton.primary(
        label: 'Log in',
        loading: _submitting,
        onPressed: _submit,
      ),
      secondaryAction: C4YButton.text(
        label: 'Create a new account',
        fullWidth: true,
        onPressed: () => Navigator.of(context).pushReplacement(
          FadeRoute<void>(child: const SignUpScreen()),
        ),
      ),
      children: <Widget>[
        if (_failed) ...<Widget>[
          FeedbackBanner.incorrect(
            context,
            title: 'That did not work',
            message: 'The email or password does not match an account. Check '
                'for a typo, or reset your password.',
            action: C4YButton.text(
              label: 'Reset my password',
              onPressed: () => Navigator.of(context).push(
                FadeRoute<void>(child: const ForgotPasswordScreen()),
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
        ],
        Form(
          key: _form,
          child: Column(
            children: <Widget>[
              C4YTextField(
                label: 'Email',
                controller: _email,
                hint: 'you@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.email],
                validator: Validators.email,
              ),
              const SizedBox(height: Space.lg),
              C4YTextField(
                label: 'Password',
                controller: _password,
                prefixIcon: Icons.lock_outline_rounded,
                obscure: true,
                autofillHints: const <String>[AutofillHints.password],
                validator: Validators.loginPassword,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: C4YButton.text(
            label: 'Forgot password?',
            onPressed: () => Navigator.of(context).push(
              FadeRoute<void>(child: const ForgotPasswordScreen()),
            ),
          ),
        ),
      ],
    );
  }
}
