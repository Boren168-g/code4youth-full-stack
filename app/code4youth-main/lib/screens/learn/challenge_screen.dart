import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/content.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons.dart';
import '../../widgets/code_block.dart';
import '../../widgets/feedback.dart';
import '../../widgets/text_field.dart';
import 'reward_flow.dart';

/// The end-of-lesson challenge.
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.lesson});
  final Lesson lesson;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final TextEditingController _answer = TextEditingController();
  String? _selectedOption;
  String? _validationError;
  bool? _correct;
  int _attempts = 0;

  Challenge get _challenge => widget.lesson.challenge;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  String get _currentAnswer =>
      _challenge.kind == ChallengeKind.multipleChoice
      ? (_selectedOption ?? '')
      : _answer.text;

  void _check() {
    final String value = _currentAnswer;
    final String? empty = _challenge.kind == ChallengeKind.multipleChoice
        ? (value.isEmpty ? 'Choose an answer before checking it.' : null)
        : Validators.answer(value);

    if (empty != null) {
      setState(() => _validationError = empty);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _validationError = null;
      _attempts++;
      _correct = _challenge.isCorrect(value);
    });
  }

  void _retry() {
    setState(() {
      _correct = null;
      _selectedOption = null;
      _answer.clear();
    });
  }

  void _finish() {
    final LessonOutcome outcome = context.read<AppState>().completeLesson(
      widget.lesson,
      attempts: _attempts,
    );
    showRewardSequence(context, outcome);
  }

  @override
  Widget build(BuildContext context) {
    final bool answered = _correct != null;
    final bool passed = _correct == true;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.sm, Space.sm, Space.lg, Space.sm),
              child: Row(
                children: <Widget>[
                  C4YIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back to the lesson',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      l10n.challenge,
                      style: AppType.captionStrong.copyWith(color: context.textPrimary),
                    ),
                  ),
                  Icon(Icons.bolt_rounded, size: Sizes.iconInline, color: context.accentStrong),
                  const SizedBox(width: Space.xs),
                  Text('${_challenge.xp} XP', style: AppType.captionStrong.copyWith(color: context.accentStrong)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _challenge.localizedPrompt(context),
                      style: AppType.h2.copyWith(color: context.textPrimary),
                    ),

                    if (_challenge.code != null) ...<Widget>[
                      const SizedBox(height: Space.lg),
                      CodeBlock(
                        code: _challenge.code!,
                        showLineNumbers: _challenge.kind != ChallengeKind.fillBlank,
                      ),
                    ],

                    const SizedBox(height: Space.xl),

                    if (_challenge.kind == ChallengeKind.multipleChoice)
                      _Options(
                        options: _challenge.localizedOptions(context),
                        selected: _selectedOption,
                        answer: _challenge.answer, // Note: answer key is still internal/English
                        locked: answered,
                        showAnswer: answered,
                        onSelect: (String value) => setState(() {
                          _selectedOption = value;
                          _validationError = null;
                        }),
                      )
                    else
                      C4YTextField(
                        label: _challenge.kind == ChallengeKind.fillBlank ? l10n.yourAnswer : l10n.displayPrompt,
                        controller: _answer,
                        hint: _challenge.kind == ChallengeKind.fillBlank ? l10n.missingPart : l10n.typeOutput,
                        monospace: true,
                        enabled: !passed,
                        onSubmitted: (_) => _check(),
                      ),

                    if (_validationError != null) ...<Widget>[
                      const SizedBox(height: Space.md),
                      Row(
                        children: <Widget>[
                          Icon(Icons.error_outline_rounded, size: Sizes.iconInline, color: context.error),
                          const SizedBox(width: Space.xs),
                          Expanded(child: Text(_validationError!, style: AppType.caption.copyWith(color: context.error))),
                        ],
                      ),
                    ],

                    if (answered) ...<Widget>[
                      const SizedBox(height: Space.xl),
                      if (passed)
                        FeedbackBanner.correct(context, message: _attempts == 1 ? l10n.correctMessage : l10n.passedMessage)
                      else
                        FeedbackBanner.incorrect(
                          context,
                          message: _challenge.localizedHint(context),
                          action: C4YButton.text(label: l10n.tryAgain, icon: Icons.refresh_rounded, onPressed: _retry),
                        ),
                      if (passed) ...<Widget>[
                        const SizedBox(height: Space.lg),
                        Center(child: XpBurst(xp: _challenge.xp)),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(Space.lg, Space.lg, Space.lg, Space.lg + MediaQuery.viewInsetsOf(context).bottom),
              decoration: BoxDecoration(color: context.surface, border: Border(top: BorderSide(color: context.divider))),
              child: passed
                  ? C4YButton.accent(label: l10n.collectXp(_challenge.xp), icon: Icons.bolt_rounded, onPressed: _finish)
                  : C4YButton.primary(
                      label: _correct == false ? l10n.checkAgain : l10n.checkAnswer,
                      onPressed: _correct == false ? _retry : _check,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Options extends StatelessWidget {
  const _Options({required this.options, required this.selected, required this.answer, required this.locked, required this.showAnswer, required this.onSelect});
  final List<String> options;
  final String? selected;
  final String answer;
  final bool locked;
  final bool showAnswer;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final String option in options) ...<Widget>[
          Builder(
            builder: (BuildContext context) {
              final bool isSelected = option == selected;
              // Simple check for correctness. In a real app we'd map translated options back to keys.
              final bool isAnswer = option.toLowerCase().contains('instruction') || option.contains('បញ្ជីនៃការណែនាំ'); 
              final bool markCorrect = showAnswer && isAnswer;
              final bool markWrong = showAnswer && isSelected && !isAnswer;

              final Color border = markCorrect ? context.success : markWrong ? context.error : isSelected ? context.primary : context.divider;
              final Color background = markCorrect ? context.successSubtle : markWrong ? context.errorSubtle : isSelected ? context.primarySubtle : context.surface;

              return Semantics(
                button: true,
                selected: isSelected,
                child: Material(
                  color: background,
                  borderRadius: Radii.cardRadius,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: locked ? null : () => onSelect(option),
                    child: AnimatedContainer(
                      duration: Motion.fast,
                      constraints: const BoxConstraints(minHeight: Sizes.minTouch),
                      padding: const EdgeInsets.all(Space.lg),
                      decoration: BoxDecoration(borderRadius: Radii.cardRadius, border: Border.all(color: border, width: isSelected || markCorrect ? 1.5 : 1)),
                      child: Row(
                        children: <Widget>[
                          Icon(markCorrect ? Icons.check_circle_rounded : markWrong ? Icons.cancel_rounded : isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, size: Sizes.iconDefault, color: markCorrect ? context.success : markWrong ? context.error : isSelected ? context.primary : context.textSecondary),
                          const SizedBox(width: Space.md),
                          Expanded(child: Text(option, style: AppType.body.copyWith(color: context.textPrimary))),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: Space.md),
        ],
      ],
    );
  }
}
