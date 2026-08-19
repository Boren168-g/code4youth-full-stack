import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/curriculum.dart';
import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chips.dart';
import '../shell.dart';
import 'auth_scaffold.dart';
import 'guardian_consent_screen.dart';

/// Onboarding: grade, interests, avatar.
///
/// Three short steps rather than one long form. The grade answer decides
/// whether guardian consent is required, and the interests answer is what the
/// dashboard uses to explain why a module is worth doing.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<String> _avatars = <String>[
    '🦊', '🐼', '🦉', '🐯', '🐸', '🐧', '🦁', '🐨', '🦄', '🐙', '🐝', '🦖',
  ];

  int _step = 0;
  String? _grade;
  final Set<String> _interests = <String>{};
  String _avatar = _avatars.first;

  bool get _canAdvance => switch (_step) {
    0 => _grade != null,
    1 => _interests.isNotEmpty,
    _ => true,
  };

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    _finish();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step--);
  }

  void _finish() {
    final AppState state = context.read<AppState>();
    state.completeOnboarding(
      grade: _grade!,
      interests: _interests.toList(),
      avatar: _avatar,
    );

    // Under 18 goes to the guardian gate; everyone else goes straight in.
    final bool needsConsent = state.user?.isMinor ?? false;
    Navigator.of(context).pushAndRemoveUntil(
      FadeRoute<void>(
        child: needsConsent ? const GuardianConsentScreen() : const AppShell(),
      ),
      (Route<void> r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: switch (_step) {
        0 => 'What grade are you in?',
        1 => 'What do you want to build?',
        _ => 'Pick your avatar',
      },
      subtitle: switch (_step) {
        0 => 'This sets the reading level of your lessons. You can change it '
            'later.',
        1 => 'Choose as many as you like. We use this to order your modules.',
        _ => 'An emoji, not a photo. We do not ask for pictures of you.',
      },
      progress: (_step + 1) / 3,
      onBack: _back,
      action: C4YButton.primary(
        label: _step < 2 ? 'Continue' : 'Finish setup',
        icon: _step < 2 ? Icons.arrow_forward_rounded : Icons.check_rounded,
        onPressed: _canAdvance ? _next : null,
      ),
      secondaryAction: _step == 1
          ? C4YButton.text(
              label: 'Skip for now',
              fullWidth: true,
              onPressed: () => setState(() => _step++),
            )
          : null,
      children: <Widget>[
        AnimatedSwitcher(
          duration: Motion.base,
          child: switch (_step) {
            0 => _GradeStep(
              key: const ValueKey<int>(0),
              selected: _grade,
              onSelect: (String g) => setState(() => _grade = g),
            ),
            1 => _InterestStep(
              key: const ValueKey<int>(1),
              selected: _interests,
              onToggle: (String i) => setState(() {
                if (!_interests.remove(i)) _interests.add(i);
              }),
            ),
            _ => _AvatarStep(
              key: const ValueKey<int>(2),
              avatars: _avatars,
              selected: _avatar,
              onSelect: (String a) => setState(() => _avatar = a),
            ),
          },
        ),
      ],
    );
  }
}

class _GradeStep extends StatelessWidget {
  const _GradeStep({super.key, required this.selected, required this.onSelect});

  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: <Widget>[
        for (final String grade in Grades.all)
          SelectableChip(
            label: grade,
            selected: selected == grade,
            onTap: () => onSelect(grade),
          ),
      ],
    );
  }
}

class _InterestStep extends StatelessWidget {
  const _InterestStep({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: <Widget>[
        for (final (String label, IconData icon) in Interests.all)
          SelectableChip(
            label: label,
            icon: icon,
            selected: selected.contains(label),
            onTap: () => onToggle(label),
          ),
      ],
    );
  }
}

class _AvatarStep extends StatelessWidget {
  const _AvatarStep({
    super.key,
    required this.avatars,
    required this.selected,
    required this.onSelect,
  });

  final List<String> avatars;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: AnimatedContainer(
            duration: Motion.base,
            curve: Motion.reward,
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: context.primarySubtle,
              shape: BoxShape.circle,
              border: Border.all(color: context.primary, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(selected, style: const TextStyle(fontSize: 52)),
          ),
        ),
        const SizedBox(height: Space.xl),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: avatars.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: Space.md,
            crossAxisSpacing: Space.md,
            childAspectRatio: 1,
          ),
          itemBuilder: (BuildContext context, int i) {
            final String avatar = avatars[i];
            final bool isSelected = avatar == selected;
            return Semantics(
              button: true,
              selected: isSelected,
              label: 'Avatar ${i + 1}',
              child: Material(
                color: isSelected ? context.primarySubtle : context.surface,
                shape: CircleBorder(
                  side: BorderSide(
                    color: isSelected ? context.primary : context.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelect(avatar),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: Space.lg),
        Text(
          'You can change any of this later in your profile.',
          textAlign: TextAlign.center,
          style: AppType.caption.copyWith(color: context.textSecondary),
        ),
      ],
    );
  }
}
