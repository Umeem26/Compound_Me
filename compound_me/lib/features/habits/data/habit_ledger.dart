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
///
/// An undone check-in is soft deleted, never removed, so restoring one of
/// its expenses brings back the same log and link. A soft-deleted log counts
/// as 0 occurrences.
class HabitLedger {
  HabitLedger(this._db);

  final AppDatabase _db;

  /// The active log of [habitId] on [date], if any.
  Future<HabitLogRow?> findLog(String habitId, LocalDate date) async {
    final row = await _findRow(habitId, date);
    return row?.deletedAt == null ? row : null;
  }

  Future<bool> hasActiveLogs(String habitId) async {
    final l = _db.habitLogs;
    final query = _db.selectOnly(l)
      ..addColumns([l.id])
      ..where(l.habitId.equals(habitId) & l.deletedAt.isNull())
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  /// Sets the occurrences of [habit] on [date] to [count]. For reduce
  /// habits, raising the count adds one expense per occurrence at
  /// [occurredAt]; lowering it soft deletes the newest ones. A count of 0
  /// soft deletes the log. Returns the new count.
  Future<int> setCount(
    HabitRow habit,
    LocalDate date,
    int count, {
    required DateTime now,
    required DateTime occurredAt,
  }) async {
    final row = await _findRow(habit.id, date);
    final current = row == null ? 0 : _activeCount(row);
    if (count == current) return current;

    final String logId;
    if (row == null) {
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
    } else {
      logId = row.id;
      if (count > 0) {
        // Also revives an undone log, keeping (habitId, date) unique.
        await _writeCount(logId, count, now);
      } else {
        await _softDeleteLog(logId, now);
      }
    }

    if (habit.kind == HabitKind.reduce) {
      if (count > current) {
        await _addOccurrences(habit, logId, count - current, occurredAt, now);
      } else {
        await _softDeleteNewest(logId, current - count, now);
      }
    }
    return count;
  }

  /// A check-in expense was deleted on its own (from the transaction list):
  /// the check-in loses that occurrence too.
  Future<void> onTransactionDeleted(String habitLogId, DateTime now) async {
    final log = await _logById(habitLogId);
    if (log == null || log.deletedAt != null) return;
    if (log.count <= 1) {
      await _softDeleteLog(log.id, now);
    } else {
      await _writeCount(log.id, log.count - 1, now);
    }
  }

  /// A deleted check-in expense was restored: its occurrence comes back,
  /// reviving the log if that was its last one.
  Future<void> onTransactionRestored(String habitLogId, DateTime now) async {
    final log = await _logById(habitLogId);
    if (log == null) return;
    await _writeCount(log.id, _activeCount(log) + 1, now);
  }

  /// Removes the undone logs of [habitId] for good. Their deleted expenses
  /// lose the link (ON DELETE SET NULL) and restore as plain expenses.
  Future<void> dropDeletedLogs(String habitId) => (_db.delete(
    _db.habitLogs,
  )..where((l) => l.habitId.equals(habitId) & l.deletedAt.isNotNull())).go();

  /// Removes logs undone before [cutoff] for good.
  Future<int> purgeDeletedLogs(DateTime cutoff) => (_db.delete(
    _db.habitLogs,
  )..where((l) => l.deletedAt.isSmallerThanValue(cutoff))).go();

  static int _activeCount(HabitLogRow log) =>
      log.deletedAt == null ? log.count : 0;

  /// Includes an undone log so a new check-in that day can reuse it.
  Future<HabitLogRow?> _findRow(String habitId, LocalDate date) =>
      (_db.select(_db.habitLogs)..where(
            (l) => l.habitId.equals(habitId) & l.date.equals(date.toIso()),
          ))
          .getSingleOrNull();

  Future<HabitLogRow?> _logById(String id) => (_db.select(
    _db.habitLogs,
  )..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<void> _writeCount(String logId, int count, DateTime now) =>
      (_db.update(_db.habitLogs)..where((l) => l.id.equals(logId))).write(
        HabitLogsCompanion(
          count: Value(count),
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );

  /// Keeps the stored count: the CHECK needs it ≥ 1, and deletedAt already
  /// makes it read as 0.
  Future<void> _softDeleteLog(String logId, DateTime now) =>
      (_db.update(_db.habitLogs)..where((l) => l.id.equals(logId))).write(
        HabitLogsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
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
