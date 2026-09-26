import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_repository.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

Matcher _rejects(ValidationError error) =>
    throwsA(isA<ValidationException>().having((e) => e.error, 'error', error));

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DriftHabitRepository habits;
  late DriftTransactionRepository transactions;
  late String wallet;
  late String food;
  final today = LocalDate(2026, 9, 27);

  setUp(() async {
    db = openTestDatabase();
    clock = FakeClock(DateTime(2026, 9, 27, 9, 30));
    habits = DriftHabitRepository(db, clock: clock.call);
    transactions = DriftTransactionRepository(db, clock: clock.call);
    wallet = await seedWallet(db);
    food = await defaultCategoryId(db, 'catFood');
  });

  HabitDraft coffee({
    int? cost = 25000,
    String? walletId,
    String? categoryId,
  }) => HabitDraft(
    name: 'Kopi',
    kind: HabitKind.reduce,
    iconKey: 'gift',
    colorKey: 'coral',
    scheduleType: ScheduleType.daily,
    costPerOccurrence: cost,
    walletId: walletId ?? wallet,
    categoryId: categoryId ?? food,
    weeklyLimit: 3,
  );

  const reading = HabitDraft(
    name: 'Baca 10 halaman',
    kind: HabitKind.build,
    iconKey: 'gift',
    colorKey: 'teal',
    scheduleType: ScheduleType.daily,
  );

  Future<int> balance() async => (await DriftWalletRepository(
    db,
  ).watchActiveWithBalance().first).single.balance;

  Future<List<TransactionEntry>> activeCheckInExpenses() async => [
    for (final t in await transactions.watchRecent(limit: 100).first)
      if (t.isFromHabit) t,
  ];

  Future<int> logCount(String habitId) async {
    final logs = await habits.watchLogs(habitId).first;
    return logs.isEmpty ? 0 : logs.single.count;
  }

  group('create and validate', () {
    test('rejects reduce habits without cost, wallet or expense '
        'category', () async {
      final salary = await defaultCategoryId(db, 'catAllowance');

      await expectLater(
        habits.create(coffee(cost: 0)),
        _rejects(ValidationError.reduceNeedsCost),
      );
      await expectLater(
        habits.create(coffee(walletId: 'missing')),
        _rejects(ValidationError.reduceNeedsWallet),
      );
      await expectLater(
        habits.create(coffee(categoryId: salary)),
        _rejects(ValidationError.reduceNeedsExpenseCategory),
      );
    });

    test('rejects empty names and invalid schedules', () async {
      await expectLater(
        habits.create(
          const HabitDraft(
            name: ' ',
            kind: HabitKind.build,
            iconKey: 'gift',
            colorKey: 'teal',
            scheduleType: ScheduleType.daily,
          ),
        ),
        _rejects(ValidationError.nameEmpty),
      );
      await expectLater(
        habits.create(
          const HabitDraft(
            name: 'Olahraga',
            kind: HabitKind.build,
            iconKey: 'gift',
            colorKey: 'teal',
            scheduleType: ScheduleType.weekdays,
          ),
        ),
        _rejects(ValidationError.scheduleNeedsDays),
      );
      await expectLater(
        habits.create(
          const HabitDraft(
            name: 'Olahraga',
            kind: HabitKind.build,
            iconKey: 'gift',
            colorKey: 'teal',
            scheduleType: ScheduleType.timesPerWeek,
            timesPerWeek: 8,
          ),
        ),
        _rejects(ValidationError.timesPerWeekOutOfRange),
      );
    });

    test('build habits drop reduce-only fields', () async {
      final id = await habits.create(
        HabitDraft(
          name: 'Bawa bekal',
          kind: HabitKind.build,
          iconKey: 'gift',
          colorKey: 'teal',
          scheduleType: ScheduleType.weekdays,
          scheduleDays: Weekdays.workdays,
          timesPerWeek: 3,
          costPerOccurrence: 10000,
          walletId: wallet,
        ),
      );
      final habit = (await habits.findById(id))!;

      expect(habit.costPerOccurrence, isNull);
      expect(habit.walletId, isNull);
      expect(habit.timesPerWeek, isNull, reason: 'not a times-per-week habit');
      expect(habit.scheduleDays, Weekdays.workdays);
      expect(habit.startDate, today);
    });
  });

  group('reduce check-ins', () {
    test('two check-ins then one fewer leaves one expense', () async {
      final id = await habits.create(coffee());

      expect(await habits.setCount(id, today, 2), 2);
      expect(await activeCheckInExpenses(), hasLength(2));
      expect(await balance(), 50000);

      expect(await habits.setCount(id, today, 1), 1);
      final remaining = await activeCheckInExpenses();
      expect(remaining, hasLength(1));
      expect(remaining.single.amount, 25000);
      expect(remaining.single.walletId, wallet, reason: 'habit wallet');
      expect(remaining.single.categoryId, food);
      expect(await logCount(id), 1);
      expect(await balance(), 75000);

      expect(await habits.setCount(id, today, 0), 0);
      expect(await activeCheckInExpenses(), isEmpty);
      expect(await habits.watchLogs(id).first, isEmpty);
      expect(await balance(), 100000);
    });

    test('toggle checks in once and a second tap undoes it', () async {
      final id = await habits.create(coffee());

      expect(await habits.toggleCheckIn(id, today), 1);
      expect(await balance(), 75000);
      expect(await habits.toggleCheckIn(id, today), 0);
      expect(await balance(), 100000);
    });

    test(
      'a double tap while the first is running only checks in once',
      () async {
        final id = await habits.create(coffee());

        final results = await Future.wait([
          habits.toggleCheckIn(id, today),
          habits.toggleCheckIn(id, today),
        ]);

        expect(results, [1, 1]);
        expect(await logCount(id), 1);
        expect(await activeCheckInExpenses(), hasLength(1));
        expect(await balance(), 75000);
      },
    );

    test('a failing write rolls back the log and every expense', () async {
      final id = await habits.create(coffee());
      await db.customStatement(
        'CREATE TRIGGER fail_second_expense BEFORE INSERT ON transactions '
        'WHEN (SELECT COUNT(*) FROM transactions) >= 1 '
        "BEGIN SELECT RAISE(ABORT, 'simulated failure'); END",
      );

      await expectLater(habits.setCount(id, today, 2), throwsA(anything));
      expect(await habits.watchLogs(id).first, isEmpty);
      expect(await activeCheckInExpenses(), isEmpty);
      expect(await balance(), 100000);
    });

    test('deleting a check-in expense removes that occurrence', () async {
      final id = await habits.create(coffee());
      await habits.setCount(id, today, 2);
      final expense = (await activeCheckInExpenses()).first;

      await transactions.softDelete(expense.id);
      expect(await logCount(id), 1);
      expect(await balance(), 75000);

      await transactions.restore(expense.id);
      expect(await logCount(id), 2);
      expect(await balance(), 50000);
    });

    test('backdated check-ins are placed at local noon of that day', () async {
      final id = await habits.create(coffee());
      final yesterday = today.addDays(-1);

      await habits.setCount(id, yesterday, 1);
      final expense = (await activeCheckInExpenses()).single;
      expect(expense.occurredAt, yesterday.atLocalHour(12).toUtc());
    });

    test('limits the count and refuses future days', () async {
      final coffeeId = await habits.create(coffee());
      final readingId = await habits.create(reading);

      await expectLater(
        habits.setCount(coffeeId, today, HabitRepository.maxDailyCount + 1),
        _rejects(ValidationError.countOutOfRange),
      );
      await expectLater(
        habits.setCount(readingId, today, 2),
        _rejects(ValidationError.countOutOfRange),
      );
      await expectLater(
        habits.toggleCheckIn(coffeeId, today.addDays(1)),
        _rejects(ValidationError.futureDate),
      );
    });
  });

  group('build check-ins and lifecycle', () {
    test('build habits toggle between 0 and 1 without transactions', () async {
      final id = await habits.create(reading);

      expect(await habits.toggleCheckIn(id, today), 1);
      expect((await habits.watchLogsOn(today).first).single.habitId, id);
      expect(await activeCheckInExpenses(), isEmpty);
      expect(await habits.toggleCheckIn(id, today), 0);
      expect(await habits.watchLogsOn(today).first, isEmpty);
    });

    test('habits with check-ins are archived, not deleted', () async {
      final id = await habits.create(reading);
      await habits.toggleCheckIn(id, today);

      await expectLater(
        habits.delete(id),
        throwsA(isA<HabitHasLogsException>()),
      );
      await expectLater(
        habits.update(id, coffee()),
        throwsA(isA<HabitHasLogsException>()),
        reason: 'switching build → reduce would orphan history',
      );
      await habits.archive(id);
      expect(await habits.watchHabits().first, isEmpty);
      expect(
        (await habits.watchHabits(includeArchived: true).first).single.id,
        id,
      );
    });

    test('a habit without check-ins can be deleted', () async {
      final id = await habits.create(reading);

      await habits.delete(id);
      expect(await habits.findById(id), isNull);
    });

    test('update, reorder and log ranges', () async {
      final a = await habits.create(reading);
      final b = await habits.create(coffee());
      await habits.update(
        a,
        const HabitDraft(
          name: 'Baca 20 halaman',
          kind: HabitKind.build,
          iconKey: 'gift',
          colorKey: 'teal',
          scheduleType: ScheduleType.daily,
        ),
      );
      await habits.reorder([b, a]);
      await habits.setCount(a, today.addDays(-2), 1);
      await habits.setCount(a, today, 1);

      final list = await habits.watchHabits().first;
      expect(list.map((h) => h.id), [b, a]);
      expect(list.last.name, 'Baca 20 halaman');
      expect(
        (await habits.watchLogs(a, from: today.addDays(-1), to: today).first)
            .map((l) => l.date),
        [today],
      );
    });
  });
}
