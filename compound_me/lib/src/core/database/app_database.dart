import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart'; // Pastikan import tables.dart ada

part 'app_database.g.dart';

@DriftDatabase(tables: [Wallets, Transactions, Categories, Habits, HabitLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(transactions, transactions.habitLogId);
          }
        },
        beforeOpen: (details) async {
          // Jalan setiap kali DB dibuka (baik instalasi baru maupun pengguna lama
          // yang upgrade dari skema lebih tua). Seed kategori default hanya kalau
          // tabel categories memang masih kosong, supaya tidak dobel dan supaya
          // pengguna lama yang belum sempat ter-seed tetap dapat kategori default.
          final existingCategories = await select(categories).get();
          if (existingCategories.isEmpty) {
            await _seedDefaultCategories();
          }
        },
      );

  Future<void> _seedDefaultCategories() async {
    final expenses = ['Makanan', 'Transport', 'Belanja', 'Tagihan', 'Hiburan'];
    for (final name in expenses) {
      await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          type: 0,
          icon: 'assets/icons/expense.png',
          color: 0xFFF44336,
        ),
      );
    }

    final incomes = ['Gaji', 'Bonus', 'Investasi'];
    for (final name in incomes) {
      await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          type: 1,
          icon: 'assets/icons/income.png',
          color: 0xFF4CAF50,
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    // GANTI NAMA FILE JADI V3 AGAR DATABASE RESET
    final file = File(p.join(dbFolder.path, 'compound_me_v3.sqlite')); 
    return NativeDatabase.createInBackground(file);
  });
}