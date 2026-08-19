import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// A read-only code sample in JetBrains Mono.
///
/// Syntax colours are drawn from the existing palette rather than a new set:
/// Indigo for keywords, Green for strings, Amber for numbers, and secondary
/// text grey for comments. Highlighting is a functional requirement for
/// readability, not decoration.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.code,
    this.showLineNumbers = true,
    this.padding = const EdgeInsets.all(Space.lg),
  });

  final String code;
  final bool showLineNumbers;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    final Color background = dark ? Neutral.backgroundDark : Indigo.s50;
    final Color border = dark ? Neutral.dividerDark : Indigo.s100;
    final List<String> lines = code.split('\n');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        // Code must not wrap — a broken line is a misread line. It scrolls
        // horizontally inside the block instead.
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < lines.length; i++)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (showLineNumbers) ...<Widget>[
                      SizedBox(
                        width: 22,
                        child: Text(
                          '${i + 1}',
                          textAlign: TextAlign.right,
                          style: AppType.code.copyWith(
                            color: context.textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                    ],
                    Text.rich(
                      TextSpan(
                        children: _highlight(context, lines[i]),
                      ),
                      style: AppType.code.copyWith(color: context.textPrimary),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline code inside a sentence — same font, sized to sit with body text.
class InlineCode extends StatelessWidget {
  const InlineCode(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: 2),
      decoration: BoxDecoration(
        color: context.isDark ? Neutral.backgroundDark : Indigo.s50,
        borderRadius: BorderRadius.circular(Radii.button / 3),
      ),
      child: Text(
        text,
        style: AppType.code.copyWith(color: context.primary, fontSize: 14),
      ),
    );
  }
}

const Set<String> _keywords = <String>{
  'if', 'else', 'elif', 'for', 'while', 'in', 'return', 'def', 'import',
  'from', 'and', 'or', 'not', 'True', 'False', 'None', 'break', 'continue',
  'class', 'try', 'except', 'pass', 'with', 'as',
};

const Set<String> _builtins = <String>{
  'print', 'input', 'int', 'str', 'float', 'len', 'range', 'list', 'bool',
  'lower', 'upper', 'append',
};

/// Tokenises one line of Python into coloured spans.
///
/// This is a teaching-grade highlighter, not a parser: it recognises comments,
/// strings, numbers, keywords and builtin calls, which is everything the
/// curriculum uses.
List<TextSpan> _highlight(BuildContext context, String line) {
  final bool dark = context.isDark;

  final Color plain = context.textPrimary;
  final Color comment = context.textSecondary;
  final Color string = dark ? Green.s300 : Green.s700;
  final Color number = dark ? Amber.s300 : Amber.s700;
  final Color keyword = dark ? Indigo.s300 : Indigo.s700;
  final Color builtin = dark ? Indigo.s200 : Indigo.s500;

  final List<TextSpan> spans = <TextSpan>[];
  int i = 0;

  void push(String text, Color color, {FontWeight? weight}) {
    if (text.isEmpty) return;
    spans.add(
      TextSpan(
        text: text,
        style: TextStyle(color: color, fontWeight: weight),
      ),
    );
  }

  while (i < line.length) {
    final String ch = line[i];

    // Comment runs to end of line.
    if (ch == '#') {
      push(line.substring(i), comment);
      break;
    }

    // String literal.
    if (ch == '"' || ch == "'") {
      final int start = i;
      i++;
      while (i < line.length && line[i] != ch) {
        i++;
      }
      if (i < line.length) i++;
      push(line.substring(start, i), string);
      continue;
    }

    // Number literal.
    if (_isDigit(ch)) {
      final int start = i;
      while (i < line.length && (_isDigit(line[i]) || line[i] == '.')) {
        i++;
      }
      push(line.substring(start, i), number);
      continue;
    }

    // Identifier or keyword.
    if (_isWordStart(ch)) {
      final int start = i;
      while (i < line.length && _isWordChar(line[i])) {
        i++;
      }
      final String word = line.substring(start, i);
      if (_keywords.contains(word)) {
        push(word, keyword, weight: FontWeight.w700);
      } else if (_builtins.contains(word)) {
        push(word, builtin, weight: FontWeight.w700);
      } else {
        push(word, plain);
      }
      continue;
    }

    push(ch, plain);
    i++;
  }

  return spans;
}

bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

bool _isWordStart(String c) {
  final int u = c.codeUnitAt(0);
  return (u >= 65 && u <= 90) || (u >= 97 && u <= 122) || c == '_';
}

bool _isWordChar(String c) => _isWordStart(c) || _isDigit(c);
