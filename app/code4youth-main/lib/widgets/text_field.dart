import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// A labelled form field.
///
/// The label sits above the box rather than floating inside it, which keeps
/// the 16 sp input text at a fixed position and avoids the cramped feel of
/// Material's default on small screens.
class C4YTextField extends StatefulWidget {
  const C4YTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.autofillHints,
    this.prefixIcon,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.enabled = true,
    this.onSubmitted,
    this.autofocus = false,
    this.monospace = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final List<String>? autofillHints;
  final IconData? prefixIcon;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  /// Renders the value in JetBrains Mono — used for code answers and OTPs.
  final bool monospace;

  @override
  State<C4YTextField> createState() => _C4YTextFieldState();
}

class _C4YTextFieldState extends State<C4YTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: AppType.captionStrong.copyWith(color: context.textPrimary),
        ),
        const SizedBox(height: Space.sm),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _hidden,
          autofillHints: widget.autofillHints,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          onFieldSubmitted: widget.onSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: (widget.monospace ? AppType.code : AppType.body).copyWith(
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helper,
            helperMaxLines: 3,
            errorMaxLines: 3,
            counterText: '',
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: Sizes.iconDefault),
            // The reveal toggle keeps its own 48 dp target.
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: Sizes.iconDefault,
                    ),
                    tooltip: _hidden ? 'Show password' : 'Hide password',
                    constraints: const BoxConstraints(
                      minWidth: Sizes.minTouch,
                      minHeight: Sizes.minTouch,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// Six single-character boxes for the email verification code.
class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.errorText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onCompleted;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // A single field sits invisibly behind the boxes so the platform
        // keyboard, paste and SMS autofill all keep working.
        Stack(
          children: <Widget>[
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (BuildContext context, TextEditingValue value, _) {
                return Row(
                  children: <Widget>[
                    for (int i = 0; i < 6; i++) ...<Widget>[
                      Expanded(
                        child: _OtpBox(
                          character: i < value.text.length
                              ? value.text[i]
                              : null,
                          active: i == value.text.length,
                          hasError: errorText != null,
                        ),
                      ),
                      if (i < 5) const SizedBox(width: Space.sm),
                    ],
                  ],
                );
              },
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  showCursor: false,
                  style: const TextStyle(height: 4),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  onChanged: (String v) {
                    if (v.length == 6) onCompleted(v);
                  },
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: Space.sm),
          Row(
            children: <Widget>[
              Icon(
                Icons.error_outline_rounded,
                size: Sizes.iconInline,
                color: context.error,
              ),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Text(
                  errorText!,
                  style: AppType.caption.copyWith(color: context.error),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.character,
    required this.active,
    required this.hasError,
  });

  final String? character;
  final bool active;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final Color border = hasError
        ? context.error
        : active
        ? context.primary
        : context.divider;

    return AnimatedContainer(
      duration: Motion.fast,
      height: 56,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: Radii.buttonRadius,
        border: Border.all(color: border, width: active || hasError ? 1.5 : 1),
      ),
      alignment: Alignment.center,
      child: Text(
        character ?? '',
        style: AppType.h2.copyWith(color: context.textPrimary),
      ),
    );
  }
}
