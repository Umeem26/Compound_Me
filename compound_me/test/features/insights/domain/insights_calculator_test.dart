import 'package:compound_me/features/insights/domain/insights_calculator.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../habits/domain/habit_fixtures.dart';

final _at = DateTime.utc(2026, 9, 20, 3);

TransactionEntry _tx(
  int amount, {
  TransactionKind kind = TransactionKind.expense,
  String? habitLogId,
  bool deleted = false,
}) => TransactionEntry(
  id: 't$amount',
  kind: kind,
  amount: amount,
  walletId: 'w',
  categoryId: 'c',
  occurredAt: _at,
  createdAt: _at,
  updatedAt: _at,
  habitLogId: habitLogId,
  deletedAt: deleted ? _at : null,
);

void main() {
  group('reduceShare', () {
    test('divides reduce-habit spending by all spending', () {
      final share = InsightsCalculator.reduceShare(
        transactions: [
          _tx(25000, habitLogId: 'kopi-1'),
          _tx(25000, habitLogId: 'kopi-2'),
          _tx(15000, habitLogId: 'build-log'),
          _tx(185000),
          _tx(500000, kind: TransactionKind.income),
          _tx(90000, habitLogId: 'kopi-3', deleted: true),
        ],
        reduceHabitLogIds: {'kopi-1', 'kopi-2', 'kopi-3'},
      );

      expect(share.reduceAmount, 50000);
      expect(share.totalExpense, 250000);
      expect(share.share, closeTo(0.2, 1e-9));
    });

    test('a period without data has no share instead of dividing by zero', () {
      final empty = InsightsCalculator.reduceShare(
        transactions: const [],
        reduceHabitLogIds: const {},
      );
      final onlyIncome = InsightsCalculator.reduceShare(
        transactions: [_tx(500000, kind: TransactionKind.income)],
        reduceHabitLogIds: const {},
      );

      expect(empty.share, isNull);
      expect(onlyIncome.share, isNull);
      expect(empty.reduceAmount, 0);
    });
  });

  group('frequency and projection', () {
    final today = day('2026-09-27');

    test('average per week is the last 28 days divided by 4', () {
      final logs = [
        ...logsOn(['2026-08-31'], count: 5), // day 28: inside
        ...logsOn(['2026-08-30'], count: 9), // day 29: outside
        ...logsOn(['2026-09-10', '2026-09-20'], count: 2),
        ...logsOn(['2026-09-27'], count: 3),
      ];

      expect(
        InsightsCalculator.averagePerWeek(logs: logs, today: today),
        (5 + 2 + 2 + 3) / 4,
      );
      expect(
        InsightsCalculator.averagePerWeek(logs: const [], today: today),
        0,
      );
    });

    test('annual projection and savings follow 05 §4.4', () {
      // Coffee 3x a week at Rp 25.000 (checklist in 06: ±Rp 1,95 jt at 50%).
      final annual = InsightsCalculator.annualProjection(
        perWeek: 3,
        costPerOccurrence: 25000,
      );

      expect(annual, 3900000);
      expect(
        InsightsCalculator.annualSavings(
          annualProjection: annual,
          reduction: 0.5,
        ),
        1950000,
      );
      expect(
        InsightsCalculator.annualSavings(
          annualProjection: annual,
          reduction: 0,
        ),
        0,
      );
    });
  });

  group('build trend', () {
    test('is the difference in percentage points', () {
      expect(
        InsightsCalculator.consistencyTrend(thisMonth: 0.83, lastMonth: 0.71),
        closeTo(12, 1e-9),
      );
      expect(
        InsightsCalculator.consistencyTrend(thisMonth: 0.61, lastMonth: 0.66),
        closeTo(-5, 1e-9),
      );
      expect(
        InsightsCalculator.consistencyTrend(thisMonth: 0.5, lastMonth: null),
        isNull,
      );
    });

    test('monthly consistency only counts the given month', () {
      final habit = habitFixture(start: day('2026-08-01'));
      final logs = logsOn([
        ...daysBetween('2026-08-01', '2026-08-31'),
        ...daysBetween('2026-09-01', '2026-09-13'),
      ]);
      final today = day('2026-09-27');

      final august = InsightsCalculator.monthlyConsistency(
        habit: habit,
        logs: logs,
        year: 2026,
        month: 8,
        today: today,
      );
      final september = InsightsCalculator.monthlyConsistency(
        habit: habit,
        logs: logs,
        year: 2026,
        month: 9,
        today: today,
      );

      expect(august, 1);
      // 13 of 26 closed days (09-01 .. 09-26); unchecked today is ignored.
      expect(september, closeTo(13 / 26, 1e-9));
      expect(
        InsightsCalculator.consistencyTrend(
          thisMonth: september,
          lastMonth: august,
        ),
        closeTo(-50, 1e-9),
      );
    });
  });
}
