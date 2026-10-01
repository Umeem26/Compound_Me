import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text input (§7.5): label above the field, no underline, muted fill and
/// the error below it. [maxLength] stops typing without showing a counter.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    this.errorText,
    this.helperText,
    this.hintText,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardType,
    this.inputFormatters = const [],
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? errorText;
  final String? helperText;
  final String? hintText;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;

  /// Applied after the [maxLength] limit.
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.sm));
    final error = errorText;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space2),
        TextField(
          controller: controller,
          enabled: enabled,
          autofocus: autofocus,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          inputFormatters: [
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
            ...inputFormatters,
          ],
          style: AppTextStyles.body.copyWith(
            color: enabled ? colors.textPrimary : colors.textSecondary,
          ),
          cursorColor: colors.primary,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.body.copyWith(color: colors.textTertiary),
            filled: true,
            fillColor: colors.surfaceMuted,
            isDense: true,
            constraints: const BoxConstraints(minHeight: AppSizes.textField),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
            border: border(colors.border, 0),
            enabledBorder: border(
              error == null ? colors.surfaceMuted : colors.danger,
              AppSizes.border,
            ),
            focusedBorder: border(
              error == null ? colors.primary : colors.danger,
              AppSizes.borderSelected,
            ),
            disabledBorder: border(colors.surfaceMuted, AppSizes.border),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.space1),
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(color: colors.danger),
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: AppSpacing.space1),
          Text(
            helperText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Search box (S-13): magnifying glass, hint, and a clear button while it
/// has text. Same fill and radius as [AppTextField], without a label.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.controller,
    required this.hintText,
    required this.clearLabel,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final String clearLabel;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.sm));
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body.copyWith(color: colors.textPrimary),
        cursorColor: colors.primary,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(color: colors.textTertiary),
          filled: true,
          fillColor: colors.surfaceMuted,
          isDense: true,
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space3,
          ),
          prefixIcon: Icon(
            AppIcons.magnifyingGlass,
            size: AppSizes.iconSm,
            color: colors.textSecondary,
          ),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: clearLabel,
                  icon: const Icon(AppIcons.x, size: AppSizes.iconSm),
                  color: colors.textSecondary,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          border: border(colors.border, 0),
          enabledBorder: border(colors.surfaceMuted, AppSizes.border),
          focusedBorder: border(colors.primary, AppSizes.borderSelected),
        ),
      ),
    );
  }
}
