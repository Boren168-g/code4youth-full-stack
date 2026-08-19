import 'dart:async';

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
import '../shell.dart';
import 'auth_scaffold.dart';
import 'onboarding_screen.dart';
import 'reset_password_screen.dart';

/// Why the code was sent — the two flows share this screen but end in
/// different places.
enum OtpPurpose { signUp, passwordReset }

/// Email verification.
///
/// In this build the correct code is always 123456 and it is shown on screen,
/// since there is no mail server behind it.
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.purpose,
  });

  final String email;
  final OtpPurpose purpose;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const String _expectedCode = '123456';

  final TextEditingController _code = TextEditingController();
  String? _error;
  bool _submitting = false;

  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return t.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  Future<void> _submit() async {
    final String? validation = Validators.otp(_code.text);
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // A wrong code returns the learner to this screen rather than dropping
    // them out of the flow.
    if (_code.text.trim() != _expectedCode) {
      setState(() {
        _submitting = false;
        _error = 'That code is not right. Check the email again, or ask for a '
            'new code.';
      });
      return;
    }

    setState(() => _submitting = false);
    if (!mounted) return;

    switch (widget.purpose) {
      case OtpPurpose.signUp:
        Navigator.of(context).pushReplacement(
          FadeRoute<void>(child: const OnboardingScreen()),
        );
      case OtpPurpose.passwordReset:
        Navigator.of(context).pushReplacement(
          FadeRoute<void>(child: const ResetPasswordScreen()),
        );
    }
  }

  void _skipVerification() {
    // A convenience for reviewing the build, not part of the product flow.
    final AppState state = context.read<AppState>();
    if (widget.purpose == OtpPurpose.passwordReset) {
      Navigator.of(context).pushReplacement(
        FadeRoute<void>(child: const ResetPasswordScreen()),
      );
      return;
    }
    if (state.isSignedIn && state.isActivated) {
      Navigator.of(context).pushAndRemoveUntil(
        FadeRoute<void>(child: const AppShell()),
        (Route<void> r) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(
        FadeRoute<void>(child: const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Check your email',
      subtitle: 'We sent a 6 digit code to ${widget.email}. It expires in '
          '10 minutes.',
      action: C4YButton.primary(
        label: 'Verify',
        loading: _submitting,
        onPressed: _submit,
      ),
      secondaryAction: C4YButton.text(
        label: _secondsLeft > 0
            ? 'Resend code in ${_secondsLeft}s'
            : 'Resend code',
        fullWidth: true,
        onPressed: _secondsLeft > 0
            ? null
            : () {
                _startCountdown();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('A new code is on its way.')),
                );
              },
      ),
      children: <Widget>[
        OtpField(
          controller: _code,
          errorText: _error,
          onCompleted: (_) => _submit(),
        ),
        const SizedBox(height: Space.xl),
        FeedbackBanner.info(
          context,
          title: 'Demo build',
          message: 'There is no mail server behind this screen. Use the code '
              '123456 to continue.',
          action: C4YButton.text(
            label: 'Fill it in for me',
            onPressed: () {
              _code.text = _expectedCode;
              setState(() => _error = null);
            },
          ),
        ),
        const SizedBox(height: Space.lg),
        Center(
          child: TextButton(
            onPressed: _skipVerification,
            child: Text(
              'Skip verification',
              style: AppType.caption.copyWith(color: context.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
