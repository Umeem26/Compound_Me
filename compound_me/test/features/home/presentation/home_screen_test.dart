import 'package:compound_me/app.dart';
import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

/// Friday morning, 25 September 2026.
final _now = DateTime(2026, 9, 25, 8, 12);

Future<String> _wallet(AppDatabase db, String name, int balance) =>
    DriftWalletRepository(db).create(
      WalletDraft(
        name: name,
        type: WalletType.cash,
        iconKey: 'wallet',
        colorKey: 'teal',
        initialBalance: balance,
      ),
    );

Future<void> _add(
  AppDatabase db,
  String walletId,
  int amount,
  DateTime at, {
  String category = 'catFood',
  TransactionKind kind = TransactionKind.expense,
  String? note,
}) async {
  await DriftTransactionRepository(db).add(
    TransactionDraft(
      kind: kind,
      amount: amount,
      walletId: walletId,
      categoryId: await defaultCategoryId(db, category),
      occurredAt: at,
      note: note,
    ),
  );
}

Finder _key(String label) =>
    find.descendant(of: find.byType(AmountKeypad), matching: find.text(label));

Finder get _save => find.widgetWithText(PrimaryButton, 'Simpan');

/// Balance text inside the Home header only.
Finder _balance(String text) =>
    find.descendant(of: find.byType(BalanceHeader), matching: find.text(text));

