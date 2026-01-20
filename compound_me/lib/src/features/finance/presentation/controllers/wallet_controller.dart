import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:drift/drift.dart'; // <--- TAMBAHKAN INI

part 'wallet_controller.g.dart';

// Controller ini bertugas mengelola List<Wallet>
@riverpod
class WalletList extends _$WalletList {
  @override
  Future<List<Wallet>> build() async {
    // 1. Panggil repository
    final repository = ref.watch(financeRepositoryProvider);
    // 2. Minta data wallets
    return repository.getWallets();
  }

  // Fungsi tambah wallet
  Future<void> addWallet({
    required String name,
    required double initialBalance,
    required int color,
  }) async {
    final repository = ref.read(financeRepositoryProvider);
    
    final newWallet = WalletsCompanion.insert(
      name: name,
      balance: Value(initialBalance),
      icon: 'assets/icons/wallet_default.png', // Default icon dulu
      color: color,
    );

    await repository.addWallet(newWallet);

    // AJAIB: Baris ini memaksa controller untuk mengambil data ulang dari database
    // UI akan otomatis berubah tanpa setState!
    ref.invalidateSelf();
  }
}