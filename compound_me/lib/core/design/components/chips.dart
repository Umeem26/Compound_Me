import 'dart:async';

import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 40 dp chip (§7.5 CategoryChips, S-13 filters) inside a 48 dp target.
/// Selected = `teal50` fill with a `teal700` border; [muted] is the quieter
/// "Semua ›" style on `surfaceMuted` without a border. A caret shows when
/// [trailingIcon] is set, e.g. for chips that open a picker.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.onTap,
    this.leading,
    this.trailingIcon,
    this.selected = false,
    this.muted = false,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final IconData? trailingIcon;
  final bool selected;
  final bool muted;

  void _tap() {
    unawaited(HapticFeedback.selectionClick());
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.sm));
    final foreground = selected ? colors.onPrimaryTint : colors.textPrimary;
    final Color background;
    final BorderSide side;
    if (selected) {
      background = colors.primaryTint;
      side = BorderSide(color: colors.primary);
    } else if (muted) {
      background = colors.surfaceMuted;
      side = BorderSide.none;
    } else {
      background = colors.surface;
      side = BorderSide(color: colors.border);
    }
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap == null ? null : _tap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
        child: Center(
          widthFactor: 1,
          child: Material(
            color: background,
            shape: RoundedRectangleBorder(borderRadius: radius, side: side),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap == null ? null : _tap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSizes.chip),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                    vertical: AppSpacing.space1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: AppSpacing.space2),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          style: AppTextStyles.label.copyWith(
                            color: muted ? colors.textSecondary : foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: AppSpacing.space1),
                        Icon(
                          trailingIcon,
                          size: AppSizes.iconXs,
                          color: muted ? colors.textSecondary : foreground,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Category icon in its preset color, sized for chips and rows.
class PresetIcon extends StatelessWidget {
  const PresetIcon({
    required this.iconKey,
    required this.colorKey,
    this.size = AppSizes.iconSm,
    super.key,
  });

  final String iconKey;
  final String colorKey;
  final double size;

  @override
  Widget build(BuildContext context) => Icon(
    AppIcons.byKey[iconKey] ?? AppIcons.dotsThreeCircle,
    size: size,
    color: context.presetColor(colorKey).foreground,
  );
}
