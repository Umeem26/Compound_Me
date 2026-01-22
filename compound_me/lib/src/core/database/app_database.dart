import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart'; // Pastikan import tables.dart ada

part 'app_database.g.dart';

@DriftDatabase(tables: [Wallets, Transactions, Categories, Habits, HabitLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    // GANTI NAMA FILE JADI V3 AGAR DATABASE RESET
    final file = File(p.join(dbFolder.path, 'compound_me_v3.sqlite')); 
    return NativeDatabase.createInBackground(file);
  });
}