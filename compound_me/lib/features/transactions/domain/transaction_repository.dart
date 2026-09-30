import 'package:compound_me/features/transactions/domain/transaction_entry.dart';

abstract interface class TransactionRepository {
  /// How long deleted transactions stay restorable (PRD US-05.2).
  static const retention = Duration(days: 30);

  /// Non-deleted transactions matching [filter], newest first.
  Stream<List<TransactionEntry>> watch(TransactionFilter filter);

  /// The newest non-deleted transactions (home, S-10).
  Stream<List<TransactionEntry>> watchRecent({int limit = 10});

  /// Like [watch], with each row's category, wallet and habit name for
  /// lists (S-10, S-13); at most [limit] rows when given.
  Stream<List<TransactionListItem>> watchItems(
    TransactionFilter filter, {
    int? limit,
  });

  /// Income and expense of everything [filter] matches, e.g. one month
  /// (S-10) or a search across all months (S-13).
  Stream<PeriodTotals> watchTotals(TransactionFilter filter);

  /// When the oldest non-deleted transaction happened, for month pickers.
  Future<DateTime?> firstOccurredAt();

  /// [firstOccurredAt] as it changes, for the "see the month before" button.
  Stream<DateTime?> watchFirstOccurredAt();

  /// Active categories of [kind], most recently used first (S-11 chips).
  Future<List<String>> recentCategoryIds(TransactionKind kind, {int limit = 6});

  /// Wallet of the newest transaction while it is still active (S-11
  /// default), or null.
  Future<String?> lastUsedWalletId();

  Future<TransactionEntry?> findById(String id);

  Future<String> add(TransactionDraft draft);

  /// Edits a transaction; one created by a habit check-in stays linked to it.
  Future<void> update(String id, TransactionDraft draft);

  /// Moves a transaction to the trash (undo window). Deleting a check-in
  /// expense also removes that occurrence from the habit log.
  Future<void> softDelete(String id);

  /// Undoes [softDelete], including the check-in occurrence it removed.
  Future<void> restore(String id);

  /// Permanently removes transactions and undone habit check-ins deleted
  /// more than [olderThan] ago. Returns how many transactions were removed.
  Future<int> purgeDeleted({Duration olderThan = retention});
}
