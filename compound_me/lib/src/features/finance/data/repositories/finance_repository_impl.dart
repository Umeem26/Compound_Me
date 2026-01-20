import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/core/database/database_provider.dart';
import '../../domain/repositories/finance_repository.dart';

part 'finance_repository_impl.g.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final AppDatabase _db;

  FinanceRepositoryImpl(this._db);

  // --- WALLET ---
  @override
  Future<List<Wallet>> getWallets() async {
    return await _db.select(_db.wallets).get();
  }

  @override
  Future<int> addWallet(WalletsCompanion wallet) async {
    return await _db.into(_db.wallets).insert(wallet);
  }

  @override
  Future<bool> updateWallet(Wallet wallet) async {
    return await _db.update(_db.wallets).replace(wallet);
  }

  @override
  Future<int> deleteWallet(int id) async {
    return await (_db.delete(_db.wallets)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- TRANSACTION ---
  @override
  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    // Logic: Ambil transaksi dari tanggal 1 s/d akhir bulan tersebut
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1).subtract(const Duration(seconds: 1));

    return await (_db.select(_db.transactions)
      ..where((tbl) => tbl.date.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();
  }

  @override
  Future<int> addTransaction(TransactionsCompanion transaction) async {
    return await _db.into(_db.transactions).insert(transaction);
  }

  @override
  Future<bool> deleteTransaction(int id) async {
    final result = await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    return result > 0;
  }

  // --- CATEGORY ---
  @override
  Future<List<Category>> getCategories() async {
    return await _db.select(_db.categories).get();
  }
}

// --- PROVIDER ---
// Ini agar Repository bisa dipanggil oleh UI nanti
@riverpod
FinanceRepository financeRepository(FinanceRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return FinanceRepositoryImpl(db);
}