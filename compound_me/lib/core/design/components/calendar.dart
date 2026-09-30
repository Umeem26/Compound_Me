import 'dart:async';
import 'dart:math' as math;

import 'package:compound_me/core/design/components/app_sheet.dart';
import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text a month grid needs, all Monday first: the week starts on Monday
/// everywhere in the app (05 §4.2), like "this week" and weekly streaks.
typedef MonthGridLabels = ({
  String Function(YearMonth month) title,
  List<String> weekdaysShort,
  List<String> weekdaysFull,
  String previous,
  String next,
});

/// One month as a 7-column grid, Monday first, with arrows (and a swipe)
/// to the months around it. [dayBuilder] draws each day's cell.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    required this.month,
    required this.labels,
    required this.dayBuilder,
    this.onPrevious,
    this.onNext,
    super.key,
  });

  final YearMonth month;
  final MonthGridLabels labels;
  final Widget Function(BuildContext context, LocalDate day, double size)
  dayBuilder;

  /// Null hides the arrow and stops the swipe that way.
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final first = LocalDate(month.year, month.month, 1);
    // Monday-first offset: weekday 1 (Monday) sits in the first column.
    final leading = first.weekday - 1;
    final days = LocalDate(month.year, month.month + 1, 0).day;
    final cells = leading + days;
    final rows = (cells / 7).ceil();

    Widget arrow(IconData icon, String label, VoidCallback? onTap) =>
        onTap == null
        ? const SizedBox.square(dimension: AppSizes.minTouchTarget)
        : IconButton(
            onPressed: onTap,
            tooltip: label,
            icon: Icon(icon, size: AppSizes.iconSm),
            color: colors.textSecondary,
          );

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 0) onPrevious?.call();
        if (velocity < 0) onNext?.call();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / 7;
          final size = math.min(width, AppSizes.minTouchTarget);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  arrow(AppIcons.caretLeft, labels.previous, onPrevious),
                  Expanded(
                    child: Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        labels.title(month),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: colors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  arrow(AppIcons.caretRight, labels.next, onNext),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    SizedBox(
                      width: width,
                      child: Semantics(
                        label: labels.weekdaysFull[i],
                        excludeSemantics: true,
                        child: Text(
                          labels.weekdaysShort[i],
                          style: AppTextStyles.caption.copyWith(
                            color: colors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.space1),
              for (var row = 0; row < rows; row++)
                Row(
                  children: [
                    for (var column = 0; column < 7; column++)
                      SizedBox(
                        width: width,
                        height: size,
                        child: switch (row * 7 + column - leading + 1) {
                          final day when day >= 1 && day <= days => Center(
                            child: dayBuilder(
                              context,
                              LocalDate(month.year, month.month, day),
                              size,
                            ),
                          ),
                          _ => null,
                        },
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Look of one day in [HabitCalendar] (§7.4).
enum CalendarDayStyle {
  /// Done: a filled `teal700` circle.
  filled,

  /// Grace day: a `gold500` outline.
  grace,

  /// Missed: a `border` dot under the number.
  missed,

  /// Today, still open: a thin outline.
  today,

  /// Nothing to show.
  plain,

  /// After today.
  future,
}

/// Legend line under [HabitCalendar]; null leaves an entry out, e.g. for
/// habits without per-day misses.
typedef CalendarLegend = ({String done, String? grace, String? missed});

/// A habit's month (§7.4): done days filled, grace days outlined in gold,
/// missed days with a dot, unscheduled days plain. [dayLabel] is what
/// screen readers hear for a day, e.g. "3 September, selesai".
class HabitCalendar extends StatelessWidget {
  const HabitCalendar({
    required this.month,
    required this.labels,
    required this.styleOf,
    required this.dayLabel,
    required this.legend,
    this.onPrevious,
    this.onNext,
    super.key,
  });

  final YearMonth month;
  final MonthGridLabels labels;
  final CalendarDayStyle Function(LocalDate day) styleOf;
  final String Function(LocalDate day, CalendarDayStyle style) dayLabel;

  final CalendarLegend legend;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final grace = legend.grace;
    final missed = legend.missed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MonthGrid(
          month: month,
          labels: labels,
          onPrevious: onPrevious,
          onNext: onNext,
          dayBuilder: (context, day, size) {
            final style = styleOf(day);
            return Semantics(
              label: dayLabel(day, style),
              excludeSemantics: true,
              child: _DayCell(
                day: day.day,
                style: style,
                size: math.min(size, AppSizes.calendarDay),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.space3),
        Wrap(
          spacing: AppSpacing.space4,
          runSpacing: AppSpacing.space2,
          children: [
            _LegendItem(style: CalendarDayStyle.filled, label: legend.done),
            if (grace != null)
              _LegendItem(style: CalendarDayStyle.grace, label: grace),
            if (missed != null)
              _LegendItem(style: CalendarDayStyle.missed, label: missed),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.style, required this.size});

  final int day;
  final CalendarDayStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final textColor = switch (style) {
      CalendarDayStyle.filled => colors.onPrimary,
      CalendarDayStyle.future => colors.textTertiary,
      CalendarDayStyle.missed || CalendarDayStyle.plain => colors.textSecondary,
      CalendarDayStyle.grace || CalendarDayStyle.today => colors.textPrimary,
    };
    final BoxBorder? border = switch (style) {
      CalendarDayStyle.grace => Border.all(
        color: colors.accent,
        width: AppSizes.borderSelected,
      ),
      CalendarDayStyle.today => Border.all(color: colors.primary),
      _ => null,
    };
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style == CalendarDayStyle.filled ? colors.primary : null,
              border: border,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: AppTextStyles.caption.tabular.copyWith(color: textColor),
            ),
          ),
          if (style == CalendarDayStyle.missed)
            Positioned(
              bottom: AppSpacing.space1,
              child: Container(
                width: AppSizes.calendarDot,
                height: AppSizes.calendarDot,
                decoration: BoxDecoration(
                  color: colors.border,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.style, required this.label});

  final CalendarDayStyle style;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Container(
            width: AppSizes.iconXs,
            height: AppSizes.iconXs,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: switch (style) {
                CalendarDayStyle.filled => colors.primary,
                CalendarDayStyle.missed => colors.border,
                _ => null,
              },
              border: style == CalendarDayStyle.grace
                  ? Border.all(
                      color: colors.accent,
                      width: AppSizes.borderSelected,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space1),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// Picks a day in a Monday-first calendar sheet (S-11 date row). Days after
/// [last] can't be picked. Returns the day at local midnight, or null.
Future<DateTime?> showDateSheet(
  BuildContext context, {
  required String title,
  required DateTime initial,
  required DateTime last,
  required MonthGridLabels labels,
  required String Function(LocalDate day) dayLabel,
}) => showAppSheet<DateTime>(
  context,
  builder: (context) => SheetBody(
    title: title,
    child: _DatePicker(
      initial: LocalDate.fromDateTime(initial),
      last: LocalDate.fromDateTime(last),
      labels: labels,
      dayLabel: dayLabel,
    ),
  ),
);

class _DatePicker extends StatefulWidget {
  const _DatePicker({
    required this.initial,
    required this.last,
    required this.labels,
    required this.dayLabel,
  });

  final LocalDate initial;
  final LocalDate last;
  final MonthGridLabels labels;
  final String Function(LocalDate day) dayLabel;

  @override
  State<_DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<_DatePicker> {
  late YearMonth _month = YearMonth(widget.initial.year, widget.initial.month);

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final lastMonth = YearMonth(widget.last.year, widget.last.month);
    return MonthGrid(
      month: _month,
      labels: widget.labels,
      onPrevious: () => setState(() => _month = _month.addMonths(-1)),
      onNext: _month.compareTo(lastMonth) < 0
          ? () => setState(() => _month = _month.addMonths(1))
          : null,
      dayBuilder: (context, day, size) {
        final enabled = !day.isAfter(widget.last);
        final selected = day == widget.initial;
        final today = day == widget.last;
        void pick() {
          unawaited(HapticFeedback.selectionClick());
          Navigator.of(context).pop(day.startLocal);
        }

        return Semantics(
          button: true,
          enabled: enabled,
          selected: selected,
          label: widget.dayLabel(day),
          excludeSemantics: true,
          onTap: enabled ? pick : null,
          child: InkResponse(
            onTap: enabled ? pick : null,
            radius: size / 2,
            child: Container(
              width: size - AppSpacing.space1,
              height: size - AppSpacing.space1,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? colors.primary : null,
                border: today && !selected
                    ? Border.all(color: colors.primary)
                    : null,
              ),
              child: Text(
                '${day.day}',
                style: AppTextStyles.body.tabular.copyWith(
                  color: selected
                      ? colors.onPrimary
                      : enabled
                      ? colors.textPrimary
                      : colors.textTertiary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
