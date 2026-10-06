import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_progress.dart';
import 'package:compound_me/features/insights/domain/home_insight.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../habits/domain/habit_fixtures.dart';

final _today = LocalDate(2026, 9, 25);
final _stamp = DateTime.utc(2026, 9, 20, 3);
final _food = Category(
  id: 'food',
  kind: CategoryKind.expense,
  nameKey: 'catFood',
  iconKey: 'forkKnife',
  colorKey: 'coral',
  sortOrder: 0,
  createdAt: _stamp,
  updatedAt: _stamp,
);

TransactionListItem _spend(int amount, DateTime at, {String? habitId}) =>
    TransactionListItem(
      entry: TransactionEntry(
        id: 't$amount${at.microsecondsSinceEpoch}',
        kind: TransactionKind.expense,
        amount: amount,
        walletId: 'w',
        categoryId: 'food',
        occurredAt: at,
        createdAt: at,
        updatedAt: at,
        habitLogId: habitId == null ? null : 'log',
      ),
      category: _food,
      walletName: 'Tunai',
      habitId: habitId,
    );

HabitProgress _progress(Habit habit, List<HabitLog> logs) =>
    progressOf(habit, logs, _today);

void main() {
  final coffee = habitFixture(
    start: LocalDate(2026, 8, 1),
    kind: HabitKind.reduce,
  );
  final reading = habitFixture(start: LocalDate(2026, 8, 1));
  final readingLogs = logsOn(daysBetween('2026-09-10', '2026-09-24'));

  HomeInsight? pick({
    required List<HabitProgress> progress,
    List<TransactionListItem> thisMonth = const [],
    List<TransactionListItem> lastMonth = const [],
    int days = 30,
  }) => HomeInsightPicker.pick(
    progress: progress,
    thisMonth: thisMonth,
    lastMonth: lastMonth,
    today: _today,
    recordedDays: days,
  );

  test('nothing shows before a week of data', () {
    final result = pick(
      progress: [_progress(coffee, const [])],
      thisMonth: [_spend(25000, DateTime(2026, 9, 3, 9), habitId: 'h')],
      days: 6,
    );

    expect(result, isNull);
  });

  test('the reduce habit with the biggest cost comes first', () {
    final result = pick(
      progress: [_progress(coffee, const []), _progress(reading, readingLogs)],
      thisMonth: [
        _spend(25000, DateTime(2026, 9, 3, 9), habitId: 'h'),
        _spend(25000, DateTime(2026, 9, 5, 9), habitId: 'h'),
      ],
    );

    expect(result, isA<ReduceCostInsight>());
    expect((result! as ReduceCostInsight).spent, 50000);
  });

  test('without reduce cost, a build streak of a week or more', () {
    final result = pick(progress: [_progress(reading, readingLogs)]);

    expect(result, isA<StreakInsight>());
    expect((result! as StreakInsight).length, 15);
  });

  test('a streak under a week is not worth a card', () {
    final short = logsOn(daysBetween('2026-09-20', '2026-09-24'));

    expect(pick(progress: [_progress(reading, short)]), isNull);
  });

  test('spending up more than 20 % on the same days of last month', () {
    // Through the 25th: 130.000 now against 100.000 then, up 30 %. The 28th
    // of last month is past the 25th and does not count.
    final result = pick(
      progress: const [],
      thisMonth: [_spend(130000, DateTime(2026, 9, 10, 9))],
      lastMonth: [
        _spend(100000, DateTime(2026, 8, 10, 9)),
        _spend(500000, DateTime(2026, 8, 28, 9)),
      ],
    );

    expect(result, isA<SpendingUpInsight>());
    expect((result! as SpendingUpInsight).percent, 30);
  });

  test('exactly 20 % up is not enough, and no base means no card', () {
    expect(
      pick(
        progress: const [],
        thisMonth: [_spend(120000, DateTime(2026, 9, 10, 9))],
        lastMonth: [_spend(100000, DateTime(2026, 8, 10, 9))],
      ),
      isNull,
    );
    expect(
      pick(
        progress: const [],
        thisMonth: [_spend(120000, DateTime(2026, 9, 10, 9))],
      ),
      isNull,
    );
  });
}
