import 'dart:async';

import 'package:compound_me/core/design/components/app_sheet.dart';
import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Icon in its preset color on a 12% tint of it (§3.5). Never a solid fill.
class IconBadge extends StatelessWidget {
  const IconBadge({
    required this.iconKey,
    required this.colorKey,
    this.size = AppSizes.iconBadge,
    this.iconSize = AppSizes.iconSm,
    super.key,
  });

  final String iconKey;
  final String colorKey;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final preset = context.presetColor(colorKey);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: preset.background,
          shape: BoxShape.circle,
        ),
        child: Icon(
          AppIcons.byKey[iconKey] ?? AppIcons.dotsThreeCircle,
          size: iconSize,
          color: preset.foreground,
        ),
      ),
    );
  }
}

/// The eight preset colors as swatches (§3.5), each with a 48 dp target.
class ColorPicker extends StatelessWidget {
  const ColorPicker({
    required this.selectedKey,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
  });

  final String selectedKey;
  final ValueChanged<String> onChanged;

  /// Spoken name of a preset, e.g. "Hijau".
  final String Function(AppPresetColor color) semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Two even rows of four: eight 48 dp targets don't fit one row.
    const perRow = 4;
    const presets = AppPresetColor.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var start = 0; start < presets.length; start += perRow)
          Row(
            children: [
              for (final preset in presets.skip(start).take(perRow))
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: AppSpacing.space2,
                  ),
                  child: _swatch(context, preset),
                ),
            ],
          ),
      ],
    );
  }

  Widget _swatch(BuildContext context, AppPresetColor preset) {
    final colors = context.tokens.colors;
    final selected = preset.key == selectedKey;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel(preset),
      excludeSemantics: true,
      onTap: () => _select(preset.key),
      child: InkResponse(
        onTap: () => _select(preset.key),
        radius: AppSizes.minTouchTarget / 2,
        child: SizedBox.square(
          dimension: AppSizes.minTouchTarget,
          child: Center(
            child: Container(
              width: AppSizes.colorSwatch,
              height: AppSizes.colorSwatch,
              decoration: BoxDecoration(
                color: preset.foreground(Theme.of(context).brightness),
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(
                        color: colors.textPrimary,
                        width: AppSizes.borderSelected,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      )
                    : null,
              ),
              child: selected
                  ? Icon(
                      AppIcons.check,
                      size: AppSizes.iconSm,
                      color: colors.surface,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  void _select(String key) {
    if (key == selectedKey) return;
    unawaited(HapticFeedback.selectionClick());
    onChanged(key);
  }
}

/// Grid of the curated icons (§6) in the chosen color. Returns the picked
/// key, or null when dismissed.
Future<String?> showIconPickerSheet(
  BuildContext context, {
  required String title,
  required String selectedKey,
  required String colorKey,
  required String Function(int position, int total) semanticLabel,
}) => showAppSheet<String>(
  context,
  builder: (context) {
    final colors = context.tokens.colors;
    final preset = context.presetColor(colorKey);
    final keys = AppIcons.byKey.keys.toList();
    return SheetBody(
      title: title,
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: AppSizes.row,
          mainAxisSpacing: AppSpacing.space1,
          crossAxisSpacing: AppSpacing.space1,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final selected = key == selectedKey;
          return Semantics(
            button: true,
            selected: selected,
            label: semanticLabel(index + 1, keys.length),
            excludeSemantics: true,
            onTap: () => Navigator.of(context).pop(key),
            child: InkResponse(
              onTap: () => Navigator.of(context).pop(key),
              radius: AppSizes.minTouchTarget / 2,
              child: Center(
                child: Container(
                  width: AppSizes.iconBadge,
                  height: AppSizes.iconBadge,
                  decoration: BoxDecoration(
                    color: preset.background,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: colors.textPrimary,
                            width: AppSizes.borderSelected,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          )
                        : null,
                  ),
                  child: Icon(
                    AppIcons.byKey[key],
                    size: AppSizes.iconSm,
                    color: preset.foreground,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  },
);
