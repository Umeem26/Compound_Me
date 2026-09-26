import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/id.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:drift/drift.dart';

/// Keeps habit logs and their check-in transactions in step (05 §3: one
/// expense per reduce occurrence, linked by habitLogId). The only place that
/// writes both tables. Every method must run inside the caller's
/// `db.transaction` so a log never exists without its transactions.
class HabitLedger {
  HabitLedger(this._db);

  final AppDatabase _db;

  Future<HabitLogRow?> findLog(String habitId, LocalDate date) =>
      (_db.select(_db.habitLogs)..where(
            (l) => l.habitId.equals(habitId) & l.date.equals(date.toIso()),
          ))
          .getSingleOrNull();

  /// Sets the occurrences of [habit] on [date] to [count]. For reduce
  /// habits, raising the count adds one expense per occurrence at
  /// [occurredAt]; lowering it soft deletes the newest ones. A count of 0
  /// removes the log. Returns the new count.
  Future<int> setCount(
    HabitRow habit,
    LocalDate date,
    int count, {
    required DateTime now,
    required DateTime occurredAt,
  }) async {
    final log = await findLog(habit.id, date);
    final current = log?.count ?? 0;
    if (count == current) return current;

    var logId = log?.id;
    if (log == null) {
      logId = newId();
      await _db
          .into(_db.habitLogs)
          .insert(
            HabitLogsCompanion.insert(
              id: logId,
              habitId: habit.id,
              date: date.toIso(),
              count: count,
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else if (count > 0) {
      await _writeCount(log.id, count, now);
    }

    if (habit.kind == HabitKind.reduce) {
      if (count > current) {
        await _addOccurrences(habit, logId!, count - current, occurredAt, now);
      } else {
        await _softDeleteNewest(logId!, current - count, now);
      }
    }

    if (count == 0 && log != null) {
      // habit_logs → transactions is ON DELETE SET NULL, so the soft-deleted
      // expenses stay in the trash, unlinked, until they are purged.
      await (_db.delete(_db.habitLogs)..where((l) => l.id.equals(log.id))).go();
    }
    return count;
  }

  /// A check-in expense was deleted on its own (from the transaction list):
  /// the check-in loses that occurrence too.
  Future<void> onTransactionDeleted(String habitLogId, DateTime now) async {
    final log = await _logById(habitLogId);
    if (log == null) return;
    if (log.count <= 1) {
      await (_db.delete(_db.habitLogs)..where((l) => l.id.equals(log.id))).go();
    } else {
      await _writeCount(log.id, log.count - 1, now);
    }
  }

  /// A deleted check-in expense was restored while its log still exists.
  Future<void> onTransactionRestored(String habitLogId, DateTime now) async {
    final log = await _logById(habitLogId);
    if (log == null) return;
    await _writeCount(log.id, log.count + 1, now);
  }

  Future<HabitLogRow?> _logById(String id) => (_db.select(
    _db.habitLogs,
  )..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<void> _writeCount(String logId, int count, DateTime now) =>
      (_db.update(_db.habitLogs)..where((l) => l.id.equals(logId))).write(
        HabitLogsCompanion(count: Value(count), updatedAt: Value(now)),
      );

  Future<void> _addOccurrences(
    HabitRow habit,
    String logId,
    int occurrences,
    DateTime occurredAt,
    DateTime now,
  ) async {
    for (var i = 0; i < occurrences; i++) {
      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: newId(),
              kind: TransactionKind.expense,
              amount: habit.costPerOccurrence!,
              walletId: habit.walletId!,
              categoryId: habit.categoryId!,
              occurredAt: occurredAt,
              habitLogId: Value(logId),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<void> _softDeleteNewest(
    String logId,
    int occurrences,
    DateTime now,
  ) async {
    final t = _db.transactions;
    final newest =
        await (_db.selectOnly(t)
              ..addColumns([t.id])
              ..where(t.habitLogId.equals(logId) & t.deletedAt.isNull())
              ..orderBy([
                OrderingTerm.desc(t.occurredAt),
                OrderingTerm.desc(t.createdAt),
                // Same timestamps (e.g. a backdated check-in): newest row.
                OrderingTerm.desc(const CustomExpression<int>('rowid')),
              ])
              ..limit(occurrences))
            .map((row) => row.read(t.id)!)
            .get();
    await (_db.update(t)..where((row) => row.id.isIn(newest))).write(
      TransactionsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}
