import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/clock.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/id.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/habits/data/habit_ledger.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/domain/transaction_repository.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drift_transaction_repository.g.dart';

const _noteMaxLength = 120;
const _likeEscape = r'\';

class DriftTransactionRepository implements TransactionRepository {
  DriftTransactionRepository(this._db, {this._clock = systemClock})
    : _ledger = HabitLedger(_db);

  final AppDatabase _db;
  final Clock _clock;
  final HabitLedger _ledger;

  DateTime get _now => toStoredUtc(_clock());

  @override
  Stream<List<TransactionEntry>> watch(TransactionFilter filter) {
    final t = _db.transactions;
    final c = _db.categories;
    final query = _db.select(t).join([
      innerJoin(c, c.id.equalsExp(t.categoryId), useColumns: false),
    ]);

    var where = t.deletedAt.isNull();
    if (filter.year != null) {
      final range = localMonthRangeUtc(filter.year!, filter.month!);
      where &=
          t.occurredAt.isBiggerOrEqualValue(range.start) &
          t.occurredAt.isSmallerThanValue(range.end);
    }
    if (filter.categoryId != null) {
      where &= t.categoryId.equals(filter.categoryId!);
    }
    if (filter.walletId != null) where &= t.walletId.equals(filter.walletId!);
    final text = filter.query?.trim() ?? '';
    if (text.isNotEmpty) {
      final pattern = '%${_escapeLike(text)}%';
      var matches =
          t.note.like(pattern, escapeChar: _likeEscape) |
          c.customName.like(pattern, escapeChar: _likeEscape);
      if (filter.extraCategoryIds.isNotEmpty) {
        matches |= t.categoryId.isIn(filter.extraCategoryIds);
      }
      where &= matches;
    }

    query
      ..where(where)
      ..orderBy([
        OrderingTerm.desc(t.occurredAt),
        OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch().map(
      (rows) => [for (final row in rows) row.readTable(t).toDomain()],
    );
  }

  @override
  Stream<List<TransactionEntry>> watchRecent({int limit = 10}) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.occurredAt),
        (t) => OrderingTerm.desc(t.createdAt),
      ])
      ..limit(limit);
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  @override
  Future<TransactionEntry?> findById(String id) async =>
      (await _find(id))?.toDomain();

  @override
  Future<String> add(TransactionDraft draft) async {
    final id = newId();
    final now = _now;
    await _db.transaction(() async {
      final note = await _validate(draft);
      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: id,
              kind: draft.kind,
              amount: draft.amount,
              walletId: draft.walletId,
              categoryId: draft.categoryId,
              note: Value(note),
              occurredAt: toStoredUtc(draft.occurredAt),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    return id;
  }

  @override
  Future<void> update(String id, TransactionDraft draft) => _db.transaction(
    () async {
      final current = await _find(id);
      if (current == null || current.deletedAt != null) {
        throw NotFoundException('transaction', id);
      }
      final note = await _validate(draft, current: current);
      await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          kind: Value(draft.kind),
          amount: Value(draft.amount),
          walletId: Value(draft.walletId),
          categoryId: Value(draft.categoryId),
          note: Value(note),
          occurredAt: Value(toStoredUtc(draft.occurredAt)),
          updatedAt: Value(_now),
        ),
      );
    },
  );

  @override
  Future<void> softDelete(String id) => _db.transaction(() async {
    final row = await _find(id);
    if (row == null) throw NotFoundException('transaction', id);
    if (row.deletedAt != null) return;
    final now = _now;
    await _setDeletedAt(id, now);
    if (row.habitLogId != null) {
      await _ledger.onTransactionDeleted(row.habitLogId!, now);
    }
  });

  @override
  Future<void> restore(String id) => _db.transaction(() async {
    final row = await _find(id);
    if (row == null) throw NotFoundException('transaction', id);
    if (row.deletedAt == null) return;
    final now = _now;
    await _setDeletedAt(id, null);
    // If the check-in itself is gone, its link was nulled by the foreign key
    // and the expense comes back as a plain one.
    if (row.habitLogId != null) {
      await _ledger.onTransactionRestored(row.habitLogId!, now);
    }
  });

  @override
  Future<int> purgeDeleted({
    Duration olderThan = TransactionRepository.retention,
  }) {
    final cutoff = toStoredUtc(_clock().subtract(olderThan));
    return (_db.delete(
      _db.transactions,
    )..where((t) => t.deletedAt.isSmallerThanValue(cutoff))).go();
  }

  Future<TransactionRow?> _find(String id) => (_db.select(
    _db.transactions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> _setDeletedAt(String id, DateTime? deletedAt) =>
      (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(_now),
        ),
      );

  /// Validates [draft] and returns the note to store. Archived wallets and
  /// categories are hidden from pickers, so only an existing link to one may
  /// be kept (when editing an older transaction).
  Future<String?> _validate(
    TransactionDraft draft, {
    TransactionRow? current,
  }) async {
    if (draft.amount <= 0) {
      throw const ValidationException(ValidationError.amountNotPositive);
    }
    final note = draft.note?.trim();
    if (note != null && note.length > _noteMaxLength) {
      throw const ValidationException(ValidationError.noteTooLong);
    }

    final wallet = await (_db.select(
      _db.wallets,
    )..where((w) => w.id.equals(draft.walletId))).getSingleOrNull();
    if (wallet == null) throw NotFoundException('wallet', draft.walletId);
    if (wallet.archivedAt != null && wallet.id != current?.walletId) {
      throw const ValidationException(ValidationError.archivedReference);
    }

    final category = await (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(draft.categoryId))).getSingleOrNull();
    if (category == null) {
      throw NotFoundException('category', draft.categoryId);
    }
    if (category.kind.name != draft.kind.name) {
      throw const ValidationException(ValidationError.categoryKindMismatch);
    }
    if (category.archivedAt != null && category.id != current?.categoryId) {
      throw const ValidationException(ValidationError.archivedReference);
    }
    return note == null || note.isEmpty ? null : note;
  }

  static String _escapeLike(String text) => text
      .replaceAll(_likeEscape, '$_likeEscape$_likeEscape')
      .replaceAll('%', '$_likeEscape%')
      .replaceAll('_', '${_likeEscape}_');
}

extension on TransactionRow {
  TransactionEntry toDomain() => TransactionEntry(
    id: id,
    kind: kind,
    amount: amount,
    walletId: walletId,
    categoryId: categoryId,
    note: note,
    occurredAt: occurredAt,
    habitLogId: habitLogId,
    deletedAt: deletedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) =>
    DriftTransactionRepository(ref.watch(appDatabaseProvider));
