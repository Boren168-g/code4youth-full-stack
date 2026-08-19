import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// The Code4Youth mark — an Indigo rounded square holding a code glyph, with
/// the 4 picked out in Amber.
///
/// Drawn rather than shipped as a raster so it recolours with the theme and
/// stays sharp at every size, which is the same reason the design system asks
/// for SVG over PNG.
class C4YLogo extends StatelessWidget {
  const C4YLogo({super.key, this.size = 72, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: context.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.code_rounded,
            size: size * 0.52,
            color: Colors.white,
          ),
        ),
        if (showWordmark) ...<Widget>[
          SizedBox(height: size * 0.22),
          const C4YWordmark(),
        ],
      ],
    );
  }
}

/// The wordmark on its own. Poppins, used sparingly so it stays distinctive.
class C4YWordmark extends StatelessWidget {
  const C4YWordmark({super.key, this.fontSize = 28});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'Code',
            style: TextStyle(color: context.textPrimary),
          ),
          TextSpan(text: '4', style: TextStyle(color: context.accent)),
          TextSpan(
            text: 'Youth',
            style: TextStyle(color: context.textPrimary),
          ),
        ],
      ),
      style: AppType.display.copyWith(fontSize: fontSize),
      semanticsLabel: 'Code4Youth',
    );
  }
}
