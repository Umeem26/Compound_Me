import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/insights/domain/insights_calculator.dart';
import 'package:compound_me/features/insights/domain/month_insights.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = LocalDate(2026, 9, 25);
final _month = YearMonth(2026, 9);
final _stamp = DateTime.utc(2026, 9, 20, 3);

Category _category(String id, String nameKey, {String color = 'coral'}) =>
    Category(
      id: id,
      kind: CategoryKind.expense,
      nameKey: nameKey,
      iconKey: 'forkKnife',
      colorKey: color,
      sortOrder: 0,
      createdAt: _stamp,
      updatedAt: _stamp,
    );

final Category _food = _category('food', 'catFood');
final Category _transport = _category(
  'transport',
  'catTransport',
  color: 'blue',
);

TransactionListItem _item(
  int amount,
  Category category, {
  String? habitId,
  String? logId,
  TransactionKind kind = TransactionKind.expense,
}) => TransactionListItem(
  entry: TransactionEntry(
    id: 't$amount${logId ?? ''}',
    kind: kind,
    amount: amount,
    walletId: 'w',
    categoryId: category.id,
    occurredAt: _stamp,
    createdAt: _stamp,
    updatedAt: _stamp,
    habitLogId: logId,
  ),
  category: category,
  walletName: 'Tunai',
  habitId: habitId,
  habitName: habitId == null ? null : 'Kopi',
);

Habit _coffee({bool archived = false}) => Habit(
  id: 'kopi',
  name: 'Kopi',
  kind: HabitKind.reduce,
  iconKey: 'coffee',
  colorKey: 'coral',
  scheduleType: ScheduleType.daily,
  costPerOccurrence: 25000,
  walletId: 'w',
  categoryId: 'food',
  createdAt: DateTime(2026, 7, 1, 12),
  archivedAt: archived ? DateTime(2026, 9, 10) : null,
);

Habit _reading({DateTime? createdAt}) => Habit(
  id: 'baca',
  name: 'Baca',
  kind: HabitKind.build,
  iconKey: 'bookOpen',
  colorKey: 'blue',
  scheduleType: ScheduleType.daily,
  createdAt: createdAt ?? DateTime(2026, 7, 1, 12),
);

List<HabitLog> _logs(String habit, Iterable<String> dates) => [
  for (final d in dates)
    HabitLog(habitId: habit, date: LocalDate.parse(d), count: 1),
];

String _iso(int month, int day) => LocalDate(2026, month, day).toIso();

void main() {
  group('MonthInsightsBuilder', () {
    final coffee = _coffee();
    // 2 coffees (50.000) out of 225.000 spent: just over a fifth.
    final items = [
      _item(25000, _food, habitId: 'kopi', logId: 'l1'),
      _item(25000, _food, habitId: 'kopi', logId: 'l2'),
      _item(125000, _food),
      _item(50000, _transport),
      _item(500000, _food, kind: TransactionKind.income),
    ];
    // 12 coffees in the last 28 days (Mon, Wed, Fri): 3 a week.
    final coffeeLogs = _logs('kopi', [
      for (var i = 0; i < 28; i += 1)
        if (const {1, 3, 5}.contains(_today.addDays(-i).weekday))
          _today.addDays(-i).toIso(),
    ]);

    test('splits the month into reduce share, habits and categories', () {
      final result = MonthInsightsBuilder.build(
        month: _month,
        today: _today,
        habits: [coffee],
        logs: coffeeLogs,
        items: items,
      );

      expect(result.totalExpense, 225000);
      expect(result.reduceShare.reduceAmount, 50000);
      expect(result.reduceShare.share, closeTo(50000 / 225000, 1e-9));
      final kopi = result.reduce.single;
      expect(kopi.spent, 50000);
      expect(kopi.perWeek, 3);
      expect(kopi.annualProjection, 3 * 52 * 25000);
      expect(result.categories.map((c) => c.category.id), [
        'food',
        'transport',
      ]);
      expect(result.categories.first.amount, 175000);
      expect(result.categories.first.share, closeTo(175000 / 225000, 1e-9));
    });

    test('an archived reduce habit shows only while it cost something', () {
      final archived = _coffee(archived: true);

      final spent = MonthInsightsBuilder.build(
        month: _month,
        today: _today,
        habits: [archived],
        logs: coffeeLogs,
        items: items,
      );
      final quiet = MonthInsightsBuilder.build(
        month: _month,
        today: _today,
        habits: [archived],
        logs: coffeeLogs,
        items: const [],
      );

      expect(spent.reduce, hasLength(1));
      expect(quiet.reduce, isEmpty);
    });

    test('a month without spending has no share and no slices', () {
      final result = MonthInsightsBuilder.build(
        month: _month,
        today: _today,
        habits: [coffee],
        logs: const [],
        items: const [],
      );

      expect(result.totalExpense, 0);
      expect(result.reduceShare.share, isNull);
      expect(result.categories, isEmpty);
      expect(result.reduce.single.annualProjection, 0);
    });

    test('build habits get consistency and the trend against last month', () {
      // Read on all 25 September days so far, 15 of the 31 in August.
      final logs = _logs('baca', [
        for (var d = 1; d <= 25; d++) _iso(9, d),
        for (var d = 1; d <= 15; d++) _iso(8, d),
      ]);

      final result = MonthInsightsBuilder.build(
        month: _month,
        today: _today,
        habits: [_reading()],
        logs: logs,
        items: const [],
      );

      final reading = result.build.single;
      expect(reading.consistency, closeTo(1, 1e-9));
      // 100 % against 15 of 31 days (48,4 %): up 52 points.
      expect(reading.trendPoints, 52);
    });

    test('a habit with nothing scheduled in the month is left out', () {
      final result = MonthInsightsBuilder.build(
        month: _month,
        today: _today,
        habits: [_reading(createdAt: DateTime(2026, 10, 3, 12))],
        logs: const [],
        items: const [],
      );

      expect(result.build, isEmpty);
    });
  });

  group('recordedDays', () {
    test('counts from the first record to today, both included', () {
      expect(
        InsightsCalculator.recordedDays(
          firstRecord: LocalDate(2026, 9, 23),
          today: _today,
        ),
        3,
      );
      expect(
        InsightsCalculator.recordedDays(firstRecord: _today, today: _today),
        1,
      );
    });

    test('is 0 without any record', () {
      expect(
        InsightsCalculator.recordedDays(firstRecord: null, today: _today),
        0,
      );
    });
  });

  test('percentChange is null without a base to compare with', () {
    expect(InsightsCalculator.percentChange(before: 0, now: 100), isNull);
    expect(
      InsightsCalculator.percentChange(before: 200, now: 250),
      closeTo(25, 1e-9),
    );
  });
}
