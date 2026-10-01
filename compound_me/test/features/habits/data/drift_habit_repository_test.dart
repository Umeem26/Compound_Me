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

    test('deleting the only check-in expense and restoring it brings back '
        'the same check-in', () async {
      final id = await habits.create(coffee());
      await habits.toggleCheckIn(id, today);
      final log = (await habits.watchLogs(id).first).single;
      final expense = (await activeCheckInExpenses()).single;

      await transactions.softDelete(expense.id);
      expect(await habits.watchLogs(id).first, isEmpty);
      expect(await habits.watchLogsOn(today).first, isEmpty);
      expect(await balance(), 100000);

      await transactions.restore(expense.id);
      final restored = (await habits.watchLogs(id).first).single;
      expect(restored.id, log.id);
      expect(restored.count, 1);
      expect((await habits.watchLogsOn(today).first).single.id, log.id);
      expect((await transactions.findById(expense.id))!.habitLogId, log.id);
      expect(await balance(), 75000);
    });

    test('restoring an expense may pass the daily input limit', () async {
      final id = await habits.create(coffee());
      const max = HabitRepository.maxDailyCount;
      await habits.setCount(id, today, max);
      final deleted = (await activeCheckInExpenses()).first;
      await transactions.softDelete(deleted.id);
      await habits.setCount(id, today, max);

      await transactions.restore(deleted.id);
      expect(await logCount(id), max + 1);
      expect(await activeCheckInExpenses(), hasLength(max + 1));
      await expectLater(
        habits.setCount(id, today, max + 1),
        _rejects(ValidationError.countOutOfRange),
        reason: 'the limit still applies to input',
      );
    });

    test('an undone check-in is kept as a deleted row and reused', () async {
      final id = await habits.create(coffee());
      await habits.toggleCheckIn(id, today);
      final log = (await habits.watchLogs(id).first).single;

      await habits.toggleCheckIn(id, today);
      final stored = await db.select(db.habitLogs).get();
      expect(stored.single.id, log.id);
      expect(stored.single.deletedAt, isNotNull);
      expect(await habits.watchLogs(id).first, isEmpty);

      expect(await habits.toggleCheckIn(id, today), 1);
      final reused = await db.select(db.habitLogs).get();
      expect(reused.single.id, log.id);
      expect(reused.single.deletedAt, isNull);
      expect(await balance(), 75000);
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

    test('an undone check-in does not block deleting the habit', () async {
      final id = await habits.create(reading);
      await habits.toggleCheckIn(id, today);
      await habits.toggleCheckIn(id, today);

      await habits.delete(id);
      expect(await habits.findById(id), isNull);
      expect(await db.select(db.habitLogs).get(), isEmpty);
    });

    test('switching kind after an undo drops the undone check-in', () async {
      final id = await habits.create(coffee());
      await habits.toggleCheckIn(id, today);
      final expense = (await activeCheckInExpenses()).single;
      await habits.toggleCheckIn(id, today);

      await habits.update(id, reading);
      expect(await db.select(db.habitLogs).get(), isEmpty);

      await transactions.restore(expense.id);
      expect(
        (await transactions.findById(expense.id))!.habitLogId,
        isNull,
        reason: 'a build habit has no expenses, so it returns as a plain one',
      );
      expect(await habits.watchLogs(id).first, isEmpty);
      expect(await balance(), 75000);
    });

    test('purge removes check-ins undone over 30 days ago', () async {
      clock.now = DateTime(2026, 8, 1, 9);
      final old = await habits.create(coffee());
      await habits.toggleCheckIn(old, LocalDate(2026, 8, 1));
      await habits.toggleCheckIn(old, LocalDate(2026, 8, 1));
      clock.now = DateTime(2026, 9, 20, 9);
      final recent = await habits.create(reading);
      await habits.toggleCheckIn(recent, LocalDate(2026, 9, 20));
      await habits.toggleCheckIn(recent, LocalDate(2026, 9, 20));
      clock.now = DateTime(2026, 9, 27, 9);

      expect(await transactions.purgeDeleted(), 1, reason: 'the old expense');
      final left = await db.select(db.habitLogs).get();
      expect(left.map((l) => l.habitId), [recent]);
      expect(await db.select(db.transactions).get(), isEmpty);
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

  group('phase 4 queries', () {
    test(
      'all logs of every habit, oldest first, without undone ones',
      () async {
        final a = await habits.create(reading);
        final b = await habits.create(coffee());
        await habits.setCount(a, today, 1);
        await habits.setCount(b, today.addDays(-1), 2);
        await habits.setCount(b, today, 1);
        await habits.setCount(b, today, 0);

        final logs = await habits.watchAllLogs().first;
        expect(
          [for (final l in logs) (l.habitId, l.date, l.count)],
          [(b, today.addDays(-1), 2), (a, today, 1)],
        );
      },
    );

    test('check-ins decide whether the kind can change', () async {
      final id = await habits.create(reading);
      expect(await habits.hasCheckIns(id), isFalse);
      await habits.setCount(id, today, 1);
      expect(await habits.hasCheckIns(id), isTrue);
      await habits.setCount(id, today, 0);
      expect(await habits.hasCheckIns(id), isFalse, reason: 'undone');
    });

    test('check-ins come newest first with what they cost', () async {
      final id = await habits.create(coffee());
      await habits.setCount(id, today.addDays(-2), 1);
      await habits.setCount(id, today, 2);
      final expenses = await activeCheckInExpenses();
      await transactions.softDelete(expenses.first.id);

      final checkIns = await habits.watchCheckIns(id).first;
      expect(
        [for (final c in checkIns) (c.date, c.count, c.spent)],
        [(today, 1, 25000), (today.addDays(-2), 1, 25000)],
      );
      expect(await habits.watchCheckIns(id, limit: 1).first, hasLength(1));
    });

    test('money spent through a habit within dates', () async {
      final id = await habits.create(coffee());
      await habits.setCount(id, LocalDate(2026, 8, 31), 1);
      await habits.setCount(id, LocalDate(2026, 9, 2), 2);
      await habits.setCount(id, today, 1);

      final spent = await habits
          .watchSpent(id, from: LocalDate(2026, 9, 1), to: today)
          .first;
      expect(spent, 75000);
      expect(
        await habits
            .watchSpent(
              id,
              from: LocalDate(2026, 1, 1),
              to: LocalDate(2026, 1, 2),
            )
            .first,
        0,
      );
    });

    test('undo puts a deleted habit back as it was', () async {
      final id = await habits.create(coffee());
      final before = (await habits.findById(id))!;
      await habits.delete(id);
      await habits.undoDelete(before);

      final after = (await habits.findById(id))!;
      expect(after.name, before.name);
      expect(after.costPerOccurrence, 25000);
      expect(after.weeklyLimit, 3);
      expect(after.createdAt, before.createdAt);
    });
  });
}
