import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import tabel yang tadi kita buat
import 'tables.dart';

// Bagian ini wajib ada untuk Code Generation
part 'app_database.g.dart';

@DriftDatabase(tables: [Wallets, Categories, Transactions, Habits, HabitLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// Fungsi untuk membuka koneksi file database di HP
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'compound_me.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}