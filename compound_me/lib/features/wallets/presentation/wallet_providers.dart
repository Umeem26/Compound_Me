import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_providers.g.dart';

@riverpod
Stream<List<WalletBalance>> activeWallets(Ref ref) =>
    ref.watch(walletRepositoryProvider).watchActiveWithBalance();

@riverpod
Stream<List<Wallet>> archivedWallets(Ref ref) =>
    ref.watch(walletRepositoryProvider).watchArchived();

/// What the wallet form needs besides the wallet itself: which of archive
/// or delete applies, and whether it is the last active one (S-41).
typedef WalletEditorSource = ({Wallet wallet, bool inUse, bool lastActive});

@riverpod
Future<WalletEditorSource?> walletEditorSource(Ref ref, String id) async {
  final repository = ref.watch(walletRepositoryProvider);
  final wallet = await repository.findById(id);
  if (wallet == null) return null;
  final active = await repository.watchActiveWithBalance().first;
  return (
    wallet: wallet,
    inUse: await repository.isInUse(id),
    lastActive: !wallet.isArchived && active.length <= 1,
  );
}
