import 'package:flutter/material.dart';

/// Design tokens for Code4Youth.
///
/// These are the only colour, spacing, radius and duration values the app is
/// allowed to use. Screens and widgets must reference these constants rather
/// than writing literal values, so that a change here propagates everywhere.

/// Primary — Indigo. Trust, focus, education, learning.
abstract final class Indigo {
  static const Color s900 = Color(0xFF1E1B4B);
  static const Color s800 = Color(0xFF2E2A6E);
  static const Color s700 = Color(0xFF3730A3);
  static const Color s600 = Color(0xFF4338CA);
  static const Color s500 = Color(0xFF4F46E5);
  static const Color s400 = Color(0xFF6366F1);
  static const Color s300 = Color(0xFF818CF8);
  static const Color s200 = Color(0xFFA5B4FC);
  static const Color s100 = Color(0xFFC7D2FE);
  static const Color s50 = Color(0xFFEEF2FF);
}

/// Accent — Amber. Points, XP, streaks, badges, rewards, achievements.
/// An attention and reward colour, never the primary application colour.
abstract final class Amber {
  static const Color s900 = Color(0xFF78350F);
  static const Color s800 = Color(0xFF92400E);
  static const Color s700 = Color(0xFFB45309);
  static const Color s600 = Color(0xFFD97706);
  static const Color s500 = Color(0xFFF59E0B);
  static const Color s400 = Color(0xFFFBBF24);
  static const Color s300 = Color(0xFFFCD34D);
  static const Color s200 = Color(0xFFFDE68A);
  static const Color s100 = Color(0xFFFEF3C7);
  static const Color s50 = Color(0xFFFFFBEB);
}

/// Success — Green. Correct answers, completed lessons, positive feedback.
abstract final class Green {
  static const Color s900 = Color(0xFF14532D);
  static const Color s800 = Color(0xFF166534);
  static const Color s700 = Color(0xFF15803D);
  static const Color s600 = Color(0xFF16A34A);
  static const Color s500 = Color(0xFF22C55E);
  static const Color s400 = Color(0xFF4ADE80);
  static const Color s300 = Color(0xFF86EFAC);
  static const Color s200 = Color(0xFFBBF7D0);
  static const Color s100 = Color(0xFFDCFCE7);
  static const Color s50 = Color(0xFFF0FDF4);
}

/// Error — Red. Incorrect answers, failed validation, destructive actions.
/// Never used decoratively.
abstract final class Red {
  static const Color s900 = Color(0xFF7F1D1D);
  static const Color s800 = Color(0xFF991B1B);
  static const Color s700 = Color(0xFFB91C1C);
  static const Color s600 = Color(0xFFDC2626);
  static const Color s500 = Color(0xFFEF4444);
  static const Color s400 = Color(0xFFF87171);
  static const Color s300 = Color(0xFFFCA5A5);
  static const Color s200 = Color(0xFFFECACA);
  static const Color s100 = Color(0xFFFEE2E2);
  static const Color s50 = Color(0xFFFEF2F2);
}

/// Neutral and surface colours for both themes.
abstract final class Neutral {
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  /// Dark-theme counterparts. Text on #111827 must stay high contrast, and
  /// dividers need to lift rather than darken against an already dark surface.
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color dividerDark = Color(0xFF374151);

  /// Locked / disabled content.
  static const Color mutedLight = Color(0xFF9CA3AF);
  static const Color mutedDark = Color(0xFF6B7280);
}

/// 8 dp spacing system. Every gap and pad in the app comes from this list.
abstract final class Space {
  /// Very small internal spacing.
  static const double xs = 4;

  /// Minimum spacing between adjacent interactive targets.
  static const double sm = 8;

  /// Compact component spacing.
  static const double md = 12;

  /// Standard padding.
  static const double lg = 16;

  /// Section spacing.
  static const double xl = 24;

  /// Major section spacing.
  static const double xxl = 32;
}

/// Corner radii. Buttons are fixed at 12 dp by the design system.
abstract final class Radii {
  static const double button = 12;
  static const double card = 16;
  static const double chip = 999;
  static const double sheet = 24;

  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Touch target and control sizing.
abstract final class Sizes {
  /// Minimum touch target on every interactive element.
  static const double minTouch = 48;

  static const double buttonHeight = 48;
  static const double textButtonHeight = 44;

  static const double iconInline = 20;
  static const double iconDefault = 24;
  static const double iconFeature = 32;
  static const double iconBadge = 48;

  static const double bottomNavHeight = 64;
  static const double progressTrackHeight = 8;
}

/// Motion. Kept under 300 ms so the interface stays responsive on the
/// lower-end hardware this app targets.
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 300);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// Scale-and-pop, used only for reward moments.
  static const Curve reward = Curves.easeOutBack;
}

/// Theme-aware token lookups.
///
/// Anywhere a colour differs between light and dark, resolve it through here
/// instead of branching on brightness at the call site.
extension C4YColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get background =>
      isDark ? Neutral.backgroundDark : Neutral.backgroundLight;
  Color get surface => isDark ? Neutral.surfaceDark : Neutral.surfaceLight;
  Color get textPrimary =>
      isDark ? Neutral.textPrimaryDark : Neutral.textPrimary;
  Color get textSecondary =>
      isDark ? Neutral.textSecondaryDark : Neutral.textSecondary;
  Color get divider => isDark ? Neutral.dividerDark : Neutral.divider;
  Color get muted => isDark ? Neutral.mutedDark : Neutral.mutedLight;

  /// Indigo reads too dark against #111827, so dark mode steps two shades
  /// lighter to hold contrast while keeping Indigo as the interactive colour.
  Color get primary => isDark ? Indigo.s400 : Indigo.s600;
  Color get primarySubtle => isDark ? Indigo.s900 : Indigo.s50;
  Color get primaryTrack => isDark ? Indigo.s800 : Indigo.s100;
  Color get onPrimary => isDark ? Neutral.textPrimary : Colors.white;

  Color get accent => isDark ? Amber.s400 : Amber.s500;
  Color get accentSubtle => isDark ? Amber.s900 : Amber.s50;
  Color get accentStrong => isDark ? Amber.s300 : Amber.s600;

  Color get success => isDark ? Green.s400 : Green.s600;
  Color get successSubtle => isDark ? Green.s900 : Green.s50;

  Color get error => isDark ? Red.s400 : Red.s600;
  Color get errorSubtle => isDark ? Red.s900 : Red.s50;
}
