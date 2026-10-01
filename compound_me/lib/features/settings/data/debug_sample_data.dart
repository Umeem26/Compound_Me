import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/clock.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debug_sample_data.g.dart';

/// Debug tool (06 §2 phase 5): fills the app with 60 days of habits,
/// check-ins and transactions so Insights has something to show. Only the
/// debug-only row in Settings reaches it (`kDebugMode`), so release builds
/// drop the code. Everything is a pure function of "today": no randomness,
/// so screenshots and the phase 5 checklist are reproducible.
class DebugSampleData {
  DebugSampleData(this._db, {this._clock = systemClock});

  final AppDatabase _db;
  final Clock _clock;

  static const days = 60;

  /// Coffee: 3 times a week at this price, the numbers of the simulator
  /// checklist (50 % of it saves Rp 1.950.000 a year).
  static const coffeeName = 'Kopi';
  static const coffeeCost = 25000;
  static const _snackName = 'Jajan malam';
  static const _snackCost = 30000;

  /// Adds the sample data. Returns false, changing nothing, when it is
  /// already there.
  Future<bool> fill() async {
    final now = _clock();
    final today = LocalDate.fromDateTime(now);
    final first = today.addDays(1 - days);

    final createHabits = DriftHabitRepository(
      _db,
      clock: () => first.atLocalHour(7),
    );
    final existing = await (_db.select(
      _db.habits,
    )..where((h) => h.name.equals(coffeeName))).get();
    if (existing.isNotEmpty) return false;

    final wallet = (await DriftWalletRepository(_db).listActive()).first;
    final expenseCategories = await DriftCategoryRepository(_db)
        .listActive(CategoryKind.expense);
    final incomeCategories = await DriftCategoryRepository(_db)
        .listActive(CategoryKind.income);
    String expense(String nameKey) =>
        expenseCategories.firstWhere((c) => c.nameKey == nameKey).id;
    final food = expense('catFood');

    final coffee = await createHabits.create(
      HabitDraft(
        name: coffeeName,
        kind: HabitKind.reduce,
        iconKey: 'coffee',
        colorKey: 'coral',
        scheduleType: ScheduleType.daily,
        costPerOccurrence: coffeeCost,
        walletId: wallet.id,
        categoryId: food,
      ),
    );
    final snack = await createHabits.create(
      HabitDraft(
        name: _snackName,
        kind: HabitKind.reduce,
        iconKey: 'cookie',
        colorKey: 'violet',
        scheduleType: ScheduleType.daily,
        costPerOccurrence: _snackCost,
        walletId: wallet.id,
        categoryId: food,
      ),
    );
    final workout = await createHabits.create(
      const HabitDraft(
        name: 'Olahraga',
        kind: HabitKind.build,
        iconKey: 'barbell',
        colorKey: 'green',
        scheduleType: ScheduleType.timesPerWeek,
        timesPerWeek: 3,
      ),
    );
    final reading = await createHabits.create(
      const HabitDraft(
        name: 'Baca',
        kind: HabitKind.build,
        iconKey: 'bookOpen',
        colorKey: 'blue',
        scheduleType: ScheduleType.daily,
      ),
    );

    for (var ago = days - 1; ago >= 0; ago--) {
      final day = today.addDays(-ago);
      // Each day is written as if it were that day, so nothing looks like
      // a future date to the repositories.
      final at = ago == 0 ? now : day.atLocalHour(21);
      final habits = DriftHabitRepository(_db, clock: () => at);
      final transactions = DriftTransactionRepository(_db, clock: () => at);

      // Coffee on Monday, Wednesday and Friday: exactly 3 a week.
      if (const {1, 3, 5}.contains(day.weekday)) {
        await habits.toggleCheckIn(coffee, day);
      }
      // Late-night snacks on Tuesday and Saturday, and a third time every
      // fifth week.
      if (const {2, 6}.contains(day.weekday) || (ago % 35 == 3)) {
        await habits.toggleCheckIn(snack, day);
      }
      // The last 30 days are better for workouts, worse for reading.
      final recent = ago < 30;
      if (const {1, 3, 6}.contains(day.weekday) &&
          _roll(ago, 3) < (recent ? 90 : 70)) {
        await habits.toggleCheckIn(workout, day);
      }
      if (_roll(ago, 7) < (recent ? 62 : 82)) {
        await habits.toggleCheckIn(reading, day);
      }

      Future<void> add(
        TransactionKind kind,
        int amount,
        String categoryId,
        int hour, {
        String? note,
      }) async {
        var occurredAt = day.atLocalHour(hour);
        if (occurredAt.isAfter(now)) {
          occurredAt = now.subtract(const Duration(minutes: 5));
        }
        await transactions.add(
          TransactionDraft(
            kind: kind,
            amount: amount,
            walletId: wallet.id,
            categoryId: categoryId,
            occurredAt: occurredAt.toUtc(),
            note: note,
          ),
        );
      }

      if (day.day == 1) {
        await add(
          TransactionKind.income,
          3500000,
          incomeCategories.firstWhere((c) => c.nameKey == 'catAllowance').id,
          9,
        );
      }
      if (day.day == 15) {
        await add(
          TransactionKind.income,
          750000,
          incomeCategories.firstWhere((c) => c.nameKey == 'catFreelance').id,
          14,
        );
      }
      if (day.day == 5) {
        await add(
          TransactionKind.expense,
          350000,
          expense('catBills'),
          10,
          note: 'Internet',
        );
      }
      if (day.weekday <= 5 && _roll(ago, 11) < 70) {
        await add(
          TransactionKind.expense,
          15000 + _roll(ago, 13) ~/ 10 * 1000,
          expense('catTransport'),
          8,
        );
      }
      if (_roll(ago, 17) < 65) {
        await add(
          TransactionKind.expense,
          20000 + _roll(ago, 19) ~/ 5 * 1000,
          food,
          12,
        );
      }
      if (ago % 9 == 4) {
        await add(
          TransactionKind.expense,
          120000 + _roll(ago, 23) * 1500,
          expense('catShopping'),
          16,
        );
      }
      if (ago % 13 == 6) {
        await add(
          TransactionKind.expense,
          60000 + _roll(ago, 29) * 900,
          expense('catEntertainment'),
          19,
        );
      }
      if (ago == 20) {
        await add(TransactionKind.expense, 85000, expense('catHealth'), 11);
      }
    }
    return true;
  }

  /// A repeatable 0–99 for a day, different per [salt].
  static int _roll(int ago, int salt) => (ago * 37 + salt * 53 + 11) % 100;
}

@Riverpod(keepAlive: true)
DebugSampleData debugSampleData(Ref ref) =>
    DebugSampleData(ref.watch(appDatabaseProvider));
