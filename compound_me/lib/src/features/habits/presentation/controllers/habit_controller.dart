import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/core/database/database_provider.dart';
import 'package:compound_me/src/features/habits/data/repositories/habit_repository_impl.dart';

// IMPORT PENTING UNTUK INTEGRASI
import 'package:compound_me/src/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';

part 'habit_controller.g.dart';

// 1. Provider: Mengambil Daftar Semua Kebiasaan
@riverpod
class HabitList extends _$HabitList {
  @override
  Future<List<Habit>> build() async {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getHabits();
  }

  Future<void> addHabit({
    required String name,
    required double cost,
    required int color,
  }) async {
    final repo = ref.read(habitRepositoryProvider);
    
    await repo.addHabit(HabitsCompanion.insert(
      name: name,
      costPerUnit: Value(cost),
      color: color,
      frequency: const Value(0),
    ));

    ref.invalidateSelf();
  }

  Future<void> deleteHabit(int id) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.deleteHabit(id);
    ref.invalidateSelf();
  }
}

// 2. Provider: Mengambil "Checklist" Hari Ini
@riverpod
class TodayHabitLogs extends _$TodayHabitLogs {
  // Guard in-flight per habit id: mencegah checkHabit() untuk habit yang sama
  // dieksekusi dobel kalau dipanggil lagi sebelum panggilan sebelumnya selesai
  // (misal tap ganda yang cepat, atau checkHabit terpanggil bersamaan).
  final Set<int> _inFlightHabitIds = {};

  @override
  Future<List<HabitLog>> build() async {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getHabitLogsByDate(DateTime.now());
  }

  // --- FUNGSI UTAMA: TOGGLE CHECKLIST HABIT + AUTO TRANSAKSI ---
  Future<void> checkHabit(Habit habit) async {
    if (_inFlightHabitIds.contains(habit.id)) return;
    _inFlightHabitIds.add(habit.id);

    try {
      final db = ref.read(appDatabaseProvider);
      final habitRepo = ref.read(habitRepositoryProvider);
      final today = DateTime.now();

      // Toleran terhadap lebih dari 1 baris log di hari yang sama (misal duplikat lama).
      final existingLogs = await habitRepo.getHabitLogsForHabitOnDate(habit.id, today);

      // Seluruh operasi (log habit + transaksi otomatis + update saldo, atau
      // sebaliknya saat uncheck) dibungkus SATU db.transaction() supaya atomik:
      // kalau salah satu langkah gagal, semuanya di-rollback bersama.
      // insertTransactionRaw/deleteTransactionRaw sengaja TIDAK membuka
      // transaction sendiri, supaya bisa "menumpang" di transaction ini.
      if (existingLogs.isEmpty) {
        // BELUM dicentang hari ini -> centang + buat transaksi otomatis (jika berbiaya)
        await db.transaction(() async {
          final logId = await habitRepo.logHabit(HabitLogsCompanion.insert(
            habitId: habit.id,
            completedAt: today,
          ));

          if (habit.costPerUnit > 0) {
            final financeRepo = ref.read(financeRepositoryProvider);

            // Cari Dompet & Kategori untuk dipotong
            // (Karena kita belum setting spesifik, kita ambil dompet pertama saja sebagai default)
            final wallets = await financeRepo.getWallets();
            final categories = await financeRepo.getCategories();

            if (wallets.isNotEmpty && categories.isNotEmpty) {
              // Ambil dompet pertama (Main Wallet)
              final targetWallet = wallets.first;

              // Cari kategori 'Jajan' atau 'Makanan', kalau gak ada ambil Expense pertama
              final targetCategory = categories.firstWhere(
                (c) => c.name.contains('Jajan') || c.name.contains('Makanan') || c.type == 0,
                orElse: () => categories.first,
              );

              // Eksekusi Pemotongan Saldo, ditautkan ke log ini lewat habitLogId
              // supaya bisa di-uncheck nanti.
              await ref.read(transactionListProvider.notifier).insertTransactionRaw(
                amount: habit.costPerUnit,
                note: "Auto-Habit: ${habit.name}", // Catatan otomatis
                date: today,
                categoryId: targetCategory.id,
                walletId: targetWallet.id,
                habitLogId: logId,
              );
            }
          }
        });
      } else {
        // SUDAH dicentang hari ini -> uncheck: hapus SEMUA log hari ini + transaksi otomatis terkait
        final financeRepo = ref.read(financeRepositoryProvider);

        await db.transaction(() async {
          for (final log in existingLogs) {
            if (habit.costPerUnit > 0) {
              final linkedTransaction = await financeRepo.getTransactionByHabitLogId(log.id);

              if (linkedTransaction != null) {
                // Supaya saldo dompet dikembalikan dalam transaction yang sama.
                await ref.read(transactionListProvider.notifier).deleteTransactionRaw(linkedTransaction);
              }
            }

            await habitRepo.deleteHabitLog(log.id);
          }
        });
      }

      ref.invalidateSelf();
      ref.invalidate(transactionListProvider);
      ref.invalidate(walletListProvider);
    } finally {
      _inFlightHabitIds.remove(habit.id);
    }
  }
}