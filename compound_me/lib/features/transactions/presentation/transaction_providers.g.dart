// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recentTransactions)
final recentTransactionsProvider = RecentTransactionsProvider._();

final class RecentTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionListItem>>,
          List<TransactionListItem>,
          Stream<List<TransactionListItem>>
        >
    with
        $FutureModifier<List<TransactionListItem>>,
        $StreamProvider<List<TransactionListItem>> {
  RecentTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentTransactionsHash();

  @$internal
  @override
  $StreamProviderElement<List<TransactionListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionListItem>> create(Ref ref) {
    return recentTransactions(ref);
  }
}

String _$recentTransactionsHash() =>
    r'f999b801aab8c2fec6a1953f30c188ec7d8cf755';

/// Income and expense of what [filter] matches (S-10, S-13 summary).

@ProviderFor(transactionTotals)
final transactionTotalsProvider = TransactionTotalsFamily._();

/// Income and expense of what [filter] matches (S-10, S-13 summary).

final class TransactionTotalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PeriodTotals>,
          PeriodTotals,
          Stream<PeriodTotals>
        >
    with $FutureModifier<PeriodTotals>, $StreamProvider<PeriodTotals> {
  /// Income and expense of what [filter] matches (S-10, S-13 summary).
  TransactionTotalsProvider._({
    required TransactionTotalsFamily super.from,
    required TransactionFilter super.argument,
  }) : super(
         retry: null,
         name: r'transactionTotalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionTotalsHash();

  @override
  String toString() {
    return r'transactionTotalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PeriodTotals> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PeriodTotals> create(Ref ref) {
    final argument = this.argument as TransactionFilter;
    return transactionTotals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionTotalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionTotalsHash() => r'b562a690cac496224e3b9d3a41b0652de57c2383';

/// Income and expense of what [filter] matches (S-10, S-13 summary).

final class TransactionTotalsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PeriodTotals>, TransactionFilter> {
  TransactionTotalsFamily._()
    : super(
        retry: null,
        name: r'transactionTotalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Income and expense of what [filter] matches (S-10, S-13 summary).

  TransactionTotalsProvider call(TransactionFilter filter) =>
      TransactionTotalsProvider._(argument: filter, from: this);

  @override
  String toString() => r'transactionTotalsProvider';
}

/// The month of the oldest transaction, or null without any.

@ProviderFor(oldestTransactionMonth)
final oldestTransactionMonthProvider = OldestTransactionMonthProvider._();

/// The month of the oldest transaction, or null without any.

final class OldestTransactionMonthProvider
    extends
        $FunctionalProvider<
          AsyncValue<YearMonth?>,
          YearMonth?,
          Stream<YearMonth?>
        >
    with $FutureModifier<YearMonth?>, $StreamProvider<YearMonth?> {
  /// The month of the oldest transaction, or null without any.
  OldestTransactionMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oldestTransactionMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oldestTransactionMonthHash();

  @$internal
  @override
  $StreamProviderElement<YearMonth?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<YearMonth?> create(Ref ref) {
    return oldestTransactionMonth(ref);
  }
}

String _$oldestTransactionMonthHash() =>
    r'b71b9db59123ce3d5bc33ac2e48ca4559d8a2c4a';

/// Current balance of all active wallets.

@ProviderFor(totalBalance)
final totalBalanceProvider = TotalBalanceProvider._();

/// Current balance of all active wallets.

final class TotalBalanceProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Current balance of all active wallets.
  TotalBalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalBalanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalBalanceHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return totalBalance(ref);
  }
}

String _$totalBalanceHash() => r'2834e945e0c2375b6f011a80448e4443f8d15242';

/// History rows; [limit] pages search results across all months.

@ProviderFor(transactionHistory)
final transactionHistoryProvider = TransactionHistoryFamily._();

/// History rows; [limit] pages search results across all months.

final class TransactionHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionListItem>>,
          List<TransactionListItem>,
          Stream<List<TransactionListItem>>
        >
    with
        $FutureModifier<List<TransactionListItem>>,
        $StreamProvider<List<TransactionListItem>> {
  /// History rows; [limit] pages search results across all months.
  TransactionHistoryProvider._({
    required TransactionHistoryFamily super.from,
    required (TransactionFilter, int?) super.argument,
  }) : super(
         retry: null,
         name: r'transactionHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionHistoryHash();

  @override
  String toString() {
    return r'transactionHistoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<TransactionListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionListItem>> create(Ref ref) {
    final argument = this.argument as (TransactionFilter, int?);
    return transactionHistory(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionHistoryHash() =>
    r'c2de345ecbd5a03bea8abdc6d7ffa4a9c483f78c';

/// History rows; [limit] pages search results across all months.

final class TransactionHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<TransactionListItem>>,
          (TransactionFilter, int?)
        > {
  TransactionHistoryFamily._()
    : super(
        retry: null,
        name: r'transactionHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// History rows; [limit] pages search results across all months.

  TransactionHistoryProvider call(TransactionFilter filter, int? limit) =>
      TransactionHistoryProvider._(argument: (filter, limit), from: this);

  @override
  String toString() => r'transactionHistoryProvider';
}
