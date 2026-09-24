// PERBAIKAN: Gunakan import yang benar
import 'package:compound_me/src/core/database/app_database.dart';

abstract class FinanceRepository {
  // --- WALLET ---
  Future<List<Wallet>> getWallets();
  Future<int> addWallet(WalletsCompanion wallet);
  Future<bool> updateWallet(Wallet wallet);
  Future<int> deleteWallet(int id);

  // --- TRANSACTION ---
  Future<List<Transaction>> getTransactionsByMonth(DateTime month);
  Future<int> addTransaction(TransactionsCompanion transaction);
  
  // PERBAIKAN: Hanya ada SATU fungsi deleteTransaction (tipe int)
  Future<int> deleteTransaction(int id);

  // Cari transaksi otomatis yang tertaut ke sebuah habit log (untuk uncheck habit)
  Future<Transaction?> getTransactionByHabitLogId(int habitLogId);

  // --- CATEGORY ---
  Future<List<Category>> getCategories();
  Future<int> addCategory(CategoriesCompanion category);
}