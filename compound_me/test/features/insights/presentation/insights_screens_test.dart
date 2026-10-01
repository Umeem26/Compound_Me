import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/settings/data/debug_sample_data.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/presentation/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

/// Friday morning, 25 September 2026.
final _now = DateTime(2026, 9, 25, 8, 12);

/// 60 days of sample data: Kopi 3 times a week at Rp 25.000 and more.
Future<void> _sample(AppDatabase db) async {
  await seedWallet(db, initialBalance: 0);
  await DebugSampleData(db, clock: () => _now).fill();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// The weekly limit stored on the sample coffee habit.
Future<int?> _coffeeLimit(AppDatabase db) async {
  final row = await (db.select(
    db.habits,
  )..where((h) => h.name.equals('Kopi'))).getSingle();
  return row.weeklyLimit;
}

void main() {
  testApp('under a week of data Insights shows how far along it is', (
    tester,
  ) async {
    await pumpApp(
      tester,
      now: _now,
      seed: (db) async {
        final wallet = await seedWallet(db);
        await DriftTransactionRepository(db, clock: () => _now).add(
          TransactionDraft(
            kind: TransactionKind.expense,
            amount: 22000,
            walletId: wallet,
            categoryId: await defaultCategoryId(db, 'catFood'),
            occurredAt: DateTime(2026, 9, 23, 12).toUtc(),
          ),
        );
      },
    );

    await goTo(tester, AppRoutes.insights);

    expect(find.text('Wawasan muncul setelah seminggu mencatat'), findsOne);
    expect(find.text('3 dari 7 hari'), findsOne);
    expect(find.byType(CategoryDonut), findsNothing);
  });

  testApp('with 60 days of data the numbers add up for Kopi', (tester) async {
    await pumpApp(tester, now: _now, seed: _sample);

    await goTo(tester, AppRoutes.insights);

    // 11 coffees in September (Mon, Wed, Fri up to the 25th) at Rp 25.000.
    expect(find.text('Kebiasaan yang dikurangi'), findsOne);
    expect(find.text('Rp 275.000'), findsOneWidget);
    expect(find.text('±3,0x/minggu · Rp 3,9 jt/th'), findsOneWidget);
    expect(find.text('Kebiasaan yang dibangun'), findsOne);
    await _scrollTo(tester, find.text('Pengeluaran per kategori'));
    expect(find.byType(CategoryDonut), findsOne);
    expect(find.text('Makanan & minuman'), findsOneWidget);
  });

  testApp('a category row opens the history filtered by it', (tester) async {
    await pumpApp(tester, now: _now, seed: _sample);
    await goTo(tester, AppRoutes.insights);

    await _scrollTo(tester, find.text('Makanan & minuman'));
    await tester.tap(find.text('Makanan & minuman'));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionsScreen), findsOne);
  });

  testApp('the simulator: 50% of Kopi is Rp 1.950.000 a year', (tester) async {
    final db = await pumpApp(tester, now: _now, seed: _sample);
    await goTo(tester, AppRoutes.insights);

    await tester.tap(find.text('Kopi'));
    await tester.pumpAndSettle();

    expect(find.text('Kalau Kopi dikurangi…'), findsOne);
    // 3 a week x Rp 25.000 x 52 weeks = Rp 3.900.000, half of it.
    expect(find.text('50%'), findsOne);
    expect(find.text('±Rp 1.950.000'), findsOne);
    expect(find.text('Simulasi, bukan saran keuangan.'), findsOne);

    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOne);
    expect(find.text('±Rp 3.900.000'), findsOne);

    await tester.drag(find.byType(Slider), const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(find.text('0%'), findsOne);
    expect(find.text('±Rp 0'), findsOne);

    // Just looking at a simulation changes nothing.
    expect(await _coffeeLimit(db), isNull);
  });

  testApp('save and grow shows 1, 3 and 5 years, disclaimer stays', (
    tester,
  ) async {
    await pumpApp(tester, now: _now, seed: _sample);
    await goTo(tester, AppRoutes.insights);
    await tester.tap(find.text('Kopi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tabung & kembangkan'));
    await tester.pumpAndSettle();

    // 0 %: the savings added up.
    expect(find.text('1 tahun'), findsOne);
    expect(find.text('Rp 1.950.000'), findsOneWidget);
    expect(find.text('Rp 5.850.000'), findsOne);
    expect(find.text('Rp 9.750.000'), findsOne);
    expect(find.text('Simulasi, bukan saran keuangan.'), findsOne);

    // 5 % a year on Rp 162.500 a month: about Rp 1.995.000 after a year.
    await tester.tap(find.widgetWithText(AppChip, '5%'));
    await tester.pumpAndSettle();
    expect(find.text('Rp 1.995.000'), findsOne);
    expect(find.text('Simulasi, bukan saran keuangan.'), findsOne);

    await tester.enterText(find.byType(TextField), '250');
    await tester.pumpAndSettle();
    expect(find.text('Isi angka antara 0 dan 100.'), findsOne);
  });

  testApp('the simulator writes the weekly limit into the habit', (
    tester,
  ) async {
    final db = await pumpApp(tester, now: _now, seed: _sample);
    await goTo(tester, AppRoutes.insights);
    await tester.tap(find.text('Kopi'));
    await tester.pumpAndSettle();
    expect(find.text('Batas mingguan sesuai simulasi: 2 kali'), findsOne);

    await tester.tap(find.text('Atur batas mingguan'));
    await tester.pumpAndSettle();

    expect(await _coffeeLimit(db), 2);
    expect(find.text('Batas mingguan diatur ke 2 kali'), findsOne);

    await tester.tap(find.text('Urungkan'));
    await tester.pumpAndSettle();
    expect(await _coffeeLimit(db), isNull);
  });

  testApp('Home offers the Kopi insight and opens the simulator', (
    tester,
  ) async {
    await pumpApp(tester, now: _now, seed: _sample);

    expect(find.text('Kopi sudah Rp 275.000 bulan ini.'), findsOne);
    await tester.tap(find.text('Lihat dampak'));
    await tester.pumpAndSettle();

    expect(find.text('Kalau Kopi dikurangi…'), findsOne);
  });

  testApp('Home has no insight card before a week of data', (tester) async {
    await pumpApp(tester, now: _now);

    expect(find.byType(InsightCard), findsNothing);
  });

  testApp('the habit detail has a working Simulasikan button', (tester) async {
    final db = await pumpApp(tester, now: _now, seed: _sample);
    final coffee = await (db.select(
      db.habits,
    )..where((h) => h.name.equals('Kopi'))).getSingle();
    await goTo(tester, AppRoutes.habit(coffee.id));

    await _scrollTo(tester, find.text('Simulasikan'));
    await tester.tap(find.text('Simulasikan'));
    await tester.pumpAndSettle();

    expect(find.text('Kalau Kopi dikurangi…'), findsOne);
  });

  testApp('Insights and the simulator hold up at text scale 1,3 on 360 dp', (
    tester,
  ) async {
    await pumpApp(
      tester,
      now: _now,
      seed: _sample,
      textScale: 1.3,
      physicalSize: const Size(1080, 2160),
      devicePixelRatio: 3,
    );
    await goTo(tester, AppRoutes.insights);
    await tester.tap(find.text('Kopi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tabung & kembangkan'));
    await tester.pumpAndSettle();
    expect(find.text('Simulasi, bukan saran keuangan.'), findsOne);

    // At this size the sheet covers the screen; close it, then check the
    // rest of the screen.
    Navigator.of(
      tester.element(find.text('Simulasi, bukan saran keuangan.')),
    ).pop();
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Pengeluaran per kategori'));
    await _scrollTo(tester, find.byType(CategoryDonut));

    expect(tester.takeException(), isNull);
  });
}
