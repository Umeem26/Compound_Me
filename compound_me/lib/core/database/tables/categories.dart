// Drift's CHECK DSL references a column inside its own getter; that is a
// declaration for the code generator, not runtime recursion.
// ignore_for_file: recursive_getters

import 'package:compound_me/core/database/tables/sync_columns.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:drift/drift.dart';

@DataClassName('CategoryRow')
class Categories extends Table with SyncColumns {
  TextColumn get kind => textEnum<CategoryKind>().check(
    kind.isIn(CategoryKind.values.map((k) => k.name)),
  )();

  /// l10n key of a default category, e.g. `catFood`.
  TextColumn get nameKey => text().nullable()();
  TextColumn get customName =>
      text().nullable().check(customName.length.isBetweenValues(1, 30))();
  TextColumn get iconKey => text()();
  TextColumn get colorKey => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => [
    // A category is either a translated default or a user-named custom one.
    'CHECK ((name_key IS NULL) <> (custom_name IS NULL))',
  ];
}
