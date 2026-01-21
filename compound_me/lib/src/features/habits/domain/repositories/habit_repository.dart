import 'package:compound_me/src/core/database/app_database.dart';

abstract class HabitRepository {
  // Ambil semua daftar kebiasaan
  Future<List<Habit>> getHabits();
  
  // Tambah kebiasaan baru
  Future<int> addHabit(HabitsCompanion habit);
  
  // Hapus
  Future<int> deleteHabit(int id);

  // --- LOG KEBIASAAN (Checklist Harian) ---
  // Mencatat hari ini sudah melakukan habit apa saja
  Future<int> logHabit(HabitLogsCompanion log);
  
  // Ambil log hari ini (biar tahu mana yang sudah dicentang)
  Future<List<HabitLog>> getHabitLogsByDate(DateTime date);
}