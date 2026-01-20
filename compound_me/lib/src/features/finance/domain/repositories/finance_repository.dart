// PERBAIKAN: Gunakan 'package:compound_me/...' agar jalur file pasti benar
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
  Future<bool> deleteTransaction(int id);
  
  // --- CATEGORY ---
  Future<List<Category>> getCategories();
}