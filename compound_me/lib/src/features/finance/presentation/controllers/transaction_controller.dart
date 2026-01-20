import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/features/finance/data/repositories/finance_repository_impl.dart';

part 'transaction_controller.g.dart';

// 1. Provider sederhana untuk menyimpan "Bulan yang dipilih"
// Default-nya adalah hari ini (Bulan sekarang)
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
    // Kita baca bulan yang sedang dipilih user
    final selectedMonth = ref.watch(selectedDateProvider);
    
    // Ambil transaksi sesuai bulan tersebut
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

    final newTransaction = TransactionsCompanion.insert(
      amount: amount,
      date: date,
      note: Value(note),
      categoryId: categoryId,
      walletId: walletId,
    );

    await repository.addTransaction(newTransaction);
    
    // Refresh list transaksi agar yang baru muncul
    ref.invalidateSelf();
    // Refresh juga list wallet, karena saldo pasti berubah kan?
    // Nanti kita import wallet_controller untuk invalidate juga.
  }
}