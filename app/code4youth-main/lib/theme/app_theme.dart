import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';
import 'typography.dart';

/// Light and dark [ThemeData] for Code4Youth.
///
/// Dark mode is defined here from the outset rather than retrofitted: students
/// study at night, and dark surfaces reduce battery drain on the mid-range
/// devices this app targets.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;

    final Color background =
        dark ? Neutral.backgroundDark : Neutral.backgroundLight;
    final Color surface = dark ? Neutral.surfaceDark : Neutral.surfaceLight;
    final Color textPrimary =
        dark ? Neutral.textPrimaryDark : Neutral.textPrimary;
    final Color textSecondary =
        dark ? Neutral.textSecondaryDark : Neutral.textSecondary;
    final Color divider = dark ? Neutral.dividerDark : Neutral.divider;

    // Indigo 600 on the #111827 background does not carry enough contrast, so
    // dark mode uses Indigo 400. Indigo remains the interactive colour in both.
    final Color primary = dark ? Indigo.s400 : Indigo.s600;
    final Color onPrimary = dark ? Neutral.textPrimary : Colors.white;
    final Color accent = dark ? Amber.s400 : Amber.s500;
    final Color error = dark ? Red.s400 : Red.s600;

    final TextTheme textTheme = AppType.themeFor(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: Fonts.body,
      fontFamilyFallback: Fonts.fallback,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: divider,
      textTheme: textTheme,

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: dark ? Indigo.s900 : Indigo.s50,
        onPrimaryContainer: dark ? Indigo.s100 : Indigo.s900,
        secondary: accent,
        onSecondary: Neutral.textPrimary,
        secondaryContainer: dark ? Amber.s900 : Amber.s50,
        onSecondaryContainer: dark ? Amber.s100 : Amber.s900,
        tertiary: dark ? Green.s400 : Green.s600,
        onTertiary: dark ? Neutral.textPrimary : Colors.white,
        tertiaryContainer: dark ? Green.s900 : Green.s50,
        onTertiaryContainer: dark ? Green.s100 : Green.s900,
        error: error,
        onError: dark ? Neutral.textPrimary : Colors.white,
        errorContainer: dark ? Red.s900 : Red.s50,
        onErrorContainer: dark ? Red.s100 : Red.s900,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerLowest: background,
        surfaceContainerLow: surface,
        surfaceContainer: surface,
        surfaceContainerHigh: dark ? const Color(0xFF283548) : Colors.white,
        surfaceContainerHighest: dark ? const Color(0xFF2F3E52) : Colors.white,
        onSurfaceVariant: textSecondary,
        outline: divider,
        outlineVariant: divider,
        shadow: Colors.black,
        scrim: Colors.black54,
        inverseSurface: dark ? Neutral.surfaceLight : Neutral.surfaceDark,
        onInverseSurface: dark ? Neutral.textPrimary : Colors.white,
        inversePrimary: dark ? Indigo.s600 : Indigo.s200,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppType.h2.copyWith(color: textPrimary),
        iconTheme: IconThemeData(
          color: textPrimary,
          size: Sizes.iconDefault,
        ),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // Cards stay light on shadow. Structure comes from the surface colour and
      // a hairline border, not from elevation.
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.cardRadius,
          side: BorderSide(color: divider),
        ),
      ),

      // Primary action. Disabled state is Indigo 200 with white text, which the
      // design system specifies in place of Material's default grey.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return Indigo.s200;
            if (states.contains(WidgetState.pressed)) {
              return dark ? Indigo.s500 : Indigo.s700;
            }
            return primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return Colors.white;
            return onPrimary;
          }),
          overlayColor: WidgetStateProperty.all(Colors.white24),
          elevation: WidgetStateProperty.all(0),
          minimumSize: WidgetStateProperty.all(
            const Size.fromHeight(Sizes.buttonHeight),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: Space.xl),
          ),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: Radii.buttonRadius),
          ),
          textStyle: WidgetStateProperty.all(AppType.button),
        ),
      ),

      // Secondary action. 1.5 dp Indigo stroke on a transparent background.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return Indigo.s200;
            return primary;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            final Color c =
                states.contains(WidgetState.disabled) ? Indigo.s200 : primary;
            return BorderSide(color: c, width: 1.5);
          }),
          overlayColor: WidgetStateProperty.all(
            primary.withValues(alpha: 0.08),
          ),
          minimumSize: WidgetStateProperty.all(
            const Size.fromHeight(Sizes.buttonHeight),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: Space.xl),
          ),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: Radii.buttonRadius),
          ),
          textStyle: WidgetStateProperty.all(AppType.button),
        ),
      ),

      // Tertiary / dismiss action at 44 dp, still inside a 48 dp touch target.
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return Indigo.s200;
            return primary;
          }),
          overlayColor: WidgetStateProperty.all(
            primary.withValues(alpha: 0.08),
          ),
          minimumSize: WidgetStateProperty.all(
            const Size(Sizes.minTouch, Sizes.textButtonHeight),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: Space.lg),
          ),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: Radii.buttonRadius),
          ),
          textStyle: WidgetStateProperty.all(AppType.button),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(textPrimary),
          minimumSize: WidgetStateProperty.all(
            const Size.square(Sizes.minTouch),
          ),
          shape: WidgetStateProperty.all(const CircleBorder()),
        ),
      ),

      iconTheme: IconThemeData(color: textPrimary, size: Sizes.iconDefault),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.lg,
        ),
        hintStyle: AppType.body.copyWith(color: textSecondary),
        labelStyle: AppType.captionStrong.copyWith(color: textSecondary),
        floatingLabelStyle: AppType.captionStrong.copyWith(color: primary),
        errorStyle: AppType.caption.copyWith(color: error),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: Radii.buttonRadius,
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.buttonRadius,
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.buttonRadius,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.buttonRadius,
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Radii.buttonRadius,
          borderSide: BorderSide(color: error, width: 1.5),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: dark ? Indigo.s800 : Indigo.s100,
        circularTrackColor: dark ? Indigo.s800 : Indigo.s100,
        linearMinHeight: Sizes.progressTrackHeight,
      ),

      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: dark ? Indigo.s900 : Indigo.s50,
        selectedColor: primary,
        labelStyle: AppType.caption.copyWith(color: textPrimary),
        secondaryLabelStyle: AppType.caption.copyWith(color: onPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.md,
          vertical: Space.sm,
        ),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return dark ? Neutral.textSecondaryDark : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return divider;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Radii.sheetRadius),
        showDragHandle: true,
        dragHandleColor: divider,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
        titleTextStyle: AppType.h2.copyWith(color: textPrimary),
        contentTextStyle: AppType.body.copyWith(color: textSecondary),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? Neutral.surfaceLight : Neutral.surfaceDark,
        contentTextStyle: AppType.body.copyWith(
          color: dark ? Neutral.textPrimary : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.button),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        titleTextStyle: AppType.body.copyWith(color: textPrimary),
        subtitleTextStyle: AppType.caption.copyWith(color: textSecondary),
        minVerticalPadding: Space.md,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
      ),

      splashFactory: InkSparkle.splashFactory,

      // Screen changes fade rather than slide, and stay under 300 ms so the
      // interface keeps feeling responsive on lower-end hardware.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
