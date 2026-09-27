// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "1.0.0 (1)": version name and build number from the platform.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// "1.0.0 (1)": version name and build number from the platform.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// "1.0.0 (1)": version name and build number from the platform.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'ff1eb5d2af994c051622516f93f238f401bb6abc';

/// Deletes all data and settings, then lets the router send the user back
/// to onboarding, as after a fresh install.

@ProviderFor(DeleteAllData)
final deleteAllDataProvider = DeleteAllDataProvider._();

/// Deletes all data and settings, then lets the router send the user back
/// to onboarding, as after a fresh install.
final class DeleteAllDataProvider
    extends $NotifierProvider<DeleteAllData, void> {
  /// Deletes all data and settings, then lets the router send the user back
  /// to onboarding, as after a fresh install.
  DeleteAllDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAllDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAllDataHash();

  @$internal
  @override
  DeleteAllData create() => DeleteAllData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$deleteAllDataHash() => r'3095bb3d4af8626f9791ad633beac99d297ee29a';

/// Deletes all data and settings, then lets the router send the user back
/// to onboarding, as after a fresh install.

abstract class _$DeleteAllData extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
