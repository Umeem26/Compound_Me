import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_providers.g.dart';

/// How many transactions Home lists (03 S-10).
const homeRecentLimit = 10;

@riverpod
Stream<List<TransactionListItem>> recentTransactions(Ref ref) => ref
    .watch(transactionRepositoryProvider)
    .watchItems(const TransactionFilter(), limit: homeRecentLimit);

@riverpod
Stream<PeriodTotals> monthTotals(Ref ref, int year, int month) =>
    ref.watch(transactionRepositoryProvider).watchMonthTotals(year, month);

/// Current balance of all active wallets.
@riverpod
Stream<int> totalBalance(Ref ref) =>
    ref.watch(walletRepositoryProvider).watchTotalBalance();

@riverpod
Stream<List<TransactionListItem>> transactionHistory(
  Ref ref,
  TransactionFilter filter,
) => ref.watch(transactionRepositoryProvider).watchItems(filter);
