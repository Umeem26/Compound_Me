import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

/// v2 database ("generation 2", fresh file). Tables arrive in phase 1; the
/// empty schema lets bootstrap open the file and apply pragmas today.
@DriftDatabase()
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static const fileName = 'compoundme.db';

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
