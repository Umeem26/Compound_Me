import 'dart:math' as math;

import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';

/// Home strip check-in (§7.4): a 56 dp circle with the habit icon, a 3 dp
/// progress ring, and the name below. Done = filled `teal700` with a white
/// icon; a reduce habit already logged today keeps the ring full and shows
/// its count in a badge. The ring fills in 250 ms (§8).
class HabitChip extends StatelessWidget {
  const HabitChip({
    required this.iconKey,
    required this.colorKey,
    required this.label,
    required this.semanticLabel,
    required this.progress,
    required this.done,
    required this.onTap,
    this.badge,
    this.onLongPress,
    super.key,
  });

  final String iconKey;
  final String colorKey;
  final String label;
  final String semanticLabel;

  /// 0–1 of the ring.
  final double progress;

  /// Filled: a build habit checked in today.
  final bool done;

  /// Reduce: today's count, shown when above zero.
  final int? badge;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final preset = context.presetColor(colorKey);
    final duration = AppDurations.resolve(
      AppDurations.base,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
    final count = badge ?? 0;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        child: SizedBox(
          width: AppSizes.habitChipLabel,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: AppSizes.habitChip + AppSizes.habitChipRing * 2,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: progress),
                        duration: duration,
                        curve: AppDurations.baseCurve,
                        builder: (context, value, _) => CustomPaint(
                          size: const Size.square(
                            AppSizes.habitChip + AppSizes.habitChipRing * 2,
                          ),
                          painter: _RingPainter(
                            progress: value,
                            track: colors.border,
                            fill: colors.primary,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: duration,
                        width: AppSizes.habitChip - AppSizes.habitChipRing,
                        height: AppSizes.habitChip - AppSizes.habitChipRing,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? colors.primary : colors.surface,
                        ),
                        child: Icon(
                          AppIcons.byKey[iconKey] ?? AppIcons.dotsThreeCircle,
                          size: AppSizes.iconLg,
                          color: done ? colors.onPrimary : preset.foreground,
                        ),
                      ),
                      if (count > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CountBadge(count: count),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small filled circle with a number, e.g. today's count of a reduce habit.
class CountBadge extends StatelessWidget {
  const CountBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Container(
      constraints: const BoxConstraints(
        minWidth: AppSizes.badge,
        minHeight: AppSizes.badge,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.full)),
        border: Border.all(color: colors.surface),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.caption.tabular.copyWith(color: colors.onPrimary),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = AppSizes.habitChipRing;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        paint
          ..color = fill
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}

/// 44 dp round check button of a HabitTile (§7.4), in a 48 dp target:
/// outlined when open, filled with a check when done, filled with the
/// count for a reduce habit logged today.
class CheckButton extends StatelessWidget {
  const CheckButton({
    required this.done,
    required this.semanticLabel,
    required this.onTap,
    this.count,
    this.onLongPress,
    super.key,
  });

  final bool done;
  final String semanticLabel;
  final VoidCallback onTap;

  /// Reduce: today's count instead of the check.
  final int? count;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final shown = count;
    return Semantics(
      button: true,
      checked: done,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: InkResponse(
        onTap: onTap,
        onLongPress: onLongPress,
        radius: AppSizes.minTouchTarget / 2,
        child: SizedBox.square(
          dimension: AppSizes.minTouchTarget,
          child: Center(
            child: AnimatedContainer(
              duration: AppDurations.resolve(
                AppDurations.fast,
                reduceMotion: MediaQuery.disableAnimationsOf(context),
              ),
              width: AppSizes.checkButton,
              height: AppSizes.checkButton,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? colors.primary : colors.surface,
                border: done
                    ? null
                    : Border.all(
                        color: colors.border,
                        width: AppSizes.borderSelected,
                      ),
              ),
              child: !done
                  ? null
                  : shown != null && shown > 0
                  ? Text(
                      '$shown',
                      style: AppTextStyles.label.tabular.copyWith(
                        color: colors.onPrimary,
                      ),
                    )
                  : Icon(
                      AppIcons.check,
                      size: AppSizes.iconSm,
                      color: colors.onPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A habit on the habits tab (§7.4): 72 dp, icon on the left, name over
/// its schedule or cost, an optional extra line (streak, week count, a
/// hint), and the check button on the right.
class HabitTile extends StatelessWidget {
  const HabitTile({
    required this.iconKey,
    required this.colorKey,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.detail,
    this.trailing,
    super.key,
  });

  final String iconKey;
  final String colorKey;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Third line, e.g. a streak with the flame icon.
  final Widget? detail;

  /// Usually a [CheckButton].
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final preset = context.presetColor(colorKey);
    const radius = BorderRadius.all(Radius.circular(AppRadius.md));
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.habitTile),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.space4,
              end: AppSpacing.space1,
              top: AppSpacing.space2,
              bottom: AppSpacing.space2,
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: AppSizes.checkButton,
                    height: AppSizes.checkButton,
                    decoration: BoxDecoration(
                      color: preset.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.byKey[iconKey] ?? AppIcons.dotsThreeCircle,
                      size: AppSizes.iconLg,
                      color: preset.foreground,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.tabular.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      ?detail,
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small line with an icon, e.g. the streak "12 hari" with the flame in
/// gold (§7.4) or "minggu ini 3/4" in warning.
class IconLine extends StatelessWidget {
  const IconLine({
    required this.text,
    this.icon,
    this.color,
    this.iconColor,
    super.key,
  });

  final String text;
  final IconData? icon;
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final textColor = color ?? colors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSizes.iconXs, color: iconColor ?? textColor),
          const SizedBox(width: AppSpacing.space1),
        ],
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.caption.tabular.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}

/// Text of [CountStepper]'s buttons.
typedef StepperLabels = ({String decrease, String increase});

/// − value + for small whole numbers (times per week, weekly limit, a
/// day's count). A null callback disables that side.
class CountStepper extends StatelessWidget {
  const CountStepper({
    required this.value,
    required this.labels,
    required this.onDecrease,
    required this.onIncrease,
    this.semanticValue,
    super.key,
  });

  /// What sits between the buttons, e.g. "3" or "Tanpa batas".
  final String value;
  final StepperLabels labels;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    Widget button(IconData icon, String label, VoidCallback? onTap) =>
        IconButton(
          onPressed: onTap,
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: colors.surfaceMuted,
            foregroundColor: colors.textPrimary,
            disabledBackgroundColor: colors.surfaceMuted.withValues(
              alpha: AppOpacity.disabled,
            ),
            fixedSize: const Size.square(AppSizes.iconButtonTonal),
            minimumSize: const Size.square(AppSizes.iconButtonTonal),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
          iconSize: AppSizes.iconSm,
          icon: Icon(icon),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(AppIcons.minus, labels.decrease, onDecrease),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: AppSizes.minTouchTarget),
          child: Semantics(
            liveRegion: true,
            label: semanticValue ?? value,
            excludeSemantics: true,
            child: Text(
              value,
              style: AppTextStyles.titleSmall.tabular.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        button(AppIcons.plus, labels.increase, onIncrease),
      ],
    );
  }
}
