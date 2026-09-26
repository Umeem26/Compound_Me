import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/database/guards.dart';
import 'package:compound_me/core/utils/clock.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/id.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/habits/data/habit_ledger.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_repository.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drift_habit_repository.g.dart';

const _nameMaxLength = 40;

class DriftHabitRepository implements HabitRepository {
  DriftHabitRepository(this._db, {this._clock = systemClock})
    : _ledger = HabitLedger(_db);

  final AppDatabase _db;
  final Clock _clock;
  final HabitLedger _ledger;

  /// Toggles in progress per habit and day. v1 double-charged when a tap
  /// landed twice before the first write finished.
  final Map<String, Future<int>> _pendingToggles = {};

  DateTime get _now => toStoredUtc(_clock());
  LocalDate get _today => LocalDate.fromDateTime(_clock());

  @override
  Stream<List<Habit>> watchHabits({bool includeArchived = false}) {
    final query = _db.select(_db.habits)
      ..where(
        (h) => includeArchived ? const Constant(true) : h.archivedAt.isNull(),
      )
      ..orderBy([
        (h) => OrderingTerm.asc(h.sortOrder),
        (h) => OrderingTerm.asc(h.createdAt),
      ]);
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  @override
  Future<Habit?> findById(String id) async => (await _find(id))?.toDomain();

  @override
  Future<String> create(HabitDraft draft) async {
    final id = newId();
    final now = _now;
    await _db.transaction(() async {
      final fields = await _validated(draft);
      final maxOrder = _db.habits.sortOrder.max();
      final last = await (_db.selectOnly(
        _db.habits,
      )..addColumns([maxOrder])).map((r) => r.read(maxOrder)).getSingle();
      await _db
          .into(_db.habits)
          .insert(
            fields.copyWith(
              id: Value(id),
              sortOrder: Value((last ?? -1) + 1),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    });
    return id;
  }

  @override
  Future<void> update(String id, HabitDraft draft) => _db.transaction(() async {
    final habit = await _require(id);
    final fields = await _validated(draft);
    if (draft.kind != habit.kind && await _hasLogs(id)) {
      throw HabitHasLogsException(id);
    }
    await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
      fields.copyWith(updatedAt: Value(_now)),
    );
  });

  @override
  Future<void> reorder(List<String> orderedIds) => _db.transaction(() async {
    final now = _now;
    for (final (index, id) in orderedIds.indexed) {
      await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
        HabitsCompanion(sortOrder: Value(index), updatedAt: Value(now)),
      );
    }
  });

  @override
  Future<void> archive(String id) => _setArchivedAt(id, _now);

  @override
  Future<void> unarchive(String id) => _setArchivedAt(id, null);

  @override
  Future<void> delete(String id) => _db.transaction(() async {
    await _require(id);
    if (await _hasLogs(id)) throw HabitHasLogsException(id);
    await (_db.delete(_db.habits)..where((h) => h.id.equals(id))).go();
  });

  @override
  Stream<List<HabitLog>> watchLogs(
    String habitId, {
    LocalDate? from,
    LocalDate? to,
  }) {
    final query = _db.select(_db.habitLogs)
      ..where((l) {
        // YYYY-MM-DD strings sort like dates.
        var condition = l.habitId.equals(habitId);
        if (from != null) {
          condition &= l.date.isBiggerOrEqualValue(from.toIso());
        }
        if (to != null) condition &= l.date.isSmallerOrEqualValue(to.toIso());
        return condition;
      })
      ..orderBy([(l) => OrderingTerm.asc(l.date)]);
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  @override
  Stream<List<HabitLog>> watchLogsOn(LocalDate date) {
    final query = _db.select(_db.habitLogs)
      ..where((l) => l.date.equals(date.toIso()));
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  @override
  Future<int> toggleCheckIn(String habitId, LocalDate date) {
    final key = '$habitId|${date.toIso()}';
    final pending = _pendingToggles[key];
    if (pending != null) return pending;

    final future = _db.transaction(() async {
      final habit = await _require(habitId);
      _checkDate(date);
      final log = await _ledger.findLog(habitId, date);
      final target = (log?.count ?? 0) == 0 ? 1 : 0;
      return await _ledger.setCount(
        habit,
        date,
        target,
        now: _now,
        occurredAt: _occurredAt(date),
      );
    });
    _pendingToggles[key] = future;
    return future.whenComplete(() => _pendingToggles.remove(key));
  }

  @override
  Future<int> setCount(String habitId, LocalDate date, int count) =>
      _db.transaction(() async {
        final habit = await _require(habitId);
        _checkDate(date);
        final max = habit.kind == HabitKind.build
            ? 1
            : HabitRepository.maxDailyCount;
        if (count < 0 || count > max) {
          throw const ValidationException(ValidationError.countOutOfRange);
        }
        return await _ledger.setCount(
          habit,
          date,
          count,
          now: _now,
          occurredAt: _occurredAt(date),
        );
      });

  /// Check-ins for today happen now; backdated ones are placed at local noon
  /// so they never slide into a neighbouring day in UTC.
  DateTime _occurredAt(LocalDate date) =>
      toStoredUtc(date == _today ? _clock() : date.atLocalHour(12));

  void _checkDate(LocalDate date) {
    if (date.isAfter(_today)) {
      throw const ValidationException(ValidationError.futureDate);
    }
  }

  Future<bool> _hasLogs(String habitId) =>
      _db.isReferenced('habit_logs', 'habit_id', habitId);

  Future<HabitRow?> _find(String id) =>
      (_db.select(_db.habits)..where((h) => h.id.equals(id))).getSingleOrNull();

  Future<HabitRow> _require(String id) async =>
      await _find(id) ?? (throw NotFoundException('habit', id));

  Future<void> _setArchivedAt(String id, DateTime? archivedAt) async {
    final updated =
        await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
          HabitsCompanion(
            archivedAt: Value(archivedAt),
            updatedAt: Value(_now),
          ),
        );
    if (updated == 0) throw NotFoundException('habit', id);
  }

  /// Checks a draft against the rules of S-21 / PRD US-08.1 and returns the
  /// columns to write, with fields that do not apply to its kind or
  /// schedule cleared.
  Future<HabitsCompanion> _validated(HabitDraft draft) async {
    final name = validName(draft.name, maxLength: _nameMaxLength);
    final reduce = draft.kind == HabitKind.reduce;

    if (draft.scheduleType == ScheduleType.weekdays &&
        (draft.scheduleDays <= 0 || draft.scheduleDays > Weekdays.all)) {
      throw const ValidationException(ValidationError.scheduleNeedsDays);
    }
    final times = draft.timesPerWeek;
    if (draft.scheduleType == ScheduleType.timesPerWeek &&
        (times == null || times < 1 || times > 7)) {
      throw const ValidationException(ValidationError.timesPerWeekOutOfRange);
    }

    if (reduce) {
      final cost = draft.costPerOccurrence;
      if (cost == null || cost <= 0) {
        throw const ValidationException(ValidationError.reduceNeedsCost);
      }
      await _checkReduceWallet(draft.walletId);
      await _checkReduceCategory(draft.categoryId);
      final limit = draft.weeklyLimit;
      if (limit != null && limit < 0) {
        throw const ValidationException(ValidationError.countOutOfRange);
      }
    }

    return HabitsCompanion(
      name: Value(name),
      kind: Value(draft.kind),
      iconKey: Value(draft.iconKey),
      colorKey: Value(draft.colorKey),
      scheduleType: Value(draft.scheduleType),
      scheduleDays: Value(
        draft.scheduleType == ScheduleType.weekdays ? draft.scheduleDays : 0,
      ),
      timesPerWeek: Value(
        draft.scheduleType == ScheduleType.timesPerWeek ? times : null,
      ),
      costPerOccurrence: Value(reduce ? draft.costPerOccurrence : null),
      walletId: Value(reduce ? draft.walletId : null),
      categoryId: Value(reduce ? draft.categoryId : null),
      weeklyLimit: Value(reduce ? draft.weeklyLimit : null),
    );
  }

  Future<void> _checkReduceWallet(String? walletId) async {
    final wallet = walletId == null
        ? null
        : await (_db.select(
            _db.wallets,
          )..where((w) => w.id.equals(walletId))).getSingleOrNull();
    if (wallet == null) {
      throw const ValidationException(ValidationError.reduceNeedsWallet);
    }
    if (wallet.archivedAt != null) {
      throw const ValidationException(ValidationError.archivedReference);
    }
  }

  Future<void> _checkReduceCategory(String? categoryId) async {
    final category = categoryId == null
        ? null
        : await (_db.select(
            _db.categories,
          )..where((c) => c.id.equals(categoryId))).getSingleOrNull();
    if (category == null || category.kind != CategoryKind.expense) {
      throw const ValidationException(
        ValidationError.reduceNeedsExpenseCategory,
      );
    }
    if (category.archivedAt != null) {
      throw const ValidationException(ValidationError.archivedReference);
    }
  }
}

extension on HabitRow {
  Habit toDomain() => Habit(
    id: id,
    name: name,
    kind: kind,
    iconKey: iconKey,
    colorKey: colorKey,
    scheduleType: scheduleType,
    scheduleDays: scheduleDays,
    timesPerWeek: timesPerWeek,
    costPerOccurrence: costPerOccurrence,
    walletId: walletId,
    categoryId: categoryId,
    weeklyLimit: weeklyLimit,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
    archivedAt: archivedAt,
  );
}

extension on HabitLogRow {
  HabitLog toDomain() => HabitLog(
    id: id,
    habitId: habitId,
    date: LocalDate.parse(date),
    count: count,
  );
}

@Riverpod(keepAlive: true)
HabitRepository habitRepository(Ref ref) =>
    DriftHabitRepository(ref.watch(appDatabaseProvider));
