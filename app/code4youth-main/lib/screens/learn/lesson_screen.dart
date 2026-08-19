import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/content.dart';
import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/code_block.dart';
import '../../widgets/progress.dart';
import 'challenge_screen.dart';

/// The lesson reader.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});
  final Lesson lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = context.read<AppState>().savedPosition(widget.lesson.id).clamp(
      0,
      widget.lesson.stepCount - 1,
    );
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    context.read<AppState>().savePosition(widget.lesson.id, index);
  }

  void _next() {
    if (_index < widget.lesson.stepCount - 1) {
      _controller.nextPage(duration: Motion.base, curve: Motion.enter);
      return;
    }
    Navigator.of(context).pushReplacement(
      FadeRoute<void>(child: ChallengeScreen(lesson: widget.lesson)),
    );
  }

  void _previous() {
    if (_index == 0) return;
    _controller.previousPage(duration: Motion.base, curve: Motion.enter);
  }

  Future<void> _confirmExit() async {
    final bool started = _index > 0;
    if (!started) {
      Navigator.of(context).pop();
      return;
    }

    final bool? leave = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) => _ExitSheet(step: _index + 1),
    );

    if (leave == true && mounted) {
      context.read<AppState>().savePosition(widget.lesson.id, _index);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Lesson lesson = widget.lesson;
    final bool isLastStep = _index == lesson.stepCount - 1;
    final l10n = AppLocalizations.of(context)!;
    final title = lesson.localizedTitle(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        backgroundColor: context.background,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.sm,
                  Space.sm,
                  Space.lg,
                  Space.sm,
                ),
                child: Row(
                  children: <Widget>[
                    C4YIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Save and close',
                      onPressed: _confirmExit,
                    ),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: AppType.captionStrong.copyWith(
                              color: context.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.schedule_rounded,
                      size: Sizes.iconInline,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: Space.xs),
                    Text(
                      '${lesson.minutes} ${l10n.minutes}',
                      style: AppType.caption.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                child: StepProgress(
                  current: _index + 1,
                  total: lesson.stepCount,
                ),
              ),
              const SizedBox(height: Space.lg),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: _onPageChanged,
                  itemCount: lesson.stepCount,
                  itemBuilder: (BuildContext context, int i) =>
                      _StepView(step: lesson.steps[i]),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(Space.lg),
                decoration: BoxDecoration(
                  color: context.surface,
                  border: Border(top: BorderSide(color: context.divider)),
                ),
                child: Row(
                  children: <Widget>[
                    if (_index > 0) ...<Widget>[
                      SizedBox(
                        width: Sizes.buttonHeight,
                        height: Sizes.buttonHeight,
                        child: OutlinedButton(
                          onPressed: _previous,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size.square(
                              Sizes.buttonHeight,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: Sizes.iconDefault,
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.sm),
                    ],
                    Expanded(
                      child: C4YButton.primary(
                        label: isLastStep ? l10n.startChallenge : l10n.continue_,
                        icon: isLastStep
                            ? Icons.quiz_rounded
                            : Icons.arrow_forward_rounded,
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({required this.step});
  final LessonStep step;

  @override
  Widget build(BuildContext context) {
    final title = step.localizedTitle(context);
    final body = step.localizedBody(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppType.h1.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: Space.lg),
          switch (step.kind) {
            StepKind.code => CodeBlock(code: body),
            StepKind.callout => _Callout(body: body),
            StepKind.list => _ListStep(body: body, items: step.items),
            StepKind.text => Text(
              body,
              style: AppType.bodyLarge.copyWith(color: context.textPrimary),
            ),
          },
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.body});
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: context.accentSubtle,
        borderRadius: Radii.cardRadius,
        border: Border(
          left: BorderSide(color: context.accent, width: 4),
          top: BorderSide(color: context.accent.withValues(alpha: 0.3)),
          right: BorderSide(color: context.accent.withValues(alpha: 0.3)),
          bottom: BorderSide(color: context.accent.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.lightbulb_rounded, size: Sizes.iconDefault, color: context.accentStrong),
          const SizedBox(width: Space.md),
          Expanded(child: Text(body, style: AppType.bodyLarge.copyWith(color: context.textPrimary))),
        ],
      ),
    );
  }
}

class _ListStep extends StatelessWidget {
  const _ListStep({required this.body, required this.items});
  final String body;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(body, style: AppType.bodyLarge.copyWith(color: context.textPrimary)),
        const SizedBox(height: Space.lg),
        for (final String item in items) ...<Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(Radii.button),
              border: Border.all(color: context.divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 9, right: Space.md),
                  decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
                ),
                Expanded(child: Text(item, style: AppType.code.copyWith(color: context.textPrimary))),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
        ],
      ],
    );
  }
}

class _ExitSheet extends StatelessWidget {
  const _ExitSheet({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.lg,
        Space.sm,
        Space.lg,
        Space.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.leaveLesson, style: AppType.h2.copyWith(color: context.textPrimary)),
          const SizedBox(height: Space.sm),
          Text(l10n.saveMessage(step), style: AppType.body.copyWith(color: context.textSecondary)),
          const SizedBox(height: Space.xl),
          C4YButton.primary(
            label: l10n.saveAndLeave,
            icon: Icons.bookmark_rounded,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: Space.sm),
          C4YButton.text(
            label: l10n.keepLearning,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
