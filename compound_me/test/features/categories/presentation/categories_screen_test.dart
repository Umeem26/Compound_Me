import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Plain queries only: awaiting a Drift stream in the test body would wait
/// on a timer that fake time never fires.
Future<CategoryRow?> _byName(AppDatabase db, String name) => (db.select(
  db.categories,
)..where((c) => c.customName.equals(name))).getSingleOrNull();

void main() {
  testApp('shows the default categories of each kind', (tester) async {
    await pumpApp(tester);
    await goTo(tester, AppRoutes.categories);

    expect(find.text('Makanan & minuman'), findsOneWidget);
    expect(find.text('Uang saku / gaji'), findsNothing);

    await _tap(tester, find.text('Pemasukan'));
    expect(find.text('Uang saku / gaji'), findsOneWidget);
    expect(find.text('Makanan & minuman'), findsNothing);
  });

  testApp('a category in use can only be archived, with undo', (tester) async {
    await pumpApp(
      tester,
      seed: (db) async {
        final wallet = await seedWallet(db);
        await DriftTransactionRepository(db).add(
          TransactionDraft(
            kind: TransactionKind.expense,
            amount: 20000,
            walletId: wallet,
            categoryId: await defaultCategoryId(db, 'catFood'),
            occurredAt: DateTime(2026, 9, 26, 12),
          ),
        );
      },
    );
    await goTo(tester, AppRoutes.categories);

    await _tap(tester, find.text('Makanan & minuman'));
    expect(find.text('Ubah kategori'), findsOneWidget);
    expect(
      find.text('Nama kategori bawaan mengikuti bahasa aplikasi.'),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(find.text('Hapus kategori'), findsNothing);

    await _tap(tester, find.text('Arsipkan kategori'));
    expect(find.text('Kategori diarsipkan'), findsOneWidget);
    expect(find.text('Diarsipkan (1)'), findsOneWidget);

    await _tap(tester, find.text('Urungkan'));
    expect(find.text('Makanan & minuman'), findsOneWidget);
    expect(find.textContaining('Diarsipkan'), findsNothing);
  });

  testApp('a custom category is added, then deleted with undo', (tester) async {
    final db = await pumpApp(tester);
    await goTo(tester, AppRoutes.categories);

    await _tap(tester, find.text('Tambah kategori'));
    expect(find.text('Kategori baru'), findsOneWidget);
    await _tap(tester, find.text('Simpan'));
    expect(find.text('Nama belum diisi.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Kopi');
    await _tap(tester, find.bySemanticsLabel('Koral'));
    await _tap(tester, find.text('Simpan'));

    expect(find.text('Kopi'), findsOneWidget);
    expect((await _byName(db, 'Kopi'))!.colorKey, 'coral');

    await _tap(tester, find.text('Kopi'));
    expect(find.text('Arsipkan kategori'), findsNothing);
    await _tap(tester, find.text('Hapus kategori'));
    expect(find.text('Kategori dihapus'), findsOneWidget);
    expect(find.text('Kopi'), findsNothing);
    expect(await _byName(db, 'Kopi'), isNull);

    await _tap(tester, find.text('Urungkan'));
    expect(find.text('Kopi'), findsOneWidget);
  });
}
