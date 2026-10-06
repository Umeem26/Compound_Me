import 'dart:math' as math;

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
    expect(
      find.bySemanticsLabel('Keluar, dua puluh dua ribu rupiah'),
      findsOneWidget,
    );
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
    expect(
      find.bySemanticsLabel('Masuk, lima ratus ribu rupiah'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Keluar, lima puluh tujuh ribu rupiah'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Selisih, plus empat ratus empat puluh tiga ribu rupiah',
      ),
      findsOneWidget,
    );
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

  testApp('the month chip switches the summary to another month', (
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
    expect(
      find.bySemanticsLabel('Keluar, dua puluh dua ribu rupiah'),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel(RegExp('Ringkasan September')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agustus 2026'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Keluar, delapan puluh ribu rupiah'),
      findsOneWidget,
    );
    expect(find.text('Agustus'), findsOneWidget);
    expect(_balance('−Rp 102.000'), findsOneWidget, reason: 'balance is now');
  });

  testApp('the summary stays one row at 360 dp and text scale 1.3', (
    tester,
  ) async {
    await pumpApp(
      tester,
      now: _now,
      textScale: 1.3,
      physicalSize: const Size(720, 1520),
      devicePixelRatio: 2,
      seed: (db) async {
        final cash = await _wallet(db, 'Tunai', 0);
        await _add(
          db,
          cash,
          125000000,
          DateTime(2026, 9, 2, 7),
          category: 'catAllowance',
          kind: TransactionKind.income,
        );
        await _add(db, cash, 99999999, DateTime(2026, 9, 3, 7));
      },
    );

    expect(tester.takeException(), isNull);
    final amounts = [
      find.text('Rp 125.000.000'),
      find.text('Rp 99.999.999'),
      find.text('+Rp 25.000.001'),
    ];
    final card = tester.getRect(find.byType(PeriodSummaryCard));
    final boxes = <Rect>[];
    for (final amount in amounts) {
      final text = find.descendant(
        of: find.byType(PeriodSummaryCard),
        matching: amount,
      );
      expect(text, findsOneWidget);
      final box = tester.getRect(text);
      expect(card.contains(box.topLeft), isTrue);
      expect(card.contains(box.bottomRight), isTrue, reason: 'not cut off');
      boxes.add(box);
    }
    // Shrunk amounts are shorter, but all three sit on the same line.
    final lowestTop = boxes.map((b) => b.top).reduce(math.max);
    final highestBottom = boxes.map((b) => b.bottom).reduce(math.min);
    expect(lowestTop, lessThan(highestBottom), reason: 'one row');
  });

  group('a new day (one "today" source)', () {
    testApp('past midnight, "Hari ini" becomes "Kemarin" by itself', (
      tester,
    ) async {
      final clock = FakeClock(DateTime(2026, 9, 25, 23, 59, 30));
      await pumpApp(
        tester,
        clock: clock.call,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 0);
          await _add(db, cash, 22000, DateTime(2026, 9, 25, 12));
        },
      );
      expect(find.text('Hari ini'), findsOneWidget);
      expect(find.text('Jumat, 25 September'), findsOneWidget);

      clock.now = DateTime(2026, 9, 26, 0, 0, 5);
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();

      expect(find.text('Kemarin'), findsOneWidget);
      expect(find.text('Sabtu, 26 September'), findsOneWidget);
    });

    testApp('past the end of a month, the default month follows', (
      tester,
    ) async {
      final clock = FakeClock(DateTime(2026, 9, 30, 23, 59, 30));
      await pumpApp(
        tester,
        clock: clock.call,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 0);
          await _add(db, cash, 22000, DateTime(2026, 9, 30, 12));
        },
      );
      expect(find.text('September'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Keluar, dua puluh dua ribu rupiah'),
        findsOneWidget,
      );

      clock.now = DateTime(2026, 10, 1, 0, 0, 5);
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();

      expect(find.text('Oktober'), findsOneWidget);
      expect(find.bySemanticsLabel('Keluar, nol rupiah'), findsOneWidget);

      // History follows too, until a month is picked there.
      await tester.tap(find.text('Lihat semua'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppChip, 'Oktober 2026'), findsOneWidget);
    });

    testApp('a month picked by hand stays after midnight', (tester) async {
      final clock = FakeClock(DateTime(2026, 9, 30, 23, 59, 30));
      await pumpApp(
        tester,
        clock: clock.call,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 0);
          await _add(db, cash, 80000, DateTime(2026, 8, 3, 7));
        },
      );
      await tester.tap(find.bySemanticsLabel(RegExp('Ringkasan September')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agustus 2026'));
      await tester.pumpAndSettle();

      clock.now = DateTime(2026, 10, 1, 0, 0, 5);
      await tester.pump(const Duration(seconds: 31));
      await tester.pumpAndSettle();
      expect(find.text('Agustus'), findsOneWidget);
    });

    testApp('coming back to the app catches up with the clock', (tester) async {
      final clock = FakeClock(DateTime(2026, 9, 25, 21));
      await pumpApp(
        tester,
        clock: clock.call,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 0);
          await _add(db, cash, 22000, DateTime(2026, 9, 25, 12));
        },
      );
      expect(find.text('Selamat malam, Raka'), findsOneWidget);

      // The app slept in the background; its timer never ran.
      clock.now = DateTime(2026, 9, 26, 8);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.text('Selamat pagi, Raka'), findsOneWidget);
      expect(find.text('Kemarin'), findsOneWidget);
    });

    testApp('a new transaction takes the current time', (tester) async {
      final clock = FakeClock(DateTime(2026, 9, 25, 10, 5));
      await pumpApp(tester, clock: clock.call);

      // No boundary between 10.05 and 13.47, so no timer ran.
      clock.now = DateTime(2026, 9, 25, 13, 47);
      await tester.tap(find.byTooltip('Tambah transaksi'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Tanggal, Hari ini, 13.47'), findsOneWidget);
    });
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
