import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// The button set defined by the design system.
///
/// Screens should use these rather than raw Material buttons, so height,
/// radius, colour and touch target stay consistent everywhere.
abstract final class C4YButton {
  /// Primary action — one per screen. Indigo 600, white label, 48 dp, 12 dp radius.
  static Widget primary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool loading = false,
    bool fullWidth = true,
  }) {
    return _Sized(
      fullWidth: fullWidth,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: _Label(label: label, icon: icon, loading: loading),
      ),
    );
  }

  /// Secondary action — transparent with a 1.5 dp Indigo stroke.
  static Widget secondary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool fullWidth = true,
  }) {
    return _Sized(
      fullWidth: fullWidth,
      child: OutlinedButton(
        onPressed: onPressed,
        child: _Label(label: label, icon: icon),
      ),
    );
  }

  /// Tertiary / dismiss action — Skip, Cancel, See all, Learn more.
  static Widget text({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return _Sized(
      fullWidth: fullWidth,
      height: Sizes.textButtonHeight,
      child: TextButton(
        onPressed: onPressed,
        child: _Label(label: label, icon: icon, iconAfter: true),
      ),
    );
  }

  /// Reward action only — Claim Reward, Continue Streak, Collect XP.
  /// Never used for navigation or standard actions.
  static Widget accent({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool fullWidth = true,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return _Sized(
          fullWidth: fullWidth,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.accent,
              foregroundColor: Neutral.textPrimary,
              disabledBackgroundColor: Amber.s200,
              disabledForegroundColor: Neutral.textSecondary,
              elevation: 0,
              minimumSize: const Size.fromHeight(Sizes.buttonHeight),
              shape: const RoundedRectangleBorder(
                borderRadius: Radii.buttonRadius,
              ),
              textStyle: AppType.button,
            ),
            child: _Label(label: label, icon: icon),
          ),
        );
      },
    );
  }

  /// Destructive action — account deletion and nothing else.
  static Widget destructive({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool fullWidth = true,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return _Sized(
          fullWidth: fullWidth,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.error,
              side: BorderSide(color: context.error, width: 1.5),
              minimumSize: const Size.fromHeight(Sizes.buttonHeight),
              shape: const RoundedRectangleBorder(
                borderRadius: Radii.buttonRadius,
              ),
              textStyle: AppType.button,
            ),
            child: _Label(label: label, icon: icon),
          ),
        );
      },
    );
  }
}

class _Sized extends StatelessWidget {
  const _Sized({
    required this.child,
    required this.fullWidth,
    this.height = Sizes.buttonHeight,
  });

  final Widget child;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Widget constrained = SizedBox(height: height, child: child);
    return fullWidth
        ? SizedBox(width: double.infinity, child: constrained)
        : constrained;
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.label,
    this.icon,
    this.loading = false,
    this.iconAfter = false,
  });

  final String label;
  final IconData? icon;
  final bool loading;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        width: Sizes.iconDefault,
        height: Sizes.iconDefault,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon == null) return Text(label);

    final Widget glyph = Icon(icon, size: Sizes.iconDefault);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (!iconAfter) ...<Widget>[glyph, const SizedBox(width: Space.sm)],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        if (iconAfter) ...<Widget>[const SizedBox(width: Space.xs), glyph],
      ],
    );
  }
}

/// Icon-only button. The glyph may be small; the touch target never is.
class C4YIconButton extends StatelessWidget {
  const C4YIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.size = Sizes.iconDefault,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Doubles as the semantic label — an icon button must never be unlabelled.
  final String tooltip;

  final Color? color;
  final double size;

  /// Gives the button a subtle surface so it reads as tappable on busy screens.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: Sizes.minTouch,
        height: Sizes.minTouch,
        child: Material(
          color: filled ? context.surface : Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: color ?? context.textPrimary,
                semanticLabel: tooltip,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
