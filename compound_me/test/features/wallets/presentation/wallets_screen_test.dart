import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

Future<String> _wallet(
  AppDatabase db,
  String name, {
  WalletType type = WalletType.bank,
  int balance = 0,
}) => DriftWalletRepository(db).create(
  WalletDraft(
    name: name,
    type: type,
    iconKey: type.defaultIconKey,
    colorKey: 'blue',
    initialBalance: balance,
  ),
);

Future<void> _spend(AppDatabase db, String walletId, int amount) async {
  await DriftTransactionRepository(db).add(
    TransactionDraft(
      kind: TransactionKind.expense,
      amount: amount,
      walletId: walletId,
      categoryId: await defaultCategoryId(db, 'catFood'),
      occurredAt: DateTime(2026, 9, 26, 12),
    ),
  );
}

/// Plain queries only: awaiting a Drift stream in the test body would wait
/// on a timer that fake time never fires.
Future<List<WalletRow>> _archived(AppDatabase db) =>
    (db.select(db.wallets)..where((w) => w.archivedAt.isNotNull())).get();

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testApp('lists active wallets with their balance and the total', (
    tester,
  ) async {
    await pumpApp(
      tester,
      seed: (db) async {
        await _wallet(db, 'Tunai', type: WalletType.cash, balance: 100000);
        final bank = await _wallet(db, 'BCA', balance: 250000);
        await _spend(db, bank, 50000);
      },
    );
    await goTo(tester, AppRoutes.wallets);

    expect(find.text('Dompet'), findsWidgets);
    expect(find.text('Rp 100.000'), findsOneWidget);
    expect(find.text('Rp 200.000'), findsOneWidget, reason: '250k − 50k');
    expect(find.text('Rp 300.000'), findsOneWidget, reason: 'total');
    expect(find.text('Tambah dompet'), findsOneWidget);
  });

  testApp('a wallet with transactions can only be archived, with undo', (
    tester,
  ) async {
    await pumpApp(
      tester,
      seed: (db) async {
        await _wallet(db, 'Tunai', type: WalletType.cash);
        final bank = await _wallet(db, 'BCA');
        await _spend(db, bank, 10000);
      },
    );
    await goTo(tester, AppRoutes.wallets);

    await _tap(tester, find.text('BCA'));
    expect(find.text('Ubah dompet'), findsOneWidget);
    expect(find.text('Arsipkan dompet'), findsOneWidget);
    expect(find.text('Hapus dompet'), findsNothing);

    await _tap(tester, find.text('Arsipkan dompet'));
    expect(find.text('Dompet diarsipkan'), findsOneWidget);
    expect(find.text('Diarsipkan (1)'), findsOneWidget);
    expect(find.text('BCA'), findsNothing, reason: 'folded away');

    await _tap(tester, find.text('Urungkan'));
    expect(find.text('BCA'), findsOneWidget);
    expect(find.textContaining('Diarsipkan'), findsNothing);
  });

  testApp('an unused wallet is deleted, and undo brings it back', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      seed: (db) async {
        await _wallet(db, 'Tunai', type: WalletType.cash);
        await _wallet(db, 'GoPay', type: WalletType.ewallet);
      },
    );
    await goTo(tester, AppRoutes.wallets);

    await _tap(tester, find.text('GoPay'));
    expect(find.text('Arsipkan dompet'), findsNothing);
    await _tap(tester, find.text('Hapus dompet'));
    expect(find.text('Dompet dihapus'), findsOneWidget);
    expect(find.text('GoPay'), findsNothing);
    expect(await _archived(db), isEmpty);

    await _tap(tester, find.text('Urungkan'));
    expect(find.text('GoPay'), findsOneWidget);
  });

  testApp('the last active wallet cannot be archived', (tester) async {
    final db = await pumpApp(
      tester,
      seed: (db) async {
        final cash = await _wallet(db, 'Tunai', type: WalletType.cash);
        await _spend(db, cash, 10000);
      },
    );
    await goTo(tester, AppRoutes.wallets);

    // Name and type label are both "Tunai"; the name comes first.
    await _tap(tester, find.text('Tunai').first);
    expect(find.text('Minimal harus ada satu dompet aktif.'), findsOneWidget);
    await _tap(tester, find.text('Arsipkan dompet'));

    expect(find.text('Ubah dompet'), findsOneWidget, reason: 'still here');
    expect(await _archived(db), isEmpty);
  });

  testApp('a new wallet needs a name and then appears in the list', (
    tester,
  ) async {
    // The default onboarded app already has one "Tunai" cash wallet.
    final db = await pumpApp(tester);
    await goTo(tester, AppRoutes.wallets);

    await _tap(tester, find.text('Tambah dompet'));
    expect(find.text('Dompet baru'), findsOneWidget);
    await _tap(tester, find.text('Simpan'));
    expect(find.text('Nama belum diisi.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'GoPay');
    await _tap(tester, find.bySemanticsLabel('Tipe, Tunai'));
    await _tap(tester, find.text('E-wallet'));
    await _tap(tester, find.bySemanticsLabel('Hijau'));
    await _tap(tester, find.text('Simpan'));

    expect(find.text('GoPay'), findsOneWidget);
    final saved = await (db.select(
      db.wallets,
    )..where((w) => w.name.equals('GoPay'))).getSingle();
    expect(saved.type, WalletType.ewallet);
    expect(saved.iconKey, 'deviceMobile', reason: 'icon follows the type');
    expect(saved.colorKey, 'green');
  });
}
