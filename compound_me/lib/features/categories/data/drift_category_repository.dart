import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/database/guards.dart';
import 'package:compound_me/core/utils/clock.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/id.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/categories/domain/category_repository.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drift_category_repository.g.dart';

const _nameMaxLength = 30;

class DriftCategoryRepository implements CategoryRepository {
  DriftCategoryRepository(this._db, {this._clock = systemClock});

  final AppDatabase _db;
  final Clock _clock;

  DateTime get _now => toStoredUtc(_clock());

  @override
  Stream<List<Category>> watch(
    CategoryKind kind, {
    bool includeArchived = false,
  }) {
    final query = _db.select(_db.categories)
      ..where(
        (c) =>
            c.kind.equalsValue(kind) &
            (includeArchived ? const Constant(true) : c.archivedAt.isNull()),
      )
      ..orderBy([
        (c) => OrderingTerm.asc(c.sortOrder),
        (c) => OrderingTerm.asc(c.createdAt),
      ]);
    return query.watch().map((rows) => [for (final r in rows) r.toDomain()]);
  }

  @override
  Future<Category?> findById(String id) async => (await (_db.select(
    _db.categories,
  )..where((c) => c.id.equals(id))).getSingleOrNull())?.toDomain();

  @override
  Future<bool> isInUse(String id) async =>
      await _db.isReferenced('transactions', 'category_id', id) ||
      await _db.isReferenced('habits', 'category_id', id);

  @override
  Future<String> create(CategoryDraft draft) async {
    final name = validName(draft.name, maxLength: _nameMaxLength);
    final id = newId();
    final now = _now;
    await _db.transaction(() async {
      final maxOrder = _db.categories.sortOrder.max();
      final last =
          await (_db.selectOnly(_db.categories)
                ..addColumns([maxOrder])
                ..where(_db.categories.kind.equalsValue(draft.kind)))
              .map((r) => r.read(maxOrder))
              .getSingle();
      await _db
          .into(_db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: id,
              kind: draft.kind,
              customName: Value(name),
              iconKey: draft.iconKey,
              colorKey: draft.colorKey,
              sortOrder: Value((last ?? -1) + 1),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    return id;
  }

  @override
  Future<void> update(
    String id, {
    String? name,
    String? iconKey,
    String? colorKey,
  }) => _db.transaction(() async {
    final category = await _require(id);
    String? customName;
    if (name != null) {
      // Default categories keep their translated name.
      if (category.nameKey != null) {
        throw const ValidationException(ValidationError.defaultCategoryRename);
      }
      customName = validName(name, maxLength: _nameMaxLength);
    }
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        customName: customName == null
            ? const Value.absent()
            : Value(customName),
        iconKey: iconKey == null ? const Value.absent() : Value(iconKey),
        colorKey: colorKey == null ? const Value.absent() : Value(colorKey),
        updatedAt: Value(_now),
      ),
    );
  });

  @override
  Future<void> reorder(List<String> orderedIds) => _db.transaction(() async {
    final now = _now;
    for (final (index, id) in orderedIds.indexed) {
      await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(sortOrder: Value(index), updatedAt: Value(now)),
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
    if (await isInUse(id)) throw CategoryInUseException(id);
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  });

  Future<CategoryRow> _require(String id) async =>
      await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(id))).getSingleOrNull() ??
      (throw NotFoundException('category', id));

  Future<void> _setArchivedAt(String id, DateTime? archivedAt) async {
    final updated =
        await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
          CategoriesCompanion(
            archivedAt: Value(archivedAt),
            updatedAt: Value(_now),
          ),
        );
    if (updated == 0) throw NotFoundException('category', id);
  }
}

extension on CategoryRow {
  Category toDomain() => Category(
    id: id,
    kind: kind,
    nameKey: nameKey,
    customName: customName,
    iconKey: iconKey,
    colorKey: colorKey,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
    archivedAt: archivedAt,
  );
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) =>
    DriftCategoryRepository(ref.watch(appDatabaseProvider));
