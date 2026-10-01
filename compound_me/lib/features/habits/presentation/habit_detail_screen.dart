import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_progress.dart';
import 'package:compound_me/features/habits/presentation/habit_actions.dart';
import 'package:compound_me/features/habits/presentation/habit_editor_screen.dart';
import 'package:compound_me/features/habits/presentation/habit_labels.dart';
import 'package:compound_me/features/habits/presentation/habit_providers.dart';
import 'package:compound_me/features/insights/domain/insights_calculator.dart';
import 'package:compound_me/features/insights/presentation/simulator_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Habit detail (S-22): streak, best and 30-day consistency, the month
/// calendar, for reduce habits this month's cost and the yearly pace,
/// and the latest check-ins. "Simulasikan" (S-31) arrives in phase 5.
class HabitDetailScreen extends ConsumerStatefulWidget {
  const HabitDetailScreen({required this.habitId, super.key});

  final String habitId;

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  /// Null follows the current month.
  YearMonth? _month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = ref.watch(habitDetailProvider(widget.habitId));
    final progress = detail.value;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppLargeTitle(
            title: progress?.habit.name ?? '',
            backLabel: l10n.actionBack,
            actions: [
              if (progress != null)
                PopupMenuButton<void>(
                  tooltip: l10n.habitsMore,
                  icon: const Icon(AppIcons.dotsThree),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => unawaited(
                        openHabitEditor(context, habitId: widget.habitId),
                      ),
                      child: Text(l10n.actionEdit),
                    ),
                    PopupMenuItem(
                      onTap: () => unawaited(_setArchived(progress.habit)),
                      child: Text(
                        progress.habit.isArchived
                            ? l10n.actionRestore
                            : l10n.habitArchive,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          ...switch (detail) {
            AsyncData(:final value?) => _content(value),
            AsyncData() => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: AppIcons.checkCircle,
                  title: l10n.habitsEmptyTitle,
                  message: l10n.errorLoadBody,
                ),
              ),
            ],
            _ => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AsyncBody<void>(
                  value: detail,
                  data: (_) => const SizedBox.shrink(),
                  errorLabels: l10n.loadErrorLabels,
                  onRetry: () => ref.invalidate(habitProgressProvider),
                ),
              ),
            ],
          },
        ],
      ),
    );
  }

  Future<void> _setArchived(Habit habit) async {
    final l10n = context.l10n;
    final repository = ref.read(habitRepositoryProvider);
    if (habit.isArchived) {
      await repository.unarchive(habit.id);
      return;
    }
    await repository.archive(habit.id);
    if (!mounted) return;
    showUndoSnackbar(
      context,
      message: l10n.habitArchivedDone,
      undoLabel: l10n.undoAction,
      onUndo: () => unawaited(repository.unarchive(habit.id)),
    );
  }

  List<Widget> _content(HabitProgress progress) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final habit = progress.habit;
    final reduce = habit.kind == HabitKind.reduce;
    final today = LocalDate.fromDateTime(ref.watch(nowProvider));
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);
    Widget section(Widget child, {double top = AppSpacing.space4}) =>
        SliverPadding(
          padding: pad.copyWith(top: top),
          sliver: SliverToBoxAdapter(child: child),
        );

    return [
      section(_Header(progress: progress), top: 0),
      if (habit.isArchived)
        section(
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.habitArchivedBanner,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => unawaited(
                    ref.read(habitRepositoryProvider).unarchive(habit.id),
                  ),
                  child: Text(l10n.actionRestore),
                ),
              ],
            ),
          ),
        ),
      section(_Stats(progress: progress)),
      if (reduce && habit.weeklyLimit == null)
        section(
          AppCard(
            onTap: () => unawaited(openHabitEditor(context, habitId: habit.id)),
            child: Row(
              children: [
                Icon(AppIcons.flame, color: colors.primary),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Text(
                    l10n.habitSetLimitCta,
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ),
                Icon(
                  AppIcons.caretRight,
                  size: AppSizes.iconSm,
                  color: colors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      section(
        AppCard(
          child: _Calendar(
            progress: progress,
            month: _month ?? YearMonth(today.year, today.month),
            today: today,
            onMonth: (month) => setState(() => _month = month),
          ),
        ),
      ),
      if (reduce) section(_CostCard(progress: progress, today: today)),
      section(
        SectionHeader(title: l10n.habitRecentTitle),
        top: AppSpacing.space6,
      ),
      section(_RecentCheckIns(habit: habit, today: today), top: 0),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progress});

  final HabitProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final habit = progress.habit;
    final reduce = habit.kind == HabitKind.reduce;
    return Row(
      children: [
        IconBadge(
          iconKey: habit.iconKey,
          colorKey: habit.colorKey,
          size: AppSizes.iconBadgeLarge,
          iconSize: AppSizes.iconLg,
        ),
        const SizedBox(width: AppSpacing.space4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${habitKindLabel(l10n, habit.kind)} · '
                '${scheduleLabel(l10n, habit)}',
                style: AppTextStyles.body.copyWith(color: colors.textPrimary),
              ),
              if (reduce)
                Text(
                  costLabel(l10n, habit),
                  style: AppTextStyles.bodySmall.tabular.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (!habit.isArchived)
          CheckButton(
            done: progress.doneToday,
            count: reduce ? progress.todayCount : null,
            semanticLabel: checkInSemantics(l10n, progress),
            onTap: () => unawaited(toggleCheckIn(context, progress)),
            onLongPress: reduce
                ? () => unawaited(openCountStepper(context, progress))
                : null,
          ),
      ],
    );
  }
}

/// Streak (with the flame), best, and 30-day consistency for build
/// habits or this week's count for reduce habits.
class _Stats extends StatelessWidget {
  const _Stats({required this.progress});

  final HabitProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final streak = progress.streak;
    final reduce = progress.habit.kind == HabitKind.reduce;
    final consistency = streak?.consistency30;
    Widget cell(String label, String value, {IconData? icon, Color? color}) =>
        Expanded(
          child: Semantics(
            container: true,
            label: '$label, $value',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: AppSizes.iconSm,
                          color: colors.accentText,
                        ),
                        const SizedBox(width: AppSpacing.space1),
                      ],
                      Text(
                        value,
                        style: AppTextStyles.titleSmall.tabular.copyWith(
                          color: color ?? colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    final none = l10n.habitStatNone;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cell(
            l10n.habitStatStreak,
            streak == null
                ? none
                : streakLabel(l10n, streak.current, streak.unit),
            icon: streak == null ? null : AppIcons.flameFill,
          ),
          const SizedBox(width: AppSpacing.space3),
          cell(
            l10n.habitStatBest,
            streak == null ? none : streakLabel(l10n, streak.best, streak.unit),
          ),
          const SizedBox(width: AppSpacing.space3),
          if (reduce)
            cell(
              l10n.habitStatThisWeek,
              progress.habit.weeklyLimit == null
                  ? '${progress.weekCount}'
                  : '${progress.weekCount}/${progress.habit.weeklyLimit}',
              color: progress.overWeeklyLimit
                  ? colors.danger
                  : progress.atWeeklyLimit
                  ? colors.warning
                  : null,
            )
          else
            cell(
              l10n.habitStatConsistency,
              consistency == null
                  ? none
                  : l10n.percent((consistency * 100).round()),
            ),
        ],
      ),
    );
  }
}

