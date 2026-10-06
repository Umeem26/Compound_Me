// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firstTransactionAt)
final firstTransactionAtProvider = FirstTransactionAtProvider._();

final class FirstTransactionAtProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime?>, DateTime?, Stream<DateTime?>>
    with $FutureModifier<DateTime?>, $StreamProvider<DateTime?> {
  FirstTransactionAtProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstTransactionAtProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstTransactionAtHash();

  @$internal
  @override
  $StreamProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime?> create(Ref ref) {
    return firstTransactionAt(ref);
  }
}

String _$firstTransactionAtHash() =>
    r'231ec19d2c6314237adbeddf39ad346592b92f1b';

/// Days since the first transaction or check-in, today included (0 without
/// any). S-30 and the Home insight wait for seven.

@ProviderFor(recordedDays)
final recordedDaysProvider = RecordedDaysProvider._();

/// Days since the first transaction or check-in, today included (0 without
/// any). S-30 and the Home insight wait for seven.

final class RecordedDaysProvider
    extends
        $FunctionalProvider<AsyncValue<int>, AsyncValue<int>, AsyncValue<int>>
    with $Provider<AsyncValue<int>> {
  /// Days since the first transaction or check-in, today included (0 without
  /// any). S-30 and the Home insight wait for seven.
  RecordedDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordedDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordedDaysHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<int> create(Ref ref) {
    return recordedDays(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<int>>(value),
    );
  }
}

String _$recordedDaysHash() => r'd84157e248411a3fb99962c78d4788c76d01569a';

/// The numbers of S-30 for one month.

@ProviderFor(monthInsights)
final monthInsightsProvider = MonthInsightsFamily._();

/// The numbers of S-30 for one month.

final class MonthInsightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<MonthInsights>,
          AsyncValue<MonthInsights>,
          AsyncValue<MonthInsights>
        >
    with $Provider<AsyncValue<MonthInsights>> {
  /// The numbers of S-30 for one month.
  MonthInsightsProvider._({
    required MonthInsightsFamily super.from,
    required YearMonth super.argument,
  }) : super(
         retry: null,
         name: r'monthInsightsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthInsightsHash();

  @override
  String toString() {
    return r'monthInsightsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<MonthInsights>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MonthInsights> create(Ref ref) {
    final argument = this.argument as YearMonth;
    return monthInsights(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MonthInsights> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MonthInsights>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MonthInsightsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthInsightsHash() => r'd7614160fa5d2ff12c4b3dd483295248f508445d';

/// The numbers of S-30 for one month.

final class MonthInsightsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<MonthInsights>, YearMonth> {
  MonthInsightsFamily._()
    : super(
        retry: null,
        name: r'monthInsightsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The numbers of S-30 for one month.

  MonthInsightsProvider call(YearMonth month) =>
      MonthInsightsProvider._(argument: month, from: this);

  @override
  String toString() => r'monthInsightsProvider';
}

/// The single insight card of Home (S-10), or null when nothing applies.

@ProviderFor(homeInsight)
final homeInsightProvider = HomeInsightProvider._();

/// The single insight card of Home (S-10), or null when nothing applies.

final class HomeInsightProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeInsight?>,
          AsyncValue<HomeInsight?>,
          AsyncValue<HomeInsight?>
        >
    with $Provider<AsyncValue<HomeInsight?>> {
  /// The single insight card of Home (S-10), or null when nothing applies.
  HomeInsightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeInsightProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeInsightHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<HomeInsight?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<HomeInsight?> create(Ref ref) {
    return homeInsight(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<HomeInsight?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<HomeInsight?>>(value),
    );
  }
}

String _$homeInsightHash() => r'ce80b2fa06631e469a90d39ddfd1a0f6f2b3a3b8';
