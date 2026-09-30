// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_editor_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitEditorSource)
final habitEditorSourceProvider = HabitEditorSourceFamily._();

final class HabitEditorSourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<HabitEditorSource>,
          HabitEditorSource,
          FutureOr<HabitEditorSource>
        >
    with
        $FutureModifier<HabitEditorSource>,
        $FutureProvider<HabitEditorSource> {
  HabitEditorSourceProvider._({
    required HabitEditorSourceFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'habitEditorSourceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitEditorSourceHash();

  @override
  String toString() {
    return r'habitEditorSourceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HabitEditorSource> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HabitEditorSource> create(Ref ref) {
    final argument = this.argument as String?;
    return habitEditorSource(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitEditorSourceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitEditorSourceHash() => r'0e55c5618113982cd2fc52c9f7e61f29e0fc2c79';

final class HabitEditorSourceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HabitEditorSource>, String?> {
  HabitEditorSourceFamily._()
    : super(
        retry: null,
        name: r'habitEditorSourceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitEditorSourceProvider call(String? id) =>
      HabitEditorSourceProvider._(argument: id, from: this);

  @override
  String toString() => r'habitEditorSourceProvider';
}
