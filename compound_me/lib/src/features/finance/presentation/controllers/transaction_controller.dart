import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';

part 'transaction_controller.g.dart';

// Provider untuk Filter Bulan
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime newDate) => state = newDate;
}

// Controller Utama
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    final repository = ref.watch(financeRepositoryProvider);
    final selectedMonth = ref.watch(selectedDateProvider);
    return repository.getTransactionsByMonth(selectedMonth);
  }

  // FUNGSI TAMBAH (ADD)
  Future<void> addTransaction({
    required double amount,
    required String note,
    required DateTime date,
    required int categoryId,
    required int walletId,
  }) async {
    final repository = ref.read(financeRepositoryProvider);

    // 1. Ambil data Wallet & Kategori
    final wallets = await repository.getWallets();
    final categories = await repository.getCategories();
    
    final targetWallet = wallets.firstWhere((w) => w.id == walletId);
    final targetCategory = categories.firstWhere((c) => c.id == categoryId);

    // 2. Hitung Saldo Baru
    double newBalance = targetWallet.balance;
    if (targetCategory.type == 0) {
      newBalance -= amount; // Expense
    } else {
      newBalance += amount; // Income
    }

    // 3. Update Saldo Wallet
    final updatedWallet = targetWallet.copyWith(balance: newBalance);
    await repository.updateWallet(updatedWallet);

    // 4. Simpan Transaksi
    final newTransaction = TransactionsCompanion.insert(
      amount: amount,
      date: date,
      note: Value(note),
      categoryId: categoryId,
      walletId: walletId,
    );

    await repository.addTransaction(newTransaction);
    
    // 5. Refresh UI
    ref.invalidateSelf(); 
    ref.invalidate(walletListProvider); 
  }

  // FUNGSI HAPUS (DELETE & REFUND)
  Future<void> deleteTransaction(Transaction transaction) async {
    final repo = ref.read(financeRepositoryProvider);

    // 1. Ambil data terkait
    final categories = await repo.getCategories();
    final category = categories.firstWhere((c) => c.id == transaction.categoryId);

    final wallets = await repo.getWallets();
    final targetWallet = wallets.firstWhere((w) => w.id == transaction.walletId);

    // 2. LOGIKA REFUND / REVERSE
    double newBalance = targetWallet.balance;
    
    if (category.type == 0) {
      // Dulu Pengeluaran, sekarang Uang Dibalikin (Ditambah)
      newBalance += transaction.amount;
    } else {
      // Dulu Pemasukan, sekarang Dibatalkan (Dikurang)
      newBalance -= transaction.amount;
    }

    // 3. Update Saldo
    await repo.updateWallet(targetWallet.copyWith(balance: newBalance));

    // 4. Hapus Data dari DB
    await repo.deleteTransaction(transaction.id);

    // 5. Refresh UI
    ref.invalidateSelf();
    ref.invalidate(walletListProvider);
  }
}