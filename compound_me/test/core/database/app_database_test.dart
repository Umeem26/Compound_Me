import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/database/seed.dart';
import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/l10n/app_localizations.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

const _now = '2026-09-27T10:00:00.000Z';

Future<void> _insertWallet(AppDatabase db, {String id = 'w1'}) =>
    db.customStatement(
      'INSERT INTO wallets (id, name, type, icon_key, color_key, '
      "initial_balance, created_at, updated_at) VALUES ('$id', 'Tunai', "
      "'cash', 'wallet', 'teal', 0, '$_now', '$_now')",
    );

Future<String> _expenseCategoryId(AppDatabase db) async {
  final row = await (db.select(
    db.categories,
  )..where((c) => c.nameKey.equals('catFood'))).getSingle();
  return row.id;
}

void main() {
  group('schema', () {
    test('enables foreign keys on open', () async {
      final db = openTestDatabase();
      final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(row.data.values.single, 1);
    });

    test('seeds 8 expense and 4 income default categories', () async {
      final db = openTestDatabase();
      final rows = await db.select(db.categories).get();

      expect(rows, hasLength(12));
      expect(rows.where((r) => r.kind == CategoryKind.expense), hasLength(8));
      expect(rows.where((r) => r.kind == CategoryKind.income), hasLength(4));
      expect(
        rows.map((r) => r.nameKey).toSet(),
        defaultCategories.map((c) => c.nameKey).toSet(),
      );
      expect(rows.every((r) => r.customName == null), isTrue);
    });

    test('every default category has an icon, a preset color and a '
        'translation in id and en', () async {
      final l10nId = lookupAppLocalizations(const Locale('id'));
      final l10nEn = lookupAppLocalizations(const Locale('en'));
      final presetKeys = AppPresetColor.values.map((c) => c.key).toSet();

      for (final category in defaultCategories) {
        expect(AppIcons.byKey, contains(category.iconKey));
        expect(presetKeys, contains(category.colorKey));
        expect(defaultCategoryName(l10nId, category.nameKey), isNotEmpty);
        expect(defaultCategoryName(l10nEn, category.nameKey), isNotEmpty);
      }
      expect(defaultCategoryName(l10nId, 'catFood'), 'Makanan & minuman');
      expect(defaultCategoryName(l10nEn, 'catFood'), 'Food & drinks');
    });

    test('upgrades the empty phase 0 schema by creating and seeding', () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final db = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) => raw.execute('PRAGMA user_version = 1'),
        ),
      );
      addTearDown(db.close);

      expect(await db.select(db.categories).get(), hasLength(12));
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 2);
    });
  });

  group('CHECK and foreign key constraints', () {
    test('reject a category with both or neither name', () async {
      final db = openTestDatabase();
      Future<void> insert(String nameKey, String customName) =>
          db.customStatement(
            'INSERT INTO categories (id, kind, name_key, custom_name, '
            "icon_key, color_key, created_at, updated_at) VALUES ('c', "
            "'expense', $nameKey, $customName, 'gift', 'teal', '$_now', "
            "'$_now')",
          );

      await expectLater(insert("'catX'", "'Kopi'"), throwsA(isA<Exception>()));
      await expectLater(insert('NULL', 'NULL'), throwsA(isA<Exception>()));
    });

    test('reject a wallet with a negative balance or a long name', () async {
      final db = openTestDatabase();
      await expectLater(
        db.customStatement(
          'INSERT INTO wallets (id, name, type, icon_key, color_key, '
          "initial_balance, created_at, updated_at) VALUES ('w', 'Tunai', "
          "'cash', 'wallet', 'teal', -1, '$_now', '$_now')",
        ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        db.customStatement(
          'INSERT INTO wallets (id, name, type, icon_key, color_key, '
          "initial_balance, created_at, updated_at) VALUES ('w', "
          "'${'x' * 31}', 'cash', 'wallet', 'teal', 0, '$_now', '$_now')",
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'reject a transaction with a zero amount or an unknown wallet',
      () async {
        final db = openTestDatabase();
        await _insertWallet(db);
        final categoryId = await _expenseCategoryId(db);
        Future<void> insert(int amount, String walletId) => db.customStatement(
          'INSERT INTO transactions (id, kind, amount, wallet_id, category_id, '
          "occurred_at, created_at, updated_at) VALUES ('t', 'expense', "
          "$amount, '$walletId', '$categoryId', '$_now', '$_now', '$_now')",
        );

        await expectLater(insert(0, 'w1'), throwsA(isA<Exception>()));
        await expectLater(insert(100, 'missing'), throwsA(isA<Exception>()));
        await insert(100, 'w1');
      },
    );

    test('keep a wallet that still has transactions', () async {
      final db = openTestDatabase();
      await _insertWallet(db);
      final categoryId = await _expenseCategoryId(db);
      await db.customStatement(
        'INSERT INTO transactions (id, kind, amount, wallet_id, category_id, '
        "occurred_at, created_at, updated_at) VALUES ('t', 'expense', 100, "
        "'w1', '$categoryId', '$_now', '$_now', '$_now')",
      );

      await expectLater(
        db.customStatement("DELETE FROM wallets WHERE id = 'w1'"),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'reject a reduce habit without cost and a malformed log date',
      () async {
        final db = openTestDatabase();
        await expectLater(
          db.customStatement(
            'INSERT INTO habits (id, name, kind, icon_key, color_key, '
            "schedule_type, created_at, updated_at) VALUES ('h', 'Kopi', "
            "'reduce', 'gift', 'teal', 'daily', '$_now', '$_now')",
          ),
          throwsA(isA<Exception>()),
        );
        await db.customStatement(
          'INSERT INTO habits (id, name, kind, icon_key, color_key, '
          "schedule_type, created_at, updated_at) VALUES ('h', 'Baca', "
          "'build', 'gift', 'teal', 'daily', '$_now', '$_now')",
        );
        await expectLater(
          db.customStatement(
            'INSERT INTO habit_logs (id, habit_id, date, count, created_at, '
            "updated_at) VALUES ('l', 'h', '27-09-2026', 1, '$_now', '$_now')",
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('allow only one log per habit and day', () async {
      final db = openTestDatabase();
      await db.customStatement(
        'INSERT INTO habits (id, name, kind, icon_key, color_key, '
        "schedule_type, created_at, updated_at) VALUES ('h', 'Baca', "
        "'build', 'gift', 'teal', 'daily', '$_now', '$_now')",
      );
      Future<void> log(String id) => db.customStatement(
        'INSERT INTO habit_logs (id, habit_id, date, count, created_at, '
        "updated_at) VALUES ('$id', 'h', '2026-09-27', 1, '$_now', '$_now')",
      );

      await log('l1');
      await expectLater(log('l2'), throwsA(isA<Exception>()));
    });
  });
}
