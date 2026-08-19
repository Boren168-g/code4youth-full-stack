import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/curriculum.dart';
import '../../models/content.dart';
import '../../models/gamification.dart';
import '../../router/app_router.dart';
import '../../state/app_state.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/chips.dart';
import '../../widgets/feedback.dart';
import '../learn/challenge_screen.dart';
import '../learn/lesson_screen.dart';

/// Lesson history.
///
/// Every completed lesson can be reopened and every challenge retried — a
/// finished lesson is a resource, not a closed door.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final List<HistoryEntry> history = state.history;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        leading: C4YIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Go back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('History'),
      ),
      body: history.isEmpty
          ? EmptyState(
              icon: Icons.history_rounded,
              title: 'No lessons yet',
              message: 'Once you finish a lesson it appears here, and you can '
                  'reopen it any time.',
              action: C4YButton.primary(
                label: 'Back to learning',
                fullWidth: false,
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                Space.lg,
                Space.lg,
                Space.xxl,
              ),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.sm),
              itemBuilder: (BuildContext context, int i) =>
                  _HistoryCard(entry: history[i]),
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final Lesson? lesson = Curriculum.lessonById(entry.lessonId);

    return C4YCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.successSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: Sizes.iconInline,
                  color: context.success,
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.lessonTitle,
                      style: AppType.bodyStrong.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.moduleTitle,
                      style: AppType.caption.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatChip.xp(entry.xpEarned, compact: true),
            ],
          ),
          const SizedBox(height: Space.md),
          // A Wrap, not a Row: at a large text scale or on a narrow phone the
          // two facts drop onto separate lines instead of clipping.
          Wrap(
            spacing: Space.md,
            runSpacing: Space.xs,
            children: <Widget>[
              _Meta(
                icon: Icons.event_rounded,
                label: _relative(entry.completedAt),
                color: context.textSecondary,
              ),
              _Meta(
                icon: entry.attempts == 1
                    ? Icons.star_rounded
                    : Icons.refresh_rounded,
                label: entry.attempts == 1
                    ? 'First try'
                    : '${entry.attempts} attempts',
                color: entry.attempts == 1
                    ? context.success
                    : context.textSecondary,
              ),
            ],
          ),
          if (lesson != null) ...<Widget>[
            const SizedBox(height: Space.md),
            Divider(color: context.divider),
            const SizedBox(height: Space.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: C4YButton.secondary(
                    label: 'Review lesson',
                    icon: Icons.menu_book_rounded,
                    onPressed: () => Navigator.of(context).push(
                      FadeRoute<void>(child: LessonScreen(lesson: lesson)),
                    ),
                  ),
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: C4YButton.secondary(
                    label: 'Retry challenge',
                    icon: Icons.replay_rounded,
                    onPressed: () => Navigator.of(context).push(
                      FadeRoute<void>(child: ChallengeScreen(lesson: lesson)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Human-readable timestamps — "Yesterday" beats a date a learner has to
  /// decode.
  static String _relative(DateTime when) {
    final Duration diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${when.day}/${when.month}/${when.year}';
  }
}

/// One icon-and-label fact in a history card's metadata line.
class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: Space.xs),
        Text(label, style: AppType.caption.copyWith(color: color)),
      ],
    );
  }
}
