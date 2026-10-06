import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/insights/domain/insights_calculator.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:meta/meta.dart';

/// A reduce habit in S-30: what it cost in the month and the pace behind
/// the yearly projection.
@immutable
class ReduceHabitInsight {
  const ReduceHabitInsight({
    required this.habit,
    required this.spent,
    required this.perWeek,
    required this.annualProjection,
  });

  final Habit habit;
  final Money spent;

  /// Occurrences per week over the last 28 days (05 §4.4).
  final double perWeek;
  final Money annualProjection;
}

/// A build habit in S-30: consistency in the month and the change from the
/// month before.
@immutable
class BuildHabitInsight {
  const BuildHabitInsight({
    required this.habit,
    required this.consistency,
    required this.trendPoints,
  });

  final Habit habit;

  /// 0–1.
  final double consistency;

  /// Percentage points against last month; null without a last month to
  /// compare.
  final int? trendPoints;
}

/// One slice of the category donut.
@immutable
class CategorySlice {
  const CategorySlice({
    required this.category,
    required this.amount,
    required this.share,
  });

  final Category category;
  final Money amount;

  /// 0–1 of the month's spending.
  final double share;
}

/// Everything S-30 shows for one month.
@immutable
class MonthInsights {
  const MonthInsights({
    required this.month,
    required this.totalExpense,
    required this.reduceShare,
    required this.reduce,
    required this.build,
    required this.categories,
  });

  final YearMonth month;
  final Money totalExpense;
  final ReduceShare reduceShare;
  final List<ReduceHabitInsight> reduce;
  final List<BuildHabitInsight> build;
  final List<CategorySlice> categories;
}

/// Puts the S-30 numbers together from habits, their logs and the month's
/// transactions. Pure Dart, so the screen only formats.
abstract final class MonthInsightsBuilder {
  static MonthInsights build({
    required YearMonth month,
    required LocalDate today,
    required Iterable<Habit> habits,
    required Iterable<HabitLog> logs,
    required Iterable<TransactionListItem> items,
  }) {
    final expenses = [
      for (final item in items)
        if (!item.entry.isDeleted && item.entry.kind == TransactionKind.expense)
          item,
    ];
    final reduceIds = {
      for (final h in habits)
        if (h.kind == HabitKind.reduce) h.id,
    };
    final spentBy = <String, Money>{};
    final reduceLogIds = <String>{};
    for (final item in expenses) {
      final habitId = item.habitId;
      final logId = item.entry.habitLogId;
      if (habitId == null || logId == null || !reduceIds.contains(habitId)) {
        continue;
      }
      reduceLogIds.add(logId);
      spentBy.update(
        habitId,
        (v) => v + item.entry.amount,
        ifAbsent: () => item.entry.amount,
      );
    }
    final share = InsightsCalculator.reduceShare(
      transactions: [for (final item in expenses) item.entry],
      reduceHabitLogIds: reduceLogIds,
    );

    final reduce = <ReduceHabitInsight>[
      for (final h in habits)
        if (h.kind == HabitKind.reduce &&
            (!h.isArchived || (spentBy[h.id] ?? 0) > 0))
          _reduceInsight(h, spentBy[h.id] ?? 0, logs, today),
    ]..sort((a, b) => b.spent.compareTo(a.spent));

    final build = <BuildHabitInsight>[
      for (final h in habits)
        if (h.kind == HabitKind.build && !h.isArchived)
          ?_buildInsight(h, logs, month, today),
    ];

    return MonthInsights(
      month: month,
      totalExpense: share.totalExpense,
      reduceShare: share,
      reduce: reduce,
      build: build,
      categories: _slices(expenses, share.totalExpense),
    );
  }

  static ReduceHabitInsight _reduceInsight(
    Habit habit,
    Money spent,
    Iterable<HabitLog> logs,
    LocalDate today,
  ) {
    final perWeek = InsightsCalculator.averagePerWeek(
      logs: [
        for (final l in logs)
          if (l.habitId == habit.id) l,
      ],
      today: today,
    );
    return ReduceHabitInsight(
      habit: habit,
      spent: spent,
      perWeek: perWeek,
      annualProjection: InsightsCalculator.annualProjection(
        perWeek: perWeek,
        costPerOccurrence: habit.costPerOccurrence ?? 0,
      ),
    );
  }

  static BuildHabitInsight? _buildInsight(
    Habit habit,
    Iterable<HabitLog> logs,
    YearMonth month,
    LocalDate today,
  ) {
    final own = [
      for (final l in logs)
        if (l.habitId == habit.id) l,
    ];
    final thisMonth = InsightsCalculator.monthlyConsistency(
      habit: habit,
      logs: own,
      year: month.year,
      month: month.month,
      today: today,
    );
    if (thisMonth == null) return null;
    final before = month.addMonths(-1);
    final lastMonth = InsightsCalculator.monthlyConsistency(
      habit: habit,
      logs: own,
      year: before.year,
      month: before.month,
      today: today,
    );
    final trend = InsightsCalculator.consistencyTrend(
      thisMonth: thisMonth,
      lastMonth: lastMonth,
    );
    return BuildHabitInsight(
      habit: habit,
      consistency: thisMonth,
      trendPoints: trend?.round(),
    );
  }

  static List<CategorySlice> _slices(
    List<TransactionListItem> expenses,
    Money total,
  ) {
    if (total == 0) return const [];
    final byCategory = <String, ({Category category, Money amount})>{};
    for (final item in expenses) {
      final id = item.category.id;
      final previous = byCategory[id]?.amount ?? 0;
      byCategory[id] = (
        category: item.category,
        amount: previous + item.entry.amount,
      );
    }
    return [
      for (final e in byCategory.values)
        CategorySlice(
          category: e.category,
          amount: e.amount,
          share: e.amount / total,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
  }
}
