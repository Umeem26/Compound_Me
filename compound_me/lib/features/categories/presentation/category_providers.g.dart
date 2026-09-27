// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All categories of one kind, archived ones included, in display order.

@ProviderFor(categoriesOfKind)
final categoriesOfKindProvider = CategoriesOfKindFamily._();

/// All categories of one kind, archived ones included, in display order.

final class CategoriesOfKindProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  /// All categories of one kind, archived ones included, in display order.
  CategoriesOfKindProvider._({
    required CategoriesOfKindFamily super.from,
    required CategoryKind super.argument,
  }) : super(
         retry: null,
         name: r'categoriesOfKindProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoriesOfKindHash();

  @override
  String toString() {
    return r'categoriesOfKindProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    final argument = this.argument as CategoryKind;
    return categoriesOfKind(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesOfKindProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoriesOfKindHash() => r'0b7aef0446d413fffe551301420d35d9ffe56263';

/// All categories of one kind, archived ones included, in display order.

final class CategoriesOfKindFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Category>>, CategoryKind> {
  CategoriesOfKindFamily._()
    : super(
        retry: null,
        name: r'categoriesOfKindProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// All categories of one kind, archived ones included, in display order.

  CategoriesOfKindProvider call(CategoryKind kind) =>
      CategoriesOfKindProvider._(argument: kind, from: this);

  @override
  String toString() => r'categoriesOfKindProvider';
}

@ProviderFor(categoryEditorSource)
final categoryEditorSourceProvider = CategoryEditorSourceFamily._();

final class CategoryEditorSourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<CategoryEditorSource?>,
          CategoryEditorSource?,
          FutureOr<CategoryEditorSource?>
        >
    with
        $FutureModifier<CategoryEditorSource?>,
        $FutureProvider<CategoryEditorSource?> {
  CategoryEditorSourceProvider._({
    required CategoryEditorSourceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryEditorSourceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryEditorSourceHash();

  @override
  String toString() {
    return r'categoryEditorSourceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CategoryEditorSource?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CategoryEditorSource?> create(Ref ref) {
    final argument = this.argument as String;
    return categoryEditorSource(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryEditorSourceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryEditorSourceHash() =>
    r'11cf90597af050aadbd05420575827f75124f192';

final class CategoryEditorSourceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CategoryEditorSource?>, String> {
  CategoryEditorSourceFamily._()
    : super(
        retry: null,
        name: r'categoryEditorSourceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryEditorSourceProvider call(String id) =>
      CategoryEditorSourceProvider._(argument: id, from: this);

  @override
  String toString() => r'categoryEditorSourceProvider';
}
