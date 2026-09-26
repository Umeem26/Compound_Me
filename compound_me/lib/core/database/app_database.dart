import 'dart:io';

import 'package:compound_me/core/database/seed.dart';
import 'package:compound_me/core/database/tables/categories.dart';
import 'package:compound_me/core/database/tables/habit_logs.dart';
import 'package:compound_me/core/database/tables/habits.dart';
import 'package:compound_me/core/database/tables/transactions.dart';
import 'package:compound_me/core/database/tables/wallets.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

/// v2 database ("generation 2", fresh file `compoundme.db`), schema from
/// docs/v2/05-architecture-and-data.md §3.
@DriftDatabase(tables: [Wallets, Categories, Transactions, Habits, HabitLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static const fileName = 'compoundme.db';

  /// 1 = phase 0, which shipped an empty schema; 2 = full phase 1 schema.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDefaultCategories(this, now: DateTime.now());
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Version 1 had no tables, so upgrading is the same as creating.
        await m.createAll();
        await seedDefaultCategories(this, now: DateTime.now());
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

QueryExecutor _openConnection() => LazyDatabase(() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(p.join(directory.path, AppDatabase.fileName));
  return NativeDatabase.createInBackground(file);
});

/// Provided by the bootstrap override so the database is opened (and the
/// splash is held) before the first frame.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) =>
    throw UnimplementedError('appDatabaseProvider must be overridden');
