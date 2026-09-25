import 'dart:async';

import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SegmentedToggleOption<T> {
  const SegmentedToggleOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// iOS-style segmented control with 2-3 options (§7.5). The visual track is
/// 40 dp tall; the tappable area is padded up to the 48 dp minimum.
class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  }) : assert(
         options.length >= 2 && options.length <= 3,
         'SegmentedToggle supports 2 or 3 options',
       );

  final List<SegmentedToggleOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final selectedIndex = options.indexWhere((o) => o.value == selected);
    const trackRadius = BorderRadius.all(Radius.circular(AppRadius.sm));
    const thumbRadius = BorderRadius.all(
      Radius.circular(AppRadius.sm - AppSpacing.space1),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSizes.segmentedHeight,
          ),
          padding: const EdgeInsets.all(AppSpacing.space1),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: trackRadius,
          ),
          child: Stack(
            children: [
              if (selectedIndex >= 0)
                Positioned.fill(
                  child: AnimatedAlign(
                    alignment: Alignment(
                      options.length == 1
                          ? 0
                          : -1 + 2 * selectedIndex / (options.length - 1),
                      0,
                    ),
                    duration: AppDurations.resolve(
                      AppDurations.base,
                      reduceMotion: reduceMotion,
                    ),
                    curve: AppDurations.baseCurve,
                    child: FractionallySizedBox(
                      widthFactor: 1 / options.length,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: thumbRadius,
                          border: Border.all(color: colors.border),
                        ),
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  for (final option in options)
                    Expanded(
                      child: _Segment(
                        label: option.label,
                        selected: option.value == selected,
                        onTap: () {
                          if (option.value == selected) return;
                          unawaited(HapticFeedback.selectionClick());
                          onChanged(option.value);
                        },
                      ),
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

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space1,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: selected ? colors.textPrimary : colors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
