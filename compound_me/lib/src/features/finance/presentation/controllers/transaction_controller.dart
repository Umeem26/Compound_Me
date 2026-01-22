import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';

part 'transaction_controller.g.dart';

@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();
  void updateDate(DateTime newDate) => state = newDate;
}

@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    final repository = ref.watch(financeRepositoryProvider);
    final selectedMonth = ref.watch(selectedDateProvider);
    return repository.getTransactionsByMonth(selectedMonth);
  }

  // FUNGSI TAMBAH TRANSAKSI (Logic Baru +/-)
  Future<void> addTransaction({
    required double amount,
    required String note,
    required DateTime date,
    required int categoryId,
    required int walletId,
  }) async {
    final repository = ref.read(financeRepositoryProvider);

    final wallets = await repository.getWallets();
    final categories = await repository.getCategories();
    
    final targetWallet = wallets.firstWhere((w) => w.id == walletId);
    final targetCategory = categories.firstWhere((c) => c.id == categoryId);

    double newBalance = targetWallet.balance;
    double finalAmount = amount; 

    // LOGIKA PENTING: Tentukan Positif/Negatif
    if (targetCategory.type == 0) {
      // Type 0 = Pengeluaran (Expense)
      newBalance -= amount;       // Kurangi Saldo
      finalAmount = -amount;      // Simpan sebagai MINUS
    } else {
      // Type 1 = Pemasukan (Income)
      newBalance += amount;       // Tambah Saldo
      finalAmount = amount;       // Simpan sebagai PLUS
    }

    // Update Saldo Wallet
    await repository.updateWallet(targetWallet.copyWith(balance: newBalance));

    // Simpan Transaksi dengan finalAmount (yg sudah ada minusnya)
    final newTransaction = TransactionsCompanion.insert(
      amount: finalAmount, 
      date: date,
      note: Value(note),
      categoryId: categoryId,
      walletId: walletId,
    );

    await repository.addTransaction(newTransaction);
    
    ref.invalidateSelf(); 
    ref.invalidate(walletListProvider); 
  }

  // FUNGSI HAPUS TRANSAKSI (Logic Universal)
  Future<void> deleteTransaction(Transaction transaction) async {
    final repo = ref.read(financeRepositoryProvider);
    final wallets = await repo.getWallets();
    
    // Cari wallet, kalau gak ketemu (misal udah dihapus) return
    final targetWallet = wallets.firstWhere((w) => w.id == transaction.walletId, orElse: () => wallets.first);

    // LOGIKA REFUND PINTAR:
    // Saldo Baru = Saldo Lama - (Nilai Transaksi)
    // Matematika: 
    // Jika hapus pengeluaran (-5000): Saldo - (-5000) = Saldo + 5000 (Uang balik)
    // Jika hapus pemasukan (+5000): Saldo - (5000) = Saldo - 5000 (Uang ditarik)
    
    double newBalance = targetWallet.balance - transaction.amount;
    
    await repo.updateWallet(targetWallet.copyWith(balance: newBalance));
    await repo.deleteTransaction(transaction.id);
    
    ref.invalidateSelf();
    ref.invalidate(walletListProvider);
  }
}