import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/core/database/database_provider.dart';

part 'transaction_controller.g.dart';

// State Provider untuk Filter Tanggal (Month Picker)
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void updateDate(DateTime date) {
    state = date;
  }
}

// Controller Utama Transaksi
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    final db = ref.watch(appDatabaseProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // Ambil data berdasarkan bulan & tahun yang dipilih
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);

    return (db.select(db.transactions)
      ..where((t) => t.date.isBetweenValues(startOfMonth, endOfMonth))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();
  }

  // 1. TAMBAH TRANSAKSI BARU
  Future<void> addTransaction({
    required double amount,
    required String note,
    required DateTime date,
    required int categoryId,
    required int walletId,
  }) async {
    final db = ref.read(appDatabaseProvider);

    // Cek Tipe Kategori (0 = Pengeluaran, 1 = Pemasukan)
    final category = await (db.select(db.categories)..where((c) => c.id.equals(categoryId))).getSingle();
    
    // Jika Pengeluaran (0), jadikan negatif. Jika Pemasukan (1), positif.
    final finalAmount = category.type == 0 ? -amount.abs() : amount.abs();

    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        amount: finalAmount,
        note: Value(note),
        date: date,
        categoryId: categoryId,
        walletId: walletId,
      ),
    );

    // Update Saldo Dompet
    await _updateWalletBalance(walletId, finalAmount);
    
    ref.invalidateSelf(); // Refresh UI
  }

  // 2. EDIT TRANSAKSI (FITUR BARU)
  Future<void> editTransaction({
    required int id,
    required double newAmount,
    required String newNote,
    required DateTime newDate,
    required int newCategoryId,
    required int newWalletId,
    required double oldAmount, // Butuh saldo lama untuk koreksi dompet
    required int oldWalletId,
  }) async {
    final db = ref.read(appDatabaseProvider);

    // Cek Tipe Kategori Baru
    final category = await (db.select(db.categories)..where((c) => c.id.equals(newCategoryId))).getSingle();
    final finalAmount = category.type == 0 ? -newAmount.abs() : newAmount.abs();

    // Update Transaksi di DB
    await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        amount: Value(finalAmount),
        note: Value(newNote),
        date: Value(newDate),
        categoryId: Value(newCategoryId),
        walletId: Value(newWalletId),
      ),
    );

    // KOREKSI SALDO DOMPET (Penting!)
    // 1. Kembalikan saldo lama (Undo efek transaksi sebelumnya)
    await _updateWalletBalance(oldWalletId, -oldAmount); 
    // 2. Terapkan saldo baru
    await _updateWalletBalance(newWalletId, finalAmount);

    ref.invalidateSelf();
  }

  // 3. HAPUS TRANSAKSI
  Future<void> deleteTransaction(Transaction trx) async {
    final db = ref.read(appDatabaseProvider);
    
    await db.delete(db.transactions).delete(trx);
    
    // Kembalikan Saldo (Minus ketemu Minus jadi Plus)
    await _updateWalletBalance(trx.walletId, -trx.amount);
    
    ref.invalidateSelf();
  }

  // Helper untuk update saldo dompet
  Future<void> _updateWalletBalance(int walletId, double amountDiff) async {
    final db = ref.read(appDatabaseProvider);
    final wallet = await (db.select(db.wallets)..where((w) => w.id.equals(walletId))).getSingle();
    
    final newBalance = wallet.balance + amountDiff;
    
    await (db.update(db.wallets)..where((w) => w.id.equals(walletId))).write(
      WalletsCompanion(balance: Value(newBalance)),
    );
    
    // Refresh Provider Wallet di UI lain
    // Catatan: Karena WalletListProvider ada di file lain, kita tidak bisa invalidate langsung dari sini
    // kecuali kita import. Tapi biarkan UI yang handle refresh via watch.
  }
}