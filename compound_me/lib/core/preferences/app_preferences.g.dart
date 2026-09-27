// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appPreferences)
final appPreferencesProvider = AppPreferencesProvider._();

final class AppPreferencesProvider
    extends $FunctionalProvider<AppPreferences, AppPreferences, AppPreferences>
    with $Provider<AppPreferences> {
  AppPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPreferencesHash();

  @$internal
  @override
  $ProviderElement<AppPreferences> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppPreferences create(Ref ref) {
    return appPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPreferences>(value),
    );
  }
}

String _$appPreferencesHash() => r'bce2efe672b1db7c4fb836ca8628bd72865a5bbe';

/// Read at bootstrap so the chosen theme applies before the first frame.

@ProviderFor(ThemeModeSetting)
final themeModeSettingProvider = ThemeModeSettingProvider._();

/// Read at bootstrap so the chosen theme applies before the first frame.
final class ThemeModeSettingProvider
    extends $NotifierProvider<ThemeModeSetting, ThemeMode> {
  /// Read at bootstrap so the chosen theme applies before the first frame.
  ThemeModeSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeSettingHash();

  @$internal
  @override
  ThemeModeSetting create() => ThemeModeSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeSettingHash() => r'448d3f9a6e687ac92d6003e133244582492a0dcd';

/// Read at bootstrap so the chosen theme applies before the first frame.

abstract class _$ThemeModeSetting extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(LocaleSetting)
final localeSettingProvider = LocaleSettingProvider._();

final class LocaleSettingProvider
    extends $NotifierProvider<LocaleSetting, Locale?> {
  LocaleSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeSettingHash();

  @$internal
  @override
  LocaleSetting create() => LocaleSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeSettingHash() => r'6fa8fd8f4f9f2d67c5eda1340b307434ae64e9f3';

abstract class _$LocaleSetting extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale?, Locale?>,
              Locale?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether onboarding finished. The router sends everyone else to it.

@ProviderFor(OnboardingDone)
final onboardingDoneProvider = OnboardingDoneProvider._();

/// Whether onboarding finished. The router sends everyone else to it.
final class OnboardingDoneProvider
    extends $NotifierProvider<OnboardingDone, bool> {
  /// Whether onboarding finished. The router sends everyone else to it.
  OnboardingDoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingDoneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingDoneHash();

  @$internal
  @override
  OnboardingDone create() => OnboardingDone();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingDoneHash() => r'ad5cd20eb618b80b46f70b0582a48a5a9af75931';

/// Whether onboarding finished. The router sends everyone else to it.

abstract class _$OnboardingDone extends $Notifier<bool> {
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

/// The name used to greet the user (onboarding, S-40).

@ProviderFor(UserName)
final userNameProvider = UserNameProvider._();

/// The name used to greet the user (onboarding, S-40).
final class UserNameProvider extends $NotifierProvider<UserName, String> {
  /// The name used to greet the user (onboarding, S-40).
  UserNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userNameProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userNameHash();

  @$internal
  @override
  UserName create() => UserName();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userNameHash() => r'9497ac08233810431ebdad5bf13e120eee4bc8f0';

/// The name used to greet the user (onboarding, S-40).

abstract class _$UserName extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Flow A ends with a one-time hint on the add button.

@ProviderFor(AddCoachMarkSeen)
final addCoachMarkSeenProvider = AddCoachMarkSeenProvider._();

/// Flow A ends with a one-time hint on the add button.
final class AddCoachMarkSeenProvider
    extends $NotifierProvider<AddCoachMarkSeen, bool> {
  /// Flow A ends with a one-time hint on the add button.
  AddCoachMarkSeenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addCoachMarkSeenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addCoachMarkSeenHash();

  @$internal
  @override
  AddCoachMarkSeen create() => AddCoachMarkSeen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$addCoachMarkSeenHash() => r'e55ab4e44be58eafcadf2c580912f1a933dded3b';

/// Flow A ends with a one-time hint on the add button.

abstract class _$AddCoachMarkSeen extends $Notifier<bool> {
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
