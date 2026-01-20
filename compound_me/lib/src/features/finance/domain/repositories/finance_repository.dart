import '../../../core/database/app_database.dart';

// Abstract Class = Kontrak Kerja.
// Kita hanya menulis nama fungsinya saja, belum isinya.
abstract class FinanceRepository {
  // --- WALLET ---
  Future<List<Wallet>> getWallets();
  Future<int> addWallet(WalletsCompanion wallet); // Mengembalikan ID wallet baru
  Future<bool> updateWallet(Wallet wallet);
  Future<int> deleteWallet(int id);

  // --- TRANSACTION ---
  // Ambil transaksi per bulan (untuk laporan bulanan)
  Future<List<Transaction>> getTransactionsByMonth(DateTime month);
  Future<int> addTransaction(TransactionsCompanion transaction);
  Future<bool> deleteTransaction(int id);
  
  // --- CATEGORY ---
  Future<List<Category>> getCategories();
}