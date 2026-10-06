// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_onboarding_setup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingSetup)
final onboardingSetupProvider = OnboardingSetupProvider._();

final class OnboardingSetupProvider
    extends
        $FunctionalProvider<OnboardingSetup, OnboardingSetup, OnboardingSetup>
    with $Provider<OnboardingSetup> {
  OnboardingSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingSetupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingSetupHash();

  @$internal
  @override
  $ProviderElement<OnboardingSetup> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OnboardingSetup create(Ref ref) {
    return onboardingSetup(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingSetup value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingSetup>(value),
    );
  }
}

String _$onboardingSetupHash() => r'a91de509213511e934eeda18bcd7e5011f2ced59';
