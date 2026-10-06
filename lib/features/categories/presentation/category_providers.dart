import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_providers.g.dart';

/// All categories of one kind, archived ones included, in display order.
@riverpod
Stream<List<Category>> categoriesOfKind(Ref ref, CategoryKind kind) =>
    ref.watch(categoryRepositoryProvider).watch(kind, includeArchived: true);

/// The category and whether archive or delete applies (S-42).
typedef CategoryEditorSource = ({Category category, bool inUse});

@riverpod
Future<CategoryEditorSource?> categoryEditorSource(Ref ref, String id) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final category = await repository.findById(id);
  if (category == null) return null;
  return (category: category, inUse: await repository.isInUse(id));
}
