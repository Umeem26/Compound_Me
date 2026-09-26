import 'package:compound_me/features/categories/domain/category.dart';

/// A category used by a transaction or a habit can only be archived, not
/// deleted (PRD F-07).
class CategoryInUseException implements Exception {
  const CategoryInUseException(this.categoryId);

  final String categoryId;
}

abstract interface class CategoryRepository {
  /// Categories of one kind in display order.
  Stream<List<Category>> watch(
    CategoryKind kind, {
    bool includeArchived = false,
  });

  Future<Category?> findById(String id);

  /// Whether any transaction (deleted ones included) or habit uses it.
  Future<bool> isInUse(String id);

  /// Adds a custom category with a user-typed name.
  Future<String> create(CategoryDraft draft);

  /// Changes icon and color of any category, and the name of custom ones.
  /// The kind never changes because transactions depend on it.
  Future<void> update(
    String id, {
    String? name,
    String? iconKey,
    String? colorKey,
  });

  Future<void> reorder(List<String> orderedIds);

  Future<void> archive(String id);

  Future<void> unarchive(String id);

  Future<void> delete(String id);
}
