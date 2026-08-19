import 'package:flutter/material.dart';

/// The kinds of block a lesson step can render.
enum StepKind {
  text,
  code,
  callout,
  list,
}

/// One screen inside a lesson.
@immutable
class LessonStep {
  const LessonStep({
    required this.kind,
    required this.title,
    required this.body,
    this.titleKm,
    this.bodyKm,
    this.language = 'python',
    this.items = const <String>[],
  });

  final StepKind kind;
  final String title;
  final String? titleKm;
  final String body;
  final String? bodyKm;
  final String language;
  final List<String> items;

  String localizedTitle(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    return (isKhmer && titleKm != null) ? titleKm! : title;
  }

  String localizedBody(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    return (isKhmer && bodyKm != null) ? bodyKm! : body;
  }
}

/// How a learner answers a challenge.
enum ChallengeKind {
  multipleChoice,
  fillBlank,
  predictOutput,
}

/// The assessment at the end of a lesson.
@immutable
class Challenge {
  const Challenge({
    required this.kind,
    required this.prompt,
    required this.answer,
    required this.hint,
    this.promptKm,
    this.hintKm,
    this.options = const <String>[],
    this.optionsKm = const <String>[],
    this.code,
    this.xp = 20,
  });

  final ChallengeKind kind;
  final String prompt;
  final String? promptKm;
  final String answer;
  final String hint;
  final String? hintKm;
  final List<String> options;
  final List<String> optionsKm;
  final String? code;
  final int xp;

  String localizedPrompt(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    return (isKhmer && promptKm != null) ? promptKm! : prompt;
  }

  String localizedHint(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    return (isKhmer && hintKm != null) ? hintKm! : hint;
  }

  List<String> localizedOptions(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    return (isKhmer && optionsKm.isNotEmpty) ? optionsKm : options;
  }

  bool isCorrect(String input) =>
      input.trim().toLowerCase() == answer.trim().toLowerCase();
}

/// A single lesson.
@immutable
class Lesson {
  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.titleKm,
    required this.summary,
    this.summaryKm,
    required this.minutes,
    required this.steps,
    required this.challenge,
    this.xp = 30,
  });

  final String id;
  final String moduleId;
  final String title;
  final String titleKm;
  final String summary;
  final String? summaryKm;
  final int minutes;
  final List<LessonStep> steps;
  final Challenge challenge;
  final int xp;

  int get stepCount => steps.length;

  String localizedTitle(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    return isKhmer ? titleKm : title;
  }

  String localizedSummary(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    return (isKhmer && summaryKm != null) ? summaryKm! : summary;
  }
}

/// A group of lessons.
@immutable
class Module {
  const Module({
    required this.id,
    required this.title,
    required this.titleKm,
    required this.description,
    this.descriptionKm,
    required this.icon,
    required this.lessons,
    this.requiresModuleId,
  });

  final String id;
  final String title;
  final String titleKm;
  final String description;
  final String? descriptionKm;
  final IconData icon;
  final List<Lesson> lessons;
  final String? requiresModuleId;

  int get lessonCount => lessons.length;
  int get totalMinutes => lessons.fold(0, (sum, l) => sum + l.minutes);

  String localizedTitle(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    return isKhmer ? titleKm : title;
  }

  String localizedDescription(BuildContext context) {
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    return (isKhmer && descriptionKm != null) ? descriptionKm! : description;
  }
}
