// Drift's CHECK DSL references a column inside its own getter; that is a
// declaration for the code generator, not runtime recursion.
// ignore_for_file: recursive_getters

import 'package:compound_me/core/database/tables/habits.dart';
import 'package:compound_me/core/database/tables/sync_columns.dart';
import 'package:drift/drift.dart';

@DataClassName('HabitLogRow')
class HabitLogs extends Table with SyncColumns {
  /// Hard delete of a habit is only allowed while it has no logs; the
  /// cascade just keeps a failed guard from leaving orphans.
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();

  /// Local calendar day `YYYY-MM-DD`, not a timestamp (05 §3).
  TextColumn get date => text()();

  /// Occurrences that day; build habits always log 1.
  IntColumn get count => integer().check(count.isBiggerOrEqualValue(1))();

  /// Undone check-in. The row stays so restoring one of its expenses brings
  /// the same log back, and a new check-in that day reuses it (the
  /// `(habitId, date)` key stays unique). Treated as count 0.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {habitId, date},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]')",
  ];
}
