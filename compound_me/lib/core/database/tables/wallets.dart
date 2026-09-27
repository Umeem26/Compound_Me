// Drift's CHECK DSL references a column inside its own getter; that is a
// declaration for the code generator, not runtime recursion.
// ignore_for_file: recursive_getters

import 'package:compound_me/core/database/tables/sync_columns.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:drift/drift.dart';

@DataClassName('WalletRow')
class Wallets extends Table with SyncColumns {
  TextColumn get name => text().check(name.length.isBetweenValues(1, 30))();
  TextColumn get type => textEnum<WalletType>().check(
    type.isIn(WalletType.values.map((t) => t.name)),
  )();
  TextColumn get iconKey => text()();
  TextColumn get colorKey => text()();
  IntColumn get initialBalance =>
      integer().check(initialBalance.isBiggerOrEqualValue(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}
