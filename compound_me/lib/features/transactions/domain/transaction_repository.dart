import 'package:compound_me/features/transactions/domain/transaction_entry.dart';

abstract interface class TransactionRepository {
  /// How long deleted transactions stay restorable (PRD US-05.2).
  static const retention = Duration(days: 30);

  /// Non-deleted transactions matching [filter], newest first.
  Stream<List<TransactionEntry>> watch(TransactionFilter filter);

  /// The newest non-deleted transactions (home, S-10).
  Stream<List<TransactionEntry>> watchRecent({int limit = 10});

  Future<TransactionEntry?> findById(String id);

  Future<String> add(TransactionDraft draft);

  /// Edits a transaction; one created by a habit check-in stays linked to it.
  Future<void> update(String id, TransactionDraft draft);

  /// Moves a transaction to the trash (undo window). Deleting a check-in
  /// expense also removes that occurrence from the habit log.
  Future<void> softDelete(String id);

  Future<void> restore(String id);

  /// Permanently removes transactions deleted more than [olderThan] ago.
  /// Returns how many rows were removed.
  Future<int> purgeDeleted({Duration olderThan = retention});
}
