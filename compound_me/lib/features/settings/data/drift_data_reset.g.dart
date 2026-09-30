// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_data_reset.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dataReset)
final dataResetProvider = DataResetProvider._();

final class DataResetProvider
    extends $FunctionalProvider<DataReset, DataReset, DataReset>
    with $Provider<DataReset> {
  DataResetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataResetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataResetHash();

  @$internal
  @override
  $ProviderElement<DataReset> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataReset create(Ref ref) {
    return dataReset(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataReset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataReset>(value),
    );
  }
}

String _$dataResetHash() => r'0170ec6d80ba5eeffa95466ca012b5a1c17a7f95';
