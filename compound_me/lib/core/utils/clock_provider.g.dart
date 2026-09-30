// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The raw clock, overridable in tests. Screens watch [nowProvider].

@ProviderFor(clock)
final clockProvider = ClockProvider._();

/// The raw clock, overridable in tests. Screens watch [nowProvider].

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  /// The raw clock, overridable in tests. Screens watch [nowProvider].
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'b2969fc7f5261f62137e0cfbaf5eccd68cd4516e';

/// Local "now" for screens: greeting, "Hari ini"/"Kemarin", the default
/// month of Home and history, and the default date of a new transaction.
/// It moves on by itself when the app comes back to the foreground and at
/// the next local midnight, so an app left open overnight shows the new
/// day. The greeting's hours (04, 10, 15, 18) count as boundaries too.

@ProviderFor(Now)
final nowProvider = NowProvider._();

/// Local "now" for screens: greeting, "Hari ini"/"Kemarin", the default
/// month of Home and history, and the default date of a new transaction.
/// It moves on by itself when the app comes back to the foreground and at
/// the next local midnight, so an app left open overnight shows the new
/// day. The greeting's hours (04, 10, 15, 18) count as boundaries too.
final class NowProvider extends $NotifierProvider<Now, DateTime> {
  /// Local "now" for screens: greeting, "Hari ini"/"Kemarin", the default
  /// month of Home and history, and the default date of a new transaction.
  /// It moves on by itself when the app comes back to the foreground and at
  /// the next local midnight, so an app left open overnight shows the new
  /// day. The greeting's hours (04, 10, 15, 18) count as boundaries too.
  NowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowHash();

  @$internal
  @override
  Now create() => Now();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$nowHash() => r'b2db3cee872bb082981fa807d3c95ef65c76267c';

/// Local "now" for screens: greeting, "Hari ini"/"Kemarin", the default
/// month of Home and history, and the default date of a new transaction.
/// It moves on by itself when the app comes back to the foreground and at
/// the next local midnight, so an app left open overnight shows the new
/// day. The greeting's hours (04, 10, 15, 18) count as boundaries too.

abstract class _$Now extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
