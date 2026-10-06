// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activeWallets)
final activeWalletsProvider = ActiveWalletsProvider._();

final class ActiveWalletsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WalletBalance>>,
          List<WalletBalance>,
          Stream<List<WalletBalance>>
        >
    with
        $FutureModifier<List<WalletBalance>>,
        $StreamProvider<List<WalletBalance>> {
  ActiveWalletsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeWalletsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeWalletsHash();

  @$internal
  @override
  $StreamProviderElement<List<WalletBalance>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WalletBalance>> create(Ref ref) {
    return activeWallets(ref);
  }
}

String _$activeWalletsHash() => r'ecda862ea38149faaafa51d9aa89a092400e4efc';

@ProviderFor(archivedWallets)
final archivedWalletsProvider = ArchivedWalletsProvider._();

final class ArchivedWalletsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Wallet>>,
          List<Wallet>,
          Stream<List<Wallet>>
        >
    with $FutureModifier<List<Wallet>>, $StreamProvider<List<Wallet>> {
  ArchivedWalletsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivedWalletsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivedWalletsHash();

  @$internal
  @override
  $StreamProviderElement<List<Wallet>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Wallet>> create(Ref ref) {
    return archivedWallets(ref);
  }
}

String _$archivedWalletsHash() => r'03dc6561145c6f3b1e80654f7aa09e5d93da27a1';

@ProviderFor(walletEditorSource)
final walletEditorSourceProvider = WalletEditorSourceFamily._();

final class WalletEditorSourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<WalletEditorSource?>,
          WalletEditorSource?,
          FutureOr<WalletEditorSource?>
        >
    with
        $FutureModifier<WalletEditorSource?>,
        $FutureProvider<WalletEditorSource?> {
  WalletEditorSourceProvider._({
    required WalletEditorSourceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletEditorSourceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletEditorSourceHash();

  @override
  String toString() {
    return r'walletEditorSourceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WalletEditorSource?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WalletEditorSource?> create(Ref ref) {
    final argument = this.argument as String;
    return walletEditorSource(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletEditorSourceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletEditorSourceHash() =>
    r'c1e186f18072477b66bfda15d6d93e895f58633e';

final class WalletEditorSourceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WalletEditorSource?>, String> {
  WalletEditorSourceFamily._()
    : super(
        retry: null,
        name: r'walletEditorSourceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WalletEditorSourceProvider call(String id) =>
      WalletEditorSourceProvider._(argument: id, from: this);

  @override
  String toString() => r'walletEditorSourceProvider';
}
