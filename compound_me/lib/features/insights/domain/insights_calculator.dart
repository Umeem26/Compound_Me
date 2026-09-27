import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/streak_calculator.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:meta/meta.dart';

/// How much of a period's spending came from reduce habits.
@immutable
class ReduceShare {
  const ReduceShare({required this.reduceAmount, required this.totalExpense});

  final Money reduceAmount;
  final Money totalExpense;

  /// 0–1, or null when there was no spending to divide by.
  double? get share => totalExpense == 0 ? null : reduceAmount / totalExpense;
}

/// Compound Insights formulas (05 §4.4), pure Dart.
abstract final class InsightsCalculator {
  /// Share of [transactions] (already limited to the period) spent through
  /// reduce-habit check-ins. [reduceHabitLogIds] are the ids of logs that
  /// belong to reduce habits. Deleted transactions and income are ignored.
  static ReduceShare reduceShare({
    required Iterable<TransactionEntry> transactions,
    required Set<String> reduceHabitLogIds,
  }) {
    var total = 0;
    var fromHabits = 0;
    for (final t in transactions) {
      if (t.isDeleted || t.kind != TransactionKind.expense) continue;
      total += t.amount;
      if (t.habitLogId != null && reduceHabitLogIds.contains(t.habitLogId)) {
        fromHabits += t.amount;
      }
    }
    return ReduceShare(reduceAmount: fromHabits, totalExpense: total);
  }

  /// Average occurrences per week: Σ count of the last 28 days ÷ 4.
  static double averagePerWeek({
    required Iterable<HabitLog> logs,
    required LocalDate today,
  }) {
    final from = today.addDays(-27);
    var total = 0;
    for (final log in logs) {
      if (log.date.isBefore(from) || log.date.isAfter(today)) continue;
      total += log.count;
    }
    return total / 4;
  }

  /// Yearly cost at the current pace: per week × 52 × cost.
  static Money annualProjection({
    required double perWeek,
    required Money costPerOccurrence,
  }) => (perWeek * 52 * costPerOccurrence).round();

  /// Savings per year when the habit is cut by [reduction] (0–1).
  static Money annualSavings({
    required Money annualProjection,
    required double reduction,
  }) {
    assert(reduction >= 0 && reduction <= 1, 'reduction is a 0–1 fraction');
    return (annualProjection * reduction).round();
  }

  /// Consistency of a build habit within one local calendar month, up to
  /// [today] for the running month.
  static double? monthlyConsistency({
    required Habit habit,
    required Iterable<HabitLog> logs,
    required int year,
    required int month,
    required LocalDate today,
  }) => StreakCalculator.consistencyBetween(
    habit: habit,
    logs: logs,
    from: LocalDate(year, month, 1),
    to: LocalDate(year, month + 1, 0),
    today: today,
  );

  /// Build-habit trend in percentage points: this month's consistency minus
  /// last month's. Null when either month has no scheduled days.
  static double? consistencyTrend({
    required double? thisMonth,
    required double? lastMonth,
  }) {
    if (thisMonth == null || lastMonth == null) return null;
    return (thisMonth - lastMonth) * 100;
  }
}
