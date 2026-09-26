// Drift's CHECK DSL references a column inside its own getter; that is a
// declaration for the code generator, not runtime recursion.
// ignore_for_file: recursive_getters

import 'package:compound_me/core/database/tables/categories.dart';
import 'package:compound_me/core/database/tables/sync_columns.dart';
import 'package:compound_me/core/database/tables/wallets.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:drift/drift.dart';

@DataClassName('HabitRow')
class Habits extends Table with SyncColumns {
  TextColumn get name => text().check(name.length.isBetweenValues(1, 40))();
  TextColumn get kind => textEnum<HabitKind>().check(
    kind.isIn(HabitKind.values.map((k) => k.name)),
  )();
  TextColumn get iconKey => text()();
  TextColumn get colorKey => text()();
  TextColumn get scheduleType => textEnum<ScheduleType>().check(
    scheduleType.isIn(ScheduleType.values.map((s) => s.name)),
  )();

  /// Weekdays bitmask, Monday = 1 ... Sunday = 64.
  IntColumn get scheduleDays => integer()
      .withDefault(const Constant(0))
      .check(scheduleDays.isBetweenValues(0, Weekdays.all))();
  IntColumn get timesPerWeek =>
      integer().nullable().check(timesPerWeek.isBetweenValues(1, 7))();
  IntColumn get costPerOccurrence =>
      integer().nullable().check(costPerOccurrence.isBiggerThanValue(0))();
  TextColumn get walletId => text().nullable().references(
    Wallets,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.restrict,
  )();
  IntColumn get weeklyLimit =>
      integer().nullable().check(weeklyLimit.isBiggerOrEqualValue(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => [
    // Reduce habits turn every check-in into an expense, so they need a
    // cost, a wallet and a category (the category kind is checked in Dart).
    "CHECK (kind <> 'reduce' OR cost_per_occurrence IS NOT NULL)",
    "CHECK (kind <> 'reduce' OR wallet_id IS NOT NULL)",
    "CHECK (kind <> 'reduce' OR category_id IS NOT NULL)",
    "CHECK (schedule_type <> 'weekdays' OR schedule_days > 0)",
    "CHECK (schedule_type <> 'timesPerWeek' OR times_per_week IS NOT NULL)",
  ];
}
