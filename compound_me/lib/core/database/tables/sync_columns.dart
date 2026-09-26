import 'package:drift/drift.dart';

/// Columns every table carries to prepare for cloud sync (05 §8): a UUID
/// primary key and UTC timestamps.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
