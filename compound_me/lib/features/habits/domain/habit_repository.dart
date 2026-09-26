import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/domain/habit.dart';

/// A habit with check-ins can only be archived, so its history and the
/// transactions it created stay intact (S-21). The same applies to
/// switching it between build and reduce.
class HabitHasLogsException implements Exception {
  const HabitHasLogsException(this.habitId);

  final String habitId;
}

abstract interface class HabitRepository {
  /// Occurrences a reduce habit can log on one day (Flow C stepper).
  static const maxDailyCount = 10;

  Stream<List<Habit>> watchHabits({bool includeArchived = false});

  Future<Habit?> findById(String id);

  Future<String> create(HabitDraft draft);

  Future<void> update(String id, HabitDraft draft);

  Future<void> reorder(List<String> orderedIds);

  Future<void> archive(String id);

  Future<void> unarchive(String id);

  Future<void> delete(String id);

  /// Logs of one habit, oldest first, optionally limited to [from]–[to].
  Stream<List<HabitLog>> watchLogs(
    String habitId, {
    LocalDate? from,
    LocalDate? to,
  });

  /// Logs of all habits on one day (home check-in strip).
  Stream<List<HabitLog>> watchLogsOn(LocalDate date);

  /// One-tap check-in: 0 → 1, and any count → 0 (tap again = undo). Atomic,
  /// and a second call while the first is still running returns the first
  /// call's result instead of toggling back. Returns the new count.
  Future<int> toggleCheckIn(String habitId, LocalDate date);

  /// Sets the occurrences on [date] (0 to [maxDailyCount] for reduce, 0 or
  /// 1 for build), adding or removing check-in expenses atomically.
  Future<int> setCount(String habitId, LocalDate date, int count);
}
