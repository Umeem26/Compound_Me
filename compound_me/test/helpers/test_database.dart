import 'package:compound_me/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fresh in-memory database (schema + seeded categories), closed after the
/// test.
AppDatabase openTestDatabase() {
  // Each test opens its own database on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// A controllable clock for repositories; advance it with [now].
class FakeClock {
  FakeClock(this.now);

  DateTime now;

  DateTime call() => now;
}
