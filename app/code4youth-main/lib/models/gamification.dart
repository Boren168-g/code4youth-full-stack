import 'package:flutter/material.dart';

/// An award a learner can unlock. Badges are Amber throughout — they are a
/// reward signal, never a navigation or status colour.
@immutable
class BadgeDef {
  const BadgeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirement,
  });

  final String id;
  final String name;

  /// What the learner did to earn it, in plain language.
  final String description;

  final IconData icon;

  /// Human-readable unlock condition, shown while the badge is still locked.
  final String requirement;
}

/// Level thresholds. Levels are cumulative XP gates, so the progress bar on the
/// home screen can always show distance to the next one.
abstract final class Levels {
  /// Cumulative XP required to *reach* each level. Index 0 is level 1.
  static const List<int> thresholds = <int>[
    0,
    100,
    250,
    450,
    700,
    1000,
    1400,
    1900,
    2500,
    3200,
  ];

  static const List<String> titles = <String>[
    'Newcomer',
    'Explorer',
    'Tinkerer',
    'Builder',
    'Problem Solver',
    'Debugger',
    'Engineer',
    'Architect',
    'Mentor',
    'Code Master',
  ];

  static int levelFor(int xp) {
    int level = 1;
    for (int i = 0; i < thresholds.length; i++) {
      if (xp >= thresholds[i]) level = i + 1;
    }
    return level;
  }

  static String titleFor(int level) =>
      titles[(level - 1).clamp(0, titles.length - 1)];

  /// Cumulative XP at which the given level starts.
  static int floorFor(int level) =>
      thresholds[(level - 1).clamp(0, thresholds.length - 1)];

  /// Cumulative XP needed for the next level, or `null` at max level.
  static int? ceilingFor(int level) =>
      level >= thresholds.length ? null : thresholds[level];

  /// Progress through the current level, 0.0–1.0. Returns 1.0 at max level.
  static double progressFor(int xp) {
    final int level = levelFor(xp);
    final int floor = floorFor(level);
    final int? ceiling = ceilingFor(level);
    if (ceiling == null) return 1;
    final int span = ceiling - floor;
    if (span <= 0) return 1;
    return ((xp - floor) / span).clamp(0.0, 1.0);
  }

  /// XP still needed to reach the next level, or `null` at max level.
  static int? remainingFor(int xp) {
    final int? ceiling = ceilingFor(levelFor(xp));
    return ceiling == null ? null : ceiling - xp;
  }
}

/// One completed lesson or challenge attempt, listed on the History screen.
@immutable
class HistoryEntry {
  const HistoryEntry({
    required this.lessonId,
    required this.lessonTitle,
    required this.moduleTitle,
    required this.completedAt,
    required this.xpEarned,
    required this.attempts,
    required this.passed,
  });

  final String lessonId;
  final String lessonTitle;
  final String moduleTitle;
  final DateTime completedAt;
  final int xpEarned;

  /// How many times the challenge was answered before it was correct.
  final int attempts;

  final bool passed;
}
