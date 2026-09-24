// Unit test untuk logika inti CompoundMe: transaksi & saldo dompet,
// serta toggle checklist habit berbiaya.
//
// Memakai ProviderContainer dengan appDatabaseProvider di-override ke
// AppDatabase in-memory (NativeDatabase.memory()) supaya tidak menyentuh
// file database asli dan tiap test berjalan dengan state bersih.

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/core/database/database_provider.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/habits/presentation/controllers/habit_controller.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  late int walletAId;
  late int walletBId;
  late int expenseCategoryId;
  late int incomeCategoryId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );

    walletAId = await db.into(db.wallets).insert(
          WalletsCompanion.insert(
            name: 'Cash',
            icon: 'assets/icons/wallet_default.png',
            color: 0xFF000000,
            balance: const Value(100000),
          ),
        );
    walletBId = await db.into(db.wallets).insert(
          WalletsCompanion.insert(
            name: 'Bank',
            icon: 'assets/icons/wallet_default.png',
            color: 0xFF000000,
            balance: const Value(50000),
          ),
        );

    // Kategori default sudah di-seed lewat MigrationStrategy.beforeOpen.
    final categories = await db.select(db.categories).get();
    expenseCategoryId = categories.firstWhere((c) => c.type == 0).id;
    incomeCategoryId = categories.firstWhere((c) => c.type == 1).id;
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<double> walletBalance(int id) async {
    final wallet = await (db.select(db.wallets)..where((w) => w.id.equals(id))).getSingle();
    return wallet.balance;
  }

  test('tambah pengeluaran mengurangi saldo', () async {
    await container.read(transactionListProvider.notifier).addTransaction(
          amount: 20000,
          note: 'Makan siang',
          date: DateTime.now(),
          categoryId: expenseCategoryId,
          walletId: walletAId,
        );

    expect(await walletBalance(walletAId), 80000);
  });

  test('tambah pemasukan menambah saldo', () async {
    await container.read(transactionListProvider.notifier).addTransaction(
          amount: 30000,
          note: 'Gaji',
          date: DateTime.now(),
          categoryId: incomeCategoryId,
          walletId: walletAId,
        );

    expect(await walletBalance(walletAId), 130000);
  });

  test('edit transaksi pindah dompet mengoreksi kedua dompet', () async {
    await container.read(transactionListProvider.notifier).addTransaction(
          amount: 20000,
          note: 'Makan siang',
          date: DateTime.now(),
          categoryId: expenseCategoryId,
          walletId: walletAId,
        );

    final trx = (await container.read(transactionListProvider.future)).first;

    await container.read(transactionListProvider.notifier).editTransaction(
          id: trx.id,
          newAmount: 20000,
          newNote: trx.note ?? '',
          newDate: trx.date,
          newCategoryId: expenseCategoryId,
          newWalletId: walletBId,
          oldAmount: trx.amount,
          oldWalletId: walletAId,
        );

    expect(await walletBalance(walletAId), 100000); // dikembalikan penuh
    expect(await walletBalance(walletBId), 30000); // 50000 - 20000
  });

  test('hapus transaksi mengembalikan saldo', () async {
    await container.read(transactionListProvider.notifier).addTransaction(
          amount: 20000,
          note: 'Makan siang',
          date: DateTime.now(),
          categoryId: expenseCategoryId,
          walletId: walletAId,
        );

    final trx = (await container.read(transactionListProvider.future)).first;

    await container.read(transactionListProvider.notifier).deleteTransaction(trx);

    expect(await walletBalance(walletAId), 100000);
  });

  test('centang habit berbiaya 2x di hari yang sama = toggle (saldo kembali ke awal, tidak terpotong dua kali)', () async {
    final initialTotal = (await walletBalance(walletAId)) + (await walletBalance(walletBId));

    final habitId = await db.into(db.habits).insert(
          HabitsCompanion.insert(
            name: 'Ngopi',
            costPerUnit: const Value(15000),
            color: 0xFF000000,
          ),
        );
    final habit = await (db.select(db.habits)..where((h) => h.id.equals(habitId))).getSingle();

    // Centang pertama kali: log dibuat, transaksi otomatis dibuat, saldo terpotong.
    await container.read(todayHabitLogsProvider.notifier).checkHabit(habit);

    final totalAfterFirstCheck = (await walletBalance(walletAId)) + (await walletBalance(walletBId));
    expect(totalAfterFirstCheck, initialTotal - 15000);
    expect(await db.select(db.habitLogs).get(), hasLength(1));
    expect(await db.select(db.transactions).get(), hasLength(1));

    // Centang lagi di hari yang sama (toggle uncheck): log & transaksi terhapus, saldo kembali.
    await container.read(todayHabitLogsProvider.notifier).checkHabit(habit);

    final totalAfterSecondCheck = (await walletBalance(walletAId)) + (await walletBalance(walletBId));
    expect(totalAfterSecondCheck, initialTotal);
    expect(await db.select(db.habitLogs).get(), isEmpty);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  test('dua checkHabit bersamaan (Future.wait) untuk habit yang sama tetap menghasilkan maksimal 1 log dan saldo terpotong sekali', () async {
    final initialTotal = (await walletBalance(walletAId)) + (await walletBalance(walletBId));

    final habitId = await db.into(db.habits).insert(
          HabitsCompanion.insert(
            name: 'Ngopi',
            costPerUnit: const Value(15000),
            color: 0xFF000000,
          ),
        );
    final habit = await (db.select(db.habits)..where((h) => h.id.equals(habitId))).getSingle();

    final notifier = container.read(todayHabitLogsProvider.notifier);

    // Dua panggilan checkHabit() untuk habit yang sama, "bersamaan" (tanpa
    // menunggu satu selesai sebelum memulai yang lain). Tanpa guard in-flight,
    // ini bisa memicu toggle dobel (log ganda / saldo terpotong dua kali atau
    // malah balik ke 0 kali kalau keduanya saling silang check-uncheck).
    await Future.wait([
      notifier.checkHabit(habit),
      notifier.checkHabit(habit),
    ]);

    final logsAfter = await db.select(db.habitLogs).get();
    expect(logsAfter.length, lessThanOrEqualTo(1));

    final transactionsAfter = await db.select(db.transactions).get();
    expect(transactionsAfter.length, logsAfter.length);

    final totalAfter = (await walletBalance(walletAId)) + (await walletBalance(walletBId));
    // Guard in-flight memastikan panggilan kedua di-skip selagi yang pertama
    // masih berjalan, jadi hasil akhirnya deterministik: tepat 1 log & saldo
    // terpotong tepat sekali (bukan 0 kali, bukan 2 kali).
    expect(logsAfter, hasLength(1));
    expect(totalAfter, initialTotal - 15000);
  });
}
