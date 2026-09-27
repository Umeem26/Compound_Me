import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/settings/data/drift_data_reset.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;

  setUp(() {
    db = openTestDatabase();
    clock = FakeClock(DateTime(2026, 9, 27, 9));
  });

  test('leaves only the default categories behind', () async {
    final wallet = await seedWallet(db);
    final food = await defaultCategoryId(db, 'catFood');
    final custom = await DriftCategoryRepository(db).create(
      const CategoryDraft(
        kind: CategoryKind.expense,
        name: 'Kopi',
        iconKey: 'coffee',
        colorKey: 'coral',
      ),
    );
    await DriftTransactionRepository(db, clock: clock.call).add(
      TransactionDraft(
        kind: TransactionKind.expense,
        amount: 20000,
        walletId: wallet,
        categoryId: custom,
        occurredAt: DateTime(2026, 9, 26, 12),
      ),
    );
    final habits = DriftHabitRepository(db, clock: clock.call);
    final coffee = await habits.create(
      HabitDraft(
        name: 'Kopi',
        kind: HabitKind.reduce,
        iconKey: 'coffee',
        colorKey: 'coral',
        scheduleType: ScheduleType.daily,
        costPerOccurrence: 25000,
        walletId: wallet,
        categoryId: food,
      ),
    );
    await habits.toggleCheckIn(coffee, LocalDate(2026, 9, 27));

    await DriftDataReset(db, clock: clock.call).deleteEverything();

    expect(await db.select(db.wallets).get(), isEmpty);
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(await db.select(db.habits).get(), isEmpty);
    expect(await db.select(db.habitLogs).get(), isEmpty);
    final categories = await db.select(db.categories).get();
    expect(categories, hasLength(12));
    expect(categories.every((c) => c.customName == null), isTrue);
  });
}
