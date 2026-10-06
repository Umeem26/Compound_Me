// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_sample_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(debugSampleData)
final debugSampleDataProvider = DebugSampleDataProvider._();

final class DebugSampleDataProvider
    extends
        $FunctionalProvider<DebugSampleData, DebugSampleData, DebugSampleData>
    with $Provider<DebugSampleData> {
  DebugSampleDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugSampleDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugSampleDataHash();

  @$internal
  @override
  $ProviderElement<DebugSampleData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DebugSampleData create(Ref ref) {
    return debugSampleData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DebugSampleData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DebugSampleData>(value),
    );
  }
}

String _$debugSampleDataHash() => r'28e00e5ecb8f0e87569a6fb9d1ce79a72433ce57';
