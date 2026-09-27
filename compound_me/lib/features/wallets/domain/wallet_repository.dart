import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';

/// A wallet that has transactions or is used by a habit can only be
/// archived, not deleted (PRD US-06.1).
class WalletInUseException implements Exception {
  const WalletInUseException(this.walletId);

  final String walletId;
}

/// At least one active wallet must always remain (PRD US-06.1).
class LastActiveWalletException implements Exception {
  const LastActiveWalletException(this.walletId);

  final String walletId;
}

abstract interface class WalletRepository {
  /// Active wallets in display order, each with its balance computed from
  /// the initial balance and non-deleted transactions (05 §3).
  Stream<List<WalletBalance>> watchActiveWithBalance();

  /// Sum of all active wallet balances.
  Stream<Money> watchTotalBalance();

  Stream<List<Wallet>> watchArchived();

  Future<Wallet?> findById(String id);

  /// Whether any transaction (deleted ones included) or habit uses it.
  Future<bool> isInUse(String id);

  Future<String> create(WalletDraft draft);

  Future<void> update(String id, WalletDraft draft);

  /// Saves the display order of active wallets.
  Future<void> reorder(List<String> orderedIds);

  Future<void> archive(String id);

  Future<void> unarchive(String id);

  Future<void> delete(String id);
}
