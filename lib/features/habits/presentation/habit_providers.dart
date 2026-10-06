import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_progress.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_providers.g.dart';

@riverpod
Stream<List<Habit>> habitList(Ref ref, {bool includeArchived = false}) => ref
    .watch(habitRepositoryProvider)
    .watchHabits(includeArchived: includeArchived);

@riverpod
Stream<List<HabitLog>> allHabitLogs(Ref ref) =>
    ref.watch(habitRepositoryProvider).watchAllLogs();

/// Every habit (archived ones too) with today's count, the week so far and
/// its streak, in display order. Moves on with "today" (nowProvider).
@riverpod
AsyncValue<List<HabitProgress>> habitProgress(Ref ref) {
  final habits = ref.watch(habitListProvider(includeArchived: true));
  final logs = ref.watch(allHabitLogsProvider);
  final today = LocalDate.fromDateTime(ref.watch(nowProvider));
  if (habits case AsyncData(value: final list)) {
    if (logs case AsyncData(value: final all)) {
      return AsyncData([for (final h in list) progressOf(h, all, today)]);
    }
  }
  if (habits case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  if (logs case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  return const AsyncLoading();
}

/// One habit's progress for its detail (S-22), or null once it is gone.
@riverpod
AsyncValue<HabitProgress?> habitDetail(Ref ref, String id) =>
    ref.watch(habitProgressProvider).whenData((all) {
      for (final p in all) {
        if (p.habit.id == id) return p;
      }
      return null;
    });

@riverpod
Stream<List<HabitLog>> habitLogs(Ref ref, String id) =>
    ref.watch(habitRepositoryProvider).watchLogs(id);

@riverpod
Stream<List<HabitCheckIn>> habitCheckIns(Ref ref, String id) =>
    ref.watch(habitRepositoryProvider).watchCheckIns(id);

/// Money a reduce habit took this month (S-22 cost card).
@riverpod
Stream<int> habitSpentThisMonth(Ref ref, String id) {
  final today = LocalDate.fromDateTime(ref.watch(nowProvider));
  return ref
      .watch(habitRepositoryProvider)
      .watchSpent(id, from: LocalDate(today.year, today.month, 1), to: today);
}
