import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/core/database/database_provider.dart';
import '../../domain/repositories/habit_repository.dart';

part 'habit_repository_impl.g.dart';

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase _db;

  HabitRepositoryImpl(this._db);

  @override
  Future<List<Habit>> getHabits() async {
    return await _db.select(_db.habits).get();
  }

  @override
  Future<int> addHabit(HabitsCompanion habit) async {
    return await _db.into(_db.habits).insert(habit);
  }

  @override
  Future<int> deleteHabit(int id) async {
    return await (_db.delete(_db.habits)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- LOGIC LOG HABIT ---
  @override
  Future<int> logHabit(HabitLogsCompanion log) async {
    return await _db.into(_db.habitLogs).insert(log);
  }

  @override
  Future<List<HabitLog>> getHabitLogsByDate(DateTime date) async {
    // Ambil log spesifik di tanggal tersebut (00:00 - 23:59)
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await (_db.select(_db.habitLogs)
      ..where((tbl) => tbl.completedAt.isBetweenValues(start, end)))
      .get();
  }
}

// --- PROVIDER ---
@riverpod
HabitRepository habitRepository(HabitRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return HabitRepositoryImpl(db);
}