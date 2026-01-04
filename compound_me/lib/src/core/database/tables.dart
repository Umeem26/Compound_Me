import 'package:drift/drift.dart';

// 1. Tabel Dompet (Wallet)
// Contoh: Cash, BCA, GoPay
class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text()(); // Kita simpan kode icon string
  IntColumn get color => integer()(); // Kita simpan value warna (0xFF...)
  RealColumn get balance => real().withDefault(const Constant(0.0))();
}

// 2. Tabel Kategori (Categories)
// Contoh: Makanan (Expense), Gaji (Income)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get type => integer()(); // 0: Expense, 1: Income
  TextColumn get icon => text()();
  IntColumn get color => integer()();
}

// 3. Tabel Transaksi (Transactions)
// Mencatat uang masuk/keluar
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  
  // Relasi (Foreign Keys)
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get walletId => integer().references(Wallets, #id)();
}

// 4. Tabel Kebiasaan (Habits) -> Fitur Unik CompoundMe
// Disini kuncinya: Habit bisa punya "cost" (biaya).
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  
  // Kalau habit ini "Merokok", costPerUnit = 30000
  // Kalau habit ini "Lari Pagi", costPerUnit = 0
  RealColumn get costPerUnit => real().withDefault(const Constant(0.0))();
  
  // 0: Daily, 1: Weekly
  IntColumn get frequency => integer().withDefault(const Constant(0))(); 
  IntColumn get color => integer()();
}

// 5. Tabel Log Kebiasaan (HabitLogs)
// Mencatat setiap kali kamu mencentang habit
class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  DateTimeColumn get completedAt => dateTime()();
}