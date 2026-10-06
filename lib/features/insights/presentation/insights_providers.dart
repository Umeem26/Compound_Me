import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/presentation/habit_providers.dart';
import 'package:compound_me/features/insights/domain/home_insight.dart';
import 'package:compound_me/features/insights/domain/insights_calculator.dart';
import 'package:compound_me/features/insights/domain/month_insights.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/presentation/transaction_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insights_providers.g.dart';

TransactionFilter _monthFilter(YearMonth month) =>
    TransactionFilter(year: month.year, month: month.month);

@riverpod
Stream<DateTime?> firstTransactionAt(Ref ref) =>
    ref.watch(transactionRepositoryProvider).watchFirstOccurredAt();

/// Days since the first transaction or check-in, today included (0 without
/// any). S-30 and the Home insight wait for seven.
@riverpod
AsyncValue<int> recordedDays(Ref ref) {
  final first = ref.watch(firstTransactionAtProvider);
  final logs = ref.watch(allHabitLogsProvider);
  final today = LocalDate.fromDateTime(ref.watch(nowProvider));
  if (first case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  if (logs case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  if (first case AsyncData(value: final at)) {
    if (logs case AsyncData(value: final all)) {
      var start = at == null ? null : LocalDate.fromDateTime(at);
      // Logs come oldest first.
      if (all.isNotEmpty && (start == null || all.first.date.isBefore(start))) {
        start = all.first.date;
      }
      return AsyncData(
        InsightsCalculator.recordedDays(firstRecord: start, today: today),
      );
    }
  }
  return const AsyncLoading();
}

/// The numbers of S-30 for one month.
@riverpod
AsyncValue<MonthInsights> monthInsights(Ref ref, YearMonth month) {
  final habits = ref.watch(habitListProvider(includeArchived: true));
  final logs = ref.watch(allHabitLogsProvider);
  final items = ref.watch(
    transactionHistoryProvider(_monthFilter(month), null),
  );
  final today = LocalDate.fromDateTime(ref.watch(nowProvider));
  for (final value in [habits, logs, items]) {
    if (value case AsyncError(:final error, :final stackTrace)) {
      return AsyncError(error, stackTrace);
    }
  }
  if (habits case AsyncData(value: final h)) {
    if (logs case AsyncData(value: final l)) {
      if (items case AsyncData(value: final i)) {
        return AsyncData(
          MonthInsightsBuilder.build(
            month: month,
            today: today,
            habits: h,
            logs: l,
            items: i,
          ),
        );
      }
    }
  }
  return const AsyncLoading();
}

/// The single insight card of Home (S-10), or null when nothing applies.
@riverpod
AsyncValue<HomeInsight?> homeInsight(Ref ref) {
  final now = ref.watch(nowProvider);
  final today = LocalDate.fromDateTime(now);
  final month = YearMonth.of(now);
  final progress = ref.watch(habitProgressProvider);
  final days = ref.watch(recordedDaysProvider);
  final thisMonth = ref.watch(
    transactionHistoryProvider(_monthFilter(month), null),
  );
  final lastMonth = ref.watch(
    transactionHistoryProvider(_monthFilter(month.addMonths(-1)), null),
  );
  for (final value in [progress, days, thisMonth, lastMonth]) {
    if (value case AsyncError(:final error, :final stackTrace)) {
      return AsyncError(error, stackTrace);
    }
  }
  if (progress case AsyncData(value: final p)) {
    if (days case AsyncData(value: final d)) {
      if (thisMonth case AsyncData(value: final a)) {
        if (lastMonth case AsyncData(value: final b)) {
          return AsyncData(
            HomeInsightPicker.pick(
              progress: p,
              thisMonth: a,
              lastMonth: b,
              today: today,
              recordedDays: d,
            ),
          );
        }
      }
    }
  }
  return const AsyncLoading();
}
