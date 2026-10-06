import 'package:compound_me/core/utils/dates.dart';
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

/// Income and expense of what [filter] matches (S-10, S-13 summary).
@riverpod
Stream<PeriodTotals> transactionTotals(Ref ref, TransactionFilter filter) =>
    ref.watch(transactionRepositoryProvider).watchTotals(filter);

/// The month of the oldest transaction, or null without any.
@riverpod
Stream<YearMonth?> oldestTransactionMonth(Ref ref) => ref
    .watch(transactionRepositoryProvider)
    .watchFirstOccurredAt()
    .map((at) => at == null ? null : YearMonth.of(at));

/// Current balance of all active wallets.
@riverpod
Stream<int> totalBalance(Ref ref) =>
    ref.watch(walletRepositoryProvider).watchTotalBalance();

/// History rows; [limit] pages search results across all months.
@riverpod
Stream<List<TransactionListItem>> transactionHistory(
  Ref ref,
  TransactionFilter filter,
  int? limit,
) => ref.watch(transactionRepositoryProvider).watchItems(filter, limit: limit);
