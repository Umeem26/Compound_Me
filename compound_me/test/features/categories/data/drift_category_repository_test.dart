import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/categories/domain/category_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

const _now = '2026-09-27T10:00:00.000Z';

CategoryDraft _custom(
  String name, {
  CategoryKind kind = CategoryKind.expense,
}) => CategoryDraft(kind: kind, name: name, iconKey: 'gift', colorKey: 'rose');

Matcher _rejects(ValidationError error) =>
    throwsA(isA<ValidationException>().having((e) => e.error, 'error', error));

void main() {
  late AppDatabase db;
  late DriftCategoryRepository categories;

  setUp(() {
    db = openTestDatabase();
    categories = DriftCategoryRepository(db);
  });

  test('lists the defaults of one kind in seed order', () async {
    final expense = await categories.watch(CategoryKind.expense).first;
    final income = await categories.watch(CategoryKind.income).first;

    expect(expense.map((c) => c.nameKey), [
      'catFood',
      'catTransport',
      'catShopping',
      'catBills',
      'catEntertainment',
      'catHealth',
      'catEducation',
      'catOtherExpense',
    ]);
    expect(income, hasLength(4));
    expect(expense.every((c) => c.isDefault), isTrue);
  });

  test('custom categories get a trimmed name and go last', () async {
    final id = await categories.create(_custom('  Kopi  '));
    final expense = await categories.watch(CategoryKind.expense).first;

    expect(expense.last.id, id);
    expect(expense.last.customName, 'Kopi');
    expect(expense.last.isDefault, isFalse);
    await expectLater(
      categories.create(_custom(' ')),
      _rejects(ValidationError.nameEmpty),
    );
  });

  group('delete', () {
    test('rejects a category used by a transaction', () async {
      final wallet = await seedWallet(db);
      final food = await defaultCategoryId(db, 'catFood');
      await db.customStatement(
        'INSERT INTO transactions (id, kind, amount, wallet_id, category_id, '
        "occurred_at, created_at, updated_at) VALUES ('t', 'expense', 100, "
        "'$wallet', '$food', '$_now', '$_now', '$_now')",
      );

      expect(await categories.isInUse(food), isTrue);
      await expectLater(
        categories.delete(food),
        throwsA(isA<CategoryInUseException>()),
      );
    });

    test('rejects a category used only by a deleted transaction', () async {
      final wallet = await seedWallet(db);
      final id = await categories.create(_custom('Kopi'));
      await db.customStatement(
        'INSERT INTO transactions (id, kind, amount, wallet_id, category_id, '
        "occurred_at, deleted_at, created_at, updated_at) VALUES ('t', "
        "'expense', 100, '$wallet', '$id', '$_now', '$_now', '$_now', "
        "'$_now')",
      );

      await expectLater(
        categories.delete(id),
        throwsA(isA<CategoryInUseException>()),
      );
    });

    test('rejects a category used by a habit', () async {
      final wallet = await seedWallet(db);
      final id = await categories.create(_custom('Kopi'));
      await db.customStatement(
        'INSERT INTO habits (id, name, kind, icon_key, color_key, '
        'schedule_type, cost_per_occurrence, wallet_id, category_id, '
        "created_at, updated_at) VALUES ('h', 'Kopi', 'reduce', 'gift', "
        "'teal', 'daily', 25000, '$wallet', '$id', '$_now', '$_now')",
      );

      await expectLater(
        categories.delete(id),
        throwsA(isA<CategoryInUseException>()),
      );
    });

    test('removes an unused category', () async {
      final id = await categories.create(_custom('Kopi'));

      expect(await categories.isInUse(id), isFalse);
      await categories.delete(id);
      expect(await categories.findById(id), isNull);
    });
  });

  test('archive hides a category until it is restored', () async {
    final food = await defaultCategoryId(db, 'catFood');

    await categories.archive(food);
    final visible = await categories.watch(CategoryKind.expense).first;
    final all = await categories
        .watch(CategoryKind.expense, includeArchived: true)
        .first;
    expect(visible.map((c) => c.id), isNot(contains(food)));
    expect(all.firstWhere((c) => c.id == food).isArchived, isTrue);

    await categories.unarchive(food);
    expect(
      (await categories.watch(CategoryKind.expense).first).map((c) => c.id),
      contains(food),
    );
  });

  test('defaults keep their translated name but can change look', () async {
    final food = await defaultCategoryId(db, 'catFood');

    await expectLater(
      categories.update(food, name: 'Makan'),
      _rejects(ValidationError.defaultCategoryRename),
    );
    await categories.update(food, iconKey: 'gift', colorKey: 'gold');
    final updated = (await categories.findById(food))!;
    expect(updated.iconKey, 'gift');
    expect(updated.colorKey, 'gold');
    expect(updated.nameKey, 'catFood');
  });

  test('custom categories can be renamed and reordered', () async {
    final kopi = await categories.create(_custom('Kopi'));
    await categories.update(kopi, name: 'Kopi susu');
    expect((await categories.findById(kopi))!.customName, 'Kopi susu');

    final food = await defaultCategoryId(db, 'catFood');
    await categories.reorder([kopi, food]);
    final expense = await categories.watch(CategoryKind.expense).first;
    expect(expense.take(2).map((c) => c.id), [kopi, food]);
    await expectLater(
      categories.archive('missing'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
