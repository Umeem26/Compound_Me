// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitListHash() => r'98c24d535f58a0b9fc1d64cceccbb59c4dde1aa8';

/// See also [HabitList].
@ProviderFor(HabitList)
final habitListProvider =
    AutoDisposeAsyncNotifierProvider<HabitList, List<Habit>>.internal(
  HabitList.new,
  name: r'habitListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$habitListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HabitList = AutoDisposeAsyncNotifier<List<Habit>>;
String _$todayHabitLogsHash() => r'bde6bebd01afbb3034a3a10028d10bdb4f4fe535';

/// See also [TodayHabitLogs].
@ProviderFor(TodayHabitLogs)
final todayHabitLogsProvider =
    AutoDisposeAsyncNotifierProvider<TodayHabitLogs, List<HabitLog>>.internal(
  TodayHabitLogs.new,
  name: r'todayHabitLogsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayHabitLogsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodayHabitLogs = AutoDisposeAsyncNotifier<List<HabitLog>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
