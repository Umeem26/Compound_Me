import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/presentation/transactions_screen.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:flutter/material.dart';
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

Future<String> _add(
  AppDatabase db,
  String walletId,
  int amount,
  DateTime at, {
  String category = 'catFood',
  String? note,
}) async {
  final categoryId = await defaultCategoryId(db, category);
  return await DriftTransactionRepository(db).add(
    TransactionDraft(
      kind: TransactionKind.expense,
      amount: amount,
      walletId: walletId,
      categoryId: categoryId,
      occurredAt: at,
      note: note,
    ),
  );
}

/// Plain queries only: awaiting a Drift stream in the test body would wait
/// on a timer that fake time never fires.
Future<Map<String, int>> _balances(AppDatabase db) async {
  final rows = await db
      .customSelect(
        'SELECT w.name, w.initial_balance - COALESCE(SUM(t.amount), 0) AS b '
        'FROM wallets w LEFT JOIN transactions t '
        'ON t.wallet_id = w.id AND t.deleted_at IS NULL '
        'GROUP BY w.id',
      )
      .get();
  return {for (final r in rows) r.read<String>('name'): r.read<int>('b')};
}

Finder _balance(String text) =>
    find.descendant(of: find.byType(BalanceHeader), matching: find.text(text));

Finder _key(String label) =>
    find.descendant(of: find.byType(AmountKeypad), matching: find.text(label));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('detail (S-12)', () {
    testApp('delete, then undo brings the transaction and balance back', (
      tester,
    ) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 100000);
          await _add(db, cash, 22000, DateTime(2026, 9, 25, 7), note: 'kopi');
        },
      );
      expect(_balance('Rp 78.000'), findsOneWidget);

      await _tap(tester, find.byType(TransactionTile));
      expect(find.text('Jumat, 25 September 2026, 07.00'), findsOneWidget);
      expect(find.text('kopi'), findsOneWidget);

      await _tap(tester, find.byTooltip('Hapus'));
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Transaksi dihapus'), findsOneWidget);
      expect(find.byType(TransactionTile), findsNothing);
      expect(_balance('Rp 100.000'), findsOneWidget);

      await tester.tap(find.text('Urungkan'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionTile), findsOneWidget);
      expect(_balance('Rp 78.000'), findsOneWidget);
    });

    testApp('editing moves an expense to another wallet', (tester) async {
      late AppDatabase database;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          database = db;
          final cash = await _wallet(db, 'Tunai', 100000);
          await _wallet(db, 'Bank', 200000);
          await _add(db, cash, 22000, DateTime(2026, 9, 25, 7));
        },
      );

      await _tap(tester, find.byType(TransactionTile));
      await _tap(tester, find.text('Edit'));
      expect(find.text('Edit transaksi'), findsOneWidget);
      expect(find.text('22.000'), findsOneWidget);

      await _tap(tester, find.bySemanticsLabel('Dompet, Tunai'));
      await _tap(tester, find.text('Bank'));
      await _tap(tester, find.text('Simpan perubahan'));

      expect(find.text('Tersimpan'), findsOneWidget);
      expect(await _balances(database), {'Tunai': 100000, 'Bank': 178000});
      expect(_balance('Rp 278.000'), findsOneWidget);
    });

    testApp('a check-in expense asks before undoing the check-in', (
      tester,
    ) async {
      late AppDatabase database;
      late String coffee;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          database = db;
          final cash = await _wallet(db, 'Tunai', 100000);
          final habits = DriftHabitRepository(db);
          coffee = await habits.create(
            HabitDraft(
              name: 'Kopi',
              kind: HabitKind.reduce,
              iconKey: 'coffee',
              colorKey: 'coral',
              scheduleType: ScheduleType.daily,
              costPerOccurrence: 25000,
              walletId: cash,
              categoryId: await defaultCategoryId(db, 'catFood'),
            ),
          );
          await habits.setCount(coffee, LocalDate(2026, 9, 25), 1);
        },
      );
      expect(find.textContaining('Kebiasaan'), findsWidgets);

      await _tap(tester, find.byType(TransactionTile));
      expect(find.text('Dari kebiasaan: Kopi'), findsOneWidget);

      // Edit keeps the type and the day tied to the check-in.
      await _tap(tester, find.text('Edit'));
      expect(find.byType(SegmentedToggle<TransactionKind>), findsNothing);
      await _tap(tester, find.byTooltip('Tutup'));

      await _tap(tester, find.byType(TransactionTile));
      await _tap(tester, find.byTooltip('Hapus'));
      expect(
        find.text('Ini juga membatalkan check-in Kopi hari itu.'),
        findsOneWidget,
      );
      await _tap(tester, find.widgetWithText(GhostButton, 'Batal'));
      expect(find.byType(TransactionTile), findsOneWidget, reason: 'kept');

      await _tap(tester, find.byType(TransactionTile));
      await _tap(tester, find.byTooltip('Hapus'));
      await _tap(tester, find.widgetWithText(DestructiveButton, 'Hapus'));
      expect(find.byType(TransactionTile), findsNothing);
      final logs = await (database.select(
        database.habitLogs,
      )..where((l) => l.deletedAt.isNull())).get();
      expect(logs, isEmpty, reason: 'the check-in went with it');
    });
  });

  group('form (S-11)', () {
    testApp('closing with input asks first; without input it just closes', (
      tester,
    ) async {
      late AppDatabase database;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          database = db;
          await _wallet(db, 'Tunai', 0);
        },
      );
      await tester.tap(find.byTooltip('Tambah transaksi'));
      await tester.pumpAndSettle();
      final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(sheet.enableDrag, isFalse, reason: 'a drag would skip the guard');
      expect(sheet.showDragHandle, isFalse);

      await _tap(tester, find.byTooltip('Tutup'));
      expect(find.byType(BottomSheet), findsNothing, reason: 'nothing typed');

      await tester.tap(find.byTooltip('Tambah transaksi'));
      await tester.pumpAndSettle();
      await tester.tap(_key('7'));
      await tester.pump();

      await _tap(tester, find.byTooltip('Tutup'));
      expect(find.text('Buang perubahan?'), findsOneWidget);
      await _tap(tester, find.text('Lanjut edit'));
      expect(find.text('7'), findsWidgets, reason: 'still in the form');

      // System back asks the same.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Buang perubahan?'), findsOneWidget);
      await _tap(tester, find.text('Buang'));
      expect(find.byType(BottomSheet), findsNothing);
      expect(await database.select(database.transactions).get(), isEmpty);
    });

    testApp('income shows income categories and adds to the balance', (
      tester,
    ) async {
      await pumpApp(tester, now: _now);
      await tester.tap(find.byTooltip('Tambah transaksi'));
      await tester.pumpAndSettle();

      await _tap(tester, find.text('Pemasukan'));
      expect(find.text('Uang saku / gaji'), findsOneWidget);
      expect(find.text('Transportasi'), findsNothing);
      for (final key in ['5', '000']) {
        await tester.tap(_key(key));
        await tester.pump();
      }
      await _tap(tester, find.text('Uang saku / gaji'));
      await _tap(tester, find.text('Simpan'));

      expect(_balance('Rp 5.000'), findsOneWidget);
      expect(find.text('+Rp 5.000'), findsWidgets);
    });

    testApp('the note row opens a text field in place of the keypad', (
      tester,
    ) async {
      late AppDatabase database;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          database = db;
          final cash = await _wallet(db, 'Tunai', 0);
          await _add(db, cash, 1000, DateTime(2026, 9, 24, 12));
        },
      );
      await tester.tap(find.byTooltip('Tambah transaksi'));
      await tester.pumpAndSettle();
      await tester.tap(_key('9'));
      await tester.pump();

      await _tap(tester, find.bySemanticsLabel(RegExp('^Catatan')));
      expect(find.byType(AmountKeypad), findsNothing);
      // The amount moves up under the title, whole, instead of half
      // scrolled out of view.
      expect(find.byType(AmountDisplay), findsNothing);
      expect(
        find.descendant(
          of: find.byType(SheetHeader),
          matching: find.text('Rp 9'),
        ),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'nasi padang');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byType(AmountKeypad), findsOneWidget);
      expect(find.byType(AmountDisplay), findsOneWidget);
      await _tap(tester, find.text('Simpan'));

      final saved = await (database.select(
        database.transactions,
      )..where((t) => t.amount.equals(9))).getSingle();
      expect(saved.note, 'nasi padang');
    });
  });

  group('history (S-13)', () {
    Future<void> seedHistory(AppDatabase db) async {
      final cash = await _wallet(db, 'Tunai', 0);
      final bank = await _wallet(db, 'Bank', 0);
      await _add(db, cash, 22000, DateTime(2026, 9, 25, 7), note: 'kopi susu');
      await _add(
        db,
        bank,
        30000,
        DateTime(2026, 9, 20, 12),
        category: 'catBills',
      );
      await _add(
        db,
        cash,
        45000,
        DateTime(2026, 8, 10, 12),
        category: 'catTransport',
      );
    }

    testApp('the month is a strict filter; "Lihat" steps back a month', (
      tester,
    ) async {
      await pumpApp(tester, now: _now, seed: seedHistory);
      await goTo(tester, AppRoutes.transactions);

      expect(find.widgetWithText(AppChip, 'September 2026'), findsOneWidget);
      expect(find.byType(TransactionTile), findsNWidgets(2));
      expect(find.text('−Rp 45.000'), findsNothing, reason: 'August waits');
      expect(
        find.bySemanticsLabel('Keluar, lima puluh dua ribu rupiah'),
        findsOneWidget,
      );

      await _tap(tester, find.text('Lihat Agustus 2026'));
      expect(find.widgetWithText(AppChip, 'Agustus 2026'), findsOneWidget);
      expect(find.byType(TransactionTile), findsOneWidget);
      expect(
        find.bySemanticsLabel('Keluar, empat puluh lima ribu rupiah'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Lihat Juli'),
        findsNothing,
        reason: 'August holds the oldest transaction',
      );
    });

    testApp('an empty month offers the month before', (tester) async {
      await pumpApp(tester, now: DateTime(2026, 10, 2, 9), seed: seedHistory);
      await goTo(tester, AppRoutes.transactions);

      expect(find.text('Belum ada transaksi di Oktober 2026'), findsOneWidget);
      expect(find.bySemanticsLabel('Keluar, nol rupiah'), findsOneWidget);
      await _tap(tester, find.text('Lihat September 2026'));
      expect(find.byType(TransactionTile), findsNWidgets(2));
    });

    testApp('a search covers every month and sums its results', (tester) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          await seedHistory(db);
          final cash = (await db.select(db.wallets).get()).first.id;
          await _add(
            db,
            cash,
            12000,
            DateTime(2025, 12, 15, 8),
            note: 'kopi hitam',
          );
        },
      );
      await goTo(tester, AppRoutes.transactions);

      await tester.enterText(find.byType(TextField), 'kopi');
      await tester.pumpAndSettle();
      final month = tester.widget<AppChip>(
        find.widgetWithText(AppChip, 'Semua bulan'),
      );
      expect(month.onTap, isNull, reason: 'disabled while searching');
      expect(find.text('Hasil pencarian'), findsOneWidget);
      expect(find.byType(TransactionTile), findsNWidgets(2));
      expect(
        find.bySemanticsLabel('Keluar, tiga puluh empat ribu rupiah'),
        findsOneWidget,
      );
      expect(
        find.text('Senin, 15 Des 2025'),
        findsOneWidget,
        reason: 'another year shows its year',
      );
      expect(find.textContaining('Lihat '), findsNothing);

      await tester.enterText(find.byType(TextField), 'Transportasi');
      await tester.pumpAndSettle();
      expect(find.text('−Rp 45.000'), findsWidgets, reason: 'from August');
    });

    testApp('search results load in pages', (tester) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 0);
          for (var i = 0; i < searchPageSize + 10; i++) {
            await _add(
              db,
              cash,
              1000 + i,
              DateTime(2026, 9, 1, 6).add(Duration(hours: i)),
              note: 'parkir',
            );
          }
        },
      );
      await goTo(tester, AppRoutes.transactions);
      await tester.enterText(find.byType(TextField), 'parkir');
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('−Rp 1.000'),
        600,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('−Rp 1.000'),
        findsWidgets,
        reason: 'the oldest one sits on the second page',
      );
    });

    testApp('searches notes and translated category names', (tester) async {
      await pumpApp(tester, now: _now, seed: seedHistory);
      await goTo(tester, AppRoutes.transactions);

      await tester.enterText(find.byType(TextField), 'susu');
      await tester.pumpAndSettle();
      expect(find.byType(TransactionTile), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'tagih');
      await tester.pumpAndSettle();
      expect(find.text('Tagihan'), findsOneWidget);
      expect(find.byType(TransactionTile), findsOneWidget);
    });

    testApp('filters by wallet and category; no match offers a reset', (
      tester,
    ) async {
      await pumpApp(tester, now: _now, seed: seedHistory);
      await goTo(tester, AppRoutes.transactions);

      await _tap(tester, find.widgetWithText(AppChip, 'Dompet'));
      await _tap(tester, find.text('Bank').last);
      expect(find.byType(TransactionTile), findsOneWidget);
      expect(find.widgetWithText(AppChip, 'Bank'), findsOneWidget);

      await _tap(tester, find.widgetWithText(AppChip, 'Kategori'));
      await _tap(tester, find.text('Transportasi').last);
      expect(find.text('Tidak ada transaksi yang cocok'), findsOneWidget);

      expect(
        find.widgetWithText(GhostButton, 'Lihat Agustus 2026'),
        findsOneWidget,
      );

      await _tap(tester, find.text('Hapus filter'));
      expect(find.byType(TransactionTile), findsNWidgets(2));
    });

    testApp('the category filter tells same-named categories apart', (
      tester,
    ) async {
      await pumpApp(tester, now: _now, seed: seedHistory);
      await goTo(tester, AppRoutes.transactions);

      await _tap(tester, find.widgetWithText(AppChip, 'Kategori'));
      expect(find.text('Lainnya (Pengeluaran)'), findsOneWidget);
      expect(find.text('Lainnya (Pemasukan)'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Transportasi'),
        ),
        findsOneWidget,
        reason: 'a unique name stays as it is',
      );

      await _tap(tester, find.text('Lainnya (Pemasukan)'));
      expect(
        find.widgetWithText(AppChip, 'Lainnya (Pemasukan)'),
        findsOneWidget,
      );
    });

    testApp('swiping left deletes, with undo', (tester) async {
      late AppDatabase database;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          database = db;
          await seedHistory(db);
        },
      );
      await goTo(tester, AppRoutes.transactions);
      expect(find.byType(TransactionTile), findsNWidgets(2));

      await tester.drag(
        find.byType(TransactionTile).first,
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TransactionTile), findsOneWidget);
      expect(find.text('Transaksi dihapus'), findsOneWidget);

      await tester.tap(find.text('Urungkan'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionTile), findsNWidgets(2));
      final live = await (database.select(
        database.transactions,
      )..where((t) => t.deletedAt.isNull())).get();
      expect(live, hasLength(3));
    });

    testApp('with no transactions at all it offers to add one', (tester) async {
      await pumpApp(tester, now: _now);
      await goTo(tester, AppRoutes.transactions);

      expect(find.text('Belum ada transaksi'), findsOneWidget);
    });
  });
}
