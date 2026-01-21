import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/features/habits/data/repositories/habit_repository_impl.dart';

part 'habit_controller.g.dart';

// 1. Provider: Mengambil Daftar Semua Kebiasaan
@riverpod
class HabitList extends _$HabitList {
  @override
  Future<List<Habit>> build() async {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getHabits();
  }

  // Tambah Kebiasaan Baru
  Future<void> addHabit({
    required String name,
    required double cost,
    required int color,
  }) async {
    final repo = ref.read(habitRepositoryProvider);
    
    await repo.addHabit(HabitsCompanion.insert(
      name: name,
      costPerUnit: Value(cost), // Kalau 0 berarti habit gratis (misal: Lari)
      color: color,
      frequency: const Value(0), // 0 = Daily (Default dulu)
    ));

    ref.invalidateSelf(); // Refresh list
  }

  // Hapus Kebiasaan
  Future<void> deleteHabit(int id) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.deleteHabit(id);
    ref.invalidateSelf();
  }
}

// 2. Provider: Mengambil "Checklist" Hari Ini
// Ini penting agar besok paginya, centangannya reset (kosong lagi).
@riverpod
class TodayHabitLogs extends _$TodayHabitLogs {
  @override
  Future<List<HabitLog>> build() async {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getHabitLogsByDate(DateTime.now());
  }

  // Fungsi: CENTANG KEBIASAAN
  Future<void> checkHabit(Habit habit) async {
    final repo = ref.read(habitRepositoryProvider);
    
    // 1. Catat di database bahwa hari ini sudah dikerjakan
    await repo.logHabit(HabitLogsCompanion.insert(
      habitId: habit.id,
      completedAt: DateTime.now(),
    ));

    // 2. Refresh agar UI checklist berubah jadi hijau
    ref.invalidateSelf();

    // --- FITUR MASA DEPAN ---
    // Di sinilah nanti kita akan tambahkan logika: 
    // "Jika habit.cost > 0, potong saldo dompet otomatis"
    // Kita simpan dulu logika itu untuk fase selanjutnya.
  }
}