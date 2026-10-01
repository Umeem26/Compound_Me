import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_progress.dart';
import 'package:compound_me/features/habits/domain/streak_calculator.dart';
import 'package:compound_me/features/insights/domain/insights_calculator.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:meta/meta.dart';

/// The one insight card on Home (S-10).
@immutable
sealed class HomeInsight {
  const HomeInsight();
}

/// A reduce habit that already cost [spent] this month.
class ReduceCostInsight extends HomeInsight {
  const ReduceCostInsight({required this.habit, required this.spent});

  final Habit habit;
  final Money spent;
}

/// A build habit with a running streak of [length] [unit]s.
class StreakInsight extends HomeInsight {
  const StreakInsight({
    required this.habit,
    required this.length,
    required this.unit,
  });

  final Habit habit;
  final int length;
  final StreakUnit unit;
}

/// Spending is [percent] % above the same stretch of last month.
class SpendingUpInsight extends HomeInsight {
  const SpendingUpInsight({required this.percent});

  final int percent;
}

/// Picks the Home insight by the priority in 03 S-10.
abstract final class HomeInsightPicker {
  /// A build streak counts from one week (7 days) on.
  static const minStreakDays = 7;

  /// Spending must grow by more than this to be worth a card.
  static const spendingGrowthPercent = 20;

  /// (1) the reduce habit with the biggest cost this month, (2) the longest
  /// build streak of at least a week, (3) spending up more than 20 % on the
  /// same days of last month. Nothing before [InsightsCalculator.minDays]
  /// days of data.
  static HomeInsight? pick({
    required List<HabitProgress> progress,
    required Iterable<TransactionListItem> thisMonth,
    required Iterable<TransactionListItem> lastMonth,
    required LocalDate today,
    required int recordedDays,
  }) {
    if (recordedDays < InsightsCalculator.minDays) return null;

    final spentBy = <String, Money>{};
    for (final item in thisMonth) {
      final habitId = item.habitId;
      if (habitId == null || item.entry.kind != TransactionKind.expense) {
        continue;
      }
      spentBy.update(
        habitId,
        (v) => v + item.entry.amount,
        ifAbsent: () => item.entry.amount,
      );
    }
    HomeInsight? costliest;
    var top = 0;
    for (final p in progress) {
      final spent = spentBy[p.habit.id] ?? 0;
      if (p.habit.kind == HabitKind.reduce && spent > top) {
        top = spent;
        costliest = ReduceCostInsight(habit: p.habit, spent: spent);
      }
    }
    if (costliest != null) return costliest;

    HomeInsight? longest;
    var longestDays = minStreakDays - 1;
    for (final p in progress) {
      final streak = p.streak;
      if (p.habit.kind != HabitKind.build ||
          p.habit.isArchived ||
          streak == null) {
        continue;
      }
      final days = streak.unit == StreakUnit.days
          ? streak.current
          : streak.current * 7;
      if (days > longestDays) {
        longestDays = days;
        longest = StreakInsight(
          habit: p.habit,
          length: streak.current,
          unit: streak.unit,
        );
      }
    }
    if (longest != null) return longest;

    final change = InsightsCalculator.percentChange(
      before: _expenseUpTo(lastMonth, today.day),
      now: _expenseUpTo(thisMonth, today.day),
    );
    if (change != null && change > spendingGrowthPercent) {
      return SpendingUpInsight(percent: change.round());
    }
    return null;
  }

  /// Expenses on days 1..[day] of the month the items belong to.
  static Money _expenseUpTo(Iterable<TransactionListItem> items, int day) {
    var sum = 0;
    for (final item in items) {
      final e = item.entry;
      if (e.kind != TransactionKind.expense || e.isDeleted) continue;
      if (LocalDate.fromDateTime(e.occurredAt).day <= day) sum += e.amount;
    }
    return sum;
  }
}
