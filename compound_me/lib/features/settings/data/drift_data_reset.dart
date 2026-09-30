import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/database/seed.dart';
import 'package:compound_me/core/utils/clock.dart';
import 'package:compound_me/features/settings/domain/data_reset.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drift_data_reset.g.dart';

class DriftDataReset implements DataReset {
  DriftDataReset(this._db, {this._clock = systemClock});

  final AppDatabase _db;
  final Clock _clock;

  @override
  Future<void> deleteEverything() => _db.transaction(() async {
    // Children before parents, so no foreign key blocks a delete.
    await _db.delete(_db.transactions).go();
    await _db.delete(_db.habitLogs).go();
    await _db.delete(_db.habits).go();
    await _db.delete(_db.categories).go();
    await _db.delete(_db.wallets).go();
    await seedDefaultCategories(_db, now: _clock());
  });
}

@Riverpod(keepAlive: true)
DataReset dataReset(Ref ref) => DriftDataReset(ref.watch(appDatabaseProvider));
