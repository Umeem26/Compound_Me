import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/features/finance/data/repositories/finance_repository_impl.dart';

// Kita butuh import WalletController agar bisa menyuruhnya refresh saldo
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';

part 'transaction_controller.g.dart';

// 1. Provider untuk menyimpan "Bulan yang dipilih"
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime newDate) => state = newDate;
}

// 2. Controller utama Transaksi
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    final repository = ref.watch(financeRepositoryProvider);
    final selectedMonth = ref.watch(selectedDateProvider);
    return repository.getTransactionsByMonth(selectedMonth);
  }

  Future<void> addTransaction({
    required double amount,
    required String note,
    required DateTime date,
    required int categoryId,
    required int walletId,
  }) async {
    final repository = ref.read(financeRepositoryProvider);

    // --- LOGIKA BARU: UPDATE SALDO DOMPET ---
    
    // 1. Ambil data Wallet & Kategori dari database untuk dicek
    final wallets = await repository.getWallets();
    final categories = await repository.getCategories();
    
    final targetWallet = wallets.firstWhere((w) => w.id == walletId);
    final targetCategory = categories.firstWhere((c) => c.id == categoryId);

    // 2. Hitung Saldo Baru
    double newBalance = targetWallet.balance;
    if (targetCategory.type == 0) {
      // Type 0 = Pengeluaran (Expense) -> KURANGI Saldo
      newBalance -= amount;
    } else {
      // Type 1 = Pemasukan (Income) -> TAMBAH Saldo
      newBalance += amount;
    }

    // 3. Simpan Perubahan Saldo ke Database Wallet
    // copyWith adalah method bawaan Drift untuk duplikasi data dengan perubahan
    final updatedWallet = targetWallet.copyWith(balance: newBalance);
    await repository.updateWallet(updatedWallet);

    // --- AKHIR LOGIKA UPDATE SALDO ---

    // 4. Simpan Transaksi (Struk)
    final newTransaction = TransactionsCompanion.insert(
      amount: amount,
      date: date,
      note: Value(note),
      categoryId: categoryId,
      walletId: walletId,
    );

    await repository.addTransaction(newTransaction);
    
    // 5. Refresh UI
    ref.invalidateSelf(); // Refresh list transaksi di bawah
    ref.invalidate(walletListProvider); // Refresh kartu hijau & list dompet (PENTING!)
  }
}