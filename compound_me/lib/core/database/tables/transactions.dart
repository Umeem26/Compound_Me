// Drift's CHECK DSL references a column inside its own getter; that is a
// declaration for the code generator, not runtime recursion.
// ignore_for_file: recursive_getters

import 'package:compound_me/core/database/tables/categories.dart';
import 'package:compound_me/core/database/tables/habit_logs.dart';
import 'package:compound_me/core/database/tables/sync_columns.dart';
import 'package:compound_me/core/database/tables/wallets.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:drift/drift.dart';

@DataClassName('TransactionRow')
@TableIndex(name: 'transactions_occurred_at', columns: {#occurredAt})
@TableIndex(
  name: 'transactions_wallet_occurred_at',
  columns: {#walletId, #occurredAt},
)
@TableIndex(
  name: 'transactions_category_occurred_at',
  columns: {#categoryId, #occurredAt},
)
@TableIndex(name: 'transactions_habit_log', columns: {#habitLogId})
class Transactions extends Table with SyncColumns {
  TextColumn get kind => textEnum<TransactionKind>().check(
    kind.isIn(TransactionKind.values.map((k) => k.name)),
  )();

  /// Always positive; the direction comes from [kind].
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();
  TextColumn get walletId =>
      text().references(Wallets, #id, onDelete: KeyAction.restrict)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  TextColumn get note =>
      text().nullable().check(note.length.isSmallerOrEqualValue(120))();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get habitLogId => text().nullable().references(
    HabitLogs,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
