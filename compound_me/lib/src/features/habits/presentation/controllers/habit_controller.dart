import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/features/habits/data/repositories/habit_repository_impl.dart';

// IMPORT PENTING UNTUK INTEGRASI
import 'package:compound_me/src/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';

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
  @override
  Future<List<HabitLog>> build() async {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getHabitLogsByDate(DateTime.now());
  }

  // --- FUNGSI UTAMA: CHECKLIST HABIT + AUTO TRANSAKSI ---
  Future<void> checkHabit(Habit habit) async {
    final habitRepo = ref.read(habitRepositoryProvider);
    
    // 1. Catat di Log Habit (Bahwa hari ini sudah dilakukan)
    await habitRepo.logHabit(HabitLogsCompanion.insert(
      habitId: habit.id,
      completedAt: DateTime.now(),
    ));

    // 2. Refresh Checklist UI biar jadi hijau dulu
    ref.invalidateSelf();

    // 3. LOGIKA COMPOUND EFFECT:
    // Jika habit ini punya biaya (misal: Ngopi 25rb), kita buat transaksi otomatis.
    if (habit.costPerUnit > 0) {
      final financeRepo = ref.read(financeRepositoryProvider);
      
      // A. Cari Dompet & Kategori untuk dipotong
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

        // B. Panggil TransactionController untuk Eksekusi Pemotongan Saldo
        // Kita pakai fungsi addTransaction yang sudah cerdas kemarin
        await ref.read(transactionListProvider.notifier).addTransaction(
          amount: habit.costPerUnit,
          note: "Auto-Habit: ${habit.name}", // Catatan otomatis
          date: DateTime.now(),
          categoryId: targetCategory.id,
          walletId: targetWallet.id,
        );
      }
    }
  }
}