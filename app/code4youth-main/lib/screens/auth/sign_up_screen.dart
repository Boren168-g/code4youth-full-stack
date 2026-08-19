import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons.dart';
import '../../widgets/text_field.dart';
import 'auth_scaffold.dart';
import 'login_screen.dart';
import 'verify_otp_screen.dart';

/// Account creation.
///
/// Nothing is submitted until every field validates and the privacy policy is
/// explicitly accepted — a minor's account cannot be created by accident.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _acceptedPolicy = false;
  bool _showPolicyError = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final bool fieldsValid = _form.currentState?.validate() ?? false;

    // The policy check is validated alongside the fields rather than blocking
    // silently, so the learner sees every problem at once.
    setState(() => _showPolicyError = !_acceptedPolicy);
    if (!fieldsValid || !_acceptedPolicy) return;

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    context.read<AppState>().register(
      displayName: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    setState(() => _submitting = false);
    if (!mounted) return;
    Navigator.of(context).push(
      FadeRoute<void>(
        child: VerifyOtpScreen(email: _email.text.trim(), purpose: OtpPurpose.signUp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'You need an email address and a password. Nothing else.',
      action: C4YButton.primary(
        label: 'Create account',
        loading: _submitting,
        onPressed: _submit,
      ),
      secondaryAction: C4YButton.text(
        label: 'I already have an account',
        fullWidth: true,
        onPressed: () => Navigator.of(context).pushReplacement(
          FadeRoute<void>(child: const LoginScreen()),
        ),
      ),
      children: <Widget>[
        Form(
          key: _form,
          child: Column(
            children: <Widget>[
              C4YTextField(
                label: 'Display name',
                controller: _name,
                hint: 'What should other learners call you?',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                autofillHints: const <String>[AutofillHints.name],
                validator: Validators.displayName,
              ),
              const SizedBox(height: Space.lg),
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
                hint: 'At least 8 characters',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: true,
                autofillHints: const <String>[AutofillHints.newPassword],
                validator: Validators.password,
              ),
              const SizedBox(height: Space.lg),
              C4YTextField(
                label: 'Confirm password',
                controller: _confirm,
                hint: 'Type it once more',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: true,
                validator: (String? v) =>
                    Validators.confirmPassword(v, _password.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.xl),
        _PolicyCheck(
          value: _acceptedPolicy,
          showError: _showPolicyError,
          onChanged: (bool v) => setState(() {
            _acceptedPolicy = v;
            if (v) _showPolicyError = false;
          }),
        ),
      ],
    );
  }
}

/// Explicit, unticked-by-default consent to the privacy policy.
class _PolicyCheck extends StatelessWidget {
  const _PolicyCheck({
    required this.value,
    required this.showError,
    required this.onChanged,
  });

  final bool value;
  final bool showError;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.button),
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(Radii.button),
            child: Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: Sizes.minTouch,
                    height: Sizes.minTouch,
                    child: Checkbox(
                      value: value,
                      onChanged: (bool? v) => onChanged(v ?? false),
                      activeColor: context.primary,
                      side: BorderSide(
                        color: showError ? context.error : context.textSecondary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: Space.md),
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: context.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '. If you are under 18 we will ask a parent '
                                  'or guardian to approve your account.',
                            ),
                          ],
                        ),
                        style: AppType.body.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: Space.sm, top: Space.xs),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.error_outline_rounded,
                  size: Sizes.iconInline,
                  color: context.error,
                ),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Text(
                    'You need to accept the Privacy Policy to continue.',
                    style: AppType.caption.copyWith(color: context.error),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
