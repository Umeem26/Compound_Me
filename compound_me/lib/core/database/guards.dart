import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:drift/drift.dart';

/// Shared checks for repositories, meant to run inside `db.transaction`.
extension RepositoryGuards on AppDatabase {
  /// Whether any row of [table] has [column] = [id]. Table and column are
  /// fixed names from repository code, never user input.
  Future<bool> isReferenced(String table, String column, String id) async {
    final row = await customSelect(
      'SELECT EXISTS(SELECT 1 FROM $table WHERE $column = ?) AS used',
      variables: [Variable.withString(id)],
    ).getSingle();
    return row.read<bool>('used');
  }
}

/// Trims [name] and checks its length, returning the trimmed value.
String validName(String name, {required int maxLength}) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    throw const ValidationException(ValidationError.nameEmpty);
  }
  if (trimmed.length > maxLength) {
    throw const ValidationException(ValidationError.nameTooLong);
  }
  return trimmed;
}
