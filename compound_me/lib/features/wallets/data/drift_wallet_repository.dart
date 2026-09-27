import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/database/guards.dart';
import 'package:compound_me/core/utils/clock.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/id.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:compound_me/features/wallets/domain/wallet_repository.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drift_wallet_repository.g.dart';

const _nameMaxLength = 30;

class DriftWalletRepository implements WalletRepository {
  DriftWalletRepository(this._db, {this._clock = systemClock});

  final AppDatabase _db;
  final Clock _clock;

  DateTime get _now => toStoredUtc(_clock());

  @override
  Stream<List<WalletBalance>> watchActiveWithBalance() {
    // Balance is derived, never stored (05 §1), so it can never disagree
    // with the transaction history the way v1's stored balance did.
    return _db
        .customSelect(
          'SELECT w.*, w.initial_balance + COALESCE(SUM(CASE '
          "WHEN t.kind = 'income' THEN t.amount "
          "WHEN t.kind = 'expense' THEN -t.amount END), 0) AS balance "
          'FROM wallets w '
          'LEFT JOIN transactions t '
          'ON t.wallet_id = w.id AND t.deleted_at IS NULL '
          'WHERE w.archived_at IS NULL '
          'GROUP BY w.id '
          'ORDER BY w.sort_order, w.created_at',
          readsFrom: {_db.wallets, _db.transactions},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              WalletBalance(
                wallet: _db.wallets.map(row.data).toDomain(),
                balance: row.read<int>('balance'),
              ),
          ],
        );
  }

  @override
  Stream<Money> watchTotalBalance() => watchActiveWithBalance().map(
    (wallets) => wallets.fold(0, (sum, w) => sum + w.balance),
  );

  @override
  Stream<List<Wallet>> watchArchived() {
    final query = _db.select(_db.wallets)
      ..where((w) => w.archivedAt.isNotNull())
      ..orderBy([(w) => OrderingTerm.desc(w.archivedAt)]);
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  @override
  Future<Wallet?> findById(String id) async => (await _find(id))?.toDomain();

  @override
  Future<bool> isInUse(String id) async =>
      await _db.isReferenced('transactions', 'wallet_id', id) ||
      await _db.isReferenced('habits', 'wallet_id', id);

  @override
  Future<String> create(WalletDraft draft) async {
    final name = _validate(draft);
    final id = newId();
    final now = _now;
    await _db.transaction(() async {
      final maxOrder = _db.wallets.sortOrder.max();
      final last = await (_db.selectOnly(
        _db.wallets,
      )..addColumns([maxOrder])).map((r) => r.read(maxOrder)).getSingle();
      await _db
          .into(_db.wallets)
          .insert(
            WalletsCompanion.insert(
              id: id,
              name: name,
              type: draft.type,
              iconKey: draft.iconKey,
              colorKey: draft.colorKey,
              initialBalance: draft.initialBalance,
              sortOrder: Value((last ?? -1) + 1),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    return id;
  }

  @override
  Future<void> update(String id, WalletDraft draft) async {
    final name = _validate(draft);
    final updated =
        await (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
          WalletsCompanion(
            name: Value(name),
            type: Value(draft.type),
            iconKey: Value(draft.iconKey),
            colorKey: Value(draft.colorKey),
            initialBalance: Value(draft.initialBalance),
            updatedAt: Value(_now),
          ),
        );
    if (updated == 0) throw NotFoundException('wallet', id);
  }

  @override
  Future<void> reorder(List<String> orderedIds) => _db.transaction(() async {
    final now = _now;
    for (final (index, id) in orderedIds.indexed) {
      await (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
        WalletsCompanion(sortOrder: Value(index), updatedAt: Value(now)),
      );
    }
  });

  @override
  Future<void> archive(String id) => _db.transaction(() async {
    final wallet = await _require(id);
    if (wallet.archivedAt != null) return;
    await _ensureNotLastActive(id);
    await _setArchivedAt(id, _now);
  });

  @override
  Future<void> unarchive(String id) => _db.transaction(() async {
    await _require(id);
    await _setArchivedAt(id, null);
  });

  @override
  Future<void> delete(String id) => _db.transaction(() async {
    final wallet = await _require(id);
    if (await isInUse(id)) throw WalletInUseException(id);
    if (wallet.archivedAt == null) await _ensureNotLastActive(id);
    await (_db.delete(_db.wallets)..where((w) => w.id.equals(id))).go();
  });

  String _validate(WalletDraft draft) {
    final name = validName(draft.name, maxLength: _nameMaxLength);
    if (draft.initialBalance < 0) {
      throw const ValidationException(ValidationError.amountNegative);
    }
    return name;
  }

  Future<WalletRow?> _find(String id) => (_db.select(
    _db.wallets,
  )..where((w) => w.id.equals(id))).getSingleOrNull();

  Future<WalletRow> _require(String id) async =>
      await _find(id) ?? (throw NotFoundException('wallet', id));

  Future<void> _ensureNotLastActive(String id) async {
    final others = _db.wallets.id.count();
    final count =
        await (_db.selectOnly(_db.wallets)
              ..addColumns([others])
              ..where(
                _db.wallets.archivedAt.isNull() &
                    _db.wallets.id.equals(id).not(),
              ))
            .map((r) => r.read(others))
            .getSingle();
    if ((count ?? 0) == 0) throw LastActiveWalletException(id);
  }

  Future<void> _setArchivedAt(String id, DateTime? archivedAt) =>
      (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
        WalletsCompanion(archivedAt: Value(archivedAt), updatedAt: Value(_now)),
      );
}

extension on WalletRow {
  Wallet toDomain() => Wallet(
    id: id,
    name: name,
    type: type,
    iconKey: iconKey,
    colorKey: colorKey,
    initialBalance: initialBalance,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
    archivedAt: archivedAt,
  );
}

@Riverpod(keepAlive: true)
WalletRepository walletRepository(Ref ref) =>
    DriftWalletRepository(ref.watch(appDatabaseProvider));