class _Calendar extends ConsumerWidget {
  const _Calendar({
    required this.progress,
    required this.month,
    required this.today,
    required this.onMonth,
  });

  final HabitProgress progress;
  final YearMonth month;
  final LocalDate today;
  final ValueChanged<YearMonth> onMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final habit = progress.habit;
    final logs = ref.watch(habitLogsProvider(habit.id)).value ?? const [];
    final marks = markMonth(
      habit: habit,
      counts: countsByDate(logs),
      graceDates: progress.streak?.graceDates ?? const {},
      month: month,
      today: today,
    );
    final perDay =
        habit.kind == HabitKind.build &&
        habit.scheduleType != ScheduleType.timesPerWeek;
    final start = YearMonth(habit.startDate.year, habit.startDate.month);
    final current = YearMonth(today.year, today.month);

    CalendarDayStyle styleOf(LocalDate day) => switch (marks[day]) {
      DayMark.done => CalendarDayStyle.filled,
      DayMark.grace => CalendarDayStyle.grace,
      DayMark.missed => CalendarDayStyle.missed,
      DayMark.open => CalendarDayStyle.today,
      DayMark.future => CalendarDayStyle.future,
      _ => CalendarDayStyle.plain,
    };
    String status(CalendarDayStyle style) => switch (style) {
      CalendarDayStyle.filled =>
        habit.kind == HabitKind.reduce ? l10n.legendLogged : l10n.legendDone,
      CalendarDayStyle.grace => l10n.legendGrace,
      CalendarDayStyle.missed => l10n.legendMissed,
      CalendarDayStyle.today => l10n.legendOpen,
      _ => '',
    };

