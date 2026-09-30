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

@ProviderFor(monthTotals)
final monthTotalsProvider = MonthTotalsFamily._();

final class MonthTotalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PeriodTotals>,
          PeriodTotals,
          Stream<PeriodTotals>
        >
    with $FutureModifier<PeriodTotals>, $StreamProvider<PeriodTotals> {
  MonthTotalsProvider._({
    required MonthTotalsFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'monthTotalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthTotalsHash();

  @override
  String toString() {
    return r'monthTotalsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<PeriodTotals> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PeriodTotals> create(Ref ref) {
    final argument = this.argument as (int, int);
    return monthTotals(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthTotalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthTotalsHash() => r'15e55a4be59dfaa941e25b17c7920c0eb06f1760';

final class MonthTotalsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PeriodTotals>, (int, int)> {
  MonthTotalsFamily._()
    : super(
        retry: null,
        name: r'monthTotalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthTotalsProvider call(int year, int month) =>
      MonthTotalsProvider._(argument: (year, month), from: this);

  @override
  String toString() => r'monthTotalsProvider';
}

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

@ProviderFor(transactionHistory)
final transactionHistoryProvider = TransactionHistoryFamily._();

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
  TransactionHistoryProvider._({
    required TransactionHistoryFamily super.from,
    required TransactionFilter super.argument,
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
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TransactionListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionListItem>> create(Ref ref) {
    final argument = this.argument as TransactionFilter;
    return transactionHistory(ref, argument);
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
    r'd848e0c70924b9a136c7efad0fd57cd551bbf2bc';

final class TransactionHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<TransactionListItem>>,
          TransactionFilter
        > {
  TransactionHistoryFamily._()
    : super(
        retry: null,
        name: r'transactionHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionHistoryProvider call(TransactionFilter filter) =>
      TransactionHistoryProvider._(argument: filter, from: this);

  @override
  String toString() => r'transactionHistoryProvider';
}
