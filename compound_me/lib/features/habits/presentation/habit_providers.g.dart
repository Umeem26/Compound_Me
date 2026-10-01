// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitList)
final habitListProvider = HabitListFamily._();

final class HabitListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Habit>>,
          List<Habit>,
          Stream<List<Habit>>
        >
    with $FutureModifier<List<Habit>>, $StreamProvider<List<Habit>> {
  HabitListProvider._({
    required HabitListFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'habitListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitListHash();

  @override
  String toString() {
    return r'habitListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Habit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Habit>> create(Ref ref) {
    final argument = this.argument as bool;
    return habitList(ref, includeArchived: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitListHash() => r'c379b4f531c11f68eb0b4427156f158fefca52e8';

final class HabitListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Habit>>, bool> {
  HabitListFamily._()
    : super(
        retry: null,
        name: r'habitListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitListProvider call({bool includeArchived = false}) =>
      HabitListProvider._(argument: includeArchived, from: this);

  @override
  String toString() => r'habitListProvider';
}

@ProviderFor(allHabitLogs)
final allHabitLogsProvider = AllHabitLogsProvider._();

final class AllHabitLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitLog>>,
          List<HabitLog>,
          Stream<List<HabitLog>>
        >
    with $FutureModifier<List<HabitLog>>, $StreamProvider<List<HabitLog>> {
  AllHabitLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allHabitLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allHabitLogsHash();

  @$internal
  @override
  $StreamProviderElement<List<HabitLog>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitLog>> create(Ref ref) {
    return allHabitLogs(ref);
  }
}

String _$allHabitLogsHash() => r'156ff15bd023f6fb4c44149b0a944309364d6a94';

/// Every habit (archived ones too) with today's count, the week so far and
/// its streak, in display order. Moves on with "today" (nowProvider).

@ProviderFor(habitProgress)
final habitProgressProvider = HabitProgressProvider._();

/// Every habit (archived ones too) with today's count, the week so far and
/// its streak, in display order. Moves on with "today" (nowProvider).

final class HabitProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitProgress>>,
          AsyncValue<List<HabitProgress>>,
          AsyncValue<List<HabitProgress>>
        >
    with $Provider<AsyncValue<List<HabitProgress>>> {
  /// Every habit (archived ones too) with today's count, the week so far and
  /// its streak, in display order. Moves on with "today" (nowProvider).
  HabitProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitProgressHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<HabitProgress>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<HabitProgress>> create(Ref ref) {
    return habitProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<HabitProgress>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<HabitProgress>>>(
        value,
      ),
    );
  }
}

String _$habitProgressHash() => r'b1b0f642ed9a40a83ea8f3f547d040bfcef2eb3c';

/// One habit's progress for its detail (S-22), or null once it is gone.

@ProviderFor(habitDetail)
final habitDetailProvider = HabitDetailFamily._();

/// One habit's progress for its detail (S-22), or null once it is gone.

final class HabitDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<HabitProgress?>,
          AsyncValue<HabitProgress?>,
          AsyncValue<HabitProgress?>
        >
    with $Provider<AsyncValue<HabitProgress?>> {
  /// One habit's progress for its detail (S-22), or null once it is gone.
  HabitDetailProvider._({
    required HabitDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitDetailHash();

  @override
  String toString() {
    return r'habitDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<HabitProgress?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<HabitProgress?> create(Ref ref) {
    final argument = this.argument as String;
    return habitDetail(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<HabitProgress?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<HabitProgress?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HabitDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitDetailHash() => r'58936ef8f7dca2bdf82219148212ab2d1c624473';

/// One habit's progress for its detail (S-22), or null once it is gone.

final class HabitDetailFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<HabitProgress?>, String> {
  HabitDetailFamily._()
    : super(
        retry: null,
        name: r'habitDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One habit's progress for its detail (S-22), or null once it is gone.

  HabitDetailProvider call(String id) =>
      HabitDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'habitDetailProvider';
}

@ProviderFor(habitLogs)
final habitLogsProvider = HabitLogsFamily._();

final class HabitLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitLog>>,
          List<HabitLog>,
          Stream<List<HabitLog>>
        >
    with $FutureModifier<List<HabitLog>>, $StreamProvider<List<HabitLog>> {
  HabitLogsProvider._({
    required HabitLogsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitLogsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitLogsHash();

  @override
  String toString() {
    return r'habitLogsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<HabitLog>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitLog>> create(Ref ref) {
    final argument = this.argument as String;
    return habitLogs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitLogsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitLogsHash() => r'5fdb6814708cc05b286976dfb9339cc6f2bb7b0d';

final class HabitLogsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<HabitLog>>, String> {
  HabitLogsFamily._()
    : super(
        retry: null,
        name: r'habitLogsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitLogsProvider call(String id) =>
      HabitLogsProvider._(argument: id, from: this);

  @override
  String toString() => r'habitLogsProvider';
}

@ProviderFor(habitCheckIns)
final habitCheckInsProvider = HabitCheckInsFamily._();

final class HabitCheckInsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitCheckIn>>,
          List<HabitCheckIn>,
          Stream<List<HabitCheckIn>>
        >
    with
        $FutureModifier<List<HabitCheckIn>>,
        $StreamProvider<List<HabitCheckIn>> {
  HabitCheckInsProvider._({
    required HabitCheckInsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitCheckInsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitCheckInsHash();

  @override
  String toString() {
    return r'habitCheckInsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<HabitCheckIn>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitCheckIn>> create(Ref ref) {
    final argument = this.argument as String;
    return habitCheckIns(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitCheckInsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitCheckInsHash() => r'35d61b489c8e752ca2cd2e55ce17c91babcdb9fb';

final class HabitCheckInsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<HabitCheckIn>>, String> {
  HabitCheckInsFamily._()
    : super(
        retry: null,
        name: r'habitCheckInsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitCheckInsProvider call(String id) =>
      HabitCheckInsProvider._(argument: id, from: this);

  @override
  String toString() => r'habitCheckInsProvider';
}

/// Money a reduce habit took this month (S-22 cost card).

@ProviderFor(habitSpentThisMonth)
final habitSpentThisMonthProvider = HabitSpentThisMonthFamily._();

/// Money a reduce habit took this month (S-22 cost card).

final class HabitSpentThisMonthProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Money a reduce habit took this month (S-22 cost card).
  HabitSpentThisMonthProvider._({
    required HabitSpentThisMonthFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitSpentThisMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitSpentThisMonthHash();

  @override
  String toString() {
    return r'habitSpentThisMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return habitSpentThisMonth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitSpentThisMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitSpentThisMonthHash() =>
    r'2136ec4b95adc8d7bcedad6bc6a0ec24eec6820e';

/// Money a reduce habit took this month (S-22 cost card).

final class HabitSpentThisMonthFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  HabitSpentThisMonthFamily._()
    : super(
        retry: null,
        name: r'habitSpentThisMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Money a reduce habit took this month (S-22 cost card).

  HabitSpentThisMonthProvider call(String id) =>
      HabitSpentThisMonthProvider._(argument: id, from: this);

  @override
  String toString() => r'habitSpentThisMonthProvider';
}
