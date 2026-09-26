import 'package:meta/meta.dart';

enum CategoryKind { expense, income }

@immutable
class Category {
  const Category({
    required this.id,
    required this.kind,
    required this.iconKey,
    required this.colorKey,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.nameKey,
    this.customName,
    this.archivedAt,
  }) : assert(
         (nameKey == null) != (customName == null),
         'Exactly one of nameKey and customName is set',
       );

  final String id;
  final CategoryKind kind;

  /// l10n key for a default category (e.g. `catFood`); null for custom ones.
  final String? nameKey;

  /// Name typed by the user; null for default categories.
  final String? customName;
  final String iconKey;
  final String colorKey;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isDefault => nameKey != null;
  bool get isArchived => archivedAt != null;
}

/// Editable fields of a custom category.
@immutable
class CategoryDraft {
  const CategoryDraft({
    required this.kind,
    required this.name,
    required this.iconKey,
    required this.colorKey,
  });

  final CategoryKind kind;
  final String name;
  final String iconKey;
  final String colorKey;
}
