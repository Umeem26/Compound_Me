import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fresh in-memory database (schema + seeded categories), closed after the
/// test.
AppDatabase openTestDatabase() {
  // Each test opens its own database on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// A controllable clock for repositories; move time by assigning [now].
class FakeClock {
  FakeClock(this.now);

  DateTime now;

  DateTime call() => now;
}

Future<String> seedWallet(
  AppDatabase db, {
  String name = 'Tunai',
  int initialBalance = 100000,
}) => DriftWalletRepository(db).create(
  WalletDraft(
    name: name,
    type: WalletType.cash,
    iconKey: 'wallet',
    colorKey: 'teal',
    initialBalance: initialBalance,
  ),
);

/// Id of a seeded default category, e.g. `catFood` or `catAllowance`.
Future<String> defaultCategoryId(AppDatabase db, String nameKey) async =>
    (await (db.select(
      db.categories,
    )..where((c) => c.nameKey.equals(nameKey))).getSingle()).id;