    return HabitCalendar(
      month: month,
      labels: l10n.monthGridLabels,
      styleOf: styleOf,
      dayLabel: (day, style) {
        final text = status(style);
        return text.isEmpty
            ? l10n.fullDate(day)
            : l10n.calendarDay(l10n.fullDate(day), text);
      },
      legend: (
        done: habit.kind == HabitKind.reduce
            ? l10n.legendLogged
            : l10n.legendDone,
        grace: perDay ? l10n.legendGrace : null,
        missed: perDay ? l10n.legendMissed : null,
      ),
      onPrevious: month.compareTo(start) > 0
          ? () => onMonth(month.addMonths(-1))
          : null,
      onNext: month.compareTo(current) < 0
          ? () => onMonth(month.addMonths(1))
          : null,
    );
  }
}

/// "Biaya bulan ini Rp 310.000 · proyeksi setahun ±Rp 4,0 jt" with the
/// simulator button (S-22).
class _CostCard extends ConsumerWidget {
  const _CostCard({required this.progress, required this.today});

  final HabitProgress progress;
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final habit = progress.habit;
    final spent = ref.watch(habitSpentThisMonthProvider(habit.id)).value;
    final logs = ref.watch(habitLogsProvider(habit.id)).value ?? const [];
    final yearly = InsightsCalculator.annualProjection(
      perWeek: InsightsCalculator.averagePerWeek(logs: logs, today: today),
      costPerOccurrence: habit.costPerOccurrence ?? 0,
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitCostMonth,
            style: AppTextStyles.label.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            spent == null ? '' : formatRupiah(spent),
            style: AppTextStyles.titleMedium.tabular.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            l10n.habitCostYear(
              formatRupiah(yearly, compact: true, localeCode: l10n.localeName),
            ),
            style: AppTextStyles.bodySmall.tabular.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          SecondaryButton(
            label: l10n.habitSimulate,
            expand: false,
            onPressed: () => unawaited(showSimulatorSheet(context, habit.id)),
          ),
        ],
      ),
    );
  }
}

class _RecentCheckIns extends ConsumerWidget {
  const _RecentCheckIns({required this.habit, required this.today});

  final Habit habit;
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final checkIns = ref.watch(habitCheckInsProvider(habit.id)).value;
    if (checkIns == null) return const SizedBox.shrink();
    if (checkIns.isEmpty) {
      return Text(
        l10n.habitRecentEmpty,
        style: AppTextStyles.body.copyWith(color: colors.textSecondary),
      );
    }
    final reduce = habit.kind == HabitKind.reduce;
    return AppListGroup(
      children: [
        for (final checkIn in checkIns)
          AppListTile(
            title: l10n.dayLabel(checkIn.date, today),
            subtitle: reduce ? l10n.habitCountValue(checkIn.count) : null,
            value: reduce ? formatRupiah(-checkIn.spent) : null,
            trailing: reduce
                ? null
                : Icon(
                    AppIcons.checkCircleFill,
                    size: AppSizes.iconSm,
                    color: colors.primary,
                  ),
            showChevron: false,
          ),
      ],
    );
  }
}
