// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_visibility.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether balances are hidden right now, on Home (S-10) and Wallets
/// (S-41) alike. Each app launch starts from the "Sembunyikan saldo"
/// setting (S-43); the eye only changes it for this session, never the
/// setting itself.

@ProviderFor(BalanceHidden)
final balanceHiddenProvider = BalanceHiddenProvider._();

/// Whether balances are hidden right now, on Home (S-10) and Wallets
/// (S-41) alike. Each app launch starts from the "Sembunyikan saldo"
/// setting (S-43); the eye only changes it for this session, never the
/// setting itself.
final class BalanceHiddenProvider
    extends $NotifierProvider<BalanceHidden, bool> {
  /// Whether balances are hidden right now, on Home (S-10) and Wallets
  /// (S-41) alike. Each app launch starts from the "Sembunyikan saldo"
  /// setting (S-43); the eye only changes it for this session, never the
  /// setting itself.
  BalanceHiddenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'balanceHiddenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$balanceHiddenHash();

  @$internal
  @override
  BalanceHidden create() => BalanceHidden();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$balanceHiddenHash() => r'b8da50a5630c317b7d7167c3f98b2ff5d5c518b1';

/// Whether balances are hidden right now, on Home (S-10) and Wallets
/// (S-41) alike. Each app launch starts from the "Sembunyikan saldo"
/// setting (S-43); the eye only changes it for this session, never the
/// setting itself.

abstract class _$BalanceHidden extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