void main() {
  testApp('saving an expense lowers the Home balance at once', (tester) async {
    await pumpApp(
      tester,
      now: _now,
      seed: (db) => _wallet(db, 'Tunai', 100000),
    );
    expect(_balance('Rp 100.000'), findsOneWidget);

    await tester.tap(find.byTooltip('Tambah transaksi'));
    await tester.pumpAndSettle();
    for (final key in ['2', '2', '000']) {
      await tester.tap(_key(key));
      await tester.pump();
    }
    await tester.tap(find.text('Makanan & minuman'));
    await tester.pump();
    await tester.tap(_save);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(_balance('Rp 78.000'), findsOneWidget);
    expect(find.text('Tersimpan'), findsOneWidget);
    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('Keluar Rp 22.000'), findsOneWidget);
    expect(find.byType(TransactionTile), findsOneWidget);

    // Undo in the snackbar takes the new expense back out.
    await tester.tap(find.text('Urungkan'));
    await tester.pumpAndSettle();
    expect(_balance('Rp 100.000'), findsOneWidget);
    expect(find.byType(TransactionTile), findsNothing);
  });

  testApp('Save stays disabled while the amount is 0', (tester) async {
    await pumpApp(
      tester,
      now: _now,
      seed: (db) async {
        final cash = await _wallet(db, 'Tunai', 100000);
        await _add(db, cash, 15000, DateTime(2026, 9, 24, 12));
      },
    );
    await tester.tap(find.byTooltip('Tambah transaksi'));
    await tester.pumpAndSettle();

    PrimaryButton button() => tester.widget<PrimaryButton>(_save);
    final chip = tester.widget<AppChip>(
      find.widgetWithText(AppChip, 'Makanan & minuman'),
    );
    expect(chip.selected, isTrue, reason: 'last category is preselected');
    expect(button().onPressed, isNull);

    await tester.tap(_key('5'));
    await tester.pump();
    expect(button().onPressed, isNotNull);

    await tester.longPress(find.bySemanticsLabel('Hapus satu angka'));
    await tester.pump();
    expect(button().onPressed, isNull, reason: 'cleared back to 0');
  });

  testApp('a first transaction needs a category chip before saving', (
    tester,
  ) async {
    await pumpApp(tester, now: _now);
    await tester.tap(find.text('Catat transaksi pertama'));
    await tester.pumpAndSettle();

    await tester.tap(_key('9'));
    await tester.pump();
    expect(tester.widget<PrimaryButton>(_save).onPressed, isNull);

    await tester.tap(find.text('Transportasi'));
    await tester.pump();
    expect(tester.widget<PrimaryButton>(_save).onPressed, isNotNull);
  });

  testApp('recent transactions are grouped per day with subtotals', (
    tester,
  ) async {
    await pumpApp(
      tester,
      now: _now,
      seed: (db) async {
        final cash = await _wallet(db, 'Tunai', 0);
        await _add(db, cash, 22000, DateTime(2026, 9, 25, 7), note: 'kopi');
        await _add(db, cash, 25000, DateTime(2026, 9, 25, 7, 30));
        await _add(
          db,
          cash,
          500000,
          DateTime(2026, 9, 24, 9),
          category: 'catAllowance',
          kind: TransactionKind.income,
        );
        await _add(db, cash, 10000, DateTime(2026, 9, 21, 9));
      },
    );

    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('−Rp 47.000'), findsOneWidget, reason: 'today');
    expect(find.text('Kemarin'), findsOneWidget);
    expect(find.text('+Rp 500.000'), findsWidgets);
    expect(find.text('Senin, 21 Sep'), findsOneWidget);
    expect(find.textContaining('kopi · Tunai'), findsOneWidget);
    expect(find.text('Masuk Rp 500.000'), findsOneWidget);
    expect(find.text('Keluar Rp 57.000'), findsOneWidget);
    expect(find.text('Selisih +Rp 443.000'), findsOneWidget);
  });

  testApp('Home lists at most ten transactions', (tester) async {
    await pumpApp(
      tester,
      now: _now,
      seed: (db) async {
        final cash = await _wallet(db, 'Tunai', 0);
        for (var i = 0; i < 12; i++) {
          await _add(db, cash, 1000 + i, DateTime(2026, 9, 25, 7, i));
        }
      },
    );
    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('−Rp 1.002'),
      300,
      scrollable: list,
    );
    expect(find.text('−Rp 1.001'), findsNothing, reason: 'the 11th oldest');
    expect(find.text('−Rp 1.000'), findsNothing);
  });

  testApp('the month pill switches the summary to another month', (
    tester,
  ) async {
    await pumpApp(
      tester,
      now: _now,
      seed: (db) async {
        final cash = await _wallet(db, 'Tunai', 0);
        await _add(db, cash, 22000, DateTime(2026, 9, 25, 7));
        await _add(db, cash, 80000, DateTime(2026, 8, 3, 7));
      },
    );
    expect(find.text('Keluar Rp 22.000'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Ringkasan September')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agustus 2026'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar Rp 80.000'), findsOneWidget);
    expect(find.text('Agustus'), findsOneWidget);
    expect(_balance('−Rp 102.000'), findsOneWidget, reason: 'balance is now');
  });

  testApp('the greeting reads naturally without a name', (tester) async {
    await pumpApp(tester, now: _now, prefs: {'userName': ''});

    expect(find.text('Selamat pagi'), findsOneWidget);
    expect(find.text('Jumat, 25 September'), findsOneWidget);
  });

  testApp('the greeting uses the name and the time of day', (tester) async {
    await pumpApp(tester, now: DateTime(2026, 9, 25, 19));

    expect(find.text('Selamat malam, Raka'), findsOneWidget);
  });

  testApp('See all opens the history above the bottom navigation', (
    tester,
  ) async {
    await pumpApp(tester, now: _now);

    await tester.tap(find.text('Lihat semua'));
    await tester.pumpAndSettle();
    expect(find.text('Transaksi'), findsWidgets);
    expect(find.byType(AppBottomNav), findsOneWidget);

    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Transaksi terbaru'), findsOneWidget);
  });

  group('hide balance (S-43)', () {
    testApp('with the setting on, balances start hidden; the eye shows them '
        'for this session only', (tester) async {
      await pumpApp(
        tester,
        now: _now,
        prefs: {'hideBalanceOnLaunch': true},
        seed: (db) => _wallet(db, 'Tunai', 100000),
      );

      expect(_balance('Rp ••••••'), findsOneWidget);
      expect(find.text('Rp 100.000'), findsNothing);
      expect(find.bySemanticsLabel('Saldo disembunyikan'), findsOneWidget);

      await tester.tap(find.byTooltip('Tampilkan saldo'));
      await tester.pumpAndSettle();
      expect(_balance('Rp 100.000'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CompoundMeApp)),
      );
      expect(
        container.read(appPreferencesProvider).hideBalanceOnLaunch,
        isTrue,
        reason: 'the setting is untouched',
      );
      expect(container.read(hideBalanceOnLaunchProvider), isTrue);

      // Wallets (S-41) follow the same state.
      await goTo(tester, AppRoutes.wallets);
      expect(find.text('Rp 100.000'), findsNWidgets(2), reason: 'total, row');
      await tester.tap(find.byTooltip('Sembunyikan saldo'));
      await tester.pumpAndSettle();
      expect(find.text('Rp ••••••'), findsNWidgets(2));
      expect(find.text('Rp 100.000'), findsNothing);
    });

    testApp('with the setting off, balances show at launch', (tester) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) => _wallet(db, 'Tunai', 100000),
      );

      expect(_balance('Rp 100.000'), findsOneWidget);
      expect(find.text('Rp ••••••'), findsNothing);
    });

    testApp('transaction amounts are never hidden', (tester) async {
      await pumpApp(
        tester,
        now: _now,
        prefs: {'hideBalanceOnLaunch': true},
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 100000);
          await _add(db, cash, 22000, DateTime(2026, 9, 25, 7));
        },
      );

      expect(_balance('Rp ••••••'), findsOneWidget);
      expect(find.text('−Rp 22.000'), findsWidgets);
    });
  });
}
