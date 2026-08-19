import 'package:flutter/material.dart';

import 'tokens.dart';

/// Typography for Code4Youth.
///
/// Inter is the default application font because it stays legible at small
/// sizes on the low-density screens common in the target market. Poppins is
/// reserved for brand and achievement moments so it keeps its impact.
/// JetBrains Mono is used wherever a learner reads or writes code.
abstract final class Fonts {
  static const String body = 'Inter';
  static const String display = 'Poppins';
  static const String code = 'JetBrains Mono';
  static const String khmer = 'Noto Sans Khmer';

  /// Every Latin style falls back to Noto Sans Khmer so Khmer glyphs render
  /// correctly inside otherwise-English UI without a separate text widget.
  static const List<String> fallback = <String>[khmer];
}

/// The mobile type scale. Body text is never smaller than 16 sp; 14 sp Caption
/// is permitted only for metadata and timestamps.
abstract final class AppType {
  static const TextStyle display = TextStyle(
    fontFamily: Fonts.display,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle body = TextStyle(
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body weight bumped for labels and emphasis, same 16 sp floor.
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const TextStyle captionStrong = TextStyle(
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
  );

  static const TextStyle code = TextStyle(
    fontFamily: Fonts.code,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  /// Button labels sit at the 16 sp body floor with semibold weight.
  static const TextStyle button = TextStyle(
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );

  /// Bottom-navigation labels. 12 sp is below the body floor but these are
  /// icon-paired labels, not reading content.
  static const TextStyle navLabel = TextStyle(
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  /// Builds the Material text theme, tinting every style for the given
  /// brightness so screens can lean on `Theme.of(context).textTheme`.
  static TextTheme themeFor(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    final Color primary =
        dark ? Neutral.textPrimaryDark : Neutral.textPrimary;
    final Color secondary =
        dark ? Neutral.textSecondaryDark : Neutral.textSecondary;

    return TextTheme(
      displayLarge: display.copyWith(color: primary),
      displayMedium: display.copyWith(color: primary),
      displaySmall: display.copyWith(color: primary),
      headlineLarge: h1.copyWith(color: primary),
      headlineMedium: h1.copyWith(color: primary),
      headlineSmall: h2.copyWith(color: primary),
      titleLarge: h2.copyWith(color: primary),
      titleMedium: bodyStrong.copyWith(color: primary),
      titleSmall: captionStrong.copyWith(color: primary),
      bodyLarge: AppType.bodyLarge.copyWith(color: primary),
      bodyMedium: AppType.body.copyWith(color: primary),
      bodySmall: caption.copyWith(color: secondary),
      labelLarge: button.copyWith(color: primary),
      labelMedium: captionStrong.copyWith(color: primary),
      labelSmall: navLabel.copyWith(color: secondary),
    );
  }
}
