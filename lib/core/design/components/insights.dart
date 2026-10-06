import 'dart:math' as math;

import 'package:compound_me/core/design/components/app_card.dart';
import 'package:compound_me/core/design/components/pickers.dart';
import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Flat bar showing a share of a whole (S-30 main card). A solid fill on a
/// muted track, never a gradient (§10). The number it stands for is always
/// written next to it, so it carries no semantics of its own.
class ProportionBar extends StatelessWidget {
  const ProportionBar({required this.value, super.key});

  /// 0–1.
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.full));
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: AppSizes.proportionBar,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: colors.surfaceMuted)),
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: value.clamp(0, 1).toDouble(),
                  child: ColoredBox(color: colors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Which way a build habit moved against last month.
enum TrendDirection { up, down, flat }

/// An arrow icon and text: teal when up, warning gold when down. Down is
/// never red, because a worse month is not a failure (05 §4.3).
class TrendLabel extends StatelessWidget {
  const TrendLabel({
    required this.text,
    required this.direction,
    required this.semanticLabel,
    super.key,
  });

  final String text;
  final TrendDirection direction;

  /// "naik 12 poin dibanding bulan lalu"; the arrow alone says nothing to a
  /// screen reader.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final color = switch (direction) {
      TrendDirection.up => colors.success,
      TrendDirection.down => colors.warning,
      TrendDirection.flat => colors.textSecondary,
    };
    final icon = switch (direction) {
      TrendDirection.up => AppIcons.caretUp,
      TrendDirection.down => AppIcons.caretDown,
      TrendDirection.flat => null,
    };
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconXs, color: color),
            const SizedBox(width: AppSpacing.space1),
          ],
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.caption.tabular.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// One slice of [CategoryDonut].
class DonutSlice {
  const DonutSlice({required this.value, required this.color});

  final double value;
  final Color color;
}

/// Donut chart (S-30). Slices are tappable; the list under it carries the
/// same information as text, so the chart itself is hidden from screen
/// readers.
class CategoryDonut extends StatelessWidget {
  const CategoryDonut({
    required this.slices,
    required this.centerLabel,
    required this.centerValue,
    required this.onSliceTap,
    super.key,
  });

  final List<DonutSlice> slices;
  final String centerLabel;
  final String centerValue;
  final ValueChanged<int> onSliceTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    const ringRadius = AppSizes.donutRing;
    const centerRadius = AppSizes.donut / 2 - ringRadius;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: AppSizes.donut,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: AppSizes.donutGap,
                centerSpaceRadius: centerRadius,
                startDegreeOffset: -90,
                sections: [
                  for (final slice in slices)
                    PieChartSectionData(
                      value: slice.value,
                      color: slice.color,
                      radius: ringRadius,
                      showTitle: false,
                    ),
                ],
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    final index = response?.touchedSection?.touchedSectionIndex;
                    if (event is FlTapUpEvent && index != null && index >= 0) {
                      onSliceTap(index);
                    }
                  },
                ),
              ),
              duration: reduceMotion ? Duration.zero : AppDurations.base,
            ),
            const SizedBox.square(dimension: centerRadius * 2),
            SizedBox.square(
              dimension: centerRadius * 2 - AppSpacing.space4,
              child: FittedBox(
                // Shrinks long totals, never blows short ones up.
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      centerValue,
                      style: AppTextStyles.titleSmall.tabular.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small ring with "3 dari 7 hari" beside it (S-30 empty state).
class DaysProgress extends StatelessWidget {
  const DaysProgress({
    required this.current,
    required this.total,
    required this.label,
    super.key,
  });

  final int current;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: AppSizes.progressRing,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                progress: total == 0 ? 0 : current / total,
                track: colors.surfaceMuted,
                fill: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.label.tabular.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = AppSizes.progressRingStroke;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawArc(rect, 0, 2 * math.pi, false, paint..color = track)
      ..drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0, 1),
        false,
        paint..color = fill,
      );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}

/// The single insight card on Home (S-10): a lightbulb, one sentence and
/// what tapping it leads to.
class InsightCard extends StatelessWidget {
  const InsightCard({
    required this.message,
    required this.actionLabel,
    required this.onTap,
    super.key,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Semantics(
      button: true,
      label: '$message $actionLabel',
      excludeSemantics: true,
      onTap: onTap,
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: AppSizes.iconBadge,
              height: AppSizes.iconBadge,
              decoration: BoxDecoration(
                color: colors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.lightbulb,
                size: AppSizes.iconSm,
                color: colors.onPrimaryTint,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: AppTextStyles.body.tabular.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          actionLabel,
                          style: AppTextStyles.label.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ),
                      Icon(
                        AppIcons.caretRight,
                        size: AppSizes.iconXs,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slider for a share from 0 to 100 % in steps of 10 (S-31), with its value
/// read out as "50 persen" for screen readers.
class PercentSlider extends StatelessWidget {
  const PercentSlider({
    required this.value,
    required this.onChanged,
    required this.valueLabel,
    required this.semanticLabel,
    super.key,
  });

  /// 0–100, a multiple of 10.
  final int value;
  final ValueChanged<int> onChanged;

  /// What the slider is for, e.g. "Kurangi".
  final String semanticLabel;

  /// Spoken form of a value, e.g. "50 persen".
  final String Function(int value) valueLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: AppSizes.sliderTrack,
          activeTrackColor: colors.primary,
          inactiveTrackColor: colors.surfaceMuted,
          thumbColor: colors.primary,
          overlayColor: colors.primaryTint,
          activeTickMarkColor: Colors.transparent,
          inactiveTickMarkColor: Colors.transparent,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: AppSizes.sliderThumb,
            elevation: 0,
            pressedElevation: 0,
          ),
          showValueIndicator: ShowValueIndicator.never,
        ),
        child: Semantics(
          label: semanticLabel,
          child: Slider(
            value: value.toDouble(),
            max: 100,
            divisions: 10,
            semanticFormatterCallback: (v) => valueLabel(v.round()),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ),
    );
  }
}

/// A habit row of S-30: icon, name and a figure on one line, a detail line
/// under them across the whole width. Unlike a plain list tile, a big
/// figure and large text never squeeze the name into broken words (text
/// scale 1,3 on 360 dp).
class InsightHabitTile extends StatelessWidget {
  const InsightHabitTile({
    required this.iconKey,
    required this.colorKey,
    required this.title,
    required this.value,
    required this.detail,
    required this.onTap,
    this.valueSemantics,
    super.key,
  });

  final String iconKey;
  final String colorKey;
  final String title;

  /// The figure on the right of the name, e.g. "Rp 310.000" or "83%".
  final String value;

  /// What a screen reader says instead of [value].
  final String? valueSemantics;

  /// Under the name and figure, e.g. a pace line or a [TrendLabel].
  final Widget detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Semantics(
      container: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.row),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(iconKey: iconKey, colorKey: colorKey),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.body.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space2),
                          Text(
                            value,
                            semanticsLabel: valueSemantics,
                            style: AppTextStyles.bodyStrong.tabular.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      detail,
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space1),
                ExcludeSemantics(
                  child: Icon(
                    AppIcons.caretRight,
                    size: AppSizes.iconSm,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
